
/*import 'package:flutter/material.dart';
import 'marker_swipe_card_config.dart';

class MarkerSwipeCard extends StatelessWidget {
  final MarkerSwipeCardConfig config;
  final void Function(int index)? onPageChanged;

  const MarkerSwipeCard({
    super.key,
    required this.config,
    this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return  PageView.builder(
          controller: config.pageController,
          itemCount: config.cards.length,
          itemBuilder: (_, index) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: config.cards[index],
          ),
          onPageChanged: onPageChanged,
        );

  }
}*/

import 'dart:async';

import 'package:animate_map_markers/src/swipe_cards/page_control_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as Math;

import '../../animate_map_markers.dart';



class MarkerSwipeCard extends StatefulWidget {

  //final void Function() animateMarkers;

  final MarkerSwipeCardConfig config;

  final Map<MarkerId, MarkerAnimationController> markerAnimationControllers;
  /// The notifier for the currently selected marker ID.
  final ValueNotifier<MarkerId?> selectedMarkerIdNotifier;

  final List<MarkerIconInfo> scaledMarkerIconInfos;

  final Completer<GoogleMapController> mapControllerCompleter;

  final PageController pageCtrl;


  /// SnapClipPageView is an advanced version of PageView
  ///
  /// Customize every signle pixel of pageview.
  const MarkerSwipeCard({
    super.key,
    required this.selectedMarkerIdNotifier,
    required this.markerAnimationControllers,
    required this.config,
    required this.scaledMarkerIconInfos,
    required this.mapControllerCompleter,
    required this.pageCtrl,
  });

  @override
  State<MarkerSwipeCard> createState() => _MarkerSwipeCardState();
}

class _MarkerSwipeCardState extends State<MarkerSwipeCard> {
  //late PageController ctrl;

  /*@override
  void initState() {
    ctrl = PageController(viewportFraction: 0.75);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.jumpToPage(widget.config.initialIndex);
    });
  }*/

  /*@override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }*/

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.pageCtrl.jumpToPage(widget.config.initialIndex);
    });
  }

@override
  void dispose() {
    widget.pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      height: config.height,
      child: PageCtrlProvider(
          pageCtrl: widget.pageCtrl,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Container(
                  decoration: config.backgroundDecoration,
                ),
              ),
                 PageView.builder(
                        onPageChanged:(index)  {
                          _handlePageChanged(index);
                         /* final controller = await widget.mapControllerCompleter.future;
                          controller.animateCamera(CameraUpdate.newLatLng(...));



                          print("index is ### ${index}");
                          final selectedMarkerId = widget.scaledMarkerIconInfos[index].markerId;

                          for (final info in widget.scaledMarkerIconInfos) {
                            final markerId = info.markerId;
                            final shouldAnimate = markerId == selectedMarkerId;

                            widget.markerAnimationControllers[markerId]
                                ?.animateMarker(markerId, shouldAnimate);
                          }

                          config.onPageChanged(index);*/
                        } ,
                        controller: widget.pageCtrl,
                        itemCount: config.length,
                        itemBuilder: config.itemBuilder,
                                     ),


            ],
          ),
        ),
    );

  }

  Future<void> _handlePageChanged(int index) async {
    final selectedInfo = widget.scaledMarkerIconInfos[index];

    // Animate marker
    for (final info in widget.scaledMarkerIconInfos) {
      final shouldAnimate = info.markerId == selectedInfo.markerId;
      widget.markerAnimationControllers[info.markerId]
          ?.animateMarker(info.markerId, shouldAnimate);
    }

    // Safely get and use the map controller
    final controller = await widget.mapControllerCompleter.future;
    /*controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: selectedInfo.position, // your LatLng
          zoom: 13.0,                    // desired zoom level
        ),
      ),
    );*/
    await controller.animateCamera(
      CameraUpdate.newLatLng(selectedInfo.position),
    );

    // Optional: notify parent or do other updates
    widget.config.onPageChanged(index);
  }
}

/// PageViewItem takes child to build the item.
class PageViewItem extends StatefulWidget {
  final int index;
  final Widget child;
  final AlignmentGeometry alignment;
  final double height;
  final Decoration Function(double animation) buildDecoration;
  final EdgeInsets padding;
  final EdgeInsets margin;


  static Decoration _defaultDecorationBuilder(double opacity) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(25),
    );
  }

  /// Responsible for increasing the height for selected item and
  /// gives animation value for decoration to customize the view.
  ///
  /// Align each widget as you need.
  const PageViewItem({
    super.key,
    this.buildDecoration = _defaultDecorationBuilder,
    required this.index,
    required this.child,
    required this.height,
    this.alignment = Alignment.bottomCenter,
    this.padding = const EdgeInsets.all(25),
    this.margin = const EdgeInsets.only(
      right: 8,
      left: 8,
    ),
  }) ;
  @override
  State<PageViewItem>  createState() => _PageViewItemState();
}

class _PageViewItemState extends State<PageViewItem> {
  double heightScale = 1;
  final maxScalePoint = .1;
  final minScaleSize = 1.0;
  double opacity = .6;
  final double maxOpacityPoint = .4;
  final double minOpacity = .6;

  late PageController pageCtrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    pageCtrl = PageCtrlProvider.of(context)!.pageCtrl ;
    pageCtrl.addListener(onChangePage);
  }

  @override
  void dispose() {
    pageCtrl.removeListener(onChangePage);
    super.dispose();
  }

  void onChangePage() {
    double page = pageCtrl.page ?? 1;
    bool shouldSetState = false;
    double currentScale = 0;
    if (page.ceil() == widget.index) {
      currentScale = (page - (widget.index - 1));
      shouldSetState = true;
    } else if (page.floor() == widget.index) {
      currentScale = ((widget.index + 1) - page);
      shouldSetState = true;
    }

    if (shouldSetState) {
      final maxOpacity = currentScale * maxOpacityPoint + minOpacity;
      opacity = Math.max(minOpacity, maxOpacity);

      final maxSize = currentScale * maxScalePoint + minScaleSize;
      heightScale = Math.max(minScaleSize, maxSize);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignment,
      child: Container(
        height: widget.height * heightScale,
        decoration:widget.buildDecoration(opacity),
        padding: widget.padding,
        margin: widget.margin,
        child: widget.child,
      ),
    );
  }
}
