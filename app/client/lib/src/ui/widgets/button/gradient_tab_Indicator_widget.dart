import 'package:flutter/material.dart';

class GradientTabIndicator extends Decoration {
  final Gradient gradient;
  final double height;

  const GradientTabIndicator({
    required this.gradient,
    this.height = 2.0,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _GradientPainter(gradient: gradient, height: height);
  }
}

class _GradientPainter extends BoxPainter {
  final Gradient gradient;
  final double height;

  _GradientPainter({required this.gradient, required this.height});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Paint paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(
          offset.dx,
          configuration.size!.height - height,
          configuration.size!.width,
          height,
        ),
      )
      ..style = PaintingStyle.fill;

    final Rect rect = Rect.fromLTWH(
      offset.dx,
      configuration.size!.height - height,
      configuration.size!.width,
      height,
    );

    canvas.drawRect(rect, paint);
  }
}
