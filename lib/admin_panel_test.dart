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
    expect(find.byIcon(Icons.logout), findsOneWidget); // Logout button
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

  testWidgets('Logout dialog appears when logout button is tapped', (
    WidgetTester tester,
  ) async {
    // Arrange: Set up the app with UserProvider
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => UserProvider(),
        child: const AdminPanelApp(),
      ),
    );

    // Act: Tap the logout button
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    // Assert: Check if logout dialog is present
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
    expect(find.text('Are you sure you want to logout?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(
      find.text('Logout'),
      findsNWidgets(2),
    ); // One in title, one in button
  });

  testWidgets('Drawer contains only Home button', (WidgetTester tester) async {
    // Arrange: Set up the app with UserProvider
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => UserProvider(),
        child: const AdminPanelApp(),
      ),
    );

    // Act: Open the drawer
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    // Assert: Check if drawer contains only Home button
    expect(find.byType(Drawer), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);

    // Ensure old drawer items are not present
    expect(find.text('Admin Menu'), findsNothing);
    expect(find.text('Dashboard'), findsNothing);
    expect(find.text('Settings'), findsNothing);
  });
}
