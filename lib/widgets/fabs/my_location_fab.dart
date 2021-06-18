import 'package:flutter/material.dart';

class MyLocationFabAnimator extends StatefulWidget {
  MyLocationFabAnimator({
    Key? key,
    required this.getLocation,
    required this.animationController,
  }) : super(key: key);

  final AnimationController animationController;
  final Function getLocation;

  @override
  _MyLocationFabAnimatorState createState() => _MyLocationFabAnimatorState();
}

class _MyLocationFabAnimatorState extends State<MyLocationFabAnimator> {
  late Animation<double> bottom;

  Widget _buildAnimation(BuildContext context, Widget? child) {
    return Positioned(
      bottom: bottom.value,
      right: 16,
      child: MyLocationFAB(getLocation: widget.getLocation),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    bottom = Tween<double>(
      begin: 84.0,
      end: 0.35 * screenHeight + 16,
    ).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Interval(72 / screenHeight, 0.35, curve: Curves.linear),
      ),
    );
    return AnimatedBuilder(
        animation: widget.animationController, builder: _buildAnimation);
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
      elevation: 6,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Icon(
        Icons.gps_fixed,
        color: Theme.of(context).primaryColor,
      ),
      onPressed: () => getLocation(),
    );
  }
}
