-- ==============================================================================
-- PROJECT X: DATABASE SETUP SCRIPT (SERVICES & PROFILES ONLY)
-- Paste and Run this in your Supabase Dashboard:
-- https://supabase.com/dashboard/project/pyjuquwuyijcyadcnjxc/sql/new
-- ==============================================================================

-- 1. Enable UUID Extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==============================================================================
-- 2. PROFILES TABLE & POLICIES
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name TEXT NOT NULL DEFAULT 'User',
    phone_number TEXT UNIQUE,
    email TEXT,
    avatar_url TEXT,
    location TEXT DEFAULT 'Indiranagar, Bengaluru',
    bio TEXT,
    is_provider BOOLEAN NOT NULL DEFAULT FALSE,
    rating DECIMAL(3, 2) DEFAULT 5.00,
    kyc_status TEXT DEFAULT 'verified',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public profiles are viewable" ON public.profiles;
DROP POLICY IF EXISTS "Allow select profiles" ON public.profiles;
CREATE POLICY "Allow select profiles" ON public.profiles FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
DROP POLICY IF EXISTS "Allow insert profiles" ON public.profiles;
CREATE POLICY "Allow insert profiles" ON public.profiles FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Allow update profiles" ON public.profiles;
CREATE POLICY "Allow update profiles" ON public.profiles FOR UPDATE USING (true);


-- ==============================================================================
-- 3. SERVICES TABLE & POLICIES (Fixes RLS Code 42501)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_id UUID,
    title TEXT NOT NULL,
    category TEXT NOT NULL,
    subtitle TEXT,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL DEFAULT 199.00,
    price_unit VARCHAR(20) NOT NULL DEFAULT '/visit',
    rating DECIMAL(3, 2) DEFAULT 4.90,
    review_count INT DEFAULT 0,
    experience_years INT DEFAULT 3,
    avg_eta VARCHAR(50) DEFAULT '15-20 mins',
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    sub_categories TEXT[] DEFAULT '{}',
    location_area TEXT DEFAULT 'Indiranagar, Bengaluru',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ensure provider_id is optional so client-side inserts never fail foreign-key checks
ALTER TABLE public.services ALTER COLUMN provider_id DROP NOT NULL;

ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public services are viewable" ON public.services;
DROP POLICY IF EXISTS "Allow select services" ON public.services;
CREATE POLICY "Allow select services" ON public.services FOR SELECT USING (true);

DROP POLICY IF EXISTS "Providers can insert own services" ON public.services;
DROP POLICY IF EXISTS "Allow insert services" ON public.services;
CREATE POLICY "Allow insert services" ON public.services FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Providers can update own services" ON public.services;
DROP POLICY IF EXISTS "Allow update services" ON public.services;
CREATE POLICY "Allow update services" ON public.services FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Providers can delete own services" ON public.services;
DROP POLICY IF EXISTS "Allow delete services" ON public.services;
CREATE POLICY "Allow delete services" ON public.services FOR DELETE USING (true);


-- ==============================================================================
-- 4. SEED INITIAL SERVICES (Plumber, Electrician, Cleaning, etc.)
-- ==============================================================================
INSERT INTO public.services (title, category, subtitle, description, price, price_unit, rating, review_count, avg_eta, sub_categories)
VALUES 
    (
        'Plumber',
        'plumbing',
        'Water Leakage, Tap Fitting & Drain Unclogging',
        'Expert plumbing services for pipe leaks, bathroom fitting installations, drain unclogging, water tank cleaning, and hydro-jet drain flushing.',
        199.00,
        '/visit',
        4.90,
        710,
        '15-20 mins',
        ARRAY['Tap & Mixer Leakage', 'Drain & Pipe Unclogging', 'Toilet & Cistern', 'Water Tank & Pump']
    ),
    (
        'Electrician',
        'electrical',
        'Electrical Wiring, Switches & Appliance Repairs',
        'Professional electrical repairs, circuit breaker troubleshooting, ceiling fan installations, smart light fittings, and complete home wiring inspection.',
        149.00,
        '/visit',
        4.80,
        840,
        '15 mins',
        ARRAY['Switches & Sockets', 'Fan Installation', 'MCB & Fuse Repair', 'Chandelier & Lights']
    ),
    (
        'House Cleaning',
        'cleaning',
        'Kitchen, Bathroom & Full House Deep Cleaning',
        'Deep sanitization and intense cleaning for kitchen counters, appliance degreasing, bathroom tile scrubbing, living room dusting, and carpet shampooing.',
        399.00,
        '/visit',
        4.90,
        620,
        '30 mins',
        ARRAY['Full Home Deep Clean', 'Kitchen Scrubbing', 'Bathroom Deep Clean', 'Sofa & Carpet']
    ),
    (
        'Carpenter',
        'carpentry',
        'Furniture repair, locks & woodwork',
        'Skilled carpenters for furniture assembly, door alignment, lock repair, custom shelving, and wooden floor touchups. Precision tools and clean finish.',
        299.00,
        '/visit',
        4.90,
        340,
        '30 mins',
        ARRAY['Furniture Assembly', 'Door & Lock Repair', 'Cabinet & Drawer', 'Wood Polishing']
    ),
    (
        'Driver on Demand',
        'driver',
        'Personal & outstation drivers on hourly basis',
        'Professional, uniform-clad drivers with background verification and defensive driving certificates. Available for hourly city drives, luxury cars, or outstation trips.',
        149.00,
        '/hr',
        4.90,
        910,
        '15 mins',
        ARRAY['City Hourly Drive', 'Outstation Trip', 'Night Driver', 'Luxury Car Specialist']
    ),
    (
        'Appliance Repair',
        'appliance',
        'AC Service, Refrigerator & Washing Machine',
        'Certified technicians for AC gas refilling, washing machine drum repair, refrigerator cooling diagnostics, and microwave servicing.',
        249.00,
        '/visit',
        4.80,
        590,
        '45 mins',
        ARRAY['AC Service & Gas', 'Washing Machine', 'Refrigerator', 'Microwave & Oven']
    )
ON CONFLICT DO NOTHING;
