import 'package:flutter/material.dart';
import '../animate_map_markers.dart';

/// A widget that wraps [MarkerDraggableSheet] and manages marker-specific animations.
///
/// This page is only displayed when a [selectedMarkerId] is provided. It coordinates
/// marker animations through the provided [markerAnimationControllers] and links
/// to the [markerSheetController] for controlling the draggable sheet behavior.
class MarkerDraggableSheetPage extends StatelessWidget {
  const MarkerDraggableSheetPage({
    super.key,
    required this.selectedMarkerId,
    required this.markerAnimationControllers,
    required this.markerSheetController,
    required this.child,
  });
  /// The content widget to be displayed inside the [MarkerDraggableSheet].
  final Widget child;
  /// The ID of the currently selected marker.
  ///
  /// If `null`, the sheet will not be displayed.
  final String? selectedMarkerId;
  /// A map of marker IDs to their corresponding [MarkerAnimationController]s.
  ///
  /// Used to control animation behavior of each individual marker.
  final Map<String,MarkerAnimationController> markerAnimationControllers;
  /// A controller for interacting with [MarkerDraggableSheet].
  final MarkerSheetController markerSheetController;

  @override
  Widget build(BuildContext context) {
    if (selectedMarkerId == null) {
      return const SizedBox.shrink();
    }
    return MarkerDraggableSheet(
        markerSheetController: markerSheetController,
        animateMarkers: () {
          markerAnimationControllers[selectedMarkerId]?.animateMarker(selectedMarkerId!, false);
        },
        child: child
    );
  }
}
