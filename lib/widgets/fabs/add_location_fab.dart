import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hitchspots/pages/create_location_page.dart';
import 'package:hitchspots/services/authentication.dart';
import 'package:provider/provider.dart';

class AddLocationFAB extends StatelessWidget {
  AddLocationFAB({
    Key? key,
    required this.mapController,
    required this.screenCoordinate,
  }) : super(key: key);

  final GoogleMapController? mapController;
  final ScreenCoordinate screenCoordinate;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      right: 16,
      child: FloatingActionButton(
        elevation: 1,
        onPressed: () async {
          Provider.of<AuthenticationState>(context, listen: false)
              .loginFlowWithAction(
                  buildContext: context,
                  postLogin: () async {
                    final LatLng middlePoint =
                        await mapController!.getLatLng(screenCoordinate);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return CreateLocationPage(centerLatLng: middlePoint);
                      }),
                    );
                  });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
