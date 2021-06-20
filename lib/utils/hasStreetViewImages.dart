import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
