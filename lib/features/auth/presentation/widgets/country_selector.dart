import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_x/app/theme/app_colors.dart';
import 'package:project_x/features/auth/domain/models/country.dart';
import 'flag_widget.dart';

class CountrySelectorModal extends StatefulWidget {
  final Country selectedCountry;
  final List<Country> countries;

  const CountrySelectorModal({
    super.key,
    required this.selectedCountry,
    this.countries = Country.defaultCountries,
  });

  static Future<Country?> show(BuildContext context, {required Country selectedCountry}) {
    return showModalBottomSheet<Country>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CountrySelectorModal(selectedCountry: selectedCountry),
    );
  }

  @override
  State<CountrySelectorModal> createState() => _CountrySelectorModalState();
}

class _CountrySelectorModalState extends State<CountrySelectorModal> {
  late List<Country> _filteredCountries;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredCountries = widget.countries;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = widget.countries;
      } else {
        _filteredCountries = widget.countries.where((c) {
          final nameMatch = c.name.toLowerCase().contains(query);
          final codeMatch = c.code.toLowerCase().contains(query);
          final dialMatch = c.dialCode.toLowerCase().contains(query);
          return nameMatch || codeMatch || dialMatch;
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header Title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Country',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search country or code...',
                hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceLightGray,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.divider),

          // Country List
          Expanded(
            child: _filteredCountries.isEmpty
                ? Center(
                    child: Text(
                      'No countries found',
                      style: GoogleFonts.inter(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    itemCount: _filteredCountries.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 64, color: AppColors.divider),
                    itemBuilder: (context, index) {
                      final country = _filteredCountries[index];
                      final isSelected = country.code == widget.selectedCountry.code;

                      return ListTile(
                        onTap: () => Navigator.pop(context, country),
                        leading: FlagWidget(country: country, width: 28, height: 18),
                        title: Text(
                          country.name,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              country.dialCode,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 10),
                              const Icon(Icons.check_circle_rounded, color: AppColors.textDark, size: 20),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
