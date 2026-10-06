import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_x/app/theme/app_colors.dart';

class ServiceFilterBottomSheet extends StatefulWidget {
  final bool availableNowOnly;
  final double minRating;
  final double maxDistanceKm;
  final String sortBy;
  final Function(bool availableNowOnly, double minRating, double maxDistanceKm, String sortBy) onApplyFilters;

  const ServiceFilterBottomSheet({
    super.key,
    required this.availableNowOnly,
    required this.minRating,
    required this.maxDistanceKm,
    required this.sortBy,
    required this.onApplyFilters,
  });

  @override
  State<ServiceFilterBottomSheet> createState() => _ServiceFilterBottomSheetState();
}

class _ServiceFilterBottomSheetState extends State<ServiceFilterBottomSheet> {
  late bool _availableNow;
  late double _rating;
  late double _distance;
  late String _sort;

  @override
  void initState() {
    super.initState();
    _availableNow = widget.availableNowOnly;
    _rating = widget.minRating;
    _distance = widget.maxDistanceKm;
    _sort = widget.sortBy;
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
          // Handle
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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter & Sort Professionals',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _availableNow = false;
                    _rating = 0.0;
                    _distance = 10.0;
                    _sort = 'Distance';
                  });
                },
                child: Text(
                  'Reset All',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF854D0E),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Availability Toggle
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Available Now Only',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
            subtitle: Text(
              'Show pros who can arrive within 30 minutes',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
            ),
            value: _availableNow,
            activeTrackColor: AppColors.primaryYellow,
            onChanged: (val) {
              setState(() {
                _availableNow = val;
              });
            },
          ),

          const Divider(height: 24),

          // Sort Options
          Text(
            'Sort By',
            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Distance', 'Rating', 'Experience', 'Price'].map((option) {
              final isSelected = _sort == option;
              return ChoiceChip(
                label: Text(
                  option,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? AppColors.textDark : AppColors.textSecondary,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppColors.primaryYellow,
                backgroundColor: AppColors.background,
                onSelected: (val) {
                  setState(() {
                    _sort = option;
                  });
                },
              );
            }).toList(),
          ),

          const Divider(height: 24),

          // Minimum Rating Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Minimum Rating',
                style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              Text(
                _rating == 0.0 ? 'Any Rating' : '★ ${_rating.toStringAsFixed(1)}+',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
            ],
          ),
          Slider(
            value: _rating,
            min: 0.0,
            max: 4.8,
            divisions: 4,
            activeColor: AppColors.primaryYellowDark,
            onChanged: (val) {
              setState(() {
                _rating = val;
              });
            },
          ),

          const SizedBox(height: 8),

          // Max Distance Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Max Distance from You',
                style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              Text(
                'Within ${_distance.toStringAsFixed(1)} km',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
            ],
          ),
          Slider(
            value: _distance,
            min: 1.0,
            max: 10.0,
            divisions: 9,
            activeColor: AppColors.primaryYellowDark,
            onChanged: (val) {
              setState(() {
                _distance = val;
              });
            },
          ),

          const SizedBox(height: 20),

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onApplyFilters(_availableNow, _rating, _distance, _sort);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: AppColors.textDark,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'Apply Filters',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
