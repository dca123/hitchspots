import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(HitchSpotApp());

class HitchSpotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HitchSpots',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final Map<String, Marker> _markers = {};
  BitmapDescriptor customIcon;
  Future<void> _onMapCreated(GoogleMapController mapController) async {
    customIcon = await BitmapDescriptor.fromAssetImage(
        createLocalImageConfiguration(context), 'assets/icons/Bad.png');
    setState(() {
      _markers.clear();
      _markers["location1"] = Marker(
        markerId: MarkerId("location1"),
        position: LatLng(37.77233630600149, -122.47879056090717),
        icon: customIcon,
      );
    });
  }

  Completer<GoogleMapController> _controller = Completer();
  static final CameraPosition _sanFranciso = CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 12,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        initialCameraPosition: _sanFranciso,
        onMapCreated: _onMapCreated,
        zoomControlsEnabled: false,
        markers: _markers.values.toSet(),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _goToTheLake, child: const Icon(Icons.add)),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}
