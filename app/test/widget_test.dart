// Basic smoke test for FakeNews Killer app.

import 'package:flutter_test/flutter_test.dart';
import 'package:fakenews_killer_app/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FakeNewsKillerApp());

    // Verify splash screen appears
    expect(find.text('FakeNews Killer'), findsOneWidget);
  });
}
