import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hitchspots/models/location_card.dart';
import 'package:hitchspots/services/authentication.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:firebase_core/firebase_core.dart';

import 'create_location_page.dart';
import '../widgets/location_info_card.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late BitmapDescriptor goodIcon;
  late BitmapDescriptor warningIcon;
  late BitmapDescriptor badIcon;

  Map<String, Marker> _markers = {};
  final geo = GeoFlutterFire();

  GoogleMapController? mapController;
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
    LatLng middlePoint = await mapController!.getLatLng(screenCoordinate);
    GeoFirePoint center = geo.point(
        latitude: middlePoint.latitude, longitude: middlePoint.longitude);
    double? zoom = await mapController!.getZoomLevel();
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

  late AnimationController _snapPointAnimationController;
  late AnimationController _completeAnimationController;
  late Animation<double> _fabBotAnimation;
  late Animation<double> _cardAnimation;
  final BorderRadiusGeometry radius = BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );

  @override
  void initState() {
    super.initState();
    _snapPointAnimationController =
        AnimationController(vsync: this, lowerBound: 0, upperBound: 1);
    _fabBotAnimation = Tween<double>(begin: 16, end: 265)
        .animate(_snapPointAnimationController);

    _completeAnimationController =
        AnimationController(vsync: this, lowerBound: 0, upperBound: 1);
    _cardAnimation = CurvedAnimation(
        parent: _completeAnimationController, curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    final ScreenCoordinate screenCoordinate =
        getCenterOfScreenCoordinater(context);

    return new Scaffold(
      body: SlidingUpPanel(
        controller: _panelController,
        minHeight: 0,
        maxHeight: MediaQuery.of(context).size.height,
        snapPoint: 0.35,
        borderRadius: radius,
        panel: LocationInfoCard(
          animation: _cardAnimation,
          radius: radius,
          maximizePanel: maximizePanel,
        ),
        onPanelSlide: (slideValue) {
          _snapPointAnimationController.value = slideValue / 0.35;
          _completeAnimationController.value = (slideValue - 0.35) / 0.65;
        },
        onPanelOpened: () {
          Provider.of<LocationCardModel>(context, listen: false).getReviews();
        },
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _sanFranciso,
              onMapCreated: _onMapCreated,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              markers: _markers.values.toSet(),
              onCameraIdle: () => _getNearbySpots(screenCoordinate),
            ),
            AddLocationFAB(
              mapController: mapController,
              screenCoordinate: screenCoordinate,
              animation: _fabBotAnimation,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _snapPointAnimationController.dispose();
    super.dispose();
  }
}

class AddLocationFAB extends AnimatedWidget {
  AddLocationFAB({
    Key? key,
    required this.mapController,
    required this.screenCoordinate,
    required Animation<double> animation,
  }) : super(
          key: key,
          listenable: animation,
        );

  final GoogleMapController? mapController;
  final ScreenCoordinate screenCoordinate;

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Positioned(
      bottom: animation.value,
      right: 16,
      child: FloatingActionButton(
        elevation: 1,
        onPressed: () async {
          Provider.of<AuthenticationState>(context, listen: false)
              .loginFlowWithAction(
                  buildContext: context,
                  postLogin: () async {
                    final LatLng middlePoint =
                        await mapController!.getLatLng(screenCoordinate);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return CreateLocationPage(centerLatLng: middlePoint);
                      }),
                    );
                  });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

ScreenCoordinate getCenterOfScreenCoordinater(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width *
      MediaQuery.of(context).devicePixelRatio;
  double screenHeight = MediaQuery.of(context).size.height *
      MediaQuery.of(context).devicePixelRatio;

  double middleX = screenWidth / 2;
  double middleY = screenHeight / 2;

  return ScreenCoordinate(x: middleX.round(), y: middleY.round());
}
