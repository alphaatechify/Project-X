import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../logging/app_logger.dart';
import 'supabase_provider.dart';

/// Database service for Supabase banking operations
class SupabaseDatabaseService {
  final SupabaseClient _supabase;

  SupabaseDatabaseService(this._supabase);

  /// Fetch bank accounts for current user
  Future<List<Map<String, dynamic>>> getBankAccounts() async {
    try {
      final response = await _supabase
          .from('bank_accounts')
          .select('*')
          .order('created_at', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.warning('Failed to fetch bank accounts: $e');
      return [];
    }
  }

  /// Fetch transactions list
  Future<List<Map<String, dynamic>>> getTransactions() async {
    try {
      final response = await _supabase
          .from('transactions')
          .select('*')
          .order('created_at', ascending: false)
          .limit(20);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.warning('Failed to fetch transactions: $e');
      return [];
    }
  }

  /// Fetch cards
  Future<List<Map<String, dynamic>>> getCards() async {
    try {
      final response = await _supabase
          .from('cards')
          .select('*')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.warning('Failed to fetch cards: $e');
      return [];
    }
  }

  /// Execute money transfer via atomic stored procedure
  Future<Map<String, dynamic>> transferFunds({
    required String senderAccountId,
    required String receiverAccountNumber,
    required double amount,
    String description = 'Account Transfer',
  }) async {
    try {
      final response = await _supabase.rpc(
        'transfer_funds',
        params: {
          'p_sender_account_id': senderAccountId,
          'p_receiver_account_number': receiverAccountNumber,
          'p_amount': amount,
          'p_description': description,
        },
      );
      return Map<String, dynamic>.from(response as Map);
    } catch (e) {
      AppLogger.error('Transfer failed: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}

/// Provider for database service
final supabaseDatabaseServiceProvider = Provider<SupabaseDatabaseService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseDatabaseService(supabase);
});

/// FutureProvider for user bank accounts
final bankAccountsFutureProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dbService = ref.watch(supabaseDatabaseServiceProvider);
  return dbService.getBankAccounts();
});

/// FutureProvider for recent transactions
final transactionsFutureProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dbService = ref.watch(supabaseDatabaseServiceProvider);
  return dbService.getTransactions();
});
