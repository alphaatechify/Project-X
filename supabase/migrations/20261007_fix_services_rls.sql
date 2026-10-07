-- ==============================================================================
-- FIX FOR SERVICES TABLE (RLS & INITIAL SERVICES SEEDING)
-- Run this in Supabase Dashboard -> SQL Editor
-- ==============================================================================

-- 1. Make provider_id optional so platform services can exist without a personal user
ALTER TABLE public.services ALTER COLUMN provider_id DROP NOT NULL;

-- 2. Update RLS policies to allow reading and writing
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Services are viewable by all users" ON public.services;
DROP POLICY IF EXISTS "Allow select services" ON public.services;
CREATE POLICY "Allow select services" ON public.services FOR SELECT USING (true);

DROP POLICY IF EXISTS "Providers can insert their own services" ON public.services;
DROP POLICY IF EXISTS "Allow insert services" ON public.services;
CREATE POLICY "Allow insert services" ON public.services FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Providers can update their own services" ON public.services;
DROP POLICY IF EXISTS "Allow update services" ON public.services;
CREATE POLICY "Allow update services" ON public.services FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Providers can delete their own services" ON public.services;
DROP POLICY IF EXISTS "Allow delete services" ON public.services;
CREATE POLICY "Allow delete services" ON public.services FOR DELETE USING (true);

-- 3. Seed Core Services (Plumber, Electrician, Cleaning, Carpenter, Driver, etc.)
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
    );
