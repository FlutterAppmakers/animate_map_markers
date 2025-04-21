import 'package:flutter/material.dart';
import '../../animate_map_markers.dart';
import 'marker_sheet_controller.dart';

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
    required this.child,
    this.config = const MarkerDraggableSheetConfig(),
  });
  /// The content widget to be displayed inside the [MarkerDraggableSheet].
  final Widget child;
  /// A map of marker IDs to their corresponding [MarkerAnimationController]s.
  ///
  /// Used to control animation behavior of each individual marker.
  final Map<String,MarkerAnimationController> markerAnimationControllers;
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
  final ValueNotifier<String?> selectedMarkerIdNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
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
          child: child,
        );
      },
    );
  }
}
