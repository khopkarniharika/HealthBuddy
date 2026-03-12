import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/user.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/emergency_dashboard_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/heart_rate_service.dart';
import 'services/settings_service.dart';
import 'services/sms_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HeartRateApp());
}

class HeartRateApp extends StatelessWidget {
  const HeartRateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<SmsService>(create: (_) => SmsService()),
        Provider<HeartRateService>(create: (_) => HeartRateService()),
        Provider<SettingsService>(create: (_) => SettingsService()),
        ChangeNotifierProvider<SettingsProvider>(
          create: (context) =>
              SettingsProvider(context.read<SettingsService>())..load(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            context.read<AuthService>(),
            context.read<SmsService>(),
          )..loadUsers(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          final settingsService = context.read<SettingsService>();

          if (settingsProvider.isLoading) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: const Scaffold(
                backgroundColor: Color(0xFF1E2A3A),
                body: Center(
                  child: CircularProgressIndicator(color: Colors.cyan),
                ),
              ),
            );
          }

          final theme = settingsService.buildTheme(settingsProvider.settings);

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Heart Rate Monitor',
            theme: theme,
            home: const LoginScreen(),
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case HomeScreen.routeName:
                  final user = settings.arguments as User;
                  return MaterialPageRoute(
                    builder: (_) => HomeScreen(user: user),
                  );
                case EmergencyDashboardScreen.routeName:
                  final user = settings.arguments as User;
                  return MaterialPageRoute(
                    builder: (_) => EmergencyDashboardScreen(user: user),
                  );
                default:
                  return MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  );
              }
            },
          );
        },
      ),
    );
  }
}

