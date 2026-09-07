import 'package:flutter/material.dart';
import 'package:ink/src/utils/colors.dart';

class UserBusinessGradientButtonWidget extends StatelessWidget {
  final double height;
  final double width;
  final double radius;
  final Widget child;
  final VoidCallback onTap;

  const UserBusinessGradientButtonWidget(
      {super.key, this.height = 0.0, this.width = 0.0, this.radius = 10.0, required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        height:height==0.0? size.height * 0.06:height,
        clipBehavior: Clip.antiAlias,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [
              linearGradieantColor1,
              linearGradieantColor2,
              linearGradieantColor3,
            ],
            stops: [0.0, 0.001, 0.8937],
          ),
          borderRadius: BorderRadius.circular((radius)),
        ),
        child: child,
      ),
    );
  }
}
