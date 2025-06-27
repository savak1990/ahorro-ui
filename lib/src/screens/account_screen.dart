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
        title: const Text('Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('User data not found.'));
          }
          final userData = snapshot.data!;
          final name = userData['name'] as String;
          final email = userData['email'] as String;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 320, maxWidth: 500),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Account Info Card ---
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 24),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person, size: 28, color: Colors.black87),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.email, size: 20, color: Colors.black54),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    email,
                                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.radio_button_checked, size: 18, color: Colors.black45),
                                const SizedBox(width: 8),
                                Text('Basic Account', style: TextStyle(color: Colors.black54, fontSize: 15)),
                              ],
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 2,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () {
                                  debugPrint('Upgrade to Premium clicked');
                                },
                                child: const Text('Upgrade to Premium', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // --- Family Block ---
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 24),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('Family', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _joinFamilyController,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter family code',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.horizontal(left: Radius.circular(12))),
                                      contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 0),
                                SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                                      ),
                                      elevation: 2,
                                    ),
                                    onPressed: () {
                                      debugPrint('Joining with code: \\${_joinFamilyController.text}');
                                    },
                                    child: const Text('Join', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Family code: 1111', style: TextStyle(color: Colors.black54, fontSize: 15)),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () {
                                      Clipboard.setData(const ClipboardData(text: '1111'));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Family code copied!')),
                                      );
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Icon(Icons.copy, size: 18, color: Colors.black38),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // --- Balances Section ---
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 32),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          debugPrint('Go to balances');
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                          child: Row(
                            children: [
                              const Icon(Icons.account_balance_wallet, color: Colors.black87),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text('Balances', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black38),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // --- Sign Out ---
                    const SizedBox(height: 16),
                    Center(
                      child: SizedBox(
                        width: 320,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.black, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            shadowColor: Colors.black12,
                            elevation: 0,
                          ).copyWith(
                            overlayColor: MaterialStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.hovered) || states.contains(MaterialState.pressed)) {
                                return Colors.black12;
                              }
                              return null;
                            }),
                          ),
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
                          icon: const Icon(Icons.logout, color: Colors.black),
                          label: const Text('Sign Out'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 