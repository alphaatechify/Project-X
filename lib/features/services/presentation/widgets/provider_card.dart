import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_x/app/theme/app_colors.dart';
import '../../domain/models/provider_model.dart';

class ProviderCard extends StatelessWidget {
  final ServiceProviderModel provider;
  final VoidCallback onViewProfile;
  final VoidCallback onBookNow;

  const ProviderCard({
    super.key,
    required this.provider,
    required this.onViewProfile,
    required this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    final isNearest = provider.distanceKm <= 0.9;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isNearest ? AppColors.primaryYellowDark : const Color(0xFFE2E8F0),
          width: isNearest ? 1.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Proximity / Distance Meter Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isNearest ? const Color(0xFFFEF08A) : AppColors.surfaceLightGray,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.near_me_rounded,
                      size: 13,
                      color: isNearest ? const Color(0xFF854D0E) : AppColors.textDark,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '📍 ${provider.formattedDistance}${isNearest ? " • NEAREST" : ""}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isNearest ? const Color(0xFF854D0E) : AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),

              // Rating Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF08A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: Color(0xFF854D0E)),
                    const SizedBox(width: 2),
                    Text(
                      '${provider.rating}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF854D0E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Main Header Row: Profile Avatar + Name + Qualifications & Clinic
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Stack with Online indicator
              Stack(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: provider.avatarBgColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: provider.avatarBgColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        provider.avatarInitials,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (provider.isAvailableNow)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // Name & Expertise Info
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
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (provider.isVoltCertified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF0284C7)),
                        ],
                      ],
                    ),
                    if (provider.qualifications.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        provider.qualifications,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0284C7),
                        ),
                      ),
                    ],
                    if (provider.clinicOrFirmName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.local_hospital_outlined, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Text(
                            provider.clinicOrFirmName,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 3),
                    Text(
                      'Specialty: ${provider.subCategory}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Expertise / Specialties Pills
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: provider.specialties.take(3).map((spec) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  spec,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          // Experience & Jobs Stats Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceLightGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  icon: Icons.work_outline_rounded,
                  label: '${provider.jobsCompleted}+ Jobs',
                ),
                Container(width: 1, height: 14, color: const Color(0xFFCBD5E1)),
                _buildStatItem(
                  icon: Icons.workspace_premium_outlined,
                  label: '${provider.experienceYears} Yrs Exp',
                ),
                Container(width: 1, height: 14, color: const Color(0xFFCBD5E1)),
                _buildStatItem(
                  icon: Icons.payments_outlined,
                  label: '${provider.price}${provider.priceUnit}',
                  isHighlight: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Availability Status Tag & Readiness Meter
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: provider.isAvailableNow ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      provider.isAvailableNow ? Icons.flash_on_rounded : Icons.schedule_rounded,
                      size: 13,
                      color: provider.isAvailableNow ? const Color(0xFF15803D) : const Color(0xFFB45309),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      provider.availabilityStatus,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: provider.isAvailableNow ? const Color(0xFF15803D) : const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '(${provider.reviewCount} reviews)',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Action Buttons: View Profile & Book Now
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onViewProfile,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    side: const BorderSide(color: AppColors.borderLight, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'View Profile',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: onBookNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    foregroundColor: AppColors.textDark,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Book Now',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    bool isHighlight = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 13,
          color: isHighlight ? AppColors.textDark : AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
            color: isHighlight ? AppColors.textDark : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
