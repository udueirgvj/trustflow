// main.dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/store_screen.dart';
import 'screens/robots_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool? _hasSession;

  @override
  void initState() {
    super.initState();
    _hasSession = SupabaseService.currentSession != null;
    SupabaseService.authStateChanges.listen((state) {
      if (!mounted) return;
      setState(() => _hasSession = state.session != null);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasSession == true) return const MainNav();
    return const LoginScreen();
  }
}

class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _currentIndex = 0;

  // الانتقال لقسم المتجر
  void _goToStore() => setState(() => _currentIndex = 1);

  // الانتقال لقسم الروبوتات
  void _goToRobots() => setState(() => _currentIndex = 2);

  @override
  Widget build(BuildContext context) {
    final screens = [
      // ✅ نمرر onGoToStore و onGoToRobots لـ HomeScreen
      HomeScreen(
        onGoToStore: _goToStore,
        onGoToRobots: _goToRobots,
      ),
      const StoreScreen(),
      RobotsScreen(onGoToStore: _goToStore),
      const WalletScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: AppColors.bgCard,
        selectedItemColor: Colors.cyan,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), label: 'Store'),
          BottomNavigationBarItem(icon: Icon(Icons.memory_outlined), label: 'Robots'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}
