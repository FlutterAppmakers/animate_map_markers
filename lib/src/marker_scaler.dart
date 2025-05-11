import 'dart:async';
import 'package:animate_map_markers/src/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A utility class to scale local asset images for use as marker icons on
/// Google Maps.
///
/// This is primarily useful when you want to display custom-sized markers
/// using assets in your Flutter project.

class MarkerScaler {
  const MarkerScaler({this.assetPath, this.icon});

  final String? assetPath;
  final Icon? icon;

  /// Creates a [BitmapDescriptor] that can be used as a Google Maps marker icon.
  ///
  /// This method supports multiple types of visual sources:
  /// - Asset images (PNG, JPG, etc.)
  /// - SVG assets
  /// - Material [Icon] widgets
  ///
  /// The rendered marker icon will be scaled to fit the specified [size] in
  /// logical pixels.
  ///
  /// ### Supported Inputs
  ///- If [assetPath] is provided:
  ///   - If it's an SVG file, it will be rendered as a vector and scaled to [size].
  ///   - If it's a raster image, it will be loaded and resized to [size].
  /// - If [icon] is provided instead of [assetPath], it will be rendered as an image with the given [size].
  /// - If neither is provided, returns [BitmapDescriptor.defaultMarker].

  Future<BitmapDescriptor> createBitmapDescriptor(Size size) async {
    if (assetPath != null) {
      if (assetPath!.isSvg) {
        return svgToBitmapDescriptor(assetName: assetPath!, size: size);
      } else {
        return await assetImageToBitmapDescriptor(
          assetPath: assetPath!,
          size: size,
        );
      }
    }
    if (icon != null) {
      return await materialIconToBitmapDescriptor(icon: icon!, size: size);
    }

    return BitmapDescriptor.defaultMarker;
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

  /// Renders an SVG asset as a [BitmapDescriptor] for use with Google Maps markers.
  ///
  /// This method loads an SVG from the specified [assetName], renders it at the given [size],
  /// and converts it into a bitmap that can be used as a custom marker icon.
  ///
  /// The rendering respects the layout constraints defined by [size] in logical pixels.
  ///
  /// ### Parameters
  /// - [assetName]: The path to the SVG asset (must be listed in `pubspec.yaml`).
  /// - [size]: The target size (width and height) of the rendered marker icon.
  Future<BitmapDescriptor> svgToBitmapDescriptor({
    required String assetName,
    required Size size,
  }) async {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: SvgPicture.asset(
        assetName,
      ),
    ).toBitmapDescriptor();
  }

  /// Converts a [Icon] widget into a [BitmapDescriptor] for use with Google Maps markers.
  ///
  /// This method takes a [Material Icon] and renders it as an image of the specified [size],
  /// preserving the original icon's visual properties (e.g., color, shadows, weight).
  ///
  /// The resulting image is then converted into a [BitmapDescriptor] that can be used
  /// as a custom marker on a Google Map.
  ///
  /// ### Parameters:
  /// - [icon]: The [Icon] widget to render.
  /// - [size]: The size (in logical pixels) for the output marker icon. Only the width is used
  ///   for scaling, as icons are square by default.

  Future<BitmapDescriptor> materialIconToBitmapDescriptor({
    required Icon icon,
    required Size size,
  }) async {
    return Icon(
      icon.icon,
      size: size.width,
      fill: icon.fill,
      weight: icon.weight,
      grade: icon.grade,
      opticalSize: icon.opticalSize,
      color: icon.color,
      semanticLabel: icon.semanticLabel,
      textDirection: icon.textDirection,
      applyTextScaling: icon.applyTextScaling,
      blendMode: icon.blendMode,
      shadows: icon.shadows,
    ).toBitmapDescriptor();
  }
}
