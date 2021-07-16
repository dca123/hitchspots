import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hitchspots/pages/create_location_page.dart';
import 'package:hitchspots/services/authentication.dart';
import 'package:hitchspots/utils/show_dialog.dart';
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
                child: Consumer<AuthenticationState>(
                  builder: (context, authState, child) {
                    if (authState.isAuthenticating) {
                      return Center(
                        child: SpinKitPulse(
                          size: 30,
                          color: Theme.of(context).cardColor,
                        ),
                      );
                    } else {
                      return Center(
                        child: Icon(
                          Icons.add,
                          color: theme.colorScheme.surface,
                        ),
                      );
                    }
                  },
                )),
            onTap: () async {
              if (Provider.of<AuthenticationState>(context, listen: false)
                      .isAuthenticating ==
                  false) {
                middlePoint = await widget.mapController!
                    .getLatLng(widget.screenCoordinate);
                if (Provider.of<AuthenticationState>(context, listen: false)
                        .loginState !=
                    LoginState.loggedIn) {
                  await showAlertDialog(
                      context: context,
                      title: "You're Not Signed In",
                      body:
                          "You will need to login or sign up before you can contribute",
                      ActionOneTitle: "Continue",
                      ActionTwoTitle: "Close",
                      ActionOne: () {
                        Provider.of<AuthenticationState>(context, listen: false)
                            .loginFlowWithAction(
                          buildContext: context,
                          postLogin: openContainer,
                        );
                      });
                } else {
                  openContainer();
                }
              }
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
