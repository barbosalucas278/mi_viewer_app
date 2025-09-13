import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_viewer_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final List<MethodCall> log = <MethodCall>[];

  channel.setMockMethodCallHandler((MethodCall methodCall) async {
    log.add(methodCall);
    if (methodCall.method == 'read') {
      return 'dummy_token';
    }
    return null;
  });

  testWidgets('Logout test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for the FutureBuilder to complete
    await tester.pumpAndSettle();

    // Verify that the home page is shown
    expect(find.text('Home page'), findsOneWidget);

    // Tap the logout button
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    // Verify that the login page is shown
    expect(find.text('Login con Auth0'), findsOneWidget);
  });
}
