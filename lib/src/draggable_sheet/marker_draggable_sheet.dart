import 'package:animate_map_markers/src/opacity_tween.dart';
import 'package:flutter/material.dart';
import 'marker_draggable_sheet_config.dart';
import 'marker_sheet_controller.dart';

class MarkerDraggableSheet extends StatefulWidget {
  final void Function() animateMarkers;

  /// The configuration object for customizing the behavior and appearance of the draggable sheet.
  ///
  /// Provides properties such as `initialChildSize`, `maxChildSize`, `curve`, `duration`,
  /// and more to control how the sheet behaves and looks.
  ///
  /// Defaults are defined within [MarkerDraggableSheetConfig].
  final MarkerDraggableSheetConfig config;

  /// An optional controller that allows external control of the sheet.
  ///
  /// When provided, this controller can be used to trigger actions such as
  /// programmatically animating the sheet from the parent widget.
  ///
  /// Example:
  /// ```dart
  /// final controller = MarkerSheetController();
  ///
  /// MarkerDraggableSheet(
  ///   controller: controller,
  ///   ...
  /// );
  ///
  /// // Later in the parent widget:
  /// controller.animateSheet();
  /// ```
  ///
  /// If null, the sheet will not respond to external control.
  final MarkerSheetController? markerSheetController;

  const MarkerDraggableSheet(
      {super.key,
      required this.animateMarkers,
      this.markerSheetController,
      required this.config});

  @override
  State<MarkerDraggableSheet> createState() => MarkerDraggableSheetState();
}

class MarkerDraggableSheetState extends State<MarkerDraggableSheet> {
  final sheet = GlobalKey();
  final controller = DraggableScrollableController();
  final ValueNotifier<double> currentChildSizeNotifier = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    currentChildSizeNotifier.value = widget.config.initialChildSize;
    widget.markerSheetController
        ?.bind(animateMarkerSheet); // bind to your method
    controller.addListener(onChanged);
  }

  void onChanged() {
    final currentSize = controller.size;
    if (currentSize <= widget.config.reverseAnimationSize) {
      widget.animateMarkers();
    }
    currentChildSizeNotifier.value = currentSize;
  }

  void collapse() => animateSheet(getSheet.snapSizes!.first);

  void anchor() => animateSheet(getSheet.snapSizes!.last);

  void goInitial() => animateSheet(getSheet.initialChildSize);

  void expand() => animateSheet(getSheet.maxChildSize);

  void hide() => animateSheet(getSheet.minChildSize);

  void animateSheet(double size) {
    controller.animateTo(size,
        duration: widget.config.duration, curve: widget.config.curve);
  }

  void animateMarkerSheet() {
    if (controller.isAttached) {
      animateSheet(widget.config.initialChildSize);
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    currentChildSizeNotifier.dispose();
  }

  DraggableScrollableSheet get getSheet =>
      (sheet.currentWidget as DraggableScrollableSheet);

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    return LayoutBuilder(builder: (context, constraints) {
      return DraggableScrollableSheet(
        key: sheet,
        initialChildSize: config.initialChildSize,
        maxChildSize: config.maxChildSize,
        minChildSize: config.minChildSize,
        expand: true,
        snap: true,
        snapSizes: [
          config.minChildSize,
          config.initialChildSize,
          config.maxChildSize,
        ],
        controller: controller,
        builder: (BuildContext context, ScrollController scrollController) {
          return ValueListenableBuilder<double>(
              valueListenable: currentChildSizeNotifier,
              builder: (context, currentSheetSize, _) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: config.boxShadow,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(config.topCornerRadius),
                      topRight: Radius.circular(config.topCornerRadius),
                    ),
                  ),
                  child: SafeArea(
                    top: currentSheetSize == config.maxChildSize,
                    child: CustomScrollView(
                      controller: scrollController,
                      slivers: [
                        topButtonIndicator(currentSheetSize: currentSheetSize),
                        SliverToBoxAdapter(
                          child: config.child,
                        ),
                      ],
                    ),
                  ),
                  // }
                  //  ),
                );
              });
        },
      );
    });
  }

  SliverToBoxAdapter topButtonIndicator({required double currentSheetSize}) {
    final config = widget.config;
    final shouldAnimate = !config.showTopIndicator;
    final shouldShow =
        config.showTopIndicator || currentSheetSize < config.dynamicThreshold;

    final indicator = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: Wrap(
            children: <Widget>[
              Container(
                width: config.topButtonIndicatorWidth,
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                height: config.topButtonIndicatorHeight,
                decoration: BoxDecoration(
                  color: config.topButtonIndicatorColor,
                  shape: BoxShape.rectangle,
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (!shouldAnimate) {
      // Always visible, no animation
      return SliverToBoxAdapter(child: indicator);
    }

    return SliverToBoxAdapter(
        child: OpacityTween(
            begin: shouldShow ? 0.0 : 1.0,
            end: shouldShow ? 1.0 : 0.0,
            child: indicator));
  }
}
