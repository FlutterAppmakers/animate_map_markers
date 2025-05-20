import 'dart:async';
import 'package:animate_map_markers/src/swipe_cards/marker_swipe_card_config_extensions.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../animate_map_markers.dart';

/// A widget that displays a swipeable carousel linked to map markers.
///
/// When a user swipes through the cards, the corresponding map marker is animated
/// and the camera moves to its position.
class MarkerSwipeCard extends StatefulWidget {
  final MarkerSwipeCardConfig config;

  /// A map of marker IDs to their associated animation controllers.
  final Map<MarkerId, MarkerAnimationController> markerAnimationControllers;

  /// The notifier for the currently selected marker ID.
  final ValueNotifier<MarkerId?> selectedMarkerIdNotifier;

  /// The list of markers that will be animated using scaling effects.
  ///
  /// Each [MarkerIconInfo] provides configuration such as marker ID, asset path, scale, and animation settings.
  final List<MarkerIconInfo> scaledMarkerIconInfos;

  /// Completer for the [GoogleMapController], used to control map interactions.
  final Completer<GoogleMapController> mapControllerCompleter;

  /// Indicates whether the carousel is animating as a result of a marker interaction.
  /// Prevents recursive updates between marker selection and carousel movement.
  final ValueNotifier<bool> isPageAnimatingFromMarker;

  /// Controller for the [CarouselSlider]
  final CarouselSliderController controller;

  const MarkerSwipeCard(
      {super.key,
      required this.selectedMarkerIdNotifier,
      required this.markerAnimationControllers,
      required this.config,
      required this.scaledMarkerIconInfos,
      required this.mapControllerCompleter,
      required this.isPageAnimatingFromMarker,
      required this.controller});

  @override
  State<MarkerSwipeCard> createState() => _MarkerSwipeCardState();
}

class _MarkerSwipeCardState extends State<MarkerSwipeCard> {
  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    return Positioned(
      left: 0,
      right: 0,
      bottom: config.bottom,
      child: CarouselSlider(
        items: config.items,
        options: config.options.toCarouselOptions(
            onPageChangedCallback: (index, reason) {
          onPageChange(index, reason);
        }),
        disableGesture: config.disableGesture,
        carouselController: widget.controller,
      ),
    );
  }

  /// Handles page change events from the carousel.
  void onPageChange(int index, CarouselPageChangedReason changeReason) {
    final isAnimating = widget.isPageAnimatingFromMarker.value;
    final selectedIndex = widget.scaledMarkerIconInfos.indexWhere(
      (info) => info.markerId == widget.selectedMarkerIdNotifier.value,
    );
    if (isAnimating) {
      if (index == selectedIndex) {
        widget.isPageAnimatingFromMarker.value = false;
      }

      return;
    }
    _handlePageChanged(index, changeReason);
  }

  /// Animates the map and the selected marker based on the current page index.
  Future<void> _handlePageChanged(
      int index, CarouselPageChangedReason changeReason) async {
    final selectedInfo = widget.scaledMarkerIconInfos[index];

    /// Animate marker
    for (final info in widget.scaledMarkerIconInfos) {
      final shouldAnimate = info.markerId == selectedInfo.markerId;
      widget.markerAnimationControllers[info.markerId]
          ?.animateMarker(info.markerId, shouldAnimate);
    }

    final controller = await widget.mapControllerCompleter.future;

    await controller.animateCamera(
      CameraUpdate.newLatLng(selectedInfo.position),
    );
  }
}
