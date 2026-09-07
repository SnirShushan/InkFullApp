// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:ink/src/utils/colors.dart';

class LargeButton extends StatelessWidget {
  final String text;
  final Function()? onTap;
  final Color? textColor;
  final Color? color;
  final Icon? icon;
  final double? width;
  const LargeButton(
      {super.key,
      required this.text,
      required this.onTap,
      this.textColor,
      this.color,
      this.icon,
      this.width});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Material(
          color: Colors.transparent,
          child: InkResponse(
            splashColor: const Color.fromARGB(255, 255, 0, 98),
            onTap: onTap ?? () {},
            child: Ink(
              height: 50,
              width: width ?? 225,
              decoration: BoxDecoration(
                color: color ?? appColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints.expand(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      icon ?? const SizedBox(),
                      icon != null
                          ? const SizedBox(width: 8)
                          : const SizedBox(),
                      Text(text,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: textColor ?? kWhite,
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
