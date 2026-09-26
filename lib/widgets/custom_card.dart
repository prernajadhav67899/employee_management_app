import 'package:employee_management_app/constants/app_textStyles.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../data/models/employee_model.dart';

/// Card representing a single employee in the dashboard list.
/// Tapping opens the detail screen; the trailing menu offers
/// Edit/Delete directly from the list.
class CustomCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool showActions;

  const CustomCard({
    super.key,
    required this.employee,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.xs,
      ),
      elevation: 0,
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              CircleAvatar(
                radius: AppSizes.avatarSm,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                backgroundImage: employee.avatar.isNotEmpty
                    ? NetworkImage(employee.avatar)
                    : null,
                child: employee.avatar.isEmpty
                    ? Text(
                        employee.name.isNotEmpty
                            ? employee.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.name,
                      style: AppTextStyles.heading3(isDark),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      employee.email,
                      style: AppTextStyles.bodySecondary(isDark),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${employee.district}, ${employee.state}, ${employee.country}',
                      style: AppTextStyles.caption(isDark),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (showActions)
                PopupMenuButton<String>(
                  tooltip: 'Employee actions',
                  icon: Icon(
                    Icons.more_vert,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}