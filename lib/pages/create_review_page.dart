import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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
        FirebaseFirestore.instance.collection('reviews').add({
          'description': descriptionTextController.text,
          'locationID': locationID,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 24),
                FormField<double>(
                  builder: (ratingFormContext) {
                    return Column(
                      children: [
                        RatingBar(
                          initialRating: 0,
                          glow: false,
                          itemPadding: EdgeInsets.symmetric(horizontal: 8.0),
                          allowHalfRating: true,
                          ratingWidget: RatingWidget(
                            full: Icon(Icons.star, color: Colors.yellow[700]),
                            half: Icon(Icons.star_half,
                                color: Colors.yellow[700]),
                            empty: Icon(Icons.star_outline,
                                color: Colors.yellow[700]),
                          ),
                          onRatingUpdate: (value) =>
                              ratingFormContext.setValue(value),
                        ),
                        if (ratingFormContext.hasError)
                          Column(
                            children: [
                              SizedBox(height: 16),
                              Text(
                                ratingFormContext.errorText!,
                                style: Theme.of(context)
                                    .textTheme
                                    .caption!
                                    .apply(color: Theme.of(context).errorColor),
                              ),
                            ],
                          ),
                      ],
                    );
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a rating';
                    }
                    ratingController = value;
                    return null;
                  },
                ),
                SizedBox(height: 24),
                TextFormField(
                  controller: descriptionTextController,
                  decoration: InputDecoration(
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                      labelText: "Experience",
                      helperText:
                          "How long did you wait ? Many vehicles go by ?",
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
                SizedBox(height: 24),
                OutlinedButton(
                    onPressed: () => {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_enhance),
                        Text("Add Photos"),
                      ],
                    ))
              ],
            ),
          ),
        ),
      );
    });
  }
}
