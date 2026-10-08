import 'package:flutter_test/flutter_test.dart';
import 'package:svpuat/main.dart';

void main() {
  testWidgets('College study app loads test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CollegeStudyApp());

    // Advance fake async timers for splash screen redirect
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify app loaded successfully
    expect(find.byType(CollegeStudyApp), findsOneWidget);
  });
}
