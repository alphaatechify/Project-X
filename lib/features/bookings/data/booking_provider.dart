import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/data/service_repository.dart';
import '../../services/domain/models/provider_model.dart';
import '../../../core/supabase/supabase_database_service.dart';
import '../domain/models/booking_model.dart';

class BookingsNotifier extends StateNotifier<List<BookingModel>> {
  final Ref? _ref;
  BookingsNotifier([this._ref]) : super(_initialSeedBookings);

  static List<BookingModel> get _initialSeedBookings {
    // 1. Live accepted booking with Ramesh Kumar (Plumber)
    final ramesh = ServiceRepository.allProviders.firstWhere(
      (p) => p.name.contains('Ramesh'),
      orElse: () => ServiceRepository.allProviders.first,
    );

    // 2. Electrician provider (completed history)
    final electrician = ServiceRepository.allProviders.firstWhere(
      (p) => p.serviceId == 'electrician',
      orElse: () => ServiceRepository.allProviders[2],
    );

    // 3. Cleaning provider (completed history)
    final cleaner = ServiceRepository.allProviders.firstWhere(
      (p) => p.serviceId == 'cleaning',
      orElse: () => ServiceRepository.allProviders[4],
    );

    // 4. AC provider (cancelled history)
    final acTech = ServiceRepository.allProviders.firstWhere(
      (p) => p.serviceId == 'appliance',
      orElse: () => ServiceRepository.allProviders.last,
    );

    return [
      // ACTIVE BOOKING (REQUEST ACCEPTED BY PROVIDER)
      BookingModel(
        id: 'BK-9482',
        serviceId: 'plumbing',
        serviceTitle: 'Tap & Faucet Installation',
        serviceIcon: Icons.plumbing_rounded,
        provider: ramesh,
        status: BookingStatus.enRoute,
        bookedAt: DateTime.now().subtract(const Duration(minutes: 8)),
        scheduledTime: 'Today, Immediate (~15 mins)',
        address: 'Flat 402, Sunshine Heights, 12th Main, Indiranagar, Bengaluru',
        totalAmount: 398.0,
        serviceOtp: '5824',
        etaMinutes: 11,
        paymentMethod: 'Pay after service (UPI / Cash)',
        isPaid: false,
        customerNotes: 'Please bring 2 Teflon tapes and replacement brass washers.',
        items: const [
          BookingItem(title: 'Tap & Faucet Installation', quantity: 1, price: 99.0),
          BookingItem(title: 'Washbasin & Sink Repair', quantity: 1, price: 249.0),
          BookingItem(title: 'Standard Visiting & Safety Charge', quantity: 1, price: 50.0),
        ],
      ),

      // COMPLETED HISTORY 1
      BookingModel(
        id: 'BK-8921',
        serviceId: 'electrician',
        serviceTitle: 'Switchboard & MCB Fitting',
        serviceIcon: Icons.bolt_rounded,
        provider: electrician,
        status: BookingStatus.completed,
        bookedAt: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
        scheduledTime: '11 Oct 2026, 02:30 PM',
        address: 'Flat 402, Sunshine Heights, 12th Main, Indiranagar',
        totalAmount: 349.0,
        serviceOtp: '7103',
        paymentMethod: 'Paid online via Google Pay UPI',
        isPaid: true,
        ratingGiven: 5.0,
        reviewGiven: 'Extremely polite, brought genuine Anchor switches and tested with multimeter.',
        items: const [
          BookingItem(title: 'Modular Switchboard Installation', quantity: 2, price: 299.0),
          BookingItem(title: 'Safety Inspection Fee', quantity: 1, price: 50.0),
        ],
      ),

      // COMPLETED HISTORY 2
      BookingModel(
        id: 'BK-8340',
        serviceId: 'cleaning',
        serviceTitle: 'Full Home Deep Cleaning',
        serviceIcon: Icons.cleaning_services_rounded,
        provider: cleaner,
        status: BookingStatus.completed,
        bookedAt: DateTime.now().subtract(const Duration(days: 9)),
        scheduledTime: '5 Oct 2026, 10:00 AM',
        address: 'Flat 402, Sunshine Heights, 12th Main, Indiranagar',
        totalAmount: 1499.0,
        serviceOtp: '3941',
        paymentMethod: 'Paid online via HDFC Credit Card',
        isPaid: true,
        ratingGiven: 4.8,
        reviewGiven: 'Whole apartment was sparkling clean! Very professional scrub machines used.',
        items: const [
          BookingItem(title: '2 BHK Deep Cleaning Package', quantity: 1, price: 1399.0),
          BookingItem(title: 'Balcony Jet Wash', quantity: 1, price: 100.0),
        ],
      ),

      // CANCELLED HISTORY 3
      BookingModel(
        id: 'BK-7612',
        serviceId: 'appliance',
        serviceTitle: 'Split AC Gas Top-up & Coil Service',
        serviceIcon: Icons.ac_unit_rounded,
        provider: acTech,
        status: BookingStatus.cancelled,
        bookedAt: DateTime.now().subtract(const Duration(days: 18)),
        scheduledTime: '26 Sep 2026, 04:00 PM',
        address: 'Flat 402, Sunshine Heights, 12th Main, Indiranagar',
        totalAmount: 1250.0,
        serviceOtp: '8401',
        paymentMethod: 'Cash on Delivery',
        isPaid: false,
        customerNotes: 'Cancelled by customer: Plans changed for the weekend.',
        items: const [
          BookingItem(title: 'AC Gas Refill (R32 Eco-Safe)', quantity: 1, price: 1200.0),
          BookingItem(title: 'Visiting charge', quantity: 1, price: 50.0),
        ],
      ),
    ];
  }

