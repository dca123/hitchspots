import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() => runApp(HitchSpotApp());

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
