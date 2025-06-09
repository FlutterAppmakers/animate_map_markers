import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../animate_map_markers.dart';

/// Signature for a callback that is triggered when a marker is tapped.
///
/// The [markerId] corresponds to the tapped marker's unique identifier.
///
typedef MarkerTapCallback = void Function(MarkerId markerId, LatLng position);

class MarkerHelper {
  final Set<Marker> markers = {};

  /// A callback triggered when a marker is tapped.
  ///
  /// This is optional and will only be called if provided.
  final MarkerTapCallback? onMarkerTapped;

  /// A map of marker IDs to their associated animation controllers.
  ///
  /// Each [MarkerAnimationControllers] handles animation logic (e.g. scaling or
  /// bouncing) for an individual marker.
  ///
  /// Marker IDs must match those used in [createMarker] or elsewhere in the app.
  ///
  final Map<MarkerId, MarkerAnimationController> markerAnimationControllers;

  MarkerHelper({this.onMarkerTapped, required this.markerAnimationControllers});

  Marker createMarker({
    required MarkerIconInfo markerIconInfo,
    BitmapDescriptor icon = BitmapDescriptor.defaultMarker,

    /// the scaled marker icon
  }) {
    return Marker(
        markerId: markerIconInfo.markerId,
        position: markerIconInfo.position,
        icon: icon,
        infoWindow: markerIconInfo.infoWindow,
        alpha: markerIconInfo.alpha,
        anchor: markerIconInfo.anchor,
        consumeTapEvents: markerIconInfo.consumeTapEvents,
        draggable: markerIconInfo.draggable,
        flat: markerIconInfo.flat,
        rotation: markerIconInfo.rotation,
        visible: markerIconInfo.visible,
        zIndexInt: markerIconInfo.zIndexInt,
        clusterManagerId: markerIconInfo.clusterManagerId,
        onTap: () {
          if (onMarkerTapped != null) {
            onMarkerTapped!(markerIconInfo.markerId, markerIconInfo.position);
          }
          markerIconInfo.onTap?.call();
          selectMarker(markerIconInfo.markerId);
        },
        onDrag: markerIconInfo.onDrag,
        onDragStart: markerIconInfo.onDragStart,
        onDragEnd: markerIconInfo.onDragEnd);
  }

  /// Selects a specific marker and deselects all others.
  ///
  /// This method iterates through all registered marker animation controllers,
  /// triggering selection animation for the marker with the given [markerId],
  /// and deselection animations for all others.
  ///
  /// This is useful for highlighting a single marker on tap while resetting the
  /// visual state of the rest.
  ///
  /// Example:
  /// ```dart
  /// await markerHelper.selectMarker('marker_3');
  /// ```
  ///
  /// - [markerId]: The unique identifier of the marker to select.
  ///
  /// Each marker’s animation is handled by its associated
  /// [MarkerAnimationController], which must be pre-registered in
  /// [markerAnimationController].
  ///

  void selectMarker(MarkerId markerId) {
    for (final entry in markerAnimationControllers.entries) {
      final isSelected = entry.key == markerId;
      entry.value.animateMarker(entry.key, isSelected);
    }
  }
}
