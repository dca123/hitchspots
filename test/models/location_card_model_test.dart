import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hitchspots/models/location_card.dart';

void main() {
  String locationID = "02AXytdxVjVvgjqQ7XlV";
  LatLng locationCoordinates = LatLng(40.9030851603782, 20.7206225395203);
  var locationData = {
    "createdBy": "Hitchwiki user",
    "hasImages": true,
    "imageUrls": [
      "https://storage.googleapis.com/hitchspots.appspot.com/street_view_images/02AXytdxVjVvgjqQ7XlV/0.jpeg",
      "https://storage.googleapis.com/hitchspots.appspot.com/street_view_images/02AXytdxVjVvgjqQ7XlV/120.jpeg",
      "https://storage.googleapis.com/hitchspots.appspot.com/street_view_images/02AXytdxVjVvgjqQ7XlV/240.jpeg",
    ],
    "legacyId": 3285,
    "name": "Tushemisht",
    "position": {
      "geohash": "srq8xw0m9",
      "geopoint": GeoPoint(
        locationCoordinates.latitude,
        locationCoordinates.longitude,
      )
    },
    "rating": 1,
    "reviewCount": 2,
  };

  var locationReviewData = {
    "locationID": locationID,
    "description": "Test Review",
    "createdByDisplayName": "Amede74",
    "rating": 5,
    "timestamp": 1421820995000,
  };
  test('updateLocation changes location info', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection("reviews").add(locationReviewData);

    LocationCardModel cardModel =
        LocationCardModel(firestoreInstance: firestore);
    await cardModel.updateLocation(locationData, locationID);

    expect(cardModel.locationID, equals(locationID));
    expect(cardModel.locationName, equals(locationData["name"]));
    expect(cardModel.recentReview, equals(locationReviewData["description"]));
    expect(cardModel.locationRating, equals(locationData["rating"]));
    expect(cardModel.reviewCount, equals(locationData["reviewCount"]));
    expect(cardModel.coordinates, equals(locationCoordinates));
    expect(cardModel.reviews, hasLength(0));
    expect(cardModel.hasImages, equals(locationData["hasImages"]));
  });
  test('getReviews updates the review list', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection("reviews").add(locationReviewData);
    await firestore.collection("reviews").add(locationReviewData);
    await firestore.collection("reviews").add(locationReviewData);

    LocationCardModel cardModel =
        LocationCardModel(firestoreInstance: firestore);

    await cardModel.updateLocation(locationData, locationID);
    await cardModel.getReviews();

    expect(cardModel.reviews, hasLength(3));
    expect(cardModel.reviews[0]["description"],
        equals(locationReviewData["description"]));
  });
  test('clearReviews clears the review list', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection("reviews").add(locationReviewData);
    await firestore.collection("reviews").add(locationReviewData);
    await firestore.collection("reviews").add(locationReviewData);

    LocationCardModel cardModel =
        LocationCardModel(firestoreInstance: firestore);

    await cardModel.updateLocation(locationData, locationID);
    await cardModel.getReviews();

    expect(cardModel.reviews, hasLength(3));

    cardModel.clearReviews();

    expect(cardModel.reviews, hasLength(0));
  });
}
