import 'package:flutter/material.dart';
import 'package:ink/src/utils/colors.dart';

import '../rotation_stage.dart';

class RotationStageHandle extends StatelessWidget {
  const RotationStageHandle({
    super.key,
    required this.side,
    required this.active,
    required this.onTap,
    required this.backgroundTransparent,
    this.activeForegroundColor,
    this.inactiveForegroundColor,
    this.activeBackgroundColor,
    this.inactiveBackgroundColor,
  });

  final RotationStageSide side;
  final bool active;
  final bool backgroundTransparent;
  final VoidCallback onTap;

  final Color? activeForegroundColor;
  final Color? inactiveForegroundColor;
  final Color? activeBackgroundColor;
  final Color? inactiveBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final labels = RotationStageLabels.of(context);
    final name = labels.getForSide(side);
    return RawChip(
      showCheckmark: false,
      onSelected: (_) => onTap(),
      label: FittedBox(
        child: Text(
          name.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: active
                    ? whiteTxtColor ?? Colors.black
                    // ? activeForegroundColor ?? colorScheme.onPrimary
                    : titleTextColor,
                // : inactiveForegroundColor ?? colorScheme.onPrimaryContainer,
              ),
        ),
      ),
      selected: active,
      shape: const StadiumBorder(side: BorderSide(color: linearGradieantColor1)),
      //disabledColor: Colors.transparent,
      shadowColor: Colors.transparent,
      // backgroundTransparent ? Colors.transparent : colorScheme.shadow,
      selectedShadowColor: backgroundTransparent
          ? Colors.transparent
          : activeBackgroundColor ?? colorScheme.primary,
      backgroundColor: bgBlack,
      // backgroundTransparent
      //     ? Colors.transparent
      //     : inactiveBackgroundColor ?? colorScheme.primaryContainer,
      selectedColor: linearGradieantColor1,
      // backgroundTransparent ? Colors.transparent: activeBackgroundColor ?? colorScheme.primary,
    );
  }
}
