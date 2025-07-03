import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'operation_id_service.dart';
import '../services/auth_service.dart';

import '../config/app_config.dart';
import '../models/transaction_type.dart';
import '../models/balance.dart';
import '../models/transaction_entry.dart';
import '../models/transactions_response.dart';
import '../models/transaction_entry_data.dart';
import '../models/categories_response.dart';
import '../models/category_data.dart';

class ApiService {
  static Future<void> postTransaction({
    required TransactionType type,
    required double amount,
    required DateTime date,
    required String categoryId,
    required String balanceId,
    String? description,
    String? merchant,
    List<TransactionEntry>? transactionEntriesParam,
  }) async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (!session.isSignedIn) {
        throw Exception('User is not signed in');
      }

      final userId = await AuthService.getUserId();

      final cognitoSession = session as CognitoAuthSession;
      final token = cognitoSession.userPoolTokensResult.value.idToken.raw;

      final url = Uri.parse(AppConfig.transactionsUrl);
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // Form transactionEntries from passed data or create single element
      final entries = transactionEntriesParam ?? [
        TransactionEntry(
          description: description ?? '',
          amount: (amount * 100).round().toDouble(), // Multiply by 100 for storage in cents
          categoryId: categoryId,
        ),
      ];

      final body = json.encode({
        'userId': userId,
        'groupId': '',
        'balanceId': balanceId,
        'type': type.name,
        'merchant': merchant ?? 'Unknown',
        'operationId': generateOperationId(),
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
        throw Exception('Failed to post transaction. Status code: ${response.statusCode}');
      }

      return json.decode(response.body);
    } catch (e) {
      debugPrint('Error posting transaction: $e');
      rethrow;
    }
  }

  static Future<TransactionsResponse> getTransactions() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (!session.isSignedIn) {
        throw Exception('User is not signed in');
      }

      final userId = await AuthService.getUserId();

      final cognitoSession = session as CognitoAuthSession;
      final token = cognitoSession.userPoolTokensResult.value.idToken.raw;

      final url = Uri.parse('${AppConfig.transactionsUrl}?userId=$userId');
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
        throw Exception('Failed to get transactions. Status code: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final items = data['items'] as List;

      final transactionEntries = items.map((item) {
        // Handle amount as string or number
        double amount;
        if (item['amount'] is String) {
          amount = double.parse(item['amount']);
        } else {
          amount = (item['amount'] as num).toDouble();
        }

        return TransactionEntryData(
          transactionId: item['transactionId'],
          transactionEntryId: item['transactionEntryId'],
          type: item['type'],
          amount: amount / 100, // Divide by 100 for display in euros
          groupId: item['groupId'] ?? '',
          userId: item['userId'] ?? '',
          balanceId: item['balanceId'] ?? '',
          balanceTitle: item['balanceTitle'] ?? '',
          balanceCurrency: item['balanceCurrency'] ?? '',
          categoryName: item['categoryName'] ?? '',
          categoryImageUrl: item['categoryImageUrl'],
          merchantName: item['merchantName'] ?? '',
          merchantImageUrl: item['merchantImageUrl'],
          operationId: item['operationId'] ?? '',
          approvedAt: DateTime.tryParse(item['approvedAt'] ?? '') ?? DateTime.now(),
          transactedAt: DateTime.tryParse(item['transactedAt'] ?? '') ?? DateTime.now(),
        );
      }).toList();

      return TransactionsResponse(
        transactionEntries: transactionEntries,
        nextToken: data['nextToken'],
      );
    } on Exception catch (e) {
      debugPrint('Error getting transactions: $e');
      rethrow;
    }
  }

  static Future<CategoriesResponse> getCategories() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (!session.isSignedIn) {
        throw Exception('User is not signed in');
      }

      final cognitoSession = session as CognitoAuthSession;
      final token = cognitoSession.userPoolTokensResult.value.idToken.raw;

      final url = Uri.parse(AppConfig.categoriesUrl);
      final headers = {
        'Authorization': 'Bearer $token',
      };

      debugPrint('GET Categories Request URL: $url');
      debugPrint('GET Categories Request Headers: $headers');

      final response = await http.get(
        url,
        headers: headers,
      );

      debugPrint('GET Categories Response Status Code: ${response.statusCode}');
      debugPrint('GET Categories Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to get categories. Status code: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final categoriesList = data['categories'] as List;

      final categories = categoriesList.map((item) {
        return CategoryData(
          id: item['categoryId'] ?? '', // API returns categoryId, not id
          name: item['name'] ?? '',
          groupId: item['groupId'] ?? 'default', // Default group if not provided
          groupName: item['groupName'] ?? 'General', // Default group name
          groupIndex: item['groupIndex'] ?? 0, // Default index
          imageUrl: item['imageUrl'],
        );
      }).toList();

      return CategoriesResponse(
        categories: categories,
        nextToken: data['nextToken'],
      );
    } on Exception catch (e) {
      debugPrint('Error getting categories: $e');
      rethrow;
    }
  }

  static Future<List<Balance>> getBalances() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (!session.isSignedIn) {
        throw Exception('User is not signed in');
      }
      final userId = await AuthService.getUserId();
      final cognitoSession = session as CognitoAuthSession;
      final token = cognitoSession.userPoolTokensResult.value.idToken.raw;

      final url = Uri.parse('${AppConfig.baseUrl}/balances?userId=$userId');
      final headers = {
        'Authorization': 'Bearer $token',
      };

      debugPrint('GET Balances Request URL: $url');
      debugPrint('GET Balances Request Headers: $headers');

      final response = await http.get(url, headers: headers);

      debugPrint('GET Balances Response Status Code: ${response.statusCode}');
      debugPrint('GET Balances Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to get balances. Status code: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final balances = data['balances'] as List? ?? [];
      return balances.map((e) => Balance.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error getting balances: $e');
      rethrow;
    }
  }

  static Future<dynamic> postBalance({
    required String userId,
    required String groupId,
    required String currency,
    required String title,
    String? description,
  }) async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (!session.isSignedIn) {
        throw Exception('User is not signed in');
      }
      final cognitoSession = session as CognitoAuthSession;
      final token = cognitoSession.userPoolTokensResult.value.idToken.raw;

      final url = Uri.parse('${AppConfig.baseUrl}/balances');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final body = json.encode({
        'userId': userId,
        'groupId': groupId,
        'currency': currency,
        'title': title,
        if (description != null && description.isNotEmpty) 'description': description,
      });

      debugPrint('POST Balance Request URL: $url');
      debugPrint('POST Balance Request Headers: $headers');
      debugPrint('POST Balance Request Body: $body');

      final response = await http.post(url, headers: headers, body: body);

      debugPrint('POST Balance Response Status Code: ${response.statusCode}');
      debugPrint('POST Balance Response Body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create balance. Status code: ${response.statusCode}');
      }
      return json.decode(response.body);
    } catch (e) {
      debugPrint('Error creating balance: $e');
      rethrow;
    }
  }
} 