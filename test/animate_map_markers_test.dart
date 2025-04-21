import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:animate_map_markers/animate_map_markers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  group('Marker Animation Tests', () {
    const validMarkerId = 'marker_1';
    TestWidgetsFlutterBinding.ensureInitialized();

    group('MarkerScaler', () {
      test(
          'should scale the marker icon and return a BitmapDescriptor', () async {
        final icon = await MarkerScaler().scaleMarkerIcon(
            'assets/map_marker.png', 60, 60);

        expect(icon, isA<BitmapDescriptor>());
      });
    });

      group('MarkerDraggableSheet', () {
        testWidgets(
            'should trigger animateMarkers when collapsed', (tester) async {
          bool triggered = false;

          await tester.pumpWidget(MaterialApp(
            home: MarkerDraggableSheet(
              animateMarkers: () => triggered = true,
              markerSheetController: MarkerSheetController(),
              child: Text('Test'),
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
              animateMarkers: () => triggered = true,
              markerSheetController: MarkerSheetController(),
              child: Text('Test'),
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
          await tester.pumpWidget(MaterialApp(
            home: MarkerDraggableSheetPage(
              selectedMarkerId: validMarkerId,
              markerAnimationControllers: {},
              markerSheetController: MarkerSheetController(),
              child: Text('Content'),
            ),
          ));

          expect(find.byType(MarkerDraggableSheet),
              findsOneWidget); // Should be visible
        });

       testWidgets(
            'should not show MarkerDraggableSheet when selectedMarkerId is null', (
            tester) async {
          await tester.pumpWidget(MaterialApp(
            home: MarkerDraggableSheetPage(
              selectedMarkerId: null,
              markerAnimationControllers: {},
              markerSheetController: MarkerSheetController(),
              child: Text('Content'),
            ),
          ));

          expect(find.byType(MarkerDraggableSheet),
              findsNothing); // Should not be visible
        });
      });
  });
}
