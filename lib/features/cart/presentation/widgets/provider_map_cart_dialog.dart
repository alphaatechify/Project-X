import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../data/cart_provider.dart';
import '../../../bookings/data/booking_provider.dart';
import '../../../bookings/domain/models/booking_model.dart';
import '../../../home/data/home_navigation_provider.dart';
import '../../../services/data/service_repository.dart';
import '../../../services/domain/models/provider_model.dart';

class ProviderMapCartDialog extends ConsumerStatefulWidget {
  final String? serviceId;
  final String? initialTaskTitle;
  final double? initialTaskPrice;

  const ProviderMapCartDialog({
    super.key,
    this.serviceId,
    this.initialTaskTitle,
    this.initialTaskPrice,
  });

  static Future<void> show(
    BuildContext context, {
    String? serviceId,
    String? initialTaskTitle,
    double? initialTaskPrice,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => ProviderMapCartDialog(
        serviceId: serviceId,
        initialTaskTitle: initialTaskTitle,
        initialTaskPrice: initialTaskPrice,
      ),
    );
  }

  @override
  ConsumerState<ProviderMapCartDialog> createState() => _ProviderMapCartDialogState();
}

class _ProviderMapCartDialogState extends ConsumerState<ProviderMapCartDialog> with SingleTickerProviderStateMixin {
  late AnimationController _radarController;
  late List<ServiceProviderModel> _allAvailableProviders;
  ServiceProviderModel? _selectedProvider;

  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'Available', 'TopRated', 'Budget', 'Nearest'
  final TextEditingController _searchController = TextEditingController();

