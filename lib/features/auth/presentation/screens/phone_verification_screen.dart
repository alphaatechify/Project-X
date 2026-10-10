import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_x/app/router/routes.dart';
import 'package:project_x/app/theme/app_colors.dart';
import 'package:project_x/app/theme/app_typography.dart';
import 'package:project_x/core/utils/phone_formatter.dart';
import 'package:project_x/core/utils/validators.dart';
import 'package:project_x/features/auth/domain/models/country.dart';
import 'package:project_x/features/auth/presentation/widgets/header_buttons.dart';
import 'package:project_x/features/auth/presentation/widgets/phone_input_widget.dart';
import 'package:project_x/features/auth/presentation/widgets/primary_button.dart';

class PhoneVerificationScreen extends ConsumerStatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  ConsumerState<PhoneVerificationScreen> createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends ConsumerState<PhoneVerificationScreen> {
  Country _selectedCountry = Country.india;
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();

  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_clearErrorOnType);
  }

  void _clearErrorOnType() {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.removeListener(_clearErrorOnType);
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _handleAutoDetect() {
    // Detect region / fallback gracefully to India with standard test formatting
    setState(() {
      _selectedCountry = Country.india;
      _phoneController.text = PhoneFormatter.formatRawNumber('1234567890', Country.india);
      _errorMessage = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Country auto-detected: India (+91)',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.textDark,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleNext() async {
    final validationError = PhoneValidators.validatePhone(
      _phoneController.text,
      _selectedCountry,
    );

    if (validationError != null) {
      setState(() {
        _errorMessage = validationError;
      });
      _phoneFocusNode.requestFocus();
      return;
    }

    final rawPhone = PhoneFormatter.getUnformattedDigits(_phoneController.text);
    if (rawPhone != '1234567890') {
      setState(() {
        _errorMessage = 'Invalid number. Only 1234567890 is accepted for login.';
      });
      _phoneFocusNode.requestFocus();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate brief processing
    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    final fullNumber = '${_selectedCountry.dialCode} $rawPhone';

    // Navigate to OTP verification screen with parameters
    context.push(
      AppRoutes.otpVerification,
      extra: {
        'country': _selectedCountry,
        'phone': rawPhone,
        'fullNumber': fullNumber,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Ambient warm yellow top-left glow
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0xFFFFF9C4), // Subtle warm yellow
                    Color(0x00FFF9C4),
                  ],
                  radius: 0.85,
                ),
              ),
            ),
          ),

          // Content Layout
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SafeArea(
                child: Column(
                  children: [
                // Top Header Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      AppBackButton(
                        onTap: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Phone Verification',
                        style: AppTypography.titleMedium,
                      ),
                      const Spacer(),
                      const AppHelpButton(),
                    ],
                  ),
                ),

                // Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),

                        // Main Heading
                        Text(
                          'Enter Phone number for\nverification',
                          style: AppTypography.headingLarge,
                        ),

                        const SizedBox(height: 14),

                        // Description Subtitle
                        Text(
                          'This number will be used for all ride-related communication.\nYou shall receive an SMS with code for verification.',
                          style: AppTypography.bodyMedium,
                        ),

                        const SizedBox(height: 28),

                        // Large Rounded Phone Input Box
                        PhoneInputWidget(
                          selectedCountry: _selectedCountry,
                          controller: _phoneController,
                          focusNode: _phoneFocusNode,
                          errorText: _errorMessage,
                          onCountryChanged: (newCountry) {
                            setState(() {
                              _selectedCountry = newCountry;
                              _phoneController.text = PhoneFormatter.formatRawNumber(
                                _phoneController.text,
                                newCountry,
                              );
                              _errorMessage = null;
                            });
                          },
                          onClear: () {
                            setState(() {
                              _errorMessage = null;
                            });
                          },
                        ),

                        const SizedBox(height: 12),

                        // Auto-detect & SMS Rate Info Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Standard SMS operator rates apply',
                                style: AppTypography.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Semantics(
                              label: 'Auto-detect phone configuration',
                              button: true,
                              child: InkWell(
                                onTap: _handleAutoDetect,
                                borderRadius: BorderRadius.circular(4),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  child: Text(
                                    'Auto-detect',
                                    style: AppTypography.captionBold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Bottom Sticky Next Button (Keyboard-safe positioning)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                  child: PrimaryButton(
                    text: 'Next',
                    isLoading: _isLoading,
                    onPressed: _handleNext,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  ),
);
}
}
