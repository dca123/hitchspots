import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hitchspots/models/location_card.dart';
import 'package:hitchspots/pages/create_review_page.dart';
import 'package:hitchspots/services/authentication.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import '../services/firebase_app_mock.dart';

Widget applicationWrapper({
  required Widget child,
  LocationCardModel? locationCardModel,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => locationCardModel ?? LocationCardModel(),
      ),
      ChangeNotifierProvider(
        create: (context) => AuthenticationState(displayName: "TestUser"),
      ),
    ],
    child: MaterialApp(
      home: child,
    ),
  );
}

main() {
  group("Shows Errors when data is invalid", () {
    testWidgets(
      "Shows error for empty text",
      (WidgetTester tester) async {
        await tester.pumpWidget(
          applicationWrapper(
            child: CreateReviewPage(),
          ),
        );

        expect(find.byType(CreateReviewPage), findsOneWidget);

        await tester.flingFrom(
          tester.getCenter(find.byType(RatingBar)),
          Offset(60, 0),
          30,
        );
        await tester.tap(find.byIcon(Icons.send));
        await tester.pump();
        expect(
          find.text("Please enter a short description of your experience"),
          findsOneWidget,
        );
      },
    );
  });
  group("When data is valid", () {
    setupFirebaseAuthMocks();

    setUpAll(() async {
      await Firebase.initializeApp();
    });

    testWidgets(
      "Adds Review, Updates Location rating, Updates LocationCardModel review values",
      (WidgetTester tester) async {
        final instance = FakeFirebaseFirestore();
        LocationCardModel locationCardModel =
            LocationCardModel(firestoreInstance: instance);
        await instance.collection('locations').doc("testLocationID").set({
          'reviewCount': 1,
          'rating': 5,
        });

        await tester.pumpWidget(
          applicationWrapper(
            child: CreateReviewPage(
              fakeFirestore: instance,
            ),
            locationCardModel: locationCardModel,
          ),
        );

        expect(find.byType(CreateReviewPage), findsOneWidget);
        await tester.flingFrom(
            tester.getCenter(find.byType(RatingBar)), Offset(60, 0), 30);
        await tester.enterText(find.byType(TextFormField), "test");
        await tester.tap(find.byIcon(Icons.send));
        await tester.pump();

        final reviewsSnapshot = await instance.collection('reviews').get();
        final locationsSnapshot = await instance.collection('locations').get();

        // Ensures that review data is added
        expect(reviewsSnapshot.docs.first.get('description'), equals("test"));
        expect(reviewsSnapshot.docs.first.get('rating'), equals(4));

        //Ensures that location rating is updated
        expect(locationsSnapshot.docs.first.get('rating'), equals((5 + 4) / 2));
        expect(locationCardModel.reviews.length, equals(1));
      },
    );
  });
}
