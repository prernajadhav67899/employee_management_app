import 'package:employee_management_app/constants/app_textStyles.dart';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_icons.dart';
import '../../constants/app_sizes.dart';
import '../../data/models/employee_model.dart';
import '../../widgets/custom_button.dart';

class EmployeeDetailScreen extends StatelessWidget {
  final Employee employee;
  final VoidCallback? onEdit;

  final Future<void> Function()? onDelete;

  const EmployeeDetailScreen({
    super.key,
    required this.employee,
    this.onEdit,
    this.onDelete,
  });

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.name}? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    await onDelete?.call();

    if (!context.mounted) return;
    Navigator.pop(context); // leave detail screen, exactly once
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppSizes.iconSm, color: AppColors.primary),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption(isDark)),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : '—',
                  style: AppTextStyles.body(isDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Employee Details'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.edit),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(AppIcons.delete, color: AppColors.error),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            children: [
              CircleAvatar(
                radius: AppSizes.avatarLg,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                backgroundImage: employee.avatar.isNotEmpty ? NetworkImage(employee.avatar) : null,
                child: employee.avatar.isEmpty
                    ? Text(
                        employee.name.isNotEmpty ? employee.name[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 32, color: AppColors.primary, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(height: AppSizes.md),
              Text(employee.name, style: AppTextStyles.heading1(isDark)),
              const SizedBox(height: AppSizes.xs),
              Text('Employee ID: ${employee.id}', style: AppTextStyles.bodySecondary(isDark)),
              const SizedBox(height: AppSizes.xl),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Column(
                  children: [
                    _infoRow(context, AppIcons.email, 'Email', employee.email),
                    Divider(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, height: 1),
                    _infoRow(context, AppIcons.phone, 'Mobile', employee.mobile),
                    Divider(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, height: 1),
                    _infoRow(context, AppIcons.location, 'Country', employee.country),
                    Divider(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, height: 1),
                    _infoRow(context, AppIcons.location, 'State', employee.state),
                    Divider(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, height: 1),
                    _infoRow(context, AppIcons.location, 'District', employee.district),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.xl),

              Row(
                children: [
                  Expanded(
                    child: CustomButton(label: 'Edit', icon: AppIcons.edit, onPressed: onEdit),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: CustomButton(
                      label: 'Delete',
                      icon: AppIcons.delete,
                      color: AppColors.error,
                      onPressed: () => _confirmDelete(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}