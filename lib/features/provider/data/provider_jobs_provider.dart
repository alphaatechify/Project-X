import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/provider_job_model.dart';

class ProviderJobsNotifier extends StateNotifier<List<ProviderJobModel>> {
  ProviderJobsNotifier() : super(_initialJobs);

  static final List<ProviderJobModel> _initialJobs = [
    // 1. Ongoing active job
    const ProviderJobModel(
      id: 'JOB-901',
      title: 'Kitchen Sink Drainage Blockage Clearing',
      category: 'Plumbing',
      customerName: 'Vikram Seth',
      customerPhone: '+91 98112 33445',
      address: 'House 88, 5th Cross, Indiranagar Stage 1, Bengaluru',
      serviceDetails: 'Heavy drain blockage in kitchen sink with water backflow. Power rotary snake inspection underway.',
      payoutAmount: 450.0,
      estimatedDuration: '30 mins',
      status: ProviderJobStatus.active,
      date: 'Today, 10:15 AM',
      otp: '4821',
    ),

    // 2. Pending / Left incomplete jobs (Pending chhode gaye)
    const ProviderJobModel(
      id: 'JOB-842',
      title: 'Under-Sink PVC Trap & Copper Pipe Replacement',
      category: 'Plumbing',
      customerName: 'Ananya Deshmukh',
      customerPhone: '+91 98221 44556',
      address: 'Villa 14, Palm Meadows, Whitefield, Bengaluru',
      serviceDetails: 'Main corroded PVC trap dismantled. Specialized 1.5-inch threaded brass pipe needed from wholesale distributor.',
      payoutAmount: 720.0,
      estimatedDuration: '45 mins',
      status: ProviderJobStatus.pendingDropped,
      date: 'Today, 08:30 AM',
      pendingReason: 'Spare Part Awaited: 1.5-inch threaded brass elbow not available locally. Vendor shipment reaching Indiranagar hub by 3:00 PM.',
      pendingActionNotes: 'Customer informed. Next slot scheduled for today at 4:30 PM.',
      otp: '7392',
    ),
    const ProviderJobModel(
      id: 'JOB-819',
      title: 'Pressure Booster Pump Installation & Testing',
      category: 'Plumbing',
      customerName: 'Rohan Kapoor',
      customerPhone: '+91 97401 88990',
      address: 'Flat 402, Sunshine Heights, 12th Main, HAL 2nd Stage, Bengaluru',
      serviceDetails: 'Pump mounting complete. Power supply inlet box trip due to dedicated MCB fault in customer switchboard.',
      payoutAmount: 950.0,
      estimatedDuration: '1 hr',
      status: ProviderJobStatus.pendingDropped,
      date: 'Yesterday, 04:45 PM',
      pendingReason: 'Electrical Interlock Pending: Society electrician needs to replace 16A trip breaker before running motor load test.',
      pendingActionNotes: 'Customer coordinated with society facility manager. Work to resume tomorrow 10:00 AM.',
      otp: '2941',
    ),
    const ProviderJobModel(
      id: 'JOB-798',
      title: 'Overhead Tank Float Valve & Overflow Fixing',
      category: 'Plumbing',
      customerName: 'Kavita Menon',
      customerPhone: '+91 98451 22334',
      address: 'B-104, Green Glen Heights, Bellandur, Bengaluru',
      serviceDetails: 'Rooftop inspection done. Tank lock key held by building supervisor who was unavailable on-site.',
      payoutAmount: 380.0,
      estimatedDuration: '30 mins',
      status: ProviderJobStatus.pendingDropped,
      date: '13 Oct 2026, 02:15 PM',
      pendingReason: 'Site Access Delayed: Terrace water tank enclosure locked by society management during afternoon hours.',
      pendingActionNotes: 'Customer rescheduled appointment for Saturday morning 9:00 AM.',
      otp: '6105',
    ),

    // 3. Completed jobs (Services successfully delivered)
    const ProviderJobModel(
      id: 'JOB-889',
      title: 'Emergency Bathroom Pipe Leakage & Brass Valve Replacement',
      category: 'Plumbing',
      customerName: 'Priya Sharma',
      customerPhone: '+91 98450 12345',
      address: 'Flat 302, Palm Grove, HAL 2nd Stage, Indiranagar, Bengaluru',
      serviceDetails: 'Main valve replaced with heavy-duty brass ball valve and Teflon seal. High-pressure testing passed.',
      payoutAmount: 650.0,
      estimatedDuration: '35 mins',
      status: ProviderJobStatus.completed,
      date: 'Today, 09:00 AM',
      completedAt: 'Today, 09:42 AM',
      rating: 5.0,
      customerFeedback: 'Instant emergency arrival within 15 minutes! Very neat and professional repair work.',
      otp: '5824',
    ),
    const ProviderJobModel(
      id: 'JOB-860',
      title: 'Master Bathroom Mixer Tap & Hand Shower Installation',
      category: 'Plumbing',
      customerName: 'Arjun Nambiar',
      customerPhone: '+91 99882 11223',
      address: 'Flat 701, Skyline Towers, Koramangala 4th Block, Bengaluru',
      serviceDetails: 'Wall-mount diverter installed, water aerator cleaned, silicone waterproof perimeter applied.',
      payoutAmount: 520.0,
      estimatedDuration: '40 mins',
      status: ProviderJobStatus.completed,
      date: 'Yesterday, 02:00 PM',
      completedAt: 'Yesterday, 02:45 PM',
      rating: 4.9,
      customerFeedback: 'Polite and skilled technician. Completed tap fitment flawlessly.',
      otp: '3318',
    ),
    const ProviderJobModel(
      id: 'JOB-835',
      title: 'Kitchen RO Water Purifier Inlet Valve Fitment',
      category: 'Plumbing',
      customerName: 'Meera Sengupta',
      customerPhone: '+91 98765 44332',
      address: 'Apt 205, Silver Oak Enclave, Domlur, Bengaluru',
      serviceDetails: 'Diverter tee installed into angle cock pipeline. No drip test verified.',
      payoutAmount: 320.0,
      estimatedDuration: '25 mins',
      status: ProviderJobStatus.completed,
      date: 'Yesterday, 11:30 AM',
      completedAt: 'Yesterday, 11:58 AM',
      rating: 5.0,
      customerFeedback: 'Quick fix, no mess left behind. Highly satisfied!',
      otp: '8872',
    ),
    const ProviderJobModel(
      id: 'JOB-812',
      title: 'Concealed Pipeline Thermal Leak Detection & Sealing',
      category: 'Plumbing',
      customerName: 'Deepak Varma',
      customerPhone: '+91 97654 32190',
      address: 'No. 45, 14th Main, HSR Layout Sector 3, Bengaluru',
      serviceDetails: 'Acoustic & thermal camera inspection found micro-fracture behind shower tile wall. Epoxy grout seal applied.',
      payoutAmount: 1400.0,
      estimatedDuration: '1.5 hrs',
      status: ProviderJobStatus.completed,
      date: '13 Oct 2026, 04:00 PM',
      completedAt: '13 Oct 2026, 05:25 PM',
      rating: 5.0,
      customerFeedback: 'Saved our tiles from getting broken! Identified exact leak spot quickly.',
      otp: '9154',
    ),
    const ProviderJobModel(
      id: 'JOB-790',
      title: 'Balcony Washing Machine Dual Drain Tap Setup',
      category: 'Plumbing',
      customerName: 'Sanjay Hegde',
      customerPhone: '+91 98102 99887',
      address: 'House 12, Defense Colony, Indiranagar, Bengaluru',
      serviceDetails: 'Dual-way bib tap installed with reinforced drain extension pipe.',
      payoutAmount: 480.0,
      estimatedDuration: '30 mins',
      status: ProviderJobStatus.completed,
      date: '12 Oct 2026, 01:15 PM',
      completedAt: '12 Oct 2026, 01:48 PM',
      rating: 4.8,
      customerFeedback: 'Neat work and checked both machines thoroughly before leaving.',
      otp: '4071',
    ),
    const ProviderJobModel(
      id: 'JOB-775',
      title: 'Geyser Inlet & Outlet Braided Steel Hose Replacement',
      category: 'Plumbing',
      customerName: 'Rashmi Kulkarni',
      customerPhone: '+91 99001 77665',
      address: 'Flat 110, Lakeview Apts, Old Airport Road, Bengaluru',
      serviceDetails: 'High-temperature braided hoses replaced with washer seal and Teflon.',
      payoutAmount: 390.0,
      estimatedDuration: '25 mins',
      status: ProviderJobStatus.completed,
      date: '11 Oct 2026, 10:00 AM',
      completedAt: '11 Oct 2026, 10:28 AM',
      rating: 5.0,
      customerFeedback: 'Courteous technician and genuine parts installed.',
      otp: '1982',
    ),
    const ProviderJobModel(
      id: 'JOB-760',
      title: 'Toilet Flush Cistern Dual Syphon Kit Replacement',
      category: 'Plumbing',
      customerName: 'Tanvi Goyal',
      customerPhone: '+91 98450 66778',
      address: 'Penthouse 12, Brigade Gateway, Malleshwaram, Bengaluru',
      serviceDetails: 'Dual flush push mechanism replaced, silent fill valve adjusted to 6L capacity.',
      payoutAmount: 550.0,
      estimatedDuration: '35 mins',
      status: ProviderJobStatus.completed,
      date: '10 Oct 2026, 03:30 PM',
      completedAt: '10 Oct 2026, 04:10 PM',
      rating: 4.9,
      customerFeedback: 'Water leak stopped completely. Very happy with the fix.',
      otp: '6543',
    ),
    const ProviderJobModel(
      id: 'JOB-745',
      title: 'Underground Sump Submersible Pump Foot-Valve Repair',
      category: 'Plumbing',
      customerName: 'Mahesh Patil',
      customerPhone: '+91 98760 11223',
      address: 'Plot 78, 2nd Cross, Cambridge Layout, Bengaluru',
      serviceDetails: 'Foot valve de-clogged and primer suction line re-bled.',
      payoutAmount: 850.0,
      estimatedDuration: '50 mins',
      status: ProviderJobStatus.completed,
      date: '09 Oct 2026, 11:00 AM',
      completedAt: '09 Oct 2026, 11:55 AM',
      rating: 5.0,
      customerFeedback: 'Knows water pumps inside out. Restored water flow in no time.',
      otp: '8234',
    ),
    const ProviderJobModel(
      id: 'JOB-730',
      title: 'Main Kitchen Basin Tap Cartridge Replacement',
      category: 'Plumbing',
      customerName: 'Nisha Sundaram',
      customerPhone: '+91 99451 33221',
      address: 'Flat 503, Embassy Habitat, Vasanth Nagar, Bengaluru',
      serviceDetails: 'Ceramic quarter-turn disc cartridge installed with silicone grease.',
      payoutAmount: 350.0,
      estimatedDuration: '20 mins',
      status: ProviderJobStatus.completed,
      date: '08 Oct 2026, 05:00 PM',
      completedAt: '08 Oct 2026, 05:22 PM',
      rating: 4.8,
      customerFeedback: 'Fast and smooth tap repair.',
      otp: '3128',
    ),
    const ProviderJobModel(
      id: 'JOB-715',
      title: 'Terrace Rainwater Harvest Gutter Unclogging',
      category: 'Plumbing',
      customerName: 'Vinod Nair',
      customerPhone: '+91 97890 44556',
      address: 'No. 19, 7th Main, JP Nagar 3rd Phase, Bengaluru',
      serviceDetails: 'Leaf grating cleared, 4-inch downpipe flushed with high pressure hose.',
      payoutAmount: 600.0,
      estimatedDuration: '40 mins',
      status: ProviderJobStatus.completed,
      date: '07 Oct 2026, 09:30 AM',
      completedAt: '07 Oct 2026, 10:15 AM',
      rating: 5.0,
      customerFeedback: 'Very thorough cleaning. Thank you!',
      otp: '7761',
    ),
    const ProviderJobModel(
      id: 'JOB-702',
      title: 'Commercial Restaurant Grease Trap Deep Cleaning',
      category: 'Plumbing',
      customerName: 'Chef Rahul (Bistro 88)',
      customerPhone: '+91 98450 77889',
      address: '100ft Road, HAL 2nd Stage, Indiranagar, Bengaluru',
      serviceDetails: 'Commercial interceptor emptied, biological enzyme dosing done.',
      payoutAmount: 1800.0,
      estimatedDuration: '1.5 hrs',
      status: ProviderJobStatus.completed,
      date: '06 Oct 2026, 07:00 AM',
      completedAt: '06 Oct 2026, 08:35 AM',
      rating: 5.0,
      customerFeedback: 'Great professional service before opening hours.',
      otp: '5540',
    ),
    const ProviderJobModel(
      id: 'JOB-688',
      title: 'Water Softener Media Top-up & Regeneration Check',
      category: 'Plumbing',
      customerName: 'Girish Murthy',
      customerPhone: '+91 98112 88776',
      address: 'Rowhouse 6, Whispering Palms, Sarjapur Road, Bengaluru',
      serviceDetails: 'Ion-exchange resin level checked, 25kg vacuum salt pellet charged.',
      payoutAmount: 750.0,
      estimatedDuration: '45 mins',
      status: ProviderJobStatus.completed,
      date: '05 Oct 2026, 03:00 PM',
      completedAt: '05 Oct 2026, 03:48 PM',
      rating: 4.9,
      customerFeedback: 'Hardness tested and confirmed low. Excellent job.',
      otp: '2093',
    ),
  ];

