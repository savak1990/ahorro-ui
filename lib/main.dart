import 'package:ahorro_ui/src/screens/home_screen.dart';
import 'package:ahorro_ui/src/screens/transactions_screen.dart';
// Temporarily hidden: import 'package:ahorro_ui/src/screens/budget_screen.dart';
import 'package:ahorro_ui/src/screens/account_screen.dart';
// Temporarily hidden: import 'package:ahorro_ui/src/screens/txn_ai_screen.dart';
import 'package:ahorro_ui/src/screens/default_balance_currency_screen.dart';
import 'package:ahorro_ui/src/screens/merchant_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'dart:async';
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
import 'package:amplify_flutter/amplify_flutter.dart';
import 'src/providers/transaction_entries_provider.dart';
import 'src/providers/app_state_provider.dart';
import 'src/providers/amplify_provider.dart';
import 'src/providers/transactions_filter_provider.dart';

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
  StreamSubscription? _hubSub;

  @override
  void initState() {
    super.initState();
    const env = String.fromEnvironment('ENV', defaultValue: 'stable');
    amplifyconfig =
        env == 'prod' ? prod_config.amplifyconfig : stable_config.amplifyconfig;
    // Конфигурируем Amplify один раз до появления Authenticator UI
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final appState = context.read<AppStateProvider>();
      await appState.amplify.configure(amplifyconfig);
      // Если уже залогинен при старте – инициализируем данные
      try {
        final session = await Amplify.Auth.fetchAuthSession();
        if (session.isSignedIn) {
          await appState.initializeApp(amplifyconfig);
        }
      } catch (_) {}
      // Подписка на события аутентификации
      _hubSub = Amplify.Hub.listen(HubChannel.Auth, (event) async {
        if (!mounted) return;
        if (event is AuthHubEvent) {
          switch (event.type) {
            case AuthHubEventType.signedIn:
              await appState.initializeApp(amplifyconfig);
              break;
            case AuthHubEventType.signedOut:
            case AuthHubEventType.sessionExpired:
              // Clear ALL cached user data when user signs out
              appState.clearAllUserData();
              break;
            default:
              break;
          }
        } else if (event.eventName == 'SIGNED_IN') {
          await appState.initializeApp(amplifyconfig);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AmplifyProvider>.value(value: appState.amplify),
        ChangeNotifierProvider<BalancesProvider>.value(
            value: appState.balances),
        ChangeNotifierProvider<CategoriesProvider>.value(
            value: appState.categories),
        ChangeNotifierProvider<MerchantsProvider>.value(
            value: appState.merchants),
        ChangeNotifierProvider<TransactionEntriesProvider>.value(
            value: appState.transactions),
        ChangeNotifierProvider<TransactionsFilterProvider>(
            create: (_) => TransactionsFilterProvider()),
      ],
      child: Authenticator(
        child: MaterialApp(
          builder: Authenticator.builder(),
          title: AppStrings.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AdaptiveTheme.lightTheme,
          darkTheme: AdaptiveTheme.darkTheme,
          themeMode: ThemeMode.system,
          initialRoute: '/',
          routes: {
            '/': (context) => _AuthGate(amplifyconfig: amplifyconfig),
            '/account': (context) => const AccountScreen(),
            '/transactions': (context) => const TransactionsScreen(),
            '/default-balance-currency': (context) =>
                const DefaultBalanceCurrencyScreen(),
            '/merchant_search': (context) => const MerchantSearchScreen(),
          },
        ),
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
  bool _didCheckBalancesForDefaultCurrency = false;

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

    // Проверка на отсутствие активных балансов и редирект на выбор валюты по умолчанию
    final balancesProvider = context.watch<BalancesProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_didCheckBalancesForDefaultCurrency) return;
      if (balancesProvider.isLoading || balancesProvider.errorMessage != null)
        return;
      if (!balancesProvider.hasData)
        return; // Ждём, пока балансы будут загружены хотя бы один раз
      final int activeCount =
          balancesProvider.balances.where((b) => b.deletedAt == null).length;
      if (activeCount == 0) {
        _didCheckBalancesForDefaultCurrency = true;
        Navigator.of(context).pushReplacementNamed('/default-balance-currency');
      } else {
        _didCheckBalancesForDefaultCurrency = true;
      }
    });

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

class _AuthGate extends StatefulWidget {
  final String amplifyconfig;
  const _AuthGate({required this.amplifyconfig});

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  @override
  Widget build(BuildContext context) {
    // Authenticator сам управляет показом форм/детей; тут просто корневой экран
    return const MainScreen();
  }
}
