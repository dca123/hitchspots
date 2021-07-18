import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hitchspots/pages/onboard_page.dart';
import 'package:hitchspots/pages/splash_screen_page.dart';
import 'package:hitchspots/utils/first_run_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget applicationWrapper({
  required Widget child,
}) {
  return MaterialApp(
    home: child,
  );
}

void main() {
  // Shows splashscreen by default
  testWidgets(
    "Shows splash screen by default",
    (WidgetTester tester) async {
      await tester.pumpWidget(
        applicationWrapper(
          child: FirstRunWrapper(
            homePage: Container(
              child: Text("test"),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(SplashScreen), findsOneWidget);
    },
  );
  testWidgets(
    "Shows onboarding page if first run",
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        "isFirstRun": true,
      });
      await tester.pumpWidget(
        applicationWrapper(
          child: FirstRunWrapper(
            homePage: Container(
              child: Text("test"),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(OnboardingPage), findsOneWidget);
    },
  );
  testWidgets(
    "Shows child widget if not first run",
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        "isFirstRun": false,
      });
      await tester.pumpWidget(
        applicationWrapper(
          child: FirstRunWrapper(
            homePage: Container(
              child: Text("test"),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text("test"), findsOneWidget);
    },
  );
}
