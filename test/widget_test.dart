import 'package:flutter_test/flutter_test.dart';

import 'package:alu_academic_assistant/main.dart';

void main() {
  testWidgets('App builds and shows onboarding or main', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AluAcademicAssistant(isLoggedIn: false));

    // Initially should show onboarding since isLoggedIn is false.
    expect(find.textContaining('Welcome'), findsOneWidget);
  });
}
