# Animate Map Markers

Animation utility for the google_maps_flutter package.

animate_map_markers is a flexible and performant Flutter package that brings your Google Maps markers to life with 
smooth scaling animations
— whether they’re built from raster images, SVGs, or Material Icons.

✨ Features:
- Smooth, customizable scaling animations for Google Maps markers.

- Optional integration with a draggable bottom sheet: When the sheet expands, markers animate. When the sheet collapses, 
animations reverse automatically.

- Built-in support for a carousel-style card slider synced with markers. Display interactive information
 (like restaurant details, place cards, etc.) under the map. Automatically syncs the selected card with the 
active marker on the map.

✨ Why use it?
- Bring your map to life with smooth and natural marker animations.

- Works with any marker style — raster images, SVGs, or Material Icons.

- Seamless UI integration with optional carousel sliders or draggable bottom sheets.

- Lightweight and easy to use

### Animated Map Markers with Carousel Slider


| Animated Map Markers with Carousel Slider                                                                                       |
|---------------------------------------------------------------------------------------------------------------------------------|
| <img src="https://raw.githubusercontent.com/FlutterAppmakers/animate_map_markers/main/gifs/animated-markers-carousel.gif" height= "400"> |

### Animated Map Markers

| Animated Map Markers                                                                                                            |
|---------------------------------------------------------------------------------------------------------------------------------|
| <img src="https://raw.githubusercontent.com/FlutterAppmakers/animate_map_markers/main/gifs/animated-markers.gif" height= "400"> |

### Animated Map Markers with Draggable Sheet

| Animated Map Markers With Draggable Sheet                                                                                             |
|---------------------------------------------------------------------------------------------------------------------------------------|
| <img src="https://raw.githubusercontent.com/FlutterAppmakers/animate_map_markers/main/gifs/animated-markers-sheet.gif" height= "400"> |


## Getting Started

