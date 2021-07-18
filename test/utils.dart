import 'package:flutter/material.dart';
import 'package:hitchspots/models/location_card.dart';
import 'package:hitchspots/services/authentication.dart';
import 'package:provider/provider.dart';

Widget applicationWrapper({
  required Widget child,
  LocationCardModel? locationCardModel,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => locationCardModel ?? LocationCardModel(),
      ),
      ChangeNotifierProvider(
        create: (context) => AuthenticationState(displayName: "TestUser"),
      ),
    ],
    child: MaterialApp(
      home: child,
    ),
  );
}