  // Normalized map pin positions matching the user's reference image layout
  static const List<Offset> _pinCoordinates = [
    Offset(0.20, 0.22),
    Offset(0.33, 0.38),
    Offset(0.14, 0.49),
    Offset(0.21, 0.78),
    Offset(0.67, 0.69),
    Offset(0.79, 0.78),
    Offset(0.86, 0.49),
    Offset(0.78, 0.22),
  ];

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // Load providers for current service
    final sId = widget.serviceId ?? 'plumbing';
    _allAvailableProviders = ServiceRepository.getProvidersForService(sId);
    if (_allAvailableProviders.isNotEmpty) {
      _selectedProvider = _allAvailableProviders.first;
    }

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _radarController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<ServiceProviderModel> get _filteredProviders {
    return _allAvailableProviders.where((p) {
      // 1. Filter by chip
      if (_selectedFilter == 'Available' && !p.isAvailableNow) return false;
      if (_selectedFilter == 'TopRated' && p.rating < 4.8) return false;
      if (_selectedFilter == 'Nearest' && p.distanceKm > 1.2) return false;
      if (_selectedFilter == 'Budget') {
        final priceNum = double.tryParse(p.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
        if (priceNum > 199.0) return false;
      }

      // 2. Search query (provider name, specialty, service, or price)
      if (_searchQuery.isNotEmpty) {
        final matchesName = p.name.toLowerCase().contains(_searchQuery);
        final matchesSpecialty = p.specialties.any((s) => s.toLowerCase().contains(_searchQuery));
        final matchesSub = p.subCategory.toLowerCase().contains(_searchQuery);
        final matchesPrice = p.price.toLowerCase().contains(_searchQuery);
        if (!matchesName && !matchesSpecialty && !matchesSub && !matchesPrice) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final cartSubtotal = ref.watch(cartSubtotalProvider);
    final cartTotalCount = ref.watch(cartTotalCountProvider);

    final double activeSubtotal = cartItems.isNotEmpty
        ? cartSubtotal
        : (widget.initialTaskPrice ?? 199.0);
    final double totalPayable = activeSubtotal + 49.0;

    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = math.min(screenSize.width * 0.94, 640.0);
    final dialogHeight = math.min(screenSize.height * 0.90, 780.0);

    final filteredList = _filteredProviders;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            // 1. Popup Dialog Header
            _buildDialogHeader(context),

            // 2. Interactive Map Section (Inspired by User's Reference Image)
            _buildMapSection(filteredList),

            // 3. Search & Live Filter Chips
            _buildSearchAndFilters(filteredList.length),

            // 4. Providers List (Plumber Name, Service, Price, Rating, Distance)
            Expanded(
              child: _buildProvidersList(filteredList),
            ),

            // 5. Bottom Booking & Cart Footer
            _buildBottomBar(context, totalPayable, cartTotalCount),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.primaryYellow.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.radar_rounded, size: 20, color: AppColors.textDark),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nearby Providers Radar',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  'Matching verified experts near Indiranagar, Bengaluru',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, size: 22, color: AppColors.textDark),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(List<ServiceProviderModel> providers) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mapWidth = constraints.maxWidth;
        return Container(
          height: 220,
          width: double.infinity,
          color: const Color(0xFFFAF7F2), // Warm ivory map background matching reference image
          child: ClipRect(
            child: Stack(
              children: [
                // Grid and road background painter
                CustomPaint(
                  size: Size(mapWidth, 220),
                  painter: _MinimalistMapPainter(),
                ),

                // Top floating pill: "✦ Your lead assistant" (matching reference image)
                Positioned(
                  top: 14,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827), // Sleek dark pill
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.22),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome, size: 13, color: Color(0xFFFFB74D)),
                          const SizedBox(width: 6),
                          Text(
                            'Your lead assistant',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Central User Location Pin with Animated Radar Waves & "Every street" chip
                Positioned(
                  top: 75,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Center Red Location Pin with Radar Ripples
                        AnimatedBuilder(
                          animation: _radarController,
                          builder: (context, child) {
                            return SizedBox(
                              width: 80,
                              height: 55,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer expanding ripple 1
                                  Transform.scale(
                                    scale: 0.6 + (_radarController.value * 0.9),
                                    child: Container(
                                      width: 65,
                                      height: 65,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFFEF4444).withValues(alpha: (1.0 - _radarController.value) * 0.4),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Outer expanding ripple 2 (offset)
                                  Transform.scale(
                                    scale: 0.4 + (((_radarController.value + 0.5) % 1.0) * 0.8),
                                    child: Container(
                                      width: 55,
                                      height: 55,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFFEF4444).withValues(alpha: (1.0 - ((_radarController.value + 0.5) % 1.0)) * 0.3),
                                          width: 1.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Pin Drop Shadow
                                  Positioned(
                                    bottom: 2,
                                    child: Container(
                                      width: 16,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  // Central Red Location Pin Marker
                                  const Positioned(
                                    top: 4,
                                    child: Icon(
                                      Icons.location_on_rounded,
                                      size: 40,
                                      color: Color(0xFFDC2626), // Bold vibrant red matching reference
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        // "Every street" White Pill Label (Directly from User Reference Image)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Every street',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Scattered Red Location Pin Markers (Nearby Providers matching reference layout)
                ...List.generate(math.min(providers.length, _pinCoordinates.length), (index) {
                  final provider = providers[index];
                  final coord = _pinCoordinates[index];
                  final isSelected = _selectedProvider?.id == provider.id;

                  return Positioned(
                    left: coord.dx * (mapWidth - 40),
                    top: coord.dy * 200,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedProvider = provider;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutBack,
                        transform: isSelected ? Matrix4.diagonal3Values(1.2, 1.2, 1.0) : Matrix4.identity(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Tooltip when selected: Provider name & price
                            if (isSelected)
                              Container(
                                margin: const EdgeInsets.only(bottom: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.25),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '${provider.name.split(' ').first} • ${provider.price}',
                                  style: GoogleFonts.inter(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                            // Red map pin marker
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                if (isSelected)
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                                    ),
                                  ),
                                Icon(
                                  Icons.location_on_rounded,
                                  size: isSelected ? 26 : 21,
                                  color: isSelected ? const Color(0xFFB91C1C) : const Color(0xFFDC2626),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchAndFilters(int matchCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
            ),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'Search plumber name, service, or price...',
                hintStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textSecondary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 9),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Horizontal Filter Chips & Matches Counter
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'All'),
                      const SizedBox(width: 6),
                      _buildFilterChip('Available', '⚡ Available Now'),
                      const SizedBox(width: 6),
                      _buildFilterChip('TopRated', '★ 4.8+ Top Rated'),
                      const SizedBox(width: 6),
                      _buildFilterChip('Budget', 'Under ₹200'),
                      const SizedBox(width: 6),
                      _buildFilterChip('Nearest', '< 1.2 km'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$matchCount Found',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0369A1),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = key;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryYellow : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFCA8A04) : const Color(0xFFCBD5E1),
            width: isSelected ? 1.2 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildProvidersList(List<ServiceProviderModel> providers) {
    if (providers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_search_outlined, size: 40, color: AppColors.textSecondary),
            const SizedBox(height: 8),
            Text(
              'No providers found matching your filter',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try resetting search or filters to see nearby professionals',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: providers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final provider = providers[index];
        final isSelected = _selectedProvider?.id == provider.id;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedProvider = provider;
            });
          },
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFEFCE8) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? const Color(0xFFEAB308) : const Color(0xFFE2E8F0),
                width: isSelected ? 1.8 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? const Color(0xFFEAB308).withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // 1. Provider Avatar with Online Pulse & Initials
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: provider.avatarBgColor,
                      child: Text(
                        provider.avatarInitials,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (provider.isAvailableNow)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),

                // 2. Name, Service Title, Location & Distance
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              provider.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF08A),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '★ ${provider.rating}',
                              style: GoogleFonts.inter(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF854D0E),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),

                      // Service Specialization
                      Text(
                        provider.specialties.isNotEmpty
                            ? '${provider.subCategory} • ${provider.specialties.first}'
                            : provider.subCategory,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0284C7),
                        ),
                      ),
                      const SizedBox(height: 3),

                      // Distance, Reviews & Area
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textMuted),
                          const SizedBox(width: 2),
                          Text(
                            '${provider.formattedDistance} • ${provider.locationArea}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // 3. Price & Radio Selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      provider.price,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF15803D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFEAB308) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected)
                            const Icon(Icons.check_rounded, size: 12, color: Color(0xFF1E293B)),
                          Text(
                            isSelected ? 'Selected' : 'Select',
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF475569),
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
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context, double totalPayable, int cartTotalCount) {
    final provider = _selectedProvider;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Order Summary row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified_user_rounded, size: 16, color: Color(0xFF15803D)),
                  const SizedBox(width: 6),
                  Text(
                    provider != null
                        ? 'Assigned: ${provider.name} (${provider.formattedDistance})'
                        : 'Select a verified provider above',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              Text(
                'Total: ₹${totalPayable.toStringAsFixed(0)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF15803D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Primary Action CTA
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                final chosenProvider = provider ?? _allAvailableProviders.first;
                final cartItems = ref.read(cartProvider);
                final List<BookingItem> items = cartItems.isNotEmpty
                    ? cartItems
                        .map((c) => BookingItem(
                              title: c.title,
                              quantity: c.quantity,
                              price: c.price,
                            ))
                        .toList()
                    : [
                        BookingItem(
                          title: widget.initialTaskTitle ?? '${chosenProvider.subCategory} Service',
                          quantity: 1,
                          price: totalPayable,
                        ),
                      ];

                ref.read(bookingsProvider.notifier).createBooking(
                  provider: chosenProvider,
                  serviceTitle: widget.initialTaskTitle ?? chosenProvider.subCategory,
                  serviceCategory: widget.serviceId ?? chosenProvider.serviceId,
                  serviceIcon: chosenProvider.serviceId == 'plumbing'
                      ? Icons.plumbing_rounded
                      : chosenProvider.serviceId == 'electrician'
                          ? Icons.bolt_rounded
                          : chosenProvider.serviceId == 'cleaning'
                              ? Icons.cleaning_services_rounded
                              : Icons.home_repair_service_rounded,
                  totalAmount: totalPayable,
                  items: items,
                );

                ref.read(cartProvider.notifier).clearCart();

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Request Accepted by ${chosenProvider.name}! Live details added to your Bookings.',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFF15803D),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    duration: const Duration(seconds: 5),
                    action: SnackBarAction(
                      label: 'VIEW',
                      textColor: AppColors.primaryYellow,
                      onPressed: () {
                        ref.read(homeBottomNavIndexProvider.notifier).state = 1;
                      },
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: AppColors.textDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flash_on_rounded, size: 18, color: AppColors.textDark),
                  const SizedBox(width: 6),
                  Text(
                    provider != null
                        ? 'Confirm & Book with ${provider.name.split(' ').first} (₹${totalPayable.toStringAsFixed(0)})'
                        : 'Confirm & Book Nearby Provider →',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
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
}

/// Custom map canvas painter faithfully recreating the minimalist cream map,
/// subtle road curve and grid matrix from the user's reference image!
class _MinimalistMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Warm Cream background
    final bgPaint = Paint()..color = const Color(0xFFF9F7F2);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Subtle Grid Matrix Lines
    final gridPaint = Paint()
      ..color = const Color(0xFFEFE9DE)
      ..strokeWidth = 1.0;

    const double gridSpacing = 52.0;
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 3. Winding Highway Road (as seen in the reference image)
    final roadPath = Path();
    roadPath.moveTo(0, size.height * 0.76);
    roadPath.cubicTo(
      size.width * 0.35, size.height * 0.62,
      size.width * 0.45, size.height * 0.48,
      size.width * 0.65, size.height * 0.46,
    );
    roadPath.cubicTo(
      size.width * 0.85, size.height * 0.44,
      size.width * 0.92, size.height * 0.28,
      size.width, size.height * 0.20,
    );

    // Road outer border
    final roadBorderPaint = Paint()
      ..color = const Color(0xFFDDD6C9)
      ..strokeWidth = 15.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(roadPath, roadBorderPaint);

    // Road inner clean white fill
    final roadFillPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 11.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(roadPath, roadFillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
