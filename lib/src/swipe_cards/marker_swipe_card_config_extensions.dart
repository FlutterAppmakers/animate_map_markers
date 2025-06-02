import 'package:animate_map_markers/src/swipe_cards/base_swipe_card_option.dart';
import 'package:carousel_slider/carousel_slider.dart';

extension MarkerSwipeCardOptionExt on BaseSwipeCardOption {
  CarouselOptions toCarouselOptions({
    void Function(int index, CarouselPageChangedReason reason)?
        onPageChangedCallback,
  }) {
    return CarouselOptions(
      height: height,
      aspectRatio: aspectRatio,
      viewportFraction: viewportFraction,
      initialPage: initialPage,
      enableInfiniteScroll: enableInfiniteScroll,
      animateToClosest: animateToClosest,
      reverse: reverse,
      autoPlay: autoPlay,
      autoPlayInterval: autoPlayInterval,
      autoPlayAnimationDuration: autoPlayAnimationDuration,
      autoPlayCurve: autoPlayCurve,
      enlargeCenterPage: enlargeCenterPage ?? false,
      scrollDirection: scrollDirection,
      onPageChanged: (index, reason) {
        onPageChangedCallback?.call(index, reason); // override callback
        onPageChanged?.call(index, reason); // original config handler
      },
      onScrolled: onScrolled,
      scrollPhysics: scrollPhysics,
      pageSnapping: pageSnapping,
      pauseAutoPlayOnTouch: pauseAutoPlayOnTouch,
      pauseAutoPlayOnManualNavigate: pauseAutoPlayOnManualNavigate,
      pauseAutoPlayInFiniteScroll: pauseAutoPlayInFiniteScroll,
      pageViewKey: pageViewKey,
      enlargeStrategy: enlargeStrategy,
      enlargeFactor: enlargeFactor,
      disableCenter: disableCenter,
      padEnds: padEnds,
      clipBehavior: clipBehavior,
    );
  }
}
