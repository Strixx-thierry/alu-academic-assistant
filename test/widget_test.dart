import 'package:flutter_test/flutter_test.dart';

import 'package:alu_academic_assistant/main.dart';

void main() {
  testWidgets('App builds and shows dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const AluAcademicAssistant());

    // Initial placeholder content in DashboardScreen.
    expect(find.text('Dashboard Screen'), findsOneWidget);
  });
}
