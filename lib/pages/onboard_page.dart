import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnboardingPage extends StatefulWidget {
  OnboardingPage({Key? key}) : super(key: key);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  Widget build(BuildContext context) {
    List<PageViewModel> introPages = [
      PageViewModel(
        reverse: true,
        titleWidget: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            "Welcome to HitchSpots",
            style: TextStyle(
                fontSize: 64, fontWeight: FontWeight.w200, color: Colors.blue),
          ),
        ),
        bodyWidget: Column(
          children: [
            Text(
              "",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w300,
              ),
            ),
            Text(
              "",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w300,
              ),
            )
          ],
        ),
        image: const Center(
          child: Icon(Icons.android),
        ),
      ),
      PageViewModel(
        title: "Explore over 20,000 locations",
        body: "Thanks to hitchwiki, explore the original hitchhiking spots",
        image: const Center(child: Icon(Icons.android)),
        footer: ElevatedButton(
          onPressed: () {
            // On button presed
          },
          child: const Text("Let's Go !"),
        ),
      ),
      PageViewModel(
        title: "Share new locations with us",
        body: "Thanks to hitchwiki, explore the original hitchhiking spots",
        image: const Center(child: Icon(Icons.android)),
        footer: ElevatedButton(
          onPressed: () {
            // On button presed
          },
          child: const Text("Let's Go !"),
        ),
      ),
      PageViewModel(
        title: "Or contribute to existing spots",
        body: "Thanks to hitchwiki, explore the original hitchhiking spots",
        image: const Center(child: Icon(Icons.android)),
        footer: ElevatedButton(
          onPressed: () {
            // On button presed
          },
          child: const Text("Let's Go !"),
        ),
      )
    ];
    return IntroductionScreen(
      pages: introPages,
      done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w600)),
      onDone: () {
        // When done button is press
      },
      next: const Icon(Icons.navigate_next),
    );
  }
}
