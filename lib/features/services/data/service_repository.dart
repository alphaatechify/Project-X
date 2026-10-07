import 'package:flutter/material.dart';
import 'package:project_x/app/theme/app_colors.dart';
import '../domain/models/provider_model.dart';
import '../domain/models/service_model.dart';

class ServiceRepository {
  static final List<ServiceModel> allServices = [
    ServiceModel(
      id: 'dr_house',
      title: 'Dr. House & Care',
      categoryName: 'Healthcare & Medical Care',
      subtitle: 'Doctor Visit & Registered Home Nursing Care',
      fullDescription:
          'Comprehensive doorstep medical assistance including home doctor visits, certified nursing care, dental checkups, elderly health monitoring, and quick blood sample collection.',
      icon: Icons.medical_services_outlined,
      themeColor: const Color(0xFFDC2626),
      themeBgColor: const Color(0xFFFEF2F2),
      cardIconBgColor: const Color(0xFFFEE2E2),
      tag: 'CERTIFIED',
      tagBgColor: const Color(0xFFFEE2E2),
      tagTextColor: const Color(0xFF991B1B),
      ctaText: 'CONSULT DOCTOR',
      rating: 4.9,
      totalReviews: '4.8k reviews',
      startingPrice: '₹499',
      subCategories: ['All', 'Dental Clinic', 'General Physician', 'Elderly Care Specialist', 'Home Nursing', 'Lab Test Sample'],
      highlights: [
        'MBBS & BDS Certified Doctors',
        'Sterilized Mobile Diagnostic Equipment',
        '24/7 Emergency Medical Dispatch'
      ],
      bannerNotice: '⚡ Nearest doctor & dental clinic available in Indiranagar within 350m.',
      avgEta: '10-20 mins',
    ),
    ServiceModel(
      id: 'house_cleaning',
      title: 'House Cleaning',
      categoryName: 'Home Hygiene & Sanitation',
      subtitle: 'Kitchen, Bathroom & Full House Deep Cleaning',
      fullDescription:
          'Deep sanitization and intense cleaning for kitchen counters, appliance degreasing, bathroom tile scrubbing, living room dusting, and carpet shampooing.',
      icon: Icons.cleaning_services_outlined,
      themeColor: const Color(0xFF059669),
      themeBgColor: const Color(0xFFECFDF5),
      cardIconBgColor: AppColors.primaryYellow,
      tag: 'BEST SELLER',
      tagBgColor: AppColors.primaryYellow,
      tagTextColor: AppColors.textDark,
      ctaText: 'BOOK CLEANING',
      rating: 4.9,
      totalReviews: '6.2k reviews',
      startingPrice: '₹399',
      subCategories: ['All', 'Full Home Deep Clean', 'Kitchen Scrubbing', 'Bathroom Deep Clean', 'Sofa & Carpet'],
      highlights: [
        '100% Eco-Safe Non-Toxic Chemicals',
        'Heavy-Duty Vacuum & Single Disk Machine',
        '30-Day Reservice Guarantee'
      ],
      bannerNotice: '✨ Book today and get free kitchen counter degreasing addon!',
      avgEta: '30 mins',
    ),
    ServiceModel(
      id: 'electrician',
      title: 'Electrician',
      categoryName: 'Electrical Fixes & Wiring',
      subtitle: 'Electrical Wiring, Switches & Appliance Repairs',
      fullDescription:
          'Professional electrical repairs, circuit breaker troubleshooting, ceiling fan installations, smart light fittings, and complete home wiring inspection.',
      icon: Icons.bolt_outlined,
      themeColor: const Color(0xFFD97706),
      themeBgColor: const Color(0xFFFFFBEB),
      cardIconBgColor: const Color(0xFFFEF08A),
      tag: '⚡ FAST 15 MIN',
      tagBgColor: const Color(0xFFFEF08A),
      tagTextColor: const Color(0xFF854D0E),
      ctaText: 'BOOK ELECTRICIAN',
      rating: 4.8,
      totalReviews: '8.4k reviews',
      startingPrice: '₹149',
      subCategories: ['All', 'Switches & Sockets', 'Fan Installation', 'MCB & Fuse Repair', 'Chandelier & Lights'],
      highlights: [
        'Licensed & Insured Electricians',
        'Insulated Professional Safety Gear',
        'Standard Rate Card - No Hidden Costs'
      ],
      bannerNotice: '⚡ 15-min instant arrival guaranteed for power outage emergencies.',
      avgEta: '15 mins',
    ),
    ServiceModel(
      id: 'plumber',
      title: 'Plumber',
      categoryName: 'Plumbing & Pipe Infrastructure',
      subtitle: 'Water Leakage, Tap Fitting & Drain Unclogging',
      fullDescription:
          'Expert plumbing services for pipe leaks, bathroom fitting installations, drain unclogging, water tank cleaning, and hydro-jet drain flushing.',
      icon: Icons.water_drop_outlined,
      themeColor: const Color(0xFF0284C7),
      themeBgColor: const Color(0xFFF0F9FF),
      cardIconBgColor: const Color(0xFFBAE6FD),
      tag: 'POPULAR',
      tagBgColor: const Color(0xFFE0F2FE),
      tagTextColor: const Color(0xFF0369A1),
      ctaText: 'BOOK PLUMBER',
      rating: 4.9,
      totalReviews: '7.1k reviews',
      startingPrice: '₹199',
      subCategories: ['All', 'Tap & Mixer Leakage', 'Drain & Pipe Unclogging', 'Toilet & Cistern', 'Water Tank & Pump'],
      highlights: [
        'Thermal Camera Leak Detection',
        '30-Day Warranty on Repairs',
        'Clean & Mess-Free Post-Work Cleanup'
      ],
      bannerNotice: '💧 Rapid response team active in HAL 2nd Stage & Indiranagar.',
      avgEta: '20 mins',
    ),
    ServiceModel(
      id: 'appliance_repair',
      title: 'Appliance Repair',
      categoryName: 'Home Appliances & Electronics',
      subtitle: 'AC Service, Refrigerator & Washing Machine',
      fullDescription:
          'Certified technicians for AC gas refilling, washing machine drum repair, refrigerator cooling diagnostics, and microwave servicing.',
      icon: Icons.kitchen_outlined,
      themeColor: const Color(0xFF4F46E5),
      themeBgColor: const Color(0xFFEEF2FF),
      cardIconBgColor: const Color(0xFFE5E7EB),
      tag: '4.8 ★ RATED',
      tagBgColor: const Color(0xFFF3F4F6),
      tagTextColor: AppColors.textDark,
      ctaText: 'INSPECT & FIX',
      rating: 4.8,
      totalReviews: '5.9k reviews',
      startingPrice: '₹249',
      subCategories: ['All', 'AC Service & Gas', 'Washing Machine', 'Refrigerator', 'Microwave & Oven'],
      highlights: [
        '100% Genuine OEM Parts Guaranteed',
        '90-Day Parts Replacement Warranty',
        'Upfront Flat Rate Repair Quotes'
      ],
      bannerNotice: '❄️ Beat the heat: AC Gas refilling includes complimentary jet washing.',
      avgEta: '45 mins',
    ),
    ServiceModel(
      id: 'carpenter',
      title: 'Carpenter',
      categoryName: 'Woodwork & Furniture',
      subtitle: 'Furniture repair, locks & woodwork',
      fullDescription:
          'Skilled carpenters for furniture assembly, door alignment, lock repair, custom shelving, and wooden floor touchups. Precision tools and clean finish.',
      icon: Icons.handyman_outlined,
      themeColor: const Color(0xFF92400E),
      themeBgColor: const Color(0xFFFEF3C7),
      cardIconBgColor: const Color(0xFFFEF3C7),
      tag: '4.9 ★',
      tagBgColor: const Color(0xFFFEF3C7),
      tagTextColor: const Color(0xFF92400E),
      ctaText: 'BOOK EXPERT',
      rating: 4.9,
      totalReviews: '3.4k reviews',
      startingPrice: '₹299',
      subCategories: ['All', 'Furniture Assembly', 'Door & Lock Repair', 'Cabinet & Drawer', 'Wood Polishing'],
      highlights: [
        'Precision Laser Leveling Tools',
        'Custom Fit Woodwork Specialist',
        'Vacuum Dust Collection Included'
      ],
      bannerNotice: '🪵 Door lock emergency & latch fixes available within 30 mins.',
      avgEta: '30 mins',
    ),
    ServiceModel(
      id: 'driver_on_demand',
      title: 'Driver on Demand',
      categoryName: 'Personal Transportation',
      subtitle: 'Personal & outstation drivers on hourly basis',
      fullDescription:
          'Professional, uniform-clad drivers with background verification and defensive driving certificates. Available for hourly city drives, luxury cars, or outstation trips.',
      icon: Icons.directions_car_outlined,
      themeColor: const Color(0xFF2563EB),
      themeBgColor: const Color(0xFFEFF6FF),
      cardIconBgColor: const Color(0xFFFEF08A),
      tag: 'HOURLY',
      tagBgColor: const Color(0xFFF3F4F6),
      tagTextColor: AppColors.textDark,
      ctaText: 'BOOK DRIVER',
      rating: 4.9,
      totalReviews: '9.1k reviews',
      startingPrice: '₹149/hr',
      subCategories: ['All', 'City Hourly Drive', 'Outstation Trip', 'Night Driver', 'Luxury Car Specialist'],
      highlights: [
        'Background Verified & Drug Tested',
        'Defensive Driving Certified',
        'Automatic & Manual Transmission Experts'
      ],
      bannerNotice: '🚗 On-demand driver pickup at your location within 15 mins.',
      avgEta: '15 mins',
    ),
    ServiceModel(
      id: 'painting_sealing',
      title: 'Painting & Sealing',
      categoryName: 'Home Improvements',
      subtitle: 'Wall painting, touchups & waterproofing',
      fullDescription:
          'Professional interior and exterior painting services with Asian Paints and Berger low-VOC odorless paints. Includes wall masking, dustless sanding, and 1-day room repaints.',
      icon: Icons.format_paint_outlined,
      themeColor: const Color(0xFF7C3AED),
      themeBgColor: const Color(0xFFF5F3FF),
      cardIconBgColor: const Color(0xFFFEF3C7),
      tag: 'WARRANTY',
      tagBgColor: const Color(0xFFF3F4F6),
      tagTextColor: AppColors.textDark,
      ctaText: 'GET ESTIMATE',
      rating: 4.8,
      totalReviews: '2.8k reviews',
      startingPrice: '₹999',
      subCategories: ['All', '1-Room Express Paint', 'Seepage & Waterproofing', 'Accent Wall & Texture', 'Full House Paint'],
      highlights: [
        'Laser Wall Area Measurement',
        'Dustless Sanding Machinery',
        '1-Year Anti-Fungal Warranty'
      ],
      bannerNotice: '🎨 Free color consult & 3D visualizer demo with every estimate.',
      avgEta: 'Same Day Consult',
    ),
    ServiceModel(
      id: 'pest_control',
      title: 'Pest Control',
      categoryName: 'Environmental Safety',
      subtitle: 'Bedbugs, termites & cockroach eradication',
      fullDescription:
          'Odorous & odorless pest control treatments using CPCB approved eco-friendly chemicals. Eliminates cockroaches, bedbugs, termites, mosquitoes, and rodents with long-term protection.',
      icon: Icons.bug_report_outlined,
      themeColor: const Color(0xFF0F766E),
      themeBgColor: const Color(0xFFF0FDF4),
      cardIconBgColor: const Color(0xFFCCFBF1),
      tag: 'ECO-SAFE',
      tagBgColor: const Color(0xFFCCFBF1),
      tagTextColor: const Color(0xFF0F766E),
      ctaText: 'DISINFECT',
      rating: 4.9,
      totalReviews: '4.1k reviews',
      startingPrice: '₹499',
      subCategories: ['All', 'Cockroach Gel Treatment', 'Termite Barrier', 'Bedbug 2-Step Eradication', 'Rodent Proofing'],
      highlights: [
        'Government Approved Non-Toxic Chemicals',
        'Safe for Children & Pets',
        'Complimentary 6-Month Reservice Warranty'
      ],
      bannerNotice: '🌿 Odorless gel treatment - no need to empty kitchen cabinets!',
      avgEta: '45 mins',
    ),
    ServiceModel(
      id: 'gardening_care',
      title: 'Gardening Care',
      categoryName: 'Outdoor & Plant Maintenance',
      subtitle: 'Pruning, lawn mowing & potted plant care',
      fullDescription:
          'Expert gardeners for balcony garden setups, lawn trimming, organic soil enrichment, pest spraying for plants, and seasonal pruning for lush greenery.',
      icon: Icons.yard_outlined,
      themeColor: const Color(0xFF15803D),
      themeBgColor: const Color(0xFFF0FDF4),
      cardIconBgColor: const Color(0xFFFEF3C7),
      tag: '4.9 ★',
      tagBgColor: const Color(0xFFFEF3C7),
      tagTextColor: const Color(0xFF92400E),
      ctaText: 'BOOK CARE',
      rating: 4.9,
      totalReviews: '1.9k reviews',
      startingPrice: '₹299',
      subCategories: ['All', 'Balcony Garden Maintenance', 'Lawn Mowing & Edging', 'Plant Potting & Repotting', 'Organic Fertilizer'],
      highlights: [
        'Certified Horticultural Experts',
        'Organic Soil & Nutrients Included',
        'Custom Plant Care Schedules'
      ],
      bannerNotice: '🪴 Transform your balcony into a green sanctuary this weekend!',
      avgEta: '1 Hour',
    ),
    ServiceModel(
      id: 'ac_deep_jet',
      title: 'AC Deep Jet Service',
      categoryName: 'AC Maintenance & Jet Cleaning',
      subtitle: 'High pressure jet clean & filter swap',
      fullDescription:
          'High-pressure water jet cleaning for split and window ACs. Removes 99.9% dust mold, improves cooling efficiency by 40%, and saves up to 25% on electricity bills.',
      icon: Icons.ac_unit_rounded,
      themeColor: const Color(0xFF0284C7),
      themeBgColor: const Color(0xFFF0F9FF),
      cardIconBgColor: const Color(0xFFE0F2FE),
      tag: '★ 4.9 (2.1k)',
      tagBgColor: AppColors.primaryYellow,
      tagTextColor: AppColors.textDark,
      ctaText: 'BOOK JET CLEAN',
      rating: 4.9,
      totalReviews: '2.1k reviews',
      startingPrice: '₹499',
      subCategories: ['All', 'Split AC Jet Wash', 'Window AC Jet Wash', 'Gas Topup Addon', 'Foam Jet Cleaning'],
      highlights: [
        'High Pressure Jet Pump Cleaning',
        'Jacket Protection against Leakage',
        'Cooling Temp Verification Check'
      ],
      bannerNotice: '⚡ Instant 20% cashback on 2+ AC jet clean bookings today.',
      avgEta: '30 mins',
    ),
    ServiceModel(
      id: 'home_sanitization',
      title: 'Full Home Sanitization',
      categoryName: 'Sterilization & Disinfection',
      subtitle: 'Steam sterilization & deep disinfectant fogging',
      fullDescription:
          'Hospital-grade thermal fogging and UL cold mist disinfection. Eliminates airborne viruses, allergens, bacteria, and mold from bedrooms, kitchens, and living rooms.',
      icon: Icons.sanitizer_outlined,
      themeColor: const Color(0xFF0D9488),
      themeBgColor: const Color(0xFFF0FDFA),
      cardIconBgColor: const Color(0xFFCCFBF1),
      tag: '★ 4.8 (1.4k)',
      tagBgColor: const Color(0xFFCCFBF1),
      tagTextColor: const Color(0xFF0F766E),
      ctaText: 'BOOK FOGGING',
      rating: 4.8,
      totalReviews: '1.4k reviews',
      startingPrice: '₹599',
      subCategories: ['All', 'ULV Cold Fogging', 'Steam Sterilization', 'Kitchen Sanitization', 'Kid Room Disinfection'],
      highlights: [
        'EPA Certified Disinfectants',
        'Zero Residue & Odor-Free',
        '100% Safe for Newborns & Pets'
      ],
      bannerNotice: '🛡️ Complete virus shield protection for your entire home.',
      avgEta: '40 mins',
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
