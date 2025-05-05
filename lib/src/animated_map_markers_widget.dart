import 'dart:async';
import 'package:animate_map_markers/src/draggable_sheet/draggable_sheet_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../animate_map_markers.dart';

class AnimatedMapMarkersWidget extends StatefulWidget {
  const AnimatedMapMarkersWidget({
    super.key,
    required this.defaultCameraLocation,
    required this.zoomLevel,
    this.style,
    this.onMapCreated,
    required this.scaledMarkerIconInfos,
    this.showDraggableSheet = false,
    this.config = const MarkerDraggableSheetConfig(child: SizedBox()),
    // other google maps params
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
    this.compassEnabled = true,
    this.layoutDirection,
    this.mapToolbarEnabled = true,
    this.cameraTargetBounds = CameraTargetBounds.unbounded,
    this.mapType = MapType.normal,
    this.minMaxZoomPreference = MinMaxZoomPreference.unbounded,
    this.rotateGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.zoomControlsEnabled = true,
    this.zoomGesturesEnabled = true,
    this.liteModeEnabled = false,
    this.tiltGesturesEnabled = true,
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = true,
    this.padding = const EdgeInsets.all(0),
    this.indoorViewEnabled = false,
    this.trafficEnabled = false,
    this.buildingsEnabled = true,
    this.polygons = const <Polygon>{},
    this.markers = const <Marker>{},
    this.circles = const <Circle>{},
    this.onCameraMoveStarted,
    this.onCameraMove,
    this.tileOverlays = const <TileOverlay>{},
    this.onCameraIdle,
    this.onTap,
    this.onLongPress,

  });

  /// The initial location of the map's camera.
  /// If null, initial location is [sourceLatLng].
  final LatLng defaultCameraLocation;

  /// The zoom level of the camera.
  final double zoomLevel;

  /// Callback method for when the map is ready to be used.
  ///
  /// Used to receive a [GoogleMapController] for this [GoogleMap].
  final void Function(GoogleMapController)? onMapCreated;

  /// Markers to be placed on the map. (apart from animated map markers).
  final Set<Marker> markers;

  /// The configuration object for customizing the behavior and appearance of the draggable sheet.
  ///
  /// Provides properties such as `initialChildSize`, `maxChildSize`, `curve`, `duration`,
  /// and more to control how the sheet behaves and looks.
  ///
  /// Defaults are defined within [MarkerDraggableSheetConfig].
  final MarkerDraggableSheetConfig config;

  /// Controls whether the draggable marker info sheet is shown below the map.
  /// Set to `true` to show the sheet, or `false` to hide it. Defaults to `false`.
  final bool showDraggableSheet;

/// scaled markers infos
final List<MarkerIconInfo> scaledMarkerIconInfos;

  /////////////////////////////////////////////////
  // OTHER GOOGLE MAPS PARAMS
  /////////////////////////////////////////////////

  /// The style for  the map.
  final String? style;

  /// Which gestures should be consumed by the map.
  ///
  /// It is possible for other gesture recognizers to be competing with the map on pointer
  /// events, e.g if the map is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The map will claim gestures that are recognized by any of the
  /// recognizers on this list.
  ///
  /// When this set is empty, the map will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  /// True if the map should show a compass when rotated.
  final bool compassEnabled;

  /// The layout direction to use for the embedded view.
  ///
  /// If this is null, the ambient [Directionality] is used instead. If there is
  /// no ambient [Directionality], [TextDirection.ltr] is used.
  final TextDirection? layoutDirection;

  /// True if the map should show a toolbar when you interact with the map. Android only.
  final bool mapToolbarEnabled;

  /// Geographical bounding box for the camera target.
  final CameraTargetBounds cameraTargetBounds;

  /// Type of map tiles to be rendered.
  final MapType mapType;

  /// Preferred bounds for the camera zoom level.
  ///
  /// Actual bounds depend on map data and device.
  final MinMaxZoomPreference minMaxZoomPreference;

  /// True if the map view should respond to rotate gestures.
  final bool rotateGesturesEnabled;

