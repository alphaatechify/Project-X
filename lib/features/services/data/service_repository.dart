import 'package:flutter/material.dart';
import '../domain/models/provider_model.dart';
import '../domain/models/service_model.dart';

class ServiceRepository {
  static final List<ServiceModel> allServices = [
    // 1. 🔧 Plumbing
    ServiceModel(
      id: 'plumbing',
      title: 'Plumbing',
      categoryName: 'Plumbing & Pipe Infrastructure',
      subtitle: 'Leaks, blockages, fittings & installations',
      fullDescription:
          'Expert plumbing services covering tap & fixture installations, pipeline leak detection, drain unclogging, water tank repair, and sanitary replacements.',
      icon: Icons.plumbing_rounded,
      themeColor: const Color(0xFF0284C7),
      themeBgColor: const Color(0xFFF0F9FF),
      cardIconBgColor: const Color(0xFFBAE6FD),
      tag: 'POPULAR',
      tagBgColor: const Color(0xFFE0F2FE),
      tagTextColor: const Color(0xFF0369A1),
      ctaText: 'BOOK PLUMBER',
      rating: 4.9,
      totalReviews: '7.8k reviews',
      startingPrice: '₹199',
      subCategories: [
        'All',
        'Plumbing Installation',
        'Plumbing Repair',
        'Water Leakage Repair',
        'Drain & Toilet Blockage Removal',
        'Plumbing Replacement',
      ],
      subServices: [
        SubServiceItem(
          title: 'Plumbing Installation',
          description: 'Installation of taps, sinks, toilets, showers, pipelines, fittings, fixtures, and other plumbing systems.',
        ),
        SubServiceItem(
          title: 'Plumbing Repair',
          description: 'Repair of taps, toilets, pipes, fittings, pumps, valves, and other plumbing issues.',
        ),
        SubServiceItem(
          title: 'Water Leakage Repair',
          description: 'Detection and repair of leaks in pipes, taps, bathrooms, kitchens, water tanks, and pipelines.',
        ),
        SubServiceItem(
          title: 'Drain & Toilet Blockage Removal',
          description: 'Removal of blockages from sinks, toilets, bathrooms, kitchens, drains, and sewer lines.',
        ),
        SubServiceItem(
          title: 'Plumbing Replacement',
          description: 'Replacement of taps, faucets, pipes, valves, toilet fittings, fixtures, and other plumbing components.',
        ),
      ],
      highlights: [
        'Thermal Camera Leak Detection',
        '30-Day Service Warranty',
        'Clean & Mess-Free Post-Work Finish',
      ],
      bannerNotice: '💧 Rapid response plumber available in Indiranagar within 20 mins.',
      avgEta: '15-20 mins',
      imageAsset: 'assets/images/plumbing_service.jpg',
      imageAlignment: const Alignment(0.0, -0.4),
    ),

    // 2. ⚡ Electrician
    ServiceModel(
      id: 'electrician',
      title: 'Electrician',
      categoryName: 'Electrical Fixes & Wiring',
      subtitle: 'Wiring, fixtures, appliances & fault repair',
      fullDescription:
          'Certified electrical technicians for switches, lights, fans, appliances, circuit breaker troubleshooting, complete rewiring, and power fault fixes.',
      icon: Icons.bolt_rounded,
      themeColor: const Color(0xFFD97706),
      themeBgColor: const Color(0xFFFFFBEB),
      cardIconBgColor: const Color(0xFFFEF08A),
      tag: '⚡ 15 MIN',
      tagBgColor: const Color(0xFFFEF08A),
      tagTextColor: const Color(0xFF854D0E),
      ctaText: 'BOOK ELECTRICIAN',
      rating: 4.8,
      totalReviews: '9.2k reviews',
      startingPrice: '₹149',
      subCategories: [
        'All',
        'Electrical Installation',
        'Electrical Repair',
        'Wiring & Rewiring',
        'Fan & Light Services',
        'Power & Electrical Fault Repair',
      ],
      subServices: [
        SubServiceItem(
          title: 'Electrical Installation',
          description: 'Installation of switches, sockets, lights, fans, appliances, wiring, and electrical fixtures.',
        ),
        SubServiceItem(
          title: 'Electrical Repair',
          description: 'Repair of switches, sockets, fans, lights, appliances, wiring, and other electrical components.',
        ),
        SubServiceItem(
          title: 'Wiring & Rewiring',
          description: 'New wiring, old wiring replacement, damaged wiring repair, and electrical rewiring.',
        ),
        SubServiceItem(
          title: 'Fan & Light Services',
          description: 'Installation, repair, replacement, and maintenance of ceiling fans, exhaust fans, lights, and fixtures.',
        ),
        SubServiceItem(
          title: 'Power & Electrical Fault Repair',
          description: 'Troubleshooting of MCBs, fuses, power failures, short circuits, voltage issues, and other electrical faults.',
        ),
      ],
      highlights: [
        'Licensed & Background-Checked Electricians',
        'Safety-Insulated Diagnostic Tools',
        'Standard Transparent Rate Card',
      ],
      bannerNotice: '⚡ 15-min instant arrival guaranteed for emergency power cut faults.',
      avgEta: '15 mins',
      imageAsset: 'assets/images/electrician_service.jpg',
      imageAlignment: const Alignment(0.1, -0.3),
    ),

    // 3. 🧹 Housekeeping
    ServiceModel(
      id: 'housekeeping',
      title: 'Housekeeping',
      categoryName: 'Home Hygiene & Sanitation',
      subtitle: 'Home, deep, kitchen, bathroom & upholstery cleaning',
      fullDescription:
          'Intensive home sanitization and cleaning for rooms, floors, kitchen countertops, bathroom tiles, sofas, carpets, and hard-to-reach surfaces.',
      icon: Icons.cleaning_services_rounded,
      themeColor: const Color(0xFF059669),
      themeBgColor: const Color(0xFFECFDF5),
      cardIconBgColor: const Color(0xFFA7F3D0),
      tag: 'TOP RATED',
      tagBgColor: const Color(0xFFECFDF5),
      tagTextColor: const Color(0xFF065F46),
      ctaText: 'BOOK CLEANING',
      rating: 4.9,
      totalReviews: '8.4k reviews',
      startingPrice: '₹399',
      subCategories: [
        'All',
        'Home Cleaning',
        'Deep Cleaning',
        'Bathroom Cleaning',
        'Kitchen Cleaning',
        'Sofa & Carpet Cleaning',
      ],
      subServices: [
        SubServiceItem(
          title: 'Home Cleaning',
          description: 'Regular and complete cleaning of rooms, floors, furniture, and household surfaces.',
        ),
        SubServiceItem(
          title: 'Deep Cleaning',
          description: 'Detailed cleaning of the entire home, including hard-to-reach areas and high-touch surfaces.',
        ),
        SubServiceItem(
          title: 'Bathroom Cleaning',
          description: 'Cleaning of toilets, tiles, showers, wash basins, floors, fittings, and other bathroom surfaces.',
        ),
        SubServiceItem(
          title: 'Kitchen Cleaning',
          description: 'Cleaning of countertops, cabinets, appliances, floors, sinks, and chimney areas.',
        ),
        SubServiceItem(
          title: 'Sofa & Carpet Cleaning',
          description: 'Professional cleaning of sofas, carpets, mattresses, curtains, and other upholstery.',
        ),
      ],
      highlights: [
        '100% Eco-Safe Non-Toxic Detergents',
        'Heavy-Duty Industrial Vacuum Machines',
        '30-Day Reservice Satisfaction Guarantee',
      ],
      bannerNotice: '✨ Complimentary kitchen degreasing included with full deep cleaning bookings!',
      avgEta: '30 mins',
      imageAsset: 'assets/images/housekeeping_service.jpg',
      imageAlignment: const Alignment(0.0, -0.85),
    ),

    // 4. 🎨 Painter
    ServiceModel(
      id: 'painter',
      title: 'Painter',
      categoryName: 'Wall Decor & Painting',
      subtitle: 'Interior, exterior, texture & touch-up painting',
      fullDescription:
          'Complete painting and wall preparation services: interior rooms, exterior weather coats, crack repair, putty finish, decorative textures, and quick touch-ups.',
      icon: Icons.format_paint_rounded,
      themeColor: const Color(0xFF7C3AED),
      themeBgColor: const Color(0xFFF5F3FF),
      cardIconBgColor: const Color(0xFFDDD6FE),
      tag: 'WARRANTY',
      tagBgColor: const Color(0xFFF5F3FF),
      tagTextColor: const Color(0xFF6D28D9),
      ctaText: 'GET ESTIMATE',
      rating: 4.8,
      totalReviews: '4.2k reviews',
      startingPrice: '₹499',
      subCategories: [
        'All',
        'Interior Painting',
        'Exterior Painting',
        'Wall Repair & Painting',
        'Texture & Decorative Painting',
        'Repainting & Touch-Up',
      ],
      subServices: [
        SubServiceItem(
          title: 'Interior Painting',
          description: 'Painting of walls, ceilings, rooms, doors, and other interior surfaces.',
        ),
        SubServiceItem(
          title: 'Exterior Painting',
          description: 'Painting of exterior walls, balconies, terraces, gates, and other outdoor surfaces.',
        ),
        SubServiceItem(
          title: 'Wall Repair & Painting',
          description: 'Repair of cracks, holes, peeling paint, damp patches, putty work, and surface preparation.',
        ),
        SubServiceItem(
          title: 'Texture & Decorative Painting',
          description: 'Decorative textures, patterns, accent walls, designer finishes, and specialty painting.',
        ),
        SubServiceItem(
          title: 'Repainting & Touch-Up',
          description: 'Refreshing old paint, repairing damaged areas, covering patches, and completing touch-up work.',
        ),
      ],
      highlights: [
        'Laser Wall Area Measurement',
        'Dustless Mechanical Sanding',
        '1-Year Anti-Fungal Peeling Warranty',
      ],
      bannerNotice: '🎨 Free color consult & 3D visualizer preview with every estimate.',
      avgEta: 'Same Day Consult',
      imageAsset: 'assets/images/painter_service.jpg',
      imageAlignment: const Alignment(0.1, -0.7),
    ),

    // 5. 🏋️ Health Coach
    ServiceModel(
      id: 'health_coach',
      title: 'Health Coach',
      categoryName: 'Fitness & Lifestyle Coaching',
      subtitle: 'Workouts, weight management, diet & wellness',
      fullDescription:
          'Dedicated personal wellness coaches providing customized exercise plans, weight loss/gain regimes, tailored nutrition guidance, sleep coaching, and healthy lifestyle habits.',
      icon: Icons.fitness_center_rounded,
      themeColor: const Color(0xFFE11D48),
      themeBgColor: const Color(0xFFFFF1F2),
      cardIconBgColor: const Color(0xFFFECDD3),
      tag: 'WELLNESS',
      tagBgColor: const Color(0xFFFFF1F2),
      tagTextColor: const Color(0xFFBE123C),
      ctaText: 'BOOK COACH',
      rating: 4.9,
      totalReviews: '3.6k reviews',
      startingPrice: '₹599',
      subCategories: [
        'All',
        'Fitness & Exercise Coaching',
        'Weight Management Coaching',
        'Nutrition & Diet Coaching',
        'Lifestyle & Habit Coaching',
        'Personal Wellness Coaching',
      ],
      subServices: [
        SubServiceItem(
          title: 'Fitness & Exercise Coaching',
          description: 'Personalized workout plans, strength training, mobility, flexibility, and general fitness guidance.',
        ),
        SubServiceItem(
          title: 'Weight Management Coaching',
          description: 'Healthy weight-loss and weight-gain guidance with sustainable lifestyle support.',
        ),
        SubServiceItem(
          title: 'Nutrition & Diet Coaching',
          description: 'Personalized nutrition guidance, healthy meal planning, and eating-habit support.',
        ),
        SubServiceItem(
          title: 'Lifestyle & Habit Coaching',
          description: 'Support with sleep, routines, stress management, productivity, and healthy habit development.',
        ),
        SubServiceItem(
          title: 'Personal Wellness Coaching',
          description: 'Wellness goal setting, accountability, progress tracking, and overall lifestyle improvement.',
        ),
      ],
      highlights: [
        'Certified Fitness & Nutrition Specialists',
        'Customized Daily Routine Blueprints',
        'Weekly 1-on-1 Accountability Check-Ins',
      ],
      bannerNotice: '🏋️ Start your personal transformation with an expert coach today.',
      avgEta: 'Online / In-Person',
      imageAsset: 'assets/images/health_coach_service.jpg',
      imageAlignment: Alignment.center,
    ),

    // 6. 🔌 Home Appliances
    ServiceModel(
      id: 'home_appliances',
      title: 'Home Appliances',
      categoryName: 'Appliance Repair & Servicing',
      subtitle: 'Refrigerator, washing machine, AC, microwave & TV',
      fullDescription:
          'Comprehensive repair and maintenance for essential home electronics: AC gas servicing, washing machine drum repair, refrigerator diagnostics, microwave fixes, and TV repairs.',
      icon: Icons.kitchen_rounded,
      themeColor: const Color(0xFF4F46E5),
      themeBgColor: const Color(0xFFEEF2FF),
      cardIconBgColor: const Color(0xFFC7D2FE),
      tag: '4.8 ★',
      tagBgColor: const Color(0xFFEEF2FF),
      tagTextColor: const Color(0xFF3730A3),
      ctaText: 'INSPECT & FIX',
      rating: 4.8,
      totalReviews: '6.7k reviews',
      startingPrice: '₹249',
      subCategories: [
        'All',
        'Refrigerator Repair & Service',
        'Washing Machine Repair & Service',
        'AC Repair & Service',
        'Microwave Oven Repair & Service',
        'TV Repair & Service',
      ],
      subServices: [
        SubServiceItem(
          title: 'Refrigerator Repair & Service',
          description: 'Inspection, troubleshooting, repair, maintenance, and component replacement.',
        ),
        SubServiceItem(
          title: 'Washing Machine Repair & Service',
          description: 'Diagnosis, repair, maintenance, installation, and parts replacement.',
        ),
        SubServiceItem(
          title: 'AC Repair & Service',
          description: 'AC inspection, repair, servicing, installation, maintenance, and gas-related services.',
        ),
        SubServiceItem(
          title: 'Microwave Oven Repair & Service',
          description: 'Troubleshooting, repair, maintenance, and component replacement.',
        ),
        SubServiceItem(
          title: 'TV Repair & Service',
          description: 'Diagnosis and repair of display, power, sound, connectivity, and other TV issues.',
        ),
      ],
      highlights: [
        '100% Genuine OEM Spares Guaranteed',
        '90-Day Parts Replacement Warranty',
        'Upfront Flat-Rate Repair Quotes',
      ],
      bannerNotice: '❄️ AC servicing includes complimentary jet washing and gas level check.',
      avgEta: '30-45 mins',
      imageAsset: 'assets/images/home_appliances_service.jpg',
      imageAlignment: const Alignment(0.0, -1.0),
    ),

    // 7. 💻 Business & Digital Services
    ServiceModel(
      id: 'business_digital',
      title: 'Business & Digital',
      categoryName: 'Digital & Growth Services',
      subtitle: 'Marketing, video editing, website, graphics & growth',
      fullDescription:
          'End-to-end creative and digital acceleration services: social media & SEO marketing, high-converting video editing, responsive website development, and branding design.',
      icon: Icons.devices_rounded,
      themeColor: const Color(0xFF0891B2),
      themeBgColor: const Color(0xFFECFEFF),
      cardIconBgColor: const Color(0xFFA5F3FC),
      tag: 'GROWTH',
      tagBgColor: const Color(0xFFECFEFF),
      tagTextColor: const Color(0xFF0E7490),
      ctaText: 'CONSULT NOW',
      rating: 4.9,
      totalReviews: '2.9k reviews',
      startingPrice: '₹999',
      subCategories: [
        'All',
        'Digital Marketing',
        'Video Editing',
        'Website Development',
        'Graphic Design',
        'Business & Growth Services',
      ],
      subServices: [
        SubServiceItem(
          title: 'Digital Marketing',
          description: 'Social media management, online advertising, SEO, content marketing, and lead generation.',
        ),
        SubServiceItem(
          title: 'Video Editing',
          description: 'Editing of YouTube videos, reels, advertisements, promotional videos, and social media content.',
        ),
        SubServiceItem(
          title: 'Website Development',
          description: 'Website creation, redesign, e-commerce development, maintenance, and technical support.',
        ),
        SubServiceItem(
          title: 'Graphic Design',
          description: 'Logos, posters, banners, social media creatives, business materials, and branding.',
        ),
        SubServiceItem(
          title: 'Business & Growth Services',
          description: 'Business consulting, lead generation, sales support, marketing strategy, and growth planning.',
        ),
      ],
      highlights: [
        'Experienced Industry Creative Specialists',
        'Rapid Turnaround Timelines',
        'Results-Driven Growth Focus',
      ],
      bannerNotice: '🚀 Free initial brand audit & web architecture review with bookings.',
      avgEta: 'Instant Consult',
      imageAsset: 'assets/images/business_digital_service.jpg',
      imageAlignment: const Alignment(-0.25, -0.3),
    ),

    // 8. 🏗️ Construction Materials Supplier
    ServiceModel(
      id: 'construction_materials',
      title: 'Construction Supply',
      categoryName: 'Building & Construction Materials',
      subtitle: 'Cement, sand, bricks, steel & hardware supply',
      fullDescription:
          'Direct site supply of certified building materials: premium cement & RMC, aggregate stones, AAC bricks & blocks, structural TMT steel, and essential construction hardware.',
      icon: Icons.foundation_rounded,
      themeColor: const Color(0xFFEA580C),
      themeBgColor: const Color(0xFFFFF7ED),
      cardIconBgColor: const Color(0xFFFED7AA),
      tag: 'SUPPLIER',
      tagBgColor: const Color(0xFFFFF7ED),
      tagTextColor: const Color(0xFFC2410C),
      ctaText: 'ORDER SUPPLY',
      rating: 4.8,
      totalReviews: '1.8k reviews',
      startingPrice: '₹1,499',
      subCategories: [
        'All',
        'Cement & Concrete Supply',
        'Sand & Aggregate Supply',
        'Bricks & Blocks Supply',
        'Steel & TMT Supply',
        'Construction Materials Supply',
      ],
      subServices: [
        SubServiceItem(
          title: 'Cement & Concrete Supply',
          description: 'Supply of cement, ready-mix concrete, and other concrete materials.',
        ),
        SubServiceItem(
          title: 'Sand & Aggregate Supply',
          description: 'Supply of sand, gravel, stone, crushed aggregate, and other construction aggregates.',
        ),
        SubServiceItem(
          title: 'Bricks & Blocks Supply',
          description: 'Supply of bricks, AAC blocks, concrete blocks, and other masonry materials.',
        ),
        SubServiceItem(
          title: 'Steel & TMT Supply',
          description: 'Supply of TMT bars, steel rods, structural steel, and reinforcement materials.',
        ),
        SubServiceItem(
          title: 'Construction Materials Supply',
          description: 'Supply of pipes, tiles, plumbing materials, electrical materials, hardware, and other building supplies.',
        ),
      ],
      highlights: [
        'Direct-From-Mill Quality Assured',
        'Same-Day Bulk Site Vehicle Dispatch',
        'Batch Test Grade Certificates Provided',
      ],
      bannerNotice: '🏗️ Direct site truck delivery within 2-4 hours across Bengaluru.',
      avgEta: '2-4 Hours',
      imageAsset: 'assets/images/construction_materials_service.jpg',
      imageAlignment: const Alignment(0.0, -0.15),
    ),

    // 9. 🪚 Carpenter
    ServiceModel(
      id: 'carpenter',
      title: 'Carpenter',
      categoryName: 'Woodwork & Furniture Craft',
      subtitle: 'Furniture repair, assembly, custom & door woodwork',
      fullDescription:
          'Master woodworking services for furniture repairs, flatpack assembly, custom wardrobes and beds, door and window fitting, alignments, and fine wood polishing.',
      icon: Icons.handyman_rounded,
      themeColor: const Color(0xFF92400E),
      themeBgColor: const Color(0xFFFEF3C7),
      cardIconBgColor: const Color(0xFFFDE68A),
      tag: '4.9 ★',
      tagBgColor: const Color(0xFFFEF3C7),
      tagTextColor: const Color(0xFF92400E),
      ctaText: 'BOOK CARPENTER',
      rating: 4.9,
      totalReviews: '5.1k reviews',
      startingPrice: '₹299',
      subCategories: [
        'All',
        'Furniture Repair',
        'Furniture Installation & Assembly',
        'Custom Furniture Making',
        'Door & Window Services',
        'Woodwork & Carpentry',
      ],
      subServices: [
        SubServiceItem(
          title: 'Furniture Repair',
          description: 'Repair and restoration of tables, chairs, beds, wardrobes, cabinets, and other wooden furniture.',
        ),
        SubServiceItem(
          title: 'Furniture Installation & Assembly',
          description: 'Assembly and installation of wardrobes, beds, cabinets, shelves, tables, and ready-made furniture.',
        ),
        SubServiceItem(
          title: 'Custom Furniture Making',
          description: 'Customized beds, wardrobes, cabinets, tables, shelves, and other furniture according to customer requirements.',
        ),
        SubServiceItem(
          title: 'Door & Window Services',
          description: 'Repair, installation, replacement, alignment, polishing, and fitting of wooden doors and windows.',
        ),
        SubServiceItem(
          title: 'Woodwork & Carpentry',
          description: 'Partitions, shelves, wall paneling, wooden frames, fittings, and other carpentry work.',
        ),
      ],
      highlights: [
        'Precision Laser Leveling Tools',
        'Custom-Fit Dimension Specialists',
        'Post-Work Clean Sawdust Vacuuming',
      ],
      bannerNotice: '🪚 Door lock & latch emergency repair available within 30 mins.',
      avgEta: '25-35 mins',
      imageAsset: 'assets/images/carpenter_service.jpg',
      imageAlignment: const Alignment(0.35, -0.7),
    ),

    // 10. 🚚 Delivery
    ServiceModel(
      id: 'delivery',
      title: 'Delivery',
      categoryName: 'On-Demand Courier & Logistics',
      subtitle: 'Parcels, food, grocery, pickup & drop, business logistics',
      fullDescription:
          'On-demand fast delivery service for parcel dispatch, confidential documents, restaurant food, groceries, multi-point pickup & drops, and business e-commerce deliveries.',
      icon: Icons.local_shipping_rounded,
      themeColor: const Color(0xFF16A34A),
      themeBgColor: const Color(0xFFDCFCE7),
      cardIconBgColor: const Color(0xFFBBF7D0),
      tag: 'SAME DAY',
      tagBgColor: const Color(0xFFDCFCE7),
      tagTextColor: const Color(0xFF15803D),
      ctaText: 'BOOK DELIVERY',
      rating: 4.9,
      totalReviews: '11.5k reviews',
      startingPrice: '₹79',
      subCategories: [
        'All',
        'Parcel & Document Delivery',
        'Food & Grocery Delivery',
        'Local Same-Day Delivery',
        'Pickup & Drop Service',
        'Business & Commercial Delivery',
      ],
      subServices: [
        SubServiceItem(
          title: 'Parcel & Document Delivery',
          description: 'Delivery of letters, documents, packages, small shipments, and other items.',
        ),
        SubServiceItem(
          title: 'Food & Grocery Delivery',
          description: 'Delivery of restaurant orders, groceries, daily essentials, and household items.',
        ),
        SubServiceItem(
          title: 'Local Same-Day Delivery',
          description: 'Fast delivery of items within the city or nearby areas on the same day.',
        ),
        SubServiceItem(
          title: 'Pickup & Drop Service',
          description: 'Pickup and delivery of documents, parcels, keys, products, and other items.',
        ),
        SubServiceItem(
          title: 'Business & Commercial Delivery',
          description: 'Delivery of shop orders, e-commerce packages, business documents, inventory, and commercial shipments.',
        ),
      ],
      highlights: [
        'Real-Time Live GPS Rider Tracking',
        'Secure Verification Handover',
        'Express 45-Min Local Drop',
      ],
      bannerNotice: '🚚 Instant rider dispatch within 15 minutes across your area.',
      avgEta: '15 mins',
      imageAsset: 'assets/images/delivery_service.jpg',
      imageAlignment: const Alignment(0.0, -0.25),
    ),
  ];

  /// Active providers (empty by default until fetched from Supabase backend)
  static final List<ServiceProviderModel> allProviders = [];

  static ServiceModel getServiceById(String id) {
    return allServices.firstWhere(
      (s) => s.id == id,
      orElse: () => allServices.firstWhere(
        (s) => s.title.toLowerCase().contains(id.toLowerCase()),
        orElse: () => allServices[0],
      ),
    );
  }

  static List<ServiceProviderModel> getProvidersForService(String serviceId) {
    return allProviders.where((p) => p.serviceId == serviceId).toList();
  }
}
