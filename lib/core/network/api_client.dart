import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  static const String _baseUrl = 'http://localhost:8000/api/v1';
  static const Duration _timeout = Duration(seconds: 30);

  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: _timeout,
      receiveTimeout: _timeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }
  }

  Future<bool> isServerReachable() async {
    try {
      final response = await _dio.get('/health/');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> batchSync({
    required String userId,
    required List<Map<String, dynamic>> cycleLogs,
    required List<Map<String, dynamic>> symptomLogs,
  }) async {
    final response = await _dio.post(
      '/sync/',
      data: {
        'user_id': userId,
        'cycle_logs': cycleLogs,
        'symptom_logs': symptomLogs,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}