  /// True if the map view should respond to scroll gestures.
  final bool scrollGesturesEnabled;

  /// True if the map view should show zoom controls. This includes two buttons
  /// to zoom in and zoom out. The default value is to show zoom controls.
  ///
  /// This is only supported on Android. And this field is silently ignored on iOS.
  final bool zoomControlsEnabled;

  /// True if the map view should respond to zoom gestures.
  final bool zoomGesturesEnabled;

  // True if the map view should be in lite mode. Android only.
  ///
  /// See https://developers.google.com/maps/documentation/android-sdk/lite#overview_of_lite_mode for more details.
  final bool liteModeEnabled;

  /// True if the map view should respond to tilt gestures.
  final bool tiltGesturesEnabled;

  /// True if a "My Location" layer should be shown on the map.
  ///
  /// This layer includes a location indicator at the current device location,
  /// as well as a My Location button.
  /// * The indicator is a small blue dot if the device is stationary, or a
  /// chevron if the device is moving.
  /// * The My Location button animates to focus on the user's current location
  /// if the user's location is currently known.
  ///
  /// Enabling this feature requires adding location permissions to both native
  /// platforms of your app.
  /// * On Android add either
  /// `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />`
  /// or `<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />`
  /// to your `AndroidManifest.xml` file. `ACCESS_COARSE_LOCATION` returns a
  /// location with an accuracy approximately equivalent to a city block, while
  /// `ACCESS_FINE_LOCATION` returns as precise a location as possible, although
  /// it consumes more battery power. You will also need to request these
  /// permissions during run-time. If they are not granted, the My Location
  /// feature will fail silently.
  /// * On iOS add a `NSLocationWhenInUseUsageDescription` key to your
  /// `Info.plist` file. This will automatically prompt the user for permissions
  /// when the map tries to turn on the My Location layer.
  final bool myLocationEnabled;

  /// Enables or disables the my-location button.
  ///
  /// The my-location button causes the camera to move such that the user's
  /// location is in the center of the map. If the button is enabled, it is
  /// only shown when the my-location layer is enabled.
  ///
  /// By default, the my-location button is enabled (and hence shown when the
  /// my-location layer is enabled).
  ///
  /// See also:
  ///   * [myLocationEnabled] parameter.
  final bool myLocationButtonEnabled;

  /// Padding to be set on map. See https://developers.google.com/maps/documentation/android-sdk/map#map_padding for more details.
  final EdgeInsets padding;

  /// Enables or disables the indoor view from the map
  final bool indoorViewEnabled;

  /// Enables or disables the traffic layer of the map
  final bool trafficEnabled;


  /// Enables or disables showing 3D buildings where available
  final bool buildingsEnabled;

  /// Polygons to be placed on the map.
  final Set<Polygon> polygons;

  /// Circles to be placed on the map.
  final Set<Circle> circles;

  /// Called when the camera starts moving.
  ///
  /// This can be initiated by the following:
  /// 1. Non-gesture animation initiated in response to user actions.
  ///    For example: zoom buttons, my location button, or marker clicks.
  /// 2. Programmatically initiated animation.
  /// 3. Camera motion initiated in response to user gestures on the map.
  ///    For example: pan, tilt, pinch to zoom, or rotate.
  final VoidCallback? onCameraMoveStarted;

  /// Called repeatedly as the camera continues to move after an
  /// onCameraMoveStarted call.
  ///
  /// This may be called as often as once every frame and should
  /// not perform expensive operations.
  final CameraPositionCallback? onCameraMove;

  /// Tile overlays to be placed on the map.
  final Set<TileOverlay> tileOverlays;

  /// Called when camera movement has ended, there are no pending
  /// animations and the user has stopped interacting with the map.
  final VoidCallback? onCameraIdle;

  /// Called every time a [GoogleMap] is tapped.
  final ArgumentCallback<LatLng>? onTap;

  /// Called every time a [GoogleMap] is long pressed.
  final ArgumentCallback<LatLng>? onLongPress;

