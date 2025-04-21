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
- Custom animation triggering via controller
- Lightweight and easy to use
### Animated Map Markers

| Animated Map Markers                                                                                                 |
|----------------------------------------------------------------------------------------------------------------------|
| <img src="https://github.com/FlutterAppmakers/animate_map_markers/blob/main/gifs/animated-markers.gif" width= "350"> |

### Animated Map Markers with Draggable Sheet

| Animated Map Markers With Draggable Sheet                                                                                 |
|---------------------------------------------------------------------------------------------------------------------------|
| <img src="https://github.com/FlutterAppmakers/animate_map_markers/blob/main/gifs/animated-markers-sheet.gif" width="350"> |


# Getting Started

## 1. Get an API Key
Visit [Google Cloud Maps Platform](https://cloud.google.com/maps-platform) and obtain an API key.

## 2. Enable Google Maps SDK for Each Platform and Directions API
* Go to [Google Developers Console](https://console.cloud.google.com), select your project, and open the Google Maps section from the navigation menu. Under APIs, enable Maps SDK for Android, Maps SDK for iOS, and Maps JavaScript API for web under the "Additional APIs" section.

* To enable Directions API, select "Directions API" in the "Additional APIs" section, then select "ENABLE".

> [!NOTE]
> Make sure the APIs you enabled are under the "Enabled APIs" section.

## 3. Refer the Documentation
For more details, see [Getting started with Google Maps Platform](https://developers.google.com/maps/gmp-get-started).

---

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

`animate_map_markers` revolves around managing animated map markers through a
`MarkerAnimationController`. Here’s the basic usage:
---

## 1. Create a map of animation controllers

```dart

final Map<String, MarkerAnimationController> _markerAnimationControllers = {};
```

## 2. Initialize the animation controller for each marker
You can initialize a MarkerAnimationController using either an asset image (raster or SVG) 
or a Material Icon.

## Using an asset image (PNG, JPG, or SVG):

```dart

final animationController = MarkerAnimationController(
  markerId: markerId,
  minMarkerSize: Size(35, 35),
  scale: 2.0, // 2x scale
  assetPath: 'assets/your_image.png', // or .svg
  duration: const Duration(milliseconds: 500),
  vsync: this, // your widget must use TickerProviderStateMixin
);
```


## Using a Material Icon:

```dart

final animationController = MarkerAnimationController(
  markerId: markerId,
  minMarkerSize: Size(35, 35),
  scale: 2.0, // 2x scale
   iconMarker:Icon(
       Icons.location_on, // Scale by specifying a larger size
       color: Colors.amber,
       size: 100,
       shadows: [
         Shadow(
         color: Colors.black.withOpacity(0.5),
         offset: Offset(2, 2),
         blurRadius: 4,
       ),
  duration: const Duration(milliseconds: 500),
  vsync: this, // your widget must use TickerProviderStateMixin
);
```

## 3. Add to map ,listen to stream and setup marker animation controller

Add the `MarkerAnimationController` to the map and listen to the stream and update the marker icon
and original icon:

```dart
///Add the `MarkerAnimationController` to the map
_markerAnimationControllers[markerId] = animationController;

/// Listen to the stream and update the marker icon
markerAnimationController.iconStream.listen(
(updatedIcon) {
  setState(() {
    _currentIcons[markerId]= updatedIcon;
  });
 },
);

/// Listen for the original icon and store it
markerAnimationController.originalIconStream.listen(
(originalIcon) {
  setState(() {
    _originalIcons[markerId]= originalIcon;
   });
  },
);

/// Setup the animation Controller
markerAnimationController.setupAnimationController();

```

## 4. Use animated icon in your marker

```dart

final markerHelper = MarkerHelper(
  markerAnimationController: _markerAnimationControllers,
);

final marker = markerHelper.createMarker(
  markerId: markerId,
  icon: _currentIcons[markerId] ?? _originalIcons[markerId] ?? BitmapDescriptor.defaultMarker,
  position: LatLng(48.8566, 2.3522),

);
```

---

# Optional Integration with a Draggable Bottom Sheet

You can optionally connect the animated markers to a draggable bottom sheet. When the bottom sheet
expands,
the markers animate smoothly, scaling up based on the sheet's movement. Similarly, when the sheet
collapses,
the markers will reverse their animation, scaling back down. This integration enhances the user
experience
by adding an interactive and visually appealing element to your map. If you don’t need a draggable
bottom sheet,
you can easily trigger the marker animations manually through your app's logic.

### Setup controllers for interaction

define a Controller to animate the draggable sheet and a ValueNotifier to keep track of the selected
marker

```dart

final markerSheetController = MarkerSheetController();

final ValueNotifier<
    String?> _selectedMarkerId = ValueNotifier<
    String?>(null);
```

#### Add Draggable sheet to display additional content when a marker is tapped

```dart
  MarkerDraggableSheetPage(
    selectedMarkerIdNotifier:: selectedMarkerId,
    markerAnimationControllers: _markerAnimationControllers,
    markerSheetController: markerSheetController,
    child:Column(
      children: [
    
      /// Add your custom  widgets here
    
        ],
      ),
    );
  },
),
```
### Marker tap interaction

To handle marker taps and trigger animations (like expanding a bottom sheet), pass an onMarkerTapped
callback to the MarkerHelper, update the selected marker and trigger the sheet animation

```dart

final markerHelper = MarkerHelper(
  onMarkerTapped: (String markerId) async {
    // Update the selected marker
    _selectedMarkerId.value = markerId;

    // Trigger the sheet animation
    markerSheetController.animateSheet();
  },
  markerAnimationController: _markerAnimationControllers,
);
```

# Clean up in dispose

Don't forget to stop all ongoing marker animations when your widget is disposed. This prevents
memory leaks and ensures everything is properly cleaned up:

```dart

final markerAnimationController = _markerAnimationControllers[markerId];
if (markerAnimationController != null) {
  markerAnimationController.stopAnimations();
  }
```

### 🛠 Customize animation curves

You can optionally customize the forward and reverse animation curves using the curve and
reverseCurve parameters of MarkerAnimationController.

By default:

curve is set to Curves.bounceOut

reverseCurve is set to Curves.linear

These provide a playful scale-up and a neutral scale-down animation. You can change them to suit
your app’s style.

```dart

final animationController = MarkerAnimationController(
  markerId: markerId,
  minMarkerSize: Size(35, 35),
  scale: 2.0,
  assetPath: 'assets/your_image.png',
  duration: const Duration(milliseconds: 500),
  vsync: this,
  curve: Curves.easeOutBack,
  reverseCurve: Curves.easeInCubic,
);
```

## Enjoy 


| Animated Map Markers with Raster Image Support                                                                        |
|-----------------------------------------------------------------------------------------------------------------------|
| <img src="https://github.com/FlutterAppmakers/animate_map_markers/blob/main/gifs/screenshot_raster.png" width= "350"> |


| Animated Map Markers  with SVG support                                                                             |
|--------------------------------------------------------------------------------------------------------------------|
| <img src="https://github.com/FlutterAppmakers/animate_map_markers/blob/main/gifs/screenshot_svg.png" width= "350"> |


| Animated Map Markers with Icon Support                                                                                          |
|---------------------------------------------------------------------------------------------------------------------|
| <img src="https://github.com/FlutterAppmakers/animate_map_markers/blob/main/gifs/screenshot_icon.png" width= "350"> |

# Contributors


| Name            | GitHub | Linkedin |
|-----------------|-------------------------------------|-------------------------------------|
| Zarrami Khaoula | [github/FlutterAppmakers](https://github.com/FlutterAppmakers/) | [linkedin/khaoula-zarrami](https://www.linkedin.com/in/khaoula-zarrami-0b354358/) |