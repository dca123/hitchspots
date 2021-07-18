import 'package:flutter/material.dart';
import 'package:hitchspots/models/location_card.dart';
import 'package:hitchspots/services/authentication.dart';
import 'package:provider/provider.dart';

/// displayName: TestUser, uid: Test123
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
        create: (context) =>
            AuthenticationState(displayName: "TestUser", uid: "TestUser123"),
      ),
    ],
    child: MaterialApp(
      home: child,
    ),
  );
}
