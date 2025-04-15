import 'package:flutter/material.dart';

import 'marker_sheet_controller.dart';

class MarkerDraggableSheet extends StatefulWidget {
  /// The content widget to be displayed inside the [MarkerDraggableSheet].
  final Widget child;
  final void Function() animateMarkers;
  /// The initial fractional value of the parent container's height to use when displaying the widget
  ///
  /// Defaults to 0.5.
  final double initialChildSize;
  /// The maximum fractional value of the parent container's height to use when displaying the widget.
  ///
  /// Defaults to 1.0.
  final double maxChildSize;
  /// The minimum fractional value of the parent container's height to use when displaying the widget.
  ///
  /// Defaults to 0.
  final double minChildSize;
  /// The fractional value of the parent container's height to use when  reversing the animation
  final double reverseAnimationSize;

  /// The curve of the animation.
  ///
  /// Defaults to [Curves.easeInOut].
  final Curve curve;

  /// The duration of the animation.
  ///
  /// Defaults to 50 milliseconds.
  final Duration duration;

  /// The width of the top button indicator.
  ///
  /// Defaults to 100.
  final double topButtonIndicatorWidth;

  /// The height of the top button indicator.
  ///
  /// Defaults to 5.
  final double topButtonIndicatorHeight;

  /// The color of the top button indicator.
  ///
  /// Defaults to [Colors.black45].
  final Color topButtonIndicatorColor;

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



  const  MarkerDraggableSheet({
    super.key,
    required this.child,
    required this.animateMarkers,
    this.initialChildSize = 0.5,
    this.maxChildSize = 1,
    this.minChildSize = 0,
    this.reverseAnimationSize = 0.1,
    this.curve = Curves.easeInOut,
    this.duration = const Duration(milliseconds: 50),
    this.topButtonIndicatorWidth = 100.0,
    this.topButtonIndicatorHeight = 5.0,
    this.topButtonIndicatorColor =  Colors.black45,
    this.markerSheetController
  });


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
    currentChildSizeNotifier.value = widget.initialChildSize;
    widget.markerSheetController?.bind(animateMarkerSheet); // bind to your method
    controller.addListener(onChanged);
  }

  void onChanged() {
    final currentSize = controller.size;
    //print("currentSize ${currentSize}");
    if (currentSize <= widget.reverseAnimationSize) {
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
    controller.animateTo(
      size,
      duration: widget.duration,
     curve:  widget.curve
    );
  }

  void animateMarkerSheet() {
    if(controller.isAttached) {
      animateSheet(widget.initialChildSize);
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
   // currentChildSizeNotifier.dispose();
  }

  DraggableScrollableSheet get getSheet =>
      (sheet.currentWidget as DraggableScrollableSheet);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return DraggableScrollableSheet(
        key: sheet,
        initialChildSize: widget.initialChildSize,
        maxChildSize:  widget.maxChildSize,
        minChildSize: widget.minChildSize,
        expand: true,
        snap: true,
        snapSizes: [
          widget.minChildSize,
          widget.initialChildSize,
          widget.maxChildSize,
        ],
        controller: controller,
        builder: (BuildContext context, ScrollController scrollController) {
          return ValueListenableBuilder<double>(
            valueListenable: currentChildSizeNotifier,

            builder: (context, currentSheetSize, _) {
              return DecoratedBox(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.yellow,
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: Offset(0, 1),
                    ),
                  ],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22),
                  ),
                ),
                  child: SafeArea(
                    top: currentSheetSize == widget.maxChildSize,
                        child: CustomScrollView(
                          controller: scrollController,
                          slivers: [
                            topButtonIndicator(),
                            SliverToBoxAdapter(
                              child: widget.child,
                            ),
                          ],
                        ),
                      ),
                   // }
                //  ),

              );
            }
          );
        },
      );
    });
  }

  SliverToBoxAdapter topButtonIndicator() {
    return SliverToBoxAdapter(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
                child: Wrap(children: <Widget>[
                  Container(
                      width: widget.topButtonIndicatorWidth,
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      height: widget.topButtonIndicatorHeight,
                      decoration: BoxDecoration(
                        color: widget.topButtonIndicatorColor,
                        shape: BoxShape.rectangle,
                        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                      )),
                ])),
          ]),
    );
  }
}


