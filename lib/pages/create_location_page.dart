import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hitchspots/services/authentication.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/form_fields/rating_bar.dart';
import '../widgets/form_fields/location_picker.dart';

class CreateLocationPage extends StatefulWidget {
  final LatLng _centerLatLng;

  CreateLocationPage({
    Key? key,
    required LatLng centerLatLng,
  })  : _centerLatLng = centerLatLng,
        super(key: key);

  @override
  _CreateLocationPageState createState() => _CreateLocationPageState();
}

class _CreateLocationPageState extends State<CreateLocationPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController locationName = TextEditingController();
  final TextEditingController locationExperience = TextEditingController();
  double ratingController = 0;
  late LatLng position;

  final geo = GeoFlutterFire();

  Future<bool> hasStreetViewImages(LatLng location) async {
    Uri imageParametersUrl =
        Uri.https("maps.googleapis.com", "/maps/api/streetview/metadata", {
      'location': '${location.latitude},${location.longitude}',
      'size': '456x456',
      'key': env['MAPS_API_KEY'],
    });
    final response = await http.get(imageParametersUrl);
    if (response.statusCode == 200) {
      String status = jsonDecode(response.body)['status'];
      if (status == "OK") return true;
    }
    return false;
  }

  Future<void> uploadImages(LatLng location, String locationID) async {
    // Heading in this context is the direction facing within 360 degrees
    Uri imageUrl(String heading) =>
        Uri.https("maps.googleapis.com", "/maps/api/streetview", {
          'location': '${location.latitude},${location.longitude}',
          'size': '456x456',
          'fov': '120',
          'heading': heading,
          'key': env['MAPS_API_KEY'],
        });

    const headings = ['0', '120', '240'];
    final documentDirectory = await getTemporaryDirectory();

    final responses =
        headings.map((heading) => http.get(imageUrl(heading))).toList();
    final List<File> files = headings
        .map((heading) =>
            File(path.join(documentDirectory.path, '$heading.jpeg')))
        .toList();

    files.asMap().forEach((index, file) async {
      var fileBodyBytes = (await responses[index]).bodyBytes;
      file.writeAsBytesSync(fileBodyBytes);
      try {
        await FirebaseStorage.instance
            .ref('street_view_images/$locationID/${headings[index]}.jpeg')
            .putFile(file);
      } on FirebaseException catch (e) {
        // e.g, e.code == 'canceled'
      }
    });
  }

  void addLocation() async {
    if (_formKey.currentState!.validate()) {
      GeoFirePoint newSpot =
          geo.point(latitude: position.latitude, longitude: position.longitude);
      final locationID =
          await FirebaseFirestore.instance.collection('locations').add({
        'name': locationName.text,
        'position': newSpot.data,
        'rating': ratingController,
        'reviewCount': 1,
        'createdBy': FirebaseAuth.instance.currentUser!.uid,
      });

      final String displayName =
          Provider.of<AuthenticationState>(context, listen: false).displayName!;
      DocumentReference location =
          await FirebaseFirestore.instance.collection('reviews').add({
        'description': locationExperience.text,
        'locationID': locationID.id,
        'rating': ratingController,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'createdByDisplayName': displayName,
      });

      if (await hasStreetViewImages(position)) {
        await uploadImages(position, location.id);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Thank you for contributing!'),
        ),
      );
      Future.delayed(Duration(milliseconds: 100), () {
        Navigator.pop(context);
      });
    }
  }

  @override
  void dispose() {
    locationName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).canvasColor,
        elevation: 0,
        // toolbarHeight: 64,
        toolbarHeight: 84,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          color: Colors.black,
        ),
        title: Text(
          "Add a location",
          style: Theme.of(context).textTheme.headline6,
        ),
        centerTitle: true,
        actions: [
          Container(
            padding: EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => addLocation(),
              color: Colors.black,
            ),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(children: [
              MapLocationFormField(
                buildContext: context,
                onSaved: (value) => position = value,
                centerLatLng: widget._centerLatLng,
              ),
              SizedBox(height: 24),
              RatingBarFormField(
                  buildContext: context,
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a rating';
                    }
                    ratingController = value;
                    return null;
                  }),
              SizedBox(height: 24),
              TextFormField(
                controller: locationName,
                maxLength: 50,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name for this location';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Location Name",
                  hintText: "Briefly describe the location ",
                  helperText: "i.e I-80 Exit, By the Doughnut shop",
                ),
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: locationExperience,
                maxLength: 300,
                decoration: InputDecoration(
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                    labelText: "Experience",
                    helperText: "How long did you wait ? It is a busy area ?",
                    hintText: "Describe your experience briefly"),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a short description of your experience';
                  }
                  return null;
                },
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
