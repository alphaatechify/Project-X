import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:project_x/app/theme/app_colors.dart';

class EmergencyContactItem {
  final String title;
  final String subtitle;
  final String number;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  const EmergencyContactItem({
    required this.title,
    required this.subtitle,
    required this.number,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });
}

class EmergencyServicesModal extends StatelessWidget {
  const EmergencyServicesModal({super.key});

  static const List<EmergencyContactItem> _contacts = [
    EmergencyContactItem(
      title: 'Police Emergency',
      subtitle: 'Law enforcement, crime reporting & immediate safety',
      number: '112',
      icon: Icons.local_police_rounded,
      iconBgColor: Color(0xFFEFF6FF),
      iconColor: Color(0xFF1D4ED8),
    ),
    EmergencyContactItem(
      title: 'Ambulance & Medical Emergency',
      subtitle: 'Trauma care, patient transport & hospital dispatch',
      number: '108',
      icon: Icons.medical_services_rounded,
      iconBgColor: Color(0xFFFEF2F2),
      iconColor: Color(0xFFDC2626),
    ),
    EmergencyContactItem(
      title: 'Women Helpline',
      subtitle: '24/7 women safety, protection & emergency assistance',
      number: '1091',
      icon: Icons.shield_rounded,
      iconBgColor: Color(0xFFFDF2F8),
      iconColor: Color(0xFFDB2777),
    ),
    EmergencyContactItem(
      title: 'Fire Brigade',
      subtitle: 'Fire outbreak, rescue operations & hazard control',
      number: '101',
      icon: Icons.local_fire_department_rounded,
      iconBgColor: Color(0xFFFFF7ED),
      iconColor: Color(0xFFEA580C),
    ),
    EmergencyContactItem(
      title: 'National Emergency Helpline',
      subtitle: 'Single unified emergency response system (ERS)',
      number: '112',
      icon: Icons.sos_rounded,
      iconBgColor: Color(0xFFFEF2F2),
      iconColor: Color(0xFFB91C1C),
    ),
  ];

  Future<void> _makeCall(BuildContext context, EmergencyContactItem item) async {
    final Uri phoneUri = Uri.parse('tel:${item.number}');
    
    // Show instant feedback SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Calling ${item.title} (${item.number})...',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF166534),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Fallback if URL launcher fails on desktop/web environment without telehandler
    }
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
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header Title
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(Icons.sos_rounded, color: Color(0xFFDC2626), size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Hotlines',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      'Tap to call directly from your device 24/7',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
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

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 16),

          // Emergency Options List
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: _contacts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _contacts[index];
                return InkWell(
                  onTap: () => _makeCall(context, item),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: item.iconBgColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(item.icon, color: item.iconColor, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    item.title,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF166534),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.number,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item.subtitle,
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Call Now Button
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF15803D),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.call_rounded, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'CALL',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
