import 'package:flutter/material.dart';

class OpacityTween extends StatelessWidget {
  final double begin;
  final double end;
  final Duration duration;
  final Widget child;
  final Curve curve;

  const OpacityTween({
    super.key,
    required this.begin,
    required this.end,
    required this.child,
    this.curve = Curves.easeInOut,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      curve: curve,
      tween: Tween<double>(begin: begin, end: end),
      duration: duration,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: IgnorePointer(
            ignoring: opacity == 0.0,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
