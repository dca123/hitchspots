import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationCardModel extends ChangeNotifier {
  String _locationName = "I-20 Exit";
  double _locationRating = 0.0;
  int _reviewCount = 0;
  late String _locationID = "testLocationID";
  String _recentReview = "";
  LatLng _coordinates = LatLng(0, 0);
  Map<String, dynamic> _reviews = {};
  bool _hasImages = false;
  FirebaseFirestore? _firestoreInstance;

  String get locationID => _locationID;
  String get locationName => _locationName;
  String get recentReview => _recentReview;
  double get locationRating => _locationRating;
  int get reviewCount => _reviewCount;
  LatLng get coordinates => _coordinates;
  List get reviews => _reviews.values.toList();
  bool get hasImages => _hasImages;

  LocationCardModel({FirebaseFirestore? firestoreInstance}) {
    _firestoreInstance = firestoreInstance;
  }

  Future<void> updateLocation(dynamic locationData, String locationID) async {
    if (_locationID != locationID) {
      _reviews.clear();
      _locationName = locationData['name'];
      _locationID = locationID;
      _hasImages = locationData['hasImages'] ?? false;
      final GeoPoint position = locationData['position']['geopoint'];
      _coordinates = LatLng(position.latitude, position.longitude);
      var reviewQuery = await _reviewQuery(locationId: _locationID, limit: 1);
      _recentReview = reviewQuery.docs.length > 0
          ? reviewQuery.docs[0].get('description')
          : "";
    }
    _locationRating = double.parse(locationData['rating'].toStringAsFixed(2));
    _reviewCount = locationData['reviewCount'];
    notifyListeners();
  }

  Future<void> getReviews() async {
    var reviewQuery = await _reviewQuery(locationId: _locationID, limit: 100);
    reviewQuery.docs.forEach((document) {
      _reviews[document.id] = document.data();
    });
    notifyListeners();
  }

  void clearReviews() {
    _reviews.clear();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _reviewQuery({
    required locationId,
    required limit,
  }) async {
    _firestoreInstance ??= FirebaseFirestore.instance;
    return await _firestoreInstance!
        .collection("reviews")
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .where("locationID", isEqualTo: locationId)
        .get();
  }
}
