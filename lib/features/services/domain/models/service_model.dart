import 'package:flutter/material.dart';

class ServiceModel {
  final String id;
  final String title;
  final String categoryName;
  final String subtitle;
  final String fullDescription;
  final IconData icon;
  final Color themeColor;
  final Color themeBgColor;
  final Color cardIconBgColor;
  final String tag;
  final Color tagBgColor;
  final Color tagTextColor;
  final String ctaText;
  final double rating;
  final String totalReviews;
  final String startingPrice;
  final List<String> subCategories;
  final List<SubServiceItem> subServices;
  final List<String> highlights;
  final String bannerNotice;
  final String avgEta;
  final String imageAsset;
  final Alignment imageAlignment;

  const ServiceModel({
    required this.id,
    required this.title,
    required this.categoryName,
    required this.subtitle,
    required this.fullDescription,
    required this.icon,
    required this.themeColor,
    required this.themeBgColor,
    required this.cardIconBgColor,
    required this.tag,
    required this.tagBgColor,
    required this.tagTextColor,
    required this.ctaText,
    required this.rating,
    required this.totalReviews,
    required this.startingPrice,
    required this.subCategories,
    this.subServices = const [],
    required this.highlights,
    required this.bannerNotice,
    required this.avgEta,
    this.imageAsset = 'assets/images/plumbing_service.jpg',
    this.imageAlignment = Alignment.center,
  });
}

class SubSubServiceItem {
  final String id;
  final String title;
  final String description;
  final String price;
  final double priceNumber;
  final String timeEstimate;

  const SubSubServiceItem({
    this.id = '',
    required this.title,
    this.description = '',
    required this.price,
    required this.priceNumber,
    this.timeEstimate = '30 mins',
  });

  String get effectiveId => id.isNotEmpty ? id : title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
}

class SubServiceItem {
  final String id;
  final String title;
  final String description;
  final String price;
  final double priceNumber;
  final String imageUrl;
  final List<String> includedItems;
  final List<SubSubServiceItem> subSubServices;

  const SubServiceItem({
    this.id = '',
    required this.title,
    required this.description,
    this.price = '₹349',
    this.priceNumber = 349.0,
    this.imageUrl = 'assets/images/plumbing_service.jpg',
    this.includedItems = const [],
    this.subSubServices = const [],
  });

  String get effectiveId => id.isNotEmpty ? id : title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
}
