class ApiConstants {
  ApiConstants._();

  static const String baseUrl =
      'https://669b3f09276e45187d34eb4e.mockapi.io/api/v1';

  static const String employees = '/employee';
  static const String countries = '/country';

  static const Duration timeout = Duration(seconds: 15);

  static String employeeById(String id) => '$employees/$id';
}