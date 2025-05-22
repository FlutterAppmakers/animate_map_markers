import 'package:animate_map_markers/animate_map_markers.dart';
import 'package:flutter/material.dart';


class MarkerSwipeCardConfig extends MarkerOverlayContent {
  final Decoration backgroundDecoration;
  final int length;
  final int initialIndex;
  final PageViewItem Function(BuildContext context, int index) itemBuilder;
  final void Function(int index) onPageChanged;
  final double height;

  const MarkerSwipeCardConfig({
    required this.onPageChanged,
    required this.height,
    this.initialIndex = 1,
    required this.itemBuilder,
    required this.length,
    this.backgroundDecoration = const BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.white, Colors.transparent],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        stops: [.35, .8],
      ),
    ),
  }
);
}


