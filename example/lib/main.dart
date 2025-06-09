// A sample Flutter app demonstrating how to use the `animate_map_markers` package.
//
// This example displays a Google Map centered on New York City with a set of predefined animated markers
// placed at notable locations. It includes five demos showing different ways to overlay content:
// - a basic animated map,
// - markers with a draggable sheet,
// - markers with a carousel slider,
// - markers using SVG assets.
// To run this example:
// - Ensure you have a valid Google Maps API key set up in your Android, iOS and web project configuration.

import 'package:animate_map_markers/animate_map_markers.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Fixed list of marker positions (New York City)

const staticLocations = [
  LatLng(40.7580, -73.9855),
  LatLng(40.7615, -73.9777),
  LatLng(40.7549, -73.9840),
  LatLng(40.7505, -73.9934),
  LatLng(40.7527, -73.9772),
  LatLng(40.7308, -73.9973),
];

/// Center location for the initial map camera

const newYorkCenter = LatLng(40.7580, -73.9855);

/// Minimum size for scaled map markers

const minMarkerSize = Size(35, 35);

void main() => runApp(const AnimatedMapMarkersDemoApp());

class AnimatedMapMarkersDemoApp extends StatelessWidget {
  const AnimatedMapMarkersDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animated Map Markers Demo',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const DemoHome(),
        '/basic': (_) => const BasicDemo(),
        '/with_draggable_sheet': (_) => const SheetDemo(),
        '/with_carousel': (_) => CarouselDemo(),
        '/elastic_carousel': (_) => ElasticCardDemo(),
        '/svg': (_) => const SvgMarkerDemo(),
      },
    );
  }
}

/// Home screen with navigation to different map marker demos

class DemoHome extends StatelessWidget {
  const DemoHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animated map markers demo')),
      body: ListView(
        children: const [
          DemoItem(title: 'Basic Animated Markers', route: '/basic'),
          DemoItem(title: 'Draggable Sheet', route: '/with_draggable_sheet'),
          DemoItem(title: 'Carousel Slider', route: '/with_carousel'),
          DemoItem(title: 'Elastic Carousel', route: '/elastic_carousel'),
          DemoItem(title: 'Svg', route: '/svg')
        ],
      ),
    );
  }
}

/// ListTile widget that navigates to a given demo route

class DemoItem extends StatelessWidget {
  final String title;
  final String route;

  const DemoItem({super.key, required this.title, required this.route});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }
}

/// Generates a list of MarkerIconInfo using predefined locations and a predefined marker asset

List<MarkerIconInfo> generateMarkers() {
  return List.generate(staticLocations.length, (i) {
    return MarkerIconInfo(
      markerId: MarkerId('marker_$i'),
      position: staticLocations[i],
      assetPath: 'assets/map_marker.png',
      minMarkerSize: minMarkerSize,
      // The scale factor applied to the marker icon during animation.
      // A value of 2.0 means the marker will grow to twice its minimum size.
      scale: 2.0,
    );
  });
}

// ================== Demos ===================

/// A simple demo showcasing how to use [AnimatedMapMarkersWidget] with
/// a set of basic animated markers on a Google Map.
///
/// This widget does not include any overlay content (like a sheet or slider),
/// and is useful as a minimal example of how to integrate animated markers.

class BasicDemo extends StatelessWidget {
  const BasicDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Basic Demo')),
      body: AnimatedMapMarkersWidget(
        defaultCameraLocation: newYorkCenter,
        zoomLevel: 13,
        scaledMarkerIconInfos: generateMarkers(),
      ),
    );
  }
}

/// A demo that displays [AnimatedMapMarkersWidget] along with a
/// draggable bottom sheet that overlays the map.
///
/// The draggable sheet displays a vertical list of [MarkerInfoCard] widgets,
/// which can be customized to show more details related to each marker.

class SheetDemo extends StatelessWidget {
  const SheetDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Draggable Sheet')),
      body: AnimatedMapMarkersWidget(
        defaultCameraLocation: newYorkCenter,
        zoomLevel: 13,
        scaledMarkerIconInfos: generateMarkers(),
        overlayContent: MarkerDraggableSheetConfig(
          showTopIndicator: false,
          boxShadow: const [
            BoxShadow(
              color: Colors.yellow,
              blurRadius: 10,
              spreadRadius: 1,
              offset: Offset(0, 1),
            )
          ],
          child: Column(
            children: List.generate(6, (_) => const MarkerInfoCard()),
          ),
        ),
      ),
    );
  }
}

/// Placeholder card used in the draggable sheet

class MarkerInfoCard extends StatelessWidget {
  const MarkerInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Row(
        children: [
          Container(height: 100, width: 100, color: Colors.black12),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 20, width: 240, color: Colors.black12),
                const SizedBox(height: 5),
                Container(height: 20, width: 180, color: Colors.black12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A demo that showcases [AnimatedMapMarkersWidget] with a swipeable
/// carousel slider overlay displaying custom content.
///
/// This demo demonstrates how to pair animated map markers with a
/// horizontally scrollable [MarkerSwipeCardConfig], which can be used
/// to present rich location-based content such as restaurant cards,
/// event information, or other interactive UI elements.

class CarouselDemo extends StatelessWidget {
  CarouselDemo({super.key});

  final List<Widget> restaurantCards = sample
      .map((restaurant) => RestaurantCard(restaurant: restaurant))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carousel Slider')),
      body: AnimatedMapMarkersWidget(
        defaultCameraLocation: newYorkCenter,
        zoomLevel: 13,
        scaledMarkerIconInfos: generateMarkers(),
        overlayContent: MarkerSwipeCardConfig(
          bottom: 55.0,
          items: restaurantCards,
          options: MarkerSwipeCardOption(
            height: 200.0,
            viewportFraction: 0.9,
            onPageChanged: (_, __) {},
          ),
        ),
      ),
    );
  }
}

/// A demo that showcases [AnimatedMapMarkersWidget] with non-scrollable
/// cards that animate into view with an elastic out effect when tapping a marker.

class ElasticCardDemo extends StatelessWidget {
  ElasticCardDemo({super.key});

