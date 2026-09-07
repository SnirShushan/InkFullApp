import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/ui/screen/sendTattoRquest/controller/imgListController.dart';
import 'package:ink/src/utils/webService.dart';

import 'rotation_stage.dart';

export 'src/model/rotation_stage_side.dart';
export 'src/rotation_stage_bar.dart';
export 'src/rotation_stage_content.dart';
export 'src/rotation_stage_controller.dart';
export 'src/rotation_stage_handle.dart';
export 'src/rotation_stage_labels.dart';

typedef RotationStageBuilder = Widget Function(
    int index, RotationStageSide side, double currentPage);

class RotationStage extends StatefulWidget {
  const RotationStage({
    super.key,
    required this.contentBuilder,
    this.controller,
    this.viewHandleBuilder,
    this.labels,
    this.barHeight = 64,
    this.barInteractable = true,
    this.islabelshow = true,
  });

  final RotationStageBuilder contentBuilder;
  final RotationStageController? controller;
  final RotationStageBuilder? viewHandleBuilder;
  final RotationStageLabelData? labels;
  final double barHeight;
  final bool barInteractable;
  final bool islabelshow;

  @override
  State<RotationStage> createState() => _RotationStageState();
}

class _RotationStageState extends State<RotationStage> {
  late final RotationStageController _controller;
  final imgListController = Get.find<ImgListController>();

  @override
  void initState() {
    _controller = widget.controller ?? RotationStageController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RotationStageLabels(
      data: widget.labels ?? RotationStageLabelData.english,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(height: 1),
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.67,
                height: MediaQuery.of(context).size.height * 0.5,
                child: RotationStageContent(
                  controller: _controller,
                  contentBuilder: widget.contentBuilder,
                ),
              ),
              if (widget.islabelshow)
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.23,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: RotationStageBar(
                    controller: _controller,
                    interactable: widget.barInteractable,
                    viewHandleBuilder: widget.viewHandleBuilder ??
                        (index, side, page) => RotationStageHandle(
                              onTap: () {
                                if (side == RotationStageSide.front) {
                                  imgListController.isbodyFrontPart(true);
                                  WebService.isBodySideFront = true;
                                } else {
                                  imgListController.isbodyFrontPart(false);
                                  WebService.isBodySideFront = false;
                                }

                                _controller.animateToPage(index);
                              },
                              side: side,
                              active: index == page.round(),
                              backgroundTransparent: !widget.barInteractable,
                            ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
