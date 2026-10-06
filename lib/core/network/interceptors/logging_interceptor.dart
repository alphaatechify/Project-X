import 'package:dio/dio.dart';
import '../../logging/app_logger.dart';

/// Network logging interceptor that formats requests/responses safely
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.debug('--> ${options.method.toUpperCase()} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.debug('<-- ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error('<-- ERROR ${err.response?.statusCode} ${err.requestOptions.uri}', err);
    handler.next(err);
  }
}
