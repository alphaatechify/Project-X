import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_x/app/theme/app_colors.dart';
import '../../data/service_repository.dart';
import '../../domain/models/provider_model.dart';
import '../../domain/models/service_model.dart';
import '../widgets/booking_bottom_sheet.dart';
import '../widgets/provider_card.dart';
import '../widgets/provider_detail_modal.dart';
import '../widgets/service_filter_bottom_sheet.dart';

class ServiceDetailScreen extends StatefulWidget {
  final String serviceId;

  const ServiceDetailScreen({
    super.key,
    required this.serviceId,
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  late ServiceModel _service;
  late List<ServiceProviderModel> _allProviders;
  late String _selectedSubCategory;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _availableNowOnly = false;
  double _minRating = 0.0;
  double _maxDistanceKm = 10.0;
  String _sortBy = 'Distance';

  @override
  void initState() {
    super.initState();
    _service = ServiceRepository.getServiceById(widget.serviceId);
    _allProviders = ServiceRepository.getProvidersForService(_service.id);
    _selectedSubCategory = _service.subCategories.first;
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ServiceProviderModel> get _filteredProviders {
    var filtered = _allProviders.where((p) {
      // 1. Subcategory filter
      if (_selectedSubCategory != 'All' && p.subCategory.toLowerCase() != _selectedSubCategory.toLowerCase()) {
        // Also allow if specialty matches
        final matchesSpecialty = p.specialties.any((s) => s.toLowerCase().contains(_selectedSubCategory.toLowerCase()));
        if (!matchesSpecialty) return false;
      }

      // 2. Search query filter
      if (_searchQuery.isNotEmpty) {
        final matchesName = p.name.toLowerCase().contains(_searchQuery);
        final matchesSub = p.subCategory.toLowerCase().contains(_searchQuery);
        final matchesSpecialty = p.specialties.any((s) => s.toLowerCase().contains(_searchQuery));
        if (!matchesName && !matchesSub && !matchesSpecialty) return false;
      }

      // 3. Availability filter
      if (_availableNowOnly && !p.isAvailableNow) return false;

      // 4. Rating filter
      if (p.rating < _minRating) return false;

      // 5. Distance filter
      if (p.distanceKm > _maxDistanceKm) return false;

      return true;
    }).toList();

    // Sorting
    if (_sortBy == 'Distance') {
      filtered.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    } else if (_sortBy == 'Rating') {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_sortBy == 'Experience') {
      filtered.sort((a, b) => b.experienceYears.compareTo(a.experienceYears));
    } else if (_sortBy == 'Price') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    }

    return filtered;
  }

  void _openFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => ServiceFilterBottomSheet(
        availableNowOnly: _availableNowOnly,
        minRating: _minRating,
        maxDistanceKm: _maxDistanceKm,
        sortBy: _sortBy,
        onApplyFilters: (availableNow, rating, distance, sort) {
          setState(() {
            _availableNowOnly = availableNow;
            _minRating = rating;
            _maxDistanceKm = distance;
            _sortBy = sort;
          });
        },
      ),
    );
  }

  void _openProviderDetail(ServiceProviderModel provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => ProviderDetailModal(
        provider: provider,
        service: _service,
        onBookNow: () => _openBookingSheet(provider),
      ),
    );
  }

  void _openBookingSheet(ServiceProviderModel provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => BookingBottomSheet(
        service: _service,
        provider: provider,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final providers = _filteredProviders;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            _buildAppBar(),

            // Scrollable Content
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Hero Header Banner tailored to the service
                  SliverToBoxAdapter(
                    child: _buildHeroBanner(),
                  ),

                  // Search & Filter Row
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceWhite,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Row(
                                children: [
                                  const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600),
                                      decoration: InputDecoration(
                                        hintText: 'Search ${_service.title} pros, skills...',
                                        hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                                        border: InputBorder.none,
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  if (_searchQuery.isNotEmpty)
                                    GestureDetector(
                                      onTap: () => _searchController.clear(),
                                      child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Filter Button
                          InkWell(
                            onTap: _openFilterModal,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: (_availableNowOnly || _minRating > 0 || _sortBy != 'Distance')
                                    ? AppColors.primaryYellow
                                    : AppColors.surfaceWhite,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                              ),
                              child: const Icon(Icons.tune_rounded, color: AppColors.textDark, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Sub-Categories Horizontal Pills
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _service.subCategories.length,
                        itemBuilder: (context, index) {
                          final category = _service.subCategories[index];
                          final isSelected = _selectedSubCategory == category;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSubCategory = category;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.textDark : AppColors.surfaceWhite,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? AppColors.textDark : const Color(0xFFE2E8F0),
                                  width: 1.2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  category,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected ? Colors.white : AppColors.textDark,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Section Title: Available Professionals Count
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'PROS NEAR YOU (${providers.length})',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.6,
                            ),
                          ),
                          Text(
                            'Sorted by: $_sortBy',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF854D0E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Provider Cards List
                  if (providers.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            const Icon(Icons.search_off_rounded, size: 54, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            Text(
                              'No professionals found',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try adjusting your search query or reset filters',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _selectedSubCategory = 'All';
                                  _availableNowOnly = false;
                                  _minRating = 0.0;
                                  _maxDistanceKm = 10.0;
                                  _sortBy = 'Distance';
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryYellow,
                                foregroundColor: AppColors.textDark,
                              ),
                              child: const Text('Reset All Filters'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final provider = providers[index];
                            return ProviderCard(
                              provider: provider,
                              onViewProfile: () => _openProviderDetail(provider),
                              onBookNow: () => _openBookingSheet(provider),
                            );
                          },
                          childCount: providers.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textDark),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _service.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  _service.categoryName,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Service saved to favorites')),
              );
            },
            icon: const Icon(Icons.bookmark_border_rounded, size: 22, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: _service.themeBgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _service.themeColor.withValues(alpha: 0.2), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: _service.themeColor.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _service.themeColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Icon(_service.icon, color: Colors.white, size: 24),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _service.tagBgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _service.tag,
                              style: GoogleFonts.inter(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: _service.tagTextColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.star_rounded, size: 14, color: Color(0xFFD97706)),
                          const SizedBox(width: 2),
                          Text(
                            '${_service.rating}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            ' (${_service.totalReviews})',
                            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _service.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'STARTING AT',
                      style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.textMuted),
                    ),
                    Text(
                      _service.startingPrice,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _service.themeColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            Text(
              _service.fullDescription,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: AppColors.textDark.withValues(alpha: 0.85),
                height: 1.45,
              ),
            ),

            const SizedBox(height: 14),

            // Highlights Row
            Column(
              children: _service.highlights.map((highlight) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, size: 14, color: _service.themeColor),
                      const SizedBox(width: 6),
                      Text(
                        highlight,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // Notice Banner Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _service.themeColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _service.bannerNotice,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Text(
                    'ETA: ${_service.avgEta}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _service.themeColor,
                    ),
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
