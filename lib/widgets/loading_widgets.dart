import 'package:employee_management_app/constants/app_textStyles.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';


/// Shown while data is loading (list fetch, submit in progress, etc).
class LoadingWidget extends StatelessWidget {
  final String? message;
  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          if (message != null) ...[
            const SizedBox(height: AppSizes.md),
            Text(message!, style: AppTextStyles.bodySecondary(isDark)),
          ],
        ],
      ),
    );
  }
}