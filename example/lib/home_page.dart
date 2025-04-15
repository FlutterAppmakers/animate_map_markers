import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late GoogleMapController mapController;
  final Map<String, BitmapDescriptor> _scaledIcons = {};
  final Map<String, AnimationController> _animationControllers = {};
  final Map<String, Animation<Size>> _scaleAnimations = {};
  final Map<String, BitmapDescriptor> _currentIcons = {};
  final Map<String, BitmapDescriptor> _originalIcons = {};
  static const double widthStart = 35.0;

  static const double heightStart = 35.0;
  static const double widthEnd = 60.0; // scale 1.7
  static const double heightEnd = 60.0; // scale 1.7
  final Set<Marker> _markers = {};

  // Define the center of Paris
  final LatLng _parisCenter = LatLng(48.8566, 2.3522);
  late Future<void> _futureData;
  late List<LatLng> _randomLocations = [];
  static const platform = MethodChannel('com.example.app/markers');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _futureData =   initializeAnimationMarkers();
    _randomLocations = generateRandomLocations();
  }


  /// Initialize the animation controller with Bounce Out curve
  Future<void> _initializeAnimation(String imagePath, String markerId) async {
    final animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    final scaleAnimation = Tween<Size>(begin: Size(widthStart, heightStart),
        end: Size(widthEnd, heightEnd)).animate(
        CurvedAnimation(
          parent: animationController,
          reverseCurve: Curves.linear,
          curve: Curves.easeIn,
        )
    );

    _animationControllers[markerId] = animationController;
    _scaleAnimations[markerId] = scaleAnimation;
    // Define separate Tweens for width and height
    //final originalIcon = await _generateScaledIcon(imagePath, Size(widthStart, heightStart));
    final originalIcon =  await _scaleMarkerIcon(widthStart, heightStart);
    _originalIcons[markerId] = originalIcon;


    animationController.addListener(() async {
      final sizeFactor = scaleAnimation.value;
      print("size Factor #### ${sizeFactor}");
      final width = sizeFactor.width;
      final height = sizeFactor.height;
      final key = '$imagePath w$width h $height';
      if (!_scaledIcons.containsKey(key)) {
        /* final BitmapDescriptor icon =
        await _generateScaledIcon(
            imagePath, sizeFactor);*/
        final BitmapDescriptor icon = await _scaleMarkerIcon(width, height);

        setState(() {
          _scaledIcons[key] = icon;
          _currentIcons[markerId] = icon;
        });
      } else {
        setState(() {
          _currentIcons [markerId] = _scaledIcons[key]!;
        });
      }
    });

  }

  /// Pre-generate icons for different scales
  Future<void> _preGenerateIcons(String imagePath, String markerId) async {
    final BitmapDescriptor icon =
    await _generateScaledIcon(imagePath, Size(widthStart, heightStart));
    final key = '$imagePath w$widthStart h $heightStart';
    _scaledIcons[key] = icon;

    setState(() {
      _currentIcons[markerId] = icon;
    });
  }

  /// Load and scale an asset image to create a marker icon
  Future<BitmapDescriptor> _generateScaledIcon(String assetPath,
      Size size) async {
    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: size.width.toInt(),
      targetHeight: size.height.toInt(),
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();

    final ByteData? byteData =
    await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      return BitmapDescriptor.bytes(byteData.buffer.asUint8List());
    } else {
      throw Exception("Failed to generate scaled icon.");
    }
  }

  /// Animate marker by switching pre-generated icons
  void _animateMarker(String markerId, bool selected) async {
    final animationController = _animationControllers[markerId];
    if (animationController != null) {

      if (selected) {

        if (animationController.status == AnimationStatus.dismissed ||
            animationController.status == AnimationStatus.completed) {
          animationController.forward();
        } else  if (animationController.status == AnimationStatus.forward)  {
          animationController.reverse();
        }
      } else {
        animationController.reset();
        animationController.reverse();
      }
    }
  }
  // Function to generate random locations around Paris
  LatLng generateRandomLocation() {
    final random = Random();
    // Latitude and Longitude ranges around Paris (within a small radius of Paris)
    final double randomLat = 48.8566 + (random.nextDouble() * 0.1) - 0.05; // random latitude near Paris
    final double randomLng = 2.3522 + (random.nextDouble() * 0.1) - 0.05; // random longitude near Paris
    return LatLng(randomLat, randomLng);
  }

  // Function to generate random marker titles and descriptions
  String generateRandomTitle(int index) {
    return 'Marker $index';
  }

  String generateRandomDescription(int index) {
    return 'Random Description $index';
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
  Set<Marker> _addRandomMarkers(List<LatLng> randomLocations){
    _markers.clear();
    final Set<Marker> markers = {};
    for (int i = 0; i < 10; i++) {
      final markerId = 'marker_$i';
      final marker = Marker(
          icon: _currentIcons[markerId] ?? _originalIcons[markerId] ?? BitmapDescriptor.defaultMarker  ,
          markerId: MarkerId(markerId),
          position: randomLocations[i],
          infoWindow: InfoWindow(
            title: generateRandomTitle(i),
            snippet: generateRandomDescription(i),
          ),
          onTap:() {

            for (var id in _animationControllers.keys) {
              if (id == markerId) {
                _animateMarker(id, true);
              }else {
                _animateMarker(id, false);
              }
            }
          }
      );
      markers.add(marker);
    }
    return markers;

  }

  // Call Android native code to scale the marker
  Future<BitmapDescriptor> _scaleMarkerIcon(double width, double height) async {
    // Load the image from assets as a byte array
    final image = await _loadImage('assets/map_marker.png');
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List imageBytes = byteData!.buffer.asUint8List();

    final ui.Codec codec = await ui.instantiateImageCodec(
      imageBytes,
      targetWidth: (width).toInt(),
      targetHeight: (height).toInt(),

    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();

    final ByteData? byteData2 =
    await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List? imageBytes2 = byteData2?.buffer.asUint8List();
    try {
      final Uint8List markerIcon = await platform.invokeMethod(
          'scaleMarker',
          {'width': width,
            'height': height,
            'image': imageBytes2,
          });

      return BitmapDescriptor.bytes(markerIcon, bitmapScaling: MapBitmapScaling.none);
    } on PlatformException catch (e) {
      print("Failed to scale marker icon: '\${e.message}'.");
      return BitmapDescriptor.defaultMarker;
    }
  }

  // Helper function to load an image from assets
  Future<ui.Image> _loadImage(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final image =  await decodeImageFromList(data.buffer.asUint8List());
    return image;
  }


  @override
  Widget build(BuildContext context) {
    print("rebuilddd ####");
    return Scaffold(
      appBar: AppBar(
        title: Text('Random Markers in Paris'),
      ),
      body: FutureBuilder<void>(
        builder: (context, snapshot) {
          final markers = _addRandomMarkers(_randomLocations);
          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _parisCenter,
              zoom: 12,
            ),
            markers: markers ,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
              // Add random markers when the map is created
            },
          );
        }, future: _futureData,
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
