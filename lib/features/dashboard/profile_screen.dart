import 'package:employee_management_app/constants/app_textStyles.dart';
import 'package:employee_management_app/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_icons.dart';
import '../../constants/app_sizes.dart';
import '../../main.dart';
import '../../widgets/custom_button.dart';

/// Shows the signed-in user's name, email and profile photo,
/// plus the theme toggle and logout.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final navigator = Navigator.of(context);
    final auth = context.read<AuthProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Log out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await auth.logout();
    // AuthWrapper sits at the first route and swaps to Login itself.
    navigator.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();

    final name = auth.displayName;
    final email = auth.email;
    final photo = auth.photoUrl;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            children: [
              Semantics(
                label: 'Profile photo of $name',
                child: CircleAvatar(
                  radius: AppSizes.avatarLg,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  backgroundImage:
                      photo.isNotEmpty ? NetworkImage(photo) : null,
                  child: photo.isEmpty
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            fontSize: 32,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Text(name, style: AppTextStyles.heading1(isDark)),
              const SizedBox(height: AppSizes.xs),
              Text(email, style: AppTextStyles.bodySecondary(isDark)),
              const SizedBox(height: AppSizes.xl),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSizes.md),
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: ValueListenableBuilder<ThemeMode>(
                  valueListenable: ThemeController.mode,
                  builder: (context, mode, _) {
                    final darkActive = mode == ThemeMode.dark;
                    return SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Dark Mode',
                        style: AppTextStyles.body(isDark),
                      ),
                      secondary: Icon(
                        darkActive ? AppIcons.darkMode : AppIcons.lightMode,
                        color: AppColors.primary,
                      ),
                      value: darkActive,
                      activeThumbColor: AppColors.primary,
                      onChanged: (_) => ThemeController.toggle(),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSizes.xl),
              CustomButton(
                label: 'Logout',
                icon: AppIcons.logout,
                color: AppColors.error,
                onPressed: () => _confirmLogout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}