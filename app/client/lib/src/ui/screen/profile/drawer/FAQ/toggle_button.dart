import 'package:flutter/material.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/utils_styles.dart';

class ToggleButton extends StatefulWidget {
  bool isSelected;
  final String text;
  final VoidCallback onPressed;
  ToggleButton({super.key, required this.isSelected, required this.text, required this.onPressed});

  @override
  State<ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onPressed,
      child: Container(
        decoration: BoxDecoration(
            color: widget.isSelected ? kWhite : appTransparent,
            border: Border.all(color: kWhite, width: 0.5),
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: Text(
            widget.text,
            style: normalWhiteStyle.copyWith(
                color: widget.isSelected ? kBlack : kWhite),
          ),
        ),
      ),
    );
  }
}
