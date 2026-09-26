import 'package:employee_management_app/providers/auth_providers.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  group('login', () {
    test('returns null and sets the user on success', () async {
      final provider = AuthProvider(repository: FakeAuthRepository());

      final error = await provider.login('jane@example.com', 'secret123');

      expect(error, isNull);
      expect(provider.isAuthenticated, isTrue);
      expect(provider.email, 'jane@example.com');
      expect(provider.isLoading, isFalse);
    });

    test('returns the message and stays unauthenticated on failure', () async {
      final provider = AuthProvider(
        repository: FakeAuthRepository(shouldFail: true),
      );

      final error = await provider.login('jane@example.com', 'wrong');

      expect(error, 'Incorrect email or password.');
      expect(provider.isAuthenticated, isFalse);
      expect(provider.isLoading, isFalse);
    });
  });

  group('register', () {
    test('stores the supplied display name', () async {
      final provider = AuthProvider(repository: FakeAuthRepository());

      final error = await provider.register(
        'Prerna',
        'prerna@example.com',
        'secret123',
      );

      expect(error, isNull);
      expect(provider.displayName, 'Prerna');
    });

    test('surfaces a duplicate-email failure', () async {
      final provider = AuthProvider(
        repository: FakeAuthRepository(
          shouldFail: true,
          failureMessage: 'An account already exists with this email.',
        ),
      );

      final error = await provider.register(
        'Prerna',
        'taken@example.com',
        'secret123',
      );

      expect(error, 'An account already exists with this email.');
    });
  });

  group('signInWithGoogle', () {
    test('populates name, email and photo', () async {
      final provider = AuthProvider(repository: FakeAuthRepository());

      final error = await provider.signInWithGoogle();

      expect(error, isNull);
      expect(provider.displayName, 'Google User');
      expect(provider.photoUrl, isNotEmpty);
    });

    test('returns the message when the user cancels', () async {
      final provider = AuthProvider(
        repository: FakeAuthRepository(
          shouldFail: true,
          failureMessage: 'Sign-in cancelled.',
        ),
      );

      expect(await provider.signInWithGoogle(), 'Sign-in cancelled.');
      expect(provider.isAuthenticated, isFalse);
    });
  });

  group('sendPasswordReset', () {
    test('returns null on success', () async {
      final provider = AuthProvider(repository: FakeAuthRepository());
      expect(await provider.sendPasswordReset('jane@example.com'), isNull);
    });
  });

  group('logout', () {
    test('clears the user', () async {
      final provider = AuthProvider(repository: FakeAuthRepository());
      await provider.login('jane@example.com', 'secret123');

      await provider.logout();

      expect(provider.isAuthenticated, isFalse);
      expect(provider.displayName, 'User');
    });
  });

  test('exposes fallbacks when no user is signed in', () {
    final provider = AuthProvider(repository: FakeAuthRepository());

    expect(provider.user, isNull);
    expect(provider.displayName, 'User');
    expect(provider.email, isEmpty);
    expect(provider.photoUrl, isEmpty);
  });
}