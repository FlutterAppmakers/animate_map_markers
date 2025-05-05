import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:animate_map_markers/animate_map_markers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  group('Marker Animation Tests', () {
    const validMarkerId = 'marker_1';
    TestWidgetsFlutterBinding.ensureInitialized();

    group('MarkerScaler', () {
      testWidgets(
          'should scale the marker icon and return a BitmapDescriptor', (tester) async {
        final markerScaler = MarkerScaler(assetPath: 'assets/map_marker.png');
        final icon = await  markerScaler.createBitmapDescriptor(Size(60.0, 60.0));

        expect(icon, isA<BitmapDescriptor>());
      });
    });

      group('MarkerDraggableSheet', () {
        testWidgets(
            'should trigger animateMarkers when collapsed', (tester) async {
          bool triggered = false;

          await tester.pumpWidget(MaterialApp(
            home: MarkerDraggableSheet(
              config: const MarkerDraggableSheetConfig(child: Text('Test'),),
              animateMarkers: () => triggered = true,
              markerSheetController: MarkerSheetController(),
            ),
          ));

          // Simulate the sheet collapse below the threshold
          final state = tester.state<MarkerDraggableSheetState>(
            find.byType(MarkerDraggableSheet),
          );

          state.controller.jumpTo(0.05); // Collapse to threshold size
          state.onChanged(); // Simulate size change

          expect(triggered, true); // Ensure that the animation was triggered
        });


        testWidgets(
            'should not trigger animateMarkers if the sheet is not collapsed', (
            tester) async {
          bool triggered = false;

          await tester.pumpWidget(MaterialApp(
            home: MarkerDraggableSheet(
              config: const MarkerDraggableSheetConfig(child: Text('Test'),),
              animateMarkers: () => triggered = true,
              markerSheetController: MarkerSheetController(),
            ),
          ));

          // Simulate the sheet being expanded above the threshold
          final state = tester.state<MarkerDraggableSheetState>(
            find.byType(MarkerDraggableSheet),
          );

          state.controller.jumpTo(0.9); // Expand above the threshold
          state.onChanged(); // Simulate size change

          expect(
              triggered, false); // Ensure that the animation was not triggered
        });
      });

      group('MarkerDraggableSheetPage', () {
        testWidgets(
            'should show MarkerDraggableSheet when selectedMarkerId is not null', (
            tester) async {
          final selectedMarkerIdNotifier = ValueNotifier<MarkerId?>(MarkerId(validMarkerId));
          await tester.pumpWidget(MaterialApp(
            home: MarkerDraggableSheetPage(
              selectedMarkerIdNotifier: selectedMarkerIdNotifier,
              markerAnimationControllers: {},
              markerSheetController: MarkerSheetController(),
              config: MarkerDraggableSheetConfig(child: Text('Content')),
            ),
          ));

          expect(find.byType(MarkerDraggableSheet),
              findsOneWidget); // Should be visible
        });

       testWidgets(
            'should not show MarkerDraggableSheet when selectedMarkerId is null', (
            tester) async {
         final selectedMarkerIdNotifier = ValueNotifier<MarkerId?>(null);
          await tester.pumpWidget(MaterialApp(
            home: MarkerDraggableSheetPage(
              selectedMarkerIdNotifier: selectedMarkerIdNotifier,
              markerAnimationControllers: {},
              markerSheetController: MarkerSheetController(),
              config: MarkerDraggableSheetConfig(child: Text('Content')),
            ),
          ));

          expect(find.byType(MarkerDraggableSheet),
              findsNothing); // Should not be visible
        });
      });
  });
}
