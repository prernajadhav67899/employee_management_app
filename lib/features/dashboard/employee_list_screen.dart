import 'package:employee_management_app/features/employee/employee_detail_screen.dart';
import 'package:employee_management_app/main.dart';
import 'package:employee_management_app/widgets/loading_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_icons.dart';
import '../../constants/app_sizes.dart';
import '../../data/models/employee_model.dart';
import '../../providers/auth_providers.dart';
import '../../providers/employee_provider.dart';
import '../../utils/app_routes.dart';
import '../employee/employee_form.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/empty_widget.dart';
import '../../widgets/error_widget.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().fetchEmployees();
    });
  }

  void _openForm({Employee? editEmployee}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmployeeFormScreen(editEmployee: editEmployee),
      ),
    );
  }

  Future<void> _handleLogout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
  }

  Future<void> _performDelete(Employee employee) async {
    final error = await context.read<EmployeeProvider>().deleteEmployee(employee.id);
    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete ${employee.name}: $error')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${employee.name} deleted')),
    );
  }

  void _handleDelete(Employee employee) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.name}? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _performDelete(employee);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<EmployeeProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Employees'),
        actions: [
          IconButton(
            icon: Icon(isDark ? AppIcons.lightMode : AppIcons.darkMode),
            onPressed: ThemeController.toggle,
          ),
          IconButton(
            icon: const Icon(AppIcons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        backgroundColor: AppColors.primary,
        child: const Icon(AppIcons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.sm),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) => context.read<EmployeeProvider>().setQuery(value),
                  decoration: InputDecoration(
                    hintText: 'Search by ${provider.filter.name}...',
                    prefixIcon: const Icon(AppIcons.search, size: AppSizes.iconSm),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: AppSizes.iconSm),
                            onPressed: () {
                              _searchController.clear();
                              context.read<EmployeeProvider>().setQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: FilterField.values.map((field) {
                      final isSelected = field == provider.filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSizes.sm),
                        child: ChoiceChip(
                          label: Text(field.name[0].toUpperCase() + field.name.substring(1)),
                          selected: isSelected,
                          onSelected: (_) => context.read<EmployeeProvider>().setFilter(field),
                          selectedColor: AppColors.primary.withOpacity(0.15),
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primary : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                          side: BorderSide(color: isSelected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody(isDark, provider)),
        ],
      ),
    );
  }

  Widget _buildBody(bool isDark, EmployeeProvider provider) {
    if (provider.isLoading) return const LoadingWidget(message: 'Loading employees...');

    if (provider.errorMessage != null) {
      return ErrorWidgetView(message: provider.errorMessage!, onRetry: provider.refresh);
    }

    final employees = provider.filteredEmployees;

    if (employees.isEmpty) {
      return EmptyWidgetWrapper(searchActive: _searchController.text.isNotEmpty);
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: AppSizes.xl),
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final employee = employees[index];
          return CustomCard(
            employee: employee,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EmployeeDetailScreen(
                    employee: employee,
                    onEdit: () => _openForm(editEmployee: employee),
                    onDelete: () => _performDelete(employee),
                  ),
                ),
              );
            },
            onEdit: () => _openForm(editEmployee: employee),
            onDelete: () => _handleDelete(employee),
          );
        },
      ),
    );
  }
}

class EmptyWidgetWrapper extends StatelessWidget {
  final bool searchActive;
  const EmptyWidgetWrapper({super.key, required this.searchActive});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: EmptyWidget(
              message: searchActive ? 'No employees match your search' : 'No employees yet',
              icon: searchActive ? AppIcons.search : AppIcons.empty,
            ),
          ),
        );
      },
    );
  }
}