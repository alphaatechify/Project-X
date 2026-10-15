import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_x/app/theme/app_colors.dart';
import 'package:project_x/features/cart/data/cart_provider.dart';
import 'package:project_x/features/cart/presentation/widgets/cart_bottom_sheet.dart';
import '../../data/service_repository.dart';
import '../../domain/models/provider_model.dart';
import '../../domain/models/service_model.dart';
import '../widgets/booking_bottom_sheet.dart';
import '../widgets/provider_card.dart';
import '../widgets/provider_detail_modal.dart';
import '../widgets/service_filter_bottom_sheet.dart';

class ServiceDetailScreen extends ConsumerStatefulWidget {
  final String serviceId;

  const ServiceDetailScreen({
    super.key,
    required this.serviceId,
  });

  @override
  ConsumerState<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends ConsumerState<ServiceDetailScreen> {
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
    final totalCartCount = ref.watch(cartTotalCountProvider);
    final subtotal = ref.watch(cartSubtotalProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: totalCartCount > 0 ? _buildStickyCartBar(totalCartCount, subtotal) : null,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
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

                  // Top 5 Master Services Included
                  if (_service.subServices.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'TOP 5 SERVICES INCLUDED',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF854D0E),
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                Text(
                                  '5 Specializations',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ...List.generate(_service.subServices.length, (index) {
                              final sub = _service.subServices[index];
                              final isSelected = _selectedSubCategory.toLowerCase() == sub.title.toLowerCase();

                              // Resolve sub-sub service tasks
                              final List<SubSubServiceItem> subTasks = sub.subSubServices.isNotEmpty
                                  ? sub.subSubServices
                                  : (sub.includedItems.isNotEmpty
                                      ? sub.includedItems.map((inc) {
                                          return SubSubServiceItem(
                                            id: '${sub.effectiveId}_${inc.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}',
                                            title: inc,
                                            description: 'Service & fitment for $inc',
                                            price: sub.price.isNotEmpty ? sub.price : '₹199',
                                            priceNumber: sub.priceNumber > 0 ? sub.priceNumber : 199.0,
                                            timeEstimate: '30 mins',
                                          );
                                        }).toList()
                                      : [
                                          SubSubServiceItem(
                                            id: sub.effectiveId,
                                            title: sub.title,
                                            description: sub.description,
                                            price: sub.price.isNotEmpty ? sub.price : '₹249',
                                            priceNumber: sub.priceNumber > 0 ? sub.priceNumber : 249.0,
                                            timeEstimate: '30-45 mins',
                                          ),
                                        ]);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isSelected ? _service.themeBgColor : AppColors.surfaceWhite,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? _service.themeColor : const Color(0xFFE2E8F0),
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 1. SubService Header (Image + Title + Description - NO Add button on main header)
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedSubCategory = sub.title;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Distinct thumbnail image
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(14),
                                            child: Container(
                                              width: 74,
                                              height: 74,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF1F5F9),
                                                borderRadius: BorderRadius.circular(14),
                                                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withValues(alpha: 0.04),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Image.asset(
                                                sub.imageUrl.isNotEmpty ? sub.imageUrl : _service.imageAsset,
                                                width: 74,
                                                height: 74,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => Icon(_service.icon, size: 30, color: _service.themeColor),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 14),

                                          // Title and Description
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        sub.title,
                                                        style: GoogleFonts.plusJakartaSans(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.w800,
                                                          color: AppColors.textDark,
                                                        ),
                                                      ),
                                                    ),
                                                    if (isSelected)
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: _service.themeColor,
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: Text(
                                                          'SELECTED',
                                                          style: GoogleFonts.inter(fontSize: 8.5, fontWeight: FontWeight.w800, color: Colors.white),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  sub.description,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 11.5,
                                                    color: AppColors.textSecondary,
                                                    height: 1.3,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFEFF6FF),
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(color: const Color(0xFFBFDBFE), width: 0.8),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(Icons.touch_app_rounded, size: 12, color: Color(0xFF1D4ED8)),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${subTasks.length} services available below',
                                                        style: GoogleFonts.inter(
                                                          fontSize: 9.5,
                                                          fontWeight: FontWeight.w700,
                                                          color: const Color(0xFF1D4ED8),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // 2. Sub-sub services List (Each item has title, price, and ADD TO CART / Stepper)
                                    const SizedBox(height: 12),
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(12, 9, 12, 7),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.playlist_add_check_rounded, size: 16, color: Color(0xFF0369A1)),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'CHOOSE SERVICES TO ADD TO CART:',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w800,
                                                    color: const Color(0xFF0369A1),
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

                                          ...List.generate(subTasks.length, (taskIndex) {
                                            final task = subTasks[taskIndex];
                                            final taskId = task.effectiveId;
                                            final taskCartQty = ref.watch(cartProvider)
                                                .where((item) => item.id == taskId || item.title == task.title)
                                                .firstOrNull?.quantity ?? 0;
                                            final isLast = taskIndex == subTasks.length - 1;

                                            return Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                                              decoration: BoxDecoration(
                                                color: taskCartQty > 0 ? const Color(0xFFF0FDF4) : Colors.transparent,
                                                border: isLast
                                                    ? null
                                                    : const Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 0.8)),
                                              ),
                                              child: Row(
                                                children: [
                                                  // Icon
                                                  Container(
                                                    width: 26,
                                                    height: 26,
                                                    decoration: BoxDecoration(
                                                      color: taskCartQty > 0 ? const Color(0xFFDCFCE7) : Colors.white,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: taskCartQty > 0 ? const Color(0xFF86EFAC) : const Color(0xFFCBD5E1),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Icon(
                                                        taskCartQty > 0 ? Icons.check_rounded : Icons.build_outlined,
                                                        size: 13,
                                                        color: taskCartQty > 0 ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),

                                                  // Task Title & Duration
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          task.title,
                                                          style: GoogleFonts.plusJakartaSans(
                                                            fontSize: 12.5,
                                                            fontWeight: FontWeight.w700,
                                                            color: AppColors.textDark,
                                                          ),
                                                        ),
                                                        if (task.description.isNotEmpty) ...[
                                                          const SizedBox(height: 2),
                                                          Text(
                                                            task.description,
                                                            style: GoogleFonts.inter(
                                                              fontSize: 10.5,
                                                              color: AppColors.textSecondary,
                                                              height: 1.25,
                                                            ),
                                                          ),
                                                        ],
                                                        const SizedBox(height: 2),
                                                        Row(
                                                          children: [
                                                            const Icon(Icons.schedule_rounded, size: 10, color: AppColors.textMuted),
                                                            const SizedBox(width: 3),
                                                            Text(
                                                              task.timeEstimate,
                                                              style: GoogleFonts.inter(
                                                                fontSize: 9.5,
                                                                fontWeight: FontWeight.w500,
                                                                color: AppColors.textMuted,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),

                                                  // Price & Add to Cart Stepper
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        task.price,
                                                        style: GoogleFonts.plusJakartaSans(
                                                          fontSize: 13.5,
                                                          fontWeight: FontWeight.w900,
                                                          color: const Color(0xFF15803D),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      taskCartQty == 0
                                                          ? InkWell(
                                                              onTap: () {
                                                                ref.read(cartProvider.notifier).addItem(
                                                                  id: taskId,
                                                                  title: task.title,
                                                                  serviceCategory: '${_service.title} • ${sub.title}',
                                                                  price: task.priceNumber,
                                                                  priceFormatted: task.price,
                                                                  imageUrl: sub.imageUrl.isNotEmpty ? sub.imageUrl : _service.imageAsset,
                                                                );
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  SnackBar(
                                                                    content: Text(
                                                                      'Added "${task.title}" (${task.price}) to cart!',
                                                                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                                                    ),
                                                                    backgroundColor: const Color(0xFF15803D),
                                                                    behavior: SnackBarBehavior.floating,
                                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                    duration: const Duration(milliseconds: 1400),
                                                                  ),
                                                                );
                                                              },
                                                              borderRadius: BorderRadius.circular(8),
                                                              child: Container(
                                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                decoration: BoxDecoration(
                                                                  color: AppColors.primaryYellow,
                                                                  borderRadius: BorderRadius.circular(8),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: AppColors.primaryYellow.withValues(alpha: 0.35),
                                                                      blurRadius: 3,
                                                                      offset: const Offset(0, 1.5),
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: Row(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    const Icon(Icons.add_rounded, size: 14, color: AppColors.textDark),
                                                                    const SizedBox(width: 2),
                                                                    Text(
                                                                      'ADD',
                                                                      style: GoogleFonts.plusJakartaSans(
                                                                        fontSize: 10.5,
                                                                        fontWeight: FontWeight.w900,
                                                                        color: AppColors.textDark,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            )
                                                          : Container(
                                                              decoration: BoxDecoration(
                                                                color: const Color(0xFF0F172A),
                                                                borderRadius: BorderRadius.circular(8),
                                                              ),
                                                              child: Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  InkWell(
                                                                    onTap: () {
                                                                      ref.read(cartProvider.notifier).decrement(taskId);
                                                                    },
                                                                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                                                                    child: const Padding(
                                                                      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                                                                      child: Icon(Icons.remove_rounded, size: 13, color: Colors.white),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                                    child: Text(
                                                                      '$taskCartQty',
                                                                      style: GoogleFonts.plusJakartaSans(
                                                                        fontSize: 11.5,
                                                                        fontWeight: FontWeight.w800,
                                                                        color: Colors.white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  InkWell(
                                                                    onTap: () {
                                                                      ref.read(cartProvider.notifier).increment(taskId);
                                                                    },
                                                                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                                                                    child: const Padding(
                                                                      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                                                                      child: Icon(Icons.add_rounded, size: 13, color: Colors.white),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
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
                    SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.crossAxisExtent >= 740;
                        if (isDesktop) {
                          return SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverGrid(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 0,
                                crossAxisSpacing: 14,
                                mainAxisExtent: 290,
                              ),
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
                          );
                        } else {
                          return SliverPadding(
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
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
}

  Widget _buildAppBar() {
    final cartCount = ref.watch(cartTotalCountProvider);

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
          // Cart Button with Live Badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () => CartBottomSheet.show(context, serviceId: _service.id),
                icon: const Icon(Icons.shopping_cart_outlined, size: 22, color: AppColors.textDark),
                tooltip: 'Cart',
              ),
              if (cartCount > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryYellow,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$cartCount',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ),
            ],
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

  Widget _buildStickyCartBar(int totalCount, double subtotal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$totalCount ${totalCount == 1 ? 'ITEM' : 'ITEMS'} IN CART',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '₹${subtotal.toStringAsFixed(0)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF15803D),
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => CartBottomSheet.show(context, serviceId: _service.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: AppColors.textDark,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Row(
                children: [
                  const Icon(Icons.shopping_cart_rounded, size: 16, color: AppColors.textDark),
                  const SizedBox(width: 6),
                  Text(
                    'View Cart →',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
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
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 720;
            if (isDesktop) {
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left details column
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: _buildHeroDetailsContent(),
                      ),
                    ),
                    // Right image column
                    if (_service.imageAsset.isNotEmpty)
                      SizedBox(
                        width: 320,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              _service.imageAsset,
                              fit: BoxFit.cover,
                              alignment: _service.imageAlignment,
                              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    _service.themeBgColor.withValues(alpha: 0.85),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 14,
                              right: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.72),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 14),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Verified Indian Pro',
                                      style: GoogleFonts.inter(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
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
              );
            } else {
              // Mobile stacked layout
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_service.imageAsset.isNotEmpty)
                    Stack(
                      children: [
                        Image.asset(
                          _service.imageAsset,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          alignment: _service.imageAlignment,
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.15),
                                  _service.themeBgColor.withValues(alpha: 0.95),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 14),
                                const SizedBox(width: 5),
                                Text(
                                  'Verified Indian Pro',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildHeroDetailsContent(),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildHeroDetailsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
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
    );
  }
}
