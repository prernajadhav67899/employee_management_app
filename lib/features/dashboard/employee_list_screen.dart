import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_icons.dart';
import '../../constants/app_sizes.dart';
import '../../data/models/employee_model.dart';
import '../../main.dart';
import '../../providers/employee_provider.dart';
import '../../utils/app_routes.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/empty_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widgets.dart';
import '../employee/employee_detail_screen.dart';
import '../employee/employee_form.dart';

/// Search modes. [id] hits GET /employee/:id directly; the rest
/// filter the already-loaded list client-side.
enum _SearchMode { id, name, email, mobile, country }

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final _searchController = TextEditingController();
  _SearchMode _mode = _SearchMode.name;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().fetchEmployees();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  EmployeeProvider get _provider => context.read<EmployeeProvider>();

  void _onSearchChanged(String value) {
    if (_mode == _SearchMode.id) return; // ID search is submit-driven
    _provider.setQuery(value);
  }

  void _onModeChanged(_SearchMode mode) {
    setState(() => _mode = mode);
    _searchController.clear();
    _provider.clearIdSearch();
    _provider.setQuery('');

    if (mode != _SearchMode.id) {
      _provider.setFilter(FilterField.values.byName(mode.name));
    }
  }

  void _submitIdSearch() {
    final id = _searchController.text.trim();
    if (id.isEmpty) {
      _provider.clearIdSearch();
      return;
    }
    _provider.searchById(id);
  }

  Future<void> _openForm({Employee? employee}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmployeeFormScreen(editEmployee: employee),
      ),
    );
  }

  void _openDetail(Employee employee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmployeeDetailScreen(
          employee: employee,
          onEdit: () => _openForm(employee: employee),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Employee employee) async {
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text(
          'Are you sure you want to delete ${employee.name}? This cannot be undone.',
        ),
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

    final error = await _provider.deleteEmployee(employee.id);

    messenger.showSnackBar(
      SnackBar(
        content: Text(error ?? '${employee.name} deleted'),
        backgroundColor: error != null ? AppColors.error : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Employees'),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            icon: Icon(isDark ? AppIcons.lightMode : AppIcons.darkMode),
            onPressed: ThemeController.toggle,
          ),
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(AppIcons.person),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add employee',
        onPressed: () => _openForm(),
        backgroundColor: AppColors.primary,
        child: const Icon(AppIcons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildSearchBar(isDark),
          Expanded(child: _buildBody(isDark)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      borderSide: BorderSide(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.sm),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onSubmitted: (_) => _submitIdSearch(),
            textInputAction: _mode == _SearchMode.id
                ? TextInputAction.search
                : TextInputAction.done,
            keyboardType: _mode == _SearchMode.id || _mode == _SearchMode.mobile
                ? TextInputType.number
                : TextInputType.text,
            decoration: InputDecoration(
              hintText: _mode == _SearchMode.id
                  ? 'Enter employee ID and press search'
                  : 'Search by ${_mode.name}...',
              prefixIcon: const Icon(AppIcons.search, size: AppSizes.iconSm),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.close, size: AppSizes.iconSm),
                      onPressed: () {
                        _searchController.clear();
                        _provider.setQuery('');
                        _provider.clearIdSearch();
                        setState(() {});
                      },
                    ),
              filled: true,
              fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md, vertical: AppSizes.sm),
              border: border,
              enabledBorder: border,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _SearchMode.values.map((mode) {
                final selected = mode == _mode;
                final label = mode == _SearchMode.id
                    ? 'ID'
                    : mode.name[0].toUpperCase() + mode.name.substring(1);

                return Padding(
                  padding: const EdgeInsets.only(right: AppSizes.sm),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: selected,
                    onSelected: (_) => _onModeChanged(mode),
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: selected
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: selected
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    return Consumer<EmployeeProvider>(
      builder: (context, provider, _) {
        if (_mode == _SearchMode.id) return _buildIdResult(provider);

        if (provider.isLoading) {
          return const LoadingWidget(message: 'Loading employees...');
        }

        if (provider.errorMessage != null && provider.employees.isEmpty) {
          return ErrorWidgetView(
            message: provider.errorMessage!,
            onRetry: provider.fetchEmployees,
          );
        }

        final employees = provider.filteredEmployees;

        return RefreshIndicator(
          onRefresh: provider.refresh,
          color: AppColors.primary,
          child: employees.isEmpty
              ? _ScrollableEmpty(searchActive: provider.query.isNotEmpty)
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: AppSizes.xxl),
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    return CustomCard(
                      employee: employee,
                      onTap: () => _openDetail(employee),
                      onEdit: () => _openForm(employee: employee),
                      onDelete: () => _confirmDelete(employee),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildIdResult(EmployeeProvider provider) {
    if (provider.idSearching) {
      return const LoadingWidget(message: 'Searching...');
    }

    if (provider.idError != null) {
      return ErrorWidgetView(
        message: provider.idError!,
        onRetry: _submitIdSearch,
      );
    }

    final result = provider.idResult;
    if (result == null) {
      return const EmptyWidget(
        message: 'Enter an employee ID to search',
        icon: AppIcons.search,
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: AppSizes.sm, bottom: AppSizes.xxl),
      children: [
        CustomCard(
          employee: result,
          onTap: () => _openDetail(result),
          onEdit: () => _openForm(employee: result),
          onDelete: () => _confirmDelete(result),
        ),
      ],
    );
  }
}

/// Empty state that still scrolls, so pull-to-refresh keeps working.
class _ScrollableEmpty extends StatelessWidget {
  final bool searchActive;
  const _ScrollableEmpty({required this.searchActive});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: EmptyWidget(
            message: searchActive
                ? 'No employees match your search'
                : 'No employees yet',
            icon: searchActive ? AppIcons.search : AppIcons.empty,
          ),
        ),
      ),
    );
  }
}