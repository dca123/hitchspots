// ignore: import_of_legacy_library_into_null_safe
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:geoflutterfire2/geoflutterfire2.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'create_location_page.dart';
import '../widgets/location_info_card.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  HomePageState() {
    init();
  }
  Map<String, Marker> _markers = {};
  final geo = GeoFlutterFire();

  Future<void> init() async {
    await Firebase.initializeApp();
  }

  Future<void> _onMapCreated(GoogleMapController mapController) async {
    BitmapDescriptor goodIcon = await BitmapDescriptor.fromAssetImage(
        createLocalImageConfiguration(context), 'assets/icons/Good.png');
    BitmapDescriptor warningIcon = await BitmapDescriptor.fromAssetImage(
        createLocalImageConfiguration(context), 'assets/icons/Warning.png');
    BitmapDescriptor badIcon = await BitmapDescriptor.fromAssetImage(
        createLocalImageConfiguration(context), 'assets/icons/Bad.png');

    BitmapDescriptor getLocationMarker(double rating) {
      if (rating >= 4) {
        return goodIcon;
      } else if (rating >= 2.5) {
        return warningIcon;
      }
      return badIcon;
    }

    GeoFirePoint center = geo.point(latitude: 37.7749, longitude: -122.4194);
    final _firestore = FirebaseFirestore.instance;

    var collectionReference = _firestore.collection('locations');

    double radius = 50;
    String field = 'position';

    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: collectionReference)
        .within(center: center, radius: radius, field: field);
    final Map<String, Marker> tempMarkers = {};
    stream.listen((List<DocumentSnapshot> documentList) {
      documentList.forEach((document) {
        GeoPoint point = document.get('position')['geopoint'];
        double rating = document.get('rating').toDouble();
        tempMarkers[document.id] = Marker(
          markerId: MarkerId(document.id),
          position: LatLng(point.latitude, point.longitude),
          icon: getLocationMarker(rating),
          onTap: () {
            setState(() {
              locationName = document.get('name');
            });

            _panelController.animatePanelToPosition(0.35);
          },
        );
      });
      setState(() {
        _markers.addAll(tempMarkers);
      });
    });
  }

  late GoogleMapController mapController;
  late String locationName = "Default Location Name";
  final PanelController _panelController = PanelController();
  static final CameraPosition _sanFranciso = CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 12,
  );

  void maximizePanel() => _panelController.animatePanelToPosition(1);

  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );

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
        body: GoogleMap(
          initialCameraPosition: _sanFranciso,
          onMapCreated: _onMapCreated,
          zoomControlsEnabled: false,
          markers: _markers.values.toSet(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.push(context, MaterialPageRoute(builder: (context) {
          return CreateLocationPage();
        })),
        child: const Icon(Icons.add),
      ),
    );
  }
}
