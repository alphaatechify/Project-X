import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_x/app/router/routes.dart';
import 'package:project_x/app/theme/app_colors.dart';
import '../../../../services/auth_service.dart';

class ProviderDashboardView extends ConsumerStatefulWidget {
  final VoidCallback? onSwitchToCustomer;

  const ProviderDashboardView({
    super.key,
    this.onSwitchToCustomer,
  });

  @override
  ConsumerState<ProviderDashboardView> createState() => _ProviderDashboardViewState();
}

class _ProviderDashboardViewState extends ConsumerState<ProviderDashboardView> {
  // Simulated incoming customer service requests (no earning/price tags)
  final List<Map<String, dynamic>> _incomingRequests = [
    {
      'id': 'REQ-101',
      'title': 'Emergency Pipe Leakage & Valve Repair',
      'category': 'Plumbing',
      'customer': 'Priya Sharma',
      'phone': '+91 98450 12345',
      'distance': '1.2 km away',
      'address': 'Flat 302, Palm Grove, HAL 2nd Stage, Indiranagar, Bengaluru',
      'serviceDetails': 'Main valve pipe is severely leaking water under kitchen sink. Urgent pipe seal and brass valve replacement needed.',
      'estimatedDuration': '30 - 45 mins',
      'isEmergency': true,
      'time': 'Just now',
    },
    {
      'id': 'REQ-102',
      'title': 'Ceiling Fan Installation & Switchboard Check',
      'category': 'Electrician',
      'customer': 'Karthik Raman',
      'phone': '+91 97412 88990',
      'distance': '2.4 km away',
      'address': 'No. 45, 12th Main, 100ft Rd, Indiranagar, Bengaluru',
      'serviceDetails': 'Installation of high-speed ceiling fan and checking for spark in master bedroom 3-pin switchboard.',
      'estimatedDuration': '45 - 60 mins',
      'isEmergency': false,
      'time': '5 mins ago',
    },
    {
      'id': 'REQ-103',
      'title': 'AC Deep Foam Cleaning & Filter Service',
      'category': 'Home Appliances',
      'customer': 'Ananya Rao',
      'phone': '+91 99001 44552',
      'distance': '3.1 km away',
      'address': 'Villa 14, Windmills Estate, Domlur, Bengaluru',
      'serviceDetails': '1.5 Ton Split AC cooling problem with dusty blower wheel. Complete foam wash & filter service needed.',
      'estimatedDuration': '1 - 1.5 hrs',
      'isEmergency': false,
      'time': '12 mins ago',
    },
  ];

  // Active accepted jobs
  final List<Map<String, dynamic>> _activeJobs = [
    {
      'id': 'JOB-901',
      'title': 'Kitchen Sink Drainage Blockage Clearing',
      'category': 'Plumbing',
      'customer': 'Vikram Seth',
      'phone': '+91 98112 33445',
      'address': 'House 88, 5th Cross, Indiranagar Stage 1, Bengaluru',
      'serviceDetails': 'Heavy drain blockage in kitchen sink with water backup.',
      'estimatedDuration': '30 mins',
      'status': 'In Progress',
      'otp': '4821',
      'startedAt': '10:15 AM',
    },
  ];

  int _completedJobsCount = 12;
  double _serviceRadiusKm = 5.0;
  bool _hasAutoTriggeredPopup = false;

