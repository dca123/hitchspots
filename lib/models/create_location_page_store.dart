import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CreateLocationPageStore extends ChangeNotifier {
  bool _isLocationPickerOpen = false;
  LatLng? _selectedLocation;
  String _locationName = "";
  String _locationExperience = "";
  double _locationRating = 0;

  bool get isLocationPickerOpen => _isLocationPickerOpen;
  LatLng? get selectedLocation => _selectedLocation;
  Map<String, dynamic> get locationData => {
        "name": _locationName,
        "experience": _locationExperience,
        "rating": _locationRating,
      };

  void toggleLocationPicker() {
    _isLocationPickerOpen = !_isLocationPickerOpen;
    notifyListeners();
  }

  void updateLocationName(String name) {
    _locationName = name;
  }

  void updateLocationExperience(String experience) {
    _locationExperience = experience;
  }

  void updateRating(double rating) {
    _locationRating = rating;
  }

  void setLocation(LatLng location) {
    _selectedLocation = location;
    toggleLocationPicker();
  }
}
