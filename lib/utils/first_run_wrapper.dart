import 'package:flutter/material.dart';
import 'package:hitchspots/pages/onboard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstRunWrapper extends StatefulWidget {
  FirstRunWrapper({Key? key, required this.homePage}) : super(key: key);

  final Widget homePage;
  @override
  _FirstRunWrapperState createState() => _FirstRunWrapperState();
}

class _FirstRunWrapperState extends State<FirstRunWrapper> {
  bool _hasLoadedRunState = false;
  late bool _isFirstRun;

  Future<void> _checkIfFirstRun() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstRun = (prefs.getBool('isFirstRun')) ?? true;
    if (isFirstRun) {
      await prefs.setBool('isFirstRun', false);
    }
    setState(() {
      _hasLoadedRunState = true;
      _isFirstRun = isFirstRun;
    });
  }

  _FirstRunWrapperState() {
    _checkIfFirstRun();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _hasLoadedRunState
          ? (_isFirstRun ? OnboardingPage() : widget.homePage)
          // TODO: SplashScreen here
          : Container(),
    );
  }
}
