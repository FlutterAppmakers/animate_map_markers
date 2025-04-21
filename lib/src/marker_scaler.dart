import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A utility class to scale local asset images for use as marker icons on
/// Google Maps.
///
/// This is primarily useful when you want to display custom-sized markers
/// using assets in your Flutter project.

class MarkerScaler {

  /// Loads and scales an asset image to be used as a [BitmapDescriptor] for
  /// Google Maps markers.
  ///
  /// The [assetPath] must point to a valid image asset listed in the project's
  /// `pubspec.yaml` file.
  ///
  /// The image will be scaled to match the specified [width] and [height]
  /// (in logical pixels).
  ///
  /// Example:
  /// ```dart
  /// final icon = await MarkerScaler.scaleMarkerIcon(
  ///   'assets/marker.png',
  ///   60,
  ///   60,
  /// );
  ///
  /// markers.add(
  ///   Marker(
  ///     icon: icon,
  ///     position: LatLng(...),
  ///     ...
  ///   ),
  /// );
  /// ```
  ///
  /// Returns a [BitmapDescriptor] that can be used when creating a [Marker].
  ///
  /// Throws an [AssertionError] if the asset is missing or invalid.


  Future<BitmapDescriptor> scaleMarkerIcon(
      String assetPath, double width, double height) async {
    final icon = await BitmapDescriptor.asset(
      ImageConfiguration(size: ui.Size(width, height)),
      assetPath,
    );
    return icon;
  }
}

