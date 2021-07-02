import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hitchspots/models/location_picker_store.dart';
import 'package:provider/provider.dart';

void main() {
  test('toggleLocationPicker toggles state', () {
    LocationPickerStore store = LocationPickerStore();
    expect(store.isLocationPickerOpen, isFalse);

    store.toggleLocationPicker();

    expect(store.isLocationPickerOpen, isTrue);

    store.toggleLocationPicker();

    expect(store.isLocationPickerOpen, isFalse);
  });
  testWidgets(
    "toggleLocationPicker updates consumers",
    (WidgetTester tester) async {
      LocationPickerStore store = LocationPickerStore();
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => store,
          child: Consumer<LocationPickerStore>(
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
    LocationPickerStore store = LocationPickerStore();
    expect(store.selectedLocation, isNull);

    LatLng myLocation = LatLng(10, -10);
    store.setLocation(myLocation);

    expect(store.selectedLocation, equals(myLocation));
  });
  testWidgets(
    "setLocation updates consumers",
    (WidgetTester tester) async {
      LocationPickerStore store = LocationPickerStore();

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => store,
          child: Consumer<LocationPickerStore>(
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
}
