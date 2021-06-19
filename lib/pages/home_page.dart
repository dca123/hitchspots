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
  static late BitmapDescriptor _goodIcon;
  static late BitmapDescriptor _warningIcon;
  static late BitmapDescriptor _badIcon;
  static late UI.Image _clusterImage;

  late ClusterManager _clusterManager;
  List<ClusterItem> _clusterItems = [];
  Map<String, Marker> _markersMap = {};
  Set<Marker> _clusterMarkers = {};

  final _geo = GeoFlutterFire();
  GoogleMapController? _mapController;
  final PanelController _panelController = PanelController();
  static final CameraPosition _centerOfWorld = CameraPosition(
    target: LatLng(0, 0),
    zoom: 0,
  );
  Location _location = Location();
  bool _isLocationGranted = false;

  late AnimationController _slidingPanelAnimationController;

  final BorderRadiusGeometry _radius = BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );

  double _snapPoint = 0.35;
  double? _noImagesCardSnapPoint;

  HomePageState() {
    init();
  }

  Future<void> init() async {
    await Firebase.initializeApp();

    _goodIcon = await BitmapDescriptor.fromAssetImage(
        createLocalImageConfiguration(context), 'assets/icons/Good.png');
    _warningIcon = await BitmapDescriptor.fromAssetImage(
        createLocalImageConfiguration(context), 'assets/icons/Warning.png');
    _badIcon = await BitmapDescriptor.fromAssetImage(
        createLocalImageConfiguration(context), 'assets/icons/Bad.png');
    _clusterImage = await _loadClusterImage('assets/icons/cluster.png');
  }

  BitmapDescriptor _ratingToMarker(double rating) {
    if (rating >= 4) {
      return _goodIcon;
    } else if (rating >= 2.5) {
      return _warningIcon;
    }
    return _badIcon;
  }

  void _maximizePanel() => _panelController.animatePanelToPosition(1);
  void _createMarkers(locationList, tempMarkers) {
    if (_noImagesCardSnapPoint == null) {
      final double cardHeight = cardDetailsKey.currentContext!.size!.height;
      final double screenHeight = MediaQuery.of(context).size.height;
      _noImagesCardSnapPoint = cardHeight / screenHeight;
      // print("$screenHeight $cardHeight $height - SCREENHEIGHT");
    }
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
          bool hasImages =
              Provider.of<LocationCardModel>(context, listen: false).hasImages;
          setState(() {
            _snapPoint = hasImages ? 0.35 : _noImagesCardSnapPoint!;
          });
          // print("SNAPPOINT - $snapPoint");
          _panelController.animatePanelToPosition(_snapPoint);
        },
      );
    });
  }

  void _getNearbySpots(ScreenCoordinate screenCoordinate) async {
    LatLngBounds bounds = await _mapController!.getVisibleRegion();
    LatLng ne = bounds.northeast;
    double r = 3963.0;
    LatLng middlePoint = await _mapController!.getLatLng(screenCoordinate);
    var lat1 = middlePoint.latitude / 57.2958;
    var lon1 = middlePoint.longitude / 57.2958;
    var lat2 = ne.latitude / 57.2958;
    var lon2 = ne.longitude / 57.2958;

    GeoFirePoint center = _geo.point(
        latitude: middlePoint.latitude, longitude: middlePoint.longitude);
    double? zoom = await _mapController!.getZoomLevel();
    var radius = r *
        acos(sin(lat1) * sin(lat2) + cos(lat1) * cos(lat2) * cos(lon2 - lon1));
    print("zoom: $zoom");
    if (zoom < 5) return;
    int limit = zoom >= 4 ? 9 : 2;
    final _firestore = FirebaseFirestore.instance;
    var locationsCollection = _firestore.collection('locations').limit(limit);

    Stream<List<DocumentSnapshot>> stream =
        _geo.collection(collectionRef: locationsCollection).within(
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
      _markersMap.addAll(tempMarkers);
      // Convert markers to ClusterItemList
      List<ClusterItem<Marker>> clusterItems = _markersMap.values
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
      this._mapController = mapController;
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
      _mapController!.animateCamera(
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
        return cluster.isMultiple
            ? Marker(
                markerId: MarkerId(cluster.getId()),
                position: cluster.location,
                onTap: () {
                  print('---- $cluster');
                  cluster.items.forEach((p) => print(p));
                },
                icon: await _getMarkerBitmap(cluster.count.toString()),
              )
            : cluster.items.first;
      };

  Future<UI.Image> _loadClusterImage(String imageAssetPath) async {
    Image image = Image.asset(imageAssetPath);
    Completer<ImageInfo> completer = Completer();
    image.image
        .resolve(createLocalImageConfiguration(context))
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info);
    }));
    ImageInfo imageInfo = await completer.future;
    return imageInfo.image;
  }

  Future<BitmapDescriptor> _getMarkerBitmap(String text) async {
    final UI.PictureRecorder pictureRecorder = UI.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final int width = _clusterImage.width;

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
      // Offset.zero,
      Offset(
        width / 2 - painter.width / 2,
        width / 3.15 - painter.height / 2,
      ),
    );

    final img = await pictureRecorder.endRecording().toImage(width, width);
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
      this._clusterMarkers = markers;
    });
  }

  @override
  void initState() {
    super.initState();
    _clusterManager = _initClusterManager();
    _slidingPanelAnimationController =
        AnimationController(vsync: this, lowerBound: 0, upperBound: 1);
  }

  final cardDetailsKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final ScreenCoordinate screenCoordinate =
        getCenterOfScreenCoordinater(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SlidingUpPanel(
        controller: _panelController,
        minHeight: 0,
        maxHeight: MediaQuery.of(context).size.height,
        snapPoint: _snapPoint,
        borderRadius: _radius,
        panel: LocationInfoCard(
          cardDetailsKey: cardDetailsKey,
          animationController: _slidingPanelAnimationController,
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
              markers: _clusterMarkers,
              onCameraMove: _clusterManager.onCameraMove,
              onCameraIdle: () {
                _getNearbySpots(screenCoordinate);
                _clusterManager.updateMap();
              },
            ),
            AddLocationWrapper(
              mapController: _mapController,
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
