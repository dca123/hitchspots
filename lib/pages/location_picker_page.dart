import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPicker extends StatelessWidget {
  LocationPicker({
    Key? key,
    required CameraPosition sanFranciso,
  })  : _sanFranciso = sanFranciso,
        super(key: key);

  final CameraPosition _sanFranciso;
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
                double screenWidth = MediaQuery.of(context).size.width *
                    MediaQuery.of(context).devicePixelRatio;
                double screenHeight = MediaQuery.of(context).size.height *
                    MediaQuery.of(context).devicePixelRatio;

                double middleX = screenWidth / 2;
                double middleY = screenHeight / 2;

                ScreenCoordinate screenCoordinate =
                    ScreenCoordinate(x: middleX.round(), y: middleY.round());

                LatLng middlePoint =
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
            initialCameraPosition: _sanFranciso,
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
