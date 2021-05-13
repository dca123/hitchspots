import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'pages/create_location_page.dart';

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
  HomePageState() {
    init();
  }
  Map<String, Marker> _markers = {};
  late BitmapDescriptor customIcon;
  final geo = Geoflutterfire();

  Future<void> init() async {
    await Firebase.initializeApp();
  }

  Future<void> _onMapCreated(GoogleMapController mapController) async {
    this.mapController = mapController;
    customIcon = await BitmapDescriptor.fromAssetImage(
        createLocalImageConfiguration(context), 'assets/icons/Bad.png');

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
        tempMarkers[document.id] = Marker(
          markerId: MarkerId(document.id),
          position: LatLng(point.latitude, point.longitude),
          icon: customIcon,
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
        print(_markers.values.toSet());
      });
    });
  }

  late GoogleMapController mapController;
  String locationName = "Test";
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
        snapPoint: 0.5,
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

class LocationInfoCard extends StatelessWidget {
  const LocationInfoCard(
      {Key? key,
      required this.radius,
      required this.maximizePanel,
      required this.locationName})
      : super(key: key);

  final BorderRadiusGeometry radius;
  final Function maximizePanel;
  final String locationName;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: radius,
        ),
        height: 103.0,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            ReviewImage(imageName: "image1"),
            ReviewImage(imageName: "image2"),
            ReviewImage(imageName: "image3"),
            ReviewImage(imageName: "image4"),
            ReviewImage(imageName: "image5"),
          ],
        ),
      ),
      LocationInfomation(locationName: locationName),
      ButtonBar(maximizePanel: maximizePanel),
      ReviewList()
    ]);
  }
}

class ReviewImage extends StatelessWidget {
  const ReviewImage({Key? key, required this.imageName}) : super(key: key);
  final String imageName;
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/locations/$imageName.jpg",
      width: 144,
      fit: BoxFit.cover,
    );
  }
}

class ReviewList extends StatelessWidget {
  const ReviewList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: [
          ReviewTile(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(),
          ),
          ReviewTile(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(),
          ),
          ReviewTile(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(),
          ),
          ReviewTile(),
        ],
      ),
    );
  }
}

class ReviewTile extends StatelessWidget {
  const ReviewTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Dev Dog",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          Row(
            children: [
              StarRatingsBar(),
              Text(
                " 5 Years Ago",
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
          Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing'
            'elit, sed do eiusmod tempor incididunt ut labore et'
            'dolore magna aliqua. Egestas maecenas pharetra'
            ' convallis posuere morbi leo urna molestie.',
            style: Theme.of(context).textTheme.bodyText2,
            softWrap: true,
          )
        ],
      ),
    );
  }
}

class ButtonBar extends StatelessWidget {
  const ButtonBar({required this.maximizePanel});
  final Function maximizePanel;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 8.0),
        scrollDirection: Axis.horizontal,
        children: [
          SizedBox(width: 24.0),
          ElevatedButton(
            onPressed: () => {},
            child: Row(
              children: [
                Icon(Icons.add),
                Text("Review"),
              ],
            ),
          ),
          SizedBox(width: 16.0),
          OutlinedButton(
            onPressed: () => maximizePanel(),
            child: Row(
              children: [
                Icon(Icons.comment),
                Text("Comments"),
              ],
            ),
          ),
          SizedBox(width: 16.0),
          OutlinedButton(
            onPressed: () => {},
            child: Row(
              children: [
                Icon(Icons.navigation),
                Text("Open in Google Maps"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LocationInfomation extends StatelessWidget {
  const LocationInfomation({required this.locationName});
  final String locationName;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 24.0, left: 24.0, bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$locationName",
            style: Theme.of(context).textTheme.headline6,
          ),
          Row(
            children: [
              Text(
                "4.9",
                style: Theme.of(context).textTheme.caption,
              ),
              StarRatingsBar(),
              Text(
                "(1,004)",
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
          Text(
            "Near Irving St, San Francisco",
            style: Theme.of(context).textTheme.caption,
          )
        ],
      ),
    );
  }
}

class StarRatingsBar extends StatelessWidget {
  const StarRatingsBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.star,
          size: 12.0,
          color: Colors.green[700],
        ),
        Icon(
          Icons.star,
          size: 12.0,
          color: Colors.green[700],
        ),
        Icon(
          Icons.star,
          size: 12.0,
          color: Colors.green[700],
        ),
        Icon(
          Icons.star_border_outlined,
          size: 12.0,
        ),
        Icon(
          Icons.star_border_outlined,
          size: 12.0,
        ),
      ],
    );
  }
}
