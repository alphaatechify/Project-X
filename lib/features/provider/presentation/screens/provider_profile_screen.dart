import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_x/app/router/routes.dart';
import 'package:project_x/app/theme/app_colors.dart';
import '../../../../services/auth_service.dart';
import '../../../../core/supabase/supabase_provider.dart';
import '../../../../core/storage/local_storage.dart';

class ProviderProfileScreen extends ConsumerStatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  ConsumerState<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends ConsumerState<ProviderProfileScreen> {
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _primaryPhoneController = TextEditingController();
  final TextEditingController _emergencyPhoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _customAmountController = TextEditingController(text: '1500');

  // States
  String _selectedCategory = 'Plumbing';
  final Set<String> _selectedSubServices = {'Plumbing Installation', 'Plumbing Repair'};
  String _selectedRate = '₹1,200/day';
  
  // Checklist State
  bool _chkOwnTools = true;
  bool _chkInstantDispatch = true;
  bool _chkGeofenceReadiness = true;

  final Map<String, List<String>> _categorySubServicesMap = {
    'Plumbing': [
      'Plumbing Installation',
      'Plumbing Repair',
      'Water Leakage Repair',
      'Drain & Toilet Blockage Removal',
      'Plumbing Replacement',
    ],
    'Electrician': [
      'Electrical Installation',
      'Electrical Repair',
      'Wiring & Rewiring',
      'Fan & Light Services',
      'Power & Electrical Fault Repair',
    ],
    'Housekeeping': [
      'Home Cleaning',
      'Deep Cleaning',
      'Bathroom Cleaning',
      'Kitchen Cleaning',
      'Sofa & Carpet Cleaning',
    ],
    'Painter': [
      'Interior Painting',
      'Exterior Painting',
      'Wall Repair & Painting',
      'Texture & Decorative Painting',
      'Repainting & Touch-Up',
    ],
    'Health Coach': [
      'Fitness & Exercise Coaching',
      'Weight Management Coaching',
      'Nutrition & Diet Coaching',
      'Lifestyle & Habit Coaching',
      'Personal Wellness Coaching',
    ],
    'Home Appliances': [
      'Refrigerator Repair & Service',
      'Washing Machine Repair & Service',
      'AC Repair & Service',
      'Microwave Oven Repair & Service',
      'TV Repair & Service',
    ],
    'Business & Digital Services': [
      'Digital Marketing',
      'Video Editing',
      'Website Development',
      'Graphic Design',
      'Business & Growth Services',
    ],
    'Construction Materials Supplier': [
      'Cement & Concrete Supply',
      'Sand & Aggregate Supply',
      'Bricks & Blocks Supply',
      'Steel & TMT Supply',
      'Construction Materials Supply',
    ],
    'Carpenter': [
      'Furniture Repair',
      'Furniture Installation & Assembly',
      'Custom Furniture Making',
      'Door & Window Services',
      'Woodwork & Carpentry',
    ],
    'Delivery': [
      'Parcel & Document Delivery',
      'Food & Grocery Delivery',
      'Local Same-Day Delivery',
      'Pickup & Drop Service',
      'Business & Commercial Delivery',
    ],
  };