  @override
  void initState() {
    super.initState();
    // Auto popup incoming request after 1 second so provider immediately sees the live notification
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasAutoTriggeredPopup && _incomingRequests.isNotEmpty) {
        _hasAutoTriggeredPopup = true;
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted && _incomingRequests.isNotEmpty) {
            _showRequestNotificationDialog(_incomingRequests.first);
          }
        });
      }
    });
  }

  void _acceptRequest(Map<String, dynamic> request) {
    setState(() {
      _incomingRequests.removeWhere((r) => r['id'] == request['id']);
      _activeJobs.insert(0, {
        'id': 'JOB-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        'title': request['title'],
        'category': request['category'],
        'customer': request['customer'],
        'phone': request['phone'],
        'address': request['address'],
        'serviceDetails': request['serviceDetails'],
        'estimatedDuration': request['estimatedDuration'],
        'status': 'Accepted • On The Way',
        'otp': '${1000 + (request['id'].hashCode.abs() % 8999)}',
        'startedAt': 'Just now',
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Job Accepted! Customer ${request['customer']} notified you are on the way.',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF15803D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _declineRequest(String requestId) {
    setState(() {
      _incomingRequests.removeWhere((r) => r['id'] == requestId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Request passed to next nearest service partner', style: GoogleFonts.inter()),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// PROMINENT INCOMING REQUEST NOTIFICATION POPUP
  /// Displays Customer Name, Contact, Address, and Required Service
  void _showRequestNotificationDialog(Map<String, dynamic> req) {
    final isEmergency = req['isEmergency'] == true;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Popup Top Header with Emergency / Dispatch Alert
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isEmergency ? const Color(0xFFFEF2F2) : const Color(0xFFEFF6FF),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border(
                      bottom: BorderSide(
                        color: isEmergency ? const Color(0xFFFECACA) : const Color(0xFFDBEAFE),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isEmergency ? const Color(0xFFDC2626) : const Color(0xFF2563EB),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isEmergency ? Icons.notification_important_rounded : Icons.notifications_active_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEmergency ? '🚨 EMERGENCY SERVICE REQUEST' : '🔔 NEW INCOMING CUSTOMER REQUEST',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: isEmergency ? const Color(0xFFDC2626) : const Color(0xFF1E40AF),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Instant dispatch request • ${req['distance']}',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isEmergency ? const Color(0xFF991B1B) : const Color(0xFF1E3A8A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textSecondary),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                // 2. Main Details Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer Name & Contact Section
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: AppColors.primaryYellow,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  (req['customer'] as String).substring(0, 1),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'CUSTOMER',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textSecondary,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDCFCE7),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'VERIFIED',
                                          style: GoogleFonts.inter(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF15803D),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    req['customer'] ?? '',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone_outlined, size: 13, color: AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        req['phone'] ?? '',
                                        style: GoogleFonts.inter(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF0369A1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Direct Call Button
                            InkWell(
                              onTap: () {
                                _callCustomer(req['customer'], req['phone']);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF86EFAC)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.call, size: 14, color: Color(0xFF15803D)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Call',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF15803D),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Service Needed Section (Kya Service Chahiye)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.build_rounded, size: 14, color: Color(0xFF854D0E)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'REQUIRED SERVICE',
                                      style: GoogleFonts.inter(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF854D0E),
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFFDE68A)),
                                  ),
                                  child: Text(
                                    req['category'] ?? '',
                                    style: GoogleFonts.inter(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF92400E),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              req['title'] ?? '',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              req['serviceDetails'] ?? 'On-site diagnosis, repair and replacement.',
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                color: const Color(0xFF78350F),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.timer_outlined, size: 13, color: Color(0xFF854D0E)),
                                const SizedBox(width: 4),
                                Text(
                                  'Estimated Duration: ${req['estimatedDuration']}',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF854D0E),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Customer Address Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF2563EB)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'CUSTOMER LOCATION',
                                      style: GoogleFonts.inter(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF2563EB),
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    req['distance'] ?? '',
                                    style: GoogleFonts.inter(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1D4ED8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              req['address'] ?? '',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Action Buttons (Decline / Accept Job)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                    border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            _declineRequest(req['id']);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(
                            'Decline',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13.5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            _acceptRequest(req);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryYellow,
                            foregroundColor: AppColors.textDark,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.textDark),
                              const SizedBox(width: 8),
                              Text(
                                'Accept Request',
                                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _completeJob(Map<String, dynamic> job) {
    setState(() {
      _activeJobs.removeWhere((j) => j['id'] == job['id']);
      _completedJobsCount += 1;
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_rounded, color: Color(0xFF15803D), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Service Completed!',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Job successfully verified and completed for ${job['customer']}.',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark, height: 1.4),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Customer:', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                      Text(job['customer'] ?? '', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Service:', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                      Text(job['category'] ?? 'General', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('OTP Verification:', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                      Text('Verified (${job['otp']})', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF15803D))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Quality Review:', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                      Text('Feedback Request Sent', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF2563EB))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: AppColors.textDark,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Done', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _callCustomer(String name, String phone) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF15803D), size: 22),
            const SizedBox(width: 10),
            Text('Contact Customer', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: $name', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const SizedBox(height: 4),
            Text('Phone: $phone', style: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF0369A1), fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Text('Calling customer for address coordinates and service check.', style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Simulated call connecting to $name at $phone...'), behavior: SnackBarBehavior.floating),
              );
            },
            icon: const Icon(Icons.call, size: 16),
            label: const Text('Call Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF15803D),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLive = ref.watch(isProviderLiveProvider);
    final profile = ref.watch(currentUserProfileProvider);
    final providerName = (profile != null && profile.fullName.isNotEmpty) ? profile.fullName : 'Expert Provider';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // 1. Header Banner with Status, Notification Bell, & Mode Switch
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryYellow,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.engineering_rounded, color: AppColors.textDark, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'PROVIDER CONSOLE',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryYellow,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        color: isLive ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'PRO PARTNER',
                                        style: GoogleFonts.inter(fontSize: 8.5, fontWeight: FontWeight.w800, color: Colors.white70),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  providerName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // Notification Bell with Badge (Tapping pops up incoming request)
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (_incomingRequests.isNotEmpty) {
                                    _showRequestNotificationDialog(_incomingRequests.first);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('No new pending customer requests at the moment.'),
                                        duration: Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 22),
                                tooltip: 'New Requests Notification',
                              ),
                              if (_incomingRequests.isNotEmpty)
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEF4444),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${_incomingRequests.length}',
                                      style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 4),

                          // Switch to Customer Mode Button
                          InkWell(
                            onTap: () {
                              ref.read(appUserModeProvider.notifier).setMode(AppUserMode.customer);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Switched to Customer Mode',
                                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF475569)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.swap_horiz_rounded, size: 14, color: AppColors.primaryYellow),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Customer View',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Online / Offline Status Toggle Bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isLive ? const Color(0xFF064E3B).withValues(alpha: 0.6) : const Color(0xFF1E293B).withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isLive ? const Color(0xFF10B981).withValues(alpha: 0.5) : const Color(0xFF475569),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: isLive ? const Color(0xFF10B981).withValues(alpha: 0.2) : Colors.white10,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isLive ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                    color: isLive ? const Color(0xFF4ADE80) : const Color(0xFF94A3B8),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isLive ? 'ONLINE • ACCEPTING DISPATCHES' : 'OFFLINE • DUTY PAUSED',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                        color: isLive ? const Color(0xFF86EFAC) : const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    Text(
                                      isLive
                                          ? 'Receiving orders within ${_serviceRadiusKm.toInt()} km radius'
                                          : 'Turn ON to accept nearby customer tasks',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Switch.adaptive(
                              value: isLive,
                              activeTrackColor: AppColors.primaryYellow,
                              onChanged: (val) {
                                ref.read(isProviderLiveProvider.notifier).state = val;
                                if (val && _incomingRequests.isNotEmpty) {
                                  _showRequestNotificationDialog(_incomingRequests.first);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // 2. High-Visibility Heads-up Notification Alert Banner (Tapping triggers popup)
              if (_incomingRequests.isNotEmpty && isLive)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: InkWell(
                    onTap: () => _showRequestNotificationDialog(_incomingRequests.first),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFCA5A5), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: const BoxDecoration(
                              color: Color(0xFFDC2626),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.ring_volume_rounded, color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'NEW REQUEST ALERT',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFFDC2626),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '• ${_incomingRequests.first['distance']}',
                                      style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: const Color(0xFF991B1B)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_incomingRequests.first['customer']} needs ${_incomingRequests.first['title']}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF991B1B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'View Popup',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // 3. Operational Performance Cards (Zero Earning references)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Completed',
                        value: '$_completedJobsCount',
                        subtitle: '100% on-time arrival',
                        icon: Icons.task_alt_rounded,
                        accentColor: const Color(0xFF15803D),
                        bgColor: const Color(0xFFF0FDF4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Active Queue',
                        value: '${_activeJobs.length} Ongoing',
                        subtitle: '${_incomingRequests.length} waiting nearby',
                        icon: Icons.handyman_rounded,
                        accentColor: const Color(0xFF0369A1),
                        bgColor: const Color(0xFFF0F9FF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Service Rating',
                        value: '4.9 ★',
                        subtitle: '98% Acceptance Rate',
                        icon: Icons.star_rounded,
                        accentColor: const Color(0xFFB45309),
                        bgColor: const Color(0xFFFEF3C7),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // 4. Ongoing / Active Jobs Section
              if (_activeJobs.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFF15803D),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Active Jobs In Progress',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_activeJobs.length} ONGOING',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ..._activeJobs.map((job) => _buildActiveJobCard(job)),
                const SizedBox(height: 20),
              ],

              // 5. Live Incoming Requests Radar (Tap on any request opens the full details popup)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFEF08A),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.radar_rounded, size: 16, color: Color(0xFF854D0E)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Nearby Customer Requests',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '${_incomingRequests.length} Available',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.touch_app_outlined, size: 14, color: AppColors.textSecondary),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              if (_incomingRequests.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 40, color: Color(0xFF15803D)),
                        const SizedBox(height: 10),
                        Text(
                          'All caught up!',
                          style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Keep your status ONLINE to receive real-time bookings from nearby customers.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._incomingRequests.map((req) => _buildIncomingRequestCard(req)),

              const SizedBox(height: 24),

              // 6. Operational Tools & Management (No Earning / Bank Payouts)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Service Operations & Settings',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                  ),
                  child: Column(
                    children: [
                      _buildToolTile(
                        icon: Icons.tune_rounded,
                        iconBg: const Color(0xFFFEF08A),
                        iconColor: const Color(0xFF854D0E),
                        title: 'Service Categories & Skills',
                        subtitle: 'Manage active categories, sub-services & equipment profile',
                        onTap: () => context.push(AppRoutes.providerProfile),
                      ),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      _buildToolTile(
                        icon: Icons.map_rounded,
                        iconBg: const Color(0xFFEFF6FF),
                        iconColor: const Color(0xFF2563EB),
                        title: 'Service Geofence Radius: ${_serviceRadiusKm.toInt()} km',
                        subtitle: 'Adjust radial coverage area for incoming dispatch requests',
                        onTap: () {
                          setState(() {
                            _serviceRadiusKm = (_serviceRadiusKm == 5.0) ? 10.0 : (_serviceRadiusKm == 10.0) ? 3.0 : 5.0;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Service radius set to ${_serviceRadiusKm.toInt()} km'),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      _buildToolTile(
                        icon: Icons.schedule_rounded,
                        iconBg: const Color(0xFFF0FDF4),
                        iconColor: const Color(0xFF15803D),
                        title: 'Working Hours & Shifts',
                        subtitle: 'Active roster: Monday – Saturday • 8:00 AM – 8:00 PM',
                        onTap: () {
                          _showScheduleDialog(context);
                        },
                      ),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      _buildToolTile(
                        icon: Icons.verified_user_rounded,
                        iconBg: const Color(0xFFF5F3FF),
                        iconColor: const Color(0xFF7C3AED),
                        title: 'Verification Vault & Badges',
                        subtitle: 'Aadhaar KYC verified • Emergency Quick Dispatch active',
                        onTap: () => context.push(AppRoutes.providerProfile),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showScheduleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.schedule_rounded, color: Color(0xFF15803D), size: 22),
            const SizedBox(width: 10),
            Text('Availability Schedule', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 17)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your service status automatically accepts requests during active shifts.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 14),
            _buildScheduleRow('Monday - Friday', '8:00 AM - 8:00 PM', true),
            const SizedBox(height: 8),
            _buildScheduleRow('Saturday', '9:00 AM - 6:00 PM', true),
            const SizedBox(height: 8),
            _buildScheduleRow('Sunday', 'Emergency Only', false),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: AppColors.textDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save & Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleRow(String day, String timing, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              timing,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isActive ? const Color(0xFF15803D) : const Color(0xFFB45309),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 19),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveJobCard(Map<String, dynamic> job) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    job['status'] ?? 'Active Job',
                    style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w800, color: const Color(0xFF92400E)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 12, color: Color(0xFF854D0E)),
                      const SizedBox(width: 4),
                      Text(
                        job['estimatedDuration'] ?? '30 mins',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF854D0E)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              job['title'] ?? '',
              style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            if (job['serviceDetails'] != null) ...[
              const SizedBox(height: 4),
              Text(
                job['serviceDetails'] as String,
                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF78350F)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(job['customer'] ?? '', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                  child: Text('OTP: ${job['otp']}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF15803D))),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(job['address'] ?? '', style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _callCustomer(job['customer'], job['phone']),
                  icon: const Icon(Icons.phone_rounded, size: 14),
                  label: const Text('Call'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textDark,
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _completeJob(job),
                    icon: const Icon(Icons.task_alt_rounded, size: 16),
                    label: Text(
                      'Complete Job',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF15803D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomingRequestCard(Map<String, dynamic> req) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: InkWell(
        onTap: () => _showRequestNotificationDialog(req),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: req['isEmergency'] == true ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
              width: req['isEmergency'] == true ? 1.5 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (req['isEmergency'] == true) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFF87171)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.flash_on_rounded, size: 12, color: Color(0xFFDC2626)),
                              const SizedBox(width: 2),
                              Text(
                                'EMERGENCY DISPATCH',
                                style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w800, color: const Color(0xFFDC2626)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          req['distance'] ?? '',
                          style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700, color: const Color(0xFF2563EB)),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          req['estimatedDuration'] ?? '30 mins',
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textDark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                req['title'] ?? '',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              // Customer & Service Type
              Row(
                children: [
                  const Icon(Icons.person_rounded, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(req['customer'] ?? '', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(width: 8),
                  Text('• ${req['time']}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      req['category'] ?? '',
                      style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Customer Address
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      req['address'] ?? '',
                      style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _declineRequest(req['id']),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text('Decline', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () => _showRequestNotificationDialog(req),
                      icon: const Icon(Icons.open_in_new_rounded, size: 15),
                      label: Text('View Details', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13.5)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryYellow,
                        foregroundColor: AppColors.textDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
