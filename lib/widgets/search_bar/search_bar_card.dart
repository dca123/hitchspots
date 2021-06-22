import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class SearchLocationCard extends StatelessWidget {
  const SearchLocationCard({
    Key? key,
    required this.street,
    required this.country,
    required this.adminArea,
    required this.location,
    required this.moveCameraToLocation,
    required this.floatingSearchBarController,
    this.distanceTo,
  }) : super(key: key);

  final String street;
  final String country;
  final String adminArea;
  final int? distanceTo;
  final LatLng location;
  final Function moveCameraToLocation;
  final FloatingSearchBarController floatingSearchBarController;

  @override
  Widget build(BuildContext context) {
    TextTheme textThemes = Theme.of(context).textTheme;
    bool isDistanceNull = distanceTo == null;

    return InkWell(
      onTap: () {
        moveCameraToLocation(location);
        floatingSearchBarController.close();
      },
      child: Container(
        height: 112,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(
          children: [
            Flexible(
              fit: FlexFit.tight,
              flex: 1,
              child: Icon(
                Icons.location_on,
                size: 32,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    street,
                    style: textThemes.subtitle1,
                  ),
                  SizedBox(
                    height: 4.0,
                  ),
                  Text(
                    adminArea,
                    style: textThemes.caption,
                  ),
                  Text(
                    country,
                    style: textThemes.caption,
                  )
                ],
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              flex: 1,
              child: Container(
                padding: EdgeInsets.only(right: 16),
                child: isDistanceNull
                    ? Container()
                    : Text(
                        "$distanceTo KM",
                        style: textThemes.headline5,
                        textAlign: TextAlign.center,
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
