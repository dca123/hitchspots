// ignore: import_of_legacy_library_into_null_safe
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:geoflutterfire2/geoflutterfire2.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hitchspots/models/location_card.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'create_location_page.dart';
import '../widgets/location_info_card.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late BitmapDescriptor goodIcon;
  late BitmapDescriptor warningIcon;
  late BitmapDescriptor badIcon;

  Map<String, Marker> _markers = {};
  final geo = GeoFlutterFire();

  late GoogleMapController mapController;
  late String locationName = "Default Location Name";
  final PanelController _panelController = PanelController();
  static final CameraPosition _sanFranciso = CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 12,
  );

  HomePageState() {
    init();
  }
  Future<void> init() async {
    await Firebase.initializeApp();
  }

  BitmapDescriptor ratingToMarker(double rating) {
    if (rating >= 4) {
      return goodIcon;
    } else if (rating >= 2.5) {
      return warningIcon;
    }
    return badIcon;
  }

  void maximizePanel() => _panelController.animatePanelToPosition(1);

  void _createMarkers(locationList, tempMarkers) {
    locationList.forEach((locationDocument) {
      print(locationDocument.get("name"));
      GeoPoint point = locationDocument.get('position')['geopoint'];
      double rating = locationDocument.get('rating').toDouble();
      tempMarkers[locationDocument.id] = Marker(
        markerId: MarkerId(locationDocument.id),
        position: LatLng(point.latitude, point.longitude),
        icon: ratingToMarker(rating),
        onTap: () {
          Provider.of<LocationCardModel>(context, listen: false)
              .updateLocation(locationDocument.data(), locationDocument.id);
          _panelController.animatePanelToPosition(0.35);
        },
      );
    });
  }

  void _getNearbySpots(ScreenCoordinate screenCoordinate) async {
    LatLng middlePoint = await mapController.getLatLng(screenCoordinate);
    GeoFirePoint center = geo.point(
        latitude: middlePoint.latitude, longitude: middlePoint.longitude);
    double zoom = await mapController.getZoomLevel();
    double radius = ((40000 / pow(2, zoom.floor())) * 2);

    final _firestore = FirebaseFirestore.instance;
    var locationsCollection = _firestore.collection('locations');

    Stream<List<DocumentSnapshot>> stream =
        geo.collection(collectionRef: locationsCollection).within(
              center: center,
              radius: radius,
              field: 'position',
              strictMode: true,
            );

    final Map<String, Marker> tempMarkers = {};

    stream.listen((locationList) {
      _createMarkers(locationList, tempMarkers);
      setState(() {
        _markers.addAll(tempMarkers);
      });
    });
  }

  Future<void> _onMapCreated(GoogleMapController mapController) async {
    this.mapController = mapController;
    goodIcon = await BitmapDescriptor.fromAssetImage(
        createLocalImageConfiguration(context), 'assets/icons/Good.png');
    warningIcon = await BitmapDescriptor.fromAssetImage(
        createLocalImageConfiguration(context), 'assets/icons/Warning.png');
    badIcon = await BitmapDescriptor.fromAssetImage(
        createLocalImageConfiguration(context), 'assets/icons/Bad.png');

    LatLng initalPos = LatLng(37.7749, -122.4194);
    ScreenCoordinate screenCoordinate =
        await mapController.getScreenCoordinate(initalPos);
    _getNearbySpots(screenCoordinate);
  }

  @override
  Widget build(BuildContext context) {
    const BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );
    final double screenWidth = MediaQuery.of(context).size.width *
        MediaQuery.of(context).devicePixelRatio;
    final double screenHeight = MediaQuery.of(context).size.height *
        MediaQuery.of(context).devicePixelRatio;

    final double middleX = screenWidth / 2;
    final double middleY = screenHeight / 2;

    final ScreenCoordinate screenCoordinate =
        ScreenCoordinate(x: middleX.round(), y: middleY.round());

    return new Scaffold(
      body: SlidingUpPanel(
        controller: _panelController,
        minHeight: 0,
        maxHeight: MediaQuery.of(context).size.height,
        snapPoint: 0.35,
        borderRadius: radius,
        panel: LocationInfoCard(
          radius: radius,
          maximizePanel: maximizePanel,
          locationName: locationName,
        ),
        onPanelOpened: () => {
          Provider.of<LocationCardModel>(context, listen: false).getReviews()
        },
        body: GoogleMap(
          initialCameraPosition: _sanFranciso,
          onMapCreated: _onMapCreated,
          zoomControlsEnabled: false,
          markers: _markers.values.toSet(),
          onCameraIdle: () => _getNearbySpots(screenCoordinate),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return CreateLocationPage();
          }),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
