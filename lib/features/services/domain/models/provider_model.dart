import 'package:flutter/material.dart';

class ServiceProviderModel {
  final String id;
  final String name;
  final String avatarUrl;
  final String avatarInitials;
  final Color avatarBgColor;
  final String serviceId;
  final String subCategory;
  final String clinicOrFirmName;
  final String qualifications;
  final double rating;
  final int reviewCount;
  final int jobsCompleted;
  final int experienceYears;
  final double distanceKm;
  final String price;
  final String priceUnit;
  final String availabilityStatus;
  final bool isAvailableNow;
  final bool isVoltCertified;
  final List<String> badges;
  final List<String> specialties;
  final String bio;
  final String locationArea;
  final String phone;

  const ServiceProviderModel({
    required this.id,
    required this.name,
    this.avatarUrl = '',
    required this.avatarInitials,
    required this.avatarBgColor,
    required this.serviceId,
    required this.subCategory,
    this.clinicOrFirmName = '',
    this.qualifications = '',
    required this.rating,
    required this.reviewCount,
    required this.jobsCompleted,
    required this.experienceYears,
    required this.distanceKm,
    required this.price,
    this.priceUnit = '/hr',
    required this.availabilityStatus,
    required this.isAvailableNow,
    required this.isVoltCertified,
    required this.badges,
    required this.specialties,
    required this.bio,
    required this.locationArea,
    this.phone = '+91 98765 00000',
  });

  String get formattedDistance {
    if (distanceKm < 1.0) {
      return '${(distanceKm * 1000).round()}m away';
    }
    return '${distanceKm.toStringAsFixed(1)} km away';
  }
}
