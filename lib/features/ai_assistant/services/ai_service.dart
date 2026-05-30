import 'package:dio/dio.dart';

class AIService {
  final Dio dio = Dio();

  Future<String> sendMessage(String prompt) async {
    final response = await dio.post(
      'https://us-central1-start-trip-8bb36.cloudfunctions.net/tripChatbot',
      data: {
        'prompt': prompt,
      },
    );

    return response.data['response'];
  }
}