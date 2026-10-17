-- ==============================================================================
-- PROJECT X: TRANSACTIONAL RPCS & AUTH TRIGGERS
-- Strictly following Project_X_API_Rate_Limit_and_RLS_Spec.md
-- ==============================================================================

-- 1. Automatic User Profile & Role Setup on Signup
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public
as $$
declare
  v_phone text;
  v_name text;
begin
  v_phone := coalesce(new.phone, (new.raw_user_meta_data->>'phone'), (new.raw_user_meta_data->>'phone_number'));
  v_name := coalesce((new.raw_user_meta_data->>'full_name'), (new.raw_user_meta_data->>'name'), 'User');

  insert into public.profiles (
    id,
    email,
    phone_number,
    full_name,
    preferred_language,
    profile_complete,
    created_at,
    updated_at
  ) values (
    new.id,
    new.email,
    v_phone,
    v_name,
    'en',
    false,
    now(),
    now()
  ) on conflict (id) do update set
    email = coalesce(excluded.email, public.profiles.email),
    phone_number = coalesce(excluded.phone_number, public.profiles.phone_number),
    updated_at = now();

  -- Grant default customer role
  insert into public.user_roles (user_id, role, granted_at)
  values (new.id, 'customer', now())
  on conflict do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();


-- ==============================================================================
-- 2. RPC: create_booking
-- Atomic booking creation with server-side price calculation and idempotency
-- ==============================================================================
create or replace function public.create_booking(
  payload jsonb,
  idempotency_key text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_caller_id uuid;
  v_existing_booking record;
  v_address_id uuid;
  v_scheduled_start timestamptz;
  v_scheduled_end timestamptz;
  v_notes text;
  v_item jsonb;
  v_variant_id uuid;
  v_variant record;
  v_qty int;
  v_line_total bigint;
  v_line_tax bigint;
  v_subtotal_paise bigint := 0;
  v_tax_paise bigint := 0;
  v_total_paise bigint := 0;
  v_booking_id uuid;
  v_booking_number bigint;
  v_items_inserted jsonb := '[]'::jsonb;
begin
  v_caller_id := auth.uid();
  if v_caller_id is null then
    raise exception '401: Unauthenticated';
  end if;

  if idempotency_key is null or trim(idempotency_key) = '' then
    raise exception '400: Idempotency-Key is required';
  end if;

  -- 1. Check Idempotency
  select id, booking_number, status, total_paise, created_at
  into v_existing_booking
  from public.bookings
  where customer_id = v_caller_id and idempotency_key = create_booking.idempotency_key;

  if v_existing_booking.id is not null then
    return jsonb_build_object(
      'id', v_existing_booking.id,
      'booking_number', v_existing_booking.booking_number,
      'status', v_existing_booking.status,
      'total_paise', v_existing_booking.total_paise,
      'created_at', v_existing_booking.created_at,
      'idempotent_replay', true
    );
  end if;

  -- 2. Resolve Address
  if payload ? 'address_id' and (payload->>'address_id') is not null then
    v_address_id := (payload->>'address_id')::uuid;
    if not exists (select 1 from public.addresses where id = v_address_id and user_id = v_caller_id) then
      raise exception '404: Address not found or does not belong to user';
    end if;
  elsif payload ? 'address' and (payload->'address') is not null then
    insert into public.addresses (
      user_id,
      recipient_name,
      recipient_phone,
      address_line1,
      address_line2,
      locality,
      city,
      state,
      postal_code,
      instructions
    ) values (
      v_caller_id,
      payload->'address'->>'recipient_name',
      payload->'address'->>'recipient_phone',
      coalesce(payload->'address'->>'address_line1', payload->'address'->>'address', 'Address details'),
      payload->'address'->>'address_line2',
      payload->'address'->>'locality',
      coalesce(payload->'address'->>'city', 'Bengaluru'),
      coalesce(payload->'address'->>'state', 'Karnataka'),
      payload->'address'->>'postal_code',
      payload->'address'->>'instructions'
    ) returning id into v_address_id;
  else
    select id into v_address_id
    from public.addresses
    where user_id = v_caller_id
    order by is_default desc, created_at desc
    limit 1;
  end if;

  -- 3. Extract Schedule and Notes
  if (payload->>'scheduled_start') is not null then
    v_scheduled_start := (payload->>'scheduled_start')::timestamptz;
  else
    v_scheduled_start := now() + interval '15 minutes';
  end if;

  if (payload->>'scheduled_end') is not null then
    v_scheduled_end := (payload->>'scheduled_end')::timestamptz;
  else
    v_scheduled_end := v_scheduled_start + interval '1 hour';
  end if;

  v_notes := payload->>'customer_notes';

  -- 4. Validate Items & Calculate Prices Strictly on Server
  if not (payload ? 'items') or jsonb_array_length(payload->'items') = 0 then
    raise exception '400: Booking must contain at least one service item';
  end if;

  -- Loop once to calculate totals
  for v_item in select * from jsonb_array_elements(payload->'items') loop
    v_variant_id := (v_item->>'variant_id')::uuid;
    v_qty := coalesce((v_item->>'quantity')::int, 1);
    if v_qty <= 0 then
      raise exception '400: Item quantity must be greater than 0';
    end if;

    select v.id, v.name as variant_name, s.name as service_name, v.base_price_paise, v.tax_rate_bps, v.estimated_duration_minutes
    into v_variant
    from public.service_variants v
    join public.services s on s.id = v.service_id
    where v.id = v_variant_id and v.is_active = true;

    if v_variant.id is null then
      raise exception '422: Service variant % is not active or does not exist', v_variant_id;
    end if;

    v_line_total := v_variant.base_price_paise * v_qty;
    v_line_tax := (v_line_total * v_variant.tax_rate_bps) / 10000;

    v_subtotal_paise := v_subtotal_paise + v_line_total;
    v_tax_paise := v_tax_paise + v_line_tax;
  end loop;

  v_total_paise := v_subtotal_paise + v_tax_paise;

  -- 5. Insert Booking
  insert into public.bookings (
    customer_id,
    address_id,
    status,
    requested_at,
    scheduled_start,
    scheduled_end,
    customer_notes,
    currency,
    subtotal_paise,
    tax_paise,
    discount_paise,
    total_paise,
    idempotency_key
  ) values (
    v_caller_id,
    v_address_id,
    'requested',
    now(),
    v_scheduled_start,
    v_scheduled_end,
    v_notes,
    'INR',
    v_subtotal_paise,
    v_tax_paise,
    0,
    v_total_paise,
    create_booking.idempotency_key
  ) returning id, booking_number into v_booking_id, v_booking_number;

  -- 6. Insert Booking Items Snapshots
  for v_item in select * from jsonb_array_elements(payload->'items') loop
    v_variant_id := (v_item->>'variant_id')::uuid;
    v_qty := coalesce((v_item->>'quantity')::int, 1);

    select v.name as variant_name, s.name as service_name, v.base_price_paise, v.tax_rate_bps, v.estimated_duration_minutes
    into v_variant
    from public.service_variants v
    join public.services s on s.id = v.service_id
    where v.id = v_variant_id;

    v_line_total := v_variant.base_price_paise * v_qty;

    insert into public.booking_items (
      booking_id,
      variant_id,
      service_name_snapshot,
      variant_name_snapshot,
      unit_price_paise,
      quantity,
      duration_minutes_snapshot,
      tax_rate_bps_snapshot,
      line_total_paise
    ) values (
      v_booking_id,
      v_variant_id,
      v_variant.service_name,
      v_variant.variant_name,
      v_variant.base_price_paise,
      v_qty,
      v_variant.estimated_duration_minutes * v_qty,
      v_variant.tax_rate_bps,
      v_line_total
    );
  end loop;

  -- 7. Insert Initial Timeline Event
  insert into public.booking_status_events (
    booking_id,
    from_status,
    to_status,
    actor_user_id,
    actor_role,
    reason_code,
    notes,
    metadata
  ) values (
    v_booking_id,
    null,
    'requested',
    v_caller_id,
    'customer',
    'BOOKING_CREATED',
    'Booking requested by customer',
    jsonb_build_object('booking_number', v_booking_number)
  );

  -- 8. Customer Notification
  insert into public.notifications (
    user_id,
    booking_id,
    channel,
    title,
    body,
    payload
  ) values (
    v_caller_id,
    v_booking_id,
    'in_app',
    'Booking Requested',
    format('Your booking #%s has been requested. We are matching you with top-rated nearby pros.', v_booking_number),
    jsonb_build_object('booking_id', v_booking_id, 'status', 'requested')
  );

  -- 9. Record Idempotency Key
  insert into public.api_idempotency_keys (
    user_id,
    idempotency_key,
    operation,
    request_hash,
    response_status,
    response_body,
    resource_id
  ) values (
    v_caller_id,
    create_booking.idempotency_key,
    'create_booking',
    md5(payload::text),
    201,
    jsonb_build_object('booking_id', v_booking_id, 'booking_number', v_booking_number),
    v_booking_id
  ) on conflict (user_id, idempotency_key, operation) do nothing;

  return jsonb_build_object(
    'id', v_booking_id,
    'booking_number', v_booking_number,
    'status', 'requested',
    'subtotal_paise', v_subtotal_paise,
    'tax_paise', v_tax_paise,
    'total_paise', v_total_paise,
    'scheduled_start', v_scheduled_start,
    'scheduled_end', v_scheduled_end,
    'created_at', now()
  );
end;
$$;


-- ==============================================================================
-- 3. RPC: accept_booking
-- Concurrency-safe provider acceptance with row locking
-- ==============================================================================
create or replace function public.accept_booking(
  p_booking_id uuid,
  p_idempotency_key text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_caller_id uuid;
  v_provider record;
  v_booking record;
begin
  v_caller_id := auth.uid();
  if v_caller_id is null then
    raise exception '401: Unauthenticated';
  end if;

  -- Validate caller has approved provider profile
  select id, status, business_name
  into v_provider
  from public.provider_profiles
  where user_id = v_caller_id;

  if v_provider.id is null or v_provider.status != 'approved' then
    raise exception '403: Caller must be an approved service provider';
  end if;

  -- Lock booking row FOR UPDATE
  select *
  into v_booking
  from public.bookings
  where id = p_booking_id
  for update;

  if v_booking.id is null then
    raise exception '404: Booking not found';
  end if;

  if v_booking.status != 'requested' then
    raise exception '409: Booking is no longer in requested status (current status: %)', v_booking.status;
  end if;

  -- Ensure no active assignment exists
  if exists (
    select 1 from public.booking_assignments
    where booking_id = p_booking_id
      and status in ('offered','accepted')
      and unassigned_at is null
  ) then
    raise exception '409: Booking has already been assigned to another provider';
  end if;

  -- Insert assignment
  insert into public.booking_assignments (
    booking_id,
    provider_id,
    status,
    offered_at,
    responded_at,
    assigned_at,
    created_by
  ) values (
    p_booking_id,
    v_provider.id,
    'accepted',
    now(),
    now(),
    now(),
    v_caller_id
  );

  -- Update booking
  update public.bookings
  set status = 'accepted',
      accepted_at = now(),
      updated_at = now()
  where id = p_booking_id;

  -- Insert event
  insert into public.booking_status_events (
    booking_id,
    from_status,
    to_status,
    actor_user_id,
    actor_role,
    reason_code,
    notes,
    metadata
  ) values (
    p_booking_id,
    'requested',
    'accepted',
    v_caller_id,
    'provider',
    'PROVIDER_ACCEPTED',
    format('Accepted by %s', coalesce(v_provider.business_name, 'Provider')),
    jsonb_build_object('provider_id', v_provider.id)
  );

  -- Notify customer
  insert into public.notifications (
    user_id,
    booking_id,
    channel,
    title,
    body,
    payload
  ) values (
    v_booking.customer_id,
    p_booking_id,
    'in_app',
    'Provider Confirmed!',
    format('%s has accepted your booking and is preparing for service.', coalesce(v_provider.business_name, 'Your professional')),
    jsonb_build_object('booking_id', p_booking_id, 'status', 'accepted', 'provider_id', v_provider.id)
  );

  return jsonb_build_object(
    'booking_id', p_booking_id,
    'status', 'accepted',
    'accepted_at', now(),
    'provider_id', v_provider.id
  );
end;
$$;


-- ==============================================================================
-- 4. RPC: transition_booking
-- Enforces booking state machine matrix and actor authorization
-- ==============================================================================
create or replace function public.transition_booking(
  p_booking_id uuid,
  p_target_status text,
  p_reason_code text default null,
  p_metadata jsonb default '{}'::jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_caller_id uuid;
  v_booking record;
  v_is_customer boolean := false;
  v_is_provider boolean := false;
  v_is_admin boolean := false;
  v_actor_role public.app_role;
  v_target public.booking_status;
begin
  v_caller_id := auth.uid();
  if v_caller_id is null then
    raise exception '401: Unauthenticated';
  end if;

  v_target := p_target_status::public.booking_status;

  -- Lock booking row
  select *
  into v_booking
  from public.bookings
  where id = p_booking_id
  for update;

  if v_booking.id is null then
    raise exception '404: Booking not found';
  end if;

  -- Determine caller role
  if v_booking.customer_id = v_caller_id then
    v_is_customer := true;
    v_actor_role := 'customer';
  end if;

  if exists (
    select 1 from public.booking_assignments ba
    join public.provider_profiles pp on pp.id = ba.provider_id
    where ba.booking_id = p_booking_id
      and pp.user_id = v_caller_id
      and ba.status in ('offered','accepted','completed')
  ) then
    v_is_provider := true;
    v_actor_role := 'provider';
  end if;

  if public.is_admin(v_caller_id) then
    v_is_admin := true;
    v_actor_role := 'admin';
  end if;

  if not (v_is_customer or v_is_provider or v_is_admin) then
    raise exception '403: Caller is not a participant in this booking';
  end if;

  -- Validate state machine transitions
  case v_booking.status
    when 'requested' then
      if v_target not in ('accepted', 'rejected', 'cancelled', 'expired') then
        raise exception '409: Invalid transition from requested to %', v_target;
      end if;
    when 'accepted' then
      if v_target not in ('provider_en_route', 'cancelled', 'no_show', 'disputed') then
        raise exception '409: Invalid transition from accepted to %', v_target;
      end if;
    when 'provider_en_route' then
      if v_target not in ('arrived', 'cancelled', 'no_show', 'disputed') then
        raise exception '409: Invalid transition from provider_en_route to %', v_target;
      end if;
    when 'arrived' then
      if v_target not in ('in_progress', 'cancelled', 'no_show', 'disputed') then
        raise exception '409: Invalid transition from arrived to %', v_target;
      end if;
    when 'in_progress' then
      if v_target not in ('completed', 'disputed') then
        raise exception '409: Invalid transition from in_progress to %', v_target;
      end if;
    else
      raise exception '409: Cannot transition booking from terminal status %', v_booking.status;
  end case;

  -- Validate actor permissions on specific transitions
  if v_target in ('provider_en_route', 'arrived', 'in_progress', 'completed') and not (v_is_provider or v_is_admin) then
    raise exception '403: Only the assigned provider can update job execution status to %', v_target;
  end if;

  if v_target = 'cancelled' and not (v_is_customer or v_is_admin or v_is_provider) then
    raise exception '403: Unauthorized to cancel this booking';
  end if;

  -- Update booking with appropriate timestamp
  update public.bookings
  set status = v_target,
      started_at = case when v_target = 'in_progress' and started_at is null then now() else started_at end,
      completed_at = case when v_target = 'completed' and completed_at is null then now() else completed_at end,
      cancelled_at = case when v_target = 'cancelled' and cancelled_at is null then now() else cancelled_at end,
      cancellation_reason = case when v_target = 'cancelled' then coalesce(p_reason_code, cancellation_reason) else cancellation_reason end,
      updated_at = now()
  where id = p_booking_id;

  -- Append event
  insert into public.booking_status_events (
    booking_id,
    from_status,
    to_status,
    actor_user_id,
    actor_role,
    reason_code,
    notes,
    metadata
  ) values (
    p_booking_id,
    v_booking.status,
    v_target,
    v_caller_id,
    v_actor_role,
    coalesce(p_reason_code, 'STATUS_TRANSITION'),
    format('Transitioned to %s', v_target),
    p_metadata
  );

  return jsonb_build_object(
    'booking_id', p_booking_id,
    'from_status', v_booking.status,
    'to_status', v_target,
    'updated_at', now()
  );
end;
$$;


-- ==============================================================================
-- 5. RPC: request_job_otp & verify_job_otp
-- Cryptographic verification for arrival, start & completion handovers
-- ==============================================================================
create or replace function public.request_job_otp(
  p_booking_id uuid,
  p_purpose text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_caller_id uuid;
  v_booking record;
  v_target_user_id uuid;
  v_recent_count int;
  v_code text;
  v_code_hash text;
  v_challenge_id uuid;
begin
  v_caller_id := auth.uid();
  if v_caller_id is null then
    raise exception '401: Unauthenticated';
  end if;

  if p_purpose not in ('arrival', 'start', 'completion', 'handover') then
    raise exception '400: Invalid purpose %', p_purpose;
  end if;

  select * into v_booking from public.bookings where id = p_booking_id;
  if v_booking.id is null then
    raise exception '404: Booking not found';
  end if;

  -- Rate limit check: max 3 sends per booking per 10 minutes
  select count(*) into v_recent_count
  from public.booking_otp_challenges
  where booking_id = p_booking_id
    and created_at > (now() - interval '10 minutes');

  if v_recent_count >= 3 then
    raise exception '429: Rate limit exceeded. Maximum 3 OTP requests per 10 minutes.';
  end if;

  -- Target user is customer (customer holds the code to provide to pro)
  v_target_user_id := v_booking.customer_id;

  -- Generate 4-digit numeric code
  v_code := lpad((floor(random() * 9000) + 1000)::int::text, 4, '0');
  v_code_hash := crypt(v_code, gen_salt('bf', 8));

  -- Invalidate any previous active challenge for this purpose
  update public.booking_otp_challenges
  set invalidated_at = now()
  where booking_id = p_booking_id
    and purpose = p_purpose
    and verified_at is null
    and invalidated_at is null;

  -- Insert challenge
  insert into public.booking_otp_challenges (
    booking_id,
    target_user_id,
    purpose,
    code_hash,
    expires_at,
    attempts,
    max_attempts
  ) values (
    p_booking_id,
    v_target_user_id,
    p_purpose,
    v_code_hash,
    now() + interval '10 minutes',
    0,
    5
  ) returning id into v_challenge_id;

  -- Send notification to customer
  insert into public.notifications (
    user_id,
    booking_id,
    channel,
    title,
    body,
    payload
  ) values (
    v_target_user_id,
    p_booking_id,
    'in_app',
    format('Your Service OTP: %s', v_code),
    format('Share this OTP (%s) with your provider for %s verification.', v_code, p_purpose),
    jsonb_build_object('otp', v_code, 'purpose', p_purpose, 'booking_id', p_booking_id)
  );

  return jsonb_build_object(
    'challenge_id', v_challenge_id,
    'purpose', p_purpose,
    'expires_at', (now() + interval '10 minutes'),
    'otp', v_code -- exposed to authenticated participant for seamless display
  );
end;
$$;

create or replace function public.verify_job_otp(
  p_challenge_id uuid,
  p_code text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_caller_id uuid;
  v_challenge record;
  v_booking record;
begin
  v_caller_id := auth.uid();
  if v_caller_id is null then
    raise exception '401: Unauthenticated';
  end if;

  select * into v_challenge
  from public.booking_otp_challenges
  where id = p_challenge_id
  for update;

  if v_challenge.id is null then
    raise exception '404: Challenge not found';
  end if;

  if v_challenge.verified_at is not null then
    return jsonb_build_object('success', true, 'message', 'OTP already verified', 'booking_id', v_challenge.booking_id);
  end if;

  if v_challenge.invalidated_at is not null then
    raise exception '422: OTP challenge has been invalidated. Please request a new one.';
  end if;

  if now() > v_challenge.expires_at then
    raise exception '422: OTP has expired. Please request a new one.';
  end if;

  if v_challenge.attempts >= v_challenge.max_attempts then
    raise exception '429: Maximum verification attempts exceeded. Please request a new OTP.';
  end if;

  -- Increment attempts
  update public.booking_otp_challenges
  set attempts = attempts + 1
  where id = p_challenge_id;

  -- Verify hash
  if crypt(p_code, v_challenge.code_hash) != v_challenge.code_hash then
    raise exception '400: Incorrect OTP code. % attempts remaining.', (v_challenge.max_attempts - v_challenge.attempts - 1);
  end if;

  -- Mark verified
  update public.booking_otp_challenges
  set verified_at = now()
  where id = p_challenge_id;

  -- Auto advance booking status if applicable
  select * into v_booking from public.bookings where id = v_challenge.booking_id for update;

  if v_challenge.purpose in ('arrival', 'start') and v_booking.status in ('accepted', 'provider_en_route', 'arrived') then
    update public.bookings set status = 'in_progress', started_at = coalesce(started_at, now()), updated_at = now() where id = v_booking.id;
    insert into public.booking_status_events (booking_id, from_status, to_status, actor_user_id, actor_role, notes)
    values (v_booking.id, v_booking.status, 'in_progress', v_caller_id, 'provider', 'Verified start OTP');
  elsif v_challenge.purpose in ('completion', 'handover') and v_booking.status = 'in_progress' then
    update public.bookings set status = 'completed', completed_at = coalesce(completed_at, now()), updated_at = now() where id = v_booking.id;
    insert into public.booking_status_events (booking_id, from_status, to_status, actor_user_id, actor_role, notes)
    values (v_booking.id, 'in_progress', 'completed', v_caller_id, 'provider', 'Verified completion OTP');
  end if;

  return jsonb_build_object(
    'success', true,
    'verified', true,
    'booking_id', v_challenge.booking_id,
    'purpose', v_challenge.purpose
  );
end;
$$;

-- Grant execution permissions
grant execute on function public.create_booking(jsonb, text) to authenticated;
grant execute on function public.accept_booking(uuid, text) to authenticated;
grant execute on function public.transition_booking(uuid, text, text, jsonb) to authenticated;
grant execute on function public.request_job_otp(uuid, text) to authenticated;
grant execute on function public.verify_job_otp(uuid, text) to authenticated;
