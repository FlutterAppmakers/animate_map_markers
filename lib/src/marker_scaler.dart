import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A utility class to scale local asset images for use as marker icons on
/// Google Maps.
///
/// This is primarily useful when you want to display custom-sized markers
/// using assets in your Flutter project.

class MarkerScaler {
  const MarkerScaler({required this.assetPath});

  final String assetPath;

  /// Creates a [BitmapDescriptor] that can be used as a Google Maps marker icon.
  ///
  /// The rendered marker icon will be scaled to fit the specified [size] in
  /// logical pixels.

  Future<BitmapDescriptor> createBitmapDescriptor(Size size) async {
        return await assetImageToBitmapDescriptor(
          assetPath: assetPath,
          size: size,
        );
  }

  /// Loads a raster image asset and converts it into a [BitmapDescriptor]
  /// for use as a custom Google Maps marker icon.
  ///
  /// This method uses the given [assetPath] to load a raster image (e.g., PNG, JPG),
  /// scales it to the specified [size], and returns a [BitmapDescriptor]
  /// suitable for use with `Marker.icon`.
  ///
  /// ### Parameters:
  /// - [assetPath]: The path to the raster image asset. It must be declared in `pubspec.yaml`.
  /// - [size]: The desired size (width and height in logical pixels) of the output marker icon.
  Future<BitmapDescriptor> assetImageToBitmapDescriptor({
    required String assetPath,
    required Size size,
  }) async {
    final icon = await BitmapDescriptor.asset(
      ImageConfiguration(size: Size(size.width, size.height)),
      assetPath,
    );
    return icon;
  }
}
