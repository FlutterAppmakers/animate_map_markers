# Animate Map Markers

Smooth scaling animations for Google Maps markers in Flutter.

**`animate_map_markers`** is a performant Flutter package that brings your custom Google Maps markers to life with elegant scaling animations.

You can optionally connect it to a draggable bottom sheet:  
When the sheet expands, markers animate smoothly. When it collapses, the animation reverses automatically.  
Don’t need a sheet? No problem — you can trigger animations manually based on your app's logic.

### ✨ Why use it?

- Smooth scaling animation for map markers
- Optional integration with draggable bottom sheets
- Custom animation triggering via controller
- Lightweight and easy to use


---

#  Basics

---

#  Syntax
`animate_map_markers` revolves around managing animated map markers through a `MarkerAnimationController`. Here’s the basic usage:
---

## 1. Create a map of animation controllers

```dart
final Map<String, MarkerAnimationController> _markerAnimationControllers = {};
```

## 2. Initialize the animation controller for each marker


```dart
final animationController = MarkerAnimationController(
  markerId: markerId,
  startSize: const Size(35, 35),
  endSize: const Size(70, 70), // 2x scale
  assetPath: 'assets/your_image.png',
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

markerAnimationController.setupAnimationController();

```

## 4. Use animated icon in your marker

```dart

final markerHelper = MarkerHelper(
markerAnimationController: _markerAnimationControllers,
);

final  marker =    markerHelper.createMarker(
markerId:markerId,
icon :  _currentIcons[markerId] ?? _originalIcons[markerId] ?? BitmapDescriptor.defaultMarker,
position:  LatLng(48.8566, 2.3522),

);
```

---

#  Optional Integration with a Draggable Bottom Sheet

You can optionally connect the animated markers to a draggable bottom sheet. When the bottom sheet expands, 
the markers animate smoothly, scaling up based on the sheet's movement. Similarly, when the sheet collapses,
the markers will reverse their animation, scaling back down. This integration enhances the user experience
by adding an interactive and visually appealing element to your map. If you don’t need a draggable bottom sheet, 
you can easily trigger the marker animations manually through your app's logic.

### Setup controllers for interaction


define a Controller to animate the draggable sheet and a ValueNotifier to keep track of the selected marker

```dart
final markerSheetController = MarkerSheetController();

final ValueNotifier<
    String?> _selectedMarkerId = ValueNotifier<
    String?>(null);
```
#### Add Draggable sheet to display additional content when a marker is tapped
```dart
ValueListenableBuilder(
valueListenable: _selectedMarkerId,
builder: (context, selectedMarkerId, _) {
return MarkerDraggableSheetPage(
selectedMarkerId: selectedMarkerId,
markerAnimationControllers:  _markerAnimationControllers,
markerSheetController: markerSheetController,
child:Column(
children: [

  //.... // Add your custom  widgets here

],
),  
);
}
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

Don't forget to stop all ongoing marker animations when your widget is disposed. This prevents memory leaks and ensures everything is properly cleaned up:

```dart

final markerAnimationController = _markerAnimationControllers[markerId];
if (markerAnimationController != null) {
  markerAnimationController.stopAnimations();
}
```