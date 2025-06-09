import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../animate_map_markers.dart';

class ScaleMarkerTransformer
    extends StreamTransformerBase<BitmapDescriptor, Marker> {
  final MarkerIconInfo markerInfo;
  final MarkerHelper markerHelper;

  ScaleMarkerTransformer(
      {required this.markerInfo, required this.markerHelper});

  @override
  Stream<Marker> bind(Stream<BitmapDescriptor> stream) {
    // TODO: implement bind
    return stream
        .map((icon) => _setScaledMarker(icon, markerInfo, markerHelper));
  }

  Marker _setScaledMarker(BitmapDescriptor currentIcon,
      MarkerIconInfo markerInfo, MarkerHelper markerHelper) {
    final marker = markerHelper.createMarker(
      markerIconInfo: markerInfo,
      icon: currentIcon,
    );

    return marker;
  }
}
