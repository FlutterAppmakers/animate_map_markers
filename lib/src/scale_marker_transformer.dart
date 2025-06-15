import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../animate_map_markers.dart';

class ScaleMarkerTransformer
    extends StreamTransformerBase<BitmapDescriptor, Map<MarkerId, Marker>> {
  final MarkerIconInfo markerInfo;
  final Map<MarkerId, MarkerAnimationController> markerAnimationControllers;
  final void Function(MarkerId)? handleMarkerTap;
  ScaleMarkerTransformer(
      {required this.markerAnimationControllers,
        required this.markerInfo,
        required this.handleMarkerTap});
  @override
  Stream<Map<MarkerId, Marker>> bind(Stream<BitmapDescriptor> stream) {
    // TODO: implement bind
    return stream.map((icon) => _setScaledMarker(icon, markerInfo));
  }

  Map<MarkerId, Marker> _setScaledMarker(
      BitmapDescriptor currentIcon, MarkerIconInfo markerInfo) {
    final markerHelper = MarkerHelper(
      onMarkerTapped: (MarkerId markerId) =>
          handleMarkerTap!(markerId), //////// check null
      markerAnimationController: markerAnimationControllers,
    );

    final marker = markerHelper.createMarker(
      markerIconInfo: markerInfo,
      icon: currentIcon,
    );

    return {markerInfo.markerId: marker};
  }
}

