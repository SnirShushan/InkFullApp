import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Soft fade + slight slide, similar to Material 3 fade-through.
class InkPageTransition extends CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final enter = CurvedAnimation(
      parent: animation,
      curve: curve ?? Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final leave = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeOutCubic,
    );

    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(enter),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-0.05, 0.015),
          end: Offset.zero,
        ).animate(enter),
        child: FadeTransition(
          opacity: Tween<double>(begin: 1, end: 0.92).animate(leave),
          child: child,
        ),
      ),
    );
  }
}
