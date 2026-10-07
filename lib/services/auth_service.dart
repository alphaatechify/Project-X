import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/logging/app_logger.dart';
import '../core/storage/local_storage.dart';
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
        _saveProfile(profile);
        _ref.read(currentUserProfileProvider.notifier).state = profile;
        return true;
      }
    } catch (e) {
      AppLogger.warning('Supabase profile check failed: $e');
    }

    return false;
  }

  void _saveProfile(UserProfile profile) {
    try {
      final prefs = _ref.read(sharedPreferencesProvider);
      prefs.setString('user_profile', jsonEncode(profile.toJson()));
    } catch (_) {}
  }

  /// Registers a new user with full name and location details in Supabase
  Future<void> registerUser({
    required String phoneNumber,
    required String fullName,
    required String location,
  }) async {
    final cleanDigits = phoneNumber.replaceAll(RegExp(r'\D'), '');

    final newProfile = UserProfile(
      phoneNumber: cleanDigits,
      fullName: fullName,
      location: location,
      isRegistered: true,
    );

    _saveProfile(newProfile);
    _ref.read(currentUserProfileProvider.notifier).state = newProfile;

    try {
      AppLogger.info('Supabase: Saving profile to database for $cleanDigits...');
      final authUser = _supabase.auth.currentUser;

      final data = {
        if (authUser != null) 'id': authUser.id,
        'phone_number': cleanDigits,
        'full_name': fullName,
        'location': location,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase.from('profiles').upsert(
        data,
        onConflict: 'phone_number',
      ).select();

      AppLogger.info('Supabase: Profile saved successfully: $response');
    } catch (e, stackTrace) {
      AppLogger.error('Supabase registerUser failed', e, stackTrace);
      debugPrint('⚠️ Supabase Profile Insert Error: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _ref.read(currentUserProfileProvider.notifier).state = null;
    try {
      final prefs = _ref.read(sharedPreferencesProvider);
      await prefs.remove('user_profile');
    } catch (_) {}
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      AppLogger.warning('Supabase signOut error: $e');
    }
  }
}

/// Provider for current user profile state with local persistence
final currentUserProfileProvider = StateProvider<UserProfile?>((ref) {
  try {
    final prefs = ref.watch(sharedPreferencesProvider);
    final raw = prefs.getString('user_profile');
    if (raw != null && raw.isNotEmpty) {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserProfile.fromJson(map);
    }
  } catch (_) {}
  return null;
});

/// Provider exposing AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AuthService(supabase, ref);
});
