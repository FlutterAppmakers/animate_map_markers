import 'package:flutter/material.dart';

import '../../animate_map_markers.dart';

class MarkerDraggableSheetConfig {
  /// The initial fractional value of the parent container's height to use when displaying the widget
  ///
  /// Defaults to 0.5.
  final double initialChildSize;

  /// The maximum fractional value of the parent container's height to use when displaying the widget.
  ///
  /// Defaults to 1.0.
  final double maxChildSize;

  /// The minimum fractional value of the parent container's height to use when displaying the widget.
  ///
  /// Defaults to 0.
  final double minChildSize;

  /// The fractional value of the parent container's height to use when  reversing the animation
  final double reverseAnimationSize;

  /// The radius of the top corners of the marker sheet.
  ///
  /// This controls how rounded the top left and top right corners appear.
  /// Defaults to 22.0 if not specified.
  final double topCornerRadius;

  /// The list of box shadows applied to the marker sheet container.
  ///
  /// Can be used to customize the elevation or depth effect of the sheet.
  /// If null, no shadow will be applied.
  final List<BoxShadow>? boxShadow;

  /// The color of the top button indicator.
  ///
  /// Defaults to [Colors.black45]
  final Color topButtonIndicatorColor;

  /// The curve of the animation.
  ///
  /// Defaults to [Curves.easeInOut].
  ///
  final Curve curve;

  /// The duration of the animation.
  ///
  /// Defaults to 50 milliseconds.
  final Duration duration;

  /// Determines whether the top button indicator is visible.
  ///
  /// If set to `true`, the top button indicator is always shown. If set to `false`,
  /// the indicator is shown only when the `currentSheetSize` is less than 0.6.
  ///
  /// Defaults to `true`.
  final bool showTopIndicator;

  /// The height of the top button indicator.
  ///
  /// Defaults to 5.
  final double topButtonIndicatorHeight;

  /// The width of the top button indicator.
  ///
  /// Defaults to 100.
  final double topButtonIndicatorWidth;

  /// This threshold helps determine when the top button indicator should become visible.
  /// Defaults to `0.6`.
  ///
  final double dynamicThreshold;

  const MarkerDraggableSheetConfig({
    this.initialChildSize = 0.48,
    this.maxChildSize = 1.0,
    this.minChildSize = 0.0,
    this.reverseAnimationSize = 0.1,
    this.topCornerRadius = 22.0,
    this.boxShadow,
    this.topButtonIndicatorColor = Colors.black45,
    this.curve = Curves.easeInOut,
    this.duration = const Duration(milliseconds: 50),
    this.showTopIndicator = true,
    this.dynamicThreshold = 0.6,
    this.topButtonIndicatorHeight = 5.0,
    this.topButtonIndicatorWidth = 50.0
  });
}
