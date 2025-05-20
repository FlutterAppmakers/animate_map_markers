import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../animate_map_markers.dart';

class DraggableSheetWrapper extends StatelessWidget {
  final ValueNotifier<MarkerId?> selectedMarkerIdNotifier;
  final Map<MarkerId, MarkerAnimationController> markerAnimationControllers;
  final MarkerSheetController markerSheetController;
  final MarkerDraggableSheetConfig config;

  const DraggableSheetWrapper({
    super.key,
    required this.selectedMarkerIdNotifier,
    required this.markerAnimationControllers,
    required this.markerSheetController,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return MarkerDraggableSheetPage(
      selectedMarkerIdNotifier: selectedMarkerIdNotifier,
      markerAnimationControllers: markerAnimationControllers,
      markerSheetController: markerSheetController,
      config: config,
    );
  }
}
