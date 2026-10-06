import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_x/app/theme/app_colors.dart';
import 'package:project_x/core/utils/phone_formatter.dart';
import 'package:project_x/features/auth/domain/models/country.dart';
import 'country_selector.dart';
import 'flag_widget.dart';

class PhoneInputWidget extends StatefulWidget {
  final Country selectedCountry;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<Country> onCountryChanged;
  final VoidCallback? onClear;
  final String? errorText;

  const PhoneInputWidget({
    super.key,
    required this.selectedCountry,
    required this.controller,
    required this.focusNode,
    required this.onCountryChanged,
    this.onClear,
    this.errorText,
  });

  @override
  State<PhoneInputWidget> createState() => _PhoneInputWidgetState();
}

class _PhoneInputWidgetState extends State<PhoneInputWidget> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = widget.focusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final hasText = widget.controller.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: hasError
                  ? AppColors.error
                  : (_isFocused ? AppColors.borderFocused : const Color(0xFFE2E8F0)),
              width: _isFocused || hasError ? 2.0 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _isFocused
                    ? Colors.black.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Country Code Selector Tap Area
              Semantics(
                label: 'Select country code',
                button: true,
                child: InkWell(
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    final selected = await CountrySelectorModal.show(
                      context,
                      selectedCountry: widget.selectedCountry,
                    );
                    if (selected != null) {
                      widget.onCountryChanged(selected);
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FlagWidget(
                          country: widget.selectedCountry,
                          width: 24,
                          height: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.selectedCountry.dialCode,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Vertical Divider
              Container(
                height: 24,
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                color: AppColors.divider,
              ),

              // Phone Number Input Field
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    letterSpacing: 0.5,
                  ),
                  inputFormatters: [
                    PhoneFormatter(country: widget.selectedCountry),
                  ],
                  decoration: InputDecoration(
                    hintText: widget.selectedCountry.exampleNumber,
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              // Clear Button (only shown when field contains text)
              if (hasText)
                Semantics(
                  label: 'Clear phone number',
                  button: true,
                  child: InkWell(
                    onTap: () {
                      widget.controller.clear();
                      if (widget.onClear != null) widget.onClear!();
                      widget.focusNode.requestFocus();
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceLightGray,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Inline Error Message
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 6),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.error),
                const SizedBox(width: 4),
                Text(
                  widget.errorText!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
