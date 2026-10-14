import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global active bottom navigation tab index for HomeScreen
/// 0: Home / Console, 1: Bookings / Jobs, 2: Profile
final homeBottomNavIndexProvider = StateProvider<int>((ref) => 0);
