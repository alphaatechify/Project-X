-- ==============================================================================
-- PROJECT X: COMPLETE MASTER DATABASE SETUP (24 CORE TABLES + POINTS REWARDS)
-- Designed for 1-Click Execution in Supabase Dashboard SQL Editor:
-- https://supabase.com/dashboard/project/pyjuquwuyijcyadcnjxc/sql/new
--
-- Features:
-- 1. All 24 Core Tables from Project X Table Inventory & ERD
-- 2. Added User Loyalty Points & Point Transactions Ledger
-- 3. Handles pre-existing profiles/services tables without breaking data
-- 4. Complete Row Level Security (RLS) policies
-- 5. Atomic RPCs: create_booking, accept_booking, transition_booking,
--    request_job_otp, verify_job_otp, award_booking_points
-- 6. Auth trigger: handle_new_user (auto profile & customer role)
-- 7. Seed Catalog: Bengaluru categories, services & variants with real prices in paise
-- ==============================================================================

-- Enable Extensions
create extension if not exists pgcrypto;
create extension if not exists "uuid-ossp";

-- ==============================================================================
-- 1. ENUMS & TYPES
-- ==============================================================================
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

-- ==============================================================================
-- 2. TABLES DDL (MODULES 1 TO 9)
-- ==============================================================================

-- 1. Profiles (auth.users 1--1 profiles)
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

-- 2. User Roles
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

-- 3. Role Transition Events
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

-- 4. Addresses
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

-- 5. Service Categories
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

-- 6. Services
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

-- 7. Service Variants
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

-- 8. Provider Profiles
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

-- 9. Provider Services
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

-- 10. Provider Availability
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

-- 11. Bookings
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

-- 12. Booking Items
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

-- 13. Booking Assignments
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

-- 14. Booking Status Events
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

-- 15. Booking OTP Challenges
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

-- 16. Reviews
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

-- 17. Payments
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

-- 18. Refunds
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

-- 19. Notifications
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

-- 20. Device Tokens
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

-- 21. Support Tickets
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

-- 22. SOS Contacts
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

-- 23. Audit Logs
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

-- 24. API Idempotency Keys
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

