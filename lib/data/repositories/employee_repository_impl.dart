import 'package:employee_management_app/constants/api_constant.dart';
import 'package:employee_management_app/services/api_client.dart';
import '../models/employee_model.dart';
import 'employee_repository.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final ApiClient _api;
  EmployeeRepositoryImpl({required ApiClient api}) : _api = api;

  @override
  Future<List<Employee>> getEmployees() async {
    final data = await _api.get(ApiConstants.employees);
    if (data is! List) throw const ApiException('Unexpected list format.');
    return data.whereType<Map<String, dynamic>>().map(Employee.fromJson).toList();
  }

  @override
  Future<Employee> getEmployeeById(String id) async {
    final data = await _api.get(ApiConstants.employeeById(id));
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Employee not found.', statusCode: 404);
    }
    return Employee.fromJson(data);
  }

  @override
  Future<Employee> createEmployee(Employee e) async {
    final data = await _api.post(ApiConstants.employees, e.toJson());
    return Employee.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<Employee> updateEmployee(Employee e) async {
    final data = await _api.put(ApiConstants.employeeById(e.id), e.toJson());
    return Employee.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteEmployee(String id) =>
      _api.delete(ApiConstants.employeeById(id));
}