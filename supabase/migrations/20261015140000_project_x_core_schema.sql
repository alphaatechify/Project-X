-- ==============================================================================
-- PROJECT X: CORE DATABASE SCHEMA (24 TABLES)
-- Compliant with Project_X_ERD_Relationships.txt and project_x_supabase_schema.sql
-- ==============================================================================

create extension if not exists pgcrypto;
create extension if not exists "uuid-ossp";

-- 1. Custom Types & Enums
do $$ begin
  if not exists (select 1 from pg_type where typname = 'app_role') then
    create type public.app_role as enum ('customer','provider','admin','support');
  end if;
  if not exists (select 1 from pg_type where typname = 'provider_status') then
    create type public.provider_status as enum ('draft','pending_review','approved','rejected','suspended');
  end if;
  if not exists (select 1 from pg_type where typname = 'booking_status') then
    create type public.booking_status as enum ('requested','accepted','rejected','provider_en_route','arrived','in_progress','completed','cancelled','expired','no_show','disputed');
  end if;
  if not exists (select 1 from pg_type where typname = 'payment_status') then
    create type public.payment_status as enum ('created','requires_action','authorized','captured','failed','cancelled','partially_refunded','refunded');
  end if;
  if not exists (select 1 from pg_type where typname = 'approval_status') then
    create type public.approval_status as enum ('pending','approved','rejected','suspended');
  end if;
end $$;

-- 2. Profiles (1--1 with auth.users, compatible with existing client fields)
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  email text,
  phone_number text unique,
  avatar_path text,
  avatar_url text,
  location text default 'Indiranagar, Bengaluru',
  bio text,
  is_provider boolean not null default false,
  rating numeric(3,2) default 5.00,
  kyc_status text default 'verified',
  preferred_language text not null default 'en',
  profile_complete boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Upgrade existing profiles columns if previously created
alter table public.profiles add column if not exists phone_number text;
alter table public.profiles add column if not exists avatar_path text;
alter table public.profiles add column if not exists avatar_url text;
alter table public.profiles add column if not exists location text default 'Indiranagar, Bengaluru';
alter table public.profiles add column if not exists bio text;
alter table public.profiles add column if not exists is_provider boolean not null default false;
alter table public.profiles add column if not exists rating numeric(3,2) default 5.00;
alter table public.profiles add column if not exists kyc_status text default 'verified';
alter table public.profiles add column if not exists preferred_language text not null default 'en';
alter table public.profiles add column if not exists profile_complete boolean not null default false;

-- 3. User Roles (RBAC)
create table if not exists public.user_roles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  role public.app_role not null,
  granted_at timestamptz not null default now(),
  granted_by uuid references public.profiles(id),
  revoked_at timestamptz,
  revoked_by uuid references public.profiles(id),
  grant_reason text,
  constraint user_roles_valid_interval check (revoked_at is null or revoked_at >= granted_at)
);
create unique index if not exists user_roles_one_active_role on public.user_roles(user_id, role) where revoked_at is null;

-- 4. Role Transition Events
create table if not exists public.role_transition_events (
  id bigint generated always as identity primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  from_role public.app_role,
  to_role public.app_role not null,
  action text not null check (action in ('granted','revoked','approved','suspended','reinstated')),
  actor_user_id uuid references public.profiles(id),
  reason text,
  metadata jsonb not null default '{}'::jsonb,
  occurred_at timestamptz not null default now(),
  request_id uuid
);
create index if not exists role_events_user_time_idx on public.role_transition_events(user_id, occurred_at desc);

-- 5. Addresses
create table if not exists public.addresses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  label text,
  recipient_name text,
  recipient_phone text,
  address_line1 text not null,
  address_line2 text,
  locality text,
  city text not null,
  state text,
  postal_code text,
  country_code char(2) not null default 'IN',
  latitude double precision,
  longitude double precision,
  instructions text,
  is_default boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (latitude is null or latitude between -90 and 90),
  check (longitude is null or longitude between -180 and 180)
);
create index if not exists addresses_user_idx on public.addresses(user_id);

