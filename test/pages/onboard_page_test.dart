import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hitchspots/pages/onboard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });
  testWidgets(
    "Onboard page sets isFirstRun to false",
    (WidgetTester tester) async {
      final SharedPreferences instance = await SharedPreferences.getInstance();
      expect(instance.getBool('isFirstRun'), isNull);

      await tester.pumpWidget(applicationWrapper(
          child: OnboardingPage(
        pageOnFinish: Text("test"),
      )));

      await tester.tap(find.byIcon(Icons.navigate_next));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.navigate_next));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.navigate_next));
      await tester.pumpAndSettle();

      expect(find.text("Get Started"), findsOneWidget);

      await tester.tap(find.text("Get Started"));
      await tester.pumpAndSettle();

      expect(instance.getBool('isFirstRun'), isFalse);
      expect(find.text("test"), findsOneWidget);
    },
  );
}
