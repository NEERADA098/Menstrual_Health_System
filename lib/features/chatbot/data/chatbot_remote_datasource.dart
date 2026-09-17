import 'package:dio/dio.dart';

class ChatbotRemoteDataSource {
  final Dio _dio;

  ChatbotRemoteDataSource()
      : _dio = Dio(BaseOptions(
          baseUrl: 'http://localhost:8000/api/v1',
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ));

  Future<String> sendMessage({
    required String question,
    required String userId,
  }) async {
    final response = await _dio.post(
      '/chat/',
      data: {'question': question, 'user_id': userId},
    );
    final answer = response.data['answer'] as String;
    if (answer.isEmpty) {
      return 'I was unable to generate a response. Please consult a doctor for medical advice.';
    }
    return answer;
  }
}
