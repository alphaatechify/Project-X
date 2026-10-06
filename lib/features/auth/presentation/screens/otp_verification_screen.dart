import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_x/app/router/routes.dart';
import 'package:project_x/app/theme/app_colors.dart';
import 'package:project_x/app/theme/app_typography.dart';
import 'package:project_x/features/auth/domain/models/country.dart';
import 'package:project_x/features/auth/presentation/controllers/auth_controller.dart';
import 'package:project_x/features/auth/presentation/widgets/header_buttons.dart';
import 'package:project_x/features/auth/presentation/widgets/otp_input_widget.dart';
import 'package:project_x/features/auth/presentation/widgets/primary_button.dart';
import 'package:project_x/services/auth_service.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final Country country;
  final String phone;
  final String fullNumber;

  const OtpVerificationScreen({
    super.key,
    required this.country,
    required this.phone,
    required this.fullNumber,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  String _otpCode = '';
  bool _isLoading = false;
  String? _errorMessage;

  Timer? _timer;
  int _secondsRemaining = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      _secondsRemaining = 30;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleResend() {
    if (!_canResend) return;

    _startCountdown();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Verification code resent to ${widget.fullNumber}',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.textDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleVerify() async {
    if (_otpCode.length < 6) {
      setState(() {
        _errorMessage = 'Please enter the complete 6-digit code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = ref.read(authServiceProvider);

    // Check if user's phone number is already registered in database
    final isRegistered = await authService.isPhoneRegistered(widget.phone);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (isRegistered) {
      // Existing User -> Direct redirect to Homepage!
      ref.read(authControllerProvider.notifier).login();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Welcome back! Existing account found.',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      context.go(AppRoutes.home);
    } else {
      // First-time User -> Navigate to Page 3 (Profile Setup)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'New user detected! Please complete Profile Setup.',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.textDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      context.push(
        AppRoutes.profileSetup,
        extra: {'phoneNumber': widget.fullNumber},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerFormatted = '00:${_secondsRemaining.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Ambient yellow glow background accent
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
                    Color(0xFFFFF9C4),
                    Color(0x00FFF9C4),
                  ],
                  radius: 0.85,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      AppBackButton(
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'OTP Verification',
                        style: AppTypography.titleMedium,
                      ),
                      const Spacer(),
                      const AppHelpButton(),
                    ],
                  ),
                ),

                // Main Content Body
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),

                        // Title
                        Text(
                          'Enter verification\ncode',
                          style: AppTypography.headingLarge,
                        ),

                        const SizedBox(height: 14),

                        // Subtitle with formatted phone number
                        Text.rich(
                          TextSpan(
                            text: 'We have sent an SMS with a 6-digit verification code to ',
                            style: AppTypography.bodyMedium,
                            children: [
                              TextSpan(
                                text: widget.fullNumber,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // OTP Input 6-Digit Slots
                        OtpInputWidget(
                          length: 6,
                          onChanged: (code) {
                            setState(() {
                              _otpCode = code;
                              if (_errorMessage != null) _errorMessage = null;
                            });
                          },
                          onCompleted: (code) {
                            setState(() {
                              _otpCode = code;
                            });
                            _handleVerify();
                          },
                        ),

                        // Error Message
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.error),
                              const SizedBox(width: 4),
                              Text(
                                _errorMessage!,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 28),

                        // Resend Countdown Timer / Action
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Didn\'t receive code?',
                              style: AppTypography.caption,
                            ),
                            Semantics(
                              label: 'Resend code',
                              button: true,
                              enabled: _canResend,
                              child: InkWell(
                                onTap: _canResend ? _handleResend : null,
                                borderRadius: BorderRadius.circular(4),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  child: Text(
                                    _canResend ? 'Resend SMS' : 'Resend in $timerFormatted',
                                    style: _canResend
                                        ? AppTypography.captionBold
                                        : GoogleFonts.inter(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textMuted,
                                          ),
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

                // Bottom Sticky Verify Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                  child: PrimaryButton(
                    text: 'Verify & Proceed',
                    isLoading: _isLoading,
                    onPressed: _handleVerify,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
