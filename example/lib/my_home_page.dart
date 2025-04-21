import 'dart:math';
import 'package:animate_map_markers/animate_map_markers.dart';
import 'package:example/marker_info_card.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const int numberOfMarkers = 20;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late GoogleMapController mapController;
  // Store current  marker icons for animations
  final Map<String, BitmapDescriptor> _currentIcons = {};
  // Store original marker icons for animations
  final Map<String, BitmapDescriptor> _originalIcons = {};

  // Starting and ending sizes for marker scaling
  static const double widthStart = 42;

  static const double heightStart = 48;
  /// Map to store animation controllers for each marker
  final Map<String,MarkerAnimationController>  _markerAnimationControllers = {};
  /// ValueNotifier for tracking the selected marker
  final ValueNotifier<
      String?> _selectedMarkerId = ValueNotifier<
      String?>(null);

  /// Define the center of Paris
  final LatLng _parisCenter = LatLng(48.8566, 2.3522);
  late Future<void> _futureData;
  late List<LatLng> _randomLocations = [];
  final markerSheetController = MarkerSheetController();

  static  const animationDuration = Duration(milliseconds: 300);
  static const animationReverseDuration = Duration(microseconds: 400);

  final List<String> markerAssets = [
    'assets/map_marker_1.png',
    'assets/map_marker_2.png',
    'assets/map_marker_3.png',
  ];

  final Random _random = Random();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    /// Initialize the markers with animations
    _futureData =   initializeAnimationMarkers();
    _randomLocations = generateRandomLocations();
  }

  /// Initialize the animation controller for each marker
  Future<void> _initializeAnimation(String imagePath, String markerId) async {
    /// Initialize the controller
    final markerAnimationController = MarkerAnimationController(
        markerId: markerId,
        minMarkerSize: Size(widthStart, heightStart),
        scale: 1.7,
        assetPath: imagePath,
        duration: animationDuration,
        reverseDuration: animationReverseDuration,
        curve: Curves.easeInOut,
        reverseCurve: Curves.fastOutSlowIn,
        vsync: this
    );

    _markerAnimationControllers[markerId] = markerAnimationController;


    /// Listen to the stream and update the marker icon
    markerAnimationController.iconStream.listen((updatedIcon) {
      setState(() {
        _currentIcons[markerId]= updatedIcon;
      });
    });

    /// Listen for the original icon and store it
    markerAnimationController.originalIconStream.listen((originalIcon) {
      setState(() {
        _originalIcons[markerId]= originalIcon;
      });
    });

    // Start the animation
    markerAnimationController.setupAnimationController();
  }

  /// Function to generate random locations around Paris
  LatLng generateRandomLocation() {
    final random = Random();
    // Latitude and Longitude ranges around Paris (within a small radius of Paris)
    final double randomLat = 48.8566 + (random.nextDouble() * 0.1) - 0.05; // random latitude near Paris
    final double randomLng = 2.3522 + (random.nextDouble() * 0.1) - 0.05; // random longitude near Paris
    return LatLng(randomLat, randomLng);
  }

  /// Function to initialize animation markers
  Future<void> initializeAnimationMarkers() async{
    for (int i = 0; i < numberOfMarkers; i++) {
      final markerId = 'marker_$i';
      final String randomAsset = markerAssets[_random.nextInt(markerAssets.length)];
      await _initializeAnimation(randomAsset, markerId);
    }
  }

  /// Function to generate a list of random locations
  List<LatLng> generateRandomLocations() {
    List<LatLng> locations = [];
    for (int i = 0; i < numberOfMarkers; i++) {
      LatLng randomLocation = generateRandomLocation();
      locations.add(randomLocation);
    }
    return locations;
  }

  /// Function to add random markers on the map
  Set<Marker> _addRandomMarkers(List<LatLng> randomLocations) {
    final Set<Marker> markers = {};

    for (int i = 0; i < numberOfMarkers; i++) {
      final markerId = 'marker_$i';
      final markerHelper = MarkerHelper(
        onMarkerTapped: (String markerId) async {
          _selectedMarkerId.value = markerId;
          /// Trigger the sheet animation
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
            /// Draggable sheet to display additional content when a marker is tapped
         MarkerDraggableSheetPage(
             selectedMarkerIdNotifier: _selectedMarkerId,
             markerAnimationControllers:  _markerAnimationControllers,
             markerSheetController: markerSheetController,
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
             ),

             child: Column(
               children: [
                 MarkerInfoCard(),
                 MarkerInfoCard(),
                 MarkerInfoCard(),
                 MarkerInfoCard(),
                 MarkerInfoCard(),
                 MarkerInfoCard(),
               ],
             )
         ),

          ],
               ),
       );

  }

  /// Stop all ongoing animations for markers.
  void stopMarkerAnimations() {
    for (int i = 0; i < 10; i++) {
      final markerId = 'marker_$i';
      final markerAnimationController = _markerAnimationControllers[markerId];
      if(markerAnimationController != null) {
        markerAnimationController.stopAnimations();
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _selectedMarkerId.dispose();
    stopMarkerAnimations();
    super.dispose();
  }
}
