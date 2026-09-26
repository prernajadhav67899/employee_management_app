import '../models/employee_model.dart';

abstract class EmployeeRepository {
  Future<List<Employee>> getEmployees();
  Future<Employee> getEmployeeById(String id);
  Future<Employee> createEmployee(Employee employee);
  Future<Employee> updateEmployee(Employee employee);
  Future<void> deleteEmployee(String id);
}