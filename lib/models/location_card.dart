import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class LocationCardModel extends ChangeNotifier {
  String _locationName = "I-20 Exit";
  double _locationRating = 0.0;
  late String _locationID = "testLocationID";
  String get locationID => _locationID;
  String get locationName => _locationName;
  double get locationRating => _locationRating;
  Map<String, dynamic> _reviews = {};
  List get reviews => _reviews.values.toList();

  void updateLocation(dynamic locationData, String locationID) {
    if (_locationID != locationID) {
      _reviews.clear();
      _locationName = locationData['name'];
      _locationRating = locationData['rating'].toDouble();
      _locationID = locationID;
    }
    print(_locationID);
    notifyListeners();
  }

  void getReviews() async {
    var reviewQuery = await FirebaseFirestore.instance
        .collection("reviews")
        .limit(5)
        .where("locationID", isEqualTo: _locationID)
        .get();
    reviewQuery.docs.forEach((document) {
      _reviews[document.id] = document.data();
    });
    print(reviews);
    notifyListeners();
  }

  void clearReviews() {
    _reviews.clear();
  }
}
