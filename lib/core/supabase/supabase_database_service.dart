import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../logging/app_logger.dart';
import 'supabase_provider.dart';

/// Comprehensive Database service for Project X On-Demand Services
class SupabaseDatabaseService {
  final SupabaseClient _supabase;

  SupabaseDatabaseService(this._supabase);

  // ===========================================================================
  // 1. CATALOG & SERVICES
  // ===========================================================================

  /// Fetch active service categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _supabase
          .from('service_categories')
          .select('*')
          .eq('is_active', true)
          .order('sort_order', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.warning('Failed to fetch service categories: $e');
      return [];
    }
  }

  /// Fetch active services, optionally filtered by category
  Future<List<Map<String, dynamic>>> getServices({String? categoryId, String? slug}) async {
    try {
      var query = _supabase.from('services').select('*, service_variants(*)').eq('is_active', true);
      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.eq('category_id', categoryId);
      }
      if (slug != null && slug.isNotEmpty) {
        query = query.eq('slug', slug);
      }
      final response = await query.order('created_at', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.warning('Failed to fetch services: $e');
      return [];
    }
  }

  /// Fetch active variants for a specific service
  Future<List<Map<String, dynamic>>> getServiceVariants(String serviceId) async {
    try {
      final response = await _supabase
          .from('service_variants')
          .select('*')
          .eq('service_id', serviceId)
          .eq('is_active', true)
          .order('base_price_paise', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.warning('Failed to fetch service variants: $e');
      return [];
    }
  }

  // ===========================================================================
  // 2. TRANSACTIONAL BOOKING RPCS
  // ===========================================================================

  /// Creates a booking atomically via transactional RPC
  Future<Map<String, dynamic>> createBooking({
    required Map<String, dynamic> payload,
    required String idempotencyKey,
  }) async {
    try {
      AppLogger.info('Calling RPC create_booking with idempotency key: $idempotencyKey');
      final response = await _supabase.rpc(
        'create_booking',
        params: {
          'payload': payload,
          'idempotency_key': idempotencyKey,
        },
      );
      AppLogger.info('Booking created successfully: $response');
      return Map<String, dynamic>.from(response as Map);
    } catch (e, stackTrace) {
      AppLogger.error('RPC create_booking failed', e, stackTrace);
      rethrow;
    }
  }

  /// Provider accepts a booking via atomic RPC with FOR UPDATE row lock
  Future<Map<String, dynamic>> acceptBooking({
    required String bookingId,
    String? idempotencyKey,
  }) async {
    try {
      AppLogger.info('Calling RPC accept_booking for $bookingId');
      final response = await _supabase.rpc(
        'accept_booking',
        params: {
          'p_booking_id': bookingId,
          if (idempotencyKey != null) 'p_idempotency_key': idempotencyKey,
        },
      );
      return Map<String, dynamic>.from(response as Map);
    } catch (e, stackTrace) {
      AppLogger.error('RPC accept_booking failed', e, stackTrace);
      rethrow;
    }
  }

  /// Advances booking state through the verified state transition matrix
  Future<Map<String, dynamic>> transitionBooking({
    required String bookingId,
    required String targetStatus,
    String? reasonCode,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      AppLogger.info('Calling RPC transition_booking for $bookingId -> $targetStatus');
      final response = await _supabase.rpc(
        'transition_booking',
        params: {
          'p_booking_id': bookingId,
          'p_target_status': targetStatus,
          if (reasonCode != null) 'p_reason_code': reasonCode,
          'p_metadata': metadata ?? {},
        },
      );
      return Map<String, dynamic>.from(response as Map);
    } catch (e, stackTrace) {
      AppLogger.error('RPC transition_booking failed', e, stackTrace);
      rethrow;
    }
  }

  /// Request a cryptographically hashed OTP challenge (arrival, start, completion)
  Future<Map<String, dynamic>> requestJobOtp({
    required String bookingId,
    required String purpose,
  }) async {
    try {
      AppLogger.info('Calling RPC request_job_otp for $bookingId ($purpose)');
      final response = await _supabase.rpc(
        'request_job_otp',
        params: {
          'p_booking_id': bookingId,
          'p_purpose': purpose,
        },
      );
      return Map<String, dynamic>.from(response as Map);
    } catch (e, stackTrace) {
      AppLogger.error('RPC request_job_otp failed', e, stackTrace);
      rethrow;
    }
  }

  /// Verifies a job OTP challenge and advances the job execution phase
  Future<Map<String, dynamic>> verifyJobOtp({
    required String challengeId,
    required String code,
  }) async {
    try {
      AppLogger.info('Calling RPC verify_job_otp for challenge $challengeId');
      final response = await _supabase.rpc(
        'verify_job_otp',
        params: {
          'p_challenge_id': challengeId,
          'p_code': code,
        },
      );
      return Map<String, dynamic>.from(response as Map);
    } catch (e, stackTrace) {
      AppLogger.error('RPC verify_job_otp failed', e, stackTrace);
      rethrow;
    }
  }

  // ===========================================================================
  // 3. BOOKINGS QUERY & DETAILS
  // ===========================================================================

  /// Fetch bookings for the current authenticated user (customer or assigned provider)
  Future<List<Map<String, dynamic>>> getMyBookings() async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('*, booking_items(*), addresses(*), booking_assignments(*, provider_profiles(*))')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.warning('Failed to fetch bookings: $e');
      return [];
    }
  }

  /// Fetch single booking detail by ID with full timeline and items
  Future<Map<String, dynamic>?> getBookingDetails(String bookingId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('*, booking_items(*), booking_status_events(*), addresses(*), booking_assignments(*, provider_profiles(*))')
          .eq('id', bookingId)
          .maybeSingle();
      if (response == null) return null;
      return Map<String, dynamic>.from(response);
    } catch (e) {
      AppLogger.warning('Failed to fetch booking details for $bookingId: $e');
      return null;
    }
  }

  // ===========================================================================
  // 4. USER ADDRESSES & NOTIFICATIONS
  // ===========================================================================

  /// Fetch user addresses
  Future<List<Map<String, dynamic>>> getMyAddresses() async {
    try {
      final response = await _supabase
          .from('addresses')
          .select('*')
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.warning('Failed to fetch addresses: $e');
      return [];
    }
  }

  /// Save or update an address
  Future<Map<String, dynamic>?> saveAddress(Map<String, dynamic> addressData) async {
    try {
      final response = await _supabase
          .from('addresses')
          .upsert(addressData)
          .select()
          .single();
      return Map<String, dynamic>.from(response);
    } catch (e) {
      AppLogger.error('Failed to save address: $e');
      return null;
    }
  }

  /// Fetch user notifications
  Future<List<Map<String, dynamic>>> getMyNotifications() async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('*')
          .order('created_at', ascending: false)
          .limit(50);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.warning('Failed to fetch notifications: $e');
      return [];
    }
  }

  // ===========================================================================
  // 5. USER LOYALTY POINTS & REWARDS
  // ===========================================================================

  /// Fetch user loyalty points summary
  Future<Map<String, dynamic>?> getUserPoints() async {
    try {
      final response = await _supabase
          .from('user_points')
          .select('*')
          .maybeSingle();
      if (response == null) return null;
      return Map<String, dynamic>.from(response);
    } catch (e) {
      AppLogger.warning('Failed to fetch user points: $e');
      return null;
    }
  }

  /// Fetch user points transactions ledger
  Future<List<Map<String, dynamic>>> getPointTransactions() async {
    try {
      final response = await _supabase
          .from('point_transactions')
          .select('*')
          .order('created_at', ascending: false)
          .limit(50);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.warning('Failed to fetch point transactions: $e');
      return [];
    }
  }
}

/// Provider for Supabase Database service
final supabaseDatabaseServiceProvider = Provider<SupabaseDatabaseService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseDatabaseService(supabase);
});

/// FutureProvider for active service categories
final serviceCategoriesFutureProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dbService = ref.watch(supabaseDatabaseServiceProvider);
  return dbService.getCategories();
});

/// FutureProvider for active services
final servicesFutureProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dbService = ref.watch(supabaseDatabaseServiceProvider);
  return dbService.getServices();
});

/// FutureProvider for user's bookings
final myBookingsFutureProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dbService = ref.watch(supabaseDatabaseServiceProvider);
  return dbService.getMyBookings();
});

/// FutureProvider for user points balance
final userPointsFutureProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final dbService = ref.watch(supabaseDatabaseServiceProvider);
  return dbService.getUserPoints();
});
