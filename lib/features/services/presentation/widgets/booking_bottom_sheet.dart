import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_x/app/theme/app_colors.dart';
import '../../domain/models/provider_model.dart';
import '../../domain/models/service_model.dart';

class BookingBottomSheet extends StatefulWidget {
  final ServiceModel service;
  final ServiceProviderModel provider;

  const BookingBottomSheet({
    super.key,
    required this.service,
    required this.provider,
  });

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  int _selectedTimeSlotIndex = 0;
  late String _selectedSubCategory;

  final List<String> _timeSlots = [
    '⚡ Instant (In 15 Mins)',
    'Today • 2:30 PM',
    'Today • 5:00 PM',
    'Tomorrow • 10:00 AM',
  ];

  @override
  void initState() {
    super.initState();
    _selectedSubCategory = widget.provider.subCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header: Booking Service & Provider
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.service.cardIconBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.service.icon, color: AppColors.textDark, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Book ${widget.service.title}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Assigned Pro: ${widget.provider.name} (★ ${widget.provider.rating})',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Sub-Category / Requirement selection
          Text(
            'Select Requirement',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.service.subCategories.where((c) => c != 'All').map((cat) {
                final isSelected = _selectedSubCategory == cat;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSubCategory = cat;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.textDark : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.textDark : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      cat,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textDark,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 18),

          // Schedule / Dispatch Selection
          Text(
            'Select Arrival Time',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_timeSlots.length, (index) {
              final isSelected = _selectedTimeSlotIndex == index;
              return ChoiceChip(
                label: Text(
                  _timeSlots[index],
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? AppColors.textDark : AppColors.textSecondary,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppColors.primaryYellow,
                backgroundColor: AppColors.background,
                side: BorderSide(
                  color: isSelected ? AppColors.primaryYellowDark : const Color(0xFFE2E8F0),
                ),
                onSelected: (val) {
                  setState(() {
                    _selectedTimeSlotIndex = index;
                  });
                },
              );
            }),
          ),

          const SizedBox(height: 18),

          // Address Summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLightGray,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, color: AppColors.textDark, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service Location: HOME',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textDark),
                      ),
                      Text(
                        'Indiranagar 100ft Rd, Bengaluru, KA 560038',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Price & Confirm Button
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL ESTIMATE',
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted),
                  ),
                  Text(
                    widget.provider.price,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showSuccessDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: AppColors.textDark,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Confirm & Dispatch',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.textDark),
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

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                'Booking Confirmed!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.provider.name} has accepted your request for ${widget.service.title}. ETA: ${_timeSlots[_selectedTimeSlotIndex]}.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Done',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
