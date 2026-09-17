import 'package:flutter_test/flutter_test.dart';
import 'package:tvk_application/main.dart';

void main() {
  testWidgets('Splash screen loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TVKGrievanceApp());
    expect(find.text('TVK'), findsOneWidget);
  });
}
