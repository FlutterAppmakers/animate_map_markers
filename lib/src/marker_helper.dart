import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../animate_map_markers.dart';

/// Signature for a callback that is triggered when a marker is tapped.
///
/// The [markerId] corresponds to the tapped marker's unique identifier.
///
typedef MarkerTapCallback = Future<void> Function(String markerId);

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
  final Map<String, MarkerAnimationController> markerAnimationController;


  MarkerHelper(
      {this.onMarkerTapped, required this.markerAnimationController});

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
    required String markerId,
    BitmapDescriptor icon = BitmapDescriptor.defaultMarker,
    required LatLng position,
    double alpha = 1.0,
    Offset anchor = const Offset(0.5, 1.0),
    bool consumeTapEvents = false,
    bool draggable = false,
    bool flat = false,
    InfoWindow infoWindow = InfoWindow.noText,
    double rotation = 0.0,
    bool visible = true,
    double zIndex = 0.0,
    ClusterManagerId? clusterManagerId,
    void Function(LatLng)? onDrag,
    void Function(LatLng)? onDragStart,
    void Function(LatLng)? onDragEnd,

}
      ) {
    return Marker(
      markerId: MarkerId(markerId),
      position: position,
      icon: icon,
      infoWindow: infoWindow,
      alpha: alpha,
      anchor: anchor,
      consumeTapEvents: consumeTapEvents,
      draggable: draggable,
      flat: flat,
      rotation: rotation,
      visible: visible,
      zIndex: zIndex,
      clusterManagerId: clusterManagerId,
      onTap: () async {
        if(onMarkerTapped != null) {
         await  onMarkerTapped!(markerId);
        }
        await selectMarker(markerId);
      },
      onDrag: onDrag,
      onDragStart: onDragStart,
      onDragEnd: onDragEnd
    );
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
  Future<void> selectMarker(String markerId) async {
    for (var id in markerAnimationController.keys) {
      if (id == markerId) {
        await markerAnimationController[id]?.animateMarker(id, true);
      } else {
        await markerAnimationController[id]?.animateMarker(id, false);
      }
    }
  }


}