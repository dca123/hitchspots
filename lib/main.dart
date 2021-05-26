import 'package:flutter/material.dart';
import 'package:hitchspots/models/location_card.dart';
import 'package:hitchspots/services/authentication.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';

void main() => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => LocationCardModel(),
          ),
          ChangeNotifierProvider(
            create: (context) => AuthenticationState(),
          ),
        ],
        child: HitchSpotApp(),
      ),
    );

class HitchSpotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HitchSpots',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
