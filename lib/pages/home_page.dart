import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as UI;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hitchspots/models/location_card.dart';
import 'package:hitchspots/services/authentication.dart';
import 'package:hitchspots/utils/show_dialog.dart';
import 'package:hitchspots/widgets/fabs/add_location_fab.dart';
import 'package:hitchspots/widgets/fabs/my_location_fab.dart';
import 'package:hitchspots/widgets/search_bar/search_bar.dart';
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
  static late CameraPosition _startLocation;
  Location _location = Location();
  bool _isLocationGranted = false;
  bool _findingLocation = false;

  late AnimationController _slidingPanelAnimationController;

  final BorderRadiusGeometry _radius = BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );

  double _snapPoint = 0.35;
  double? _noImagesCardSnapPoint;

  bool _isInitialized = false;
  HomePageState() {
    init();
  }

  Future<void> init() async {
    await Firebase.initializeApp();
    await Provider.of<AuthenticationState>(context, listen: false)
        .ensureFirebaseInit();
    // FirebaseFirestore.instance.settings =
    //     Settings(host: '192.168.1.2:8005', sslEnabled: false);

    if (await Permission.location.isGranted &&
        await _location.serviceEnabled()) {
      LatLng location = await _getLocation();
      _startLocation = CameraPosition(target: location, zoom: 10);
    } else {
      LatLng ipLocation = await getIPLocation() ?? LatLng(0, 0);
      _startLocation = CameraPosition(target: ipLocation, zoom: 10);
    }

    setState(() {
      _isInitialized = true;
    });

    _goodIcon = await BitmapDescriptor.fromAssetImage(
        createLocalImageConfiguration(context), 'assets/icons/Good.png');
    _warningIcon = await BitmapDescriptor.fromAssetImage(
        createLocalImageConfiguration(context), 'assets/icons/Warning.png');
    _badIcon = await BitmapDescriptor.fromAssetImage(
        createLocalImageConfiguration(context), 'assets/icons/Bad.png');
    _clusterImage = await _loadClusterImage('assets/icons/cluster.png');
  }

  Future<LatLng?> getIPLocation() async {
    try {
      var response = await Dio()
          .get('http://ip-api.com/json/62.210.188.30??fields=lat,lon');
      return LatLng(response.data["lat"], response.data["lon"]);
    } catch (e) {
      print(e);
    }
  }

  BitmapDescriptor _ratingToMarker(double rating) {
    if (rating >= 3.0) {
      return _goodIcon;
    } else if (rating >= 2.0) {
      return _warningIcon;
    }
    return _badIcon;
  }

  void _maximizePanel() => _panelController.animatePanelToPosition(1);

  void _createMarkers(List<DocumentSnapshot> locationList, tempMarkers) {
    if (_noImagesCardSnapPoint == null) {
      final double cardHeight = cardDetailsKey.currentContext!.size!.height;
      final double screenHeight = MediaQuery.of(context).size.height;
      _noImagesCardSnapPoint = cardHeight / screenHeight;
      // print("$screenHeight $cardHeight $height - SCREENHEIGHT");
    }
    locationList.forEach((locationDocument) {
      dynamic locationData = locationDocument.data();
      GeoPoint point = locationDocument.get('position')['geopoint'];
      double rating = locationDocument.get('rating').toDouble();
      bool hasImages = locationData['hasImages'] ?? false;
      tempMarkers[locationDocument.id] = Marker(
        markerId: MarkerId(locationDocument.id),
        position: LatLng(point.latitude, point.longitude),
        icon: _ratingToMarker(rating),
        onTap: () async {
          await Provider.of<LocationCardModel>(context, listen: false)
              .updateLocation(locationData, locationDocument.id);
          setState(() {
            _snapPoint = hasImages ? 0.35 : _noImagesCardSnapPoint!;
          });
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
  }

  void _requestLocationPermission() async {
    if (await Permission.location.request().isGranted) {
      if (await _location.serviceEnabled()) {
        _moveCameraToUserLocation();
      } else {
        await showAlertDialog(
          context: context,
          title: "Location Services Disabled",
          body: "Please enable location services to use this feature",
        );
        _location.requestService();
      }
    } else if (await Permission.location.isDenied) {
      await showAlertDialog(
        context: context,
        title: "Location Permission Denied",
        body:
            "Please provide location permissions to HitchSpots in your settings",
      );
      await openAppSettings();
    }
  }

  void _moveCameraToUserLocation() async {
    if (await Permission.location.isGranted) {
      setState(() {
        _isLocationGranted = true;
        _findingLocation = true;
      });
      LatLng location = await _getLocation();
      setState(() {
        _findingLocation = false;
      });
      _moveCameraToLocation(location);
    }
  }

  // Call only if location permission is enabled
  Future<LatLng> _getLocation() async {
    assert(await Permission.location.isGranted);
    LocationData locationData = await _location.getLocation();
    return LatLng(locationData.latitude!, locationData.longitude!);
  }

  void _moveCameraToLocation(LatLng location, [double? zoom]) async {
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(location.latitude, location.longitude),
          zoom: zoom ?? 10,
        ),
      ),
    );
  }

  Future<Marker> Function(Cluster) get _markerBuilder => (cluster) async {
        return cluster.isMultiple
            ? Marker(
                markerId: MarkerId(cluster.getId()),
                position: cluster.location,
                onTap: () async {
                  double zoom = await _mapController!.getZoomLevel() + 0.5;
                  _moveCameraToLocation(cluster.location, zoom);
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
        fontSize: 30,
        fontWeight: FontWeight.w400,
      ),
    );
    painter.layout();
    painter.paint(
      canvas,
      // Offset.zero,
      Offset(
        width / 2 - painter.width / 2,
        width / 3.25 - painter.height / 2,
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
      initialZoom: 10,
      levels: [1, 4.25, 6.75, 8.25, 11.5],
      stopClusteringZoom: 12,
      extraPercent: 0.4,
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
            _isInitialized
                ? GoogleMap(
                    initialCameraPosition: _startLocation,
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
                  )
                : Center(child: Text("Initializing")),
            AddLocationWrapper(
              mapController: _mapController,
              screenCoordinate: screenCoordinate,
            ),
            MyLocationFabAnimator(
              getLocation: _requestLocationPermission,
              animationController: _slidingPanelAnimationController,
              findingLocation: _findingLocation,
            ),
            SearchBar(
              isLocationGranted: _isLocationGranted,
              location: _location,
              moveCameraToLocation: _moveCameraToLocation,
            ),
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
