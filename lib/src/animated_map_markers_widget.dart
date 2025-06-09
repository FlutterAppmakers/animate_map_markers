import 'dart:async';
import 'package:animate_map_markers/src/scale_marker_transformer.dart';
import 'package:animate_map_markers/src/swipe_cards/base_swipe_card_option.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../animate_map_markers.dart';

/// A widget that displays a [GoogleMap] with animated, scalable markers.
///
/// The markers animate by scaling their size smoothly using custom icons. Optionally,
/// a draggable sheet can appear below the map when a marker is tapped, showing additional information.

class AnimatedMapMarkersWidget extends StatefulWidget {
  /// Creates an [AnimatedMapMarkersWidget].
  ///
  /// The [defaultCameraLocation], [zoomLevel], and [scaledMarkerIconInfos] must not be null.
  /// Optionally show a draggable sheet and pass additional [GoogleMap] parameters.
  const AnimatedMapMarkersWidget({
    super.key,
    required this.defaultCameraLocation,
    required this.zoomLevel,
    this.style,
    this.onMapCreated,
    required this.scaledMarkerIconInfos,
    this.animateToMarker = true,
    this.overlayContent,
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

  /// Provides custom overlay content to display above the map, such as a
  /// draggable bottom sheet or a horizontal swipeable card view (PageView).
  ///
  /// Use this property to define how additional marker-related UI should be
  /// presented. It accepts subclasses of [MarkerOverlayContent], such as:
  ///
  /// - [MarkerDraggableSheetConfig]: displays a draggable bottom sheet
  ///   containing marker information.
  /// - [MarkerSwipeCardConfig]: displays a swipeable horizontal card layout
  ///   that syncs with markers on the map.
  ///
  /// If `overlayContent` is `null`, no overlay will be shown.

  final MarkerOverlayContent? overlayContent;

  /// The list of markers that will be animated using scaling effects.
  ///
  /// Each [MarkerIconInfo] provides configuration such as marker ID, asset path, scale, and animation settings.
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

  /// Whether to animate the camera to the marker’s position when a marker is tapped.
  ///
  /// If `true`, the map camera will smoothly animate to center on the marker.
  /// If `false`, the camera remains in its current position.
  /// Defaults to `true` for a more intuitive user experience.
  final bool animateToMarker;

  @override
  State<AnimatedMapMarkersWidget> createState() =>
      _AnimatedMapMarkersWidgetState();
}

class _AnimatedMapMarkersWidgetState extends State<AnimatedMapMarkersWidget>
    with TickerProviderStateMixin {
  final _mapsControllerCompleter = Completer<GoogleMapController>();

  Future<GoogleMapController> getGoogleMapsController() =>
      _mapsControllerCompleter.future;

  /// Animated Markers to be placed on the map.
  final ValueNotifier<Set<Marker>> _markersMapNotifier =
      ValueNotifier<Set<Marker>>({});
  final Map<MarkerId, Marker> _markerMap = {};

  /// Map to store animation controllers for each marker
  final Map<MarkerId, MarkerAnimationController> _markerAnimationControllers =
      {};

  final markerSheetController = MarkerSheetController();

  /// ValueNotifier for tracking the selected marker
  final ValueNotifier<MarkerId?> _selectedMarkerId =
      ValueNotifier<MarkerId?>(null);

  final ValueNotifier<bool> isPageAnimatingFromMarker = ValueNotifier(false);
  final CarouselSliderController carouselSliderController =
      CarouselSliderController();

  late MarkerHelper markerHelper;
  Stream<Marker>? mapStream;
  StreamSubscription<Marker>? _mapStreamSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeAnimationMarkers();

    markerHelper = MarkerHelper(
      onMarkerTapped: (MarkerId markerId, LatLng position) {
        _handleMarkerTap(markerId, position);
      },
      markerAnimationControllers: _markerAnimationControllers,
    );

    _updateMarkers();
  }

  /// Initialize the animation controller for each marker
  void _initializeAnimation(MarkerIconInfo markerIconInfo) {
    final markerId = markerIconInfo.markerId;

    /// Initialize the controller
    final markerAnimationController = MarkerAnimationController(
        markerId: markerId,
        minMarkerSize: markerIconInfo.minMarkerSize,
        scale: markerIconInfo.scale,
        assetPath: markerIconInfo.assetPath,
        duration: markerIconInfo.duration,
        reverseDuration: markerIconInfo.reverseDuration,
        curve: markerIconInfo.curve,
        reverseCurve: markerIconInfo.reverseCurve,
        vsync: this);

    /// Start the animation
    markerAnimationController.setupAnimationController();
    _markerAnimationControllers[markerId] = markerAnimationController;
  }

  void _updateMarker(MarkerAnimationController markerAnimationController,
      MarkerIconInfo markerIconInfo) {
    /// Listen to the stream and update the marker icon
    final iconStream = markerAnimationController.iconStream;
    mapStream = iconStream.scale(markerIconInfo, markerHelper);
    if (mapStream != null) {
      _mapStreamSubscription = mapStream!.listen((updatedMarker) {
        if (!mounted) return;

        /// Only update if the widget is still active

        final markerId = updatedMarker.markerId;

        /// Replace the old marker with the new one
        _markerMap[markerId] = updatedMarker;

        /// Notify listeners to rebuild the map
        _markersMapNotifier.value = _markerMap.values.toSet();
      });
    }
  }

  void _updateMarkers() {
    for (var markerIconInfo in widget.scaledMarkerIconInfos) {
      final markerAnimationController =
          _markerAnimationControllers[markerIconInfo.markerId];
      if (markerAnimationController != null) {
        _updateMarker(markerAnimationController, markerIconInfo);
      }
    }
  }

  /// Function to initialize animation markers
  void _initializeAnimationMarkers() {
    for (var markerInfo in widget.scaledMarkerIconInfos) {
      _initializeAnimation(markerInfo);
    }
  }

  void _handleMarkerTap(MarkerId markerId, LatLng position) {
    _selectedMarkerId.value = markerId;

    isPageAnimatingFromMarker.value = true;

    _animateToLocation(markerId, position);

    _handleOverlayActionForMarker(markerId);
  }

  /// Handles the overlay UI behavior when a marker is tapped, based on the
  /// current [overlayContent] configuration.
  ///
  /// This function checks the type of [widget.overlayContent] and triggers
  /// the appropriate UI update:
  ///
  /// - If the overlay is a [MarkerDraggableSheetConfig], it triggers the sheet animation.
  /// - If the overlay is a [MarkerSwipeCardConfig], it navigates the card carousel to the
  ///   corresponding marker index.
  /// - For all other configurations, no action is performed.

  void _handleOverlayActionForMarker(MarkerId markerId) {
    switch (widget.overlayContent) {
      case MarkerDraggableSheetConfig():

        /// Trigger the sheet animation
        markerSheetController.animateSheet();
        break;

      case MarkerSwipeCardConfig():

        /// jump to Marker swipe card index
        final index = widget.scaledMarkerIconInfos
            .indexWhere((info) => info.markerId == markerId);

        final indexPage = (index == -1) ? 0 : index;

        final config = widget.overlayContent as MarkerSwipeCardConfig;
        _animateCarousel(config.options, indexPage);
        break;
      default:

        /// no action
        break;
    }
  }

  /// Animates the camera to the given [position] while preserving the current zoom level.
  ///
  /// This function retrieves the current zoom level from the map controller, then
  /// animates the camera to center on the provided [position] with that zoom level.
  ///
  /// Typically used when a marker is tapped or a user action requires focusing
  /// on a specific location on the map.
  ///
  /// [position] - The target [LatLng] coordinates to center the camera on.

  void _animateToLocation(MarkerId markerId, LatLng position) {
    if (!widget.animateToMarker) {
      return;
    }

    _mapsControllerCompleter.future.then((controller) {
      controller.getZoomLevel().then((zoom) {
        final CameraPosition newPosition =
            CameraPosition(target: position, zoom: zoom);
        controller.animateCamera(
          CameraUpdate.newCameraPosition(newPosition),
        );
      });
    });
  }

  /// Animates the carousel to the given page index using behavior
  /// defined by the specific [BaseSwipeCardOption] subclass.
  ///
  /// If [options] is [NeverScrollCardOption], the animation uses an
  /// elasticOut curve. For [MarkerSwipeCardOption], a default animation
  /// is performed. Otherwise, no animation occurs.

  void _animateCarousel(BaseSwipeCardOption options, int indexPage) {
    switch (options) {
      case MarkerSwipeCardOption():
        carouselSliderController.animateToPage(indexPage);
        break;
      case NeverScrollCardOption():
        carouselSliderController.animateToPage(indexPage,
            curve: Curves.elasticOut);
        break;
      default:

        /// no action
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ValueListenableBuilder<Set<Marker>>(
            valueListenable: _markersMapNotifier,
            builder: (context, markersMap, _) {
              return GoogleMap(
                initialCameraPosition: CameraPosition(
                    target: widget.defaultCameraLocation,
                    zoom: widget.zoomLevel),
                markers: {...markersMap, ...widget.markers},
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
            }),
        if (widget.overlayContent is MarkerDraggableSheetConfig)

          /// Draggable sheet to display additional content when a marker is tapped
          MarkerDraggableSheetPage(
              selectedMarkerIdNotifier: _selectedMarkerId,
              markerAnimationControllers: _markerAnimationControllers,
              markerSheetController: markerSheetController,
              config: widget.overlayContent as MarkerDraggableSheetConfig)
        else if (widget.overlayContent is MarkerSwipeCardConfig)
          MarkerSwipeCard(
            selectedMarkerIdNotifier: _selectedMarkerId,
            markerAnimationControllers: _markerAnimationControllers,
            config: widget.overlayContent as MarkerSwipeCardConfig,
            scaledMarkerIconInfos: widget.scaledMarkerIconInfos,
            mapControllerCompleter: _mapsControllerCompleter,
            isPageAnimatingFromMarker: isPageAnimatingFromMarker,
            controller: carouselSliderController,
          )
        else
          SizedBox.shrink()
      ],
    );
  }

  /// Stop all ongoing animations for markers.
  void stopMarkerAnimations() {
    for (var markerInfo in widget.scaledMarkerIconInfos) {
      final markerId = markerInfo.markerId;
      final markerAnimationController = _markerAnimationControllers[markerId];
      if (markerAnimationController != null) {
        markerAnimationController.stopAnimations();
      }
    }
  }

  @override
  void dispose() {
    _mapStreamSubscription?.cancel();
    stopMarkerAnimations();
    _selectedMarkerId.dispose();
    _markersMapNotifier.dispose();
    isPageAnimatingFromMarker.dispose();
    if (_mapsControllerCompleter.isCompleted) {
      _mapsControllerCompleter.future.then(
        (controller) => controller.dispose(),
      );
    }

    super.dispose();
  }
}

extension on Stream<BitmapDescriptor> {
  Stream<Marker> scale(
    MarkerIconInfo markerInfo,
    MarkerHelper markerHelper,
  ) {
    return transform(ScaleMarkerTransformer(
        markerInfo: markerInfo, markerHelper: markerHelper));
  }
}
