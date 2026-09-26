import 'package:employee_management_app/constants/app_textStyles.dart';
import 'package:employee_management_app/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_icons.dart';
import '../../constants/app_sizes.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfields.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final error = await context
        .read<AuthProvider>()
        .sendPasswordReset(_emailController.text);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _errorMessage = error;
      _emailSent = error == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet =
        MediaQuery.of(context).size.width > AppSizes.mobileMaxWidth;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(AppIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 440 : double.infinity,
              ),
              child: _emailSent
                  ? _buildSuccessState(isDark)
                  : _buildFormState(isDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormState(bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.lock_reset_outlined,
            size: 56,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSizes.md),
          Text('Reset your password', style: AppTextStyles.heading1(isDark)),
          const SizedBox(height: AppSizes.xs),
          Text(
            "Enter the email associated with your account and we'll send a "
            "link to reset your password.",
            style: AppTextStyles.bodySecondary(isDark),
          ),
          const SizedBox(height: AppSizes.xl),
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Row(
                children: [
                  const Icon(
                    AppIcons.error,
                    color: AppColors.error,
                    size: AppSizes.iconSm,
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyles.errorText,
                    ),
                  ),
                ],
              ),
            ),
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
          const SizedBox(height: AppSizes.lg),
          CustomButton(
            label: 'Send Reset Link',
            onPressed: _handleResetPassword,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.mark_email_read_outlined,
          size: 64,
          color: AppColors.success,
        ),
        const SizedBox(height: AppSizes.lg),
        Text(
          'Check your email',
          style: AppTextStyles.heading2(isDark),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.sm),
        Text(
          "We've sent a password reset link to "
          "${_emailController.text.trim()}",
          style: AppTextStyles.bodySecondary(isDark),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.xl),
        CustomButton(
          label: 'Back to Log In',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}