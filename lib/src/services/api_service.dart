import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

import '../config/app_config.dart';
import '../models/transaction_type.dart';

class ApiService {
  static const String _baseUrl = AppConfig.baseUrl;

  static Future<void> postTransaction({
    required TransactionType type,
    required double amount,
    required DateTime date,
    required String category,
    String? description,
  }) async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (!session.isSignedIn) {
        throw Exception('User is not signed in');
      }

      final currentUser = await Amplify.Auth.getCurrentUser();
      final userId = currentUser.userId;

      final cognitoSession = session as CognitoAuthSession;
      final token = cognitoSession.userPoolTokensResult.value.idToken.raw;

      final url = Uri.parse(_baseUrl);
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final body = json.encode({
        'user_id': userId,
        'group_id': '11111', // Замоканное значение
        'type': type.name,
        'amount': amount,
        'balance_id': '11111', // Замоканное значение
        'category': category,
        'description': description ?? '',
        'transacted_at': date.toIso8601String(),
      });

      debugPrint('Request URL: $url');
      debugPrint('Request Headers: $headers');
      debugPrint('Request Body: $body');

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        // Выбрасываем исключение, чтобы его можно было поймать в UI
        throw Exception(
            'Failed to post transaction. Status code: ${response.statusCode}');
      }
    } on Exception catch (e) {
      debugPrint('Error posting transaction: $e');
      // Перебрасываем исключение, чтобы UI мог его обработать
      rethrow;
    }
  }
} 