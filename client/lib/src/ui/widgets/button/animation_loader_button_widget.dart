import 'package:flutter/material.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';

class AnimationLoaderButtonWidget extends StatefulWidget {
  final String title;
  final VoidCallback onTap;
  final bool isLoading;
  final List<Color> colors;

  const AnimationLoaderButtonWidget(
      {super.key,
      required this.title,
      required this.onTap,
      required this.isLoading,
      this.colors = const [
        linearGradieantColor1,
        linearGradieantColor2,
        linearGradieantColor3,
      ]});

  @override
  State<AnimationLoaderButtonWidget> createState() =>
      _AnimationLoaderButtonWidgetState();
}

class _AnimationLoaderButtonWidgetState
    extends State<AnimationLoaderButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(); // Rotates continuously
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.all(size.width * 0.01),
      child: InkWell(
        onTap: widget.isLoading
            ? null
            : widget.onTap, // Disable tap during loading
        child: Container(
          width: size.width,
          height: size.height * 0.07,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: widget.colors,
              stops: const [0.0, 0.001, 0.8937],
            ),
          ),
          child: widget.isLoading
              ? RotationTransition(
                  turns: _controller,
                  child: Image.asset(
                    AppAssets.loadingIcon, // Replace with your asset
                    color: Colors.white,
                  ),
                )
              : Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
        ),
      ),
    );
  }
}