-- 25. User Points Table (Customer Loyalty & Rewards Points)
create table if not exists public.user_points (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.profiles(id) on delete cascade,
  available_points int not null default 0 check (available_points >= 0),
  lifetime_points_earned int not null default 0 check (lifetime_points_earned >= 0),
  tier text not null default 'silver' check (tier in ('bronze','silver','gold','platinum')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists user_points_user_idx on public.user_points(user_id);

-- 26. Point Transactions (History Ledger of Points)
create table if not exists public.point_transactions (
  id bigint generated always as identity primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  booking_id uuid references public.bookings(id) on delete set null,
  points int not null,
  type text not null check (type in ('earned','redeemed','expired','bonus','refund')),
  description text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
create index if not exists point_tx_user_idx on public.point_transactions(user_id, created_at desc);

-- Updated_At trigger helper
create or replace function public.set_updated_at()
returns trigger language plpgsql set search_path = public
as $$ begin new.updated_at = now(); return new; end $$;

do $$
declare t text;
begin
  foreach t in array array['profiles','addresses','service_categories','services','provider_profiles','bookings','payments','support_tickets','sos_contacts','user_points'] loop
    execute format('drop trigger if exists set_updated_at on public.%I', t);
    execute format('create trigger set_updated_at before update on public.%I for each row execute function public.set_updated_at()', t);
  end loop;
end $$;

-- ==============================================================================
-- 3. ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================

-- Security Functions
create or replace function public.has_role(p_user_id uuid, p_role public.app_role)
returns boolean language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from public.user_roles
    where user_id = p_user_id
      and role = p_role
      and revoked_at is null
  );
$$;

create or replace function public.is_admin(p_user_id uuid)
returns boolean language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from public.user_roles
    where user_id = p_user_id
      and role in ('admin', 'support')
      and revoked_at is null
  );
$$;

create or replace function public.is_provider_assigned_to_booking(p_booking_id uuid, p_user_id uuid)
returns boolean language sql stable security definer set search_path = public
as $$
  select exists (
    select 1
    from public.booking_assignments ba
    join public.provider_profiles pp on pp.id = ba.provider_id
    where ba.booking_id = p_booking_id
      and pp.user_id = p_user_id
  );
$$;

create or replace function public.is_customer_of_booking(p_booking_id uuid, p_user_id uuid)
returns boolean language sql stable security definer set search_path = public
as $$
  select exists (
    select 1
    from public.bookings
    where id = p_booking_id
      and customer_id = p_user_id
  );
$$;

grant execute on function public.has_role(uuid, public.app_role) to authenticated, anon;
grant execute on function public.is_admin(uuid) to authenticated, anon;
grant execute on function public.is_provider_assigned_to_booking(uuid, uuid) to authenticated, anon;
grant execute on function public.is_customer_of_booking(uuid, uuid) to authenticated, anon;

-- Enable RLS on all tables
do $$
declare t text;
begin
  foreach t in array array[
    'profiles','user_roles','role_transition_events','addresses','service_categories','services','service_variants',
    'provider_profiles','provider_services','provider_availability','bookings','booking_items','booking_assignments',
    'booking_status_events','booking_otp_challenges','reviews','payments','refunds','notifications','device_tokens',
    'support_tickets','sos_contacts','audit_logs','api_idempotency_keys','user_points','point_transactions'
  ] loop
    execute format('alter table public.%I enable row level security', t);
  end loop;
end $$;

-- Clear previous policies
do $$
declare pol record;
begin
  for pol in (select schemaname, tablename, policyname from pg_policies where schemaname = 'public') loop
    execute format('drop policy if exists %I on %I.%I', pol.policyname, pol.schemaname, pol.tablename);
  end loop;
end $$;

-- Policies definition
create policy "Profiles select policy" on public.profiles for select using (true);
create policy "Profiles insert policy" on public.profiles for insert with check (auth.uid() = id or public.is_admin(auth.uid()));
create policy "Profiles update policy" on public.profiles for update using (auth.uid() = id or public.is_admin(auth.uid()));

create policy "User roles select policy" on public.user_roles for select using (user_id = auth.uid() or public.is_admin(auth.uid()));
create policy "User roles admin insert" on public.user_roles for insert with check (public.is_admin(auth.uid()));
create policy "User roles admin update" on public.user_roles for update using (public.is_admin(auth.uid()));

create policy "Role events select policy" on public.role_transition_events for select using (user_id = auth.uid() or actor_user_id = auth.uid() or public.is_admin(auth.uid()));

create policy "Addresses select policy" on public.addresses for select using (
  user_id = auth.uid()
  or public.is_admin(auth.uid())
  or exists (
    select 1 from public.bookings b
    where b.address_id = addresses.id
      and public.is_provider_assigned_to_booking(b.id, auth.uid())
  )
);
create policy "Addresses insert policy" on public.addresses for insert with check (user_id = auth.uid() or public.is_admin(auth.uid()));
create policy "Addresses update policy" on public.addresses for update using (user_id = auth.uid() or public.is_admin(auth.uid()));
create policy "Addresses delete policy" on public.addresses for delete using (user_id = auth.uid() or public.is_admin(auth.uid()));

create policy "Categories select policy" on public.service_categories for select using (is_active = true or public.is_admin(auth.uid()));
create policy "Categories admin write" on public.service_categories for all using (public.is_admin(auth.uid()));

create policy "Services select policy" on public.services for select using (is_active = true or public.is_admin(auth.uid()));
create policy "Services admin write" on public.services for all using (public.is_admin(auth.uid()));

create policy "Variants select policy" on public.service_variants for select using (is_active = true or public.is_admin(auth.uid()));
create policy "Variants admin write" on public.service_variants for all using (public.is_admin(auth.uid()));

create policy "Provider profiles select" on public.provider_profiles for select using (status = 'approved' or user_id = auth.uid() or public.is_admin(auth.uid()));
create policy "Provider profiles insert" on public.provider_profiles for insert with check (user_id = auth.uid() or public.is_admin(auth.uid()));
create policy "Provider profiles update" on public.provider_profiles for update using (user_id = auth.uid() or public.is_admin(auth.uid()));

create policy "Provider services select" on public.provider_services for select using (
  (approval_status = 'approved' and is_active = true)
  or exists (select 1 from public.provider_profiles pp where pp.id = provider_services.provider_id and pp.user_id = auth.uid())
  or public.is_admin(auth.uid())
);
create policy "Provider services write" on public.provider_services for all using (
  exists (select 1 from public.provider_profiles pp where pp.id = provider_services.provider_id and pp.user_id = auth.uid())
  or public.is_admin(auth.uid())
);

create policy "Provider availability select" on public.provider_availability for select using (true);
create policy "Provider availability write" on public.provider_availability for all using (
  exists (select 1 from public.provider_profiles pp where pp.id = provider_availability.provider_id and pp.user_id = auth.uid())
  or public.is_admin(auth.uid())
);

create policy "Bookings select policy" on public.bookings for select using (
  customer_id = auth.uid()
  or public.is_provider_assigned_to_booking(id, auth.uid())
  or public.is_admin(auth.uid())
);
create policy "Bookings insert policy" on public.bookings for insert with check (customer_id = auth.uid() or public.is_admin(auth.uid()));
create policy "Bookings update policy" on public.bookings for update using (
  customer_id = auth.uid()
  or public.is_provider_assigned_to_booking(id, auth.uid())
  or public.is_admin(auth.uid())
);

create policy "Booking items select policy" on public.booking_items for select using (
  public.is_customer_of_booking(booking_id, auth.uid())
  or public.is_provider_assigned_to_booking(booking_id, auth.uid())
  or public.is_admin(auth.uid())
);
create policy "Booking items insert policy" on public.booking_items for insert with check (
  public.is_customer_of_booking(booking_id, auth.uid())
  or public.is_admin(auth.uid())
);

create policy "Assignments select policy" on public.booking_assignments for select using (
  exists (select 1 from public.provider_profiles pp where pp.id = booking_assignments.provider_id and pp.user_id = auth.uid())
  or public.is_customer_of_booking(booking_id, auth.uid())
  or public.is_admin(auth.uid())
);
create policy "Assignments provider write" on public.booking_assignments for all using (
  exists (select 1 from public.provider_profiles pp where pp.id = booking_assignments.provider_id and pp.user_id = auth.uid())
  or public.is_admin(auth.uid())
);

create policy "Status events select policy" on public.booking_status_events for select using (
  public.is_customer_of_booking(booking_id, auth.uid())
  or public.is_provider_assigned_to_booking(booking_id, auth.uid())
  or public.is_admin(auth.uid())
);

create policy "OTP challenges select" on public.booking_otp_challenges for select using (target_user_id = auth.uid() or public.is_admin(auth.uid()));

create policy "Reviews select policy" on public.reviews for select using (
  moderation_status = 'published'
  or reviewer_id = auth.uid()
  or exists (select 1 from public.provider_profiles pp where pp.id = reviews.provider_id and pp.user_id = auth.uid())
  or public.is_admin(auth.uid())
);
create policy "Reviews insert policy" on public.reviews for insert with check (reviewer_id = auth.uid());
create policy "Reviews update policy" on public.reviews for update using (reviewer_id = auth.uid() or public.is_admin(auth.uid()));

create policy "Payments select policy" on public.payments for select using (customer_id = auth.uid() or public.is_admin(auth.uid()));
create policy "Payments insert policy" on public.payments for insert with check (customer_id = auth.uid() or public.is_admin(auth.uid()));
create policy "Payments update policy" on public.payments for update using (customer_id = auth.uid() or public.is_admin(auth.uid()));

create policy "Refunds select policy" on public.refunds for select using (
  exists (select 1 from public.payments p where p.id = refunds.payment_id and p.customer_id = auth.uid())
  or public.is_admin(auth.uid())
);

create policy "Notifications select" on public.notifications for select using (user_id = auth.uid());
create policy "Notifications update" on public.notifications for update using (user_id = auth.uid());
create policy "Notifications insert" on public.notifications for insert with check (user_id = auth.uid() or public.is_admin(auth.uid()));

create policy "Device tokens all" on public.device_tokens for all using (user_id = auth.uid());
create policy "Support tickets select" on public.support_tickets for select using (user_id = auth.uid() or assigned_to = auth.uid() or public.is_admin(auth.uid()));
create policy "Support tickets insert" on public.support_tickets for insert with check (user_id = auth.uid());
create policy "Support tickets update" on public.support_tickets for update using (user_id = auth.uid() or assigned_to = auth.uid() or public.is_admin(auth.uid()));
create policy "SOS contacts all" on public.sos_contacts for all using (user_id = auth.uid());
create policy "Audit logs admin select" on public.audit_logs for select using (public.is_admin(auth.uid()));
create policy "Idempotency keys all" on public.api_idempotency_keys for all using (user_id = auth.uid() or public.is_admin(auth.uid()));

create policy "User points select" on public.user_points for select using (user_id = auth.uid() or public.is_admin(auth.uid()));
create policy "User points update" on public.user_points for update using (user_id = auth.uid() or public.is_admin(auth.uid()));
create policy "Point transactions select" on public.point_transactions for select using (user_id = auth.uid() or public.is_admin(auth.uid()));
create policy "Point transactions insert" on public.point_transactions for insert with check (user_id = auth.uid() or public.is_admin(auth.uid()));

-- ==============================================================================
-- 4. ATOMIC RPCS & AUTH TRIGGERS
-- ==============================================================================

-- Auth User Signup Trigger
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
    id, email, phone_number, full_name, preferred_language, profile_complete, created_at, updated_at
  ) values (
    new.id, new.email, v_phone, v_name, 'en', false, now(), now()
  ) on conflict (id) do update set
    email = coalesce(excluded.email, public.profiles.email),
    phone_number = coalesce(excluded.phone_number, public.profiles.phone_number),
    updated_at = now();

  insert into public.user_roles (user_id, role, granted_at)
  values (new.id, 'customer', now())
  on conflict do nothing;

  -- Initialize points balance for new user
  insert into public.user_points (user_id, available_points, lifetime_points_earned)
  values (new.id, 50, 50) -- 50 Welcome bonus points!
  on conflict do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- create_booking
