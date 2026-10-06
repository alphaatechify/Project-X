import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_x/app/theme/app_colors.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const AppBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Back',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () => Navigator.of(context).maybePop(),
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                CupertinoIcons.chevron_left,
                size: 18,
                color: AppColors.textDark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppHelpButton extends StatelessWidget {
  final VoidCallback? onTap;

  const AppHelpButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Help',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ??
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Help: Enter your 10-digit mobile number for verification.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                CupertinoIcons.question_circle,
                size: 20,
                color: AppColors.textDark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
