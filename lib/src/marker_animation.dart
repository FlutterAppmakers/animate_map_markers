import 'dart:async';

import 'package:animate_map_markers/animate_map_markers.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerAnimationController {
  late AnimationController animationController;
  late final Animation<Size> scaleAnimation;
  final Map<String, BitmapDescriptor> _scaledIcons = {};
  final Map<String, AnimationController> _animationControllers = {};
  final Map<String, Animation<Size>> _scaleAnimations = {};
  final Map<String, BitmapDescriptor> _currentIcons = {};
  final Map<String, BitmapDescriptor> _originalIcons = {};
  // Stream controller to notify about icon changes
  final StreamController<BitmapDescriptor> _iconStreamController = StreamController<BitmapDescriptor>.broadcast();
  Stream<BitmapDescriptor> get iconStream => _iconStreamController.stream;
  final StreamController<BitmapDescriptor> _originalIconStreamController = StreamController<BitmapDescriptor>.broadcast();
  Stream<BitmapDescriptor> get originalIconStream => _originalIconStreamController.stream;


  // Getter for accessing the _animationControllers map
  Map<String, AnimationController> get animationControllers => _animationControllers;


  // Getter for accessing the originalIcons


  MarkerAnimationController({
    required this.markerId,
    required this.startSize,
    required this.endSize,
    required this.assetPath,
    //required this.animationController,
    required this.vsync,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.fastOutSlowIn,
  });

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
    animationController = AnimationController(
        vsync: vsync, // Pass the TickerProvider to the AnimationController
        duration: duration,
    );
    scaleAnimation = Tween<Size>(
      begin: startSize, // Start size
      end: endSize,   // End size (scaled up)
    ).animate(
      CurvedAnimation(
        parent: animationController, // Link the controller to the animation
        curve: curve,         // Apply the curve to smooth the animation
      ),
    );

    _animationControllers[markerId] = animationController;
    _scaleAnimations[markerId] = scaleAnimation;
    // Define separate Tweens for width and height
    //final originalIcon = await _generateScaledIcon(imagePath, Size(widthStart, heightStart));
    final originalIcon =  await MarkerScaler.scaleMarkerIcon(assetPath, startSize.width, startSize.height);
    _originalIcons[markerId] = originalIcon;
    _originalIconStreamController.add(_originalIcons[markerId]!);


    animationController.addListener(() async {
      final sizeFactor = scaleAnimation.value;
      print("size Factor #### ${sizeFactor}");
      final width = sizeFactor.width;
      final height = sizeFactor.height;
      final key = '$assetPath w$width h $height';
      if (!_scaledIcons.containsKey(key)) {
        final BitmapDescriptor icon = await MarkerScaler.scaleMarkerIcon(assetPath, width, height);

          _scaledIcons[key] = icon;
          _currentIcons[markerId] = icon;
      } else {
          _currentIcons [markerId] = _scaledIcons[key]!;
      }
      // Add the updated icon to the stream
      _iconStreamController.add(_currentIcons[markerId]!);
    });
  }

  /// Animate marker by switching pre-generated icons
  Future<void> animateMarker(String markerId, bool selected) async {
    print(_animationControllers);
    final animationController = _animationControllers[markerId];
    print(animationController);
    if (animationController != null) {
      if (selected) {

        if (animationController.status == AnimationStatus.dismissed ||
            animationController.status == AnimationStatus.completed) {
          startAnimation();
        } else  if (animationController.status == AnimationStatus.forward)  {
          reverseAnimation();
        }
      } else {
        resetAnimation();
        reverseAnimation();
      }
    }
  }

  // Start the animation (scale up)
  void startAnimation() {
    animationController.forward();
  }

  void resetAnimation() {
    animationController.reset();
  }

  // Reverse the animation (scale down)
  void reverseAnimation() {
    animationController.reverse();
  }

  // Dispose of the controller when it's no longer needed
  void dispose() {
    animationController.dispose();
  }

  }

