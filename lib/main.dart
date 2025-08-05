import 'package:ahorro_ui/src/screens/home_screen.dart';
import 'package:ahorro_ui/src/screens/transactions_screen.dart';
// Temporarily hidden: import 'package:ahorro_ui/src/screens/budget_screen.dart';
import 'package:ahorro_ui/src/screens/settings_screen.dart';
import 'package:ahorro_ui/src/screens/account_screen.dart';
// Temporarily hidden: import 'package:ahorro_ui/src/screens/txn_ai_screen.dart';
import 'package:ahorro_ui/src/screens/default_balance_currency_screen.dart';
import 'package:ahorro_ui/src/screens/merchant_search_screen.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/providers/balances_provider.dart';
import 'src/providers/categories_provider.dart';
import 'src/providers/merchants_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'amplifyconfiguration.dart' as stable_config;
import 'amplifyconfiguration_prod.dart' as prod_config;

import 'src/constants/app_colors.dart';
import 'src/constants/app_strings.dart';
import 'src/config/app_theme.dart';
import 'src/widgets/adaptive_navigation.dart';

import 'src/services/auth_service.dart';
import 'src/providers/transaction_entries_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //print('PWD: ${Directory.current.path}');
  //print('ENV EXISTS: ${File('.env').existsSync()}');
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BalancesProvider()..loadBalances()),
        ChangeNotifierProvider(create: (_) => CategoriesProvider()..loadCategories()),
        ChangeNotifierProvider(create: (_) => MerchantsProvider()..loadMerchants()),
        ChangeNotifierProvider(create: (_) => TransactionEntriesProvider()..loadEntries()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String amplifyconfig;

  @override
  void initState() {
    super.initState();
    // Select config based on ENV dart define
    const env = String.fromEnvironment('ENV', defaultValue: 'stable');
    if (env == 'prod') {
      amplifyconfig = prod_config.amplifyconfig;
    } else {
      amplifyconfig = stable_config.amplifyconfig;
    }
    _configureAmplify();
  }

  Future<void> _configureAmplify() async {
    try {
      final auth = AmplifyAuthCognito();
      await Amplify.addPlugin(auth);
      await Amplify.configure(amplifyconfig);
    } on Exception catch (e) {
      safePrint('An error occurred configuring Amplify: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Authenticator(
      signUpForm: SignUpForm.custom(fields: [
        SignUpFormField.name(required: true),
        SignUpFormField.email(required: true),
        SignUpFormField.password(),
        SignUpFormField.passwordConfirmation()
      ]),
      child: MaterialApp(
        builder: Authenticator.builder(),
        title: AppStrings.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: '/',
        routes: {
          '/': (context) => const MainScreen(),
          '/account': (context) => const AccountScreen(),
          '/transactions': (context) => const TransactionsScreen(),
          '/default-balance-currency': (context) => const DefaultBalanceCurrencyScreen(),
          '/merchant_search': (context) => const MerchantSearchScreen(),
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String? _pendingTransactionType;

  void _showTransactionsTab([String? type]) {
    setState(() {
      _selectedIndex = 1; // Transactions tab
      _pendingTransactionType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      HomeScreen(
        onShowTransactions: (type) => _showTransactionsTab(type),
      ),
      TransactionsScreen(
        initialType: _pendingTransactionType,
      ),
      // Temporarily hidden: const BudgetScreen(),
      // Temporarily hidden: const TxnAiScreen(),
    ];

    final List<NavigationDestination> _destinations = const [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Home',
      ),
      NavigationDestination(
        icon: Icon(Icons.swap_horiz_outlined),
        selectedIcon: Icon(Icons.swap_horiz),
        label: 'Transactions',
      ),
      // Temporarily hidden: NavigationDestination(
      //   icon: Icon(Icons.account_balance_wallet_outlined),
      //   selectedIcon: Icon(Icons.account_balance_wallet),
      //   label: 'Budget',
      // ),
      // Temporarily hidden: NavigationDestination(
      //   icon: Icon(Icons.smart_toy_outlined),
      //   selectedIcon: Icon(Icons.smart_toy_outlined),
      //   label: 'TxnAi',
      // ),
    ];

    return AdaptiveNavigation(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
          if (index != 1) _pendingTransactionType = null;
        });
      },
      children: _screens,
      destinations: _destinations,
    );
  }
}