create or replace function public.create_booking(
  payload jsonb,
  idempotency_key text
)
returns jsonb language plpgsql security definer set search_path = public
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
begin
  v_caller_id := auth.uid();
  if v_caller_id is null then raise exception '401: Unauthenticated'; end if;
  if idempotency_key is null or trim(idempotency_key) = '' then raise exception '400: Idempotency-Key is required'; end if;

  select id, booking_number, status, total_paise, created_at into v_existing_booking
  from public.bookings where customer_id = v_caller_id and idempotency_key = create_booking.idempotency_key;

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

  if payload ? 'address_id' and (payload->>'address_id') is not null then
    v_address_id := (payload->>'address_id')::uuid;
  elsif payload ? 'address' and (payload->'address') is not null then
    insert into public.addresses (
      user_id, recipient_name, recipient_phone, address_line1, address_line2, locality, city, state, postal_code, instructions
    ) values (
      v_caller_id, payload->'address'->>'recipient_name', payload->'address'->>'recipient_phone',
      coalesce(payload->'address'->>'address_line1', payload->'address'->>'address', 'Address details'),
      payload->'address'->>'address_line2', payload->'address'->>'locality',
      coalesce(payload->'address'->>'city', 'Bengaluru'), coalesce(payload->'address'->>'state', 'Karnataka'),
      payload->'address'->>'postal_code', payload->'address'->>'instructions'
    ) returning id into v_address_id;
  else
    select id into v_address_id from public.addresses where user_id = v_caller_id order by is_default desc, created_at desc limit 1;
  end if;

  if (payload->>'scheduled_start') is not null then v_scheduled_start := (payload->>'scheduled_start')::timestamptz;
  else v_scheduled_start := now() + interval '15 minutes'; end if;

  if (payload->>'scheduled_end') is not null then v_scheduled_end := (payload->>'scheduled_end')::timestamptz;
  else v_scheduled_end := v_scheduled_start + interval '1 hour'; end if;

  v_notes := payload->>'customer_notes';

  if not (payload ? 'items') or jsonb_array_length(payload->'items') = 0 then
    raise exception '400: Booking must contain at least one service item';
  end if;

  for v_item in select * from jsonb_array_elements(payload->'items') loop
    v_variant_id := (v_item->>'variant_id')::uuid;
    v_qty := coalesce((v_item->>'quantity')::int, 1);
    if v_qty <= 0 then raise exception '400: Item quantity must be greater than 0'; end if;

    select v.id, v.name as variant_name, coalesce(s.name, s.title, 'Service') as service_name, v.base_price_paise, v.tax_rate_bps, v.estimated_duration_minutes
    into v_variant from public.service_variants v join public.services s on s.id = v.service_id
    where v.id = v_variant_id and v.is_active = true;

    if v_variant.id is null then raise exception '422: Service variant % is not active', v_variant_id; end if;

    v_line_total := v_variant.base_price_paise * v_qty;
    v_line_tax := (v_line_total * v_variant.tax_rate_bps) / 10000;
    v_subtotal_paise := v_subtotal_paise + v_line_total;
    v_tax_paise := v_tax_paise + v_line_tax;
  end loop;

  v_total_paise := v_subtotal_paise + v_tax_paise;

  insert into public.bookings (
    customer_id, address_id, status, requested_at, scheduled_start, scheduled_end,
    customer_notes, currency, subtotal_paise, tax_paise, discount_paise, total_paise, idempotency_key
  ) values (
    v_caller_id, v_address_id, 'requested', now(), v_scheduled_start, v_scheduled_end,
    v_notes, 'INR', v_subtotal_paise, v_tax_paise, 0, v_total_paise, create_booking.idempotency_key
  ) returning id, booking_number into v_booking_id, v_booking_number;

  for v_item in select * from jsonb_array_elements(payload->'items') loop
    v_variant_id := (v_item->>'variant_id')::uuid;
    v_qty := coalesce((v_item->>'quantity')::int, 1);

    select v.name as variant_name, coalesce(s.name, s.title, 'Service') as service_name, v.base_price_paise, v.tax_rate_bps, v.estimated_duration_minutes
    into v_variant from public.service_variants v join public.services s on s.id = v.service_id where v.id = v_variant_id;

    v_line_total := v_variant.base_price_paise * v_qty;

    insert into public.booking_items (
      booking_id, variant_id, service_name_snapshot, variant_name_snapshot,
      unit_price_paise, quantity, duration_minutes_snapshot, tax_rate_bps_snapshot, line_total_paise
    ) values (
      v_booking_id, v_variant_id, v_variant.service_name, v_variant.variant_name,
      v_variant.base_price_paise, v_qty, v_variant.estimated_duration_minutes * v_qty, v_variant.tax_rate_bps, v_line_total
    );
  end loop;

  insert into public.booking_status_events (
    booking_id, from_status, to_status, actor_user_id, actor_role, reason_code, notes, metadata
  ) values (
    v_booking_id, null, 'requested', v_caller_id, 'customer', 'BOOKING_CREATED',
    'Booking requested by customer', jsonb_build_object('booking_number', v_booking_number)
  );

  insert into public.notifications (
    user_id, booking_id, channel, title, body, payload
  ) values (
    v_caller_id, v_booking_id, 'in_app', 'Booking Requested',
    format('Your booking #%s has been requested. We are matching you with top-rated nearby pros.', v_booking_number),
    jsonb_build_object('booking_id', v_booking_id, 'status', 'requested')
  );

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

