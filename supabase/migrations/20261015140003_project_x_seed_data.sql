-- ==============================================================================
-- PROJECT X: BENGALURU ON-DEMAND SERVICES SEED DATA
-- Populates active categories, services, and variants with accurate pricing
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
  srv_toilet uuid;

  srv_switchboard uuid;
  srv_fan uuid;
  srv_mcb uuid;

  srv_home_clean uuid;
  srv_bath_clean uuid;
  srv_kitchen_clean uuid;

  srv_ac uuid;
  srv_washing uuid;
  srv_fridge uuid;
begin
  -- 1. Insert Service Categories
  insert into public.service_categories (slug, name, description, sort_order, is_active)
  values 
    ('plumbing', 'Plumbing', 'Tap fittings, water leaks, pipelines, tanks & drain unblocking', 1, true)
  on conflict (slug) do update set name = excluded.name, description = excluded.description
  returning id into cat_plumbing;

  insert into public.service_categories (slug, name, description, sort_order, is_active)
  values 
    ('electrician', 'Electrician', 'Switchboard, wiring, fans, chandeliers, MCB & power troubleshooting', 2, true)
  on conflict (slug) do update set name = excluded.name, description = excluded.description
  returning id into cat_electrician;

  insert into public.service_categories (slug, name, description, sort_order, is_active)
  values 
    ('cleaning', 'Cleaning & Sanitization', 'Full apartment deep cleaning, bathroom descaling, kitchen & sofa', 3, true)
  on conflict (slug) do update set name = excluded.name, description = excluded.description
  returning id into cat_cleaning;

  insert into public.service_categories (slug, name, description, sort_order, is_active)
  values 
    ('appliance', 'Appliance Repair', 'AC power saver foam cleaning, gas top-up, washing machine & fridge', 4, true)
  on conflict (slug) do update set name = excluded.name, description = excluded.description
  returning id into cat_appliance;

  insert into public.service_categories (slug, name, description, sort_order, is_active)
  values 
    ('carpentry', 'Carpentry & Furniture', 'Door locks, hinges, curtain rods, drilling & furniture assembly', 5, true)
  on conflict (slug) do update set name = excluded.name, description = excluded.description
  returning id into cat_carpentry;

  insert into public.service_categories (slug, name, description, sort_order, is_active)
  values 
    ('painting', 'Painting & Waterproofing', 'Single wall texture, interior touchup, waterproofing & full home', 6, true)
  on conflict (slug) do update set name = excluded.name, description = excluded.description
  returning id into cat_painting;

  -- 2. Insert Services (Plumbing)
  insert into public.services (category_id, slug, name, title, category, short_description, description, price, price_unit, sub_categories, is_active)
  values 
    (cat_plumbing, 'plumbing-tap-mixer', 'Tap & Faucet Installation', 'Plumber', 'plumbing', 'Water Leakage, Tap Fitting & Drain Unclogging', 'Expert plumbing services for pipe leaks, tap replacement, bathroom fitting installations.', 99.00, '/visit', array['Tap Repair','Mixer Fitting','Washer Replacement'], true)
  on conflict (slug) do update set name = excluded.name
  returning id into srv_tap;

  insert into public.services (category_id, slug, name, title, category, short_description, description, price, price_unit, sub_categories, is_active)
  values 
    (cat_plumbing, 'plumbing-sink-unclog', 'Washbasin & Sink Repair', 'Sink Specialist', 'plumbing', 'Sink pipe unclogging and bottle trap replacement', 'Clears kitchen sink blockage and installs waste coupling and PVC pipes.', 249.00, '/job', array['Sink Unclogging','Bottle Trap Repair'], true)
  on conflict (slug) do update set name = excluded.name
  returning id into srv_sink;

  insert into public.services (category_id, slug, name, title, category, short_description, description, price, price_unit, sub_categories, is_active)
  values 
    (cat_plumbing, 'plumbing-water-tank', 'Overhead Water Tank Cleaning', 'Water Tank Pro', 'plumbing', 'Hygienic mechanized sludge removal & UV sanitization', 'Complete deep disinfection of overhead Sintex or concrete water tanks up to 1000L.', 799.00, '/tank', array['Mechanized Sludge Extraction','UV Antibacterial Rinse'], true)
  on conflict (slug) do update set name = excluded.name
  returning id into srv_tank;

  -- 3. Insert Services (Electrician)
  insert into public.services (category_id, slug, name, title, category, short_description, description, price, price_unit, sub_categories, is_active)
  values 
    (cat_electrician, 'elec-switchboard', 'Switchboard & Socket Installation', 'Electrician', 'electrician', 'Modular switch repair, socket replacement & wiring', 'Certified electrical technicians for safe switches, 16A AC sockets and earthing inspection.', 149.00, '/visit', array['Modular Switch Replacement','16A Power Socket Installation'], true)
  on conflict (slug) do update set name = excluded.name
  returning id into srv_switchboard;

  insert into public.services (category_id, slug, name, title, category, short_description, description, price, price_unit, sub_categories, is_active)
  values 
    (cat_electrician, 'elec-fan', 'Ceiling Fan Installation & Repair', 'Fan Technician', 'electrician', 'Regulator replacement, blade balancing & new fan mounting', 'Fast fan installation with heavy-duty anchor fasteners and silent operation balancing.', 199.00, '/fan', array['Ceiling Fan Fitting','Capacitor & Regulator Check'], true)
  on conflict (slug) do update set name = excluded.name
  returning id into srv_fan;

  insert into public.services (category_id, slug, name, title, category, short_description, description, price, price_unit, sub_categories, is_active)
  values 
    (cat_electrician, 'elec-mcb', 'MCB Tripping & Fuse Box Repair', 'Power Specialist', 'electrician', 'Short-circuit detection and distribution board repair', 'Isolates burnt wires, balances phase load and replaces malfunctioning double-pole MCBs.', 299.00, '/job', array['MCB Diagnosis','Distribution Board Rewiring'], true)
  on conflict (slug) do update set name = excluded.name
  returning id into srv_mcb;

  -- 4. Insert Services (Cleaning)
  insert into public.services (category_id, slug, name, title, category, short_description, description, price, price_unit, sub_categories, is_active)
  values 
    (cat_cleaning, 'clean-full-home', 'Full Home Deep Cleaning', 'House Cleaning', 'cleaning', 'Intensive mechanized scrubbing, balcony, kitchen and bathroom', 'Complete sanitization with industrial vacuuming, degreasing, and floor scrubbing machines.', 1499.00, '/flat', array['1 BHK Cleaning','2 BHK Cleaning','Balcony Jet Spray'], true)
  on conflict (slug) do update set name = excluded.name
  returning id into srv_home_clean;

  insert into public.services (category_id, slug, name, title, category, short_description, description, price, price_unit, sub_categories, is_active)
  values 
    (cat_cleaning, 'clean-bathroom', 'Bathroom Tile & Tap Descaling', 'Bathroom Pro', 'cleaning', 'Hard water stain removal, WC disinfection & mirror buffing', 'Removes 100% limescale, hard water stains from tiles, fixtures, taps and showerheads.', 399.00, '/bathroom', array['Hard Water Stain Treatment','Grout Buffing'], true)
  on conflict (slug) do update set name = excluded.name
  returning id into srv_bath_clean;

  -- 5. Insert Services (Appliance)
  insert into public.services (category_id, slug, name, title, category, short_description, description, price, price_unit, sub_categories, is_active)
  values 
    (cat_appliance, 'app-ac-service', 'Split AC Deep Foam Jet Service', 'AC Technician', 'appliance', 'Power jet cleaning, cooling coil foam bath, gas pressure check', 'Increases cooling efficiency up to 2.5x and cuts electricity bills with non-toxic foam jet wash.', 499.00, '/unit', array['Indoor Unit Foam Jet Wash','Outdoor Condenser Pressure Clean'], true)
  on conflict (slug) do update set name = excluded.name
  returning id into srv_ac;

  insert into public.services (category_id, slug, name, title, category, short_description, description, price, price_unit, sub_categories, is_active)
  values 
    (cat_appliance, 'app-washing-machine', 'Washing Machine Inspection & Repair', 'Appliance Pro', 'appliance', 'Drum vibration, drainage pump, error codes & motor check', 'Comprehensive diagnosis for front-load, top-load, and semi-automatic washing machines.', 249.00, '/visit', array['Drum Spin Fix','Water Inlet & Drain Repair'], true)
  on conflict (slug) do update set name = excluded.name
  returning id into srv_washing;

  -- 6. Insert Service Variants (Immutable Pricing in Paise: 1 INR = 100 Paise)
  -- Plumbing Variants
  insert into public.service_variants (service_id, sku, name, description, base_price_paise, estimated_duration_minutes, tax_rate_bps, unit_label, is_active)
  values
    (srv_tap, 'VAR-TAP-SINGLE', 'Single Tap / Spindle Replacement', 'Fix continuous dripping or replace brass spindle', 9900, 20, 500, 'tap', true),
    (srv_tap, 'VAR-TAP-MIXER', 'Wall Mixer / Diverter Fitting', 'Complete replacement of hot & cold bath mixer unit', 24900, 45, 500, 'unit', true),
    (srv_sink, 'VAR-SINK-UNCLOG', 'Sink Waste Coupling & Trap Clearance', 'Mechanical snake clean of bottle trap and outlet pipe', 19900, 30, 500, 'sink', true),
    (srv_tank, 'VAR-TANK-1000L', 'Overhead Tank Cleaning (Up to 1000L)', 'Mechanized suction, high-pressure jet wash and potassium wash', 79900, 60, 1800, 'tank', true)
  on conflict (sku) do update set base_price_paise = excluded.base_price_paise;

  -- Electrician Variants
  insert into public.service_variants (service_id, sku, name, description, base_price_paise, estimated_duration_minutes, tax_rate_bps, unit_label, is_active)
  values
    (srv_switchboard, 'VAR-ELEC-SWITCH', 'Modular Switch / 6A Socket Replacement', 'Includes testing with digital multimeter and safe earthing', 7900, 15, 500, 'switch', true),
    (srv_switchboard, 'VAR-ELEC-BOARD', 'Complete 8-Modular Board Installation', 'New box fitting, concealed cutting and wiring terminations', 29900, 45, 500, 'board', true),
    (srv_fan, 'VAR-FAN-INSTALL', 'Ceiling Fan Installation with Fasteners', 'Assembling downrod, balancing blades and ceiling hook fastening', 14900, 25, 500, 'fan', true),
    (srv_mcb, 'VAR-MCB-REPAIR', 'Double Pole MCB / Isolator Replacement', 'Resolves recurrent tripping and neutral leakage currents', 29900, 40, 500, 'mcb', true)
  on conflict (sku) do update set base_price_paise = excluded.base_price_paise;

  -- Cleaning Variants
  insert into public.service_variants (service_id, sku, name, description, base_price_paise, estimated_duration_minutes, tax_rate_bps, unit_label, is_active)
  values
    (srv_home_clean, 'VAR-CLEAN-1BHK', '1 BHK Full Home Deep Cleaning', 'Bedrooms, living room, windows, balcony, kitchen and 1 bath', 149900, 180, 1800, 'flat', true),
    (srv_home_clean, 'VAR-CLEAN-2BHK', '2 BHK Full Home Deep Cleaning', 'Complete apartment deep cleaning with high-rpm floor scrubbers', 219900, 240, 1800, 'flat', true),
    (srv_bath_clean, 'VAR-CLEAN-BATH', 'Single Bathroom Hard Water Descaling', 'Intense acid-free descaling of tiles, commode, taps & glass', 39900, 45, 1800, 'bathroom', true)
  on conflict (sku) do update set base_price_paise = excluded.base_price_paise;

  -- Appliance Variants
  insert into public.service_variants (service_id, sku, name, description, base_price_paise, estimated_duration_minutes, tax_rate_bps, unit_label, is_active)
  values
    (srv_ac, 'VAR-AC-FOAM-JET', 'Split AC Foam Jet Power Wash', 'Deep cleaning with indoor AC jacket, foam spray and fin comb', 49900, 45, 1800, 'unit', true),
    (srv_washing, 'VAR-WASH-INSPECT', 'Washing Machine Diagnostic Checkup', 'Diagnose motor, drain pump, drum bearings and PCB controller', 24900, 30, 500, 'unit', true)
  on conflict (sku) do update set base_price_paise = excluded.base_price_paise;

end $$;