## 1. Get an API Key
Visit [Google Cloud Maps Platform](https://cloud.google.com/maps-platform) and obtain an API key.

## 2. Enable Google Maps SDK for Each Platform and Directions API
* Go to [Google Developers Console](https://console.cloud.google.com), select your project, and open the Google Maps section from the navigation menu. Under APIs, enable Maps SDK for Android, Maps SDK for iOS, and Maps JavaScript API for web under the "Additional APIs" section.

* To enable Directions API, select "Directions API" in the "Additional APIs" section, then select "ENABLE".

> [!NOTE]
> Make sure the APIs you enabled are under the "Enabled APIs" section.

## 3. Refer the Documentation
For more details, see [Getting started with Google Maps Platform](https://developers.google.com/maps/gmp-get-started).


#  Platform-Specific Setup

## Android
> [!NOTE]
> Refer to the platform specific setup for google maps [here](https://pub.dev/packages/google_maps_flutter#android)

Specify your API key in the application manifest `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...
  <application ...
    <meta-data android:name="com.google.android.geo.API_KEY"
               android:value="YOUR KEY HERE"/>
```

## iOS
> [!NOTE]
> Refer to the platform specific setup for google maps [here](https://pub.dev/packages/google_maps_flutter#ios)

Specify your API key in the application delegate `ios/Runner/AppDelegate.m`:

```objectivec
#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "GoogleMaps/GoogleMaps.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GMSServices provideAPIKey:@"YOUR KEY HERE"];
  [GeneratedPluginRegistrant registerWithRegistry:self];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
@end
```

Or in your swift code, specify your API key in the application delegate `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR KEY HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

# Syntax
This guide will walk you through the steps to implement animated markers on Google Maps in Flutter using the AnimatedMapMarkersWidget.
You can optionally integrate a draggable bottom sheet for added interactivity.

## 1. Create your MarkerIconInfo list
Each MarkerIconInfo represents a marker you want to animate on the map, including its position, 
appearance, and scale animation.

### Using an asset image (PNG, JPG, or SVG):

```dart
final markerIconsInfos = List.generate(7, (index) {
  return MarkerIconInfo(
    markerId: MarkerId('marker_$index'),
    position: position,
    assetPath: 'assets/map_marker.png', // or .svg
    minMarkerSize: Size(42, 48),
    scale: 1.7,
  );
});
```

### Using a Material Icon:
```dart
final markerIconsInfos = [
  MarkerIconInfo(
    markerId: MarkerId('marker_1'),
    position: LatLng(48.8566, 2.3522),
    icon: Icon(
      Icons.location_on,
      color: Colors.amber,
      size: 100,
      shadows: [
        Shadow(
          color: Colors.black.withOpacity(0.5),
          offset: Offset(2, 2),
          blurRadius: 4,
        ),
      ],
    ),
    minMarkerSize: Size(35, 35),
    scale: 1.7,
  ),
];


```
## 2. Use AnimatedMapMarkersWidget in your widget tree

This widget handles animated scaling for your markers
```dart
return AnimatedMapMarkersWidget(
  defaultCameraLocation: LatLng(48.8566, 2.3522),
  zoomLevel: 12,
  scaledMarkerIconInfos: markerIconsInfos,
);
```

## Show a carousel of marker-related content

To display a swipeable carousel linked to map markers, provide a MarkerSwipeCardConfig to the overlayContent parameter:

```dart
return AnimatedMapMarkersWidget(
  defaultCameraLocation: LatLng(48.8566, 2.3522),
  zoomLevel: 12,
  scaledMarkerIconInfos: markerIconsInfos,
  overlayContent:MarkerSwipeCardConfig(
   bottom: 30,
 /// Provide a list of widgets to display in the carousel (e.g. restaurant cards)
  items: restaurantCards,
   options: MarkerSwipeCardOption(
   height: 270,
   enlargeCenterPage: true,
   onPageChanged: (index, reason) {
   /// perform additional actions when the carousel page changes
   },
  ),
 ),
);


```

## Show a draggable bottom sheet

To display a draggable bottom sheet  when a marker is tapped, provide a MarkerDraggableSheetConfig to the overlayContent parameter:

```dart
return AnimatedMapMarkersWidget(
  defaultCameraLocation: LatLng(48.8566, 2.3522),
  zoomLevel: 12,
  scaledMarkerIconInfos: markerIconsInfos,
  overlayContent: MarkerDraggableSheetConfig(
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

```

### 🛠 Customize animation curves

You can optionally customize the forward and reverse animation curves using the curve and
reverseCurve parameters of MarkerIconInfo.
You can also control animation timing using duration and reverseDuration.

By default:

- curve is set to Curves.bounceOut

- reverseCurve is set to Curves.linear

- duration is set to Duration(milliseconds: 500),

- reverseDuration is set to Duration(milliseconds: 500),

These provide a playful scale-up and a neutral scale-down animation. You can change them to suit
your app’s style.

```dart
final markerIconsInfos = [
  MarkerIconInfo(
    markerId: MarkerId('marker_1'),
    position: LatLng(48.8566, 2.3522),
    assetPath: 'assets/your_image.svg',
    minMarkerSize: Size(35, 35),
    scale: 2.0,
    duration: const Duration(milliseconds: 700),
    reverseDuration: const Duration(milliseconds: 300),
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeInCubic,
  ),
];

```

| Animated Map Markers with Raster Image Support                                                                                   |
|----------------------------------------------------------------------------------------------------------------------------------|
| <img src="https://raw.githubusercontent.com/FlutterAppmakers/animate_map_markers/main/gifs/screenshot_raster.png" height= "400"> |


| Animated Map Markers  with SVG support                                                                                        |
|-------------------------------------------------------------------------------------------------------------------------------|
| <img src="https://raw.githubusercontent.com/FlutterAppmakers/animate_map_markers/main/gifs/screenshot_svg.png" height= "400"> |


| Animated Map Markers with Icon Support                                                                                         |
|--------------------------------------------------------------------------------------------------------------------------------|
| <img src="https://raw.githubusercontent.com/FlutterAppmakers/animate_map_markers/main/gifs/screenshot_icon.png" height= "400"> |

## Contributors


| Name            | GitHub | Linkedin |
|-----------------|-------------------------------------|-------------------------------------|
| Zarrami Khaoula | [github/FlutterAppmakers](https://github.com/FlutterAppmakers/) | [linkedin/khaoula-zarrami](https://www.linkedin.com/in/khaoula-zarrami-0b354358/) |