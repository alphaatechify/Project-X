-- ==============================================================================
-- PROJECT X (KINETIC VOLT) - SUPABASE ON-DEMAND SERVICES BACKEND SCHEMA
-- Tables:
--   1. public.profiles (Linked to auth.users)
--   2. public.services (Connected to public.profiles via provider_id)
-- ==============================================================================

-- 1. Enable UUID Extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==============================================================================
-- 1. PROFILES TABLE (Customers & Providers)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL DEFAULT 'User',
    phone_number TEXT UNIQUE,
    email TEXT,
    avatar_url TEXT,
    location TEXT DEFAULT 'Indiranagar, Bengaluru',
    bio TEXT,
    is_provider BOOLEAN NOT NULL DEFAULT FALSE,
    rating DECIMAL(3, 2) DEFAULT 5.00,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Profiles Policies
CREATE POLICY "Public profiles are viewable by everyone"
    ON public.profiles FOR SELECT
    USING (true);

CREATE POLICY "Users can insert their own profile"
    ON public.profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

-- ==============================================================================
-- 2. SERVICES TABLE (Plumber, Electrician, Cleaning, Carpenter, Driver, etc.)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,                      -- e.g. 'Plumber', 'Electrician', 'House Cleaning'
    category TEXT NOT NULL,                   -- e.g. 'plumbing', 'electrical', 'cleaning', 'carpentry', 'driver'
    subtitle TEXT,                            -- e.g. 'Pipe Leakage, Tap & Sanitary Repair'
    description TEXT,                         -- Detailed description of service
    price DECIMAL(10, 2) NOT NULL DEFAULT 399.00,
    price_unit VARCHAR(20) NOT NULL DEFAULT '/hr', -- '/hr', '/day', '/visit'
    rating DECIMAL(3, 2) DEFAULT 4.90,
    review_count INT DEFAULT 0,
    experience_years INT DEFAULT 3,
    avg_eta VARCHAR(50) DEFAULT '15-30 mins',
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    sub_categories TEXT[] DEFAULT '{}',       -- ['Tap Repair', 'Drain Cleaning', 'Water Tank']
    location_area TEXT DEFAULT 'Indiranagar, Bengaluru',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for lightning fast searches
CREATE INDEX IF NOT EXISTS idx_services_provider_id ON public.services(provider_id);
CREATE INDEX IF NOT EXISTS idx_services_category ON public.services(category);
CREATE INDEX IF NOT EXISTS idx_services_is_available ON public.services(is_available);

-- Enable RLS on services
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;

-- Services Policies
CREATE POLICY "Services are viewable by all users"
    ON public.services FOR SELECT
    USING (true);

CREATE POLICY "Providers can insert their own services"
    ON public.services FOR INSERT
    WITH CHECK (auth.uid() = provider_id);

CREATE POLICY "Providers can update their own services"
    ON public.services FOR UPDATE
    USING (auth.uid() = provider_id);

CREATE POLICY "Providers can delete their own services"
    ON public.services FOR DELETE
    USING (auth.uid() = provider_id);

-- ==============================================================================
-- 3. AUTOMATIC PROFILE CREATION TRIGGER (ON SIGNUP)
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user_profile()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO public.profiles (
        id,
        full_name,
        phone_number,
        email,
        avatar_url,
        is_provider
    )
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'Customer'),
        COALESCE(NEW.phone, NEW.raw_user_meta_data->>'phone'),
        NEW.email,
        NEW.raw_user_meta_data->>'avatar_url',
        COALESCE((NEW.raw_user_meta_data->>'is_provider')::BOOLEAN, FALSE)
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_profile();
