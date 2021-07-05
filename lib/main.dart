import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hitchspots/models/location_card.dart';
import 'package:hitchspots/services/authentication.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';

void main() async {
  // runApp(ProviderWrapper());
  runApp(
    ProviderWrapper(),
  );
}

class ProviderWrapper extends StatelessWidget {
  const ProviderWrapper({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LocationCardModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthenticationState(),
        ),
      ],
      child: HitchSpotApp(),
    );
  }
}

class HitchSpotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: MaterialApp(
        title: 'HitchSpots',
        locale: DevicePreview.locale(context), // Add the locale here
        builder: DevicePreview.appBuilder,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage(),
      ),
    );
  }
}
