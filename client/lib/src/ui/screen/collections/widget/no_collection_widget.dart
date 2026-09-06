import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ink/src/ui/widgets/button/custom_gradient_btn_widget.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/utils_styles.dart';

class NoCollectionWidget extends StatelessWidget {
  final Size size;
  final VoidCallback onPressed;

  const NoCollectionWidget(
      {super.key, required this.size, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Center(
            child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(AppAssets.noPhotoRound, height: size.height * 0.07),
        SizedBox(height: size.height * 0.02),
        Text(
          tr("not_found_profile_menu.noCollectionTitle"),
          style: bigBoldWhiteStyle,
        ),
        SizedBox(height: size.height * 0.01),
        Text(
          tr("not_found_profile_menu.noCollectionSubtitle"),
          style: normalWhiteStyle,
        ),
        SizedBox(height: size.height * 0.02),
        CustomGradientButtonWidget(
          width: size.width*0.35,

          textSize: 14,
            title:  tr("not_found_profile_menu.noCollectionbtn"),
            onTap: onPressed,
            ),
      ],
    )));
  }
}
