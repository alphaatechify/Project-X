import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_x/app/router/routes.dart';
import 'package:project_x/app/theme/app_colors.dart';
import 'package:project_x/features/bookings/presentation/widgets/bookings_view.dart';
import 'package:project_x/features/profile/presentation/widgets/profile_view.dart';
import '../widgets/emergency_services_modal.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedBottomNavIndex = 0;
  bool _isProviderMode = false;
  final TextEditingController _searchController = TextEditingController();

  void _showEmergencyModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => const EmergencyServicesModal(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showLocationPickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Location', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.my_location_rounded, color: AppColors.textDark),
              title: Text('Indiranagar 100ft Rd', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              subtitle: Text('HAL 2nd Stage, Indiranagar, Bengaluru, KA 560038', style: GoogleFonts.inter(fontSize: 12)),
              trailing: const Icon(Icons.check_circle_rounded, color: AppColors.primaryYellowDark),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.add_location_alt_outlined),
              title: Text('+ Add New Address', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedBottomNavIndex,
          children: [
            _buildHomeContent(),
            const BookingsView(),
            const ProfileView(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // 1. Top Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Bolt Squircle Logo
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryYellow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.flash_on_rounded, color: AppColors.textDark, size: 22),
                  ),
                ),
                const SizedBox(width: 10),

                // Location Dropdown Selector
                InkWell(
                  onTap: _showLocationPickerSheet,
                  borderRadius: BorderRadius.circular(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HOME',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Indiranagar 100ft Rd',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: AppColors.textDark),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Notification Bell
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No new notifications'), duration: Duration(seconds: 2)),
                    );
                  },
                  icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textDark, size: 24),
                ),

                // User Avatar Button (Redirects to Profile page)
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedBottomNavIndex = 2;
                    });
                  },
                  borderRadius: BorderRadius.circular(19),
                  child: Container(
                    width: 38,
                    height: 38,
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
          ),

          const SizedBox(height: 12),

          // 2. Sub-header GPS Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAB308),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'GPS ACTIVE',
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF854D0E)),
                ),
                const SizedBox(width: 8),
                Text(
                  '• HAL 2nd Stage, Indiranagar',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                ),
                const Spacer(),

                // Mode Tag Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isProviderMode ? const Color(0xFFFEF08A) : const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.flash_on_rounded, size: 12, color: _isProviderMode ? const Color(0xFF854D0E) : const Color(0xFF0369A1)),
                      const SizedBox(width: 2),
                      Text(
                        _isProviderMode ? 'PROVIDER' : 'CUSTOMER',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _isProviderMode ? const Color(0xFF854D0E) : const Color(0xFF0369A1),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. Search Bar Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              hintText: 'Search electrician, plumber,',
                              hintStyle: GoogleFonts.inter(fontSize: 13.5, color: AppColors.textMuted),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        const Icon(Icons.mic_none_rounded, color: AppColors.textSecondary, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Filter Button
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                  ),
                  child: const Icon(Icons.tune_rounded, color: AppColors.textDark, size: 20),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 4. Dual Mode Protocol Banner Card (Dark Banner)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF18181B), // Dark sleek background
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 4)),
                ],
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.flash_on_rounded, size: 14, color: AppColors.primaryYellow),
                              const SizedBox(width: 4),
                              Text(
                                'DUAL MODE PROTOCOL',
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFA1A1AA),
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Go Live as Provider',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      // Toggle Switch
                      Switch.adaptive(
                        value: _isProviderMode,
                        activeTrackColor: AppColors.primaryYellow,
                        onChanged: (val) {
                          setState(() {
                            _isProviderMode = val;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(val ? 'Switched to Provider Mode' : 'Switched to Customer Mode'),
                              duration: const Duration(milliseconds: 1500),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isProviderMode
                        ? '🟢 ONLINE • Receiving instant service requests nearby (5.0 km geofence).'
                        : '● OFFLINE • Browsing as Customer. Switch ON to accept Instant bookings near you (5.0 km geofence).',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: const Color(0xFFA1A1AA),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => context.push(AppRoutes.providerProfile),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF27272A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF3F3F46), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.edit_note_rounded, size: 16, color: AppColors.primaryYellow),
                          const SizedBox(width: 6),
                          Text(
                            'Edit Provider Profile →',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryYellow,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),


          const SizedBox(height: 24),

          // 5. Essential Services Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AVAILABLE NOW',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF854D0E), letterSpacing: 0.6),
                ),
                Text(
                  'Essential Services',
                  style: GoogleFonts.plusJakartaSans(fontSize: 21, fontWeight: FontWeight.w800, color: AppColors.textDark),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Essential Services 2-Column Grid (Descriptions Removed)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.35,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildServiceCard(
                  serviceId: 'dr_house',
                  title: 'Dr. House & Care',
                  tag: 'CERTIFIED',
                  tagBgColor: const Color(0xFFFEE2E2),
                  tagTextColor: const Color(0xFF991B1B),
                  iconBgColor: const Color(0xFFFEE2E2),
                  icon: Icons.medical_services_outlined,
                  ctaText: 'CONSULT',
                ),
                _buildServiceCard(
                  serviceId: 'house_cleaning',
                  title: 'House Cleaning',
                  tag: 'BEST',
                  tagBgColor: AppColors.primaryYellow,
                  tagTextColor: AppColors.textDark,
                  iconBgColor: AppColors.primaryYellow,
                  icon: Icons.cleaning_services_outlined,
                  ctaText: 'BOOK EXPERT',
                ),
                _buildServiceCard(
                  serviceId: 'electrician',
                  title: 'Electrician',
                  tag: '⚡ FAST',
                  tagBgColor: const Color(0xFFFEF08A),
                  tagTextColor: const Color(0xFF854D0E),
                  iconBgColor: const Color(0xFFFEF08A),
                  icon: Icons.bolt_outlined,
                  ctaText: 'BOOK EXPERT',
                ),
                _buildServiceCard(
                  serviceId: 'plumber',
                  title: 'Plumber',
                  tag: 'POPULAR',
                  tagBgColor: const Color(0xFFE0F2FE),
                  tagTextColor: const Color(0xFF0369A1),
                  iconBgColor: const Color(0xFFBAE6FD),
                  icon: Icons.water_drop_outlined,
                  ctaText: 'BOOK EXPERT',
                ),
                _buildServiceCard(
                  serviceId: 'appliance_repair',
                  title: 'Appliance Repair',
                  tag: '4.8 ★',
                  tagBgColor: const Color(0xFFF3F4F6),
                  tagTextColor: AppColors.textDark,
                  iconBgColor: const Color(0xFFE5E7EB),
                  icon: Icons.kitchen_outlined,
                  ctaText: 'INSPECT & FIX',
                ),
                _buildServiceCard(
                  serviceId: 'carpenter',
                  title: 'Carpenter',
                  tag: '4.9 ★',
                  tagBgColor: const Color(0xFFFEF3C7),
                  tagTextColor: const Color(0xFF92400E),
                  iconBgColor: const Color(0xFFFEF3C7),
                  icon: Icons.handyman_outlined,
                  ctaText: 'BOOK EXPERT',
                ),
                _buildServiceCard(
                  serviceId: 'driver_on_demand',
                  title: 'Driver on Demand',
                  tag: 'HOURLY',
                  tagBgColor: const Color(0xFFF3F4F6),
                  tagTextColor: AppColors.textDark,
                  iconBgColor: const Color(0xFFFEF08A),
                  icon: Icons.directions_car_outlined,
                  ctaText: 'BOOK DRIVER',
                ),
                _buildServiceCard(
                  serviceId: 'painting_sealing',
                  title: 'Painting & Sealing',
                  tag: 'WARRANTY',
                  tagBgColor: const Color(0xFFF3F4F6),
                  tagTextColor: AppColors.textDark,
                  iconBgColor: const Color(0xFFFEF3C7),
                  icon: Icons.format_paint_outlined,
                  ctaText: 'GET ESTIMATE',
                ),
                _buildServiceCard(
                  serviceId: 'pest_control',
                  title: 'Pest Control',
                  tag: 'ECO-SAFE',
                  tagBgColor: const Color(0xFFCCFBF1),
                  tagTextColor: const Color(0xFF0F766E),
                  iconBgColor: const Color(0xFFCCFBF1),
                  icon: Icons.bug_report_outlined,
                  ctaText: 'DISINFECT',
                ),
                _buildServiceCard(
                  serviceId: 'gardening_care',
                  title: 'Gardening Care',
                  tag: '4.9 ★',
                  tagBgColor: const Color(0xFFFEF3C7),
                  tagTextColor: const Color(0xFF92400E),
                  iconBgColor: const Color(0xFFFEF3C7),
                  icon: Icons.yard_outlined,
                  ctaText: 'BOOK CARE',
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // 6. Recommended Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RECOMMENDED',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 0.6),
                    ),
                    Text(
                      'Trending in Indiranagar',
                      style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                  ],
                ),
                Text(
                  'SEE ALL',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF854D0E)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Horizontal Trending Cards List
          SizedBox(
            height: 240,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildTrendingCard(
                  serviceId: 'ac_deep_jet',
                  title: 'AC Deep Jet Service',
                  subtitle: 'High pressure jet clean & filter swap',
                  rating: '★ 4.9 (2.1k)',
                  imagePath: 'assets/images/ac_deep_clean.jpg',
                ),
                const SizedBox(width: 14),
                _buildTrendingCard(
                  serviceId: 'home_sanitization',
                  title: 'Full Home Sanitization',
                  subtitle: 'Steam sterilization & deep disinfectant',
                  rating: '★ 4.8 (1.4k)',
                  imagePath: 'assets/images/home_sanitizing.jpg',
                ),
              ],
            ),
          ),


          const SizedBox(height: 24),

          // 7. Emergency Services Banner Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: InkWell(
              onTap: _showEmergencyModal,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFCA5A5), width: 1),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(child: Icon(Icons.sos_rounded, color: Colors.white, size: 24)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Emergency Response', style: GoogleFonts.plusJakartaSans(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFFDC2626), borderRadius: BorderRadius.circular(8)),
                                child: Text('24/7 SOS', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text('Police (112), Ambulance (108), Fire (101)', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text('View All', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF991B1B))),
                        const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF991B1B)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // 8. Volt Certified Guarantee Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(child: Icon(Icons.verified_user_rounded, color: AppColors.textDark, size: 24)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Volt Certified Guarantee', style: GoogleFonts.plusJakartaSans(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                        const SizedBox(height: 2),
                        Text('Background-verified pros with 30-day warranty', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required String serviceId,
    required String title,
    required String tag,
    required Color tagBgColor,
    required Color tagTextColor,
    required Color iconBgColor,
    required IconData icon,
    required String ctaText,
  }) {
    return InkWell(
      onTap: () {
        context.push(AppRoutes.serviceDetail, extra: {'serviceId': serviceId});
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: AppColors.textDark, size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: tagBgColor, borderRadius: BorderRadius.circular(10)),
                  child: Text(tag, style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w800, color: tagTextColor)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(ctaText, style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(color: AppColors.surfaceLightGray, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.textDark),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingCard({
    required String serviceId,
    required String title,
    required String subtitle,
    required String rating,
    required String imagePath,
  }) {
    return InkWell(
      onTap: () {
        context.push(AppRoutes.serviceDetail, extra: {'serviceId': serviceId});
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                  imagePath,
                  width: 240,
                  height: 130,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 240,
                    height: 130,
                    color: const Color(0xFFFEF08A),
                    child: const Center(
                      child: Icon(Icons.cleaning_services_rounded, size: 44, color: AppColors.textDark),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.75), borderRadius: BorderRadius.circular(10)),
                    child: Text(rating, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('⏱ Same Day', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.primaryYellow, borderRadius: BorderRadius.circular(14)),
                        child: Text('+ BOOK', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textDark)),
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


  Widget _buildBottomNavigationBar() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(index: 0, label: 'Home', icon: Icons.home_rounded),
          _buildNavItem(index: 1, label: 'Bookings', icon: Icons.calendar_today_rounded),
          _buildNavItem(index: 2, label: 'Profile', icon: Icons.person_outline_rounded),
        ],
      ),
    );
  }

  Widget _buildNavItem({required int index, required String label, required IconData icon}) {
    final isSelected = _selectedBottomNavIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedBottomNavIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryYellow : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 20,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? AppColors.textDark : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
