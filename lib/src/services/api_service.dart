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
import '../models/merchant.dart';


class ApiService {
  static Future<void> postTransaction({
    required TransactionType type,
    double? amount,
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
          amount: ((amount ?? 0.0) * 100).round(),
          categoryId: categoryId,
        ),
      ];

      // debugPrint('[ApiService.postTransaction] --- REQUEST DATA ---');
      // debugPrint('userId: $userId');
      // debugPrint('groupId: ""');
      // debugPrint('balanceId: $balanceId');
      // debugPrint('type: ${type.name}');
      // debugPrint('merchant: ${merchant ?? 'Unknown'}');
      // debugPrint('operationId: ${generateOperationId()}');
      // debugPrint('approvedAt: ${date.toUtc().toIso8601String()}');
      // debugPrint('transactedAt: ${date.toUtc().toIso8601String()}');
      // debugPrint('transactionEntries: ${entries.map((e) => e.toJson()).toList()}');
      // debugPrint('Headers: $headers');

      final bodyMap = <String, dynamic>{
        'userId': userId,
        'groupId': '',
        'type': type.name,
        'operationId': generateOperationId(),
        'approvedAt': date.toUtc().toIso8601String(),
        'transactedAt': date.toUtc().toIso8601String(),
      };
      if (balanceId.isNotEmpty) {
        bodyMap['balanceId'] = balanceId;
      }
      if (merchant != null && merchant.isNotEmpty) {
        bodyMap['merchant'] = merchant;
      }
      if (entries.isNotEmpty) {
        bodyMap['transactionEntries'] = entries.map((e) => e.toJson()).toList();
      }
      // description и categoryId не передаем, если пустые
      // amount на верхнем уровне не передаем

      final body = json.encode(bodyMap);

      // debugPrint('[ApiService.postTransaction] BODY: $body');

