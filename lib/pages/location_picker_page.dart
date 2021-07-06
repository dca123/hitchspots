import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hitchspots/models/location_picker_store.dart';
import 'package:provider/provider.dart';
import './home_page.dart';

class LocationPickerPage extends StatefulWidget {
  LocationPickerPage({
    Key? key,
    required LatLng centerLatLng,
  })  : centerCamPos = CameraPosition(
          target: centerLatLng,
          zoom: 18,
        ),
        super(key: key);

  final CameraPosition centerCamPos;
  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPickerPage> {
  late GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Provider.of<LocationPickerStore>(context, listen: false)
            .toggleLocationPicker();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).canvasColor,
          elevation: 1,
          toolbarHeight: 84,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () =>
                Provider.of<LocationPickerStore>(context, listen: false)
                    .toggleLocationPicker(),
            color: Colors.black,
          ),
          title: Text(
            "Select on the map",
            style: Theme.of(context).textTheme.headline6,
          ),
          centerTitle: true,
          actions: [
            Container(
              padding: EdgeInsets.only(right: 16),
              child: IconButton(
                icon: const Icon(Icons.done),
                onPressed: () async {
                  final ScreenCoordinate screenCoordinate =
                      getCenterOfScreenCoordinater(context);

                  final LatLng middlePoint =
                      await mapController.getLatLng(screenCoordinate);
                  Provider.of<LocationPickerStore>(context, listen: false)
                      .setLocation(middlePoint);
                },
                color: Colors.black,
              ),
            )
          ],
        ),
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: widget.centerCamPos,
              buildingsEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),
            Center(child: Image.asset('assets/icons/Picker.png')),
          ],
        ),
      ),
    );
  }
}
