import 'dart:ui';

import 'package:flutter/material.dart';

import '../rotation_stage.dart';

class RotationStageBar extends StatelessWidget {
  const RotationStageBar({
    super.key,
    required this.controller,
    required this.viewHandleBuilder,
    this.height = kToolbarHeight,
    this.interactable = true,
    this.minHandleOpacity = 0,
  })  : assert(minHandleOpacity >= 0),
        assert(minHandleOpacity <= 1);

  final RotationStageController controller;
  final RotationStageBuilder viewHandleBuilder;
  final bool interactable;
  final double height;
  final double minHandleOpacity;

  @override
  Widget build(BuildContext context) {
    final visOffset = 0.30 / controller.pageController.viewportFraction;
    return SizedBox(
      height: height,
      child: ValueListenableBuilder<double>(
        valueListenable: controller,
        builder: (context, page, _) => PageView.builder(
          scrollDirection: Axis.vertical,
          allowImplicitScrolling: true,
          pageSnapping: false,
          scrollBehavior: const ScrollBehavior(),
          itemCount: 2,
          clipBehavior: Clip.hardEdge,
          physics: const NeverScrollableScrollPhysics(),
          controller: controller.pageController,
          itemBuilder: (context, index) {
            final offset = (page - index).abs().clamp(0, visOffset) / visOffset;
            final opacity = lerpDouble(minHandleOpacity, 1, 1 - offset);
            return Container(
              margin: EdgeInsets.only(top: 2),
              child: Center(
                child: Opacity(
                  opacity: Curves.ease.transform(opacity!),
                  child: AnimatedOpacity(
                    duration: kThemeAnimationDuration,
                    opacity: interactable && index != index ? 0 : 1,
                    child: viewHandleBuilder(
                      index,
                      RotationStageSide.forIndex(index),
                      page,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/*
Column(
                children: [
                  Center(
                    child: Opacity(
                      opacity: Curves.ease.transform(1),
                      child: AnimatedOpacity(
                        duration: kThemeAnimationDuration,
                        // opacity: interactable && index != index ? 0 : 1,
                        opacity: 1,
                        child: RotationStageHandle(
                          onTap: () {
                            // if (side == RotationStageSide.front) {
                            //   WebService.isBodySideFront = true;
                            // } else {
                            //   WebService.isBodySideFront = false;
                            // }
                            controller.animateToPage(0);
                          },
                          side: RotationStageSide.front,
                          active: 0 == page.round(),
                          backgroundTransparent: false,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Opacity(
                      opacity: Curves.ease.transform(1),
                      child: AnimatedOpacity(
                        duration: kThemeAnimationDuration,
                        opacity: 1,
                        // opacity: interactable && index != index ? 0 : 1,
                        child: RotationStageHandle(
                          onTap: () {
                            // if (side == RotationStageSide.front) {
                            //   WebService.isBodySideFront = true;
                            // } else {
                            //   WebService.isBodySideFront = false;
                            // }
                            controller.animateToPage(2);
                          },
                          side: RotationStageSide.back,
                          active: 1 == page.round(),
                          backgroundTransparent: true,
                        ),
                      ),
                    ),
                  )
                ],
              )
*/
