import 'package:dio/dio.dart';

class AshaRemoteDataSource {
  final Dio _dio;

  AshaRemoteDataSource()
      : _dio = Dio(BaseOptions(
          baseUrl: 'http://localhost:8000/api/v1',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ));

  Future<Map<String, dynamic>> getCommunityummary() async {
    final response = await _dio.get('/community/summary');
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getFlaggedUsers() async {
    final response = await _dio.get('/community/flagged-users');
    return List<Map<String, dynamic>>.from(response.data as List);
  }
}
