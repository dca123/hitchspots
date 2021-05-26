import 'package:flutter/material.dart';
import 'package:hitchspots/services/authentication.dart';
import '../widgets/form_fields/rating_bar.dart';
import 'package:hitchspots/widgets/form_fields/rating_bar.dart';
import '../models/location_card.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateReviewPage extends StatelessWidget {
  CreateReviewPage({
    Key? key,
  }) : super(key: key);
  final descriptionTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  double? ratingController;
  @override
  Widget build(BuildContext context) {
    void addLocation(String locationID) {
      if (_formKey.currentState!.validate()) {
        final String displayName =
            Provider.of<AuthenticationState>(context, listen: false)
                .displayName!;
        FirebaseFirestore.instance.collection('reviews').add({
          'description': descriptionTextController.text,
          'locationID': locationID,
          'rating': ratingController,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'createdByDisplayName': displayName,
        });

        DocumentReference locationDocumentRef =
            FirebaseFirestore.instance.collection('locations').doc(locationID);
        FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot location =
              await transaction.get(locationDocumentRef);
          int oldReviewCount = location.get('reviewCount');
          int newReviewCount = oldReviewCount + 1;

          double oldRatingTotal = location.get('rating') * oldReviewCount;
          double newRating =
              (oldRatingTotal + ratingController!) / newReviewCount;

          transaction.update(locationDocumentRef,
              {'rating': newRating, 'reviewCount': newReviewCount});
        });
        Provider.of<LocationCardModel>(context, listen: false).clearReviews();
        Provider.of<LocationCardModel>(context, listen: false).getReviews();
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
            Container(
              padding: EdgeInsets.only(right: 16),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => addLocation(locationCard.locationID),
                color: Colors.black,
              ),
            )
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
                    controller: descriptionTextController,
                    maxLength: 300,
                    decoration: InputDecoration(
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                        labelText: "Experience",
                        helperText:
                            "How long did you wait ? It is a busy area ?",
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
                  // SizedBox(height: 24),
                  // OutlinedButton(
                  //   onPressed: () => {},
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       Icon(Icons.camera_enhance),
                  //       Text("Add Photos"),
                  //     ],
                  // ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