  void _selectCategory(String cat) {
    setState(() {
      _selectedCategory = cat;
      _selectedSubServices.clear();
      final subs = _categorySubServicesMap[cat] ?? [];
      if (subs.length >= 2) {
        _selectedSubServices.addAll(subs.take(2));
      } else {
        _selectedSubServices.addAll(subs);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(currentUserProfileProvider);
      if (profile != null) {
        if (_nameController.text.isEmpty && profile.fullName.isNotEmpty) {
          _nameController.text = profile.fullName;
        }
        if (_primaryPhoneController.text.isEmpty && profile.phoneNumber.isNotEmpty) {
          _primaryPhoneController.text = profile.phoneNumber;
        }
        if (_emailController.text.isEmpty && profile.email.isNotEmpty) {
          _emailController.text = profile.email;
        }
        if (_bioController.text.isEmpty && profile.bio.isNotEmpty) {
          _bioController.text = profile.bio;
        }
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _primaryPhoneController.dispose();
    _emergencyPhoneController.dispose();
    _bioController.dispose();
    _customAmountController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final authService = ref.read(authServiceProvider);
    final supabase = ref.read(supabaseClientProvider);
    final profile = ref.read(currentUserProfileProvider);

    final cleanDigits = _primaryPhoneController.text.replaceAll(RegExp(r'\D'), '');
    final phone = cleanDigits.isNotEmpty ? cleanDigits : (profile?.phoneNumber ?? '1234567890');
    final name = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : (profile?.fullName ?? 'Service Partner');
    final email = _emailController.text.trim();
    final bio = _bioController.text.trim();

    double priceNumber = 1200.0;
    if (_selectedRate == 'Custom') {
      priceNumber = double.tryParse(_customAmountController.text.replaceAll(RegExp(r'[^\d.]'), '')) ?? 1500.0;
    } else {
      priceNumber = double.tryParse(_selectedRate.replaceAll(RegExp(r'[^\d.]'), '')) ?? 1200.0;
    }

    // 1. Update Profile in local state, SharedPreferences & Supabase
    await authService.updateProfile(
      fullName: name,
      phoneNumber: phone,
      email: email,
      bio: bio,
      isProvider: true,
    );

    // 2. Set provider LIVE state
    ref.read(isProviderLiveProvider.notifier).state = true;
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setBool('is_provider_live', true);
    } catch (_) {}

    // 3. Find provider ID from profile
    String? providerId = (profile != null && profile.id.isNotEmpty) ? profile.id : null;
    if (providerId == null) {
      try {
        var profileRow = await supabase
            .from('profiles')
            .select('id')
            .eq('phone_number', phone)
            .maybeSingle();

        if (profileRow == null && !phone.startsWith('91')) {
          profileRow = await supabase
              .from('profiles')
              .select('id')
              .eq('phone_number', '91$phone')
              .maybeSingle();
        }
        if (profileRow != null && profileRow['id'] != null) {
          providerId = profileRow['id'].toString();
        }
      } catch (e) {
        debugPrint('⚠️ Error getting provider profile ID: $e');
      }
    }

    // 4. Insert service offering into Supabase services table
    try {
      final serviceData = {
        if (providerId != null) 'provider_id': providerId,
        'title': _selectedCategory,
        'category': _selectedCategory.toLowerCase().replaceAll(' ', '_'),
        'description': bio.isNotEmpty ? bio : 'Professional $_selectedCategory service by $name',
        'price': priceNumber,
        'price_unit': '/day',
        'sub_categories': _selectedSubServices.toList(),
        'is_available': true,
      };

      final inserted = await supabase.from('services').insert(serviceData).select();
      debugPrint('✅ Service saved in Supabase successfully: $inserted');
    } catch (e) {
      debugPrint('⚠️ Error saving service to Supabase: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Supabase Services Insert: $e',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Profile & Service Updated! You are LIVE on the dispatch network.',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF15803D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 20),
          onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.home),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'Provider Information',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            Text(
              'STEP 1 OF 3',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF655318),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.person_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Top Yellow Header Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF08A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flash_on_rounded, size: 12, color: Color(0xFF854D0E)),
                  const SizedBox(width: 4),
                  Text(
                    'PROVIDER ENROLLMENT • INSTANT DISPATCH NETWORK',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF854D0E),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'Register as a Service Pro',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Complete your profile to receive instant nearby client bookings within a 5 km geofence radius.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            // Progress bar
            Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: 0.5,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.primaryYellow,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '50%',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Partner Profile Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              ),
              child: Row(
                children: [
                  Builder(
                    builder: (context) {
                      final profile = ref.watch(currentUserProfileProvider);
                      final currentName = _nameController.text.trim().isNotEmpty
                          ? _nameController.text.trim()
                          : ((profile != null && profile.fullName.isNotEmpty) ? profile.fullName : 'Service Partner');
                      final initial = currentName.isNotEmpty ? currentName[0].toUpperCase() : 'P';
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: 54,
                              height: 54,
                              color: AppColors.primaryYellow,
                              child: Center(
                                child: Text(
                                  initial,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: const Color(0xFF06B6D4), // cyan dot
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final profile = ref.watch(currentUserProfileProvider);
                        final currentName = _nameController.text.trim().isNotEmpty
                            ? _nameController.text.trim()
                            : ((profile != null && profile.fullName.isNotEmpty) ? profile.fullName : 'Service Partner');
                        final loc = (profile != null && profile.location.isNotEmpty) ? profile.location : 'Partner Hub';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  currentName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF06B6D4)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Verified Partner • $loc',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF08A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'TARGET ETA',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF713F12),
                          ),
                        ),
                        Text(
                          '< 15 min',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF713F12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // SECTION 1: CONTACT & IDENTITY LOCK
            _buildSectionHeader('1. CONTACT & IDENTITY LOCK', badgeText: '🔒 256-bit Encrypted'),
            const SizedBox(height: 14),

            // Full Name
            _buildInputLabel('FULL NAME'),
            const SizedBox(height: 6),
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.person_outline_rounded, color: AppColors.textSecondary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textDark),
                      decoration: const InputDecoration(
                        hintText: 'Enter your full name',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: (val) => setState(() {}),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Email Address
            _buildInputLabel('EMAIL ADDRESS'),
            const SizedBox(height: 6),
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.email_outlined, color: AppColors.textSecondary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textDark),
                      decoration: const InputDecoration(
                        hintText: 'Enter your email address',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCFFAFE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_rounded, size: 12, color: Color(0xFF0891B2)),
                        const SizedBox(width: 2),
                        Text(
                          'Verified',
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF0891B2)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Primary Dispatch Phone
            _buildInputLabel('PRIMARY DISPATCH PHONE (MOBILE NUMBER)'),
            const SizedBox(height: 6),
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.phone_outlined, color: AppColors.textSecondary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _primaryPhoneController,
                      style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textDark),
                      decoration: const InputDecoration(
                        hintText: 'Enter mobile number',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.flash_on_rounded, size: 12, color: AppColors.textDark),
                        const SizedBox(width: 2),
                        Text(
                          'Linked OTP',
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textDark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Secondary Emergency Phone
            _buildInputLabel('SECONDARY EMERGENCY PHONE'),
            const SizedBox(height: 6),
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Text('🇮🇳', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text('+91', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _emergencyPhoneController,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textDark),
                      decoration: InputDecoration(
                        hintText: 'Enter secondary emergency phone',
                        hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Used for urgent job dispatch & customer backup notifications.',
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
            ),

            const SizedBox(height: 28),

            // SECTION 2: PRIMARY SPECIALTY
            _buildSectionHeader('2. PRIMARY SPECIALTY', badgeText: 'REQUIRED'),
            const SizedBox(height: 8),
            Text(
              'Select Primary Category',
              style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            const SizedBox(height: 2),
            Text(
              'Pick your domain. You can switch category anytime.',
              style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),

            // 10 Specialty Cards Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                int crossAxisCount = 2;
                double childAspectRatio = 1.45;
                if (width >= 860) {
                  crossAxisCount = 4;
                  childAspectRatio = 1.6;
                } else if (width >= 600) {
                  crossAxisCount = 3;
                  childAspectRatio = 1.5;
                } else {
                  crossAxisCount = 2;
                  childAspectRatio = 1.45;
                }

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children: [
                    _buildSpecialtyCard(
                      title: 'Plumbing',
                      subtitle: 'Leaks & Fixtures',
                      icon: Icons.plumbing_rounded,
                      isSelected: _selectedCategory == 'Plumbing',
                      onTap: () => _selectCategory('Plumbing'),
                    ),
                    _buildSpecialtyCard(
                      title: 'Electrician',
                      subtitle: 'Wiring & Power',
                      icon: Icons.bolt_rounded,
                      isSelected: _selectedCategory == 'Electrician',
                      onTap: () => _selectCategory('Electrician'),
                    ),
                    _buildSpecialtyCard(
                      title: 'Housekeeping',
                      subtitle: 'Deep Clean & Hygiene',
                      icon: Icons.cleaning_services_rounded,
                      isSelected: _selectedCategory == 'Housekeeping',
                      onTap: () => _selectCategory('Housekeeping'),
                    ),
                    _buildSpecialtyCard(
                      title: 'Painter',
                      subtitle: 'Wall & Texture',
                      icon: Icons.format_paint_rounded,
                      isSelected: _selectedCategory == 'Painter',
                      onTap: () => _selectCategory('Painter'),
                    ),
                    _buildSpecialtyCard(
                      title: 'Health Coach',
                      subtitle: 'Fitness & Wellness',
                      icon: Icons.fitness_center_rounded,
                      isSelected: _selectedCategory == 'Health Coach',
                      onTap: () => _selectCategory('Health Coach'),
                    ),
                    _buildSpecialtyCard(
                      title: 'Home Appliances',
                      subtitle: 'AC, Fridge & TV',
                      icon: Icons.kitchen_rounded,
                      isSelected: _selectedCategory == 'Home Appliances',
                      onTap: () => _selectCategory('Home Appliances'),
                    ),
                    _buildSpecialtyCard(
                      title: 'Business & Digital Services',
                      subtitle: 'Web, Video & Growth',
                      icon: Icons.devices_rounded,
                      isSelected: _selectedCategory == 'Business & Digital Services',
                      onTap: () => _selectCategory('Business & Digital Services'),
                    ),
                    _buildSpecialtyCard(
                      title: 'Construction Materials Supplier',
                      subtitle: 'Cement, Sand & Steel',
                      icon: Icons.foundation_rounded,
                      isSelected: _selectedCategory == 'Construction Materials Supplier',
                      onTap: () => _selectCategory('Construction Materials Supplier'),
                    ),
                    _buildSpecialtyCard(
                      title: 'Carpenter',
                      subtitle: 'Furniture & Woodwork',
                      icon: Icons.handyman_rounded,
                      isSelected: _selectedCategory == 'Carpenter',
                      onTap: () => _selectCategory('Carpenter'),
                    ),
                    _buildSpecialtyCard(
                      title: 'Delivery',
                      subtitle: 'Parcels & Same Day',
                      icon: Icons.local_shipping_rounded,
                      isSelected: _selectedCategory == 'Delivery',
                      onTap: () => _selectCategory('Delivery'),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),
            _buildInputLabel('APPLICABLE SUB-SERVICES FOR ${_selectedCategory.toUpperCase()}'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (_categorySubServicesMap[_selectedCategory] ?? ['General Service', 'Inspection'])
                  .map((sub) => _buildSubServiceChip(sub))
                  .toList(),
            ),

            const SizedBox(height: 28),

            // SECTION 3: PRICING MODEL
            _buildSectionHeader('3. PRICING MODEL'),
            const SizedBox(height: 8),
            Text(
              'Daily Charge & Pricing Rate',
              style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            const SizedBox(height: 2),
            Text(
              'Set your standard full-day (8 hrs) or base hourly dispatch charge.',
              style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),

            // Rate Card Box
            Builder(
              builder: (context) {
                final displayPrice = _selectedRate == 'Custom'
                    ? (_customAmountController.text.trim().isEmpty ? '0' : _customAmountController.text.trim())
                    : _selectedRate.replaceAll('₹', '').replaceAll('/day', '').trim();

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'FULL DAY RATE (8 HOURS)',
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 0.6),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: const Color(0xFFFEF08A), borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              _selectedRate == 'Custom' ? 'CUSTOM' : 'STANDARD',
                              style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w800, color: const Color(0xFF713F12)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('₹$displayPrice', style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                          const SizedBox(width: 6),
                          Text('/ day', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Selectable Chips
                      Row(
                        children: [
                          _buildRateOptionChip('₹800/day'),
                          const SizedBox(width: 8),
                          _buildRateOptionChip('₹1,200/day'),
                          const SizedBox(width: 8),
                          _buildRateOptionChip('₹1,800/day'),
                          const SizedBox(width: 8),
                          _buildRateOptionChip('Custom'),
                        ],
                      ),

                      // Custom Amount Input Box when "Custom" is selected
                      if (_selectedRate == 'Custom') ...[
                        const SizedBox(height: 14),
                        _buildInputLabel('ENTER CUSTOM RATE AMOUNT (₹)'),
                        const SizedBox(height: 6),
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primaryYellowDark, width: 1.5),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: [
                              Text('₹', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _customAmountController,
                                  keyboardType: TextInputType.number,
                                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                                  decoration: const InputDecoration(
                                    hintText: 'Enter custom daily rate (e.g. 1500)',
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                  onChanged: (val) => setState(() {}),
                                ),
                              ),
                              Text('/ day', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 14),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Text('Overtime Add-on Rate', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                          const Spacer(),
                          Text('₹ 180 / hr', style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // 0% Commission Guarantee Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFECFEFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFA5F3FC), width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0891B2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.verified_outlined, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('0% Commission Guarantee', style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w800, color: const Color(0xFF0E7490))),
                        const SizedBox(height: 2),
                        Text('0% platform commission on your first 10 bookings. 100% direct instant bank payout.', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF155E75), height: 1.3)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // SECTION 4: PROFESSIONAL PROFILE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader('4. PROFESSIONAL PROFILE'),
                Text('156 / 500 characters', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Work Experience & Bio',
              style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              ),
              padding: const EdgeInsets.all(14),
              child: TextField(
                controller: _bioController,
                maxLines: 4,
                style: GoogleFonts.inter(fontSize: 13, height: 1.4, color: AppColors.textDark),
                decoration: const InputDecoration(border: InputBorder.none, isDense: true),
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.lightbulb_outline_rounded, size: 14, color: Color(0xFF854D0E)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Profiles with authentic equipment notes receive 3x more acceptances.',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // SECTION 5: SERVICE READINESS (COVID-19 REMOVED)
            _buildSectionHeader('5. SERVICE READINESS'),
            const SizedBox(height: 8),
            Text(
              'Pro Safety & Gear Checklist',
              style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            const SizedBox(height: 12),

            _buildCheckTile(
              icon: Icons.home_repair_service_outlined,
              label: 'Own tools & equipment kit',
              value: _chkOwnTools,
              onChanged: (val) => setState(() => _chkOwnTools = val ?? false),
            ),
            const SizedBox(height: 8),
            _buildCheckTile(
              icon: Icons.timer_outlined,
              label: 'Ready for instant 15-min dispatch',
              value: _chkInstantDispatch,
              onChanged: (val) => setState(() => _chkInstantDispatch = val ?? false),
            ),
            const SizedBox(height: 8),
            _buildCheckTile(
              icon: Icons.near_me_outlined,
              label: '5.0 km radial travel readiness',
              value: _chkGeofenceReadiness,
              onChanged: (val) => setState(() => _chkGeofenceReadiness = val ?? false),
            ),

            const SizedBox(height: 28),

            // SECTION 6: VERIFICATION VAULT (POLICE VERIFICATION REMOVED)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader('6. VERIFICATION VAULT'),
                Text('VERIFIED', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF15803D))),
              ],
            ),
            const SizedBox(height: 12),

            _buildVaultCard(
              icon: Icons.badge_outlined,
              title: 'Government Aadhaar Authentication',
              subtitle: '✔ Aadhaar KYC Verified (Biometric Linked)',
              trailingWidget: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(8)),
                child: Text('VERIFIED', style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w800, color: const Color(0xFF15803D))),
              ),
            ),
            const SizedBox(height: 10),

            // Add Skill Certificates
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Upload Certificate Dialog'), duration: Duration(seconds: 1)),
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1, style: BorderStyle.solid),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.workspace_premium_outlined, size: 18, color: AppColors.textDark),
                      const SizedBox(width: 8),
                      Text(
                        'Add Skill Certificates (Optional)',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Boost Daily Earnings Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(color: AppColors.primaryYellow, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.bolt_rounded, color: AppColors.textDark, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Boost Daily Earnings', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                        const SizedBox(height: 2),
                        Text('Accepting 2 instant jobs/day yields ~₹36,000/mo.', style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textDark),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: AppColors.textDark,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Submit Application & Go Live',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 20, color: AppColors.textDark),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            Center(
              child: Text(
                'By continuing, you agree to Volt Provider Terms & 5.0 km geofence dispatch SLA.',
                style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    ),
  ),
);
}

  Widget _buildSectionHeader(String title, {String? badgeText}) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        if (badgeText != null) ...[
          const Spacer(),
          Text(
            badgeText,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        color: AppColors.textSecondary,
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _buildSpecialtyCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryYellow : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryYellowDark : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1.2,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black.withValues(alpha: 0.1) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: AppColors.textDark),
                ),
                const Spacer(),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: isSelected ? const Color(0xFF713F12) : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.textDark,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.check_rounded, color: AppColors.primaryYellow, size: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubServiceChip(String label) {
    final isSelected = _selectedSubServices.contains(label);
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedSubServices.remove(label);
          } else {
            _selectedSubServices.add(label);
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFEF08A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFEAB308) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_rounded : Icons.add_rounded,
              size: 14,
              color: isSelected ? const Color(0xFF713F12) : AppColors.textDark,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: isSelected ? const Color(0xFF713F12) : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRateOptionChip(String rateText) {
    final isSelected = _selectedRate == rateText;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedRate = rateText),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryYellow : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              rateText,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckTile({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textDark),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textDark),
            ),
          ),
          Checkbox(
            value: value,
            activeColor: AppColors.primaryYellow,
            checkColor: AppColors.textDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildVaultCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailingWidget,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.textDark, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          trailingWidget,
        ],
      ),
    );
  }
}
