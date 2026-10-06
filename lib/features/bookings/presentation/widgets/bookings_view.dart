import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_x/app/theme/app_colors.dart';

class BookingsView extends StatefulWidget {
  const BookingsView({super.key});

  @override
  State<BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends State<BookingsView> {
  int _selectedFilterIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final List<String> _filters = ['All (6)', 'Active (2)', 'Completed (3)', 'Cancelled (1)'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.tune_rounded, color: AppColors.textDark, size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                Text(
                  'Bookings',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const Spacer(),

                // Notification Bell with Badge Dot
                Stack(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textDark, size: 24),
                    ),
                    Positioned(
                      top: 10,
                      right: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryYellow,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),

                // User Avatar Button
                Container(
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
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Search Box Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              hintText: 'Search by service or booking ID...',
                              hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 48,
                  height: 48,
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

          const SizedBox(height: 14),

          // 3. Category Filter Chips
          SizedBox(
            height: 38,
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
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
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
                        _filters[index],
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Filter view condition
          if (_selectedFilterIndex == 0 || _selectedFilterIndex == 1) ...[
            // 4. Card 1: Live Active Booking Card (Technician Arriving)
            _buildLiveUpdateHeader(),
            const SizedBox(height: 8),
            _buildLiveActiveBookingCard(),

            const SizedBox(height: 24),

            // 5. Card 2: Scheduled Next Booking
            _buildScheduledHeader(),
            const SizedBox(height: 8),
            _buildScheduledNextCard(),

            const SizedBox(height: 24),
          ],

          if (_selectedFilterIndex == 0 || _selectedFilterIndex == 2 || _selectedFilterIndex == 3) ...[
            // 6. Section: Past Service History
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Past Service History',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Most Recent',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textSecondary),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Card 3: Completed Dr House & Care
            if (_selectedFilterIndex == 0 || _selectedFilterIndex == 2)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildCompletedCard1(),
              ),

            const SizedBox(height: 12),

            // Card 4: Completed House Cleaning
            if (_selectedFilterIndex == 0 || _selectedFilterIndex == 2)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildCompletedCard2(),
              ),

            const SizedBox(height: 12),

            // Card 5: Cancelled Electrician
            if (_selectedFilterIndex == 0 || _selectedFilterIndex == 3)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildCancelledCard(),
              ),

            const SizedBox(height: 24),
          ],