-- 6. Service Categories (Tree structure)
create table if not exists public.service_categories (
  id uuid primary key default gen_random_uuid(),
  parent_id uuid references public.service_categories(id),
  slug text not null unique,
  name text not null,
  description text,
  image_path text,
  sort_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 7. Services
create table if not exists public.services (
  id uuid primary key default gen_random_uuid(),
  category_id uuid references public.service_categories(id) on delete set null,
  slug text,
  name text,
  title text,
  category text,
  short_description text,
  description text,
  image_path text,
  price numeric(10,2) default 199.00,
  price_unit text default '/visit',
  sub_categories text[] default '{}',
  is_available boolean not null default true,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Upgrade existing services columns
alter table public.services add column if not exists category_id uuid references public.service_categories(id) on delete set null;
alter table public.services add column if not exists slug text;
alter table public.services add column if not exists name text;
alter table public.services add column if not exists title text;
alter table public.services add column if not exists is_active boolean not null default true;
update public.services set name = coalesce(name, title, 'Service') where name is null;
update public.services set slug = coalesce(slug, lower(regexp_replace(coalesce(name, title, id::text), '[^a-zA-Z0-9]+', '-', 'g'))) where slug is null;
create unique index if not exists services_slug_key on public.services(slug);
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'services_slug_unique') then
    alter table public.services add constraint services_slug_unique unique using index services_slug_key;
  end if;
exception when others then null;
end $$;
create index if not exists services_category_active_idx on public.services(category_id, is_active);

-- 8. Service Variants (Bookable units with immutable pricing)
create table if not exists public.service_variants (
  id uuid primary key default gen_random_uuid(),
  service_id uuid not null references public.services(id) on delete cascade,
  sku text unique,
  name text not null,
  description text,
  base_price_paise bigint not null check (base_price_paise >= 0),
  currency char(3) not null default 'INR',
  estimated_duration_minutes int not null default 30 check (estimated_duration_minutes > 0),
  tax_rate_bps int not null default 0 check (tax_rate_bps between 0 and 10000),
  unit_label text not null default 'job',
  is_active boolean not null default true,
  effective_from timestamptz not null default now(),
  effective_to timestamptz,
  created_at timestamptz not null default now(),
  check (effective_to is null or effective_to > effective_from)
);
create index if not exists service_variants_active_idx on public.service_variants(service_id, is_active);

-- 9. Provider Profiles
create table if not exists public.provider_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.profiles(id) on delete cascade,
  business_name text,
  bio text,
  status public.provider_status not null default 'draft',
  verification_submitted_at timestamptz,
  approved_at timestamptz,
  approved_by uuid references public.profiles(id),
  rejection_reason text,
  service_radius_km numeric(6,2) not null default 5 check (service_radius_km > 0 and service_radius_km <= 200),
  latitude double precision,
  longitude double precision,
  average_rating numeric(3,2) not null default 0 check (average_rating between 0 and 5),
  completed_jobs_count bigint not null default 0 check (completed_jobs_count >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists provider_profiles_status_idx on public.provider_profiles(status);

-- 10. Provider Services (Mapping providers to service variants)
create table if not exists public.provider_services (
  id uuid primary key default gen_random_uuid(),
  provider_id uuid not null references public.provider_profiles(id) on delete cascade,
  variant_id uuid not null references public.service_variants(id) on delete cascade,
  approval_status public.approval_status not null default 'pending',
  is_active boolean not null default true,
  provider_price_paise bigint check (provider_price_paise is null or provider_price_paise >= 0),
  approved_at timestamptz,
  approved_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  unique(provider_id, variant_id)
);
create index if not exists provider_services_discovery_idx on public.provider_services(variant_id, approval_status, is_active);

-- 11. Provider Availability
create table if not exists public.provider_availability (
  id uuid primary key default gen_random_uuid(),
  provider_id uuid not null references public.provider_profiles(id) on delete cascade,
  weekday smallint check (weekday between 0 and 6),
  start_local_time time,
  end_local_time time,
  specific_date date,
  is_available boolean not null default true,
  timezone text not null default 'Asia/Kolkata',
  created_at timestamptz not null default now(),
  check ((specific_date is not null) or (weekday is not null and start_local_time is not null and end_local_time is not null)),
  check (start_local_time is null or end_local_time is null or end_local_time > start_local_time)
);
create index if not exists provider_availability_lookup_idx on public.provider_availability(provider_id, specific_date, weekday);

-- 12. Bookings
create table if not exists public.bookings (
  id uuid primary key default gen_random_uuid(),
  booking_number bigint generated always as identity unique,
  customer_id uuid not null references public.profiles(id),
  address_id uuid references public.addresses(id) on delete set null,
  status public.booking_status not null default 'requested',
  requested_at timestamptz not null default now(),
  scheduled_start timestamptz,
  scheduled_end timestamptz,
  accepted_at timestamptz,
  started_at timestamptz,
  completed_at timestamptz,
  cancelled_at timestamptz,
  cancellation_reason text,
  customer_notes text,
  currency char(3) not null default 'INR',
  subtotal_paise bigint not null default 0 check (subtotal_paise >= 0),
  tax_paise bigint not null default 0 check (tax_paise >= 0),
  discount_paise bigint not null default 0 check (discount_paise >= 0),
  total_paise bigint not null default 0 check (total_paise >= 0),
  idempotency_key text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(customer_id, idempotency_key),
  check (scheduled_end is null or scheduled_start is null or scheduled_end > scheduled_start)
);
create index if not exists bookings_customer_created_idx on public.bookings(customer_id, created_at desc);
create index if not exists bookings_status_requested_idx on public.bookings(status, requested_at);

-- 13. Booking Items (Immutable line item snapshots)
create table if not exists public.booking_items (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null references public.bookings(id) on delete cascade,
  variant_id uuid references public.service_variants(id) on delete set null,
  service_name_snapshot text not null,
  variant_name_snapshot text not null,
  unit_price_paise bigint not null check (unit_price_paise >= 0),
  quantity int not null default 1 check (quantity > 0),
  duration_minutes_snapshot int not null check (duration_minutes_snapshot > 0),
  tax_rate_bps_snapshot int not null default 0 check (tax_rate_bps_snapshot between 0 and 10000),
  line_total_paise bigint not null check (line_total_paise >= 0),
  created_at timestamptz not null default now()
);
create index if not exists booking_items_booking_idx on public.booking_items(booking_id);

-- 14. Booking Assignments
create table if not exists public.booking_assignments (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null references public.bookings(id) on delete cascade,
  provider_id uuid not null references public.provider_profiles(id) on delete cascade,
  status text not null check (status in ('offered','accepted','rejected','withdrawn','completed')),
  offered_at timestamptz not null default now(),
  responded_at timestamptz,
  assigned_at timestamptz,
  unassigned_at timestamptz,
  rejection_reason text,
  created_by uuid references public.profiles(id),
  request_id uuid
);
create unique index if not exists booking_one_active_assignment on public.booking_assignments(booking_id)
  where status in ('offered','accepted') and unassigned_at is null;
create index if not exists assignments_provider_status_idx on public.booking_assignments(provider_id, status, offered_at desc);

-- 15. Booking Status Events (Audited timeline)
create table if not exists public.booking_status_events (
  id bigint generated always as identity primary key,
  booking_id uuid not null references public.bookings(id) on delete cascade,
  from_status public.booking_status,
  to_status public.booking_status not null,
  actor_user_id uuid references public.profiles(id),
  actor_role public.app_role,
  reason_code text,
  notes text,
  metadata jsonb not null default '{}'::jsonb,
  occurred_at timestamptz not null default now(),
  request_id uuid
);
create index if not exists booking_events_timeline_idx on public.booking_status_events(booking_id, occurred_at);

-- 16. Booking OTP Challenges (Cryptographic hashed verification)
create table if not exists public.booking_otp_challenges (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null references public.bookings(id) on delete cascade,
  target_user_id uuid not null references public.profiles(id) on delete cascade,
  purpose text not null check (purpose in ('arrival','start','completion','handover')),
  code_hash text not null,
  expires_at timestamptz not null,
  attempts int not null default 0 check (attempts >= 0),
  max_attempts int not null default 5 check (max_attempts between 1 and 10),
  verified_at timestamptz,
  invalidated_at timestamptz,
  created_at timestamptz not null default now()
);
create index if not exists booking_otp_active_idx on public.booking_otp_challenges(booking_id, purpose, expires_at);

-- 17. Reviews
create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null unique references public.bookings(id) on delete cascade,
  reviewer_id uuid not null references public.profiles(id) on delete cascade,
  provider_id uuid not null references public.provider_profiles(id) on delete cascade,
  rating smallint not null check (rating between 1 and 5),
  review_text text,
  moderation_status text not null default 'pending' check (moderation_status in ('pending','published','hidden')),
  created_at timestamptz not null default now()
);
create index if not exists reviews_provider_idx on public.reviews(provider_id, created_at desc);

-- 18. Payments
create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null unique references public.bookings(id) on delete cascade,
  customer_id uuid not null references public.profiles(id) on delete cascade,
  gateway text not null,
  gateway_order_id text,
  gateway_payment_id text unique,
  status public.payment_status not null default 'created',
  amount_paise bigint not null check (amount_paise >= 0),
  currency char(3) not null default 'INR',
  gateway_event_id text unique,
  authorized_at timestamptz,
  captured_at timestamptz,
  failed_at timestamptz,
  raw_gateway_payload jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists payments_booking_status_idx on public.payments(booking_id, status);

-- 19. Refunds
create table if not exists public.refunds (
  id uuid primary key default gen_random_uuid(),
  payment_id uuid not null references public.payments(id) on delete cascade,
  gateway_refund_id text unique,
  amount_paise bigint not null check (amount_paise > 0),
  reason text,
  status text not null default 'requested' check (status in ('requested','processing','succeeded','failed','cancelled')),
  requested_by uuid references public.profiles(id),
  processed_at timestamptz,
  created_at timestamptz not null default now()
);
create index if not exists refunds_payment_idx on public.refunds(payment_id, created_at desc);

-- 20. Notifications
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  booking_id uuid references public.bookings(id) on delete set null,
  channel text not null default 'in_app' check (channel in ('in_app','push','sms','email')),
  title text not null,
  body text not null,
  payload jsonb not null default '{}'::jsonb,
  read_at timestamptz,
  delivery_status text not null default 'queued' check (delivery_status in ('queued','sent','delivered','failed','read')),
  created_at timestamptz not null default now()
);
create index if not exists notifications_user_created_idx on public.notifications(user_id, created_at desc);

