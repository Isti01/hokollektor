import 'dart:math' as math;

import 'package:flutter/material.dart';

const Curve sunCurve = Curves.linear;
const maxSize1 = 0.9;
const maxSize2 = 0.8;

class CollectorProgressIndicator extends StatefulWidget {
  final Color color0;
  final Color color1;
  final Color color2;

  final VoidCallback onFinished;
  final double size;
  final double elevation;
  final Duration duration;

  const CollectorProgressIndicator({
    Key key,
    this.color0,
    this.color1,
    this.color2,
    this.onFinished,
    this.size = 50.0,
    this.elevation = 2.0,
    this.duration = const Duration(seconds: 3),
  }) : super(key: key);

  @override
  _CollectorProgressIndicatorState createState() =>
      _CollectorProgressIndicatorState();
}

class _CollectorProgressIndicatorState extends State<CollectorProgressIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  Animation<double> _sizeAnimation;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: widget.duration);
    super.initState();
    _controller.forward();
    _controller.addListener(() => this.setState(() {}));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.repeat();

        if (widget.onFinished != null) {
          widget.onFinished();
        }
      }
    });

    _sizeAnimation = CurvedAnimation(parent: _controller, curve: sunCurve);
  }

  double _getMotionAnimation1() {
    if (_controller.value < 0.25)
      return Tween<double>(begin: 0.0, end: maxSize1).evaluate(
          CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.25)));
    else
      return Tween<double>(begin: maxSize1, end: 0.0).evaluate(
          CurvedAnimation(parent: _controller, curve: Interval(0.25, 0.66)));
  }

  double _getMotionAnimation2() {
    if (_controller.value < 0.25)
      return Tween<double>(begin: 0.0, end: maxSize2).evaluate(
          CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.25)));
    else if (_controller.value < 0.5)
      return Tween<double>(begin: maxSize2, end: 0.0).evaluate(
          CurvedAnimation(parent: _controller, curve: Interval(0.25, 0.5)));
    else if (_controller.value < 0.75)
      return Tween<double>(begin: 0.0, end: maxSize2).evaluate(
          CurvedAnimation(parent: _controller, curve: Interval(0.5, 0.75)));
    else
      return Tween<double>(begin: maxSize2, end: 0.0).evaluate(
          CurvedAnimation(parent: _controller, curve: Interval(0.75, 1)));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size1 = widget.size / 3 * (2 + _getMotionAnimation1() ?? 0.0);

    final size2 = widget.size / 3 * (2 + _getMotionAnimation2() ?? 0.0);

    return Transform.rotate(
      angle: math.pi * _sizeAnimation?.value ?? 0.0,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Material(
            elevation: widget.elevation,
            color: widget.color2 ?? Colors.yellow[700],
            child: Container(
              height: size1,
              width: size1,
            ),
          ),
          Transform.rotate(
            angle: math.pi / 4,
            child: Material(
              // elevation: widget.elevation,
              color: widget.color1 ?? Colors.yellow[600],
              child: Container(
                height: size2,
                width: size2,
              ),
            ),
          ),
          Material(
            shape: CircleBorder(),
            color: widget.color0 ?? Colors.yellow[400],
            elevation: widget.elevation,
            child: Container(
              height: widget.size,
              width: widget.size,
            ),
          ),
        ],
      ),
    );
  }
}
