import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

extension ToBitDescription on Widget {
  Future<BitmapDescriptor> toBitmapDescriptor(
      {Size? logicalSize,
        Size? imageSize,
        Duration waitToRender = const Duration(milliseconds: 10),
        TextDirection textDirection = TextDirection.ltr}) async {

    /// tells Flutter: "only render this subtree" — it helps isolate this widget so it can be rendered into an image.
    final widget = RepaintBoundary(
      child: MediaQuery(
          data: const MediaQueryData(),
          child: Directionality(textDirection: TextDirection.ltr, child: this)),
    );


    ///Gets the current screen/view. Required to build a render tree that matches your device resolution.
    final view = ui.PlatformDispatcher.instance.views.first;

    ///builds and renders a widget to an image
    final pngBytes = await createImageFromWidget(widget,
        waitToRender: waitToRender,
        view: view,
        logicalSize: logicalSize,
        imageSize: imageSize);

    return BitmapDescriptor.bytes(pngBytes,
        imagePixelRatio: view.devicePixelRatio);
  }
}

/// Creates an image from the given widget by first spinning up a element and render tree,
/// wait [waitToRender] to render the widget that take time like network and asset images

/// The final image will be of size [imageSize] and the the widget will be layout, ... with the given [logicalSize].
/// By default Value of  [imageSize] and [logicalSize] will be calculate from the app main window

Future<Uint8List> createImageFromWidget(Widget widget,
    {Size? logicalSize,
     required Duration waitToRender,
      required ui.FlutterView view,
      Size? imageSize}) async {
  final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();
  logicalSize ??= view.physicalSize / view.devicePixelRatio;
  imageSize ??= view.physicalSize;

  // assert(logicalSize.aspectRatio == imageSize.aspectRatio);

  final RenderView renderView = RenderView(
    view: view,
    child: RenderPositionedBox(
        alignment: Alignment.center, child: repaintBoundary),
    configuration: ViewConfiguration(
      physicalConstraints:
      BoxConstraints.tight(logicalSize) * view.devicePixelRatio,
      logicalConstraints: BoxConstraints.tight(logicalSize),
      devicePixelRatio: view.devicePixelRatio,
    ),
  );

  final PipelineOwner pipelineOwner = PipelineOwner();
  final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());

  pipelineOwner.rootNode = renderView;
  renderView.prepareInitialFrame();

  final RenderObjectToWidgetElement<RenderBox> rootElement =
  RenderObjectToWidgetAdapter<RenderBox>(
    container: repaintBoundary,
    child: widget,
  ).attachToRenderTree(buildOwner);

  buildOwner.buildScope(rootElement);

  /// Adds a brief delay to allow layout and async content (e.g. images) to begin loading.
    await Future.delayed(waitToRender);

  /// Waits until the end of the current frame to ensure rendering has completed.
    await WidgetsBinding.instance.endOfFrame;


  buildOwner.buildScope(rootElement);
  buildOwner.finalizeTree();

  pipelineOwner.flushLayout();
  pipelineOwner.flushCompositingBits();
  pipelineOwner.flushPaint();

  final ui.Image image = await repaintBoundary.toImage(
      pixelRatio: imageSize.width / logicalSize.width);
  final ByteData? byteData =
  await image.toByteData(format: ui.ImageByteFormat.png);

  return byteData!.buffer.asUint8List();
}


/// Extension on [String] to check if an asset path refers to an SVG file.
extension SvgAssetCheck on String {
  /// Returns `true` if the string ends with `.svg` (case-insensitive).
  bool get isSvg => toLowerCase().endsWith('.svg');
}
