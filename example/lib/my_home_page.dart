import 'dart:math';
import 'package:animate_map_markers/animate_map_markers.dart';
import 'package:example/share_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late GoogleMapController mapController;
  final Map<String, BitmapDescriptor> _currentIcons = {};
  final Map<String, BitmapDescriptor> _originalIcons = {};
  static const double widthStart = 35;

  static const double heightStart = 35;
  static const double widthEnd = 70; // scale 1.7
  static const double heightEnd = 70; // scale 1.7
  final Map<String,MarkerAnimationController>  _markerAnimationControllers = {};
  final ValueNotifier<
      String?> _selectedMarkerId = ValueNotifier<
      String?>(null);

  // Define the center of Paris
  final LatLng _parisCenter = LatLng(48.8566, 2.3522);
  late Future<void> _futureData;
  late List<LatLng> _randomLocations = [];

  final controller = DraggableScrollableController();
  final markerSheetController = MarkerSheetController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _futureData =   initializeAnimationMarkers();
    _randomLocations = generateRandomLocations();
  }

  /// Initialize the animation controller with Bounce Out curve
  Future<void> _initializeAnimation(String imagePath, String markerId) async {
    // Initialize the controller
    final markerAnimationController = MarkerAnimationController(
        markerId: markerId,
        startSize: Size(widthStart, heightStart),
        endSize: Size(widthEnd, heightEnd),
        assetPath: imagePath,
        duration: const Duration(milliseconds: 120),
        vsync: this
    );

    _markerAnimationControllers[markerId] = markerAnimationController;


    // Listen to the stream and update the marker icon
    markerAnimationController.iconStream.listen((updatedIcon) {
      setState(() {
        print(123);
        _currentIcons[markerId]= updatedIcon;
      });
    });

    markerAnimationController.originalIconStream.listen((originalIcon) {
      setState(() {
        print(456);
        print(originalIcon);
        _originalIcons[markerId]= originalIcon;
      });
    });

    // Start the animation
    markerAnimationController.animateTo();
  }

  // Function to generate random locations around Paris
  LatLng generateRandomLocation() {
    final random = Random();
    // Latitude and Longitude ranges around Paris (within a small radius of Paris)
    final double randomLat = 48.8566 + (random.nextDouble() * 0.1) - 0.05; // random latitude near Paris
    final double randomLng = 2.3522 + (random.nextDouble() * 0.1) - 0.05; // random longitude near Paris
    return LatLng(randomLat, randomLng);
  }

  Future<void> initializeAnimationMarkers() async{
    for (int i = 0; i < 10; i++) {
      final markerId = 'marker_$i';
      await _initializeAnimation('assets/map_marker.png', markerId);
    }
  }
  List<LatLng> generateRandomLocations() {
    List<LatLng> locations = [];
    for (int i = 0; i < 10; i++) {
      LatLng randomLocation = generateRandomLocation();
      locations.add(randomLocation);
    }
    return locations;
  }

  // Function to add random markers on the map
  Set<Marker> _addRandomMarkers(List<LatLng> randomLocations) {
    final Set<Marker> markers = {};

    for (int i = 0; i < 10; i++) {
      final markerId = 'marker_$i';
      final markerHelper = MarkerHelper(
        onMarkerTapped: (String markerId) async {
          print("Selected Marker Id is ### ${markerId}");
          _selectedMarkerId.value = markerId;
          markerSheetController.animateSheet();
     },
        markerAnimationController: _markerAnimationControllers,
      );

    final  marker =    markerHelper.createMarker(
      markerId:markerId,
       icon :  _currentIcons[markerId] ?? _originalIcons[markerId] ?? BitmapDescriptor.defaultMarker,
       position:  randomLocations[i],

    );
    markers.add(marker);
    }
    return markers;

  }

  @override
  Widget build(BuildContext context) {
    print("rebuilddd ####");
       return Scaffold(
         body: Stack(
          children: [
            FutureBuilder<void>(
                future: _futureData,
         
                builder: (context, snap) {
                  final markers = _addRandomMarkers(_randomLocations);
         
                          return  GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _parisCenter,
                              zoom: 12,
                            ),
                            markers: markers,
                            onMapCreated: (GoogleMapController controller) {
                              mapController = controller;
                              // Add random markers when the map is created
                            },
                          );
                        }
         
                     // }
                 // );
         
               // }
            ),
            ValueListenableBuilder(
              valueListenable: _selectedMarkerId,
              builder: (context, selectedMarkerId, _) {
                return MarkerDraggableSheetPage(
                    selectedMarkerId: selectedMarkerId,
                    markerAnimationControllers:  _markerAnimationControllers,
                    markerSheetController: markerSheetController,
                  child: Column(
                    children: [
                      SharePage(),
                      SharePage(),
                      SharePage(),
                      SharePage(),
                      SharePage(),
                      SharePage(),
                      SharePage(),
                    ],
                  )
                );
              }
            ),

          ],
               ),
       );

  }

  @override
  void dispose() {
    // TODO: implement dispose
    _selectedMarkerId.dispose();
    controller.dispose();
    super.dispose();
  }
}