          // 7. Service Assurance & Support Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildSupportBanner(),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveUpdateHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAB308),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'LIVE UPDATE',
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF854D0E),
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          Text(
            'Ref: #BK-98241',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveActiveBookingCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Top Accent Line
            Container(height: 4, color: AppColors.primaryYellow),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tag + Title + ETA Box Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF08A),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.near_me_rounded, size: 12, color: Color(0xFF713F12)),
                                  const SizedBox(width: 4),
                                  Text(
                                    'TECHNICIAN ARRIVING',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF713F12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'AC Deep Jet Clean & Filte...',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  'Indiranagar 100ft Rd • Today, 2:30 PM',
                                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Dark ETA Box
                      Container(
                        width: 58,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF18181B),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'ETA',
                              style: GoogleFonts.inter(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryYellow,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              '8m',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Provider Info Card Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        // Provider Avatar
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(Icons.person_rounded, color: Colors.white, size: 22),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Name & Rating
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ramesh K.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, size: 14, color: Color(0xFFEAB308)),
                                  const SizedBox(width: 2),
                                  Text(
                                    '4.9 ',
                                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                                  ),
                                  Text(
                                    '(1,420+ jobs)',
                                    style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Action Buttons: Call + Message
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Calling technician Ramesh K...')),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: AppColors.surfaceWhite,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.phone_outlined, size: 18, color: AppColors.textDark),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Chat opened with Ramesh K.')),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: AppColors.surfaceWhite,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: AppColors.textDark),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Start Service OTP Box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'START SERVICE OTP',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Share only upon arrival',
                              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '4 8 2 1',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 4,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('OTP copied to clipboard!')),
                                );
                              },
                              icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.textSecondary),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Track on Live Map Yellow Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Live Map Tracking opened!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryYellow,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.explore_outlined, color: AppColors.textDark, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Track on Live Map',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_rounded, color: AppColors.textDark, size: 16),
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
    );
  }

  Widget _buildScheduledHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'SCHEDULED NEXT',
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
              letterSpacing: 0.6,
            ),
          ),
          Text(
            'Ref: #BK-97402',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledNextCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF854D0E), shape: BoxShape.circle)),
                            const SizedBox(width: 4),
                            Text(
                              'CONFIRMED',
                              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textDark),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Plumbing - Pipe Leakage &\nSink Fitting',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            'Tomorrow, Oct 18 • 10:00 AM - 11:30 AM',
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Icon Box Squircle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.plumbing_rounded, color: AppColors.textDark, size: 20),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Provider Tile
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(Icons.person_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Suresh V.',
                          style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
                        ),
                        Text(
                          'Master Certified Plumber',
                          style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      'View Profile',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Action Buttons Row: Reschedule, Checklist, Cancel
            Row(
              children: [
                Expanded(
                  child: _buildSecondaryActionButton(
                    icon: Icons.calendar_month_outlined,
                    label: 'Resche...',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSecondaryActionButton(
                    icon: Icons.assignment_outlined,
                    label: 'Checklist',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.close_rounded, size: 14, color: Color(0xFF991B1B)),
                          const SizedBox(width: 4),
                          Text(
                            'Cancel',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF991B1B)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedCard1() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 14, color: Color(0xFF0F766E)),
                        const SizedBox(width: 4),
                        Text(
                          'Completed',
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF0F766E)),
                        ),
                        Text(
                          ' • Oct 12, 2023',
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Dr. House & Care - Health ...',
                      style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Paid ₹499 via UPI AutoPay',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                child: const Center(child: Icon(Icons.medical_services_outlined, color: AppColors.textDark, size: 20)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Rating box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Text('Your Rating:', style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary)),
                const Spacer(),
                const Icon(Icons.star_rounded, size: 14, color: Color(0xFFEAB308)),
                const Icon(Icons.star_rounded, size: 14, color: Color(0xFFEAB308)),
                const Icon(Icons.star_rounded, size: 14, color: Color(0xFFEAB308)),
                const Icon(Icons.star_rounded, size: 14, color: Color(0xFFEAB308)),
                const Icon(Icons.star_rounded, size: 14, color: Color(0xFFEAB308)),
                const SizedBox(width: 4),
                Text('5.0', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Action Buttons: Invoice + Rebook Service
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(14)),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long_outlined, size: 16, color: AppColors.textDark),
                        const SizedBox(width: 6),
                        Text('Invoice', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(color: const Color(0xFF18181B), borderRadius: BorderRadius.circular(14)),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        Text('Rebook Service', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedCard2() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 14, color: Color(0xFF0F766E)),
                        const SizedBox(width: 4),
                        Text('Completed', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF0F766E))),
                        Text(' • Sep 28, 2023', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('House Cleaning - Deep Kit...', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    const SizedBox(height: 2),
                    Text('Paid ₹899 via Credit Card', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                child: const Center(child: Icon(Icons.cleaning_services_outlined, color: AppColors.textDark, size: 20)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Warranty status box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFFEF08A).withValues(alpha: 0.4), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.verified_user_outlined, size: 14, color: Color(0xFF854D0E)),
                const SizedBox(width: 6),
                Text('30-Day Service Warranty Active', style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: const Color(0xFF854D0E))),
                const Spacer(),
                Text('9 Days Left', style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w800, color: const Color(0xFF854D0E))),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Action Buttons: Invoice + Rebook Service
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(14)),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long_outlined, size: 16, color: AppColors.textDark),
                        const SizedBox(width: 6),
                        Text('Invoice', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(color: const Color(0xFF18181B), borderRadius: BorderRadius.circular(14)),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        Text('Rebook Service', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(8)),
                          child: Text('Cancelled', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF991B1B))),
                        ),
                        Text(' • Sep 15, 2023', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Electrician - Switchboard ...', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.account_balance_wallet_outlined, size: 14, color: Color(0xFF0F766E)),
                        const SizedBox(width: 4),
                        Text('Refund of ₹199 settled to bank', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF0F766E))),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                child: const Center(child: Icon(Icons.bolt_outlined, color: AppColors.textDark, size: 20)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Full Width Action Button: Book Again
          Container(
            height: 42,
            width: double.infinity,
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(14)),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.refresh_rounded, size: 16, color: AppColors.textDark),
                  const SizedBox(width: 6),
                  Text('Book Again', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: AppColors.textDark),
            const SizedBox(width: 4),
            Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportBanner() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryYellow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(Icons.headset_mic_rounded, color: AppColors.textDark, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service Assurance &\nSupport',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Have issues or need to claim warranty on a recent booking? Our dispute desk responds within 5 minutes.',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: const Color(0xFFA1A1AA),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Chat with Support',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryYellow,
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primaryYellow),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