-- accept_booking
create or replace function public.accept_booking(
  p_booking_id uuid,
  p_idempotency_key text default null
)
returns jsonb language plpgsql security definer set search_path = public
as $$
declare
  v_caller_id uuid;
  v_provider record;
  v_booking record;
begin
  v_caller_id := auth.uid();
  if v_caller_id is null then raise exception '401: Unauthenticated'; end if;

  select id, status, business_name into v_provider
  from public.provider_profiles where user_id = v_caller_id;

  if v_provider.id is null or v_provider.status != 'approved' then
    raise exception '403: Caller must be an approved service provider';
  end if;

  select * into v_booking from public.bookings where id = p_booking_id for update;
  if v_booking.id is null then raise exception '404: Booking not found'; end if;
  if v_booking.status != 'requested' then
    raise exception '409: Booking is no longer in requested status (current: %)', v_booking.status;
  end if;

  if exists (select 1 from public.booking_assignments where booking_id = p_booking_id and status in ('offered','accepted') and unassigned_at is null) then
    raise exception '409: Booking has already been assigned';
  end if;

  insert into public.booking_assignments (
    booking_id, provider_id, status, offered_at, responded_at, assigned_at, created_by
  ) values (
    p_booking_id, v_provider.id, 'accepted', now(), now(), now(), v_caller_id
  );

  update public.bookings set status = 'accepted', accepted_at = now(), updated_at = now() where id = p_booking_id;

  insert into public.booking_status_events (
    booking_id, from_status, to_status, actor_user_id, actor_role, reason_code, notes, metadata
  ) values (
    p_booking_id, 'requested', 'accepted', v_caller_id, 'provider', 'PROVIDER_ACCEPTED',
    format('Accepted by %s', coalesce(v_provider.business_name, 'Provider')), jsonb_build_object('provider_id', v_provider.id)
  );

  insert into public.notifications (
    user_id, booking_id, channel, title, body, payload
  ) values (
    v_booking.customer_id, p_booking_id, 'in_app', 'Provider Confirmed!',
    format('%s has accepted your booking and is preparing for service.', coalesce(v_provider.business_name, 'Your professional')),
    jsonb_build_object('booking_id', p_booking_id, 'status', 'accepted', 'provider_id', v_provider.id)
  );

  return jsonb_build_object('booking_id', p_booking_id, 'status', 'accepted', 'accepted_at', now(), 'provider_id', v_provider.id);
