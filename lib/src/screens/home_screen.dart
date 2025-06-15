import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../constants/app_strings.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<String> _fetchUserName() async {
    try {
      final attributes = await Amplify.Auth.fetchUserAttributes();
      final nameAttr = attributes.firstWhere(
        (attr) => attr.userAttributeKey.key == 'name',
        orElse: () => const AuthUserAttribute(
          userAttributeKey: CognitoUserAttributeKey.name,
          value: 'User',
        ),
      );
      return nameAttr.value;
    } catch (e) {
      return 'User';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/account');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Spacer(flex: 1),
          FutureBuilder<String>(
            future: _fetchUserName(),
            builder: (context, snapshot) {
              final name = snapshot.data ?? 'User';
              return Text(
                'Hello, $name',
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              );
            },
          ),
          const Spacer(flex: 2),
          const Center(
            child: Text(
              'Welcome to the Home Screen!',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
