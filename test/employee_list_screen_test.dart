import 'package:employee_management_app/features/dashboard/employee_list_screen.dart';
import 'package:employee_management_app/providers/employee_provider.dart';
import 'package:employee_management_app/widgets/custom_card.dart';
import 'package:employee_management_app/widgets/empty_widget.dart';
import 'package:employee_management_app/widgets/error_widget.dart';
import 'package:employee_management_app/widgets/loading_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import 'package:employee_management_app/data/models/employee_model.dart';

import 'fakes.dart';

/// Never resolves, so the loading frame stays on screen long
/// enough to assert against.
class HangingRepository extends FakeEmployeeRepository {
  @override
  Future<List<Employee>> getEmployees() => Completer<List<Employee>>().future;
}

Widget wrap(EmployeeProvider provider) {
  return ChangeNotifierProvider.value(
    value: provider,
    child: const MaterialApp(home: EmployeeListScreen()),
  );
}

/// Opens the card's popup menu and taps Delete, leaving the
/// confirmation dialog on screen.
Future<void> openDeleteDialog(WidgetTester tester) async {
  await tester.tap(find.byType(PopupMenuButton<String>).first);
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(PopupMenuItem<String>, 'Delete'));
  await tester.pumpAndSettle();
}

void main() {
    testWidgets('shows a loading indicator while fetching', (tester) async {
    final provider = providerWith(HangingRepository());

    await tester.pumpWidget(wrap(provider));
    await tester.pump(); // run initState's post-frame fetch

    expect(find.byType(LoadingWidget), findsOneWidget);
  });
  
  testWidgets('renders a card per employee once loaded', (tester) async {
    final provider = providerWith(FakeEmployeeRepository(store: seedEmployees));

    await tester.pumpWidget(wrap(provider));
    await tester.pumpAndSettle();

    expect(find.byType(CustomCard), findsNWidgets(2));
    expect(find.text('Kumar'), findsOneWidget);
    expect(find.text('Sakshi'), findsOneWidget);
  });

  testWidgets('shows the empty state when the API returns nothing',
      (tester) async {
    final provider = providerWith(FakeEmployeeRepository(store: const []));

    await tester.pumpWidget(wrap(provider));
    await tester.pumpAndSettle();

    expect(find.byType(EmptyWidget), findsOneWidget);
    expect(find.text('No employees yet'), findsOneWidget);
  });

  testWidgets('shows the error state with a retry action on failure',
      (tester) async {
    final provider = providerWith(FakeEmployeeRepository(shouldFail: true));

    await tester.pumpWidget(wrap(provider));
    await tester.pumpAndSettle();

    expect(find.byType(ErrorWidgetView), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('typing in the search box filters the list', (tester) async {
    final provider = providerWith(FakeEmployeeRepository(store: seedEmployees));

    await tester.pumpWidget(wrap(provider));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Sakshi');
    await tester.pumpAndSettle();

    expect(find.byType(CustomCard), findsOneWidget);
    expect(find.text('Kumar'), findsNothing);
  });

  testWidgets('a non-matching search shows the search empty state',
      (tester) async {
    final provider = providerWith(FakeEmployeeRepository(store: seedEmployees));

    await tester.pumpWidget(wrap(provider));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzzzz');
    await tester.pumpAndSettle();

    expect(find.text('No employees match your search'), findsOneWidget);
  });

  testWidgets('delete asks for confirmation; cancelling keeps the row',
      (tester) async {
    final provider = providerWith(FakeEmployeeRepository(store: seedEmployees));

    await tester.pumpWidget(wrap(provider));
    await tester.pumpAndSettle();

    await openDeleteDialog(tester);

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('Are you sure'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(provider.employees, hasLength(2));
  });

  testWidgets('confirming delete removes the employee', (tester) async {
    final provider = providerWith(FakeEmployeeRepository(store: seedEmployees));

    await tester.pumpWidget(wrap(provider));
    await tester.pumpAndSettle();

    await openDeleteDialog(tester);

    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(provider.employees, hasLength(1));
    expect(provider.employees.single.id, '2');
  });
}