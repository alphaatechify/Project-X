import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:project_x/app/theme/app_colors.dart';

class SupportDeskModal extends StatelessWidget {
  const SupportDeskModal({super.key});

  Future<void> _makeCall(BuildContext context, String number) async {
    final Uri phoneUri = Uri.parse('tel:$number');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dialing Support Desk ($number)...', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF15803D),
      ),
    );
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.only(top: 12, bottom: 24, left: 20, right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.support_agent_rounded, color: Color(0xFF0369A1), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Support & Help Desk',
                      style: GoogleFonts.plusJakartaSans(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    Text(
                      '24/7 Priority support for customers & providers',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 16),

          // Action 1: Live Chat
          _buildActionTile(
            context: context,
            icon: Icons.chat_bubble_outline_rounded,
            title: '24/7 Live Support Chat',
            subtitle: 'Connect with a support specialist in < 2 mins',
            badge: 'ONLINE',
            badgeBg: const Color(0xFFDCFCE7),
            badgeTextColor: const Color(0xFF15803D),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening 24/7 Live Support Chat session...', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  backgroundColor: AppColors.textDark,
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          // Action 2: Call Helpline
          _buildActionTile(
            context: context,
            icon: Icons.phone_callback_rounded,
            title: 'Call Toll-Free Helpline',
            subtitle: '1800-VOLT-HELP (1800 865 84357)',
            badge: 'TOLL-FREE',
            badgeBg: const Color(0xFFFEF08A),
            badgeTextColor: const Color(0xFF713F12),
            onTap: () => _makeCall(context, '180086584357'),
          ),
          const SizedBox(height: 10),

          // Action 3: Provider Earnings & Distribution FAQ
          _buildActionTile(
            context: context,
            icon: Icons.payments_outlined,
            title: 'Provider Earnings & Tax Guide',
            subtitle: 'Understand payouts, TDS, GST invoice & 0% commission',
            badge: 'GUIDE',
            badgeBg: const Color(0xFFF1F5F9),
            badgeTextColor: AppColors.textDark,
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening Provider Earnings & Tax Guide...', style: GoogleFonts.inter()),
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          // Action 4: Dispute Resolution
          _buildActionTile(
            context: context,
            icon: Icons.gavel_rounded,
            title: 'Dispute Resolution & Safety Center',
            subtitle: 'Raise service dispute or request 30-day warranty refund',
            badge: 'SLA 24H',
            badgeBg: const Color(0xFFFEE2E2),
            badgeTextColor: const Color(0xFF991B1B),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening Dispute Resolution Portal...', style: GoogleFonts.inter()),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeBg,
    required Color badgeTextColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: AppColors.textDark, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(6)),
                        child: Text(badge, style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w800, color: badgeTextColor)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
