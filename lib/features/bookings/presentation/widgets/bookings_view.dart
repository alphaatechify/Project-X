import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../data/booking_provider.dart';
import '../../domain/models/booking_model.dart';
import '../../../home/data/home_navigation_provider.dart';
import '../../../services/data/service_repository.dart';
import '../../../services/domain/models/provider_model.dart';
import '../../../services/presentation/widgets/provider_detail_modal.dart';
import '../../../cart/presentation/widgets/provider_map_cart_dialog.dart';

class BookingsView extends ConsumerStatefulWidget {
  const BookingsView({super.key});

  @override
  ConsumerState<BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends ConsumerState<BookingsView> {
  int _selectedFilterIndex = 0; // 0: All, 1: Active, 2: Completed, 3: Cancelled
  final TextEditingController _searchController = TextEditingController();
  final List<String> _filters = ['All', 'Active', 'Completed', 'Cancelled'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allBookings = ref.watch(bookingsProvider);
    final activeCount = allBookings.where((b) => b.isActive).length;
    final completedCount = allBookings.where((b) => b.isCompleted).length;
    final cancelledCount = allBookings.where((b) => b.isCancelled).length;

    // Filter by query and tab
    final query = _searchController.text.trim().toLowerCase();
    final filteredBookings = allBookings.where((b) {
      if (_selectedFilterIndex == 1 && !b.isActive) return false;
      if (_selectedFilterIndex == 2 && !b.isCompleted) return false;
      if (_selectedFilterIndex == 3 && !b.isCancelled) return false;

      if (query.isNotEmpty) {
        final matchId = b.id.toLowerCase().contains(query);
        final matchService = b.serviceTitle.toLowerCase().contains(query);
        final matchProvider = b.provider.name.toLowerCase().contains(query);
        return matchId || matchService || matchProvider;
      }
      return true;
    }).toList();

    final activeBookings = filteredBookings.where((b) => b.isActive).toList();
    final pastBookings = filteredBookings.where((b) => !b.isActive).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // 1. Top Header Row
              _buildTopHeader(activeCount),

              const SizedBox(height: 14),

              // 2. Search Box Row
              _buildSearchBar(),

              const SizedBox(height: 12),

              // 3. Category Filter Chips with dynamic counts
              _buildFilterChips(
                totalCount: allBookings.length,
                activeCount: activeCount,
                completedCount: completedCount,
                cancelledCount: cancelledCount,
              ),

              const SizedBox(height: 18),

              // If everything is filtered out
              if (filteredBookings.isEmpty)
                _buildEmptyState()
              else ...[
                // 4. SECTION 1: Service Provider Accepted Request (Active Booking Cards)
                if (activeBookings.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ACCEPTED & LIVE REQUESTS',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: const Color(0xFF0F766E),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${activeBookings.length} Active',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final booking in activeBookings)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: _buildActiveAcceptedBookingCard(booking),
                    ),
                  const SizedBox(height: 18),
                ],

                // 5. SECTION 2: Customer History (Past Bookings)
                if (pastBookings.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(Icons.history_rounded, size: 18, color: AppColors.textDark),
                        const SizedBox(width: 8),
                        Text(
                          'Customer Booking History',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${pastBookings.length} Bookings',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth >= 680;
                        if (isDesktop) {
                          final itemWidth = (constraints.maxWidth - 14) / 2;
                          return Wrap(
                            spacing: 14,
                            runSpacing: 14,
                            children: pastBookings.map((booking) {
                              return SizedBox(
                                width: itemWidth,
                                child: _buildHistoryBookingCard(booking),
                              );
                            }).toList(),
                          );
                        } else {
                          return Column(
                            children: pastBookings.map((booking) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildHistoryBookingCard(booking),
                              );
                            }).toList(),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 24),

              // 6. Service Assurance & Support Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSupportBanner(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Top Header ---
  Widget _buildTopHeader(int activeCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryYellow.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.assignment_turned_in_rounded, color: AppColors.primaryYellowDark, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Bookings',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Live accepted requests & service history',
                style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: activeCount > 0 ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: activeCount > 0 ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: activeCount > 0 ? const Color(0xFF16A34A) : AppColors.textMuted,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$activeCount Active',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: activeCount > 0 ? const Color(0xFF15803D) : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Search Bar ---
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'Search by provider name, booking ID, service...',
                        hintStyle: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textMuted),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Filter Chips ---
  Widget _buildFilterChips({
    required int totalCount,
    required int activeCount,
    required int completedCount,
    required int cancelledCount,
  }) {
    final counts = [totalCount, activeCount, completedCount, cancelledCount];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedFilterIndex == index;
          return InkWell(
            onTap: () {
              setState(() {
                _selectedFilterIndex = index;
              });
            },
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.textDark : AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? AppColors.textDark : const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    _filters[index],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withValues(alpha: 0.25) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${counts[index]}',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ===========================================================================
  // SECTION 1: ACTIVE / ACCEPTED SERVICE PROVIDER CARD
  // Shows service provider who accepted request + security OTP + live ETA + call/chat
  // ===========================================================================
  Widget _buildActiveAcceptedBookingCard(BookingModel booking) {
    final provider = booking.provider;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF10B981), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.22),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Live Accepted Banner Header - High-Contrast Confirmed Highlight
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF047857), Color(0xFF059669), Color(0xFF0D9488)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(17),
                topRight: Radius.circular(17),
              ),
            ),
            child: Row(
              children: [
                // Prominent Confirmed Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'CONFIRMED',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                          color: const Color(0xFF065F46),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'REQUEST ACCEPTED & EN ROUTE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, size: 13, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'ETA: ${booking.etaMinutes}m',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 640;
                if (isDesktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Provider Info, Quick Actions, Security OTP
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildActiveProviderInfo(provider),
                            const SizedBox(height: 12),
                            _buildActiveQuickActions(provider, booking),
                            const SizedBox(height: 12),
                            _buildActiveOtpBox(booking),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Right Column: Progress Stepper, Details, Status simulation, Footer
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLiveProgressStepper(booking.status),
                            const SizedBox(height: 12),
                            _buildActiveServiceCost(booking),
                            const SizedBox(height: 12),
                            _buildActiveStatusSimulator(booking),
                            const SizedBox(height: 10),
                            _buildActiveCardFooter(booking),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildActiveProviderInfo(provider),
                      const SizedBox(height: 12),
                      _buildActiveQuickActions(provider, booking),
                      const SizedBox(height: 14),
                      _buildActiveOtpBox(booking),
                      const SizedBox(height: 14),
                      _buildLiveProgressStepper(booking.status),
                      const SizedBox(height: 14),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      const SizedBox(height: 12),
                      _buildActiveServiceCost(booking),
                      const SizedBox(height: 12),
                      _buildActiveStatusSimulator(booking),
                      const SizedBox(height: 10),
                      _buildActiveCardFooter(booking),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper 1: Provider Profile Snippet ---
  Widget _buildActiveProviderInfo(ServiceProviderModel provider) {
    return InkWell(
      onTap: () {
        final service = ServiceRepository.allServices.firstWhere(
          (s) => s.id == provider.serviceId,
          orElse: () => ServiceRepository.allServices.first,
        );
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => ProviderDetailModal(
            provider: provider,
            service: service,
            onBookNow: () => Navigator.pop(ctx),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Provider Avatar with Verified Badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: provider.avatarBgColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      provider.avatarInitials,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 12, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            // Provider Info Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          provider.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF08A),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 13, color: Color(0xFF854D0E)),
                            const SizedBox(width: 3),
                            Text(
                              '${provider.rating}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF854D0E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    provider.qualifications.isNotEmpty
                        ? provider.qualifications
                        : 'Certified Service Specialist • ${provider.jobsCompleted}+ Jobs',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.navigation_rounded, size: 12, color: Color(0xFF0F766E)),
                      const SizedBox(width: 4),
                      Text(
                        '${provider.formattedDistance} • ${provider.locationArea}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F766E),
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

  // --- Helper 2: Quick Action Buttons ---
  Widget _buildActiveQuickActions(ServiceProviderModel provider, BookingModel booking) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showCallDialog(provider),
            icon: const Icon(Icons.phone_in_talk_rounded, size: 15, color: Color(0xFF15803D)),
            label: Text(
              'Call Provider',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF15803D),
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFFF0FDF4),
              side: const BorderSide(color: Color(0xFFBBF7D0)),
              padding: const EdgeInsets.symmetric(vertical: 9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showChatDialog(provider),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15, color: AppColors.textDark),
            label: Text(
              'Message',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.surfaceWhite,
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              padding: const EdgeInsets.symmetric(vertical: 9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () {
            ProviderMapCartDialog.show(
              context,
              serviceId: booking.serviceId,
              initialTaskTitle: booking.serviceTitle,
              initialTaskPrice: booking.totalAmount,
            );
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.primaryYellow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.map_rounded, size: 18, color: AppColors.textDark),
          ),
        ),
      ],
    );
  }

  // --- Helper 3: Service Start Security OTP ---
  Widget _buildActiveOtpBox(BookingModel booking) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFCE8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFEF08A), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryYellow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.key_rounded, size: 18, color: AppColors.textDark),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SERVICE START OTP',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: const Color(0xFF854D0E),
                  ),
                ),
                Text(
                  'Share only when provider arrives at your home',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: const Color(0xFF713F12),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF18181B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              booking.serviceOtp,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                color: AppColors.primaryYellow,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper 4: Service & Cost Details ---
  Widget _buildActiveServiceCost(BookingModel booking) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(booking.serviceIcon, size: 18, color: AppColors.textDark),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.serviceTitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Booking ID: ${booking.id} • ${booking.address}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
              ),
              if (booking.items.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: booking.items
                      .map(
                        (item) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${item.quantity}x ${item.title}',
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${booking.totalAmount.toStringAsFixed(0)}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            Text(
              'Pay after service',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF15803D),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Helper 5: Status Simulator Bar ---
  Widget _buildActiveStatusSimulator(BookingModel booking) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.touch_app_rounded, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            'Simulate Status:',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
          const Spacer(),
          if (booking.status != BookingStatus.inProgress)
            InkWell(
              onTap: () {
                ref.read(bookingsProvider.notifier).updateStatus(booking.id, BookingStatus.inProgress);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Provider marked as arrived! Work in progress for ${booking.id}.'),
                    backgroundColor: const Color(0xFF8B5CF6),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Start Work',
                  style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ),
          if (booking.status != BookingStatus.inProgress)
            const SizedBox(width: 6),
          InkWell(
            onTap: () {
              ref.read(bookingsProvider.notifier).updateStatus(booking.id, BookingStatus.completed);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Job marked as completed! Moved to history for ${booking.id}.'),
                  backgroundColor: const Color(0xFF15803D),
                ),
              );
              _showRateDialog(booking);
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF15803D),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Complete Job',
                style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper 6: Active Card Footer ---
  Widget _buildActiveCardFooter(BookingModel booking) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: () => _confirmCancelBooking(booking),
          icon: const Icon(Icons.close_rounded, size: 14, color: Color(0xFFDC2626)),
          label: Text(
            'Cancel Booking',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFDC2626),
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        TextButton.icon(
          onPressed: () => _showSupportDialog(),
          icon: const Icon(Icons.help_outline_rounded, size: 14, color: AppColors.textSecondary),
          label: Text(
            'Help & Support',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  // --- Live Progress Stepper ---
  Widget _buildLiveProgressStepper(BookingStatus status) {
    final steps = [
      {'title': 'Booked', 'done': true},
      {'title': 'Accepted', 'done': true},
      {
        'title': 'On the Way',
        'done': status == BookingStatus.enRoute || status == BookingStatus.inProgress,
        'active': status == BookingStatus.enRoute
      },
      {'title': 'Started', 'done': status == BookingStatus.inProgress, 'active': status == BookingStatus.inProgress},
      {'title': 'Done', 'done': status == BookingStatus.completed},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      if (i > 0)
                        Expanded(
                          child: Container(
                            height: 2.5,
                            color: (steps[i]['done'] as bool)
                                ? const Color(0xFF10B981)
                                : const Color(0xFFCBD5E1),
                          ),
                        ),
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: (steps[i]['done'] as bool)
                              ? const Color(0xFF10B981)
                              : (steps[i]['active'] == true
                                  ? const Color(0xFF0F766E)
                                  : const Color(0xFFE2E8F0)),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: (steps[i]['done'] as bool)
                              ? const Icon(Icons.check, size: 11, color: Colors.white)
                              : Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                        ),
                      ),
                      if (i < steps.length - 1)
                        Expanded(
                          child: Container(
                            height: 2.5,
                            color: (steps[i + 1]['done'] as bool)
                                ? const Color(0xFF10B981)
                                : const Color(0xFFCBD5E1),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    steps[i]['title'] as String,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: (steps[i]['done'] as bool) || (steps[i]['active'] == true)
                          ? FontWeight.w800
                          : FontWeight.w500,
                      color: (steps[i]['done'] as bool) || (steps[i]['active'] == true)
                          ? AppColors.textDark
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // SECTION 2: CUSTOMER HISTORY (PAST / COMPLETED BOOKINGS)
  // Shows full history of completed/cancelled services, provider details, receipts, rebook
  // ===========================================================================
  Widget _buildHistoryBookingCard(BookingModel booking) {
    final isCompleted = booking.isCompleted;
    final provider = booking.provider;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Service Title & Grayscale Status Pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  booking.serviceIcon,
                  size: 18,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.serviceTitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${booking.scheduledTime} • ID: ${booking.id}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Grayscale / Off-tone Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCompleted ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
                      size: 12,
                      color: const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      booking.status.label.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 10),

          // 2. Grayscale Service Provider Info
          InkWell(
            onTap: () {
              final service = ServiceRepository.allServices.firstWhere(
                (s) => s.id == provider.serviceId,
                orElse: () => ServiceRepository.allServices.first,
              );
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => ProviderDetailModal(
                  provider: provider,
                  service: service,
                  onBookNow: () {
                    Navigator.pop(ctx);
                    _rebookService(booking);
                  },
                ),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFCBD5E1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        provider.avatarInitials,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCompleted
                              ? 'Serviced by ${provider.name}'
                              : 'Requested provider: ${provider.name}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                        Text(
                          provider.clinicOrFirmName.isNotEmpty
                              ? provider.clinicOrFirmName
                              : provider.qualifications,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 2),
                      Text(
                        '${provider.rating}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 3. Grayscale Review given snippet (if any)
          if (booking.reviewGiven != null && booking.reviewGiven!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.format_quote_rounded, size: 14, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      booking.reviewGiven!,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  if (booking.ratingGiven != null)
                    Row(
                      children: [
                        for (int s = 0; s < 5; s++)
                          Icon(
                            s < booking.ratingGiven!.floor()
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 11,
                            color: const Color(0xFF94A3B8),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),

          // 4. Grayscale Payment & Off-tone Rebook Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹${booking.totalAmount.toStringAsFixed(0)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  Text(
                    booking.paymentMethod,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (isCompleted && booking.ratingGiven == null)
                    OutlinedButton(
                      onPressed: () => _showRateDialog(booking),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'Rate',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF64748B)),
                      ),
                    ),
                  if (isCompleted && booking.ratingGiven == null)
                    const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _rebookService(booking),
                    icon: const Icon(Icons.refresh_rounded, size: 13),
                    label: Text(
                      'Rebook',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      foregroundColor: const Color(0xFF334155),
                      elevation: 0,
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Empty Bookings State ---
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryYellow.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_long_rounded, size: 32, color: AppColors.primaryYellowDark),
            ),
            const SizedBox(height: 14),
            Text(
              'No Bookings in this Category',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'When you book a service, live provider info and history will appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(homeBottomNavIndexProvider.notifier).state = 0;
              },
              icon: const Icon(Icons.explore_rounded, size: 16),
              label: Text(
                'Explore Services',
                style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: AppColors.textDark,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Support Banner ---
  Widget _buildSupportBanner() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryYellow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.headset_mic_rounded, color: AppColors.textDark, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service Assurance & Support',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Issues with an accepted provider or need warranty claim? 24/7 dedicated support desk.',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFFA1A1AA),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _showSupportDialog(),
            icon: const Icon(Icons.chevron_right_rounded, color: AppColors.primaryYellow, size: 24),
          ),
        ],
      ),
    );
  }

  // --- Actions & Dialogs ---
  void _showCallDialog(ServiceProviderModel provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.phone_rounded, color: Color(0xFF15803D)),
            const SizedBox(width: 8),
            Text('Call ${provider.name}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connecting you securely to your assigned service provider:',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.call, size: 18, color: Color(0xFF0F766E)),
                  const SizedBox(width: 8),
                  Text(
                    provider.phone,
                    style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• Calls are recorded for quality & safety\n• ETA is tracked live via GPS',
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Dialing ${provider.name} (${provider.phone})...'),
                  backgroundColor: const Color(0xFF15803D),
                ),
              );
            },
            icon: const Icon(Icons.call, size: 16),
            label: const Text('Dial Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF15803D),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showChatDialog(ServiceProviderModel provider) {
    final chatTextController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.chat_bubble_rounded, color: AppColors.textDark),
            const SizedBox(width: 8),
            Text('Message ${provider.name}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: chatTextController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g. Please ring bell 402, lift is under maintenance...',
                hintStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Message sent to ${provider.name}!'),
                  backgroundColor: AppColors.textDark,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryYellow, foregroundColor: AppColors.textDark),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _confirmCancelBooking(BookingModel booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Cancel Booking?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        content: Text(
          'Are you sure you want to cancel ${booking.serviceTitle} with ${booking.provider.name}?',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Keep Booking')),
          ElevatedButton(
            onPressed: () {
              ref.read(bookingsProvider.notifier).cancelBooking(booking.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking cancelled successfully.'),
                  backgroundColor: Color(0xFFDC2626),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );
  }

  void _showRateDialog(BookingModel booking) {
    double selectedRating = 5.0;
    final reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Rate & Review', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('How was your service experience with ${booking.provider.name}?'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 1; i <= 5; i++)
                      IconButton(
                        onPressed: () => setModalState(() => selectedRating = i.toDouble()),
                        icon: Icon(
                          i <= selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: const Color(0xFFEAB308),
                          size: 32,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: reviewController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Write a short feedback (optional)...',
                    hintStyle: GoogleFonts.inter(fontSize: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  ref.read(bookingsProvider.notifier).rateBooking(
                        booking.id,
                        selectedRating,
                        reviewController.text.trim(),
                      );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thank you for rating!'), backgroundColor: Color(0xFF15803D)),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryYellow, foregroundColor: AppColors.textDark),
                child: const Text('Submit Review'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _rebookService(BookingModel booking) {
    ProviderMapCartDialog.show(
      context,
      serviceId: booking.serviceId,
      initialTaskTitle: booking.serviceTitle,
      initialTaskPrice: booking.totalAmount,
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.support_agent_rounded, color: AppColors.primaryYellowDark),
            const SizedBox(width: 8),
            Text('Dispute & Warranty Desk', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• 30-Day Service Guarantee on all completed jobs.', style: GoogleFonts.inter(fontSize: 12.5)),
            const SizedBox(height: 6),
            Text('• Dedicated dispute resolution team available 24/7.', style: GoogleFonts.inter(fontSize: 12.5)),
            const SizedBox(height: 6),
            Text('• Instant refund protection for unfulfilled bookings.', style: GoogleFonts.inter(fontSize: 12.5)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.textDark, foregroundColor: Colors.white),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
