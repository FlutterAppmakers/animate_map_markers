# Animate Map Markers

Smooth scaling animations for Google Maps markers in Flutter.

**`animate_map_markers`** is a performant Flutter package that brings your custom Google Maps
markers to life with elegant scaling animations — whether your markers are built 
from raster images, SVGs, or Material Icons.

You can optionally connect it to a draggable bottom sheet:  
When the sheet expands, markers animate smoothly. When it collapses, the animation reverses
automatically.  
Don’t need a sheet? No problem — you can trigger animations manually based on your app's logic.

### ✨ Why use it?

- Smooth scaling animation for map markers
- Supports raster images, SVG assets, and Material Icons
- Optional integration with draggable bottom sheets
- Lightweight and easy to use

### Animated Map Markers

| Animated Map Markers                                                                                                 |
|----------------------------------------------------------------------------------------------------------------------|
| <img src="https://raw.githubusercontent.com/FlutterAppmakers/animate_map_markers/main/gifs/animated-markers.gif" width= "350"> |

### Animated Map Markers with Draggable Sheet

| Animated Map Markers With Draggable Sheet                                                                                 |
|---------------------------------------------------------------------------------------------------------------------------|
| <img src="https://raw.githubusercontent.com/FlutterAppmakers/animate_map_markers/main/gifs/animated-markers-sheet.gif" width="350"> |


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
  MarkerIconInfo.materialIcon(
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

## (Optional) Show a draggable bottom sheet

To show additional content when a marker is tapped, enable the draggable sheet by setting showDraggableSheet to true and providing a config:
```dart
return AnimatedMapMarkersWidget(
  defaultCameraLocation: LatLng(48.8566, 2.3522),
  zoomLevel: 12,
  scaledMarkerIconInfos: markerIconsInfos,
  showDraggableSheet: true, // Optional, defaults to false
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

## Enjoy 


| Animated Map Markers with Raster Image Support                                                                        |
|-----------------------------------------------------------------------------------------------------------------------|
| <img src="https://raw.githubusercontent.com/FlutterAppmakers/animate_map_markers/main/gifs/screenshot_raster.png" width= "350"> |


| Animated Map Markers  with SVG support                                                                                      |
|-----------------------------------------------------------------------------------------------------------------------------|
| <img src="https://raw.githubusercontent.com/FlutterAppmakers/animate_map_markers/main/gifs/screenshot_svg.png" width= "350"> |


| Animated Map Markers with Icon Support                                                                                        |
|---------------------------------------------------------------------------------------------------------------------|
| <img src="https://raw.githubusercontent.com/FlutterAppmakers/animate_map_markers/main/gifs/screenshot_icon.png" width= "350"> |

## Contributors


| Name            | GitHub | Linkedin |
|-----------------|-------------------------------------|-------------------------------------|
| Zarrami Khaoula | [github/FlutterAppmakers](https://github.com/FlutterAppmakers/) | [linkedin/khaoula-zarrami](https://www.linkedin.com/in/khaoula-zarrami-0b354358/) |