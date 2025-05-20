import 'package:animate_map_markers/animate_map_markers.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'marker_swipe_card_option.dart';

class MarkerSwipeCardConfig extends MarkerOverlayContent {
  /// The widgets to be shown in the carousel of default constructor
  final List<Widget>? items;

  /// A [MapController], used to control the map.
  final CarouselSliderController? carouselController;

  final bool? disableGesture;

  /// Configuration options for the swipe card behavior and appearance.
  final MarkerSwipeCardOption options;

  /// Distance from the bottom of the map to the swipe card.
  ///
  /// Defaults to `50`
  final double bottom;

  const MarkerSwipeCardConfig({
    required this.items,
    required this.options,
    this.carouselController,
    this.disableGesture,
    this.bottom = 50,
  });
}