  final List<Widget> restaurantCards = sample
      .map((restaurant) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: RestaurantCard(restaurant: restaurant),
          ))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Elastic Card Animation')),
      body: AnimatedMapMarkersWidget(
        defaultCameraLocation: newYorkCenter,
        zoomLevel: 13,
        scaledMarkerIconInfos: generateMarkers(),
        overlayContent: MarkerSwipeCardConfig(
          bottom: 55.0,
          items: restaurantCards,
          options: NeverScrollCardOption(
            height: 200.0,
            onPageChanged: (_, __) {},
          ),
        ),
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;

  RestaurantCard({super.key, required this.restaurant});

  final TextStyle restaurantTextStyle =
      TextStyle(color: Colors.grey[700], fontSize: 11);
  final TextStyle nameTextStyle =
      TextStyle(fontWeight: FontWeight.w500, fontSize: 15);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(
                      restaurant.image,
                      fit: BoxFit.cover,
                      width: 140,
                      height: 140,
                    ),
                  ),
                  SizedBox(
                    width: 2.0,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 8.0,
                        ),
                        Text(restaurant.name, style: nameTextStyle),
                        const SizedBox(height: 4),
                        Text(restaurant.cuisine, style: restaurantTextStyle),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("${restaurant.rating}",
                                style: restaurantTextStyle),
                            const SizedBox(width: 8),
                            Icon(Icons.star, color: Colors.amber, size: 20),
                          ],
                        ),
                        Text(
                          restaurant.location,
                          style: restaurantTextStyle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 150,
            right: 0,
            bottom: 20,
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.grey[500],
                  size: 20,
                ),
                Text(
                  restaurant.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: restaurantTextStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Demo showing how to use SVG assets as animated map markers.
///
/// This example uses static marker positions and SVG images located in
/// the assets folder (`assets/svg_map_marker.svg`).

class SvgMarkerDemo extends StatelessWidget {
  const SvgMarkerDemo({super.key});

  static const Duration duration = Duration(milliseconds: 500);

  /// Generates markers using an SVG asset.
  List<MarkerIconInfo> _buildSvgMarkers() {
    return List.generate(staticLocations.length, (i) {
      return MarkerIconInfo(
        markerId: MarkerId('svg_marker_$i'),
        position: staticLocations[i],
        assetPath: 'assets/map_marker.svg',
        minMarkerSize: const Size(40, 40),
        scale: 1.8,
        curve: Curves.fastOutSlowIn,
        reverseCurve: Curves.decelerate,
        duration: duration,
        reverseDuration: duration,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SVG Animated Markers')),
      body: AnimatedMapMarkersWidget(
        defaultCameraLocation: newYorkCenter,
        zoomLevel: 13,
        scaledMarkerIconInfos: _buildSvgMarkers(),
      ),
    );
  }
}

class Restaurant {
  final String name;
  final String image;
  final double rating;
  final String cuisine;
  final String description;
  final String location;

  const Restaurant({
    required this.name,
    required this.image,
    required this.rating,
    required this.cuisine,
    required this.description,
    required this.location,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      name: json['name'] as String,
      image: json['image'] as String,
      rating: (json['rating'] as num).toDouble(),
      cuisine: json['cuisine'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'rating': rating,
      'cuisine': cuisine,
      'description': description,
      'location': location,
    };
  }
}

List<Restaurant> sample = [
  Restaurant(
    name: "Joe's Pizza",
    image:
        "https://cdn.pixabay.com/photo/2017/08/10/16/11/burj-al-arab-2624317_1280.jpg",
    rating: 4.7,
    cuisine: "Pizza",
    description: "0.2 km fom downTown",
    location: "7 Carmine St, New York, NY",
  ),
  Restaurant(
    name: "Katz's Delicatessen",
    image:
        "https://cdn.pixabay.com/photo/2017/03/15/16/55/jumeirah-beach-hotel-2146761_1280.jpg",
    rating: 4.6,
    cuisine: "Deli",
    description: "0.1 km fom downTown",
    location: "205 E Houston St, New York, NY",
  ),
  Restaurant(
    name: "Shake Shack",
    image:
        "https://cdn.pixabay.com/photo/2024/02/25/19/25/invalidendom-8596490_1280.jpg",
    rating: 4.5,
    cuisine: "Burgers",
    description: "0.1 km fom downTown",
    location: "Madison Square Park, New York, NY",
  ),
  Restaurant(
    name: "The Halal Guys",
    image:
        "https://cdn.pixabay.com/photo/2017/01/27/22/19/dubai-2014317_1280.jpg",
    rating: 4.4,
    cuisine: "Middle Eastern",
    description: "0.1 km fom downTown",
    location: "W 53rd St Ave, New York, NY",
  ),
  Restaurant(
    name: "Le Bernardin",
    image:
        "https://cdn.pixabay.com/photo/2017/01/28/19/31/landscape-2016308_1280.jpg",
    rating: 4.8,
    cuisine: "French/Seafood",
    description: "0.2 km fom downTown",
    location: "155 W 51st St, New York, NY",
  ),
  Restaurant(
    name: "Taco Fiesta",
    image:
        "https://cdn.pixabay.com/photo/2020/05/22/08/17/breakfast-5204352_1280.jpg",
    rating: 4.3,
    cuisine: "Mexican",
    description: "0.3 km fom downTown",
    location: "88 9th Ave, New York, NY",
  ),
];