end;
$$;

-- transition_booking
create or replace function public.transition_booking(
  p_booking_id uuid,
  p_target_status text,
  p_reason_code text default null,
  p_metadata jsonb default '{}'::jsonb
)
returns jsonb language plpgsql security definer set search_path = public
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
  if v_caller_id is null then raise exception '401: Unauthenticated'; end if;
  v_target := p_target_status::public.booking_status;

  select * into v_booking from public.bookings where id = p_booking_id for update;
  if v_booking.id is null then raise exception '404: Booking not found'; end if;

  if v_booking.customer_id = v_caller_id then v_is_customer := true; v_actor_role := 'customer'; end if;
  if exists (select 1 from public.booking_assignments ba join public.provider_profiles pp on pp.id = ba.provider_id where ba.booking_id = p_booking_id and pp.user_id = v_caller_id and ba.status in ('offered','accepted','completed')) then
    v_is_provider := true; v_actor_role := 'provider';
  end if;
  if public.is_admin(v_caller_id) then v_is_admin := true; v_actor_role := 'admin'; end if;

  if not (v_is_customer or v_is_provider or v_is_admin) then raise exception '403: Caller is not a participant'; end if;

  case v_booking.status
    when 'requested' then
      if v_target not in ('accepted', 'rejected', 'cancelled', 'expired') then raise exception '409: Invalid transition requested -> %', v_target; end if;
    when 'accepted' then
      if v_target not in ('provider_en_route', 'cancelled', 'no_show', 'disputed') then raise exception '409: Invalid transition accepted -> %', v_target; end if;
    when 'provider_en_route' then
      if v_target not in ('arrived', 'cancelled', 'no_show', 'disputed') then raise exception '409: Invalid transition provider_en_route -> %', v_target; end if;
    when 'arrived' then
      if v_target not in ('in_progress', 'cancelled', 'no_show', 'disputed') then raise exception '409: Invalid transition arrived -> %', v_target; end if;
    when 'in_progress' then
      if v_target not in ('completed', 'disputed') then raise exception '409: Invalid transition in_progress -> %', v_target; end if;
    else
      raise exception '409: Cannot transition from terminal status %', v_booking.status;
  end case;

  if v_target in ('provider_en_route', 'arrived', 'in_progress', 'completed') and not (v_is_provider or v_is_admin) then
    raise exception '403: Only the assigned provider can advance execution status';
  end if;

  update public.bookings
  set status = v_target,
      started_at = case when v_target = 'in_progress' and started_at is null then now() else started_at end,
      completed_at = case when v_target = 'completed' and completed_at is null then now() else completed_at end,
      cancelled_at = case when v_target = 'cancelled' and cancelled_at is null then now() else cancelled_at end,
      cancellation_reason = case when v_target = 'cancelled' then coalesce(p_reason_code, cancellation_reason) else cancellation_reason end,
      updated_at = now()
  where id = p_booking_id;

  insert into public.booking_status_events (
    booking_id, from_status, to_status, actor_user_id, actor_role, reason_code, notes, metadata
  ) values (
    p_booking_id, v_booking.status, v_target, v_caller_id, v_actor_role,
    coalesce(p_reason_code, 'STATUS_TRANSITION'), format('Transitioned to %s', v_target), p_metadata
  );

  -- Award points if completed
  if v_target = 'completed' then
    perform public.award_booking_points(p_booking_id);
  end if;

  return jsonb_build_object('booking_id', p_booking_id, 'from_status', v_booking.status, 'to_status', v_target, 'updated_at', now());
end;
$$;

-- request_job_otp
create or replace function public.request_job_otp(
  p_booking_id uuid,
  p_purpose text
)
returns jsonb language plpgsql security definer set search_path = public
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
  if v_caller_id is null then raise exception '401: Unauthenticated'; end if;
  if p_purpose not in ('arrival', 'start', 'completion', 'handover') then raise exception '400: Invalid purpose %', p_purpose; end if;

  select * into v_booking from public.bookings where id = p_booking_id;
  if v_booking.id is null then raise exception '404: Booking not found'; end if;

  select count(*) into v_recent_count from public.booking_otp_challenges
  where booking_id = p_booking_id and created_at > (now() - interval '10 minutes');
  if v_recent_count >= 3 then raise exception '429: Maximum 3 OTP requests per 10 minutes'; end if;

  v_target_user_id := v_booking.customer_id;
  v_code := lpad((floor(random() * 9000) + 1000)::int::text, 4, '0');
  v_code_hash := crypt(v_code, gen_salt('bf', 8));

  update public.booking_otp_challenges set invalidated_at = now()
  where booking_id = p_booking_id and purpose = p_purpose and verified_at is null and invalidated_at is null;

  insert into public.booking_otp_challenges (
    booking_id, target_user_id, purpose, code_hash, expires_at, attempts, max_attempts
  ) values (
    p_booking_id, v_target_user_id, p_purpose, v_code_hash, now() + interval '10 minutes', 0, 5
  ) returning id into v_challenge_id;

  insert into public.notifications (
    user_id, booking_id, channel, title, body, payload
  ) values (
    v_target_user_id, p_booking_id, 'in_app', format('Your Service OTP: %s', v_code),
    format('Share this OTP (%s) with your provider for %s verification.', v_code, p_purpose),
    jsonb_build_object('otp', v_code, 'purpose', p_purpose, 'booking_id', p_booking_id)
  );

  return jsonb_build_object('challenge_id', v_challenge_id, 'purpose', p_purpose, 'expires_at', (now() + interval '10 minutes'), 'otp', v_code);
