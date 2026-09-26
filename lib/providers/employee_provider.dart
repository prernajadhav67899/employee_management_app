import 'package:employee_management_app/data/repositories/contry_repository.dart';
import 'package:flutter/foundation.dart';

import '../data/models/country_model.dart';
import '../data/models/employee_model.dart';
import '../data/repositories/employee_repository.dart';
import '../services/api_client.dart';

enum FilterField { name, email, mobile, country }

class EmployeeProvider extends ChangeNotifier {
  final EmployeeRepository _repo;
  final CountryRepository _countryRepo;

  EmployeeProvider({
    required EmployeeRepository repository,
    required CountryRepository countryRepository,
  })  : _repo = repository,
        _countryRepo = countryRepository;

  List<Employee> _employees = [];
  List<Country> _countries = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _query = '';
  FilterField _filter = FilterField.name;

  /// Result of a search-by-ID (GET /employee/:id). Null when not searching.
  Employee? _idResult;
  bool _idSearching = false;
  String? _idError;

  List<Employee> get employees => _employees;
  List<Country> get countries => _countries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  FilterField get filter => _filter;
  String get query => _query;
  Employee? get idResult => _idResult;
  bool get idSearching => _idSearching;
  String? get idError => _idError;

  List<Employee> get filteredEmployees {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _employees;

    return _employees.where((e) {
      switch (_filter) {
        case FilterField.name:
          return e.name.toLowerCase().contains(q);
        case FilterField.email:
          return e.email.toLowerCase().contains(q);
        case FilterField.mobile:
          return e.mobile.contains(q);
        case FilterField.country:
          return e.country.toLowerCase().contains(q);
      }
    }).toList();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setFilter(FilterField field) {
    _filter = field;
    notifyListeners();
  }

  Future<void> fetchEmployees() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _employees = await _repo.getEmployees();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Something went wrong.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Pull-to-refresh — no full-screen spinner.
  Future<void> refresh() async {
    try {
      _employees = await _repo.getEmployees();
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    }
    notifyListeners();
  }

  Future<void> fetchCountries() async {
    if (_countries.isNotEmpty) return;
    try {
      _countries = await _countryRepo.getCountries();
      notifyListeners();
    } catch (_) {
      // Non-fatal: the form falls back to a free-text country field.
    }
  }

  Future<void> searchById(String id) async {
    _idSearching = true;
    _idError = null;
    _idResult = null;
    notifyListeners();

    try {
      _idResult = await _repo.getEmployeeById(id.trim());
    } on ApiException catch (e) {
      _idError = e.message;
    } finally {
      _idSearching = false;
      notifyListeners();
    }
  }

  void clearIdSearch() {
    _idResult = null;
    _idError = null;
    notifyListeners();
  }

  /// Returns null on success, or an error message on failure.
  Future<String?> createEmployee(Employee e) async {
    try {
      final created = await _repo.createEmployee(e);
      _employees = [created, ..._employees];
      notifyListeners();
      return null;
    } on ApiException catch (err) {
      return err.message;
    }
  }

  Future<String?> updateEmployee(Employee e) async {
    try {
      final updated = await _repo.updateEmployee(e);
      final i = _employees.indexWhere((x) => x.id == updated.id);
      if (i != -1) _employees[i] = updated;
      notifyListeners();
      return null;
    } on ApiException catch (err) {
      return err.message;
    }
  }

  Future<String?> deleteEmployee(String id) async {
    try {
      await _repo.deleteEmployee(id);
      _employees.removeWhere((e) => e.id == id);
      notifyListeners();
      return null;
    } on ApiException catch (err) {
      return err.message;
    }
  }
}