import 'package:employee_management_app/constants/app_textStyles.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_icons.dart';
import '../constants/app_sizes.dart';

class EmptyWidget extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyWidget({
    super.key,
    this.message = 'Nothing here yet',
    this.icon = AppIcons.empty,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.iconXl, color: AppColors.lightTextSecondary),
          const SizedBox(height: AppSizes.md),
          Text(message, style: AppTextStyles.bodySecondary(isDark)),
        ],
      ),
    );
  }
}