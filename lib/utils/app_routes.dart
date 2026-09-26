/// Named route constants for static (argument-less) screens.
/// EmployeeDetailScreen and EmployeeFormScreen are pushed directly
/// with MaterialPageRoute instead, since they need to carry an
/// Employee argument that a named-route table can't type-check.
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
}