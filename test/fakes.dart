import 'package:employee_management_app/data/models/country_model.dart';
import 'package:employee_management_app/data/models/employee_model.dart';
import 'package:employee_management_app/data/repositories/auth_repository.dart';
import 'package:employee_management_app/data/repositories/contry_repository.dart';
import 'package:employee_management_app/data/repositories/employee_repository.dart';
import 'package:employee_management_app/providers/employee_provider.dart';
import 'package:employee_management_app/services/api_client.dart';
import 'package:employee_management_app/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Shared test data.
const seedEmployees = [
  Employee(
    id: '1',
    name: 'Kumar',
    email: 'kumar@gmail.com',
    mobile: '7755336688',
    country: 'India',
    state: 'Telangana',
    district: 'Hyderabad',
  ),
  Employee(
    id: '2',
    name: 'Sakshi',
    email: 'sakshi@yahoo.com',
    mobile: '8989989999',
    country: 'Kuwait',
    state: 'Maharashtra',
    district: 'Pune',
  ),
];

/// In-memory stand-in for the real repository. No network involved.
class FakeEmployeeRepository implements EmployeeRepository {
  List<Employee> store;
  bool shouldFail;

  FakeEmployeeRepository({List<Employee>? store, this.shouldFail = false})
      : store = [...?store];

  void _maybeFail() {
    if (shouldFail) throw const ApiException('Network unavailable.');
  }

  @override
  Future<List<Employee>> getEmployees() async {
    _maybeFail();
    return [...store];
  }

  @override
  Future<Employee> getEmployeeById(String id) async {
    _maybeFail();
    final match = store.where((e) => e.id == id);
    if (match.isEmpty) {
      throw const ApiException('Employee not found.', statusCode: 404);
    }
    return match.first;
  }

  @override
  Future<Employee> createEmployee(Employee employee) async {
    _maybeFail();
    final created = Employee(
      id: '99',
      name: employee.name,
      email: employee.email,
      mobile: employee.mobile,
      country: employee.country,
      state: employee.state,
      district: employee.district,
    );
    store.add(created);
    return created;
  }

  @override
  Future<Employee> updateEmployee(Employee employee) async {
    _maybeFail();
    return employee;
  }

  @override
  Future<void> deleteEmployee(String id) async {
    _maybeFail();
    store.removeWhere((e) => e.id == id);
  }
}

class FakeCountryRepository implements CountryRepository {
  @override
  Future<List<Country>> getCountries() async => const [
        Country(id: '32', name: 'India'),
        Country(id: '44', name: 'Kuwait'),
      ];
}

EmployeeProvider providerWith(FakeEmployeeRepository repo) => EmployeeProvider(
      repository: repo,
      countryRepository: FakeCountryRepository(),
    );

/// Minimal Firebase User. noSuchMethod absorbs the members
/// the tests never touch.
class FakeUser implements User {
  @override
  final String? displayName;
  @override
  final String? email;
  @override
  final String? photoURL;

  FakeUser({this.displayName, this.email, this.photoURL});

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeAuthRepository implements AuthRepository {
  User? _current;
  bool shouldFail;
  String failureMessage;

  FakeAuthRepository({
    User? initialUser,
    this.shouldFail = false,
    this.failureMessage = 'Incorrect email or password.',
  }) : _current = initialUser;

  @override
  User? get currentUser => _current;

  @override
  Stream<User?> get authStateChanges => const Stream<User?>.empty();

  void _maybeFail() {
    if (shouldFail) throw AuthException(failureMessage);
  }

  @override
  Future<User> signIn(String email, String password) async {
    _maybeFail();
    return _current = FakeUser(email: email, displayName: 'Test User');
  }

  @override
  Future<User> register(String name, String email, String password) async {
    _maybeFail();
    return _current = FakeUser(email: email, displayName: name);
  }

  @override
  Future<User> signInWithGoogle() async {
    _maybeFail();
    return _current = FakeUser(
      email: 'google@gmail.com',
      displayName: 'Google User',
      photoURL: 'https://example.com/photo.png',
    );
  }

  @override
  Future<void> sendPasswordReset(String email) async => _maybeFail();

  @override
  Future<void> signOut() async => _current = null;
}