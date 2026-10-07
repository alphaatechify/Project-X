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
  final String email;
  final String location;
  final String bio;
  final bool isProvider;
  final bool isRegistered;

  const UserProfile({
    this.id = '',
    required this.phoneNumber,
    required this.fullName,
    this.email = '',
    required this.location,
    this.bio = '',
    this.isProvider = false,
    required this.isRegistered,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? json['phone']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? 'User',
      email: json['email']?.toString() ?? '',
      location: json['location']?.toString() ?? 'Indiranagar, Bengaluru',
      bio: json['bio']?.toString() ?? '',
      isProvider: json['is_provider'] == true,
      isRegistered: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'phone_number': phoneNumber,
      'full_name': fullName,
      if (email.isNotEmpty) 'email': email,
      if (location.isNotEmpty) 'location': location,
      if (bio.isNotEmpty) 'bio': bio,
      'is_provider': isProvider,
    };
  }

  UserProfile copyWith({
    String? id,
    String? phoneNumber,
    String? fullName,
    String? email,
    String? location,
    String? bio,
    bool? isProvider,
    bool? isRegistered,
  }) {
    return UserProfile(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      isProvider: isProvider ?? this.isProvider,
      isRegistered: isRegistered ?? this.isRegistered,
    );
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
          .select('id, full_name, phone_number, email, location, bio, is_provider')
          .eq('phone_number', cleanDigits)
          .maybeSingle();

      if (response != null) {
        AppLogger.info('Supabase: Existing profile found for $cleanDigits');
        final profile = UserProfile.fromJson(response);
        _saveProfile(profile);
        _ref.read(currentUserProfileProvider.notifier).state = profile;
        if (profile.isProvider) {
          _ref.read(isProviderLiveProvider.notifier).state = true;
        }
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

  /// Updates profile details (name, phone, email, bio, isProvider) locally and in Supabase
  Future<void> updateProfile({
    required String fullName,
    required String phoneNumber,
    String email = '',
    String location = '',
    String bio = '',
    bool? isProvider,
  }) async {
    final cleanDigits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final current = _ref.read(currentUserProfileProvider);

    final updated = UserProfile(
      id: current?.id ?? '',
      phoneNumber: cleanDigits.isNotEmpty ? cleanDigits : (current?.phoneNumber ?? ''),
      fullName: fullName.isNotEmpty ? fullName : (current?.fullName ?? 'User'),
      email: email.isNotEmpty ? email : (current?.email ?? ''),
      location: location.isNotEmpty ? location : (current?.location ?? 'Indiranagar, Bengaluru'),
      bio: bio.isNotEmpty ? bio : (current?.bio ?? ''),
      isProvider: isProvider ?? (current?.isProvider ?? false),
      isRegistered: true,
    );

    _saveProfile(updated);
    _ref.read(currentUserProfileProvider.notifier).state = updated;

    try {
      final phone = updated.phoneNumber;
      if (phone.isNotEmpty) {
        await _supabase.from('profiles').upsert({
          if (updated.id.isNotEmpty) 'id': updated.id,
          'phone_number': phone,
          'full_name': updated.fullName,
          'email': updated.email,
          'location': updated.location,
          'bio': updated.bio,
          'is_provider': updated.isProvider,
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'phone_number');
      }
    } catch (e) {
      debugPrint('⚠️ Error updating profile in Supabase: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _ref.read(currentUserProfileProvider.notifier).state = null;
    _ref.read(isProviderLiveProvider.notifier).state = false;
    try {
      final prefs = _ref.read(sharedPreferencesProvider);
      await prefs.remove('user_profile');
      await prefs.remove('is_provider_live');
    } catch (_) {}
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      AppLogger.warning('Supabase signOut error: $e');
    }
  }
}

/// Provider to track if provider is live/online
final isProviderLiveProvider = StateProvider<bool>((ref) {
  try {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool('is_provider_live') ?? false;
  } catch (_) {
    return false;
  }
});

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
