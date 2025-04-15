import 'dart:math';
import 'package:animate_map_markers/animate_map_markers.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'marker_info_card.dart';

const int numberOfMarkers = 7;
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {
  /// Define the center of Paris
  final LatLng _parisCenter = LatLng(48.8566, 2.3522);

  final ValueNotifier<List<MarkerIconInfo>> scaledMarkerIconInfos = ValueNotifier<List<MarkerIconInfo>>([]);

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
    final double randomLat = 48.8566 + (random.nextDouble() * 0.1) -
        0.05; // random latitude near Paris
    final double randomLng = 2.3522 + (random.nextDouble() * 0.1) -
        0.05; // random longitude near Paris
    return LatLng(randomLat, randomLng);
  }

  final Random _random = Random();

  /// Function to add random markers on the map
  List<MarkerIconInfo> _generateRandomMarkersIconInfos() {
    final List<MarkerIconInfo> markerInfos = [];

    for (int i = 0; i < numberOfMarkers; i++) {
      final markerId = MarkerId('marker_$i');
      final String randomAsset = markerAssets[_random.nextInt(markerAssets.length)];
      final location = generateRandomLocation();
      final markerInfo = MarkerIconInfo(
          markerId: markerId,
          position: location,
          assetPath:  randomAsset,
          minMarkerSize: minMarkerSize,
          scale: 1.7,
          curve: Curves.fastOutSlowIn,
          reverseCurve: Curves.easeInOut
      );

      markerInfos.add(markerInfo);
    }
    return markerInfos;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<MarkerIconInfo>>(
     valueListenable: scaledMarkerIconInfos,
      builder: (context, markerIconsInfos,_ ) {
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
               children:
                 List.generate(6, (_) => MarkerInfoCard()),

        ),
            ),
        );
      }
    );
  }
}
