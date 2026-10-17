# Project X — API / Backend Contract (Draft)

## Conventions
- Base: Supabase project URL. Auth: `Authorization: Bearer <user JWT>`.
- Flutter contains only the Supabase publishable/anon key; never ship `service_role`.
- Phone login: Supabase Auth OTP. Normalize phone to E.164; never authenticate via a `profiles` lookup.
- Mutating calls include an `Idempotency-Key` UUID. Server binds key to authenticated user + operation + request hash.
- Money is stored as integer paise; times are `timestamptz` (UTC); render in user/provider timezone.
- Return structured errors: `400 validation_error`, `401 unauthenticated`, `403 forbidden`, `404 not_found`, `409 state_conflict`, `422 business_rule_failed`, `429 rate_limited`, `500 internal_error`.
- Proposed limits below are starting application policy, not Supabase default guarantees. Enforce edge/IP limits plus database business limits.

## Read APIs (PostgREST under RLS)
| Purpose | Suggested query/table | Rules | Initial limit |
|---|---|---|---|
| Active catalogue | `service_categories`, `services`, `service_variants` | Active records only; bounded pagination | 120/min/user |
| Own profile | `profiles` | `auth.uid() = id`; column allow-list for updates | 60/min/user |
| Own addresses | `addresses` | Owner-only CRUD | 30/min/user |
| Own booking list | `bookings` | Customer or assigned provider only; paginated | 60/min/user |
| Booking timeline | `booking_status_events` | Only booking participants | 60/min/user |
| Provider service cards | RPC/search endpoint | Approved provider + active mapping only; bounded radius/results | 30/min/user |
| Own notifications | `notifications` | `user_id = auth.uid()` | 60/min/user |

## RPCs (transactional)
### `create_booking(payload jsonb, idempotency_key text) -> booking summary`
1. Validate caller has active customer capability.
2. Resolve address and ensure caller owns it.
3. Validate each active service variant, quantity, provider/service eligibility and slot.
4. Ignore all client-submitted prices/taxes/totals; calculate on server.
5. Insert `bookings`, immutable `booking_items` snapshots, and initial `booking_status_events` atomically.
6. Store idempotency response; same key+same payload returns original booking; same key+different payload returns 409.
7. Enqueue notification via an outbox/notification table after commit (prefer transactional outbox for production).

### `accept_booking(booking_id uuid, idempotency_key text) -> booking summary`
1. Caller must have active provider role and approved `provider_profiles`.
2. Lock booking row `FOR UPDATE`; require `status = 'requested'` and unexpired request.
3. Validate provider offers all required variants and is available for requested slot/radius.
4. Insert `booking_assignments`; update booking to `accepted`; append event with actor, from/to, timestamp, request ID.
5. Commit atomically. Competing acceptors get 409; exactly one active assignment.

### `transition_booking(booking_id uuid, target_status text, reason_code text, metadata jsonb)`
- Enforce transition matrix and actor rights server-side.
- Provider may mark en_route/arrived/in_progress/completed only for their accepted assignment.
- Customer may cancel only within policy; admin/support actions require dedicated role.
- Append event and update current state in one transaction.
- Completion OTP verification must be separate controlled operation; never accept raw OTP as trusted metadata.

### `request_job_otp(booking_id uuid, purpose text)` / `verify_job_otp(challenge_id uuid, code text)`
- Server-generated random code; persist only a cryptographic hash; expiry typically 5–10 minutes.
- Rate limits: 3 sends per booking per 10 minutes, 5 verification attempts per challenge; invalidate older active challenge.
- Never log raw OTP. Use SMS vendor secret only in Edge Function secrets.

## Edge Functions
| Function | Trigger | Security |
|---|---|---|
| `send-auth-sms` | Only if custom Auth SMS integration is needed | Prefer Supabase Auth SMS hook/provider configuration; abuse limits |
| `payment-create-intent` | Customer begins payment | Server computes amount; provider secret stored as Edge Function secret |
| `payment-webhook` | Gateway callback | Verify signature, unique gateway event ID, idempotent ledger update |
| `send-notification` | Outbox worker / event | Authorized recipient only; retries with backoff; no PII in push body |
| `provider-review-admin` | Admin review | Role check + audit log + reason |
| `support-admin-action` | Support/admin mutation | Least privilege + audit trail |

## Initial rate-limit policy
| Operation | Proposed limit | Additional controls |
|---|---:|---|
| Auth OTP request | 3/phone/10 min; 10/IP/hour | CAPTCHA/abuse signals; vendor spend alerts |
| Auth OTP verification | 5 failed attempts/challenge | Expire challenges; progressive backoff |
| Create booking | 5/user/min | Idempotency + daily abuse threshold |
| Provider accept | 10/provider/min | Row lock + active assignment uniqueness |
| Catalog reads | 120/user/min | CDN/cache where safe; pagination |
| Provider search | 30/user/min | Max radius/result count; query timeout |
| Cancel booking | 10/user/min | Policy-based cancellation checks |
| Review submit | 3/user/min | One review per completed booking |
| Support/SOS create | 5/user/min | Spam/abuse monitoring; SOS UX disclaimer |
| Job OTP send/verify | 3 sends/booking/10 min; 5 verify attempts/challenge | Hash + expiry + lockout |
| Payment create | 5/user/min | Idempotency; gateway reconciliation |
| Webhooks | Vendor-specific | Signature verification + unique event IDs |

## Booking state matrix
- `requested -> accepted | rejected | cancelled | expired`
- `accepted -> provider_en_route | cancelled | no_show | disputed`
- `provider_en_route -> arrived | cancelled | no_show | disputed`
- `arrived -> in_progress | cancelled | no_show | disputed`
- `in_progress -> completed | disputed`
- Terminal: `completed`, `rejected`, `cancelled`, `expired`, `no_show` (dispute may be a separate case rather than overwriting completion).
- Exact policy must be approved by product/legal and encoded in SQL RPC; clients cannot directly update `bookings.status`.

## RLS minimum matrix
| Table | Customer | Provider | Admin/support |
|---|---|---|---|
| `profiles` | Own profile | Own profile | Narrow audited access |
| `addresses` | Own CRUD | No access unless booking requires limited snapshot | Narrow audited access |
| `bookings` | Own as customer | Assigned bookings only | Separate privileged workflows |
| `booking_items` | Own booking items | Assigned booking items only | Audited |
| `booking_status_events` | Participant read-only | Participant read-only | Audited read |
| `user_roles` | Read own active roles; no self-grant | Same | Role grants only through trusted function |
| `provider_profiles` | Public approved subset | Own full profile | Review workflow |
| `payments/refunds` | Own payment summary | No payment PII by default | Audited financial access |
| `audit_logs` | No direct access | No direct access | Restricted internal access |

## Deployment gates
- Run schema in staging first; add tested RLS policies before exposing app functionality.
- Write SQL tests for RLS and concurrency; simulate simultaneous accept calls.
- Add migration versioning, backup/PITR, monitoring, alerting and scheduled idempotency cleanup.
- Configure Auth SMS, push, payment gateway and webhook secrets outside client code.
- Do not claim production-ready until integration tests pass on a real Supabase staging project.