end;
$$;

-- verify_job_otp
create or replace function public.verify_job_otp(
  p_challenge_id uuid,
  p_code text
)
returns jsonb language plpgsql security definer set search_path = public
as $$
declare
  v_caller_id uuid;
  v_challenge record;
  v_booking record;
begin
  v_caller_id := auth.uid();
  if v_caller_id is null then raise exception '401: Unauthenticated'; end if;

  select * into v_challenge from public.booking_otp_challenges where id = p_challenge_id for update;
  if v_challenge.id is null then raise exception '404: Challenge not found'; end if;
  if v_challenge.verified_at is not null then return jsonb_build_object('success', true, 'message', 'Already verified'); end if;
  if v_challenge.invalidated_at is not null then raise exception '422: OTP invalidated'; end if;
  if now() > v_challenge.expires_at then raise exception '422: OTP expired'; end if;
  if v_challenge.attempts >= v_challenge.max_attempts then raise exception '429: Maximum attempts exceeded'; end if;

  update public.booking_otp_challenges set attempts = attempts + 1 where id = p_challenge_id;

  if crypt(p_code, v_challenge.code_hash) != v_challenge.code_hash then
    raise exception '400: Incorrect OTP code. % attempts remaining.', (v_challenge.max_attempts - v_challenge.attempts - 1);
  end if;

  update public.booking_otp_challenges set verified_at = now() where id = p_challenge_id;

  select * into v_booking from public.bookings where id = v_challenge.booking_id for update;

  if v_challenge.purpose in ('arrival', 'start') and v_booking.status in ('accepted', 'provider_en_route', 'arrived') then
    update public.bookings set status = 'in_progress', started_at = coalesce(started_at, now()), updated_at = now() where id = v_booking.id;
    insert into public.booking_status_events (booking_id, from_status, to_status, actor_user_id, actor_role, notes)
    values (v_booking.id, v_booking.status, 'in_progress', v_caller_id, 'provider', 'Verified start OTP');
  elsif v_challenge.purpose in ('completion', 'handover') and v_booking.status = 'in_progress' then
    update public.bookings set status = 'completed', completed_at = coalesce(completed_at, now()), updated_at = now() where id = v_booking.id;
    insert into public.booking_status_events (booking_id, from_status, to_status, actor_user_id, actor_role, notes)
    values (v_booking.id, 'in_progress', 'completed', v_caller_id, 'provider', 'Verified completion OTP');
    perform public.award_booking_points(v_booking.id);
  end if;

  return jsonb_build_object('success', true, 'verified', true, 'booking_id', v_challenge.booking_id, 'purpose', v_challenge.purpose);
end;
$$;

-- award_booking_points
create or replace function public.award_booking_points(
  p_booking_id uuid,
  p_points_multiplier numeric default 0.05
)
returns jsonb language plpgsql security definer set search_path = public
as $$
declare
  v_booking record;
  v_points_earned int;
begin
  select * into v_booking from public.bookings where id = p_booking_id;
  if v_booking.id is null then raise exception 'Booking not found'; end if;

  v_points_earned := greatest(10, floor((v_booking.total_paise / 100) * p_points_multiplier)::int);

  insert into public.user_points (user_id, available_points, lifetime_points_earned)
  values (v_booking.customer_id, v_points_earned, v_points_earned)
  on conflict (user_id) do update set
    available_points = public.user_points.available_points + excluded.available_points,
    lifetime_points_earned = public.user_points.lifetime_points_earned + excluded.lifetime_points_earned,
    updated_at = now();

  insert into public.point_transactions (user_id, booking_id, points, type, description, metadata)
  values (
    v_booking.customer_id, p_booking_id, v_points_earned, 'earned',
    format('Reward points for completed booking #%s', v_booking.booking_number),
    jsonb_build_object('booking_id', p_booking_id, 'total_paise', v_booking.total_paise)
  );

  return jsonb_build_object('success', true, 'user_id', v_booking.customer_id, 'points_earned', v_points_earned);
end;
$$;

grant execute on function public.create_booking(jsonb, text) to authenticated;
grant execute on function public.accept_booking(uuid, text) to authenticated;
grant execute on function public.transition_booking(uuid, text, text, jsonb) to authenticated;
grant execute on function public.request_job_otp(uuid, text) to authenticated;
grant execute on function public.verify_job_otp(uuid, text) to authenticated;
grant execute on function public.award_booking_points(uuid, numeric) to authenticated;

-- ==============================================================================
-- 5. BENGALURU CATALOG DISCOVERY SEED DATA
-- ==============================================================================
do $$
declare
  cat_plumbing uuid;
  cat_electrician uuid;
  cat_cleaning uuid;
  cat_appliance uuid;
  cat_carpentry uuid;
  cat_painting uuid;

  srv_tap uuid;
  srv_sink uuid;
  srv_tank uuid;

  srv_switchboard uuid;
  srv_fan uuid;
  srv_mcb uuid;

  srv_home_clean uuid;
  srv_bath_clean uuid;

  srv_ac uuid;
  srv_washing uuid;
