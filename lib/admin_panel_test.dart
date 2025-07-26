import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'dashboard.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() {
  testWidgets('AdminPanelApp renders DashboardScreen correctly', (
    WidgetTester tester,
  ) async {
    // Arrange: Set up the app with UserProvider
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => UserProvider(),
        child: const AdminPanelApp(),
      ),
    );

    // Act: Trigger a frame
    await tester.pump();

    // Assert: Check if key UI elements are present
    expect(find.text('Admin Dashboard'), findsOneWidget); // AppBar title
    expect(find.byType(AppBar), findsOneWidget); // AppBar
    expect(find.byType(UserListView), findsOneWidget); // User list
    expect(find.byIcon(Icons.search), findsOneWidget); // Search button
    expect(find.byIcon(Icons.filter_list), findsOneWidget); // Filter button
  });

  testWidgets('UserListView shows loading indicator when empty', (
    WidgetTester tester,
  ) async {
    // Arrange: Set up the app with UserProvider
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => UserProvider(),
        child: const AdminPanelApp(),
      ),
    );

    // Act: Trigger a frame
    await tester.pump();

    // Assert: Check if loading indicator is shown when users list is empty
    expect(find.byType(SpinKitCircle), findsOneWidget); // Loading indicator
  });

  testWidgets('Filter dialog is compact and functional', (
    WidgetTester tester,
  ) async {
    // Arrange: Set up the app with UserProvider
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => UserProvider(),
        child: const AdminPanelApp(),
      ),
    );

    // Act: Open the filter dialog
    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();

    // Assert: Check if dialog is present and compact
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Filter Users'), findsOneWidget);
    expect(find.byType(DropdownButton<String>), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Measure dialog size (approximate check for compactness)
    final dialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
    final contentPadding = dialog.contentPadding as EdgeInsets;
    expect(contentPadding.top, lessThanOrEqualTo(8)); // Compact top padding
    expect(
      contentPadding.bottom,
      lessThanOrEqualTo(8),
    ); // Compact bottom padding
  });
}
