import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../pages/location_picker_page.dart';

class MapLocationFormField extends FormField<LatLng> {
  static GoogleMapController? mapController;
  MapLocationFormField({
    required BuildContext buildContext,
    required onSaved,
    required LatLng centerLatLng,
  }) : super(
          onSaved: onSaved,
          validator: (LatLng? value) {
            if (value == null) {
              return "Please select a location";
            }
          },
          builder: (context) {
            final CameraPosition centerCamPos = CameraPosition(
              target: centerLatLng,
              zoom: 18,
            );

            return Column(
              children: [
                Container(
                  height: 100,
                  child: GestureDetector(
                    onTap: () async {
                      final LatLng result = await Navigator.push(
                        buildContext,
                        MaterialPageRoute(builder: (context) {
                          return LocationPicker(centerOfScreen: centerCamPos);
                        }),
                      );
                      CameraUpdate updatedPosition =
                          CameraUpdate.newLatLng(result);
                      mapController!.moveCamera(updatedPosition);
                      print(result);
                      context.didChange(result);
                      context.save();
                    },
                    child: Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: centerCamPos,
                          zoomControlsEnabled: false,
                          onMapCreated: (controller) {
                            mapController = controller;
                          },
                        ),
                        Opacity(
                          opacity: 0.65,
                          child: Container(
                            color: Colors.black,
                          ),
                        ),
                        Center(
                          child: Text(
                            "Tap to select location",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (context.hasError)
                  Container(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      context.errorText!,
                      style: Theme.of(buildContext)
                          .textTheme
                          .caption!
                          .apply(color: Theme.of(buildContext).errorColor),
                    ),
                  )
              ],
            );
          },
        );
}