  void completeJob(String jobId, {String? notes}) {
    state = [
      for (final job in state)
        if (job.id == jobId)
          job.copyWith(
            status: ProviderJobStatus.completed,
            completedAt: 'Just now',
            rating: 5.0,
            customerFeedback: notes ?? 'Customer verified via OTP. Service marked completed successfully.',
          )
        else
          job,
    ];
  }

  void markAsPending(String jobId, {required String reason, String? notes}) {
    state = [
      for (final job in state)
        if (job.id == jobId)
          job.copyWith(
            status: ProviderJobStatus.pendingDropped,
            pendingReason: reason,
            pendingActionNotes: notes ?? 'Pending follow-up required.',
          )
        else
          job,
    ];
  }

  void resumeJob(String jobId) {
    state = [
      for (final job in state)
        if (job.id == jobId)
          job.copyWith(
            status: ProviderJobStatus.active,
          )
        else
          job,
    ];
  }

  void addIncomingJob({
    required String title,
    required String category,
    required String customerName,
    required String customerPhone,
    required String address,
    required String serviceDetails,
    required double payoutAmount,
    required String estimatedDuration,
  }) {
    final newJob = ProviderJobModel(
      id: 'JOB-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      title: title,
      category: category,
      customerName: customerName,
      customerPhone: customerPhone,
      address: address,
      serviceDetails: serviceDetails,
      payoutAmount: payoutAmount,
      estimatedDuration: estimatedDuration,
      status: ProviderJobStatus.active,
      date: 'Just now',
      otp: '${1000 + (title.hashCode.abs() % 8999)}',
    );

    state = [newJob, ...state];
  }
}

final providerJobsProvider = StateNotifierProvider<ProviderJobsNotifier, List<ProviderJobModel>>((ref) {
  return ProviderJobsNotifier();
});

// Computed Providers for Statistics
final providerCompletedJobsProvider = Provider<List<ProviderJobModel>>((ref) {
  return ref.watch(providerJobsProvider).where((j) => j.isCompleted).toList();
});

final providerPendingJobsProvider = Provider<List<ProviderJobModel>>((ref) {
  return ref.watch(providerJobsProvider).where((j) => j.isPending).toList();
});

final providerActiveJobsProvider = Provider<List<ProviderJobModel>>((ref) {
  return ref.watch(providerJobsProvider).where((j) => j.isActive).toList();
});

final providerEarningsSummaryProvider = Provider<double>((ref) {
  final completed = ref.watch(providerCompletedJobsProvider);
  return completed.fold(0.0, (sum, j) => sum + j.payoutAmount);
});

final providerCompletionRateProvider = Provider<double>((ref) {
  final all = ref.watch(providerJobsProvider);
  final completed = all.where((j) => j.isCompleted).length;
  if (all.isEmpty) return 100.0;
  return (completed / all.length) * 100.0;
});
