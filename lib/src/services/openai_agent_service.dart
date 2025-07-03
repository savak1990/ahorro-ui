import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIAgentService {
  static String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static const _apiUrl = 'https://api.openai.com/v1/chat/completions';

  /// messages — история сообщений, functions — список описаний функций (опционально)
  Future<OpenAIResponse> sendMessage(List<Map<String, String>> messages, {List<Map<String, dynamic>>? functions}) async {
    final body = {
      'model': 'gpt-3.5-turbo-1106',
      'messages': messages,
      if (functions != null) 'functions': functions,
      if (functions != null) 'function_call': 'auto',
    };
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final choice = data['choices'][0];
      final message = choice['message'];
      final content = message['content'] as String?;
      final functionCall = message['function_call'];
      return OpenAIResponse(
        content: content,
        functionCall: functionCall,
      );
    } else {
      throw Exception('Error OpenAI: \\${response.statusCode} \\${response.body}');
    }
  }
}

class OpenAIResponse {
  final String? content;
  final dynamic functionCall;
  OpenAIResponse({this.content, this.functionCall});
} 