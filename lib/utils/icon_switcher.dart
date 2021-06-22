import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class IconSwitcherWrapper extends StatelessWidget {
  // Remember to add value keys to the icons
  IconSwitcherWrapper({
    Key? key,
    required this.iconIfTrue,
    required this.iconIfFalse,
    required this.condition,
    this.duration,
  }) : super(key: key);

  final Widget iconIfTrue;
  final Widget iconIfFalse;
  final bool condition;
  final int? duration;

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
        // duration: Duration(seconds: 2),
        duration: Duration(milliseconds: duration ?? 300),
        transitionBuilder: (child, animation, secondaryAnimation) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
            fillColor: Colors.transparent,
          );
        },
        child: condition ? iconIfTrue : iconIfFalse);
  }
}
