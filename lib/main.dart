import 'package:ahorro_ui/src/screens/home_screen.dart';
import 'package:ahorro_ui/src/screens/transactions_screen.dart';
// Temporarily hidden: import 'package:ahorro_ui/src/screens/budget_screen.dart';
import 'package:ahorro_ui/src/screens/account_screen.dart';
// Temporarily hidden: import 'package:ahorro_ui/src/screens/txn_ai_screen.dart';
import 'package:ahorro_ui/src/screens/default_balance_currency_screen.dart';
import 'package:ahorro_ui/src/screens/merchant_search_screen.dart';
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
import 'src/config/adaptive_theme.dart';
import 'src/widgets/adaptive_navigation.dart';

import 'src/services/auth_service.dart';
import 'src/providers/transaction_entries_provider.dart';
import 'src/providers/app_state_provider.dart';
import 'src/providers/amplify_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppStateProvider(),
      child: const MyApp(),
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
    const env = String.fromEnvironment('ENV', defaultValue: 'stable');
    amplifyconfig = env == 'prod' ? prod_config.amplifyconfig : stable_config.amplifyconfig;
    // Запускаем инициализацию через AppStateProvider
    // Используем addPostFrameCallback, чтобы контекст уже был смонтирован
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppStateProvider>();
      appState.initializeApp(amplifyconfig);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AmplifyProvider>.value(value: appState.amplify),
        ChangeNotifierProvider<BalancesProvider>.value(value: appState.balances),
        ChangeNotifierProvider<CategoriesProvider>.value(value: appState.categories),
        ChangeNotifierProvider<MerchantsProvider>.value(value: appState.merchants),
        ChangeNotifierProvider<TransactionEntriesProvider>.value(value: appState.transactions),
      ],
      child: MaterialApp(
        title: AppStrings.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AdaptiveTheme.lightTheme,
        darkTheme: AdaptiveTheme.darkTheme,
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
