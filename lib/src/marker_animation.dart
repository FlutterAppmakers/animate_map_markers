import 'dart:async';

import 'package:animate_map_markers/animate_map_markers.dart';
import 'package:animate_map_markers/src/animation_extensions.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerAnimationController {
  late final Animation<Size> scaleAnimation;
  final Map<String, BitmapDescriptor> _scaledIcons = {};
  final Map<String, AnimationController> _runningAnimationControllers = {};
  final Map<String, Animation<Size>> _scaleAnimations = {};
  final Map<String, BitmapDescriptor> _currentIcons = {};
  final Map<String, BitmapDescriptor> _originalIcons = {};
  // Stream controller to notify about icon changes
  final StreamController<BitmapDescriptor> _iconStreamController = StreamController<BitmapDescriptor>.broadcast();
  Stream<BitmapDescriptor> get iconStream => _iconStreamController.stream;
  final StreamController<BitmapDescriptor> _originalIconStreamController = StreamController<BitmapDescriptor>.broadcast();
  Stream<BitmapDescriptor> get originalIconStream => _originalIconStreamController.stream;


  // Getter for accessing the _animationControllers map
  Map<String, AnimationController> get runningAnimationControllers => _runningAnimationControllers;


  // Getter for accessing the originalIcons

  final MarkerScaler markerScaler;


  MarkerAnimationController({
    required this.markerId,
    required this.startSize,
    required this.endSize,
    required this.assetPath,
    //required this.animationController,
    required this.vsync,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.fastOutSlowIn,
    MarkerScaler? scaler,
  }): markerScaler = scaler ?? MarkerScaler();

  final String markerId;
  final Size startSize;

  final Size endSize;

  final String assetPath;

  /// The vsync of the animation.
  final TickerProvider vsync;

  /// The duration of the animation.
  ///
  /// Defaults to 500 milliseconds.
  final Duration duration;

  /// The curve of the animation.
  ///
  /// Defaults to [Curves.fastOutSlowIn].
  final Curve curve;

  // Constructor expects a TickerProvider as vsync
  Future<void> animateTo() async {
    // Now that the animationController is initialized, create the scaleAnimation
    final animationController = AnimationController(
        vsync: vsync, // Pass the TickerProvider to the AnimationController
        duration: duration,
    );
    final animation = CurvedAnimation(
      parent: animationController, // Link the controller to the animation
      curve: curve,         // Apply the curve to smooth the animation
    ); /*.onEnd(() {
      animationController.dispose();
      _runningAnimationControllers.remove(markerId);
    });*/

    scaleAnimation = Tween<Size>(
      begin: startSize, // Start size
      end: endSize,   // End size (scaled up)
    ).animate(
      animation
    );

    _runningAnimationControllers[markerId] = animationController;
    _scaleAnimations[markerId] = scaleAnimation;
    //final markerScaler = MarkerScaler();
    final originalIcon =  await markerScaler.scaleMarkerIcon(assetPath, startSize.width, startSize.height);
    _originalIcons[markerId] = originalIcon;
    _originalIconStreamController.add(_originalIcons[markerId]!);


    animationController.addListener(() async {
      final sizeFactor = scaleAnimation.value;
      print("size Factor #### ${sizeFactor}");
      final width = sizeFactor.width;
      final height = sizeFactor.height;
      final key = '$assetPath w$width h $height';
      if (!_scaledIcons.containsKey(key)) {
        final BitmapDescriptor icon = await markerScaler.scaleMarkerIcon(assetPath, width, height);

          _scaledIcons[key] = icon;
          _currentIcons[markerId] = icon;
      } else {
          _currentIcons [markerId] = _scaledIcons[key]!;
      }
      // Add the updated icon to the stream
      print("current Icon marker Id ${_currentIcons[markerId]!} ${markerId}");
      _iconStreamController.add(_currentIcons[markerId]!);
    });
  }

  /// Animate marker by switching pre-generated icons
  Future<void> animateMarker(String markerId, bool selected) async {
    print("111$_runningAnimationControllers");
    final animationController = _runningAnimationControllers[markerId];
    print(animationController);
    if (animationController != null) {
      if (selected) {
        toggleAnimationDirection(animationController);
      } else {
        resetAnimation(animationController);
        reverseAnimation(animationController);
      }
    }
  }

  void toggleAnimationDirection(AnimationController animationController) {
    if (animationController.status == AnimationStatus.dismissed ||
        animationController.status == AnimationStatus.completed) {
      animationController.forward();
    } else  if (animationController.status == AnimationStatus.forward)  {
      animationController.reverse();
    }
  }

  void reverseAnimation(AnimationController animationController) {
    print('🔥 Reversing animation');
    animationController.reverse();
  }

  void resetAnimation(AnimationController animationController) {
        animationController.reset();
    }

  // Dispose of the controller when it's no longer needed
  void dispose() {
    // Stop running animations and dispose their controllers.
    stopAnimations();
    disposeStreamControllers();
  }

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

