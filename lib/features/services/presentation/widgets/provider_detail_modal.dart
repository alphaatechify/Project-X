import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_x/app/theme/app_colors.dart';
import '../../domain/models/provider_model.dart';
import '../../domain/models/service_model.dart';

class ProviderDetailModal extends StatelessWidget {
  final ServiceProviderModel provider;
  final ServiceModel service;
  final VoidCallback onBookNow;

  const ProviderDetailModal({
    super.key,
    required this.provider,
    required this.service,
    required this.onBookNow,
  });

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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle bar
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

            // Distance & Readiness Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF08A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '📍 Meter Distance: ${provider.formattedDistance}',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF854D0E),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: provider.isAvailableNow ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    provider.availabilityStatus,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: provider.isAvailableNow ? const Color(0xFF15803D) : const Color(0xFFB45309),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Top Header: Profile avatar & Name & Rating
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: provider.avatarBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      provider.avatarInitials,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              provider.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          if (provider.isVoltCertified) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.verified_rounded, size: 18, color: Color(0xFF0284C7)),
                          ],
                        ],
                      ),
                      if (provider.qualifications.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          provider.qualifications,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0284C7),
                          ),
                        ),
                      ],
                      if (provider.clinicOrFirmName.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          '🏥 ${provider.clinicOrFirmName}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 16, color: Color(0xFFD97706)),
                          const SizedBox(width: 4),
                          Text(
                            '${provider.rating}',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            ' (${provider.reviewCount} reviews)',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Key Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Completed Jobs',
                    value: '${provider.jobsCompleted}+',
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Experience',
                    value: '${provider.experienceYears} Years',
                    icon: Icons.workspace_premium_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Visiting Rate',
                    value: provider.price,
                    icon: Icons.payments_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // About Bio
            Text(
              'About Professional / Clinic',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              provider.bio,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            // Specialties
            Text(
              'Key Expertise & Services Offered',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.specialties.map((spec) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 14, color: Color(0xFF0284C7)),
                      const SizedBox(width: 4),
                      Text(
                        spec,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // CTA Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onBookNow();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: AppColors.textDark,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'Book Now with ${provider.name}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
