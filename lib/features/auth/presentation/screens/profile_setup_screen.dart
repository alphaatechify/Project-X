import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_x/app/router/routes.dart';
import 'package:project_x/app/theme/app_colors.dart';
import 'package:project_x/features/auth/presentation/controllers/auth_controller.dart';
import 'package:project_x/features/auth/presentation/widgets/header_buttons.dart';
import 'package:project_x/features/auth/presentation/widgets/primary_button.dart';
import 'package:project_x/services/auth_service.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const ProfileSetupScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Alex Morgan');
  final FocusNode _nameFocusNode = FocusNode();

  final String _currentLocation = 'Indiranagar 100ft Rd';
  final String _currentAddress = 'HAL 2nd Stage, Indiranagar, Bengaluru, KA 560038';
  bool _isLocationConfirmed = false;
  bool _isLoading = false;

  String _homeAddress = 'Set address';
  String _workAddress = 'Add office';

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _handleSaveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter your full name',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Register user in auth service
    await ref.read(authServiceProvider).registerUser(
          phoneNumber: widget.phoneNumber,
          fullName: _nameController.text.trim(),
          location: '$_currentLocation, $_currentAddress',
        );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // Mark as authenticated in Riverpod state
    ref.read(authControllerProvider.notifier).login();

    // Navigate directly to Home Screen
    context.go(AppRoutes.home);
  }

  void _showAddCustomBookmarkDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Custom Bookmark', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'e.g., Gym, Parent\'s House',
            filled: true,
            fillColor: AppColors.surfaceLightGray,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Custom bookmark "${controller.text}" added!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: AppColors.textDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  AppBackButton(
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STEP 3 OF 3',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF854D0E), // Gold/olive dark
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        'Profile Setup',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const AppHelpButton(),
                  const SizedBox(width: 8),

                  // Avatar icon button
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF655318), // Warm brown/olive avatar background
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Quick Onboarding Subheader Tag
                    Row(
                      children: [
                        const Icon(Icons.flash_on_rounded, size: 16, color: Color(0xFF854D0E)),
                        const SizedBox(width: 4),
                        Text(
                          'QUICK ONBOARDING',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF854D0E),
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Section 1: Account Details Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ACCOUNT DETAILS',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.6,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.lock_outline_rounded, size: 14, color: Color(0xFF0F766E)),
                            const SizedBox(width: 4),
                            Text(
                              'Encrypted',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0F766E),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Full Name Input Card
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Full Name',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.person_outline_rounded, size: 20, color: AppColors.textDark),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _nameController,
                                  focusNode: _nameFocusNode,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section 2: Allow Location Access Card
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Top Right Ambient Warm Yellow Glow Accent inside card
                          Positioned(
                            top: -20,
                            right: -20,
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Color(0xFFFEF08A), // Light soft yellow
                                    Color(0x00FEF08A),
                                  ],
                                  radius: 0.85,
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top Row: Yellow Icon + GPS READY Badge
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Location Arrow Yellow Squircle Container
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryYellow,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.near_me_rounded,
                                          color: AppColors.textDark,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    // Title & Subtitle
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Allow Location\nAccess',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.textDark,
                                              height: 1.2,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Instant driver-matching & zero-wait estimations',
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              color: AppColors.textSecondary,
                                              height: 1.35,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // GPS READY Tag Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF08A),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'GPS\nREADY',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF713F12),
                                          height: 1.1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // Auto-detected location box
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF854D0E),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'AUTO-DETECTED LOCATION',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF854D0E),
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.location_on_outlined,
                                            size: 20,
                                            color: Color(0xFF854D0E),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _currentLocation,
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w800,
                                                    color: AppColors.textDark,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  _currentAddress,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12.5,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Button 1: Confirm Current Location
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _isLocationConfirmed = true;
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Location confirmed: $_currentLocation'),
                                          duration: const Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isLocationConfirmed ? const Color(0xFFEAB308) : AppColors.primaryYellow,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _isLocationConfirmed ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                                          color: AppColors.textDark,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _isLocationConfirmed ? 'Location Confirmed ✓' : 'Confirm Current Location',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // Button 2: Adjust on Map or Pick Manually
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Map selection picker opened'),
                                          duration: Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE5E7EB),
                                      side: BorderSide.none,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.map_outlined, color: AppColors.textDark, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Adjust on Map or Pick Manually',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section 3: Fast Bookmarks (Optional)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'FAST BOOKMARKS (OPTIONAL)',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.6,
                          ),
                        ),
                        InkWell(
                          onTap: _showAddCustomBookmarkDialog,
                          child: Text(
                            '+ Add Custom',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF854D0E),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Two Bookmark Cards
                    Row(
                      children: [
                        // Home Bookmark
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _homeAddress = 'Indiranagar 100ft Rd';
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceWhite,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceLightGray,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.home_outlined, color: AppColors.textDark, size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Home',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                        Text(
                                          _homeAddress,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Work Bookmark
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _workAddress = 'Tech Park, Whitefield';
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceWhite,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceLightGray,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.business_outlined, color: AppColors.textDark, size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Work',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                        Text(
                                          _workAddress,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Bottom CTA Save Profile Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                children: [
                  PrimaryButton(
                    text: 'Save Profile',
                    isLoading: _isLoading,
                    onPressed: _handleSaveProfile,
                  ),
                  const SizedBox(height: 10),

                  // Footer Disclaimer Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shield_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'You can fine-tune all personal preferences anytime in Settings.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
