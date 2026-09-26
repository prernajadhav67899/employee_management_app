import 'package:employee_management_app/constants/app_textStyles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_icons.dart';
import '../../constants/app_sizes.dart';
import '../../data/models/employee_model.dart';
import '../../providers/employee_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfields.dart';

/// Add / Edit employee form. In edit mode the fields are
/// pre-populated from [editEmployee] and the save call routes to
/// PUT instead of POST.
class EmployeeFormScreen extends StatefulWidget {
  final Employee? editEmployee;

  const EmployeeFormScreen({super.key, this.editEmployee});

  bool get isEditMode => editEmployee != null;

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _mobileController;
  late final TextEditingController _stateController;
  late final TextEditingController _districtController;

  String? _selectedCountry;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    final e = widget.editEmployee;
    _nameController = TextEditingController(text: e?.name ?? '');
    _emailController = TextEditingController(text: e?.email ?? '');
    _mobileController = TextEditingController(text: e?.mobile ?? '');
    _stateController = TextEditingController(text: e?.state ?? '');
    _districtController = TextEditingController(text: e?.district ?? '');
    _selectedCountry =
        (e?.country.isNotEmpty ?? false) ? e!.country : null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().fetchCountries();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final provider = context.read<EmployeeProvider>();

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final employee = Employee(
      id: widget.editEmployee?.id ?? '',
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      mobile: _mobileController.text.trim(),
      country: _selectedCountry ?? '',
      state: _stateController.text.trim(),
      district: _districtController.text.trim(),
      avatar: widget.editEmployee?.avatar ?? '',
    );

    final error = widget.isEditMode
        ? await provider.updateEmployee(employee)
        : await provider.createEmployee(employee);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error != null) {
      setState(() => _errorMessage = error);
      return;
    }

    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          widget.isEditMode ? 'Employee updated' : 'Employee added',
        ),
        backgroundColor: AppColors.success,
      ),
    );
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
        title: Text(widget.isEditMode ? 'Edit Employee' : 'Add Employee'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 520 : double.infinity,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSizes.sm),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusSm),
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
                      controller: _nameController,
                      label: 'Full Name',
                      prefixIcon: AppIcons.person,
                      validator: (v) => Validators.required(v, 'Name'),
                    ),
                    const SizedBox(height: AppSizes.md),
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      prefixIcon: AppIcons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: AppSizes.md),
                    CustomTextField(
                      controller: _mobileController,
                      label: 'Mobile',
                      prefixIcon: AppIcons.phone,
                      keyboardType: TextInputType.phone,
                      validator: Validators.mobile,
                    ),
                    const SizedBox(height: AppSizes.md),
                    _buildCountryDropdown(isDark),
                    const SizedBox(height: AppSizes.md),
                    CustomTextField(
                      controller: _stateController,
                      label: 'State',
                      prefixIcon: AppIcons.location,
                      validator: (v) => Validators.required(v, 'State'),
                    ),
                    const SizedBox(height: AppSizes.md),
                    CustomTextField(
                      controller: _districtController,
                      label: 'District',
                      prefixIcon: AppIcons.location,
                      validator: (v) => Validators.required(v, 'District'),
                    ),
                    const SizedBox(height: AppSizes.xl),
                    CustomButton(
                      label: widget.isEditMode
                          ? 'Save Changes'
                          : 'Add Employee',
                      onPressed: _handleSave,
                      isLoading: _isSaving,
                    ),
                    const SizedBox(height: AppSizes.md),
                    CustomButton(
                      label: 'Cancel',
                      isOutlined: true,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Country list comes from GET /country. The currently selected
  /// value is folded into the item list so edit mode never crashes
  /// on a country the API didn't return.
  Widget _buildCountryDropdown(bool isDark) {
    return Consumer<EmployeeProvider>(
      builder: (context, provider, _) {
        final names = <String>{
          ...provider.countries
              .map((c) => c.name)
              .where((n) => n.isNotEmpty),
          if (_selectedCountry != null && _selectedCountry!.isNotEmpty)
            _selectedCountry!,
        }.toList();

        return DropdownButtonFormField<String>(
          initialValue: _selectedCountry,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Country',
            prefixIcon:
                const Icon(AppIcons.location, size: AppSizes.iconSm),
            filled: true,
            fillColor:
                isDark ? AppColors.darkSurface : AppColors.lightSurface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.md,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: BorderSide(
                color:
                    isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
          ),
          items: names
              .map((n) => DropdownMenuItem(value: n, child: Text(n)))
              .toList(),
          onChanged: (value) => setState(() => _selectedCountry = value),
          validator: (value) =>
              value == null ? 'Please select a country' : null,
        );
      },
    );
  }
}