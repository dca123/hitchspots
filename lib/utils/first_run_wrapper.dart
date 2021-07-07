import 'package:flutter/material.dart';
import 'package:hitchspots/pages/onboard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstRunWrapper extends StatelessWidget {
  FirstRunWrapper({Key? key, required this.homePage}) : super(key: key);
  Future<bool> _checkIfFirstRun() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstRun = (prefs.getBool('isFirstRun')) ?? true;
    return isFirstRun;
  }

  final Widget homePage;
  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder<bool>(
      future: _checkIfFirstRun(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (snapshot.data == true) {
              return OnboardingPage();
            } else {
              return homePage;
            }
          default:
            return Container(child: Text("Loading Cache Data"));
        }
      },
    ));
  }
}