-- 21. Device Tokens
create table if not exists public.device_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  platform text not null check (platform in ('ios','android','web')),
  token text not null unique,
  last_seen_at timestamptz not null default now(),
  disabled_at timestamptz,
  created_at timestamptz not null default now()
);
create index if not exists device_tokens_user_active_idx on public.device_tokens(user_id) where disabled_at is null;

-- 22. Support Tickets
create table if not exists public.support_tickets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  booking_id uuid references public.bookings(id) on delete set null,
  subject text not null,
  description text not null,
  status text not null default 'open' check (status in ('open','in_progress','waiting_on_user','resolved','closed')),
  priority text not null default 'normal' check (priority in ('low','normal','high','urgent')),
  assigned_to uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  resolved_at timestamptz
);
create index if not exists support_tickets_user_idx on public.support_tickets(user_id, created_at desc);

-- 23. SOS Contacts
create table if not exists public.sos_contacts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  contact_name text not null,
  phone_e164 text not null,
  relationship text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists sos_contacts_user_idx on public.sos_contacts(user_id);

-- 24. Audit Logs
create table if not exists public.audit_logs (
  id bigint generated always as identity primary key,
  actor_user_id uuid references public.profiles(id),
  action text not null,
  entity_type text not null,
  entity_id text,
  request_id uuid,
  ip_hash text,
  user_agent text,
  metadata jsonb not null default '{}'::jsonb,
  occurred_at timestamptz not null default now()
);
create index if not exists audit_logs_entity_idx on public.audit_logs(entity_type, entity_id, occurred_at desc);
create index if not exists audit_logs_actor_idx on public.audit_logs(actor_user_id, occurred_at desc);

-- 25. API Idempotency Keys
create table if not exists public.api_idempotency_keys (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  idempotency_key text not null,
  operation text not null,
  request_hash text not null,
  response_status int,
  response_body jsonb,
  resource_id uuid,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '48 hours'),
  unique(user_id, idempotency_key, operation)
);
create index if not exists api_idempotency_expiry_idx on public.api_idempotency_keys(expires_at);

-- Updated_At trigger helper
create or replace function public.set_updated_at()
returns trigger language plpgsql set search_path = public
as $$ begin new.updated_at = now(); return new; end $$;

do $$
declare t text;
begin
  foreach t in array array['profiles','addresses','service_categories','services','provider_profiles','bookings','payments','support_tickets','sos_contacts'] loop
    execute format('drop trigger if exists set_updated_at on public.%I', t);
    execute format('create trigger set_updated_at before update on public.%I for each row execute function public.set_updated_at()', t);
  end loop;
end $$;
