import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/services.dart';
import '../../src/constants/app_colors.dart';
import '../../src/screens/balances_screen.dart';

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
        title: Text(
          'Account',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        shadowColor: AppColors.divider,
      ),
      backgroundColor: AppColors.background,
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
                    // --- Profile Section ---
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Profile',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person, size: 28, color: AppColors.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  name,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.email, size: 20, color: AppColors.accent),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  email,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.radio_button_checked, size: 18, color: AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Text('Basic Account', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                            ],
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.surface,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () {
                                debugPrint('Upgrade to Premium clicked');
                              },
                              child: Text('Upgrade to Premium', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.surface)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // --- Family Section ---
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Family',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _joinFamilyController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter family code',
                                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textHint),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.horizontal(left: Radius.circular(12))),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 0),
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.surface,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    debugPrint('Joining with code: \\${_joinFamilyController.text}');
                                  },
                                  child: Text('Join', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.surface)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Family code: 1111', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
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
                                    child: Icon(Icons.copy, size: 18, color: AppColors.accent),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // --- Balances Section ---
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Balances',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.only(bottom: 32),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const BalancesScreen(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                          child: Row(
                            children: [
                              Icon(Icons.account_balance_wallet, color: AppColors.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text('Balances', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              ),
                              Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.accent),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // --- Account Actions Section ---
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Account Actions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.only(bottom: 0),
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: SizedBox(
                          width: 320,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                              shadowColor: Colors.black12,
                              elevation: 0,
                            ).copyWith(
                              overlayColor: MaterialStateProperty.resolveWith((states) {
                                if (states.contains(MaterialState.hovered) || states.contains(MaterialState.pressed)) {
                                  return AppColors.hover;
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
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              }
                            },
                            icon: Icon(Icons.logout, color: AppColors.primary),
                            label: const Text('Sign Out'),
                          ),
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