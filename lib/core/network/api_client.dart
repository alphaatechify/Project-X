import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/config/app_config.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: AppConstants.apiTimeout,
      receiveTimeout: AppConstants.apiTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(AuthInterceptor(secureStorage));
  if (config.enableLogging) {
    dio.interceptors.add(LoggingInterceptor());
  }

  return dio;
});
