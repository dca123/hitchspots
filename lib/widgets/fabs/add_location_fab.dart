import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hitchspots/pages/create_location_page.dart';
import 'package:hitchspots/services/authentication.dart';
import 'package:provider/provider.dart';

class AddLocationWrapper extends StatefulWidget {
  AddLocationWrapper({
    Key? key,
    required this.mapController,
    required this.screenCoordinate,
  }) : super(key: key);

  final GoogleMapController? mapController;
  final ScreenCoordinate screenCoordinate;
  final CircleBorder circleFabBorder = CircleBorder();
  final double mobileFabDimension = 56;
  @override
  _AddLocationWrapperState createState() => _AddLocationWrapperState();
}

class _AddLocationWrapperState extends State<AddLocationWrapper> {
  late LatLng middlePoint;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Positioned(
      bottom: 16,
      right: 16,
      child: OpenContainer<bool>(
        onClosed: (success) {
          if (success == true) {
            Future.delayed(const Duration(milliseconds: 500), () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Thank you for contributing!'),
                ),
              );
            });
          }
        },
        closedShape: widget.circleFabBorder,
        closedElevation: 6,
        closedColor: theme.primaryColor,
        closedBuilder: (context, openContainer) {
          return InkWell(
            child: SizedBox(
              height: widget.mobileFabDimension,
              width: widget.mobileFabDimension,
              child: Center(
                child: Icon(
                  Icons.add,
                  color: theme.colorScheme.surface,
                ),
              ),
            ),
            onTap: () async {
              middlePoint = await widget.mapController!
                  .getLatLng(widget.screenCoordinate);
              Provider.of<AuthenticationState>(context, listen: false)
                  .loginFlowWithAction(
                buildContext: context,
                postLogin: () => openContainer(),
              );
            },
          );
        },
        openBuilder: (context, closedContainer) {
          return CreateLocationPageProvider(
            closedContainer: closedContainer,
            centerLatLng: middlePoint,
          );
        },
      ),
    );
  }
}