  /// Create a new booking when customer accepts in radar map dialog
  String createBooking({
    required ServiceProviderModel provider,
    required String serviceTitle,
    required String serviceCategory,
    required IconData serviceIcon,
    required double totalAmount,
    required List<BookingItem> items,
    String? address,
    String? notes,
  }) {
    final random = Random();
    final otp = (1000 + random.nextInt(9000)).toString();
    final newId = 'BK-${2000 + random.nextInt(8000)}';

    final newBooking = BookingModel(
      id: newId,
      serviceId: serviceCategory,
      serviceTitle: serviceTitle,
      serviceIcon: serviceIcon,
      provider: provider,
      status: BookingStatus.accepted,
      bookedAt: DateTime.now(),
      scheduledTime: 'Today, Immediate (${provider.formattedDistance})',
      address: address ?? 'Flat 402, Sunshine Heights, 12th Main, Indiranagar, Bengaluru',
      totalAmount: totalAmount,
      serviceOtp: otp,
      etaMinutes: 14,
      paymentMethod: 'Pay after service (UPI / Cash)',
      isPaid: false,
      items: items,
      customerNotes: notes,
    );

    state = [newBooking, ...state];

    // Asynchronously call Supabase RPC if service is available
    _syncBookingToSupabase(newBooking, notes);

    return newId;
  }

  Future<void> _syncBookingToSupabase(BookingModel booking, String? notes) async {
    final ref = _ref;
    if (ref == null) return;
    try {
      final dbService = ref.read(supabaseDatabaseServiceProvider);
      final idempotencyKey = 'bk-${DateTime.now().millisecondsSinceEpoch}-${booking.id}';
      
      final payload = {
        'address': {
          'address_line1': booking.address,
          'city': 'Bengaluru',
          'state': 'Karnataka',
        },
        'customer_notes': notes,
        'items': [
          for (final item in booking.items)
            {
              // Pass quantity and metadata
              'quantity': item.quantity,
              'title': item.title,
            }
        ]
      };

      await dbService.createBooking(
        payload: payload,
        idempotencyKey: idempotencyKey,
      );
    } catch (_) {
      // Offline fallback: keep local state without interrupting UI
    }
  }

  void cancelBooking(String bookingId, {String? reason}) {
    state = [
      for (final b in state)
        if (b.id == bookingId)
          b.copyWith(
            status: BookingStatus.cancelled,
            reviewGiven: reason ?? 'Cancelled by customer',
          )
        else
          b,
    ];

    final ref = _ref;
    if (ref != null) {
      try {
        final dbService = ref.read(supabaseDatabaseServiceProvider);
        dbService.transitionBooking(
          bookingId: bookingId,
          targetStatus: 'cancelled',
          reasonCode: reason,
        );
      } catch (_) {}
    }
  }

  void rateBooking(String bookingId, double rating, String review) {
    state = [
      for (final b in state)
        if (b.id == bookingId)
          b.copyWith(
            ratingGiven: rating,
            reviewGiven: review,
          )
        else
          b,
    ];
  }

  void updateStatus(String bookingId, BookingStatus newStatus) {
    state = [
      for (final b in state)
        if (b.id == bookingId)
          b.copyWith(
            status: newStatus,
            isPaid: newStatus == BookingStatus.completed ? true : b.isPaid,
          )
        else
          b,
    ];

    final ref = _ref;
    if (ref != null) {
      try {
        final dbService = ref.read(supabaseDatabaseServiceProvider);
        dbService.transitionBooking(
          bookingId: bookingId,
          targetStatus: newStatus.name,
        );
      } catch (_) {}
    }
  }
}

final bookingsProvider = StateNotifierProvider<BookingsNotifier, List<BookingModel>>((ref) {
  return BookingsNotifier(ref);
});
