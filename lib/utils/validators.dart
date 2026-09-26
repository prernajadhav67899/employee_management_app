/// Shared form validators. The auth and employee-form screens
/// currently have their own inline copies of these — safe to swap
/// those for calls into this file when you get a spare moment,
/// but not required for the app to run.
class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
        final regex = RegExp(r'^[\w.+-]+@([\w-]+\.)+[\w-]{2,}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  static String? mobile(String? value) {
    if (value == null || value.trim().isEmpty) return 'Mobile number is required';
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 7) return 'Enter a valid mobile number';
    return null;
  }
}