begin
  insert into public.service_categories (slug, name, description, sort_order, is_active)
  values 
    ('plumbing', 'Plumbing', 'Tap fittings, water leaks, pipelines, tanks & drain unblocking', 1, true)
  on conflict (slug) do update set name = excluded.name returning id into cat_plumbing;

  insert into public.service_categories (slug, name, description, sort_order, is_active)
  values 
    ('electrician', 'Electrician', 'Switchboard, wiring, fans, chandeliers, MCB & power troubleshooting', 2, true)
  on conflict (slug) do update set name = excluded.name returning id into cat_electrician;

  insert into public.service_categories (slug, name, description, sort_order, is_active)
  values 
    ('cleaning', 'Cleaning & Sanitization', 'Full apartment deep cleaning, bathroom descaling, kitchen & sofa', 3, true)
  on conflict (slug) do update set name = excluded.name returning id into cat_cleaning;

  insert into public.service_categories (slug, name, description, sort_order, is_active)
  values 
    ('appliance', 'Appliance Repair', 'AC power saver foam cleaning, gas top-up, washing machine & fridge', 4, true)
  on conflict (slug) do update set name = excluded.name returning id into cat_appliance;

  insert into public.service_categories (slug, name, description, sort_order, is_active)
  values 
    ('carpentry', 'Carpentry & Furniture', 'Door locks, hinges, curtain rods, drilling & furniture assembly', 5, true)
  on conflict (slug) do update set name = excluded.name returning id into cat_carpentry;

  insert into public.service_categories (slug, name, description, sort_order, is_active)
  values 
    ('painting', 'Painting & Waterproofing', 'Single wall texture, interior touchup, waterproofing & full home', 6, true)
  on conflict (slug) do update set name = excluded.name returning id into cat_painting;

  -- Plumbing Services & Variants
  insert into public.services (category_id, slug, name, title, category, short_description, description, price, price_unit, sub_categories, is_active)
  values 
    (cat_plumbing, 'plumbing-tap-mixer', 'Tap & Faucet Installation', 'Plumber', 'plumbing', 'Water Leakage, Tap Fitting & Drain Unclogging', 'Expert plumbing services for pipe leaks, tap replacement, bathroom fitting installations.', 99.00, '/visit', array['Tap Repair','Mixer Fitting','Washer Replacement'], true)
  on conflict (slug) do update set name = excluded.name returning id into srv_tap;

  insert into public.services (category_id, slug, name, title, category, short_description, description, price, price_unit, sub_categories, is_active)
  values 
    (cat_plumbing, 'plumbing-sink-unclog', 'Washbasin & Sink Repair', 'Sink Specialist', 'plumbing', 'Sink pipe unclogging and bottle trap replacement', 'Clears kitchen sink blockage and installs waste coupling and PVC pipes.', 249.00, '/job', array['Sink Unclogging','Bottle Trap Repair'], true)
  on conflict (slug) do update set name = excluded.name returning id into srv_sink;

  insert into public.services (category_id, slug, name, title, category, short_description, description, price, price_unit, sub_categories, is_active)
  values 
    (cat_plumbing, 'plumbing-water-tank', 'Overhead Water Tank Cleaning', 'Water Tank Pro', 'plumbing', 'Hygienic mechanized sludge removal & UV sanitization', 'Complete deep disinfection of overhead Sintex or concrete water tanks up to 1000L.', 799.00, '/tank', array['Mechanized Sludge Extraction','UV Antibacterial Rinse'], true)
  on conflict (slug) do update set name = excluded.name returning id into srv_tank;

  insert into public.service_variants (service_id, sku, name, description, base_price_paise, estimated_duration_minutes, tax_rate_bps, unit_label, is_active)
  values
    (srv_tap, 'VAR-TAP-SINGLE', 'Single Tap / Spindle Replacement', 'Fix continuous dripping or replace brass spindle', 9900, 20, 500, 'tap', true),
    (srv_tap, 'VAR-TAP-MIXER', 'Wall Mixer / Diverter Fitting', 'Complete replacement of hot & cold bath mixer unit', 24900, 45, 500, 'unit', true),
    (srv_sink, 'VAR-SINK-UNCLOG', 'Sink Waste Coupling & Trap Clearance', 'Mechanical snake clean of bottle trap and outlet pipe', 19900, 30, 500, 'sink', true),
    (srv_tank, 'VAR-TANK-1000L', 'Overhead Tank Cleaning (Up to 1000L)', 'Mechanized suction, high-pressure jet wash and potassium wash', 79900, 60, 1800, 'tank', true)
  on conflict (sku) do update set base_price_paise = excluded.base_price_paise;

  -- Electrician Services & Variants
  insert into public.services (category_id, slug, name, title, category, short_description, description, price, price_unit, sub_categories, is_active)
  values 
    (cat_electrician, 'elec-switchboard', 'Switchboard & Socket Installation', 'Electrician', 'electrician', 'Modular switch repair, socket replacement & wiring', 'Certified electrical technicians for safe switches, 16A AC sockets and earthing inspection.', 149.00, '/visit', array['Modular Switch Replacement','16A Power Socket Installation'], true)
  on conflict (slug) do update set name = excluded.name returning id into srv_switchboard;

  insert into public.services (category_id, slug, name, title, category, short_description, description, price, price_unit, sub_categories, is_active)
  values 
    (cat_electrician, 'elec-fan', 'Ceiling Fan Installation & Repair', 'Fan Technician', 'electrician', 'Regulator replacement, blade balancing & new fan mounting', 'Fast fan installation with heavy-duty anchor fasteners and silent operation balancing.', 199.00, '/fan', array['Ceiling Fan Fitting','Capacitor & Regulator Check'], true)
  on conflict (slug) do update set name = excluded.name returning id into srv_fan;

  insert into public.services (category_id, slug, name, title, category, short_description, description, price, price_unit, sub_categories, is_active)
  values 
    (cat_electrician, 'elec-mcb', 'MCB Tripping & Fuse Box Repair', 'Power Specialist', 'electrician', 'Short-circuit detection and distribution board repair', 'Isolates burnt wires, balances phase load and replaces malfunctioning double-pole MCBs.', 299.00, '/job', array['MCB Diagnosis','Distribution Board Rewiring'], true)
  on conflict (slug) do update set name = excluded.name returning id into srv_mcb;

  insert into public.service_variants (service_id, sku, name, description, base_price_paise, estimated_duration_minutes, tax_rate_bps, unit_label, is_active)
  values
    (srv_switchboard, 'VAR-ELEC-SWITCH', 'Modular Switch / 6A Socket Replacement', 'Includes testing with digital multimeter and safe earthing', 7900, 15, 500, 'switch', true),
    (srv_switchboard, 'VAR-ELEC-BOARD', 'Complete 8-Modular Board Installation', 'New box fitting, concealed cutting and wiring terminations', 29900, 45, 500, 'board', true),
    (srv_fan, 'VAR-FAN-INSTALL', 'Ceiling Fan Installation with Fasteners', 'Assembling downrod, balancing blades and ceiling hook fastening', 14900, 25, 500, 'fan', true),
    (srv_mcb, 'VAR-MCB-REPAIR', 'Double Pole MCB / Isolator Replacement', 'Resolves recurrent tripping and neutral leakage currents', 29900, 40, 500, 'mcb', true)
  on conflict (sku) do update set base_price_paise = excluded.base_price_paise;

  -- Cleaning Services & Variants
  insert into public.services (category_id, slug, name, title, category, short_description, description, price, price_unit, sub_categories, is_active)
  values 
    (cat_cleaning, 'clean-full-home', 'Full Home Deep Cleaning', 'House Cleaning', 'cleaning', 'Intensive mechanized scrubbing, balcony, kitchen and bathroom', 'Complete sanitization with industrial vacuuming, degreasing, and floor scrubbing machines.', 1499.00, '/flat', array['1 BHK Cleaning','2 BHK Cleaning','Balcony Jet Spray'], true)
  on conflict (slug) do update set name = excluded.name returning id into srv_home_clean;

  insert into public.services (category_id, slug, name, title, category, short_description, description, price, price_unit, sub_categories, is_active)
  values 
    (cat_cleaning, 'clean-bathroom', 'Bathroom Tile & Tap Descaling', 'Bathroom Pro', 'cleaning', 'Hard water stain removal, WC disinfection & mirror buffing', 'Removes 100% limescale, hard water stains from tiles, fixtures, taps and showerheads.', 399.00, '/bathroom', array['Hard Water Stain Treatment','Grout Buffing'], true)
  on conflict (slug) do update set name = excluded.name returning id into srv_bath_clean;

  insert into public.service_variants (service_id, sku, name, description, base_price_paise, estimated_duration_minutes, tax_rate_bps, unit_label, is_active)
  values
    (srv_home_clean, 'VAR-CLEAN-1BHK', '1 BHK Full Home Deep Cleaning', 'Bedrooms, living room, windows, balcony, kitchen and 1 bath', 149900, 180, 1800, 'flat', true),
    (srv_home_clean, 'VAR-CLEAN-2BHK', '2 BHK Full Home Deep Cleaning', 'Complete apartment deep cleaning with high-rpm floor scrubbers', 219900, 240, 1800, 'flat', true),
    (srv_bath_clean, 'VAR-CLEAN-BATH', 'Single Bathroom Hard Water Descaling', 'Intense acid-free descaling of tiles, commode, taps & glass', 39900, 45, 1800, 'bathroom', true)
  on conflict (sku) do update set base_price_paise = excluded.base_price_paise;

  -- Appliance Services & Variants
  insert into public.services (category_id, slug, name, title, category, short_description, description, price, price_unit, sub_categories, is_active)
  values 
    (cat_appliance, 'app-ac-service', 'Split AC Deep Foam Jet Service', 'AC Technician', 'appliance', 'Power jet cleaning, cooling coil foam bath, gas pressure check', 'Increases cooling efficiency up to 2.5x and cuts electricity bills with non-toxic foam jet wash.', 499.00, '/unit', array['Indoor Unit Foam Jet Wash','Outdoor Condenser Pressure Clean'], true)
  on conflict (slug) do update set name = excluded.name returning id into srv_ac;

  insert into public.services (category_id, slug, name, title, category, short_description, description, price, price_unit, sub_categories, is_active)
  values 
    (cat_appliance, 'app-washing-machine', 'Washing Machine Inspection & Repair', 'Appliance Pro', 'appliance', 'Drum vibration, drainage pump, error codes & motor check', 'Comprehensive diagnosis for front-load, top-load, and semi-automatic washing machines.', 249.00, '/visit', array['Drum Spin Fix','Water Inlet & Drain Repair'], true)
  on conflict (slug) do update set name = excluded.name returning id into srv_washing;

  insert into public.service_variants (service_id, sku, name, description, base_price_paise, estimated_duration_minutes, tax_rate_bps, unit_label, is_active)
  values
    (srv_ac, 'VAR-AC-FOAM-JET', 'Split AC Foam Jet Power Wash', 'Deep cleaning with indoor AC jacket, foam spray and fin comb', 49900, 45, 1800, 'unit', true),
    (srv_washing, 'VAR-WASH-INSPECT', 'Washing Machine Diagnostic Checkup', 'Diagnose motor, drain pump, drum bearings and PCB controller', 24900, 30, 500, 'unit', true)
  on conflict (sku) do update set base_price_paise = excluded.base_price_paise;

end $$;
