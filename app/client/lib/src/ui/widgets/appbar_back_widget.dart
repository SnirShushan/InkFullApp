import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';

class AppBarBackButtonWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final Color titleColor;
  final Color iconColor;
  final double height;
  final String title;
  final bool isAction;
  const AppBarBackButtonWidget(
      {super.key,
      required this.title,
      required this.titleColor,
      required this.iconColor,
      this.isAction = false,
      this.height = kToolbarHeight});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: scaffoldBg,
      title: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(AppAssets.backarrowIcon,
                      width: 22, height: 22, color: iconColor),
                  SizedBox(width: size.width * 0.02),
                  Text(
                    tr(title),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 20,
                          color: titleColor,
                          fontWeight: FontWeight.w700,
                        ),
                  )
                ]),
          ),
        ],
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(height);
}
