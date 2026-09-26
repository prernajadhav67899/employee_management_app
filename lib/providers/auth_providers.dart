import 'package:employee_management_app/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo;

  AuthProvider({required AuthRepository repository}) : _repo = repository {
    _user = _repo.currentUser;
    _repo.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  String get displayName => _user?.displayName ?? 'User';
  String get email => _user?.email ?? '';
  String get photoUrl => _user?.photoURL ?? '';

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Returns null on success, or an error message on failure.
  Future<String?> login(String email, String password) async {
    _setLoading(true);
    try {
      _user = await _repo.signIn(email, password);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> register(String name, String email, String password) async {
    _setLoading(true);
    try {
      _user = await _repo.register(name, email, password);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> signInWithGoogle() async {
    _setLoading(true);
    try {
      _user = await _repo.signInWithGoogle();
      return null;
    } on AuthException catch (e) {
      return e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> sendPasswordReset(String email) async {
    _setLoading(true);
    try {
      await _repo.sendPasswordReset(email);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _repo.signOut();
    _user = null;
    notifyListeners();
  }
}