import 'dart:convert';

import 'package:employee_management_app/data/models/employee_model.dart';
import 'package:employee_management_app/data/repositories/employee_repository_impl.dart';
import 'package:employee_management_app/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Repository backed by a mocked HTTP client, so no request
/// ever leaves the test process.
EmployeeRepositoryImpl repoWith(
  Future<http.Response> Function(http.Request) handler,
) {
  return EmployeeRepositoryImpl(api: ApiClient(client: MockClient(handler)));
}

const _employeeJson = {
  'id': '16',
  'name': 'Kumar',
  'email': 'kumar@gmail.com',
  'mobile': '7755336688',
  'country': 'India',
  'state': 'Telangana',
  'district': 'Hyderabad',
};

void main() {
  group('getEmployees', () {
    test('parses a list of employees', () async {
      final repo = repoWith(
        (_) async => http.Response(jsonEncode([_employeeJson]), 200),
      );

      final result = await repo.getEmployees();

      expect(result, hasLength(1));
      expect(result.first.name, 'Kumar');
      expect(result.first.district, 'Hyderabad');
    });

    test('returns an empty list when the API has no records', () async {
      final repo = repoWith((_) async => http.Response('[]', 200));
      expect(await repo.getEmployees(), isEmpty);
    });

    test('throws ApiException on a server error', () async {
      final repo = repoWith((_) async => http.Response('boom', 500));

      expect(
        () => repo.getEmployees(),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });
  });

  group('getEmployeeById', () {
    test('hits the /:id endpoint and parses one employee', () async {
      late String requestedPath;

      final repo = repoWith((request) async {
        requestedPath = request.url.path;
        return http.Response(jsonEncode(_employeeJson), 200);
      });

      final employee = await repo.getEmployeeById('16');

      expect(requestedPath, endsWith('/employee/16'));
      expect(employee.id, '16');
    });

    test('throws on 404 for an unknown id', () async {
      final repo = repoWith((_) async => http.Response('Not found', 404));

      expect(
        () => repo.getEmployeeById('9999'),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 404),
        ),
      );
    });
  });

  group('createEmployee', () {
    test('POSTs the body and returns the created record', () async {
      late Map<String, dynamic> sentBody;

      final repo = repoWith((request) async {
        sentBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(jsonEncode({..._employeeJson, 'id': '99'}), 201);
      });

      final created = await repo.createEmployee(const Employee(
        id: '',
        name: 'Kumar',
        email: 'kumar@gmail.com',
        mobile: '7755336688',
        country: 'India',
        state: 'Telangana',
        district: 'Hyderabad',
      ));

      expect(sentBody['name'], 'Kumar');
      expect(
        sentBody.containsKey('id'),
        isFalse,
        reason: 'id is assigned by the API, not sent',
      );
      expect(created.id, '99');
    });
  });

  group('updateEmployee', () {
    test('PUTs to the /:id endpoint', () async {
      late String method;
      late String path;

      final repo = repoWith((request) async {
        method = request.method;
        path = request.url.path;
        return http.Response(
          jsonEncode({..._employeeJson, 'name': 'Kumar S'}),
          200,
        );
      });

      final updated = await repo.updateEmployee(
        Employee.fromJson(_employeeJson).copyWith(name: 'Kumar S'),
      );

      expect(method, 'PUT');
      expect(path, endsWith('/employee/16'));
      expect(updated.name, 'Kumar S');
    });
  });

  group('deleteEmployee', () {
    test('sends DELETE to the /:id endpoint', () async {
      late String method;
      late String path;

      final repo = repoWith((request) async {
        method = request.method;
        path = request.url.path;
        return http.Response('', 200);
      });

      await repo.deleteEmployee('16');

      expect(method, 'DELETE');
      expect(path, endsWith('/employee/16'));
    });
  });
}