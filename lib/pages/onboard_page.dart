import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hitchspots/pages/home_page.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  OnboardingPage({Key? key, required this.pageOnFinish}) : super(key: key);

  final Widget pageOnFinish;
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  TextStyle headline1() => TextStyle(
        fontSize: 64,
        fontWeight: FontWeight.w200,
        color: Theme.of(context).accentColor,
      );
  TextStyle headline2() => TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w300,
        color: Colors.blueGrey,
      );
  TextStyle headline3() => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w300,
        color: Colors.blueGrey,
      );

  PageViewModel _pageViewModelCreator({
    required String title,
    required String image,
    String? body,
  }) =>
      PageViewModel(
        decoration: PageDecoration(
          bodyFlex: 2,
          imageFlex: 4,
          bodyAlignment: Alignment.center,
          imageAlignment: Alignment.topCenter,
        ),
        body: "",
        titleWidget: Container(
          child: Column(
            children: [
              Text(
                title,
                style: headline2(),
                textAlign: TextAlign.center,
              ),
              Text(
                body ?? "",
                style: headline3(),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
        image: Material(
          elevation: 16,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Container(
            child: Image.asset("assets/onboarding/$image.png"),
          ),
        ),
      );

  List<PageViewModel> introPages(context) => [
        PageViewModel(
          reverse: true,
          decoration: PageDecoration(
            bodyAlignment: Alignment.bottomCenter,
            bodyFlex: 3,
            imageFlex: 4,
          ),
          titleWidget: Center(
            child: Container(
              child: AutoSizeText(
                "Welcome to HitchSpots",
                maxLines: 2,
                textAlign: TextAlign.center,
                style: headline1(),
              ),
            ),
          ),
          body: "",
          image: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Image.asset(
                "assets/onboarding/person_1.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        _pageViewModelCreator(
            title: "Explore over 20,000 locations",
            body: "Tapping on markers reveals more info",
            image: "screencap_1"),
        _pageViewModelCreator(
            title: "Contribute to existing locations", image: "screencap_2"),
        _pageViewModelCreator(
            title: "Share new locations with other hitchhikers",
            image: "screencap_3"),
      ];

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: introPages(context),
      initialPage: 0,
      done: Text(
        "Get Started",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).accentColor,
        ),
      ),
      onDone: () async {
        // When done button is press
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isFirstRun', false);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) {
            return widget.pageOnFinish;
          }),
        );
      },
      next: const Icon(
        Icons.navigate_next,
        color: Color.fromRGBO(6, 214, 160, 1),
      ),
      dotsDecorator: DotsDecorator(
        activeColor: Theme.of(context).accentColor,
      ),
    );
  }
}
