import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hitchspots/models/location_picker_store.dart';
import 'package:provider/provider.dart';

class LocationPickerFormField extends FormField<LatLng> {
  static GoogleMapController? mapController;
  LocationPickerFormField({
    required BuildContext buildContext,
    required Function(LatLng?) onSaved,
    required LatLng centerLatLng,
    required GlobalKey<FormState> formkey,
  }) : super(
          initialValue:
              Provider.of<CreateLocationPageStore>(buildContext, listen: false)
                  .selectedLocation,
          onSaved: onSaved,
          validator: (LatLng? value) {
            if (value == null) {
              return "Please select a location";
            }
            onSaved(value);
          },
          builder: (formContext) {
            final CameraPosition centerCamPos = CameraPosition(
              target: formContext.widget.initialValue ?? centerLatLng,
              zoom: 18,
            );
            return Column(
              children: [
                Container(
                  height: 100,
                  child: GestureDetector(
                    onTap: () {
                      formkey.currentState!.save();
                      Provider.of<CreateLocationPageStore>(buildContext,
                              listen: false)
                          .toggleLocationPicker();
                    },
                    child: Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: centerCamPos,
                          buildingsEnabled: false,
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
                if (formContext.hasError)
                  Container(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      formContext.errorText!,
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
