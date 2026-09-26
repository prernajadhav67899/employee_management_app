import 'package:employee_management_app/constants/app_textStyles.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_icons.dart';
import '../constants/app_sizes.dart';
import 'custom_button.dart';

class ErrorWidgetView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorWidgetView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(AppIcons.error, size: AppSizes.iconXl, color: AppColors.error),
            const SizedBox(height: AppSizes.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body(isDark),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSizes.lg),
              SizedBox(
                width: 160,
                child: CustomButton(label: 'Retry', onPressed: onRetry, icon: AppIcons.refresh),
              ),
            ],
          ],
        ),
      ),
    );
  }
}