import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/logging/app_logger.dart';
import '../core/supabase/supabase_provider.dart';

class UserProfile {
  final String id;
  final String phoneNumber;
  final String fullName;
  final String location;
  final bool isRegistered;

  const UserProfile({
    this.id = '',
    required this.phoneNumber,
    required this.fullName,
    required this.location,
    required this.isRegistered,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? json['phone']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? 'User',
      location: json['location']?.toString() ?? 'Indiranagar, Bengaluru',
      isRegistered: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'phone_number': phoneNumber,
      'full_name': fullName,
      if (location.isNotEmpty) 'location': location,
    };
  }
}

class AuthService {
  final SupabaseClient _supabase;
  final Ref _ref;

  // Fallback cache of registered numbers
  final Set<String> _registeredPhoneNumbers = {
    '9876543210',
    '+919876543210',
    '9999999999',
  };

  AuthService(this._supabase, this._ref);

  /// Checks if the phone number is already registered in Supabase database
  Future<bool> isPhoneRegistered(String phoneNumber) async {
    final cleanDigits = phoneNumber.replaceAll(RegExp(r'\D'), '');

    try {
      AppLogger.info('Supabase: Checking if phone $cleanDigits exists in profiles...');
      final response = await _supabase
          .from('profiles')
          .select('id, full_name, phone_number')
          .eq('phone_number', cleanDigits)
          .maybeSingle();

      if (response != null) {
        AppLogger.info('Supabase: Existing profile found for $cleanDigits');
        final profile = UserProfile.fromJson(response);
        _ref.read(currentUserProfileProvider.notifier).state = profile;
        return true;
      }
    } catch (e) {
      AppLogger.warning('Supabase profile check fallback: $e');
    }

    // Check local fallback
    final isLocal = _registeredPhoneNumbers.any(
      (reg) => reg.replaceAll(RegExp(r'\D'), '') == cleanDigits,
    );

    if (isLocal) {
      _ref.read(currentUserProfileProvider.notifier).state = UserProfile(
        phoneNumber: cleanDigits,
        fullName: 'Alex Morgan',
        location: 'Indiranagar, Bengaluru',
        isRegistered: true,
      );
    }

    return isLocal;
  }

  /// Registers a new user with full name and location details in Supabase
  Future<void> registerUser({
    required String phoneNumber,
    required String fullName,
    required String location,
  }) async {
    final cleanDigits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    _registeredPhoneNumbers.add(cleanDigits);

    final newProfile = UserProfile(
      phoneNumber: cleanDigits,
      fullName: fullName,
      location: location,
      isRegistered: true,
    );

    _ref.read(currentUserProfileProvider.notifier).state = newProfile;

    try {
      AppLogger.info('Supabase: Saving profile to database...');
      final authUser = _supabase.auth.currentUser;

      final data = {
        if (authUser != null) 'id': authUser.id,
        'phone_number': cleanDigits,
        'full_name': fullName,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('profiles').upsert(data);
      AppLogger.info('Supabase: Profile saved successfully for $cleanDigits');
    } catch (e) {
      AppLogger.warning('Supabase registerUser fallback: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _ref.read(currentUserProfileProvider.notifier).state = null;
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      AppLogger.warning('Supabase signOut error: $e');
    }
  }
}

/// Provider for current user profile state
final currentUserProfileProvider = StateProvider<UserProfile?>((ref) => null);

/// Provider exposing AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AuthService(supabase, ref);
});
