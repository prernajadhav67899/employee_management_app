import 'package:employee_management_app/constants/app_textStyles.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';


/// Reusable primary/secondary button with a built-in loading spinner.
/// Used on every submit action (login, register, save employee...).
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? color;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.primary;

    final child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppSizes.iconSm, color: isOutlined ? bg : Colors.white),
                const SizedBox(width: AppSizes.sm),
              ],
              Text(
                label,
                style: AppTextStyles.button.copyWith(color: isOutlined ? bg : Colors.white),
              ),
            ],
          );

    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: bg, width: 1.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              child: child,
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: bg,
                disabledBackgroundColor: bg.withOpacity(0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                elevation: 0,
              ),
              child: child,
            ),
    );
  }
}