      // debugPrint('Request URL: $url');
      //debugPrint('Request Headers: $headers');
      //debugPrint('Request Body: $body');

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      // debugPrint('[ApiService.postTransaction] --- RESPONSE ---');
      // debugPrint('Response Status Code: ${response.statusCode}');
      // debugPrint('Response Body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        //debugPrint('[ApiService.postTransaction] ERROR: Failed to post transaction. Status code: ${response.statusCode}');
        throw Exception('Failed to post transaction. Status code: ${response.statusCode}');
      }

      // debugPrint('[ApiService.postTransaction] Transaction posted successfully!');
      return json.decode(response.body);
    } catch (e) {
      //debugPrint('[ApiService.postTransaction] Exception: $e');
      debugPrint('Error posting transaction: $e');
      rethrow;
    }
  }

  static Future<void> postMovementTransaction({
    required String fromBalanceId,
    required String toBalanceId,
    required double amount,
    double? convertedAmount,
    required DateTime date,
    String? description,
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

      // Create two transactions: move_out and move_in
      final moveOutTransaction = {
        'userId': userId,
        'balanceId': fromBalanceId,
        'type': 'move_out',
        'transactedAt': date.toUtc().toIso8601String(),
        'transactionEntries': [
          {
            'description': description ?? 'Transfer to another account',
            'amount': (amount * 100).round(), // Convert to cents
          }
        ]
      };

      final moveInTransaction = {
        'userId': userId,
        'balanceId': toBalanceId,
        'type': 'move_in',
        'transactedAt': date.toUtc().toIso8601String(),
        'transactionEntries': [
          {
            'description': description ?? 'Transfer from another account',
            'amount': (convertedAmount != null ? convertedAmount * 100 : amount * 100).round(), // Use converted amount if available
          }
        ]
      };

      final bodyMap = {
        'transactions': [moveOutTransaction, moveInTransaction]
      };

      // debugPrint('[ApiService.postMovementTransaction] --- REQUEST DATA ---');
      // debugPrint('userId: $userId');
      // debugPrint('fromBalanceId: $fromBalanceId');
      // debugPrint('toBalanceId: $toBalanceId');
      // debugPrint('amount: $amount');
      // debugPrint('convertedAmount: $convertedAmount');
      // debugPrint('move_out amount: ${(amount * 100).round()}');
      // debugPrint('move_in amount: ${(convertedAmount != null ? convertedAmount * 100 : amount * 100).round()}');
      // debugPrint('date: ${date.toUtc().toIso8601String()}');
      // debugPrint('description: ${description ?? 'Transfer'}');

      final body = json.encode(bodyMap);

      // debugPrint('[ApiService.postMovementTransaction] BODY: $body');

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      // debugPrint('[ApiService.postMovementTransaction] --- RESPONSE ---');
      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        //debugPrint('[ApiService.postMovementTransaction] ERROR: Failed to post movement transaction. Status code: ${response.statusCode}');
        throw Exception('Failed to post movement transaction. Status code: ${response.statusCode}');
      }

      debugPrint('[ApiService.postMovementTransaction] Movement transaction posted successfully!');
      return json.decode(response.body);
    } catch (e) {
      //debugPrint('[ApiService.postMovementTransaction] Exception: $e');
      debugPrint('Error posting movement transaction: $e');
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

      //debugPrint('GET Request URL: $url');
      //debugPrint('GET Request Headers: $headers');

      final response = await http.get(
        url,
        headers: headers,
      );

      //debugPrint('GET Response Status Code: ${response.statusCode}');
      //debugPrint('GET Response Body: ${response.body}');

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
          name: item['name'] ?? '',
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

      //debugPrint('GET Categories Request URL: $url');
      //debugPrint('GET Categories Request Headers: $headers');

      final response = await http.get(
        url,
        headers: headers,
      );

      //debugPrint('GET Categories Response Status Code: ${response.statusCode}');
      //debugPrint('GET Categories Response Body: ${response.body}');

      if (response.statusCode != 200) {
        //debugPrint('Categories API: Failed with status code: ${response.statusCode}');
        //debugPrint('Categories API: Response body: ${response.body}');
        throw Exception('Failed to get categories. Status code: ${response.statusCode}. Response: ${response.body}');
      }

      final data = json.decode(response.body);
      return CategoriesResponse.fromJson(data);
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

      //debugPrint('GET Balances Request URL: $url');
      //debugPrint('GET Balances Request Headers: $headers');

      final response = await http.get(url, headers: headers);

     // debugPrint('GET Balances Response Status Code: ${response.statusCode}');
      //debugPrint('GET Balances Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to get balances. Status code: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final balances = data['items'] as List? ?? [];
      //debugPrint('ApiService: Found ${balances.length} balances in response');
      final result = balances.map((e) => Balance.fromJson(e)).toList();
      //debugPrint('ApiService: Parsed ${result.length} Balance objects');
      return result;
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

      //debugPrint('POST Balance Request URL: $url');
      // debugPrint('POST Balance Request Headers: $headers');
      // debugPrint('POST Balance Request Body: $body');

      final response = await http.post(url, headers: headers, body: body);

      debugPrint('POST Balance Response Status Code: ${response.statusCode}');
      //debugPrint('POST Balance Response Body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create balance. Status code: ${response.statusCode}');
      }
      return json.decode(response.body);
    } catch (e) {
      debugPrint('Error creating balance: $e');
      rethrow;
    }
  }

  static Future<void> deleteBalance(String balanceId) async {
    final session = await Amplify.Auth.fetchAuthSession();
    if (!session.isSignedIn) throw Exception('User is not signed in');
    final cognitoSession = session as CognitoAuthSession;
    final token = cognitoSession.userPoolTokensResult.value.idToken.raw;

    final url = Uri.parse('${AppConfig.baseUrl}/balances/$balanceId');
    final headers = {
      'Authorization': 'Bearer $token',
    };

    final response = await http.delete(url, headers: headers);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete balance. Status code:  [31m${response.statusCode} [0m');
    }
  }

  static Future<Map<String, dynamic>> getTransactionById(String transactionId) async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (!session.isSignedIn) {
        throw Exception('User is not signed in');
      }
      final cognitoSession = session as CognitoAuthSession;
      final token = cognitoSession.userPoolTokensResult.value.idToken.raw;
      final url = Uri.parse('${AppConfig.transactionsUrl}/$transactionId');
      final headers = {
        'Authorization': 'Bearer $token',
        'accept': 'application/json',
      };
      // debugPrint('GET Transaction by ID URL: $url');
      // debugPrint('GET Transaction by ID Headers: $headers');
      final response = await http.get(url, headers: headers);
      //debugPrint('GET Transaction by ID Status Code: ${response.statusCode}');
      //debugPrint('GET Transaction by ID Body: ${response.body}');
      if (response.statusCode != 200) {
        throw Exception('Failed to get transaction. Status code: ${response.statusCode}');
      }
      return json.decode(response.body);
    } catch (e) {
      debugPrint('Error getting transaction by id: $e');
      rethrow;
    }
  }

  static Future<List<Merchant>> getMerchants() async {
    final session = await Amplify.Auth.fetchAuthSession();
    if (!session.isSignedIn) {
      throw Exception('User is not signed in');
    }
    final userId = await AuthService.getUserId();
    final cognitoSession = session as CognitoAuthSession;
    final token = cognitoSession.userPoolTokensResult.value.idToken.raw;

    final url = Uri.parse('${AppConfig.baseUrl}/merchants?userId=$userId');
    final headers = {
      'Authorization': 'Bearer $token',
    };
    //debugPrint('[ApiService.getMerchants] URL: $url');
    //debugPrint('[ApiService.getMerchants] HEADERS: $headers');
    final response = await http.get(url, headers: headers);
    //debugPrint('[ApiService.getMerchants] RESPONSE STATUS: ${response.statusCode}');
    //debugPrint('[ApiService.getMerchants] RESPONSE BODY: ${response.body}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List merchantsJson = data['items'] ?? [];
      return merchantsJson.map<Merchant>((e) => Merchant.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load merchants: \\${response.statusCode}');
    }
  }

  static Future<Merchant> postMerchant({required String name, required String userId}) async {
    final session = await Amplify.Auth.fetchAuthSession();
    if (!session.isSignedIn) {
      throw Exception('User is not signed in');
    }
    final cognitoSession = session as CognitoAuthSession;
    final token = cognitoSession.userPoolTokensResult.value.idToken.raw;

    final url = Uri.parse('${AppConfig.baseUrl}/merchants');
    final body = jsonEncode({'name': name, 'userId': userId});
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    //debugPrint('[ApiService.postMerchant] URL: $url');
    //debugPrint('[ApiService.postMerchant] BODY: $body');
    // debugPrint('[ApiService.postMerchant] HEADERS: $headers');
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    //debugPrint('[ApiService.postMerchant] RESPONSE STATUS: ${response.statusCode}');
    //debugPrint('[ApiService.postMerchant] RESPONSE BODY: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Merchant.fromJson(data);
    } else {
      throw Exception('Failed to create merchant: \\${response.statusCode}');
    }
  }
} 