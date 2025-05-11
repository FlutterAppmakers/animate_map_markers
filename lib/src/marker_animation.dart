import 'dart:async';

import 'package:animate_map_markers/animate_map_markers.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A controller that handles animation and icon scaling for Google Map markers.
///
/// This class uses Flutter animations to smoothly scale marker icons on the map
/// and emits updated [BitmapDescriptor]s through a stream for rendering.
class MarkerAnimationController {
  /// The animation that controls the scaling size of the marker icon.
  late final Animation<Size> scaleAnimation;

  /// A cache of pre-scaled marker icons mapped by a unique key.
  final Map<String, BitmapDescriptor> _scaledIcons = {};

  /// A map of running animation controllers associated with their respective marker IDs.
  final Map<MarkerId, AnimationController> _runningAnimationControllers = {};

  /// A map holding the current displayed icons for each marker.
  final Map<MarkerId, BitmapDescriptor> _currentIcons = {};

  /// A map holding the original (unscaled) icons for each marker.
  final Map<MarkerId, BitmapDescriptor> _originalIcons = {};

  /// Stream controller that broadcasts updates when a marker's icon changes.
  final StreamController<BitmapDescriptor> _iconStreamController =
      StreamController<BitmapDescriptor>.broadcast();

  /// A stream of updated marker icons for listening to icon changes.
  Stream<BitmapDescriptor> get iconStream => _iconStreamController.stream;

  /// Stream controller that broadcasts the original marker icons.
  final StreamController<BitmapDescriptor> _originalIconStreamController =
      StreamController<BitmapDescriptor>.broadcast();

  /// A stream of original marker icons for listening to unscaled icon updates.
  Stream<BitmapDescriptor> get originalIconStream =>
      _originalIconStreamController.stream;

  /// Getter for accessing the _animationControllers map
  Map<MarkerId, AnimationController> get runningAnimationControllers =>
      _runningAnimationControllers;

  /// Getter for accessing the originalIcons

  final MarkerScaler markerScaler;

  /// Creates a new [MarkerAnimationController].
  ///
  /// [assetPath] is used to load a marker image from assets.
  /// [iconMarker] is used to render a Material [Icon] as the marker.
  ///
  /// You must provide either [assetPath] for an image icon or [iconMarker] for a Material icon.

  MarkerAnimationController({
    required this.markerId,
    required this.minMarkerSize,
    required this.scale,
    this.assetPath,
    this.iconMarker,
    required this.vsync,
    this.duration = const Duration(milliseconds: 500),
    this.reverseDuration = const Duration(milliseconds: 500),
    this.curve = Curves.bounceOut,
    this.reverseCurve = Curves.linear,
    MarkerScaler? scaler,
  }) : markerScaler =
            scaler ?? MarkerScaler(assetPath: assetPath, icon: iconMarker);

  /// Material icon that can be passed which can be used
  /// in place of a default [Marker].
  final Icon? iconMarker;

  /// A unique identifier for the marker.
  final MarkerId markerId;

  /// The base size of the marker before scaling.
  final Size minMarkerSize;

  /// The scale factor to be applied to [minMarkerSize] for the maximum size.
  /// For example, a scale of 1.3 increases the size by 30%.
  final double scale;

  /// The asset path for the marker icon image.
  final String? assetPath;

  /// The vsync of the animation.
  final TickerProvider vsync;

  /// The duration of the animation.
  ///
  /// Defaults to 500 milliseconds.
  final Duration duration;

  /// The reverse duration of the animation.
  ///
  /// Defaults to 500 milliseconds.
  final Duration reverseDuration;

  /// The curve of the animation.
  ///
  /// Defaults to [Curves.bounceOut].
  final Curve curve;

  /// The reverse curve of the animation.
  ///
  /// Defaults to [Curves.linear].
  final Curve reverseCurve;

