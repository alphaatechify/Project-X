import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../data/provider_jobs_provider.dart';
import '../../domain/models/provider_job_model.dart';

class ProviderJobsView extends ConsumerStatefulWidget {
  const ProviderJobsView({super.key});

  @override
  ConsumerState<ProviderJobsView> createState() => _ProviderJobsViewState();
}

class _ProviderJobsViewState extends ConsumerState<ProviderJobsView> {
  int _selectedFilterIndex = 0; // 0: All, 1: Completed, 2: Pending/Dropped, 3: Active
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
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

  void _showMarkPendingDialog(ProviderJobModel job) {
    final reasons = [
      'Spare parts / specialty fittings out of stock (Vendor shipment awaited)',
      'Customer requested reschedule / not available at premises',
      'Society or site access restricted / enclosure locked',
      'Electrical / water supply shut down at building level',
      'Structural issue discovered requiring additional estimate approval',
    ];
    String selectedReason = reasons.first;
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.pause_circle_filled_rounded, color: Color(0xFFD97706), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mark Service as Pending', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 17)),
                    Text('Specify why work was left incomplete', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Primary Reason (Pending Chhoda Gaya):', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 8),
                ...reasons.map((r) {
                  final isSelected = selectedReason == r;
                  return GestureDetector(
                    onTap: () {
                      setDialogState(() {
                        selectedReason = r;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFEF3C7) : AppColors.surfaceLightGray,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFD97706) : const Color(0xFFE2E8F0),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                            color: isSelected ? const Color(0xFFD97706) : AppColors.textMuted,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              r,
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Text('Next Action / Reschedule Slot Note:', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Customer informed, next visit slot 4:30 PM today...',
                    hintStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surfaceLightGray,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                final note = notesController.text.trim().isNotEmpty
                    ? notesController.text.trim()
                    : 'Customer notified. Visit scheduled for follow-up.';
                ref.read(providerJobsProvider.notifier).markAsPending(
                      job.id,
                      reason: selectedReason,
                      notes: note,
                    );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Job marked as Pending: $selectedReason'),
                    backgroundColor: const Color(0xFFD97706),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text('Save as Pending', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompleteDialog(ProviderJobModel job) {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_rounded, color: Color(0xFF15803D), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Complete Service', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 17)),
                  Text(job.title, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payments_rounded, color: Color(0xFF15803D), size: 22),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Payout to be credited', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                      Text('₹${job.payoutAmount.toStringAsFixed(0)}', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF15803D))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text('Completion & Work Summary Notes:', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                hintText: 'e.g. Work executed cleanly, pressure tested, zero leaks confirmed...',
                hintStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surfaceLightGray,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF15803D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              final note = noteController.text.trim().isNotEmpty
                  ? noteController.text.trim()
                  : 'Customer verified with OTP. Job marked completed with 5.0 rating.';
              ref.read(providerJobsProvider.notifier).completeJob(job.id, notes: note);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Awesome! ${job.title} marked as Completed (+₹${job.payoutAmount.toStringAsFixed(0)})'),
                  backgroundColor: const Color(0xFF15803D),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text('Confirm Completion', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allJobs = ref.watch(providerJobsProvider);
    final completedJobs = ref.watch(providerCompletedJobsProvider);
    final pendingJobs = ref.watch(providerPendingJobsProvider);
    final activeJobs = ref.watch(providerActiveJobsProvider);
    final totalEarnings = ref.watch(providerEarningsSummaryProvider);
    final completionRate = ref.watch(providerCompletionRateProvider);

    // Apply active filter tab
    List<ProviderJobModel> displayedJobs;
    switch (_selectedFilterIndex) {
      case 1:
        displayedJobs = completedJobs;
        break;
      case 2:
        displayedJobs = pendingJobs;
        break;
      case 3:
        displayedJobs = activeJobs;
        break;
      case 0:
      default:
        displayedJobs = allJobs;
        break;
    }

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      displayedJobs = displayedJobs.where((j) {
        final matchId = j.id.toLowerCase().contains(_searchQuery);
        final matchTitle = j.title.toLowerCase().contains(_searchQuery);
        final matchCustomer = j.customerName.toLowerCase().contains(_searchQuery);
        final matchAddress = j.address.toLowerCase().contains(_searchQuery);
        final matchReason = (j.pendingReason ?? '').toLowerCase().contains(_searchQuery);
        return matchId || matchTitle || matchCustomer || matchAddress || matchReason;
      }).toList();
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Section Header with Title & Live Status
              _buildPageHeader(completedCount: completedJobs.length, pendingCount: pendingJobs.length),

              // 2. Performance Summary Analytics Grid (Kitne Complete vs Kitne Pending)
              _buildAnalyticsGrid(
                completedCount: completedJobs.length,
                pendingCount: pendingJobs.length,
                activeCount: activeJobs.length,
                totalEarnings: totalEarnings,
                completionRate: completionRate,
              ),

              const SizedBox(height: 24),

              // 3. Search and Filter Bar
              _buildSearchAndFilters(
                allCount: allJobs.length,
                completedCount: completedJobs.length,
                pendingCount: pendingJobs.length,
                activeCount: activeJobs.length,
              ),

              const SizedBox(height: 20),

              // 4. Job List View
              if (displayedJobs.isEmpty)
                _buildEmptyState()
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: displayedJobs.map((job) => _buildJobCard(job)).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader({required int completedCount, required int pendingCount}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryYellow,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryYellow.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.handyman_rounded, color: AppColors.textDark, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Service Jobs History',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'PARTNER CONSOLE',
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF0369A1)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Overview of completed services ($completedCount) & pending jobs ($pendingCount) requiring follow-up.',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsGrid({
    required int completedCount,
    required int pendingCount,
    required int activeCount,
    required double totalEarnings,
    required double completionRate,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 780;

          final cardCompleted = _buildStatCard(
            title: 'SERVICES COMPLETED',
            value: '$completedCount Jobs',
            subText: '₹${totalEarnings.toStringAsFixed(0)} Earned • 4.9★ Avg',
            icon: Icons.check_circle_rounded,
            accentColor: const Color(0xFF15803D),
            bgColor: const Color(0xFFF0FDF4),
            borderColor: const Color(0xFFBBF7D0),
            badgeText: 'PAID & VERIFIED',
            badgeBg: const Color(0xFFDCFCE7),
            badgeColor: const Color(0xFF15803D),
          );

          final cardPending = _buildStatCard(
            title: 'PENDING / LEFT INCOMPLETE',
            value: '$pendingCount Pending',
            subText: '$pendingCount services paused / parts awaited',
            icon: Icons.pause_circle_filled_rounded,
            accentColor: const Color(0xFFD97706),
            bgColor: const Color(0xFFFFFBEB),
            borderColor: const Color(0xFFFDE68A),
            badgeText: 'NEEDS FOLLOW-UP',
            badgeBg: const Color(0xFFFEF3C7),
            badgeColor: const Color(0xFFB45309),
          );

          final cardActive = _buildStatCard(
            title: 'ACTIVE IN PROGRESS',
            value: '$activeCount Live',
            subText: 'Currently dispatched on site',
            icon: Icons.autorenew_rounded,
            accentColor: const Color(0xFF0284C7),
            bgColor: const Color(0xFFF0F9FF),
            borderColor: const Color(0xFFBAE6FD),
            badgeText: 'LIVE JOB',
            badgeBg: const Color(0xFFE0F2FE),
            badgeColor: const Color(0xFF0369A1),
          );

          final cardRate = _buildStatCard(
            title: 'JOB SUCCESS RATE',
            value: '${completionRate.toStringAsFixed(1)}%',
            subText: 'On-time delivery score: 96%',
            icon: Icons.trending_up_rounded,
            accentColor: const Color(0xFF7C3AED),
            bgColor: const Color(0xFFF5F3FF),
            borderColor: const Color(0xFFDDD6FE),
            badgeText: 'EXCELLENT',
            badgeBg: const Color(0xFFEDE9FE),
            badgeColor: const Color(0xFF6D28D9),
          );

          if (isWide) {
            return Row(
              children: [
                Expanded(child: cardCompleted),
                const SizedBox(width: 14),
                Expanded(child: cardPending),
                const SizedBox(width: 14),
                Expanded(child: cardActive),
                const SizedBox(width: 14),
                Expanded(child: cardRate),
              ],
            );
          } else {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: cardCompleted),
                    const SizedBox(width: 12),
                    Expanded(child: cardPending),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: cardActive),
                    const SizedBox(width: 12),
                    Expanded(child: cardRate),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subText,
    required IconData icon,
    required Color accentColor,
    required Color bgColor,
    required Color borderColor,
    required String badgeText,
    required Color badgeBg,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w800, color: badgeColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 0.5),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.textDark),
          ),
          const SizedBox(height: 4),
          Text(
            subText,
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: accentColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters({
    required int allCount,
    required int completedCount,
    required int pendingCount,
    required int activeCount,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Search Input
          Container(
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
                      hintText: 'Search by Job ID, customer, service title or pending reason...',
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

          const SizedBox(height: 14),

          // Filter Tab Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterPill(
                  index: 0,
                  label: 'All Jobs',
                  count: allCount,
                  color: AppColors.textDark,
                ),
                const SizedBox(width: 8),
                _buildFilterPill(
                  index: 1,
                  label: 'Completed Services',
                  count: completedCount,
                  color: const Color(0xFF15803D),
                  icon: Icons.check_circle_rounded,
                ),
                const SizedBox(width: 8),
                _buildFilterPill(
                  index: 2,
                  label: 'Pending Chhode Hue',
                  count: pendingCount,
                  color: const Color(0xFFD97706),
                  icon: Icons.pause_circle_filled_rounded,
                ),
                const SizedBox(width: 8),
                _buildFilterPill(
                  index: 3,
                  label: 'In Progress',
                  count: activeCount,
                  color: const Color(0xFF0284C7),
                  icon: Icons.autorenew_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill({
    required int index,
    required String label,
    required int count,
    required Color color,
    IconData? icon,
  }) {
    final isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilterIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textDark : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.textDark : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: isSelected ? Colors.white : color),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.2) : AppColors.surfaceLightGray,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(ProviderJobModel job) {
    final isPending = job.isPending;
    final isCompleted = job.isCompleted;
    final isActive = job.isActive;

    // Border & Shadow based on state
    Border cardBorder;
    Color cardBg;
    List<BoxShadow> cardShadows;

    if (isActive) {
      cardBg = AppColors.surfaceWhite;
      cardBorder = Border.all(color: const Color(0xFF0284C7), width: 2.5);
      cardShadows = [
        BoxShadow(
          color: const Color(0xFF0284C7).withValues(alpha: 0.25),
          blurRadius: 22,
          spreadRadius: 2,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    } else if (isCompleted) {
      cardBg = const Color(0xFFFAFAFA);
      cardBorder = Border.all(color: const Color(0xFFE2E8F0), width: 1.0);
      cardShadows = [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];
    } else {
      cardBg = AppColors.surfaceWhite;
      cardBorder = Border.all(color: const Color(0xFFFDE68A), width: 1.2);
      cardShadows = [
        BoxShadow(
          color: const Color(0xFFD97706).withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: cardBorder,
        boxShadow: cardShadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Card Bar: ID, Date, Payout, Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isActive
                  ? const LinearGradient(
                      colors: [Color(0xFF0369A1), Color(0xFF0284C7)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              color: isActive
                  ? null
                  : (isCompleted ? const Color(0xFFF1F5F9) : job.status.bgColor.withValues(alpha: 0.4)),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive
                              ? Colors.white.withValues(alpha: 0.3)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        job.id,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isActive ? const Color(0xFF0369A1) : (isCompleted ? const Color(0xFF64748B) : AppColors.textDark),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      job.date,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: isActive ? Colors.white.withValues(alpha: 0.9) : (isCompleted ? const Color(0xFF94A3B8) : AppColors.textSecondary),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Payout badge
                    Text(
                      '₹${job.payoutAmount.toStringAsFixed(0)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isActive ? Colors.white : (isCompleted ? const Color(0xFF475569) : const Color(0xFF15803D)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Status Badge
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
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
                                color: Color(0xFF0284C7),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'ACTIVE TASK',
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0369A1),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_outline_rounded, size: 12, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text(
                              'COMPLETED',
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: job.status.bgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: job.status.color.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(job.status.icon, size: 12, color: job.status.color),
                            const SizedBox(width: 4),
                            Text(
                              job.status.label,
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: job.status.color,
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

          // 2. Main Job Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: isCompleted ? const Color(0xFF334155) : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  job.serviceDetails,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: isCompleted ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 12),
                Divider(height: 1, color: isCompleted ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9)),
                const SizedBox(height: 12),

                // Customer & Location Details
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isCompleted ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          job.customerName.isNotEmpty ? job.customerName[0] : 'C',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            color: isCompleted ? const Color(0xFF64748B) : AppColors.textDark,
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
                            job.customerName,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: isCompleted ? const Color(0xFF475569) : AppColors.textDark,
                            ),
                          ),
                          Text(
                            job.address,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: isCompleted ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.phone_rounded,
                        color: isCompleted ? const Color(0xFF94A3B8) : const Color(0xFF0284C7),
                        size: 20,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Calling customer ${job.customerName} (${job.customerPhone})...'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),

                // 3. Highlighted Callout for PENDING / LEFT INCOMPLETE JOBS
                if (isPending) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFD97706)),
                            const SizedBox(width: 6),
                            Text(
                              'REASON SERVICE LEFT PENDING:',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFB45309),
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.pendingReason ?? 'Service paused before completion.',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                        ),
                        if (job.pendingActionNotes != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFDE68A)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.schedule_rounded, size: 13, color: Color(0xFFD97706)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    job.pendingActionNotes ?? '',
                                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF92400E)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                // 4. Completed Job Feedback & Rating Snippet (Grayscale / Off-tone)
                if (isCompleted && job.customerFeedback != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.star_rounded, size: 16, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Customer Feedback: "${job.customerFeedback}"',
                            style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // 5. Active Job Action Bar (Vibrant Highlighted)
                if (isActive) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.key_rounded, size: 15, color: Color(0xFF0284C7)),
                            const SizedBox(width: 6),
                            Text('Service OTP: ', style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                            Text(job.otp, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w900, color: const Color(0xFF0284C7))),
                          ],
                        ),
                        Text('Est: ${job.estimatedDuration}', style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                // Action Buttons for this card
                Row(
                  children: [
                    if (isPending) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF15803D),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                          label: Text('Mark Completed', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12.5)),
                          onPressed: () => _showCompleteDialog(job),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0284C7),
                          side: const BorderSide(color: Color(0xFF0284C7)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded, size: 16),
                        label: Text('Resume Work', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12.5)),
                        onPressed: () {
                          ref.read(providerJobsProvider.notifier).resumeJob(job.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Job resumed to In Progress: ${job.title}'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ] else if (isActive) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF15803D),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.check_circle_rounded, size: 16),
                          label: Text('Complete Job', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12.5)),
                          onPressed: () => _showCompleteDialog(job),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFD97706),
                          side: const BorderSide(color: Color(0xFFD97706)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.pause_circle_outline_rounded, size: 16),
                        label: Text('Leave Pending', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12.5)),
                        onPressed: () => _showMarkPendingDialog(job),
                      ),
                    ] else ...[
                      // Grayscale Off-tone Button for Completed Jobs
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF475569),
                            backgroundColor: const Color(0xFFF1F5F9),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.receipt_long_rounded, size: 16, color: Color(0xFF64748B)),
                          label: Text('View Service Summary', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12.5, color: const Color(0xFF475569))),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                              builder: (ctx) => Container(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Service Receipt • ${job.id}', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800)),
                                    const SizedBox(height: 12),
                                    Text(job.title, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
                                    const SizedBox(height: 6),
                                    Text(job.serviceDetails, style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textSecondary)),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Customer Payout:', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                                        Text('₹${job.payoutAmount.toStringAsFixed(0)} (Credited)', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: const Color(0xFF15803D))),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Completed At:', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                                        Text(job.completedAt ?? job.date, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.textDark,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        ),
                                        onPressed: () => Navigator.pop(ctx),
                                        child: Text('Close', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded, size: 36, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            Text(
              'No jobs found matching your criteria',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              'Try adjusting your search query or switching the filter tab.',
              style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
