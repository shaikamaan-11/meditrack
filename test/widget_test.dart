// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:meditrack/main.dart';
import 'package:meditrack/providers/auth_provider.dart';

void main() {
  testWidgets('MedTrack app loads login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MedTrackApp());

    expect(find.text('MedTrack'), findsOneWidget);
    expect(find.text('Medical Records Manager'), findsOneWidget);
  });

  test('demo sign up works without Firebase configuration', () async {
    final auth = AppAuthProvider();

    await auth.signUp(
      name: 'Test User',
      email: 'test@example.com',
      password: 'Password123!',
      role: 'Patient',
    );

    expect(auth.errorMessage, isNull);
    expect(auth.appUser, isNotNull);
    expect(auth.appUser!.email, 'test@example.com');
    expect(auth.appUser!.role, 'Patient');
  });
}
