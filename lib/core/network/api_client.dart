// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import '../../env.dart';
import '../network/interceptors.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio) {
    _dio.options
      ..baseUrl = Env.backendBaseUrl
      ..connectTimeout = const Duration(seconds: 20)
      ..receiveTimeout = const Duration(seconds: 30);
    _dio.interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
    ]);
  }

  Dio get dio => _dio;
}
