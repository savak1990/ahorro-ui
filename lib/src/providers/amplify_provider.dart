import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'base_provider.dart';

class AmplifyProvider extends BaseProvider {
  bool _isConfigured = false;

  bool get isConfigured => _isConfigured || Amplify.isConfigured;

  Future<void> configure(String amplifyconfig) async {
    if (isConfigured) {
      _isConfigured = true;
      return;
    }

    await execute(() async {
      try {
        final auth = AmplifyAuthCognito();
        await Amplify.addPlugin(auth);
      } catch (_) {
        // Плагин мог быть добавлен ранее при hot-restart — игнорируем
      }
      if (!Amplify.isConfigured) {
        await Amplify.configure(amplifyconfig);
      }
      _isConfigured = true;
      debugPrint('[AmplifyProvider]: configured');
    });
  }
}