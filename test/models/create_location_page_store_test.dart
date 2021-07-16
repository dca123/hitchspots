import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hitchspots/models/create_location_page_store.dart';
import 'package:provider/provider.dart';

void main() {
  test('toggleLocationPicker toggles state', () {
    CreateLocationPageStore store = CreateLocationPageStore();
    expect(store.isLocationPickerOpen, isFalse);

    store.toggleLocationPicker();

    expect(store.isLocationPickerOpen, isTrue);

    store.toggleLocationPicker();

    expect(store.isLocationPickerOpen, isFalse);
  });
  testWidgets(
    "toggleLocationPicker updates consumers",
    (WidgetTester tester) async {
      CreateLocationPageStore store = CreateLocationPageStore();
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => store,
          child: Consumer<CreateLocationPageStore>(
            builder: (context, locationPickerStore, child) {
              return locationPickerStore.isLocationPickerOpen
                  ? Text(
                      "isOpen",
                      textDirection: TextDirection.ltr,
                    )
                  : Text(
                      "isClosed",
                      textDirection: TextDirection.ltr,
                    );
            },
          ),
        ),
      );

      expect(find.text('isClosed'), findsOneWidget);

      store.toggleLocationPicker();

      await tester.pump();

      expect(find.text('isOpen'), findsOneWidget);
    },
  );
  test('setLocation sets location', () {
    CreateLocationPageStore store = CreateLocationPageStore();
    expect(store.selectedLocation, isNull);

    LatLng myLocation = LatLng(10, -10);
    store.setLocation(myLocation);

    expect(store.selectedLocation, equals(myLocation));
  });
  testWidgets(
    "setLocation updates consumers",
    (WidgetTester tester) async {
      CreateLocationPageStore store = CreateLocationPageStore();

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => store,
          child: Consumer<CreateLocationPageStore>(
            builder: (context, locationPickerStore, child) {
              return Text(
                locationPickerStore.selectedLocation.toString(),
                textDirection: TextDirection.ltr,
              );
            },
          ),
        ),
      );

      expect(find.text('null'), findsOneWidget);

      LatLng myLocation = LatLng(10, -10);
      store.setLocation(myLocation);

      await tester.pump();
      expect(find.text(myLocation.toString()), findsOneWidget);
    },
  );

  test('locationData provides no null values', () {
    CreateLocationPageStore store = CreateLocationPageStore();
    Map locationData = store.locationData;

    for (var value in locationData.values) {
      expect(value, isNotNull);
    }
  });

  test('updateLocationName updates LocationName', () {
    {
      CreateLocationPageStore store = CreateLocationPageStore();
      String testText = "TestData";
      store.updateLocationName(testText);
      expect(store.locationData["name"], equals(testText));
    }
  });
  test('updateLocationExperience updates LocationExperience', () {
    {
      CreateLocationPageStore store = CreateLocationPageStore();
      String testText = "TestData";
      store.updateLocationExperience(testText);
      expect(store.locationData["experience"], equals(testText));
    }
  });
  test('updateRating updates Rating', () {
    {
      CreateLocationPageStore store = CreateLocationPageStore();
      double testRating = 3;
      store.updateRating(testRating);
      expect(store.locationData["rating"], equals(testRating));
    }
  });
}
