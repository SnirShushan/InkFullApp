import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../bodyparts.dart';
import '../rotation_stage/rotation_stage.dart';

class BodyPartSelectorTurnable extends StatelessWidget {
  const BodyPartSelectorTurnable({
    super.key,
    required this.bodyParts,
    this.onSelectionUpdated,
    this.mirrored = false,
    this.islabelshow = true,
    this.padding = EdgeInsets.zero,
    this.labelData,
  });

  final BodyParts bodyParts;
  final Function(BodyParts)? onSelectionUpdated;
  final bool mirrored;
  final bool islabelshow;
  final EdgeInsets padding;
  final RotationStageLabelData? labelData;

  @override
  Widget build(BuildContext context) {
    return RotationStage(
      islabelshow: islabelshow,
      contentBuilder: (index, side, page) => Padding(
        padding: padding,
        child: Padding(
          padding: EdgeInsets.all(Get.size.width * 0.02),
          child: BodyPartSelector(
            side: side.map(
              front: BodySide.front,
              // left: BodySide.left,
              back: BodySide.back,
              // right: BodySide.right,
            ),
            selectedColor: const Color(0xFFDFDCE3),
            unselectedColor: const Color(0xFF211D25),
            selectedOutlineColor: const Color(0xFFDFDCE3),
            unselectedOutlineColor: const Color(0xFFDFDCE3),
            bodyParts: bodyParts,
            onSelectionUpdated: onSelectionUpdated,
            mirrored: mirrored,
          ),
        ),
      ),
      labels: labelData,
    );
  }
}
