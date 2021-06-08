import 'package:flutter/material.dart';

class MyLocationFabAnimator extends StatelessWidget {
  MyLocationFabAnimator({
    Key? key,
    required this.getLocation,
    required this.animationController,
  })  : bottom = Tween<double>(begin: 84.0, end: 265.0).animate(
          CurvedAnimation(
            parent: animationController,
            curve: Interval(0.1, 0.35, curve: Curves.linear),
          ),
        ),
        super(key: key);

  final AnimationController animationController;
  final Animation<double> bottom;
  final Function getLocation;

  Widget _buildAnimation(BuildContext context, Widget? child) {
    return Positioned(
      bottom: bottom.value,
      right: 16,
      child: MyLocationFAB(getLocation: getLocation),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animationController, builder: _buildAnimation);
  }
}

class MyLocationFAB extends StatelessWidget {
  const MyLocationFAB({
    Key? key,
    required this.getLocation,
  }) : super(key: key);

  final Function getLocation;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      elevation: 2,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Icon(
        Icons.gps_fixed,
        color: Theme.of(context).primaryColor,
      ),
      onPressed: () => getLocation(),
    );
  }
}
