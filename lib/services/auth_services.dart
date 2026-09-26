import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Wraps FirebaseAuth + Google Sign-In. Throws [AuthException]
/// with human-readable messages so the UI never sees a raw
/// FirebaseAuthException code.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  static bool _googleReady = false;

  /// google_sign_in v7 requires initialize() exactly once before use.
  static Future<void> initGoogle() async {
    if (_googleReady) return;
    await GoogleSignIn.instance.initialize();
    _googleReady = true;
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return cred.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e));
    }
  }

  Future<User> register(String name, String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user!.updateDisplayName(name.trim());
      await cred.user!.reload();
      return _auth.currentUser!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e));
    }
  }

  /// google_sign_in v7: authenticate() replaces signIn(), and
  /// `authentication` is a synchronous getter.
  Future<User> signInWithGoogle() async {
    try {
      await initGoogle();

      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final cred = await _auth.signInWithCredential(credential);
      return cred.user!;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthException('Sign-in cancelled.');
      }
      throw AuthException(e.description ?? 'Google sign-in failed.');
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e));
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }

  String _message(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}