// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verifyz that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hitchspots/widgets/fabs/my_location_fab.dart';

void main() {
  group('Icon depends on findingLocation', () {
    testWidgets(
      "gps_not_fixed icon when finding location is true",
      (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(
          home: MyLocationFAB(
            getLocation: () {},
            findingLocation: true,
          ),
        ));

        expect(find.byIcon(Icons.gps_not_fixed), findsOneWidget);
      },
    );
    testWidgets(
      "gps_fixed icon when finding location is false",
      (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(
          home: MyLocationFAB(
            getLocation: () {},
            findingLocation: false,
          ),
        ));

        expect(find.byIcon(Icons.gps_fixed), findsOneWidget);
      },
    );
  });
}
