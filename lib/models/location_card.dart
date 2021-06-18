import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationCardModel extends ChangeNotifier {
  String _locationName = "I-20 Exit";
  double _locationRating = 0.0;
  int _reviewCount = 0;
  late String _locationID = "testLocationID";
  String _recentReview = "";
  LatLng _coordinates = LatLng(0, 0);
  Map<String, dynamic> _reviews = {};
  bool _hasImages = false;

  String get locationID => _locationID;
  String get locationName => _locationName;
  String get recentReview => _recentReview;
  double get locationRating => _locationRating;
  int get reviewCount => _reviewCount;
  LatLng get coordinates => _coordinates;
  List get reviews => _reviews.values.toList();
  bool get hasImages => _hasImages;

  Future<void> updateLocation(dynamic locationData, String locationID) async {
    if (_locationID != locationID) {
      _reviews.clear();
      _locationName = locationData['name'];
      _locationID = locationID;
      final GeoPoint position = locationData['position']['geopoint'];
      _coordinates = LatLng(position.latitude, position.longitude);
      var reviewQuery = await _reviewQuery(locationId: _locationID, limit: 1);
      _recentReview = reviewQuery.docs.length > 0
          ? reviewQuery.docs[0].get('description')
          : "";
      // _hasImages = await hasStreetViewImages(_coordinates);
    }
    _locationRating = double.parse(locationData['rating'].toStringAsFixed(2));
    _reviewCount = locationData['reviewCount'];
    notifyListeners();
  }

  void getReviews() async {
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
  }) async =>
      await FirebaseFirestore.instance
          .collection("reviews")
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .where("locationID", isEqualTo: locationId)
          .get();

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
}
