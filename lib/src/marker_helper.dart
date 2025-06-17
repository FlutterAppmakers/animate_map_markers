import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../animate_map_markers.dart';

/// Signature for a callback that is triggered when a marker is tapped.
///
/// The [markerId] corresponds to the tapped marker's unique identifier.
///
typedef MarkerTapCallback = void Function(MarkerId markerId, LatLng  position);

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
  ///
  MarkerId? _selectedMarkerId; // To store the ID of the currently selected marker
  MarkerId? _previousSelectedMarkerId; // To store the ID of the previously selected marker
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
        onTap: () {
          markerIconInfo.onTap?.call();
          if (onMarkerTapped != null) {
            onMarkerTapped!(markerIconInfo.markerId, markerIconInfo.position);
          }
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
    // Store the current selected marker as the previous one
    _previousSelectedMarkerId = _selectedMarkerId;
    // Set the newly tapped marker as the current selected one
    _selectedMarkerId = markerId;
    // You can now access _previousSelectedMarkerId and _selectedMarkerId
    print('Previously selected marker: $_previousSelectedMarkerId');
    print('Currently selected marker: $_selectedMarkerId');

    if (_selectedMarkerId != null) {
      final controller = markerAnimationControllers[_selectedMarkerId!];
      if (controller != null) {
        controller.animateMarker(
            _selectedMarkerId!, true); /// Pass `true` for selected
      }
    }

    if (_previousSelectedMarkerId != null &&
        _previousSelectedMarkerId != _selectedMarkerId) {
      final controller = markerAnimationControllers[_previousSelectedMarkerId!];
      if (controller != null) {
        controller.animateMarker(
            _previousSelectedMarkerId!, false); // Pass `false` for deselected
      }
    }
  }
}
