import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
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
  const MarkerScaler({required this.assetPath});

  final String assetPath;

  /// Creates a [BitmapDescriptor] that can be used as a Google Maps marker icon.
  ///
  /// The rendered marker icon will be scaled to fit the specified [size] in
  /// logical pixels.

  Future<BitmapDescriptor> createBitmapDescriptor(Size size) async {
    if (!assetPath.isSvg) {
      return await assetImageToBitmapDescriptor(
        assetPath: assetPath,
        size: size,
      );
    } else {
      return await getBitmapDescriptorFromSvgAsset(
          assetName: assetPath, size: size);
    }
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

  static Future<BitmapDescriptor> assetImageToBitmapDescriptor({
    required String assetPath,
    required Size size,
  }) async {
    final icon = await BitmapDescriptor.asset(
      ImageConfiguration(size: Size(size.width, size.height)),
      assetPath,
    );
    return icon;
  }

  /// Loads an SVG asset and converts it into a [BitmapDescriptor]
  /// for use as a custom Google Maps marker icon.
  ///
  /// This method renders the SVG located at [assetName] to a raster image,
  /// scales it to match the specified [size] (in logical pixels), and returns
  /// a [BitmapDescriptor] that can be used for Google Maps markers.
  ///
  /// The method accounts for the device's pixel ratio to ensure the rendered
  /// image appears sharp on all screen densities. It uses Flutter's vector
  /// graphics rendering to draw the SVG and convert it to a PNG byte array.
  ///
  /// ### Parameters:
  /// - [assetName]: The path to the SVG asset. Must be included in `pubspec.yaml`.
  /// - [size]: The desired size (width and height in logical pixels) of the output icon.

  static Future<BitmapDescriptor> getBitmapDescriptorFromSvgAsset(
      {required final String assetName, required final Size size}) async {
    final pictureInfo = await vg.loadPicture(SvgAssetLoader(assetName), null);

    double devicePixelRatio =
        ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
    int width = (size.width * devicePixelRatio).toInt();
    int height = (size.height * devicePixelRatio).toInt();

    final scaleFactor = min(
      width / pictureInfo.size.width,
      height / pictureInfo.size.height,
    );

    final recorder = ui.PictureRecorder();

    ui.Canvas(recorder)
      ..scale(scaleFactor)
      ..drawPicture(pictureInfo.picture);

    final rasterPicture = recorder.endRecording();

    final image = rasterPicture.toImageSync(width, height);
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;

    return BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
  }
}

/// Extension on [String] to check if an asset path refers to an SVG file.
extension SvgAssetCheck on String {
  /// Returns `true` if the string ends with `.svg` (case-insensitive).
  bool get isSvg => toLowerCase().endsWith('.svg');
}
