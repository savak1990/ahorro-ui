import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/services.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late Future<Map<String, dynamic>> _userInfoFuture;
  final _joinFamilyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userInfoFuture = _fetchUserInfo();
  }

  @override
  void dispose() {
    _joinFamilyController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchUserInfo() async {
    final attributes = await Amplify.Auth.fetchUserAttributes();
    
    final nameAttribute = attributes.firstWhere(
      (element) => element.userAttributeKey.key == 'name',
      orElse: () => const AuthUserAttribute(
        userAttributeKey: CognitoUserAttributeKey.name,
        value: 'User',
      ),
    );
    
    final emailAttribute = attributes.firstWhere(
      (element) => element.userAttributeKey.key == 'email',
      orElse: () => const AuthUserAttribute(
        userAttributeKey: CognitoUserAttributeKey.email,
        value: 'N/A',
      ),
    );

    return {
      'name': nameAttribute.value,
      'email': emailAttribute.value,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('User data not found.'));
          }
          
          final userData = snapshot.data!;
          final name = userData['name'] as String;
          final email = userData['email'] as String;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  email,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Your Family Code',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('1111', style: TextStyle(fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(const ClipboardData(text: '1111'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Family code copied!')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Join a Family',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _joinFamilyController,
                        decoration: const InputDecoration(
                          labelText: 'Enter code',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Implement join family logic
                        debugPrint(
                            'Joining with code: ${_joinFamilyController.text}');
                      },
                      child: const Text('Join'),
                    ),
                  ],
                ),
                const Spacer(),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await Amplify.Auth.signOut();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error signing out: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 