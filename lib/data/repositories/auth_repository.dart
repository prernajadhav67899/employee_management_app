import 'package:employee_management_app/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';


abstract class AuthRepository {
  User? get currentUser;
  Stream<User?> get authStateChanges;
  Future<User> signIn(String email, String password);
  Future<User> register(String name, String email, String password);
  Future<User> signInWithGoogle();
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _service;

  AuthRepositoryImpl({required AuthService service}) : _service = service;

  @override
  User? get currentUser => _service.currentUser;

  @override
  Stream<User?> get authStateChanges => _service.authStateChanges;

  @override
  Future<User> signIn(String email, String password) =>
      _service.signIn(email, password);

  @override
  Future<User> register(String name, String email, String password) =>
      _service.register(name, email, password);

  @override
  Future<User> signInWithGoogle() => _service.signInWithGoogle();

  @override
  Future<void> sendPasswordReset(String email) =>
      _service.sendPasswordReset(email);

  @override
  Future<void> signOut() => _service.signOut();
}