import 'package:flutter/material.dart';
import 'package:hitchspots/utils/widget_switcher.dart';

class MyLocationFabAnimator extends StatefulWidget {
  MyLocationFabAnimator({
    Key? key,
    required this.getLocation,
    required this.animationController,
    required this.findingLocation,
  }) : super(key: key);

  final AnimationController animationController;
  final Function getLocation;
  final bool findingLocation;

  @override
  _MyLocationFabAnimatorState createState() => _MyLocationFabAnimatorState();
}

class _MyLocationFabAnimatorState extends State<MyLocationFabAnimator> {
  late Animation<double> bottom;

  Widget _buildAnimation(BuildContext context, Widget? child) {
    return Positioned(
      bottom: bottom.value,
      right: 16,
      child: MyLocationFAB(
          getLocation: widget.getLocation,
          findingLocation: widget.findingLocation),
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

class MyLocationFAB extends StatefulWidget {
  const MyLocationFAB({
    Key? key,
    required this.getLocation,
    required this.findingLocation,
  }) : super(key: key);

  final Function getLocation;
  final bool findingLocation;

  @override
  _MyLocationFABState createState() => _MyLocationFABState();
}

class _MyLocationFABState extends State<MyLocationFAB>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      lowerBound: 0.5,
    );
    animation = CurvedAnimation(parent: controller, curve: Curves.easeInOut)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });
  }

  @override
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.findingLocation) {
      controller.forward();
    }
    return FloatingActionButton(
      elevation: 6,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: WidgetSwitcherWrapper(
        duration: 700,
        condition: widget.findingLocation,
        widgetIfTrue: ScaleTransition(
          key: ValueKey('gps_not_fixed'),
          scale: animation,
          child: Icon(
            Icons.gps_not_fixed,
            color: Theme.of(context).primaryColor,
          ),
        ),
        widgetIfFalse: Icon(
          Icons.gps_fixed,
          key: ValueKey('gps_fixed'),
          color: Theme.of(context).primaryColor,
        ),
      ),
      onPressed: () => widget.getLocation(),
    );
  }
}
