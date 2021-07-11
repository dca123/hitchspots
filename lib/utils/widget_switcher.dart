import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class WidgetSwitcherWrapper extends StatelessWidget {
  // Remember to add value keys to the icons
  WidgetSwitcherWrapper({
    Key? key,
    required this.widgetIfTrue,
    required this.widgetIfFalse,
    required this.condition,
    this.duration = 300,
    this.fillColor = Colors.transparent,
  }) : super(key: key);

  final Widget widgetIfTrue;
  final Widget widgetIfFalse;
  final bool condition;

  /// Duration in milliseconds
  final int duration;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
        duration: Duration(milliseconds: duration),
        transitionBuilder: (child, animation, secondaryAnimation) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
            fillColor: fillColor,
          );
        },
        child: condition ? widgetIfTrue : widgetIfFalse);
  }
}
