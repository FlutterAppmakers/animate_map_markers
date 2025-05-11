import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../animate_map_markers.dart';

/// Signature for a callback that is triggered when a marker is tapped.
///
/// The [markerId] corresponds to the tapped marker's unique identifier.
///
typedef MarkerTapCallback = Future<void> Function(MarkerId markerId);

class MarkerHelper {
  final Set<Marker> markers = {};

  /// A callback triggered when a marker is tapped.
  ///
  /// This is optional and will only be called if provided.
  final MarkerTapCallback? onMarkerTapped;

  /// A map of marker IDs to their associated animation controllers.
  ///
  /// Each [MarkerAnimationController] handles animation logic (e.g. scaling or
  /// bouncing) for an individual marker.
  ///
  /// Marker IDs must match those used in [createMarker] or elsewhere in the app.
  ///
  final Map<MarkerId, MarkerAnimationController> markerAnimationController;

  MarkerHelper({this.onMarkerTapped, required this.markerAnimationController});

  /// Creates a [Marker] with full configuration and optional tap + drag callbacks.
  ///
  /// This method wraps the [Marker] constructor and adds internal tap handling
  /// (including [onMarkerTapped] and selection state).
  ///
  /// See [Marker] for more details on each parameter.
  ///
  /// Example:
  /// ```dart
  /// final marker = markerHelper.createMarker(
  ///   markerId: 'marker_1',
  ///   position: LatLng(37.4219999, -122.0840575),
  ///   icon: customIcon,
  ///   draggable: true,
  ///   onDragEnd: (newPosition) {
  ///     print('Marker moved to $newPosition');
  ///   },
  /// );
  /// ```
  ///
  /// - [markerId]: A unique identifier for the marker. This will also be used
  ///   as the title in the [InfoWindow].
  ///
  /// - [icon]: A [BitmapDescriptor] representing the visual icon of the marker.
  ///   This can be a default Google Maps icon or a custom scaled asset.
  ///
  /// - [position]: The [LatLng] coordinates where the marker will be placed on
  ///   the map.
  ///
  /// Returns a fully configured [Marker] with built-in tap handling.
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
        zIndex: markerIconInfo.zIndex,
        clusterManagerId: markerIconInfo.clusterManagerId,
        onTap: () async {
          if (onMarkerTapped != null) {
            await onMarkerTapped!(markerIconInfo.markerId);
          }
          await selectMarker(markerIconInfo.markerId);
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
  Future<void> selectMarker(MarkerId markerId) async {
    for (final entry in markerAnimationController.entries) {
      final isSelected = entry.key == markerId;
      await entry.value.animateMarker(entry.key, isSelected);
    }
  }
}
