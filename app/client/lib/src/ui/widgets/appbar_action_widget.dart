import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';

class AppBarActionButtonWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final Color titleColor;
  final Color iconColor;
  final double height;
  final String iconName;
  final VoidCallback onPressed;
  final VoidCallback? onBackPressed;
  final String title;
  const AppBarActionButtonWidget(
      {super.key,
      required this.title,
      required this.onPressed,
      this.titleColor = titleTextWhiteColor,
      this.iconColor = titleTextWhiteColor,
      this.height = kToolbarHeight,
      required this.iconName,
      this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: scaffoldBg,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          children: [
            InkWell(
              onTap: onBackPressed ?? () => Navigator.of(context).pop(),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(AppAssets.backarrowIcon,
                        width: 22, height: 22, color: iconColor),
                    SizedBox(width: size.width * 0.02),
                    Text(
                      tr(title),
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontSize: 20,
                                color: titleColor,
                                fontWeight: FontWeight.w700,
                              ),
                    )
                  ]),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: IconButton(
              icon: SvgPicture.asset(
                iconName,
                color: titleTextWhiteColor,
              ),
              onPressed: onPressed),
        )
      ],
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(height);
}
