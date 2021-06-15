import 'dart:async';
import 'dart:io';
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
  late BitmapDescriptor goodIcon;
  late BitmapDescriptor warningIcon;
  late BitmapDescriptor badIcon;
  late BitmapDescriptor clusterIcon;

  Map<String, Marker> _markers = {};
  Set<Marker> markers = {};

  final geo = GeoFlutterFire();
  GoogleMapController? mapController;
  final PanelController _panelController = PanelController();
  static final CameraPosition _sanFranciso = CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 2,
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
    // double radius = ((40000 / pow(2, zoom.floor())) * 2);
    print("zoom: $zoom");
    // print("dis: $dis");
    // int limit = 1;
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
      print("length ${locationList.length}");
      _createMarkers(locationList, tempMarkers);

      print("ITEMS - ${_manager.items.toList()}");
      _markers.addAll(tempMarkers);

      List<ClusterItem<Marker>> clusterItems = _markers.values
          .map((Marker marker) =>
              ClusterItem<Marker>(marker.position, item: marker))
          .toList();
      _manager.setItems(clusterItems);
    });
  }

  Future<void> _onMapCreated(GoogleMapController mapController) async {
    setState(() {
      this.mapController = mapController;
      _manager.setMapController(mapController);
    });

    moveCameraToUserLocation();

    goodIcon = await BitmapDescriptor.fromAssetImage(
        createLocalImageConfiguration(context), 'assets/icons/Good.png');
    warningIcon = await BitmapDescriptor.fromAssetImage(
        createLocalImageConfiguration(context), 'assets/icons/Warning.png');
    badIcon = await BitmapDescriptor.fromAssetImage(
        createLocalImageConfiguration(context), 'assets/icons/Bad.png');
    clusterIcon = await BitmapDescriptor.fromAssetImage(
        createLocalImageConfiguration(context), 'assets/icons/cluster.png');
  }

  void getLocation() async {
    if (await Permission.location.request().isGranted) {
      moveCameraToUserLocation();
    }
  }

  void moveCameraToUserLocation() async {
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

  List<ClusterItem> items = [];
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
                // icon: clusterIcon,
                icon: await _getMarkerBitmap(cluster.isMultiple ? width : 75,
                    text: cluster.isMultiple ? cluster.count.toString() : null),
              )
            : cluster.items.first;
      };

  Future<UI.Image> loadUiImage(String imageAssetPath) async {
    // final ByteData data = await rootBundle.load(imageAssetPath);
    // final Completer<UI.Image> completer = Completer();
    // UI.decodeImageFromList(Uint8List.view(data.buffer), (UI.Image img) {
    //   return completer.complete(img);
    // });
    // return completer.future;

    double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    ByteData data = await rootBundle.load(imageAssetPath);
    print(pixelRatio);
    UI.Codec codec = await UI.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: pixelRatio.round() * 50);
    UI.FrameInfo fi = await codec.getNextFrame();
    ByteData? imageAsByte =
        await fi.image.toByteData(format: UI.ImageByteFormat.png);

    Future<UI.Image> myBackground =
        decodeImageFromList(imageAsByte!.buffer.asUint8List());

    return myBackground;
  }

  Future<BitmapDescriptor> _getMarkerBitmap(double size, {String? text}) async {
    final UI.PictureRecorder pictureRecorder = UI.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    UI.Image image = await loadUiImage('assets/icons/4.0x/cluster.png');
    canvas.drawImage(image, Offset.zero, Paint());

    if (text != null) {
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
    }

    final img = await pictureRecorder
        .endRecording()
        .toImage(size.toInt(), size.toInt());
    final data =
        await img.toByteData(format: UI.ImageByteFormat.png) as ByteData;

    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }

  late ClusterManager _manager;

  @override
  void initState() {
    _manager = _initClusterManager();
    _slidingPanelAnimationController =
        AnimationController(vsync: this, lowerBound: 0, upperBound: 1);
    super.initState();
  }

  ClusterManager _initClusterManager() {
    return ClusterManager(
      items,
      _updateMarkers,
      markerBuilder: _markerBuilder,
      initialZoom: 16,
      stopClusteringZoom: 12,
    );
  }

  void _updateMarkers(Set<Marker> markers) {
    print('Updated ${markers.length} markers');
    setState(() {
      this.markers = markers;
    });
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
        snapPoint: 0.35,
        borderRadius: radius,
        panel: LocationInfoCard(
          animationController: _slidingPanelAnimationController,
          radius: radius,
          maximizePanel: maximizePanel,
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
              initialCameraPosition: _sanFranciso,
              onMapCreated: _onMapCreated,
              myLocationEnabled: _isLocationGranted,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              markers: markers,
              onCameraMove: _manager.onCameraMove,
              onCameraIdle: () {
                _getNearbySpots(screenCoordinate);
                _manager.updateMap();
              },
            ),
            AddLocationWrapper(
              mapController: mapController,
              screenCoordinate: screenCoordinate,
            ),
            MyLocationFabAnimator(
              getLocation: getLocation,
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
