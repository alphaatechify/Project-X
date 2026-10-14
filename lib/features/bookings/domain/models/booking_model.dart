import 'package:flutter/material.dart';
import '../../../services/domain/models/provider_model.dart';

enum BookingStatus {
  pending,
  accepted,
  enRoute,
  inProgress,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case BookingStatus.pending:
        return 'Request Sent';
      case BookingStatus.accepted:
        return 'Provider Accepted';
      case BookingStatus.enRoute:
        return 'On the Way';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case BookingStatus.pending:
        return const Color(0xFFF59E0B);
      case BookingStatus.accepted:
        return const Color(0xFF0284C7);
      case BookingStatus.enRoute:
        return const Color(0xFF10B981);
      case BookingStatus.inProgress:
        return const Color(0xFF8B5CF6);
      case BookingStatus.completed:
        return const Color(0xFF16A34A);
      case BookingStatus.cancelled:
        return const Color(0xFFEF4444);
    }
  }
}

class BookingItem {
  final String title;
  final int quantity;
  final double price;

  const BookingItem({
    required this.title,
    this.quantity = 1,
    required this.price,
  });
}

class BookingModel {
  final String id;
  final String serviceId;
  final String serviceTitle;
  final IconData serviceIcon;
  final ServiceProviderModel provider;
  final BookingStatus status;
  final DateTime bookedAt;
  final String scheduledTime;
  final String address;
  final double totalAmount;
  final String serviceOtp;
  final int etaMinutes;
  final String paymentMethod;
  final bool isPaid;
  final List<BookingItem> items;
  final String? customerNotes;
  final double? ratingGiven;
  final String? reviewGiven;

  const BookingModel({
    required this.id,
    required this.serviceId,
    required this.serviceTitle,
    required this.serviceIcon,
    required this.provider,
    required this.status,
    required this.bookedAt,
    required this.scheduledTime,
    required this.address,
    required this.totalAmount,
    required this.serviceOtp,
    this.etaMinutes = 15,
    this.paymentMethod = 'Pay after service (UPI / Cash)',
    this.isPaid = false,
    required this.items,
    this.customerNotes,
    this.ratingGiven,
    this.reviewGiven,
  });

  bool get isActive =>
      status == BookingStatus.pending ||
      status == BookingStatus.accepted ||
      status == BookingStatus.enRoute ||
      status == BookingStatus.inProgress;

  bool get isCompleted => status == BookingStatus.completed;
  bool get isCancelled => status == BookingStatus.cancelled;

  BookingModel copyWith({
    BookingStatus? status,
    int? etaMinutes,
    bool? isPaid,
    double? ratingGiven,
    String? reviewGiven,
  }) {
    return BookingModel(
      id: id,
      serviceId: serviceId,
      serviceTitle: serviceTitle,
      serviceIcon: serviceIcon,
      provider: provider,
      status: status ?? this.status,
      bookedAt: bookedAt,
      scheduledTime: scheduledTime,
      address: address,
      totalAmount: totalAmount,
      serviceOtp: serviceOtp,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      paymentMethod: paymentMethod,
      isPaid: isPaid ?? this.isPaid,
      items: items,
      customerNotes: customerNotes,
      ratingGiven: ratingGiven ?? this.ratingGiven,
      reviewGiven: reviewGiven ?? this.reviewGiven,
    );
  }
}
