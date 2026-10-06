import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_x/app/router/routes.dart';
import 'package:project_x/app/theme/app_colors.dart';

class ProviderProfileScreen extends ConsumerStatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  ConsumerState<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends ConsumerState<ProviderProfileScreen> {
  // Controllers
  final TextEditingController _emailController = TextEditingController(text: 'rahul.care@kineticvolt.com');
  final TextEditingController _primaryPhoneController = TextEditingController(text: '+91 98765 43210');
  final TextEditingController _emergencyPhoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController(
    text: 'Experienced professional with over 8 years specializing in deep household sanitation, eco-friendly chemical cleaning, and quick kitchen degreasing. Punctual, polite',
  );

  // States
  String _selectedCategory = 'House Cleaning';
  final Set<String> _selectedSubServices = {'Deep Cleaning', 'Kitchen & Oven'};
  String _selectedRate = '₹1,200/day';
  
  // Checklist State
  bool _chkOwnTools = true;
  bool _chkInstantDispatch = true;
  bool _chkVaccinated = true;
  bool _chkGeofenceReadiness = true;

  @override
  void dispose() {
    _emailController.dispose();
    _primaryPhoneController.dispose();
    _emergencyPhoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Provider Profile Updated! You are LIVE on the dispatch network.',
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
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          'assets/images/doctor_rahul_sharma.jpg',
                          width: 54,
                          height: 54,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 54,
                            height: 54,
                            color: const Color(0xFF0F172A),
                            child: const Icon(Icons.person_rounded, color: Colors.white, size: 30),
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
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Rahul Sharma',
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
                          'Top Tier Partner • Gurugram Hub',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
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
                      decoration: const InputDecoration(border: InputBorder.none, isDense: true),
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
            _buildInputLabel('PRIMARY DISPATCH PHONE'),
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
                      decoration: const InputDecoration(border: InputBorder.none, isDense: true),
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
              'Pick your domain. You can add secondary skills after identity verification.',
              style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),

            // 6 Specialty Cards Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.45,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _buildSpecialtyCard(
                  title: 'House Cleaning',
                  subtitle: 'Houseworker',
                  icon: Icons.cleaning_services_outlined,
                  isSelected: _selectedCategory == 'House Cleaning',
                  onTap: () => setState(() => _selectedCategory = 'House Cleaning'),
                ),
                _buildSpecialtyCard(
                  title: 'Electrician',
                  subtitle: 'Wiring & Meters',
                  icon: Icons.bolt_outlined,
                  isSelected: _selectedCategory == 'Electrician',
                  onTap: () => setState(() => _selectedCategory = 'Electrician'),
                ),
                _buildSpecialtyCard(
                  title: 'Plumber',
                  subtitle: 'Pipes & Fixtures',
                  icon: Icons.water_drop_outlined,
                  isSelected: _selectedCategory == 'Plumber',
                  onTap: () => setState(() => _selectedCategory = 'Plumber'),
                ),
                _buildSpecialtyCard(
                  title: 'Appliance Repair',
                  subtitle: 'AC & Fridge',
                  icon: Icons.kitchen_outlined,
                  isSelected: _selectedCategory == 'Appliance Repair',
                  onTap: () => setState(() => _selectedCategory = 'Appliance Repair'),
                ),
                _buildSpecialtyCard(
                  title: 'Carpenter',
                  subtitle: 'Furniture & Locks',
                  icon: Icons.handyman_outlined,
                  isSelected: _selectedCategory == 'Carpenter',
                  onTap: () => setState(() => _selectedCategory = 'Carpenter'),
                ),
                _buildSpecialtyCard(
                  title: 'Doctor & Home Care',
                  subtitle: 'Nursing Support',
                  icon: Icons.medical_services_outlined,
                  isSelected: _selectedCategory == 'Doctor & Home Care',
                  onTap: () => setState(() => _selectedCategory = 'Doctor & Home Care'),
                ),
              ],
            ),

            const SizedBox(height: 16),
            _buildInputLabel('APPLICABLE SUB-SERVICES'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSubServiceChip('Deep Cleaning'),
                _buildSubServiceChip('Kitchen & Oven'),
                _buildSubServiceChip('Floor Mopping & Buffing'),
                _buildSubServiceChip('Bathroom Scrubbing'),
              ],
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
            Container(
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
                        child: Text('STANDARD', style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w800, color: const Color(0xFF713F12))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('₹1,200', style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textDark)),
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

            // SECTION 5: SERVICE READINESS
            _buildSectionHeader('5. SERVICE READINESS'),
            const SizedBox(height: 8),
            Text(
              'Pro Safety & Gear Checklist',
              style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            const SizedBox(height: 12),

            _buildCheckTile(
              icon: Icons.home_repair_service_outlined,
              label: 'Own tools & cleaning kit',
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
              icon: Icons.verified_user_outlined,
              label: 'COVID-19 vaccinated & verified ID',
              value: _chkVaccinated,
              onChanged: (val) => setState(() => _chkVaccinated = val ?? false),
            ),
            const SizedBox(height: 8),
            _buildCheckTile(
              icon: Icons.near_me_outlined,
              label: '5.0 km radial travel readiness',
              value: _chkGeofenceReadiness,
              onChanged: (val) => setState(() => _chkGeofenceReadiness = val ?? false),
            ),

            const SizedBox(height: 28),

            // SECTION 6: VERIFICATION VAULT
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

            _buildVaultCard(
              icon: Icons.shield_outlined,
              title: 'Police Verification State...',
              subtitle: 'Certificate: DL-6841 • POLL...',
              trailingWidget: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFFEF08A), borderRadius: BorderRadius.circular(8)),
                child: Text('VALID 2026', style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w800, color: const Color(0xFF713F12))),
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
