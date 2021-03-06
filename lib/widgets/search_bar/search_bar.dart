import 'dart:math';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hitchspots/widgets/search_bar/search_bar_card.dart';
import 'package:hitchspots/widgets/settings/settings_modal.dart';
import 'package:location/location.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

class SearchBar extends StatefulWidget {
  const SearchBar(
      {Key? key,
      required this.isLocationGranted,
      required this.location,
      required this.moveCameraToLocation})
      : super(key: key);

  final bool isLocationGranted;
  final Location location;
  final Function moveCameraToLocation;

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  FloatingSearchBarController _floatingSearchBarController =
      FloatingSearchBarController();

  Set<SearchLocationPlaceMark> _searchLocationPlaceMarkSet = {};
  bool _hasSearchError = false;
  void _onSubmitted(locationText) async {
    _searchLocationPlaceMarkSet.clear();

    List<dynamic> searchResults = [];
    late List<geocoding.Location> possibleLocations;
    try {
      possibleLocations = await geocoding.locationFromAddress(locationText);
    } catch (e) {
      setState(() {
        _hasSearchError = true;
      });
      return;
    }

    for (geocoding.Location location in possibleLocations) {
      List<geocoding.Placemark> placemark =
          await geocoding.placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      searchResults.add({'location': location, 'placemark': placemark.first});
    }

    LocationData? locationData;
    if (widget.isLocationGranted) {
      locationData = await widget.location.getLocation();
    }

    searchResults.forEach((result) {
      geocoding.Location resultLocation = result['location'];
      geocoding.Placemark resultPlacemark = result['placemark'];
      int? distance;

      if (locationData != null) {
        LatLng myLocation =
            LatLng(locationData.latitude!, locationData.longitude!);
        distance = calculateDistance(myLocation,
            LatLng(resultLocation.latitude, resultLocation.longitude));
      }

      _searchLocationPlaceMarkSet.add(
        SearchLocationPlaceMark(
          country: resultPlacemark.country ?? "",
          street: resultPlacemark.street ?? "",
          adminArea: resultPlacemark.administrativeArea ?? "",
          distance: distance,
          location: LatLng(
            resultLocation.latitude,
            resultLocation.longitude,
          ),
        ),
      );
    });

    // Display the Found locations
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return FloatingSearchBar(
      hint: 'Type in an address',
      title: Text(
        'Where are we hitchiking to ?',
        style: TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.w400,
          fontSize: 16,
        ),
      ),
      hintStyle: TextStyle(
        color: Colors.black45,
        fontWeight: FontWeight.w400,
      ),
      controller: _floatingSearchBarController,
      backdropColor: Colors.black45,
      borderRadius: BorderRadius.circular(8),
      margins: const EdgeInsets.only(top: 45, right: 20, left: 20),
      scrollPadding: const EdgeInsets.only(top: 20, bottom: 56),
      transitionDuration: const Duration(milliseconds: 300),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: 350,
      onSubmitted: _onSubmitted,
      onFocusChanged: (hasFocus) {
        setState(() {
          _hasSearchError = false;
        });
      },
      transition: SlideFadeFloatingSearchBarTransition(),
      automaticallyImplyBackButton: false,
      actions: [
        FloatingSearchBarAction.icon(
            icon: Icon(
              Icons.tune,
              color: Colors.black38,
            ),
            onTap: () {
              showModal(
                context: context,
                builder: (BuildContext context) {
                  return SettingsCard();
                },
              );
            }),
      ],
      builder: (context, transition) {
        return _hasSearchError
            ? Container(
                child: Text(
                "No locations found. Try again with a generic location name !",
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ))
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Material(
                  color: Colors.white,
                  elevation: 4.0,
                  child: Column(
                    children: _searchLocationPlaceMarkSet
                        .map(
                          (place) => SearchLocationCard(
                            street: place.street,
                            adminArea: place.adminArea,
                            country: place.country,
                            distanceTo: place.distance,
                            location: place.location,
                            moveCameraToLocation: widget.moveCameraToLocation,
                            floatingSearchBarController:
                                _floatingSearchBarController,
                          ),
                        )
                        .toList(),
                  ),
                ),
              );
      },
    );
  }
}

class SearchLocationPlaceMark {
  SearchLocationPlaceMark({
    required this.country,
    required this.adminArea,
    required this.street,
    required this.location,
    this.distance,
  });

  final String country;
  final String adminArea;
  final String street;
  final int? distance;
  final LatLng location;

  @override
  int get hashCode {
    int result = 17;
    result = 37 * result + country.hashCode;
    result = 37 * result + adminArea.hashCode;
    result = 37 * result + street.hashCode;
    result = 37 * result + (distance ?? 0);
    return result;
  }

  @override
  bool operator ==(dynamic other) {
    return other is SearchLocationPlaceMark &&
        other.country == country &&
        other.adminArea == adminArea &&
        other.distance == distance &&
        other.street == street;
  }
}

int calculateDistance(LatLng position1, LatLng position2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((position2.latitude - position1.latitude) * p) / 2 +
      c(position1.latitude * p) *
          c(position2.latitude * p) *
          (1 - c((position2.longitude - position1.longitude) * p)) /
          2;
  return (12742 * asin(sqrt(a))).round();
}
