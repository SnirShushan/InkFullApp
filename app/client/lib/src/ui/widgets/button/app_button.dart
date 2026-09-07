import 'package:flutter/material.dart';
import 'package:ink/src/utils/colors.dart';

class GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Gradient gradient;
  final double borderRadius;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.gradient = const LinearGradient(
      colors: [
        linearGradieantColor1,
        linearGradieantColor2,
        linearGradieantColor3,
      ],
      stops: [0.0, 0.001, 0.8937],
      begin: Alignment.centerRight, // For RTL, start from right
      end: Alignment.centerLeft,
    ),
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: size.height * 0.022, vertical: size.height * 0.03),
      height: size.height * 0.07,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: EdgeInsets.symmetric(
                vertical: size.width * 0.02, horizontal: size.width * 0.05),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
