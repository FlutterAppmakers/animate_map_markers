import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Class used to provide information about the marker on the [GoogleMap] widget.
/// Pass either an asset image [assetPath] or a material [icon] to change the appearance of the icon.
/// [assetMarkerSize] can be provided to resize image at [assetPath].
///
/// See also:
///   * [bitmapDescriptor] parameter.
class MarkerIconInfo {
  const MarkerIconInfo({
    required this.markerId,
    required this.minMarkerSize,
    required this.position,
    required this.scale,
    this.icon,
    this.assetPath,
    this.duration = const Duration(milliseconds: 500),
    this.reverseDuration =  const Duration(milliseconds: 500),
    this.curve = Curves.bounceOut,
    this.reverseCurve = Curves.linear,
    // other marker params
    this.alpha = 1.0,
    this.anchor = const Offset(0.5, 1.0),
    this.consumeTapEvents = false,
    this.draggable = false,
    this.flat = false,
    this.infoWindow = InfoWindow.noText,
    this.rotation =  0.0,
    this.visible = true,
    this.zIndex = 0.0,
    this.clusterManagerId,
    this.onDrag,
    this.onDragStart,
    this.onDragEnd,
  });


  /// A unique identifier for the marker.
 final  MarkerId markerId;

 /// Geographical location of the marker.
  final  LatLng position;

  /// Material icon that can be passed which can be used
  /// in place of a default [Marker].
  final Icon? icon;

  /// Asset image path that can be passed which can be used
  /// in place of a default [Marker].
  final String? assetPath;


  /// The base size of the marker before scaling.
  final Size minMarkerSize;

  /// The duration of the animation.
  ///
  /// Defaults to 500 milliseconds.
  final Duration duration;

  /// The reverse duration of the animation.
  ///
  /// Defaults to 500 milliseconds.
  final Duration reverseDuration;

  /// The curve of the animation.
  ///
  /// Defaults to [Curves.bounceOut].
  final Curve curve;


  /// The reverse curve of the animation.
  ///
  /// Defaults to [Curves.linear].
  final Curve reverseCurve;


  /// The scale factor to be applied to [minMarkerSize] for the maximum size.
  /// For example, a scale of 1.3 increases the size by 30%.
  final double scale;

  /////////////////////////////////////////////////
  // OTHER MARKER PARAMS
  /////////////////////////////////////////////////

  /// The opacity of the marker, between 0.0 and 1.0 inclusive.
  ///
  /// 0.0 means fully transparent, 1.0 means fully opaque.
  final double alpha;

  /// The icon image point that will be placed at the [position] of the marker.
  ///
  /// The image point is specified in normalized coordinates: An anchor of
  /// (0.0, 0.0) means the top left corner of the image. An anchor
  /// of (1.0, 1.0) means the bottom right corner of the image.
  final  Offset anchor;

  /// True if the marker icon consumes tap events. If not, the map will perform
  /// default tap handling by centering the map on the marker and displaying its
  /// info window.
  final bool consumeTapEvents;

  /// True if the marker is draggable by user touch events.
  final bool draggable;

  /// True if the marker is rendered flatly against the surface of the Earth, so
  /// that it will rotate and tilt along with map camera movements.
  final bool flat;

  /// A Google Maps InfoWindow.
  ///
  /// The window is displayed when the marker is tapped.
  final InfoWindow infoWindow;

  /// Rotation of the marker image in degrees clockwise from the [anchor] point.
  final double rotation;

  /// True if the marker is visible.
  final bool visible;

  /// The z-index of the marker, used to determine relative drawing order of
  /// map overlays.
  ///
  /// Overlays are drawn in order of z-index, so that lower values means drawn
  /// earlier, and thus appearing to be closer to the surface of the Earth.
  final double zIndex;

  /// Marker clustering is managed by [ClusterManager] with [clusterManagerId].
  final ClusterManagerId? clusterManagerId;

  /// Signature reporting the new [LatLng] during the drag event.
  final Function(LatLng)? onDrag;

  /// Signature reporting the new [LatLng] at the start of a drag event.
  final Function(LatLng)? onDragStart;

  /// Signature reporting the new [LatLng] at the end of a drag event.
  final Function(LatLng)? onDragEnd;
}
