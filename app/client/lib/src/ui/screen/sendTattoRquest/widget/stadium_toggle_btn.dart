import 'package:flutter/material.dart';
import 'package:ink/src/utils/colors.dart';

class StadiumToggleButton extends StatelessWidget {
  final List<String> children;
  final int selectedIndex;
  final Function(int) onPressed;

  const StadiumToggleButton({
    Key? key,
    required this.children,
    required this.selectedIndex,
    required this.onPressed,
  }) : super(key: key);

  BorderRadius _getBorderRadius(int index) {
    return BorderRadius.circular(100);
  }

  Color _getBorderColor(int index) {
    return selectedIndex == index ? linearGradieantColor1 : linearGradieantColor1;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        children.length,
        (index) => GestureDetector(
          onTap: () => onPressed(index),
          child: Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              gradient: selectedIndex == index ? appLinearGradient : null,
              borderRadius: _getBorderRadius(index),
              border: Border.all(color: _getBorderColor(index), width: 2.0),
            ),
            child: Text(
              children[index],
              style: TextStyle(
                color: selectedIndex == index ? whiteTxtColor : titleTextColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
