-- ==============================================================================
-- PROJECT X: ROW LEVEL SECURITY (RLS) POLICIES
-- Strict least-privilege policies based on Project_X_API_Rate_Limit_and_RLS_Spec.md
-- ==============================================================================

-- 1. Helper Security Functions
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

-- 2. Enable RLS on all 24 tables
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

-- Drop all existing policies to ensure clean state
do $$
declare
  pol record;
begin
  for pol in (
    select schemaname, tablename, policyname
    from pg_policies
    where schemaname = 'public'
  ) loop
    execute format('drop policy if exists %I on %I.%I', pol.policyname, pol.schemaname, pol.tablename);
  end loop;
end $$;

-- ==============================================================================
-- 3. Profiles Policies
-- ==============================================================================
create policy "Profiles select policy" on public.profiles
  for select using (true);

create policy "Profiles insert policy" on public.profiles
  for insert with check (auth.uid() = id or public.is_admin(auth.uid()));

create policy "Profiles update policy" on public.profiles
  for update using (auth.uid() = id or public.is_admin(auth.uid()));

-- ==============================================================================
-- 4. User Roles & Role Transition Events
-- ==============================================================================
create policy "User roles select policy" on public.user_roles
  for select using (user_id = auth.uid() or public.is_admin(auth.uid()));

create policy "User roles admin insert" on public.user_roles
  for insert with check (public.is_admin(auth.uid()));

create policy "User roles admin update" on public.user_roles
  for update using (public.is_admin(auth.uid()));

create policy "Role events select policy" on public.role_transition_events
  for select using (user_id = auth.uid() or actor_user_id = auth.uid() or public.is_admin(auth.uid()));

-- ==============================================================================
-- 5. Addresses Policies
-- ==============================================================================
create policy "Addresses select policy" on public.addresses
  for select using (
    user_id = auth.uid()
    or public.is_admin(auth.uid())
    or exists (
      select 1 from public.bookings b
      where b.address_id = addresses.id
        and public.is_provider_assigned_to_booking(b.id, auth.uid())
    )
  );

create policy "Addresses insert policy" on public.addresses
  for insert with check (user_id = auth.uid() or public.is_admin(auth.uid()));

create policy "Addresses update policy" on public.addresses
  for update using (user_id = auth.uid() or public.is_admin(auth.uid()));

create policy "Addresses delete policy" on public.addresses
  for delete using (user_id = auth.uid() or public.is_admin(auth.uid()));

-- ==============================================================================
-- 6. Catalog Policies: Categories, Services, Variants (Public Read, Admin Write)
-- ==============================================================================
create policy "Categories select policy" on public.service_categories
  for select using (is_active = true or public.is_admin(auth.uid()));

create policy "Categories admin write" on public.service_categories
  for all using (public.is_admin(auth.uid()));

create policy "Services select policy" on public.services
  for select using (is_active = true or public.is_admin(auth.uid()));

create policy "Services admin write" on public.services
  for all using (public.is_admin(auth.uid()));

create policy "Variants select policy" on public.service_variants
  for select using (is_active = true or public.is_admin(auth.uid()));

create policy "Variants admin write" on public.service_variants
  for all using (public.is_admin(auth.uid()));

-- ==============================================================================
-- 7. Provider Profiles, Services & Availability
-- ==============================================================================
create policy "Provider profiles select" on public.provider_profiles
  for select using (status = 'approved' or user_id = auth.uid() or public.is_admin(auth.uid()));

create policy "Provider profiles insert" on public.provider_profiles
  for insert with check (user_id = auth.uid() or public.is_admin(auth.uid()));

create policy "Provider profiles update" on public.provider_profiles
  for update using (user_id = auth.uid() or public.is_admin(auth.uid()));

create policy "Provider services select" on public.provider_services
  for select using (
    (approval_status = 'approved' and is_active = true)
    or exists (select 1 from public.provider_profiles pp where pp.id = provider_services.provider_id and pp.user_id = auth.uid())
    or public.is_admin(auth.uid())
  );

create policy "Provider services write" on public.provider_services
  for all using (
    exists (select 1 from public.provider_profiles pp where pp.id = provider_services.provider_id and pp.user_id = auth.uid())
    or public.is_admin(auth.uid())
  );

create policy "Provider availability select" on public.provider_availability
  for select using (true);

create policy "Provider availability write" on public.provider_availability
  for all using (
    exists (select 1 from public.provider_profiles pp where pp.id = provider_availability.provider_id and pp.user_id = auth.uid())
    or public.is_admin(auth.uid())
  );

-- ==============================================================================
-- 8. Bookings & Booking Items
-- ==============================================================================
create policy "Bookings select policy" on public.bookings
  for select using (
    customer_id = auth.uid()
    or public.is_provider_assigned_to_booking(id, auth.uid())
    or public.is_admin(auth.uid())
  );

