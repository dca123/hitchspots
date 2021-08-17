import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hitchspots/models/create_location_page_store.dart';
import 'package:hitchspots/pages/create_location_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import '../services/firebase_app_mock.dart';
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
      expect(find.byType(CreateLocationPage), findsOneWidget);

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
  group("When data is valid", () {
    setupFirebaseAuthMocks();

    setUpAll(() async {
      await Firebase.initializeApp();
    });

    testWidgets(
      "Adds Location, Adds Review",
      (WidgetTester tester) async {
        final instance = FakeFirebaseFirestore();
        final CreateLocationPageStore locationPageStore =
            CreateLocationPageStore();
        locationPageStore.setLocation(LatLng(0, 0));

        await tester.pumpWidget(
          applicationWrapper(
            child: ChangeNotifierProvider(
              create: (context) => locationPageStore,
              child: CreateLocationPage(
                centerLatLng: LatLng(0, 0),
                closedContainer: () => {},
                fakeFirestore: instance,
              ),
            ),
          ),
        );

        expect(find.byType(CreateLocationPage), findsOneWidget);
        await tester.flingFrom(
            tester.getCenter(find.byType(RatingBar)), Offset(60, 0), 30);
        await tester.enterText(
            find.byKey(ValueKey("locationName")), "testLocationName");
        await tester.enterText(
            find.byKey(ValueKey("locationDescription")), "testDescription");

        await tester.tap(find.byIcon(Icons.send));
        await tester.pump();

        final locationSnapshot =
            (await instance.collection('locations').get()).docs.first;
        final reviewSnapshot =
            (await instance.collection('reviews').get()).docs.first;

        expect(locationSnapshot.get('name'), "testLocationName");
        expect(locationSnapshot.get('rating'), 4);
        expect(locationSnapshot.get('reviewCount'), 1);
        expect(locationSnapshot.get('hasImages'), false);
        expect(locationSnapshot.get('createdBy'), "TestUser123");

        expect(reviewSnapshot.get('description'), "testDescription");
        expect(reviewSnapshot.get('locationID'), locationSnapshot.id);
        expect(reviewSnapshot.get('rating'), 4);
        expect(reviewSnapshot.get('createdByDisplayName'), "TestUser");
      },
    );
  });
}
