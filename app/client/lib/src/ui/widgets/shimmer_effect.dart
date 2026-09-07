
import 'package:flutter/material.dart';

class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerEffect({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  }) : super(key: key);

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerOffsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(); // Repeat without reverse for a continuous flow

    // This animation ranges from 0.0 to 1.0.
    // It controls the progress of the shimmer wave across the child.
    _shimmerOffsetAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerOffsetAnimation,
      builder: (BuildContext context, Widget? child) {
        return ShaderMask(
          // Blend mode that composites the shader over the child,
          // taking the child's alpha as its own. This makes the shimmer
          // appear only on the visible (non-transparent) parts of the child.
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect bounds) {
            // Calculate the current horizontal offset for the gradient.
            // The value of _shimmerOffsetAnimation.value (0.0 to 1.0) is mapped
            // to a wider range (e.g., -1.0 to 2.0 or -1.5 to 2.5) to ensure
            // the gradient starts completely off-screen left and ends completely off-screen right.
            // A factor of 3.0 gives a good sweep.
            final double dx = bounds.width * (_shimmerOffsetAnimation.value * 3.0 - 1.0);

            // Define the linear gradient for the shimmer effect.
            return LinearGradient(
              colors: <Color>[
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              // Stops define where each color is placed in the gradient (0.0 to 1.0 of gradient width).
              // These values create a narrow highlight in the middle of the gradient.
              stops: const <double>[0.4, 0.5, 0.6],
              // The gradient itself is defined to sweep horizontally.
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              tileMode: TileMode.clamp, // Prevents repeating the gradient.
            ).createShader(
              // The Rect for the shader. This is key to making the gradient slide.
              // We create a Rect that is wider than the `bounds` of the child
              // (e.g., twice the width) and shift its left edge by `dx`.
              // This makes the entire gradient appear to slide across the child's bounds.
              Rect.fromLTWH(
                dx, // The shifting left position of the gradient's container.
                bounds.top,
                bounds.width * 2, // The gradient needs to be wider to sweep across the child.
                bounds.height,
              ),
            );
          },
          child: widget.child,
        );
      },
    );
  }
}