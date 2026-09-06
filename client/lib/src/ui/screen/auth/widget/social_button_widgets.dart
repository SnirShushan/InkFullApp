import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ink/src/utils/colors.dart';

class SocialButtonWidgets extends StatelessWidget {
  final String title;
  final images;
  final Function()? onpressed;
  const SocialButtonWidgets(
      {super.key, required this.onpressed, required this.title, this.images});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: SizedBox(
        width: size.width * 0.9,
        height: size.height * 0.06,
        child: ElevatedButton.icon(
          icon: SvgPicture.asset(
            images,
            height: 20.0,
            width: 20.0,
          ),
          label: Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                inherit: false,
                fontSize: 44 * 0.43,
                color: titleTextWhiteColor,
                // defaults styles aligned with https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/cupertino/text_theme.dart#L16
                fontFamily: '.SF Pro Text',
                letterSpacing: -0.41,
              )),
          onPressed: onpressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: socialoginbtn, // Google Red
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // <-- Radius
            ), // Rounded corners
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
          ),
        ),
      ),
    );
  }
}
