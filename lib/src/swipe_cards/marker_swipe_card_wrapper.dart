import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../animate_map_markers.dart';

class MarkerSwipeCardWrapper extends StatelessWidget {
  final ValueNotifier<MarkerId?> selectedMarkerIdNotifier;
  final Map<MarkerId, MarkerAnimationController> markerAnimationControllers;
  final MarkerSwipeCardConfig config;
  final List<MarkerIconInfo> scaledMarkerIconInfos;
  final Completer<GoogleMapController> mapControllerCompleter;
  final PageController pageCtrl;

  const MarkerSwipeCardWrapper({
    super.key,
    required this.selectedMarkerIdNotifier,
    required this.markerAnimationControllers,
    required this.config,
    required this.scaledMarkerIconInfos,
    required this.mapControllerCompleter,
    required this.pageCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return MarkerSwipeCard(
      selectedMarkerIdNotifier: selectedMarkerIdNotifier,
      markerAnimationControllers: markerAnimationControllers,
      config: config,
      scaledMarkerIconInfos: scaledMarkerIconInfos,
      mapControllerCompleter: mapControllerCompleter,
      pageCtrl: pageCtrl,
    );
  }
}
