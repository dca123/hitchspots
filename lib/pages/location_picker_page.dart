import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import './home_page.dart';

class LocationPicker extends StatefulWidget {
  LocationPicker({
    Key? key,
    required CameraPosition centerOfScreen,
  })  : _centerOfScreen = centerOfScreen,
        super(key: key);

  final CameraPosition _centerOfScreen;

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).canvasColor,
        elevation: 1,
        // toolbarHeight: 64,
        toolbarHeight: 84,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
                Navigator.pop(context, middlePoint);
              },
              color: Colors.black,
            ),
          )
        ],
      ),
      // appBar: AppBar(
      //   title: Text("Move the Map to the Spot"),

      // ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: widget._centerOfScreen,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
          ),
          Center(child: Image.asset('assets/icons/Good.png')),
        ],
      ),
    );
  }
}
