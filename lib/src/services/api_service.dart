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
    String? merchant,
    List<TransactionEntry>? transactionEntries,
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

      // Формируем transactionEntries из переданных данных или создаем один элемент
      final entries = transactionEntries ?? [
        TransactionEntry(
          description: description ?? '',
          amount: (amount * 100).round().toDouble(), // Умножаем на 100 для хранения в центах
          categoryId: 'c47ac10b-58cc-4372-a567-0e02b2c3d479', // Замоканное значение
        ),
      ];

      final body = json.encode({
        'userId': userId,
        'groupId': '6a785a55-fced-4f13-af78-5c19a39c9abc', // Замоканное значение
        'balanceId': '847ac10b-58cc-4372-a567-0e02b2c3d479', // Замоканное значение
        'type': type.name,
        'merchant': merchant ?? 'Unknown',
        'operationId': _generateOperationId(),
        'approvedAt': date.toUtc().toIso8601String(),
        'transactedAt': date.toUtc().toIso8601String(),
        'transactionEntries': entries.map((e) => e.toJson()).toList(),
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

  static Future<TransactionsResponse> getTransactions() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (!session.isSignedIn) {
        throw Exception('User is not signed in');
      }

      final currentUser = await Amplify.Auth.getCurrentUser();
      final userId = currentUser.userId;

      final cognitoSession = session as CognitoAuthSession;
      final token = cognitoSession.userPoolTokensResult.value.idToken.raw;

      final url = Uri.parse('$_baseUrl?userId=$userId');
      final headers = {
        'Authorization': 'Bearer $token',
      };

      debugPrint('GET Request URL: $url');
      debugPrint('GET Request Headers: $headers');

      final response = await http.get(
        url,
        headers: headers,
      );

      debugPrint('GET Response Status Code: ${response.statusCode}');
      debugPrint('GET Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to get transactions. Status code: ${response.statusCode}');
      }

      final jsonData = json.decode(response.body);
      return TransactionsResponse.fromJson(jsonData);
    } on Exception catch (e) {
      debugPrint('Error getting transactions: $e');
      rethrow;
    }
  }

  static String _generateOperationId() {
    // Генерируем UUID для operationId
    return '3fa85f64-5717-4562-b3fc-2c963f66afa6'; // Замоканное значение
  }
}

class TransactionEntry {
  final String description;
  final double amount;
  final String categoryId;

  TransactionEntry({
    required this.description,
    required this.amount,
    required this.categoryId,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'amount': (amount * 100).round().toDouble(), // Умножаем на 100 для хранения в центах
      'categoryId': categoryId,
    };
  }
}

class TransactionsResponse {
  final List<TransactionEntryData> transactionEntries;
  final String? nextToken;

  TransactionsResponse({
    required this.transactionEntries,
    this.nextToken,
  });

  factory TransactionsResponse.fromJson(Map<String, dynamic> json) {
    final items = json['items'] as List? ?? [];
    return TransactionsResponse(
      transactionEntries: items
          .map((entry) => TransactionEntryData.fromJson(entry))
          .toList(),
      nextToken: json['nextToken'],
    );
  }
}

class TransactionEntryData {
  final String groupId;
  final String userId;
  final String balanceId;
  final String transactionId;
  final String transactionEntryId;
  final String type;
  final double amount;
  final String balanceTitle;
  final String balanceCurrency;
  final String categoryName;
  final String? categoryImageUrl;
  final String merchantName;
  final String? merchantImageUrl;
  final String operationId;
  final DateTime approvedAt;
  final DateTime transactedAt;

  TransactionEntryData({
    required this.groupId,
    required this.userId,
    required this.balanceId,
    required this.transactionId,
    required this.transactionEntryId,
    required this.type,
    required this.amount,
    required this.balanceTitle,
    required this.balanceCurrency,
    required this.categoryName,
    this.categoryImageUrl,
    required this.merchantName,
    this.merchantImageUrl,
    required this.operationId,
    required this.approvedAt,
    required this.transactedAt,
  });

  factory TransactionEntryData.fromJson(Map<String, dynamic> json) {
    // Обрабатываем amount как строку или число
    final amountValue = json['amount'];
    double amount;
    if (amountValue is String) {
      amount = double.tryParse(amountValue) ?? 0.0;
    } else if (amountValue is num) {
      amount = amountValue.toDouble();
    } else {
      amount = 0.0;
    }
    
    return TransactionEntryData(
      groupId: json['groupId'] ?? '',
      userId: json['userId'] ?? '',
      balanceId: json['balanceId'] ?? '',
      transactionId: json['transactionId'] ?? '',
      transactionEntryId: json['transactionEntryId'] ?? '',
      type: json['type'] ?? '',
      amount: amount / 100, // Делим на 100 для отображения в евро
      balanceTitle: json['balanceTitle'] ?? '',
      balanceCurrency: json['balanceCurrency'] ?? '',
      categoryName: json['categoryName'] ?? '',
      categoryImageUrl: json['categoryImageUrl'],
      merchantName: json['merchantName'] ?? '',
      merchantImageUrl: json['merchantImageUrl'],
      operationId: json['operationId'] ?? '',
      approvedAt: DateTime.tryParse(json['approvedAt'] ?? '') ?? DateTime.now(),
      transactedAt: DateTime.tryParse(json['transactedAt'] ?? '') ?? DateTime.now(),
    );
  }
} 