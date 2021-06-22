import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hitchspots/widgets/search_bar/search_bar_card.dart';
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

class _SearchBarState extends State<SearchBar> {
  FloatingSearchBarController _floatingSearchBarController =
      FloatingSearchBarController();

  Set<SearchLocationPlaceMark> _searchLocationPlaceMarkSet = {};

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return FloatingSearchBar(
      hint: 'Type in an address',
      title: Text(
        'Where are hitchiking to ...',
      ),
      controller: _floatingSearchBarController,
      borderRadius: BorderRadius.circular(16),
      margins: const EdgeInsets.only(top: 40, right: 20, left: 20),
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 300),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      // width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {},
      onSubmitted: (locationText) async {
        _searchLocationPlaceMarkSet.clear();
        List<geocoding.Location> locations =
            await geocoding.locationFromAddress(locationText);

        List<dynamic> searchResults = [];

        for (geocoding.Location location in locations) {
          geocoding.Placemark placemark =
              (await geocoding.placemarkFromCoordinates(
            location.latitude,
            location.longitude,
          ))
                  .first;

          searchResults.add({'location': location, 'placemark': placemark});
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
      },
      transition: SlideFadeFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.place),
            onPressed: () {},
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
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
                      distanceTo: place.distance ?? 0,
                      location: place.location,
                      moveCameraToLocation: widget.moveCameraToLocation,
                      floatingSearchBarController: _floatingSearchBarController,
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