  @override
  State<AnimatedMapMarkersWidget> createState() => _AnimatedMapMarkersWidgetState();
}

class _AnimatedMapMarkersWidgetState extends State<AnimatedMapMarkersWidget> with TickerProviderStateMixin{

  final _mapsControllerCompleter = Completer<GoogleMapController>();

  Future<GoogleMapController> getGoogleMapsController() =>
      _mapsControllerCompleter.future;

  /// Animated Markers to be placed on the map.
  final _markersMap = <MarkerId, Marker>{};

  /// Map to store animation controllers for each marker
  final Map<MarkerId,MarkerAnimationController>  _markerAnimationControllers = {};

  final markerSheetController = MarkerSheetController();

  late Future<void> _futureData;

  /// ValueNotifier for tracking the selected marker
  final ValueNotifier<
      MarkerId?> _selectedMarkerId = ValueNotifier<
      MarkerId?>(null);

  final ValueNotifier<Map<MarkerId, BitmapDescriptor>> _currentIconsNotifier = ValueNotifier<Map<MarkerId, BitmapDescriptor>>({});
  final ValueNotifier<Map<MarkerId, BitmapDescriptor>> _originalIconsNotifier = ValueNotifier<Map<MarkerId, BitmapDescriptor>>({});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _futureData =  _initializeAnimationMarkers();
  }

  /// Initialize the animation controller for each marker
  Future<void> _initializeAnimation(MarkerIconInfo markerIconInfo) async {
    final markerId = markerIconInfo.markerId;
    /// Initialize the controller
    final markerAnimationController = MarkerAnimationController(
        markerId: markerId,
        minMarkerSize: markerIconInfo.minMarkerSize,
        scale:markerIconInfo.scale,
        assetPath: markerIconInfo.assetPath,
        iconMarker: markerIconInfo.icon,
        duration: markerIconInfo.duration,
        reverseDuration: markerIconInfo.reverseDuration,
        curve: markerIconInfo.curve,
        reverseCurve: markerIconInfo.reverseCurve,
        vsync: this
    );

    _markerAnimationControllers[markerId] = markerAnimationController;


    /// Listen to the stream and update the marker icon
    markerAnimationController.iconStream.listen((updatedIcon) {
      _currentIconsNotifier.value = Map.from(_currentIconsNotifier.value)..[markerId] = updatedIcon;
    });

    /// Listen for the original icon and store it
    markerAnimationController.originalIconStream.listen((originalIcon) {
      _originalIconsNotifier.value = Map.from(_originalIconsNotifier.value)..[markerId] = originalIcon;
    });

    /// Start the animation
    markerAnimationController.setupAnimationController();
  }

  /// Function to initialize animation markers
  Future<void> _initializeAnimationMarkers() async{
    for (var markerInfo in widget.scaledMarkerIconInfos) {
      await _initializeAnimation(markerInfo);
    }
  }

  /// setting source and destination markers
  Future<void>_setScaledMarkers(Map<MarkerId, BitmapDescriptor> currentIcons, Map<MarkerId, BitmapDescriptor> originalIcons) async {
    _markersMap.clear();
    for (var markerInfo in widget.scaledMarkerIconInfos) {
      if (markerInfo.visible) {
        final markerHelper = MarkerHelper(
          onMarkerTapped: (MarkerId markerId) async {
            _selectedMarkerId.value = markerId;
            /// Trigger the sheet animation
            markerSheetController.animateSheet();

          },
          markerAnimationController: _markerAnimationControllers,
        );

        final  marker =    markerHelper.createMarker(
          markerIconInfo: markerInfo,
          icon :  currentIcons[markerInfo.markerId] ?? originalIcons[markerInfo.markerId] ?? BitmapDescriptor.defaultMarker,
        );

        _markersMap[markerInfo.markerId] = marker;
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<void>(
          future: _futureData,
          builder: (context, snap) {
            final connectionWaiting = snap.connectionState == ConnectionState.waiting;
            if (snap.hasError) {
              return Center(child: Text('Error initializing markers: ${snap.error}'));
            }
            return ValueListenableBuilder<Map<MarkerId, BitmapDescriptor>>(
              valueListenable: _currentIconsNotifier,
              builder: (context, currentIcons, _) {
                return ValueListenableBuilder<Map<MarkerId, BitmapDescriptor>>(
                  valueListenable: _originalIconsNotifier,
                  builder: (context, originalIcons, _) {
                    if (!connectionWaiting) {
                      // Only scale markers after data is ready
                      _setScaledMarkers(currentIcons, originalIcons);
                    }

                    return GoogleMap(
                      initialCameraPosition: CameraPosition(
                          target: widget.defaultCameraLocation,
                        zoom: widget.zoomLevel
                      ),
                      markers: connectionWaiting
                          ? widget.markers // fallback (no scaled markers yet)
                          : {..._markersMap.values, ...widget.markers},
                      style: widget.style,
                      onMapCreated: (controller) {
                        _mapsControllerCompleter.complete(controller);
                        if (widget.onMapCreated != null) {
                          return widget.onMapCreated!(controller);
                        }
                      },
                      /////////////////////////////////////////////////
                      // OTHER GOOGLE MAPS PARAMS
                      /////////////////////////////////////////////////
                      gestureRecognizers: widget.gestureRecognizers,
                      compassEnabled: widget.compassEnabled,
                      layoutDirection: widget.layoutDirection,
                      mapToolbarEnabled: widget.mapToolbarEnabled,
                      cameraTargetBounds: widget.cameraTargetBounds,
                      mapType: widget.mapType,
                      minMaxZoomPreference: widget.minMaxZoomPreference,
                      rotateGesturesEnabled: widget.rotateGesturesEnabled,
                      scrollGesturesEnabled: widget.scrollGesturesEnabled,
                      zoomControlsEnabled: widget.zoomControlsEnabled,
                      zoomGesturesEnabled: widget.zoomGesturesEnabled,
                      liteModeEnabled: widget.liteModeEnabled,
                      tiltGesturesEnabled: widget.tiltGesturesEnabled,
                      myLocationEnabled: widget.myLocationEnabled,
                      myLocationButtonEnabled: widget.myLocationButtonEnabled,
                      padding: widget.padding,
                      indoorViewEnabled: widget.indoorViewEnabled,
                      trafficEnabled: widget.trafficEnabled,
                      buildingsEnabled: widget.buildingsEnabled,
                      polygons: widget.polygons,
                      circles: widget.circles,
                      onCameraMoveStarted: widget.onCameraMoveStarted,
                      tileOverlays: widget.tileOverlays,
                      onCameraMove: widget.onCameraMove,
                      onCameraIdle: widget.onCameraIdle,
                      onTap: widget.onTap,
                      onLongPress: widget.onLongPress,
                    );
                  }
                );
              }
            );
          }
        ),

        /// Draggable sheet to display additional content when a marker is tapped
        DraggableSheetWrapper(
            showDraggableSheet: widget.showDraggableSheet,
            selectedMarkerIdNotifier: _selectedMarkerId,
            markerAnimationControllers: _markerAnimationControllers,
            markerSheetController: markerSheetController,
            config: widget.config
        ),

      ],
    );
  }

  /// Stop all ongoing animations for markers.
  void stopMarkerAnimations() {
    for (var markerInfo in widget.scaledMarkerIconInfos) {
      final markerId = markerInfo.markerId;
      final markerAnimationController = _markerAnimationControllers[markerId];
      if(markerAnimationController != null) {
        markerAnimationController.stopAnimations();
      }
    }
  }

  @override
  void dispose() {
    if (_mapsControllerCompleter.isCompleted) {
      _mapsControllerCompleter.future.then(
            (controller) => controller.dispose(),
      );
    }

    stopMarkerAnimations();
    _selectedMarkerId.dispose();
    _currentIconsNotifier.dispose();
    _originalIconsNotifier.dispose();
    super.dispose();
  }

}
