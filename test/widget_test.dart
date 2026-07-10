import 'package:flutter_test/flutter_test.dart';
import 'package:alarmation/main.dart';

void main() {
  testWidgets('Alarmation initial landing screen smoke test',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AlarmationApp());

    // Verify that our custom manifestation tagline is present on screen.
    expect(find.text('Wake Up With Purpose.'), findsOneWidget);
  });
}
