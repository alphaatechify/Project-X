import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider exposing the initialized SupabaseClient instance
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider exposing the currently authenticated Supabase User (or null)
final currentUserProvider = Provider<User?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.currentUser;
});

/// Stream provider for auth state changes (signed in, signed out, token refreshed, etc.)
final authStateStreamProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});
