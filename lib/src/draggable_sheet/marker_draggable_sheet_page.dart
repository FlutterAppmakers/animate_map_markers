import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../animate_map_markers.dart';

/// A widget that wraps [MarkerDraggableSheet] and manages marker-specific animations.
///
/// This page is only displayed when a [selectedMarkerId] is provided. It coordinates
/// marker animations through the provided [markerAnimationControllers] and links
/// to the [markerSheetController] for controlling the draggable sheet behavior.
class MarkerDraggableSheetPage extends StatelessWidget {
  const MarkerDraggableSheetPage({
    super.key,
    required this.selectedMarkerIdNotifier,
    required this.markerAnimationControllers,
    required this.markerSheetController,
    this.config = const MarkerDraggableSheetConfig(child: SizedBox()),
  });

  /// A map of marker IDs to their corresponding [MarkerAnimationController]s.
  ///
  /// Used to control animation behavior of each individual marker.
  final Map<MarkerId, MarkerAnimationController> markerAnimationControllers;

  /// A controller for interacting with [MarkerDraggableSheet].
  final MarkerSheetController markerSheetController;

  /// The configuration object for customizing the behavior and appearance of the draggable sheet.
  ///
  /// Provides properties such as `initialChildSize`, `maxChildSize`, `curve`, `duration`,
  /// and more to control how the sheet behaves and looks.
  ///
  /// Defaults are defined within [MarkerDraggableSheetConfig].
  final MarkerDraggableSheetConfig config;

  /// The notifier for the currently selected marker ID.
  final ValueNotifier<MarkerId?> selectedMarkerIdNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MarkerId?>(
      valueListenable: selectedMarkerIdNotifier,
      builder: (context, selectedMarkerId, _) {
        if (selectedMarkerId == null) {
          return const SizedBox.shrink();
        }

        return MarkerDraggableSheet(
          config: config,
          markerSheetController: markerSheetController,
          animateMarkers: () {
            markerAnimationControllers[selectedMarkerId]
                ?.animateMarker(selectedMarkerId, false);
          },
        );
      },
    );
  }
}
