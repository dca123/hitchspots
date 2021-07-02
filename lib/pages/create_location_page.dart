import 'package:animations/animations.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hitchspots/models/location_picker_store.dart';
import 'package:hitchspots/services/authentication.dart';
import 'package:hitchspots/utils/icon_switcher.dart';
import 'package:provider/provider.dart';
import '../widgets/form_fields/rating_bar.dart';
import '../widgets/form_fields/location_picker.dart';
import 'location_picker_page.dart';

class CreateLocationPage extends StatefulWidget {
  final LatLng _centerLatLng;
  final Function closedContainer;
  CreateLocationPage({
    Key? key,
    required LatLng centerLatLng,
    required Function closedContainer,
  })  : closedContainer = closedContainer,
        _centerLatLng = centerLatLng,
        super(key: key);

  @override
  _CreateLocationPageState createState() => _CreateLocationPageState();
}

class _CreateLocationPageState extends State<CreateLocationPage> {
  final _formKey = GlobalKey<FormState>();

  final geo = GeoFlutterFire();

  final TextEditingController locationName = TextEditingController();
  final TextEditingController locationExperience = TextEditingController();
  double ratingController = 0;
  late LatLng position;

  bool isSaving = false;

  void addLocation() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isSaving = !isSaving;
      });

      GeoFirePoint newSpot =
          geo.point(latitude: position.latitude, longitude: position.longitude);
      final locationID =
          await FirebaseFirestore.instance.collection('locations').add({
        'name': locationName.text,
        'position': newSpot.data,
        'rating': ratingController,
        'reviewCount': 1,
        'hasImages': false,
        'createdBy': FirebaseAuth.instance.currentUser!.uid,
      });

      final String displayName =
          Provider.of<AuthenticationState>(context, listen: false).displayName!;
      await FirebaseFirestore.instance.collection('reviews').add({
        'description': locationExperience.text,
        'locationID': locationID.id,
        'rating': ratingController,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'createdByDisplayName': displayName,
      });
      print("CREATED LOCAITON WITH ID - ${locationID.id}");
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
    locationExperience.dispose();
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
          onPressed: () => widget.closedContainer(),
          color: Colors.black,
        ),
        title: Text(
          "Add a location",
          style: Theme.of(context).textTheme.headline6,
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 2.0),
            child: IconSwitcherWrapper(
              condition: isSaving,
              iconIfTrue: IconButton(
                key: ValueKey('spinner'),
                onPressed: () => {},
                icon: SpinKitWave(
                  color: Colors.black,
                  size: 16,
                ),
              ),
              iconIfFalse: IconButton(
                key: ValueKey('send'),
                icon: const Icon(Icons.send),
                onPressed: () => addLocation(),
                color: Colors.black,
              ),
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
                onSaved: (value) => position = value!,
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

class _SharedAxisTransitionSwitcher extends StatelessWidget {
  const _SharedAxisTransitionSwitcher({
    required this.fillColor,
    required this.child,
    required this.reverse,
  });

  final Widget child;
  final Color fillColor;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      reverse: reverse,
      transitionBuilder: (child, animation, secondaryAnimation) {
        return SharedAxisTransition(
          transitionType: SharedAxisTransitionType.scaled,
          child: child,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
        );
      },
      child: child,
    );
  }
}

class _CreateLocationPageSwitcher extends StatelessWidget {
  const _CreateLocationPageSwitcher({
    Key? key,
    required this.centerLatLng,
    required this.closedContainer,
  }) : super(key: key);
  final LatLng centerLatLng;
  final Function closedContainer;
  @override
  Widget build(BuildContext context) {
    return Consumer<LocationPickerStore>(
      builder: (context, locationPickerStore, child) {
        Widget pageSwitcher = locationPickerStore.isLocationPickerOpen
            ? LocationPickerPage(
                centerLatLng: centerLatLng,
              )
            : CreateLocationPage(
                centerLatLng: centerLatLng,
                closedContainer: closedContainer,
              );
        return _SharedAxisTransitionSwitcher(
          fillColor: Colors.transparent,
          reverse: !locationPickerStore.isLocationPickerOpen,
          child: pageSwitcher,
        );
      },
    );
  }
}

class CreateLocationPageProvider extends StatelessWidget {
  const CreateLocationPageProvider({
    Key? key,
    required this.centerLatLng,
    required this.closedContainer,
  }) : super(key: key);

  final LatLng centerLatLng;
  final Function closedContainer;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LocationPickerStore(),
      child: _CreateLocationPageSwitcher(
        centerLatLng: centerLatLng,
        closedContainer: closedContainer,
      ),
    );
  }
}
