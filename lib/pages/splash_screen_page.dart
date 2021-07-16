import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          width: MediaQuery.of(context).size.width * 0.785,
          color: Colors.white,
          child: RiveAnimation.asset(
            "assets/splash/globe.riv",
          )),
    );
  }
}
