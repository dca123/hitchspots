import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
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
  HomePageState() {
    init();
  }
  final Map<String, Marker> _markers = {};
  late BitmapDescriptor customIcon;

  Future<void> init() async {
    await Firebase.initializeApp();
  }
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
  const LocationInfomation();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 24.0, left: 24.0, bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "I-74 Exit",
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
