import 'package:flutter/material.dart';

enum ProviderJobStatus {
  active,
  completed,
  pendingDropped;

  String get label {
    switch (this) {
      case ProviderJobStatus.active:
        return 'In Progress';
      case ProviderJobStatus.completed:
        return 'Completed';
      case ProviderJobStatus.pendingDropped:
        return 'Pending / Left Incomplete';
    }
  }

  Color get color {
    switch (this) {
      case ProviderJobStatus.active:
        return const Color(0xFF0284C7);
      case ProviderJobStatus.completed:
        return const Color(0xFF15803D);
      case ProviderJobStatus.pendingDropped:
        return const Color(0xFFD97706);
    }
  }

  Color get bgColor {
    switch (this) {
      case ProviderJobStatus.active:
        return const Color(0xFFE0F2FE);
      case ProviderJobStatus.completed:
        return const Color(0xFFDCFCE7);
      case ProviderJobStatus.pendingDropped:
        return const Color(0xFFFEF3C7);
    }
  }

  IconData get icon {
    switch (this) {
      case ProviderJobStatus.active:
        return Icons.autorenew_rounded;
      case ProviderJobStatus.completed:
        return Icons.check_circle_rounded;
      case ProviderJobStatus.pendingDropped:
        return Icons.pause_circle_filled_rounded;
    }
  }
}

class ProviderJobModel {
  final String id;
  final String title;
  final String category;
  final String customerName;
  final String customerPhone;
  final String address;
  final String serviceDetails;
  final double payoutAmount;
  final String estimatedDuration;
  final ProviderJobStatus status;
  final String date;
  final String? completedAt;
  final String? pendingReason;
  final String? pendingActionNotes;
  final double? rating;
  final String? customerFeedback;
  final String otp;

  const ProviderJobModel({
    required this.id,
    required this.title,
    required this.category,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.serviceDetails,
    required this.payoutAmount,
    required this.estimatedDuration,
    required this.status,
    required this.date,
    this.completedAt,
    this.pendingReason,
    this.pendingActionNotes,
    this.rating,
    this.customerFeedback,
    required this.otp,
  });

  bool get isCompleted => status == ProviderJobStatus.completed;
  bool get isPending => status == ProviderJobStatus.pendingDropped;
  bool get isActive => status == ProviderJobStatus.active;

  ProviderJobModel copyWith({
    String? id,
    String? title,
    String? category,
    String? customerName,
    String? customerPhone,
    String? address,
    String? serviceDetails,
    double? payoutAmount,
    String? estimatedDuration,
    ProviderJobStatus? status,
    String? date,
    String? completedAt,
    String? pendingReason,
    String? pendingActionNotes,
    double? rating,
    String? customerFeedback,
    String? otp,
  }) {
    return ProviderJobModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      address: address ?? this.address,
      serviceDetails: serviceDetails ?? this.serviceDetails,
      payoutAmount: payoutAmount ?? this.payoutAmount,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      status: status ?? this.status,
      date: date ?? this.date,
      completedAt: completedAt ?? this.completedAt,
      pendingReason: pendingReason ?? this.pendingReason,
      pendingActionNotes: pendingActionNotes ?? this.pendingActionNotes,
      rating: rating ?? this.rating,
      customerFeedback: customerFeedback ?? this.customerFeedback,
      otp: otp ?? this.otp,
    );
  }
}
