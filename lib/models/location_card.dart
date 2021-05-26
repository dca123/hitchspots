import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LocationCardModel extends ChangeNotifier {
  String _locationName = "I-20 Exit";
  double _locationRating = 0.0;
  int _reviewCount = 0;
  late String _locationID = "testLocationID";
  String _recentReview = "";
  Map<String, dynamic> _reviews = {};

  String get locationID => _locationID;
  String get locationName => _locationName;
  String get recentReview => _recentReview;
  double get locationRating => _locationRating;
  int get reviewCount => _reviewCount;
  List get reviews => _reviews.values.toList();

  void updateLocation(dynamic locationData, String locationID) async {
    if (_locationID != locationID) {
      _reviews.clear();
      _locationName = locationData['name'];
      _locationID = locationID;
      var reviewQuery = await _reviewQuery(locationId: _locationID, limit: 1);
      _recentReview = reviewQuery.docs[0].get('description');
    }
    _locationRating = double.parse(locationData['rating'].toStringAsFixed(2));
    _reviewCount = locationData['reviewCount'];
    print(_locationID);
    notifyListeners();
  }

  void getReviews() async {
    var reviewQuery = await _reviewQuery(locationId: _locationID, limit: 10);
    reviewQuery.docs.forEach((document) {
      _reviews[document.id] = document.data();
    });
    print(reviews);
    notifyListeners();
  }

  void clearReviews() {
    _reviews.clear();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _reviewQuery({
    required locationId,
    required limit,
  }) async {
    return await FirebaseFirestore.instance
        .collection("reviews")
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .where("locationID", isEqualTo: locationId)
        .get();
  }
}
