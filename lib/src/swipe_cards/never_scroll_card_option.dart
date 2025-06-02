import 'package:animate_map_markers/src/swipe_cards/base_swipe_card_option.dart';
import 'package:flutter/material.dart';

class NeverScrollCardOption extends BaseSwipeCardOption {
  NeverScrollCardOption({
    super.height,
    super.aspectRatio,
    super.initialPage,
    super.enableInfiniteScroll,
    super.animateToClosest,
    super.reverse,
    super.autoPlay,
    super.autoPlayInterval,
    super.autoPlayAnimationDuration,
    super.autoPlayCurve,
    super.enlargeCenterPage,
    super.onPageChanged,
    super.onScrolled,
    super.pageSnapping,
    super.scrollDirection,
    super.pauseAutoPlayOnTouch,
    super.pauseAutoPlayOnManualNavigate,
    super.pauseAutoPlayInFiniteScroll,
    super.pageViewKey,
    super.enlargeStrategy,
    super.enlargeFactor,
    super.disableCenter,
    super.padEnds,
    super.clipBehavior,
  }) : super(
            scrollPhysics: const NeverScrollableScrollPhysics(),
            viewportFraction: 1.0);
}
