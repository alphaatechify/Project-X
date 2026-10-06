import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_x/app/theme/app_colors.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon = Icons.arrow_forward_rounded,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return Semantics(
      label: widget.text,
      button: true,
      enabled: isEnabled,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: isEnabled ? widget.onPressed : null,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 56,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isEnabled ? AppColors.primaryYellow : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(28),
                boxShadow: isEnabled
                    ? [
                        BoxShadow(
                          color: AppColors.primaryYellow.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.textDark),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.text,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isEnabled ? AppColors.textDark : AppColors.textMuted,
                            ),
                          ),
                          if (widget.icon != null) ...[
                            const SizedBox(width: 8),
                            Icon(
                              widget.icon,
                              size: 20,
                              color: isEnabled ? AppColors.textDark : AppColors.textMuted,
                            ),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
