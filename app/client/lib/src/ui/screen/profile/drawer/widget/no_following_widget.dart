import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/business_dashboard.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/bussinessdashboard_binding.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard_binding.dart';
import 'package:ink/src/ui/widgets/button/custom_gradient_btn_widget.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/utils_styles.dart';

class NoFollowingWidget extends StatelessWidget {
  final String currentUserType;
  final Size size;

  const NoFollowingWidget(
      {super.key, required this.size, required this.currentUserType});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Center(
            child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(AppAssets.noUserRound, height: size.height * 0.07),
        SizedBox(height: size.height * 0.02),
        Text(
          tr("not_found_profile_menu.noFollowingTitle"),
          style: bigBoldWhiteStyle,
        ),
        SizedBox(height: size.height * 0.01),
        Text(
          tr("not_found_profile_menu.noFollowingSubtitle"),
          style: normalWhiteStyle,
        ),
        SizedBox(height: size.height * 0.04),
        CustomGradientButtonWidget(
          width: size.width * 0.4,
          textSize: 14,
          onTap: () {
            if (currentUserType == "2") {
              Get.offAll(BusinessDashBoard(initialIndex: 3),
                  binding: BusinessDashBoardBinding());
            } else {
              Get.offAll(const DashBoard(initialIndex: 2),
                  binding: DashBoardBinding());
            }
          },
          title: tr("not_found_profile_menu.noFollowingBtn"),
        ),
      ],
    )));
  }
}
