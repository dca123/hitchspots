import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hitchspots/models/create_location_page_store.dart';
import 'package:hitchspots/pages/create_location_page.dart';
import 'package:provider/provider.dart';

import '../utils.dart';

void main() {
  testWidgets(
    "Shows error messages when not filled out",
    (WidgetTester tester) async {
      await tester.pumpWidget(
        applicationWrapper(
          child: ChangeNotifierProvider(
            create: (context) => CreateLocationPageStore(),
            child: CreateLocationPage(
                centerLatLng: LatLng(0, 0), closedContainer: () => {}),
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();
      expect(find.text("Please select a location"), findsOneWidget);
      expect(find.text("Please select a rating"), findsOneWidget);
      expect(
          find.text("Please enter a name for this location"), findsOneWidget);
      expect(find.text("Please enter a short description of your experience"),
          findsOneWidget);
    },
  );
}