  /// Sets up the animation controller and scaling animation for a specific marker.
  ///
  /// - Initializes an [AnimationController] and a [CurvedAnimation] using the provided [vsync], [duration], [curve], and [reverseCurve].
  /// - Creates a [Tween] that scales the marker's size during the animation.
  /// - Preloads the original scaled icon and adds it to the stream controller.
  /// - Listens to the animation progress and updates marker icons dynamically based on the current animation value.
  Future<void> setupAnimationController() async {
    // Now that the animationController is initialized, create the scaleAnimation
    final animationController = AnimationController(
        vsync: vsync, // Pass the TickerProvider to the AnimationController
        duration: duration,
        reverseDuration: reverseDuration);
    final animation = CurvedAnimation(
        parent: animationController, curve: curve, reverseCurve: reverseCurve);

    final Size scaledSize = Size(
      minMarkerSize.width * scale,
      minMarkerSize.height * scale,
    );

    scaleAnimation = Tween<Size>(
      begin: minMarkerSize,
      end: scaledSize,
    ).animate(animation);

    _runningAnimationControllers[markerId] = animationController;

    // final originalIcon =  await markerScaler.scaleMarkerIcon(assetPath, minMarkerSize.width, minMarkerSize.height);
    final originalIcon =
        await markerScaler.createBitmapDescriptor(minMarkerSize);
    _originalIcons[markerId] = originalIcon;
    _originalIconStreamController.add(_originalIcons[markerId]!);

    animationController.addListener(_onAnimationTick);
  }

  /// Handles the animation tick, called every time the marker animation is updated.
  /// It checks whether the current icon for the marker has been generated and cached.
  /// If the icon exists in the cache, it is used immediately; if not, it triggers
  /// asynchronous icon generation.
  void _onAnimationTick() {
    final size = scaleAnimation.value;
    final width = size.width;
    final height = size.height;
    final key = '$assetPath w$width h$height';

    if (_scaledIcons.containsKey(key)) {
      _currentIcons[markerId] = _scaledIcons[key]!;
      _iconStreamController.add(_currentIcons[markerId]!);
    } else {
      // Schedule async bitmap generation without blocking listener
      _generateAndCacheIcon(Size(width, height), key);
    }
  }

  /// Asynchronously generates and caches the bitmap descriptor for a marker icon
  /// at the given size. If the icon is already cached, it returns early
  /// to avoid duplicate work.
  void _generateAndCacheIcon(Size size, String key) async {
    // Avoid duplicate work
    if (_scaledIcons.containsKey(key)) return;

    final icon = await markerScaler.createBitmapDescriptor(size);
    _scaledIcons[key] = icon;
    _currentIcons[markerId] = icon;
    _iconStreamController.add(icon);
  }

  /// Animate marker by switching pre-generated icons
  Future<void> animateMarker(MarkerId markerId, bool selected) async {
    final animationController = _runningAnimationControllers[markerId];
    if (animationController != null) {
      if (selected) {
        toggleAnimationDirection(animationController);
      } else {
        reverseAnimation(animationController);
      }
    }
  }

  /// Toggles the direction of the given [AnimationController].
  ///
  /// - If the animation is completed or dismissed, it starts playing forward.
  /// - If the animation is currently playing forward, it reverses the animation.
  void toggleAnimationDirection(AnimationController animationController) {
    if (animationController.status == AnimationStatus.dismissed ||
        animationController.status == AnimationStatus.completed) {
      animationController.forward();
    } else if (animationController.status == AnimationStatus.forward) {
      animationController.reverse();
    }
  }

  /// Reverses the animation controlled by the given [AnimationController].
  void reverseAnimation(AnimationController animationController) {
    animationController.reverse();
  }

  /// Dispose of the controller when it's no longer needed
  void dispose() {
    /// Stop running animations and dispose their controllers.
    stopAnimations();
    disposeStreamControllers();
  }

  /// Closes the internal stream controllers used for emitting marker icons.
  void disposeStreamControllers() {
    if (!_originalIconStreamController.isClosed) {
      _originalIconStreamController.close();
    }

    if (!_iconStreamController.isClosed) {
      _iconStreamController.close();
    }
  }

  /// Stop all ongoing animations.
  void stopAnimations() {
    for (final controller in _runningAnimationControllers.values) {
      if (controller.isAnimating) controller.stop();
      controller.dispose();
    }
    _runningAnimationControllers.clear();
  }
}
