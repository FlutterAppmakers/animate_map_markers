import 'package:flutter/material.dart';
import 'dart:math';
import 'package:animate_map_markers/animate_map_markers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A sample Flutter app demonstrating how to use the `animate_map_markers` package.
///
/// This example displays a Google Map centered on Paris with a set of randomly placed
/// animated markers. Each marker scales smoothly using the `AnimatedMapMarkersWidget`.
///
/// Features:
/// - Random marker generation around a fixed location (Paris)
/// - Support for both PNG and SVG marker assets
/// - Smooth scale animation on markers
/// - An optional draggable bottom sheet that lists additional marker info
///
/// To run this example:
///  Ensure you have a valid Google Maps API key set up in your Android and iOS config.
///
/// Dependencies:
/// - `animate_map_markers`: for animated marker handling
/// - `google_maps_flutter`: for displaying Google Maps

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomePage(),
    );
  }
}

const int numberOfMarkers = 7;

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Define the center of Paris
  final LatLng _parisCenter = LatLng(48.8566, 2.3522);

  final ValueNotifier<List<MarkerIconInfo>> scaledMarkerIconInfos =
      ValueNotifier<List<MarkerIconInfo>>([]);

  final List<String> markerAssets = [
    'assets/map_marker_1.png',
    'assets/map_marker_2.png',
    'assets/map_marker_3.png',
    'assets/map_marker_4.svg',
  ];

  /// The base size of the marker before scaling.
  static const minMarkerSize = Size(42.0, 48.0);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scaledMarkerIconInfos.value = _generateRandomMarkersIconInfos();
  }

  /// Function to generate random locations around Paris
  LatLng generateRandomLocation() {
    final random = Random();
    // Latitude and Longitude ranges around Paris (within a small radius of Paris)
    final double randomLat = 48.8566 +
        (random.nextDouble() * 0.1) -
        0.05; // random latitude near Paris
    final double randomLng = 2.3522 +
        (random.nextDouble() * 0.1) -
        0.05; // random longitude near Paris
    return LatLng(randomLat, randomLng);
  }

  final Random _random = Random();

  /// Function to add random markers on the map
  List<MarkerIconInfo> _generateRandomMarkersIconInfos() {
    final List<MarkerIconInfo> markerInfos = [];

    for (int i = 0; i < numberOfMarkers; i++) {
      final markerId = MarkerId('marker_$i');
      final String randomAsset =
          markerAssets[_random.nextInt(markerAssets.length)];
      final location = generateRandomLocation();
      final markerInfo = MarkerIconInfo(
          markerId: markerId,
          position: location,
          assetPath: randomAsset,
          minMarkerSize: minMarkerSize,
          scale: 1.7,
          curve: Curves.fastOutSlowIn,
          reverseCurve: Curves.easeInOut);

      markerInfos.add(markerInfo);
    }
    return markerInfos;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<MarkerIconInfo>>(
        valueListenable: scaledMarkerIconInfos,
        builder: (context, markerIconsInfos, _) {
          return AnimatedMapMarkersWidget(
            defaultCameraLocation: _parisCenter,
            zoomLevel: 12,
            scaledMarkerIconInfos: markerIconsInfos,
            showDraggableSheet: true,
            config: MarkerDraggableSheetConfig(
              showTopIndicator: false,
              boxShadow: [
                BoxShadow(
                  color: Colors.yellow,
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
              child: Column(
                children: List.generate(6, (_) => MarkerInfoCard()),
              ),
            ),
          );
        });
  }

  @override
  void dispose() {
    scaledMarkerIconInfos.dispose();
    super.dispose();
  }
}

class MarkerInfoCard extends StatelessWidget {
  const MarkerInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 30, right: 30),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Container(
                    color: Colors.black12,
                    height: 100,
                    width: 100,
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Container(
                        color: Colors.black12,
                        height: 20,
                        width: 240,
                      ),
                    ),
                    SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Container(
                        color: Colors.black12,
                        height: 20,
                        width: 180,
                      ),
                    ),
                    SizedBox(height: 50),
                  ],
                )
              ],
            ),
            SizedBox(height: 10),
          ],
        ));
  }
}
