import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerStore extends ChangeNotifier {
  bool _isLocationPickerOpen = false;
  LatLng? _selectedLocation;

  bool get isLocationPickerOpen => _isLocationPickerOpen;
  LatLng? get selectedLocation => _selectedLocation;

  void toggleLocationPicker() {
    _isLocationPickerOpen = !_isLocationPickerOpen;
    notifyListeners();
  }

  void setLocation(LatLng location) {
    _selectedLocation = location;
    toggleLocationPicker();
  }
}
