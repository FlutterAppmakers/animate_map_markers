import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:animate_map_markers/animate_map_markers.dart'; // ✅ This should point to MarkerScaler

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'markers_test.mocks.dart';

@GenerateMocks([MarkerScaler])
void main() {
  group('MarkerAnimationController', () {
    late MockMarkerScaler mockMarkerScaler;
    late MarkerAnimationController controller;

    setUp(() {
      mockMarkerScaler = MockMarkerScaler();
    });

    testWidgets('emits icon when animation runs', (WidgetTester tester) async {
      // fake icon returned by mock
      final fakeIcon = BitmapDescriptor.defaultMarker;

      // mock scaling to always return the fakeIcon
      when(mockMarkerScaler.scaleMarkerIcon(any, any, any))
          .thenAnswer((_) async => fakeIcon);

      controller = MarkerAnimationController(
        markerId: MarkerId('test_marker'),
        minMarkerSize: const Size(60, 60),
        scale: 1.7,
        assetPath: 'assets/map_marker.png',
        vsync: tester,
        duration: const Duration(milliseconds: 100), // shorter duration
        scaler: mockMarkerScaler,
        reverseDuration: const Duration(milliseconds: 100),
      );

      // listen to emitted icons
      final iconUpdates = <BitmapDescriptor>[];
      controller.iconStream.listen((icon) {
        iconUpdates.add(icon);
      });

      // run animation
      controller.setupAnimationController();

      // 🔥 This actually starts the animation
      controller.animateMarker(MarkerId('test_marker'), true);

      // pump to start animation
      await tester.pump();

      // simulate time passing to finish animation
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Ensure we received updates
      expect(iconUpdates.isNotEmpty, true);
      expect(iconUpdates.last, fakeIcon);
    });
  });
}
