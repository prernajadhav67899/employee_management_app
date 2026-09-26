import 'package:employee_management_app/data/repositories/contry_repository.dart';
import 'package:employee_management_app/providers/auth_providers.dart';
import 'package:employee_management_app/services/auth_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants/app_colors.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/employee_repository_impl.dart';
import 'features/auth/forget_password.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/splash_screen.dart';
import 'features/dashboard/employee_list_screen.dart';
import 'features/dashboard/profile_screen.dart';
import 'firebase_options.dart';
import 'providers/employee_provider.dart';
import 'services/api_client.dart';
import 'utils/app_routes.dart';

class ThemeController {
  ThemeController._();

  static const _key = 'theme_mode_dark';
  static final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.light);
  static SharedPreferences? _prefs;

  static Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final isDark = _prefs?.getBool(_key) ?? false;
    mode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static void toggle() {
    final isDark = mode.value != ThemeMode.dark;
    mode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    _prefs?.setBool(_key, isDark);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AuthService.initGoogle();
  await ThemeController.load();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            repository: AuthRepositoryImpl(service: AuthService()),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => EmployeeProvider(
            repository: EmployeeRepositoryImpl(api: apiClient),
            countryRepository: CountryRepositoryImpl(api: apiClient),
          ),
        ),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeController.mode,
        builder: (context, mode, _) {
          return MaterialApp(
            title: 'Employee Management',
            debugShowCheckedModeBanner: false,
            themeMode: mode,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              scaffoldBackgroundColor: AppColors.lightBackground,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                brightness: Brightness.light,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.lightSurface,
                foregroundColor: AppColors.lightTextPrimary,
                elevation: 0,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: AppColors.darkBackground,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                brightness: Brightness.dark,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.darkSurface,
                foregroundColor: AppColors.darkTextPrimary,
                elevation: 0,
              ),
            ),
            home: const AuthWrapper(),
            routes: {
              AppRoutes.login: (context) => const LoginScreen(),
              AppRoutes.register: (context) => const RegisterScreen(),
              AppRoutes.forgotPassword: (context) =>
                  const ForgotPasswordScreen(),
              AppRoutes.dashboard: (context) => const EmployeeListScreen(),
              AppRoutes.profile: (context) => const ProfileScreen(),
            },
          );
        },
      ),
    );
  }
}