import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'base_provider.dart';

class AmplifyProvider extends BaseProvider {
  bool _isConfigured = false;
  String? _currentUserName;
  bool _isFetchingUserName = false;

  bool get isConfigured => _isConfigured || Amplify.isConfigured;
  String? get currentUserName => _currentUserName;

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

  Future<void> ensureSignedIn() async {
    await execute(() async {
      final session = await Amplify.Auth.fetchAuthSession();
      if (!session.isSignedIn) {
        try {
          await Amplify.Auth.signInWithWebUI();
        } catch (e) {
          debugPrint('[AmplifyProvider]: sign-in cancelled or failed: $e');
          rethrow;
        }
      }
    });
  }

  Future<void> loadCurrentUserName() async {
    if (!isConfigured || _isFetchingUserName) return;
    _isFetchingUserName = true;
    try {
      final attributes = await Amplify.Auth.fetchUserAttributes();
      final nameAttr = attributes.firstWhere(
        (attr) => attr.userAttributeKey.key == 'name',
        orElse: () => const AuthUserAttribute(
          userAttributeKey: CognitoUserAttributeKey.name,
          value: 'User',
        ),
      );
      _currentUserName = (nameAttr.value.isNotEmpty) ? nameAttr.value : 'User';
      notifyListeners();
    } catch (e) {
      debugPrint('[AmplifyProvider]: failed to fetch user name: $e');
    } finally {
      _isFetchingUserName = false;
    }
  }

  void clearUserData() {
    _currentUserName = null;
    notifyListeners();
  }
}
