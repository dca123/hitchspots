import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hitchspots/services/authentication.dart';
import 'package:hitchspots/utils/widget_switcher.dart';
import '../widgets/form_fields/rating_bar.dart';
import 'package:hitchspots/widgets/form_fields/rating_bar.dart';
import '../models/location_card.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class CreateReviewPage extends StatefulWidget {
  CreateReviewPage({Key? key, FirebaseFirestore? fakeFirestore})
      : super(key: key) {
    firestoreInstance = fakeFirestore;
  }
  late final FirebaseFirestore? firestoreInstance;
  @override
  _CreateReviewPageState createState() => _CreateReviewPageState();
}

class _CreateReviewPageState extends State<CreateReviewPage> {
  final descriptionTextController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  double ratingController = 0;
  bool isSaving = false;

  Future<void> ensureFirebaseInit() async {
    if (Firebase.apps.length < 1) {
      await Firebase.initializeApp();
    }
    widget.firestoreInstance ??= FirebaseFirestore.instance;
  }

  @override
  Widget build(BuildContext context) {
    void addLocation(String locationID) async {
      if (_formKey.currentState!.validate()) {
        setState(() {
          isSaving = true;
        });
        await ensureFirebaseInit();
        final String displayName =
            Provider.of<AuthenticationState>(context, listen: false)
                .displayName!;
        widget.firestoreInstance!.collection('reviews').add({
          'description': descriptionTextController.text,
          'locationID': locationID,
          'rating': ratingController,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'createdByDisplayName': displayName,
        });

        DocumentReference locationDocumentRef =
            widget.firestoreInstance!.collection('locations').doc(locationID);
        widget.firestoreInstance!.runTransaction((transaction) async {
          DocumentSnapshot location =
              await transaction.get(locationDocumentRef);
          int oldReviewCount = location.get('reviewCount');
          int newReviewCount = oldReviewCount + 1;

          double oldRatingTotal =
              location.get('rating').toDouble() * oldReviewCount;
          double newRating =
              (oldRatingTotal + ratingController) / newReviewCount;

          transaction.update(locationDocumentRef,
              {'rating': newRating, 'reviewCount': newReviewCount});
        });
        Provider.of<LocationCardModel>(context, listen: false).clearReviews();
        Provider.of<LocationCardModel>(context, listen: false).getReviews();

        Navigator.pop(context, true);
      }
    }

    return Consumer<LocationCardModel>(builder: (context, locationCard, child) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).canvasColor,
          elevation: 0,
          toolbarHeight: 84,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            color: Colors.black,
          ),
          title: Text(
            "${locationCard.locationName}",
            style: Theme.of(context).textTheme.headline6,
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 2.0),
              child: WidgetSwitcherWrapper(
                condition: isSaving,
                widgetIfTrue: IconButton(
                  key: ValueKey('spinner'),
                  onPressed: null,
                  icon: SpinKitWave(
                    color: Colors.black,
                    size: 16,
                  ),
                ),
                widgetIfFalse: IconButton(
                  key: ValueKey('send'),
                  icon: const Icon(Icons.send),
                  onPressed: () => addLocation(locationCard.locationID),
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 24),
                  RatingBarFormField(
                    initialValue: ratingController,
                    onSaved: (double? rating) => ratingController = rating!,
                  ),
                  SizedBox(height: 24),
                  TextFormField(
                    controller: descriptionTextController,
                    maxLength: 300,
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                      labelText: "Experience",
                      helperText: "How long did you wait ? It is a busy area ?",
                      hintText: "Describe your experience briefly",
                    ),
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a short description of your experience';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    descriptionTextController.dispose();
    super.dispose();
  }
}
