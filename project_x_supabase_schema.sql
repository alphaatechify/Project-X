-- Project X / Supabase starter schema
-- PostgreSQL migration draft. Review and test in a staging project before production.
-- Assumes Supabase Auth schema exists. Never ship service_role key to Flutter.
create extension if not exists pgcrypto;
-- Optional for radius-based provider discovery:
-- create extension if not exists postgis;

create type public.app_role as enum ('customer','provider','admin','support');
create type public.provider_status as enum ('draft','pending_review','approved','rejected','suspended');
create type public.booking_status as enum ('requested','accepted','rejected','provider_en_route','arrived','in_progress','completed','cancelled','expired','no_show','disputed');
create type public.payment_status as enum ('created','requires_action','authorized','captured','failed','cancelled','partially_refunded','refunded');
create type public.approval_status as enum ('pending','approved','rejected','suspended');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  email text,
  avatar_path text,
  preferred_language text not null default 'en',
  profile_complete boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.user_roles (
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
create unique index user_roles_one_active_role on public.user_roles(user_id, role) where revoked_at is null;

create table public.role_transition_events (
  id bigint generated always as identity primary key,
  user_id uuid not null references public.profiles(id),
  from_role public.app_role,
  to_role public.app_role not null,
  action text not null check (action in ('granted','revoked','approved','suspended','reinstated')),
  actor_user_id uuid references public.profiles(id),
  reason text,
  metadata jsonb not null default '{}'::jsonb,
  occurred_at timestamptz not null default now(),
  request_id uuid
);
create index role_events_user_time_idx on public.role_transition_events(user_id, occurred_at desc);

create table public.addresses (
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
create index addresses_user_idx on public.addresses(user_id);

create table public.service_categories (
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

create table public.services (
  id uuid primary key default gen_random_uuid(),
  category_id uuid not null references public.service_categories(id),
  slug text not null unique,
  name text not null,
  short_description text,
  description text,
  image_path text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index services_category_active_idx on public.services(category_id, is_active);

create table public.service_variants (
  id uuid primary key default gen_random_uuid(),
  service_id uuid not null references public.services(id),
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
create index service_variants_active_idx on public.service_variants(service_id, is_active);

create table public.provider_profiles (
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
create index provider_profiles_status_idx on public.provider_profiles(status);

create table public.provider_services (
  id uuid primary key default gen_random_uuid(),
  provider_id uuid not null references public.provider_profiles(id) on delete cascade,
  variant_id uuid not null references public.service_variants(id),
  approval_status public.approval_status not null default 'pending',
  is_active boolean not null default true,
  provider_price_paise bigint check (provider_price_paise is null or provider_price_paise >= 0),
  approved_at timestamptz,
  approved_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  unique(provider_id, variant_id)
);
create index provider_services_discovery_idx on public.provider_services(variant_id, approval_status, is_active);

create table public.provider_availability (
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
create index provider_availability_lookup_idx on public.provider_availability(provider_id, specific_date, weekday);

create table public.bookings (
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
create index bookings_customer_created_idx on public.bookings(customer_id, created_at desc);
create index bookings_status_requested_idx on public.bookings(status, requested_at);

create table public.booking_items (
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
create index booking_items_booking_idx on public.booking_items(booking_id);

create table public.booking_assignments (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null references public.bookings(id) on delete cascade,
  provider_id uuid not null references public.provider_profiles(id),
  status text not null check (status in ('offered','accepted','rejected','withdrawn','completed')),
  offered_at timestamptz not null default now(),
  responded_at timestamptz,
  assigned_at timestamptz,
  unassigned_at timestamptz,
  rejection_reason text,
  created_by uuid references public.profiles(id),
  request_id uuid
);
create unique index booking_one_active_assignment on public.booking_assignments(booking_id)
  where status in ('offered','accepted') and unassigned_at is null;
create index assignments_provider_status_idx on public.booking_assignments(provider_id, status, offered_at desc);

create table public.booking_status_events (
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
create index booking_events_timeline_idx on public.booking_status_events(booking_id, occurred_at);

create table public.booking_otp_challenges (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null references public.bookings(id) on delete cascade,
  target_user_id uuid not null references public.profiles(id),
  purpose text not null check (purpose in ('arrival','start','completion','handover')),
  code_hash text not null,
  expires_at timestamptz not null,
  attempts int not null default 0 check (attempts >= 0),
  max_attempts int not null default 5 check (max_attempts between 1 and 10),
  verified_at timestamptz,
  invalidated_at timestamptz,
  created_at timestamptz not null default now()
);
create index booking_otp_active_idx on public.booking_otp_challenges(booking_id, purpose, expires_at);

create table public.reviews (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null unique references public.bookings(id),
  reviewer_id uuid not null references public.profiles(id),
  provider_id uuid not null references public.provider_profiles(id),
  rating smallint not null check (rating between 1 and 5),
  review_text text,
  moderation_status text not null default 'pending' check (moderation_status in ('pending','published','hidden')),
  created_at timestamptz not null default now()
);
create index reviews_provider_idx on public.reviews(provider_id, created_at desc);

create table public.payments (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null unique references public.bookings(id),
  customer_id uuid not null references public.profiles(id),
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
create index payments_booking_status_idx on public.payments(booking_id, status);

create table public.refunds (
  id uuid primary key default gen_random_uuid(),
  payment_id uuid not null references public.payments(id),
  gateway_refund_id text unique,
  amount_paise bigint not null check (amount_paise > 0),
  reason text,
  status text not null default 'requested' check (status in ('requested','processing','succeeded','failed','cancelled')),
  requested_by uuid references public.profiles(id),
  processed_at timestamptz,
  created_at timestamptz not null default now()
);
create index refunds_payment_idx on public.refunds(payment_id, created_at desc);

create table public.notifications (
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
create index notifications_user_created_idx on public.notifications(user_id, created_at desc);

create table public.device_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  platform text not null check (platform in ('ios','android','web')),
  token text not null unique,
  last_seen_at timestamptz not null default now(),
  disabled_at timestamptz,
  created_at timestamptz not null default now()
);
create index device_tokens_user_active_idx on public.device_tokens(user_id) where disabled_at is null;

create table public.support_tickets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
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
create index support_tickets_user_idx on public.support_tickets(user_id, created_at desc);

create table public.sos_contacts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  contact_name text not null,
  phone_e164 text not null,
  relationship text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index sos_contacts_user_idx on public.sos_contacts(user_id);

create table public.audit_logs (
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
create index audit_logs_entity_idx on public.audit_logs(entity_type, entity_id, occurred_at desc);
create index audit_logs_actor_idx on public.audit_logs(actor_user_id, occurred_at desc);

create table public.api_idempotency_keys (
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
create index api_idempotency_expiry_idx on public.api_idempotency_keys(expires_at);

-- updated_at helper; attach to mutable tables as appropriate.
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

-- Security baseline: enable RLS everywhere. Add policies only after testing the exact app flows.
do $$
declare t text;
begin
  foreach t in array array[
    'profiles','user_roles','role_transition_events','addresses','service_categories','services','service_variants',
    'provider_profiles','provider_services','provider_availability','bookings','booking_items','booking_assignments',
    'booking_status_events','booking_otp_challenges','reviews','payments','refunds','notifications','device_tokens',
    'support_tickets','sos_contacts','audit_logs','api_idempotency_keys'
  ] loop
    execute format('alter table public.%I enable row level security', t);
  end loop;
end $$;

-- Deliberately no broad permissive policies here. Without policies, RLS denies access.
-- Add explicit owner/participant SELECT policies and narrowly scoped write policies.
-- Prefer SECURITY DEFINER RPCs with fixed search_path and EXECUTE grants for booking transitions.
