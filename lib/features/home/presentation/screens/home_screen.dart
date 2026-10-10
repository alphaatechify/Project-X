import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_x/app/router/routes.dart';
import 'package:project_x/app/theme/app_colors.dart';
import 'package:project_x/features/bookings/presentation/widgets/bookings_view.dart';
import 'package:project_x/features/profile/presentation/widgets/profile_view.dart';
import 'package:project_x/features/services/data/service_repository.dart';
import 'package:project_x/features/services/domain/models/service_model.dart';
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
  String _searchQuery = '';
  String _selectedSubServiceCategory = 'plumbing';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

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
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
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
                              hintText: 'Search plumbing, cleaning, appliances...',
                              hintStyle: GoogleFonts.inter(fontSize: 13.5, color: AppColors.textMuted),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                            },
                            child: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
                          )
                        else
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _searchQuery.isNotEmpty ? 'SEARCH RESULTS' : 'AVAILABLE NOW • 10 CATEGORIES',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF854D0E), letterSpacing: 0.6),
                    ),
                    Text(
                      'Essential Services',
                      style: GoogleFonts.plusJakartaSans(fontSize: 21, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                  ],
                ),
                Text(
                  '${_filteredHomeServices.length} Services',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Essential Services 2-Column Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _filteredHomeServices.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.search_off_rounded, size: 40, color: AppColors.textMuted),
                          const SizedBox(height: 8),
                          Text(
                            'No services match "$_searchQuery"',
                            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          TextButton(
                            onPressed: () => _searchController.clear(),
                            child: const Text('Clear search'),
                          ),
                        ],
                      ),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      int crossAxisCount = 2;
                      double childAspectRatio = 0.88;

                      if (width >= 860) {
                        crossAxisCount = 4;
                        childAspectRatio = 0.85;
                      } else if (width >= 600) {
                        crossAxisCount = 3;
                        childAspectRatio = 0.85;
                      } else {
                        crossAxisCount = 2;
                        childAspectRatio = 0.82;
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredHomeServices.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: childAspectRatio,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                        ),
                        itemBuilder: (context, index) {
                          final service = _filteredHomeServices[index];
                          return _buildServiceCard(
                            serviceId: service.id,
                            title: service.title,
                            subtitle: service.subtitle,
                            startingPrice: service.startingPrice,
                            tag: service.tag,
                            tagBgColor: service.tagBgColor,
                            tagTextColor: service.tagTextColor,
                            iconBgColor: service.cardIconBgColor,
                            icon: service.icon,
                            imageAsset: service.imageAsset,
                            imageAlignment: service.imageAlignment,
                            ctaText: service.ctaText,
                          );
                        },
                      );
                    },
                  ),
          ),

          const SizedBox(height: 28),

          // 5B. Master Sub-Services Directory Explorer
          _buildSubServicesDirectory(),

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
                  serviceId: 'plumbing',
                  title: 'Plumbing & Pipe Repair',
                  subtitle: 'Tap leakage, flush & pipe unclogging',
                  rating: '★ 4.9 (7.8k)',
                  imagePath: 'assets/images/plumbing_service.jpg',
                  imageAlignment: const Alignment(0.0, -0.4),
                ),
                const SizedBox(width: 14),
                _buildTrendingCard(
                  serviceId: 'electrician',
                  title: 'Emergency Electrical Fix',
                  subtitle: '15-min instant arrival for power faults',
                  rating: '★ 4.8 (9.2k)',
                  imagePath: 'assets/images/electrician_service.jpg',
                  imageAlignment: const Alignment(0.1, -0.3),
                ),
                const SizedBox(width: 14),
                _buildTrendingCard(
                  serviceId: 'housekeeping',
                  title: 'Deep House Cleaning',
                  subtitle: 'Kitchen, bathroom & sofa sanitization',
                  rating: '★ 4.9 (8.4k)',
                  imagePath: 'assets/images/housekeeping_service.jpg',
                  imageAlignment: const Alignment(0.0, -0.85),
                ),
                const SizedBox(width: 14),
                _buildTrendingCard(
                  serviceId: 'home_appliances',
                  title: 'AC & Fridge Servicing',
                  subtitle: 'Jet pump washing & gas level refill',
                  rating: '★ 4.8 (6.7k)',
                  imagePath: 'assets/images/home_appliances_service.jpg',
                  imageAlignment: const Alignment(0.0, -1.0),
                ),
                const SizedBox(width: 14),
                _buildTrendingCard(
                  serviceId: 'carpenter',
                  title: 'Custom Furniture Making',
                  subtitle: 'Teak wood assembly, doors & lock repair',
                  rating: '★ 4.9 (5.1k)',
                  imagePath: 'assets/images/carpenter_service.jpg',
                  imageAlignment: const Alignment(0.35, -0.7),
                ),
                const SizedBox(width: 14),
                _buildTrendingCard(
                  serviceId: 'delivery',
                  title: 'Local Same-Day Delivery',
                  subtitle: 'Express 45-min parcel & food drop',
                  rating: '★ 4.9 (11.5k)',
                  imagePath: 'assets/images/delivery_service.jpg',
                  imageAlignment: const Alignment(0.0, -0.25),
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
    ),
  ),
);
}

  List<ServiceModel> get _filteredHomeServices {
    if (_searchQuery.isEmpty) {
      return ServiceRepository.allServices;
    }
    return ServiceRepository.allServices.where((s) {
      final inTitle = s.title.toLowerCase().contains(_searchQuery);
      final inCategory = s.categoryName.toLowerCase().contains(_searchQuery);
      final inSubtitle = s.subtitle.toLowerCase().contains(_searchQuery);
      final inSubs = s.subServices.any((sub) =>
          sub.title.toLowerCase().contains(_searchQuery) ||
          sub.description.toLowerCase().contains(_searchQuery));
      return inTitle || inCategory || inSubtitle || inSubs;
    }).toList();
  }

  Widget _buildSubServicesDirectory() {
    final activeService = ServiceRepository.allServices.firstWhere(
      (s) => s.id == _selectedSubServiceCategory,
      orElse: () => ServiceRepository.allServices.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SUB-SERVICES DIRECTORY',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF854D0E),
                      letterSpacing: 0.6,
                    ),
                  ),
                  Text(
                    'Master Sub-Services',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  context.push(AppRoutes.serviceDetail, extra: {'serviceId': activeService.id});
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        'OPEN CATEGORY',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF854D0E)),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_forward_rounded, size: 13, color: Color(0xFF854D0E)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Horizontal Category Tabs
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: ServiceRepository.allServices.length,
            itemBuilder: (context, index) {
              final s = ServiceRepository.allServices[index];
              final isSelected = s.id == _selectedSubServiceCategory;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSubServiceCategory = s.id;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.textDark : AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.textDark : const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        s.icon,
                        size: 15,
                        color: isSelected ? AppColors.primaryYellow : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        s.title,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Active Category Indian Professional Showcase Banner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  activeService.imageAsset,
                  fit: BoxFit.cover,
                  alignment: activeService.imageAlignment,
                  errorBuilder: (context, error, stackTrace) => Container(color: activeService.themeBgColor),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.85),
                        Colors.black.withValues(alpha: 0.15),
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryYellow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '⚡ VERIFIED INDIAN PROS',
                          style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${activeService.title} Experts in Indiranagar',
                        style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      Text(
                        activeService.bannerNotice,
                        style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.9)),
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

        const SizedBox(height: 14),

        // 5 Sub-Services Cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: activeService.subServices.asMap().entries.map((entry) {
              final idx = entry.key;
              final sub = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
                ),
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: activeService.cardIconBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${idx + 1}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: activeService.themeColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  sub.title,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  context.push(AppRoutes.serviceDetail, extra: {'serviceId': activeService.id});
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF08A),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Book',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF854D0E),
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      const Icon(Icons.arrow_forward_rounded, size: 12, color: Color(0xFF854D0E)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sub.description,
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard({
    required String serviceId,
    required String title,
    required String subtitle,
    required String startingPrice,
    required String tag,
    required Color tagBgColor,
    required Color tagTextColor,
    required Color iconBgColor,
    required IconData icon,
    required String imageAsset,
    required String ctaText,
    Alignment imageAlignment = Alignment.center,
  }) {
    return InkWell(
      onTap: () {
        context.push(AppRoutes.serviceDetail, extra: {'serviceId': serviceId});
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indian Professional Image Showcase
            Expanded(
              flex: 11,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    imageAsset,
                    fit: BoxFit.cover,
                    alignment: imageAlignment,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: iconBgColor,
                      child: Center(child: Icon(icon, color: AppColors.textDark, size: 28)),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.28),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.2),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, color: Colors.white, size: 10),
                          const SizedBox(width: 4),
                          Text(
                            tag,
                            style: GoogleFonts.inter(fontSize: 8.5, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Starts $startingPrice • 5 Services',
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(ctaText, style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(color: AppColors.surfaceLightGray, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.textDark),
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

  Widget _buildTrendingCard({
    required String serviceId,
    required String title,
    required String subtitle,
    required String rating,
    required String imagePath,
    Alignment imageAlignment = Alignment.center,
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
                  alignment: imageAlignment,
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
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1080),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(index: 0, label: 'Home', icon: Icons.home_rounded),
            _buildNavItem(index: 1, label: 'Bookings', icon: Icons.calendar_today_rounded),
            _buildNavItem(index: 2, label: 'Profile', icon: Icons.person_outline_rounded),
          ],
        ),
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