create policy "Bookings insert policy" on public.bookings
  for insert with check (customer_id = auth.uid() or public.is_admin(auth.uid()));

create policy "Bookings update policy" on public.bookings
  for update using (
    customer_id = auth.uid()
    or public.is_provider_assigned_to_booking(id, auth.uid())
    or public.is_admin(auth.uid())
  );

create policy "Booking items select policy" on public.booking_items
  for select using (
    public.is_customer_of_booking(booking_id, auth.uid())
    or public.is_provider_assigned_to_booking(booking_id, auth.uid())
    or public.is_admin(auth.uid())
  );

create policy "Booking items insert policy" on public.booking_items
  for insert with check (
    public.is_customer_of_booking(booking_id, auth.uid())
    or public.is_admin(auth.uid())
  );

-- ==============================================================================
-- 9. Booking Assignments & Timeline Events
-- ==============================================================================
create policy "Assignments select policy" on public.booking_assignments
  for select using (
    exists (select 1 from public.provider_profiles pp where pp.id = booking_assignments.provider_id and pp.user_id = auth.uid())
    or public.is_customer_of_booking(booking_id, auth.uid())
    or public.is_admin(auth.uid())
  );

create policy "Assignments provider write" on public.booking_assignments
  for all using (
    exists (select 1 from public.provider_profiles pp where pp.id = booking_assignments.provider_id and pp.user_id = auth.uid())
    or public.is_admin(auth.uid())
  );

create policy "Status events select policy" on public.booking_status_events
  for select using (
    public.is_customer_of_booking(booking_id, auth.uid())
    or public.is_provider_assigned_to_booking(booking_id, auth.uid())
    or public.is_admin(auth.uid())
  );

-- ==============================================================================
-- 10. OTP Challenges
-- ==============================================================================
create policy "OTP challenges select" on public.booking_otp_challenges
  for select using (target_user_id = auth.uid() or public.is_admin(auth.uid()));

-- ==============================================================================
-- 11. Reviews
-- ==============================================================================
create policy "Reviews select policy" on public.reviews
  for select using (
    moderation_status = 'published'
    or reviewer_id = auth.uid()
    or exists (select 1 from public.provider_profiles pp where pp.id = reviews.provider_id and pp.user_id = auth.uid())
    or public.is_admin(auth.uid())
  );

create policy "Reviews insert policy" on public.reviews
  for insert with check (
    reviewer_id = auth.uid()
    and exists (
      select 1 from public.bookings b
      where b.id = reviews.booking_id
        and b.customer_id = auth.uid()
        and b.status = 'completed'
    )
  );

create policy "Reviews update policy" on public.reviews
  for update using (reviewer_id = auth.uid() or public.is_admin(auth.uid()));

-- ==============================================================================
-- 12. Payments & Refunds
-- ==============================================================================
create policy "Payments select policy" on public.payments
  for select using (customer_id = auth.uid() or public.is_admin(auth.uid()));

create policy "Payments insert policy" on public.payments
  for insert with check (customer_id = auth.uid() or public.is_admin(auth.uid()));

create policy "Payments update policy" on public.payments
  for update using (customer_id = auth.uid() or public.is_admin(auth.uid()));

create policy "Refunds select policy" on public.refunds
  for select using (
    exists (select 1 from public.payments p where p.id = refunds.payment_id and p.customer_id = auth.uid())
    or public.is_admin(auth.uid())
  );

-- ==============================================================================
-- 13. Notifications & Device Tokens
-- ==============================================================================
create policy "Notifications select" on public.notifications
  for select using (user_id = auth.uid());

create policy "Notifications update" on public.notifications
  for update using (user_id = auth.uid());

create policy "Notifications insert" on public.notifications
  for insert with check (user_id = auth.uid() or public.is_admin(auth.uid()));

create policy "Device tokens all" on public.device_tokens
  for all using (user_id = auth.uid());

-- ==============================================================================
-- 14. Support Tickets & SOS Contacts
-- ==============================================================================
create policy "Support tickets select" on public.support_tickets
  for select using (user_id = auth.uid() or assigned_to = auth.uid() or public.is_admin(auth.uid()));

create policy "Support tickets insert" on public.support_tickets
  for insert with check (user_id = auth.uid());

create policy "Support tickets update" on public.support_tickets
  for update using (user_id = auth.uid() or assigned_to = auth.uid() or public.is_admin(auth.uid()));

create policy "SOS contacts all" on public.sos_contacts
  for all using (user_id = auth.uid());

-- ==============================================================================
-- 15. Audit Logs & Idempotency Keys
-- ==============================================================================
create policy "Audit logs admin select" on public.audit_logs
  for select using (public.is_admin(auth.uid()));

create policy "Idempotency keys all" on public.api_idempotency_keys
  for all using (user_id = auth.uid() or public.is_admin(auth.uid()));
