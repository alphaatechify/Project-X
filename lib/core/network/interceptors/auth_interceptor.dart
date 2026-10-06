import 'package:dio/dio.dart';
import '../../storage/secure_storage.dart';
import '../../constants/storage_keys.dart';

/// Interceptor to append bearer tokens automatically to outgoing requests
class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.read(StorageKeys.authTokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Handle unauthorized session expiration trigger
    }
    handler.next(err);
  }
}
