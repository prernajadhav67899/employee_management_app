import 'package:employee_management_app/data/models/employee_model.dart';
import 'package:employee_management_app/providers/employee_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  group('fetchEmployees', () {
    test('populates the list and clears loading', () async {
      final provider =
          providerWith(FakeEmployeeRepository(store: seedEmployees));

      await provider.fetchEmployees();

      expect(provider.employees, hasLength(2));
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('surfaces an error message when the repository throws', () async {
      final provider = providerWith(FakeEmployeeRepository(shouldFail: true));

      await provider.fetchEmployees();

      expect(provider.employees, isEmpty);
      expect(provider.errorMessage, 'Network unavailable.');
      expect(provider.isLoading, isFalse);
    });

    test('notifies listeners', () async {
      final provider =
          providerWith(FakeEmployeeRepository(store: seedEmployees));
      var notifications = 0;
      provider.addListener(() => notifications++);

      await provider.fetchEmployees();

      expect(notifications, greaterThan(0));
    });
  });

  group('filtering', () {
    late EmployeeProvider provider;

    setUp(() async {
      provider = providerWith(FakeEmployeeRepository(store: seedEmployees));
      await provider.fetchEmployees();
    });

    test('returns everything when the query is empty', () {
      expect(provider.filteredEmployees, hasLength(2));
    });

    test('filters by name, case-insensitively', () {
      provider.setFilter(FilterField.name);
      provider.setQuery('kum');
      expect(provider.filteredEmployees.single.name, 'Kumar');
    });

    test('filters by email', () {
      provider.setFilter(FilterField.email);
      provider.setQuery('yahoo');
      expect(provider.filteredEmployees.single.name, 'Sakshi');
    });

    test('filters by mobile', () {
      provider.setFilter(FilterField.mobile);
      provider.setQuery('7755');
      expect(provider.filteredEmployees.single.id, '1');
    });

    test('filters by country', () {
      provider.setFilter(FilterField.country);
      provider.setQuery('kuwait');
      expect(provider.filteredEmployees.single.name, 'Sakshi');
    });

    test('returns empty for a query that matches nothing', () {
      provider.setQuery('zzzzz');
      expect(provider.filteredEmployees, isEmpty);
    });
  });

  group('searchById', () {
    test('sets idResult for a known id', () async {
      final provider =
          providerWith(FakeEmployeeRepository(store: seedEmployees));

      await provider.searchById('2');

      expect(provider.idResult?.name, 'Sakshi');
      expect(provider.idError, isNull);
      expect(provider.idSearching, isFalse);
    });

    test('sets idError for an unknown id', () async {
      final provider =
          providerWith(FakeEmployeeRepository(store: seedEmployees));

      await provider.searchById('9999');

      expect(provider.idResult, isNull);
      expect(provider.idError, 'Employee not found.');
    });

    test('clearIdSearch resets both result and error', () async {
      final provider =
          providerWith(FakeEmployeeRepository(store: seedEmployees));
      await provider.searchById('1');

      provider.clearIdSearch();

      expect(provider.idResult, isNull);
      expect(provider.idError, isNull);
    });
  });

  group('CRUD updates local state', () {
    test('createEmployee prepends the new record', () async {
      final provider =
          providerWith(FakeEmployeeRepository(store: seedEmployees));
      await provider.fetchEmployees();

      final error = await provider.createEmployee(const Employee(
        id: '',
        name: 'Tejas',
        email: 'tejas@gmail.com',
        mobile: '8998989090',
        country: 'India',
        state: 'Maharashtra',
        district: 'Nashik',
      ));

      expect(error, isNull);
      expect(provider.employees, hasLength(3));
      expect(provider.employees.first.name, 'Tejas');
    });

    test('updateEmployee replaces the matching record in place', () async {
      final provider =
          providerWith(FakeEmployeeRepository(store: seedEmployees));
      await provider.fetchEmployees();

      final error = await provider.updateEmployee(
        seedEmployees.first.copyWith(name: 'Kumar S'),
      );

      expect(error, isNull);
      expect(provider.employees.first.name, 'Kumar S');
      expect(provider.employees, hasLength(2));
    });

    test('deleteEmployee removes the record', () async {
      final provider =
          providerWith(FakeEmployeeRepository(store: seedEmployees));
      await provider.fetchEmployees();

      final error = await provider.deleteEmployee('1');

      expect(error, isNull);
      expect(provider.employees, hasLength(1));
      expect(provider.employees.single.id, '2');
    });

    test('returns the error and leaves state intact on failure', () async {
      final repo = FakeEmployeeRepository(store: seedEmployees);
      final provider = providerWith(repo);
      await provider.fetchEmployees();

      repo.shouldFail = true;
      final error = await provider.deleteEmployee('1');

      expect(error, 'Network unavailable.');
      expect(provider.employees, hasLength(2));
    });
  });

  group('fetchCountries', () {
    test('loads countries for the form dropdown', () async {
      final provider = providerWith(FakeEmployeeRepository());

      await provider.fetchCountries();

      expect(provider.countries, hasLength(2));
      expect(provider.countries.first.name, 'India');
    });
  });
}