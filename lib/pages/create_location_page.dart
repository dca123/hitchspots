import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/form_fields/rating_bar.dart';
import '../widgets/form_fields/location_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class CreateLocationPage extends StatefulWidget {
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

  void addLocation() async {
    if (_formKey.currentState!.validate()) {
      GeoFirePoint newSpot =
          geo.point(latitude: position.latitude, longitude: position.longitude);
      print(locationName.text);
      print(locationExperience.text);
      print(ratingController);
      print(position);
      final locationID =
          await FirebaseFirestore.instance.collection('locations').add({
        'name': locationName.text,
        'position': newSpot.data,
        'rating': ratingController,
      });

      FirebaseFirestore.instance.collection('reviews').add({
        'description': locationExperience.text,
        'locationID': locationID.id,
        'rating': ratingController,
      });

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
          child: Column(children: [
            MapLocationFormField(
              buildContext: context,
              onSaved: (value) => position = value,
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Add name",
                hintText: "Simple Location Description",
              ),
            ),
            SizedBox(height: 24),
            TextFormField(
              controller: locationExperience,
              decoration: InputDecoration(
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  labelText: "Experience",
                  helperText: "How long did you wait ? Many vehicles go by ?",
                  hintText: "Describe your experience briefly."),
              maxLines: 3,
              keyboardType: TextInputType.multiline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
          ]),
        ),
      ),
    );
  }
}
