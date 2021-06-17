import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as UI;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hitchspots/models/location_card.dart';
import 'package:hitchspots/widgets/fabs/add_location_fab.dart';
import 'package:hitchspots/widgets/fabs/my_location_fab.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:firebase_core/firebase_core.dart';

import '../widgets/location_info_card.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  static late BitmapDescriptor goodIcon;
  static late BitmapDescriptor warningIcon;
  static late BitmapDescriptor badIcon;
  static late UI.Image _clusterImage;

  late ClusterManager _clusterManager;
  List<ClusterItem> _clusterItems = [];
  Map<String, Marker> _markers = {};
  Set<Marker> markers = {};

  final geo = GeoFlutterFire();
  GoogleMapController? mapController;
  final PanelController _panelController = PanelController();
  static final CameraPosition _centerOfWorld = CameraPosition(
    target: LatLng(0, 0),
    zoom: 0,
  );
  Location _location = Location();
  bool _isLocationGranted = false;

  late AnimationController _slidingPanelAnimationController;

  final BorderRadiusGeometry radius = BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );

  HomePageState() {
    init();
  }

  Future<void> init() async {
    await Firebase.initializeApp();

    double width = MediaQuery.of(context).devicePixelRatio.round() * 50;
    _clusterImage = await _loadUiImage('assets/icons/cluster.png', width);

    goodIcon = await BitmapDescriptor.fromAssetImage(
        createLocalImageConfiguration(context), 'assets/icons/Good.png');
    warningIcon = await BitmapDescriptor.fromAssetImage(
        createLocalImageConfiguration(context), 'assets/icons/Warning.png');
    badIcon = await BitmapDescriptor.fromAssetImage(
        createLocalImageConfiguration(context), 'assets/icons/Bad.png');
  }

  BitmapDescriptor _ratingToMarker(double rating) {
    if (rating >= 4) {
      return goodIcon;
    } else if (rating >= 2.5) {
      return warningIcon;
    }
    return badIcon;
  }

  void _maximizePanel() => _panelController.animatePanelToPosition(1);
  bool hasImages = false;
  void _createMarkers(locationList, tempMarkers) {
    locationList.forEach((locationDocument) {
      GeoPoint point = locationDocument.get('position')['geopoint'];
      double rating = locationDocument.get('rating').toDouble();
      tempMarkers[locationDocument.id] = Marker(
        markerId: MarkerId(locationDocument.id),
        position: LatLng(point.latitude, point.longitude),
        icon: _ratingToMarker(rating),
        onTap: () async {
          await Provider.of<LocationCardModel>(context, listen: false)
              .updateLocation(locationDocument.data(), locationDocument.id);
          setState(() {
            hasImages = Provider.of<LocationCardModel>(context, listen: false)
                .hasImages;
          });
          _panelController.animatePanelToPosition(hasImages ? 0.35 : 0.20);
        },
      );
    });
  }

  void _getNearbySpots(ScreenCoordinate screenCoordinate) async {
    LatLngBounds bounds = await mapController!.getVisibleRegion();
    LatLng ne = bounds.northeast;
    double r = 3963.0;
    LatLng middlePoint = await mapController!.getLatLng(screenCoordinate);
    var lat1 = middlePoint.latitude / 57.2958;
    var lon1 = middlePoint.longitude / 57.2958;
    var lat2 = ne.latitude / 57.2958;
    var lon2 = ne.longitude / 57.2958;

    GeoFirePoint center = geo.point(
        latitude: middlePoint.latitude, longitude: middlePoint.longitude);
    double? zoom = await mapController!.getZoomLevel();
    var radius = r *
        acos(sin(lat1) * sin(lat2) + cos(lat1) * cos(lat2) * cos(lon2 - lon1));
    print("zoom: $zoom");
    if (zoom < 5) return;
    int limit = zoom >= 4 ? 9 : 2;
    final _firestore = FirebaseFirestore.instance;
    var locationsCollection = _firestore.collection('locations').limit(limit);

    Stream<List<DocumentSnapshot>> stream =
        geo.collection(collectionRef: locationsCollection).within(
              center: center,
              radius: radius,
              field: 'position',
              strictMode: false,
            );

    final Map<String, Marker> tempMarkers = {};

    stream.listen((locationList) {
      // Create Markers
      _createMarkers(locationList, tempMarkers);
      // Add Markers to Marker map
      _markers.addAll(tempMarkers);
      // Convert markers to ClusterItemList
      List<ClusterItem<Marker>> clusterItems = _markers.values
          .map((Marker marker) => ClusterItem<Marker>(
                marker.position,
                item: marker,
              ))
          .toList();
      _clusterManager.setItems(clusterItems);
    });
  }

  Future<void> _onMapCreated(GoogleMapController mapController) async {
    setState(() {
      this.mapController = mapController;
      _clusterManager.setMapController(mapController);
    });

    _moveCameraToUserLocation();
  }

  void _getLocation() async {
    if (await Permission.location.request().isGranted) {
      _moveCameraToUserLocation();
    }
  }

  void _moveCameraToUserLocation() async {
    if (await Permission.location.isGranted) {
      setState(() {
        _isLocationGranted = true;
      });
      LocationData locationData = await _location.getLocation();
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(locationData.latitude!, locationData.longitude!),
            zoom: 12,
          ),
        ),
      );
    }
  }

  Future<Marker> Function(Cluster) get _markerBuilder => (cluster) async {
        double width = MediaQuery.of(context).devicePixelRatio.round() * 50;
        return cluster.isMultiple
            ? Marker(
                markerId: MarkerId(cluster.getId()),
                position: cluster.location,
                onTap: () {
                  print('---- $cluster');
                  cluster.items.forEach((p) => print(p));
                },
                icon: await _getMarkerBitmap(width, cluster.count.toString()),
              )
            : cluster.items.first;
      };

  Future<UI.Image> _loadUiImage(String imageAssetPath, double width) async {
    ByteData data = await rootBundle.load(imageAssetPath);
    UI.Codec codec = await UI.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width.round());
    UI.FrameInfo fi = await codec.getNextFrame();
    ByteData? imageAsByte =
        await fi.image.toByteData(format: UI.ImageByteFormat.png);

    Future<UI.Image> myBackground =
        decodeImageFromList(imageAsByte!.buffer.asUint8List());

    return myBackground;
  }

  Future<BitmapDescriptor> _getMarkerBitmap(double size, String text) async {
    final UI.PictureRecorder pictureRecorder = UI.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    canvas.drawImage(_clusterImage, Offset.zero, Paint());

    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: Theme.of(context).textTheme.headline4?.fontSize,
        ));
    painter.layout();
    painter.paint(
      canvas,
      Offset(
        size / 2 - painter.width / 2,
        size / 3.15 - painter.height / 2,
      ),
    );

    final img = await pictureRecorder
        .endRecording()
        .toImage(size.toInt(), size.toInt());
    final data =
        await img.toByteData(format: UI.ImageByteFormat.png) as ByteData;

    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }

  ClusterManager _initClusterManager() {
    return ClusterManager(
      _clusterItems,
      _updateMarkers,
      markerBuilder: _markerBuilder,
      initialZoom: 16,
      stopClusteringZoom: 12,
    );
  }

  void _updateMarkers(Set<Marker> markers) {
    setState(() {
      this.markers = markers;
    });
  }

  @override
  void initState() {
    _clusterManager = _initClusterManager();
    _slidingPanelAnimationController =
        AnimationController(vsync: this, lowerBound: 0, upperBound: 1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ScreenCoordinate screenCoordinate =
        getCenterOfScreenCoordinater(context);
    return new Scaffold(
      resizeToAvoidBottomInset: false,
      body: SlidingUpPanel(
        controller: _panelController,
        minHeight: 0,
        maxHeight: MediaQuery.of(context).size.height,
        snapPoint: hasImages ? 0.35 : 0.20,
        borderRadius: radius,
        panel: LocationInfoCard(
          animationController: _slidingPanelAnimationController,
          radius: radius,
          maximizePanel: _maximizePanel,
        ),
        onPanelSlide: (slideValue) {
          _slidingPanelAnimationController.value = slideValue;
        },
        onPanelOpened: () {
          Provider.of<LocationCardModel>(context, listen: false).getReviews();
        },
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _centerOfWorld,
              onMapCreated: _onMapCreated,
              myLocationEnabled: _isLocationGranted,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              markers: markers,
              onCameraMove: _clusterManager.onCameraMove,
              onCameraIdle: () {
                _getNearbySpots(screenCoordinate);
                _clusterManager.updateMap();
              },
            ),
            AddLocationWrapper(
              mapController: mapController,
              screenCoordinate: screenCoordinate,
            ),
            MyLocationFabAnimator(
              getLocation: _getLocation,
              animationController: _slidingPanelAnimationController,
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _slidingPanelAnimationController.dispose();
    super.dispose();
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
