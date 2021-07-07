import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hitchspots/utils/first_run_wrapper.dart';
import 'package:hitchspots/utils/provider_wrapper.dart';
import 'pages/home_page.dart';

void main() async {
  // runApp(ProviderWrapper());
  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) => ProviderWrapper(
        app: HitchSpotApp(),
      ),
    ),
  );
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
          accentColor: Color.fromRGBO(6, 214, 160, 1),
        ),
        home: FirstRunWrapper(homePage: HomePage()),
      ),
    );
  }
}
