import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:project_x/features/auth/domain/models/country.dart';

/// Renders country flags with high visual fidelity.
/// Special custom painter for India (IN) for pixel-perfect rendering across all devices.
class FlagWidget extends StatelessWidget {
  final Country country;
  final double width;
  final double height;

  const FlagWidget({
    super.key,
    required this.country,
    this.width = 24,
    this.height = 16,
  });

  @override
  Widget build(BuildContext context) {
    if (country.code == 'IN') {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(1.5),
          child: CustomPaint(
            size: Size(width, height),
            painter: _IndiaFlagPainter(),
          ),
        ),
      );
    }

    // Default flag emoji rendering for other countries
    return Text(
      country.flagEmoji,
      style: TextStyle(fontSize: height * 0.9),
    );
  }
}

class _IndiaFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stripeHeight = size.height / 3;

    // Saffron Top Stripe
    final saffronPaint = Paint()..color = const Color(0xFFFF9933);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, stripeHeight), saffronPaint);

    // White Middle Stripe
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, stripeHeight, size.width, stripeHeight), whitePaint);

    // Green Bottom Stripe
    final greenPaint = Paint()..color = const Color(0xFF138808);
    canvas.drawRect(Rect.fromLTWH(0, stripeHeight * 2, size.width, stripeHeight), greenPaint);

    // Ashoka Chakra (Navy Wheel)
    final navyPaint = Paint()
      ..color = const Color(0xFF000080)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = stripeHeight * 0.42;

    canvas.drawCircle(center, radius, navyPaint);

    // Draw Wheel Spokes
    final spokePaint = Paint()
      ..color = const Color(0xFF000080)
      ..strokeWidth = 0.5;

    for (int i = 0; i < 24; i++) {
      final angle = (i * 15) * (math.pi / 180);
      final dx = radius * math.cos(angle);
      final dy = radius * math.sin(angle);
      canvas.drawLine(center, Offset(center.dx + dx, center.dy + dy), spokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
