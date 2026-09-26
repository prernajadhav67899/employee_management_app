import 'package:employee_management_app/constants/app_textStyles.dart';
import 'package:employee_management_app/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_icons.dart';
import '../../constants/app_sizes.dart';
import '../../utils/app_routes.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfields.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _run(Future<String?> Function() action) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final error = await action();

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _errorMessage = error;
    });

    // On success the AuthWrapper swaps the screen automatically.
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;
    _run(() => context.read<AuthProvider>().login(
          _emailController.text,
          _passwordController.text,
        ));
  }

  void _handleGoogleSignIn() {
    _run(() => context.read<AuthProvider>().signInWithGoogle());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet =
        MediaQuery.of(context).size.width > AppSizes.mobileMaxWidth;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.lg,
              vertical: AppSizes.xl,
            ),
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: isTablet ? 440 : double.infinity),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.badge_outlined,
                        size: 56, color: AppColors.primary),
                    const SizedBox(height: AppSizes.md),
                    Text('Welcome back',
                        style: AppTextStyles.heading1(isDark),
                        textAlign: TextAlign.center),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      'Sign in to manage your employees',
                      style: AppTextStyles.bodySecondary(isDark),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.xl),
                    if (_errorMessage != null) ...[
                      _ErrorBanner(message: _errorMessage!),
                      const SizedBox(height: AppSizes.md),
                    ],
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'you@example.com',
                      prefixIcon: AppIcons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: AppSizes.md),
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      prefixIcon: AppIcons.password,
                      isPassword: true,
                      validator: Validators.password,
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(
                            context, AppRoutes.forgotPassword),
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    CustomButton(
                      label: 'Log In',
                      onPressed: _handleLogin,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: AppSizes.lg),
                    Row(
                      children: [
                        Expanded(
                            child: Divider(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder)),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.sm),
                          child: Text('or',
                              style: AppTextStyles.caption(isDark)),
                        ),
                        Expanded(
                            child: Divider(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder)),
                      ],
                    ),
                    const SizedBox(height: AppSizes.lg),
                    CustomButton(
                      label: 'Continue with Google',
                      onPressed: _handleGoogleSignIn,
                      isOutlined: true,
                      icon: AppIcons.google,
                    ),
                    const SizedBox(height: AppSizes.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ",
                            style: AppTextStyles.bodySecondary(isDark)),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.register),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Inline error banner shared by the auth screens.
class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Row(
        children: [
          const Icon(AppIcons.error,
              color: AppColors.error, size: AppSizes.iconSm),
          const SizedBox(width: AppSizes.sm),
          Expanded(child: Text(message, style: AppTextStyles.errorText)),
        ],
      ),
    );
  }
}