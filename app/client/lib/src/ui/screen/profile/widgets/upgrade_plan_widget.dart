import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/data/source/network/api.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/ui/screen/profile/subscription/iosubscription/purchase_ios_screen.dart';
import 'package:ink/src/ui/screen/profile/subscription/purchase_screen.dart';
import 'package:ink/src/ui/widgets/button/custom_gradient_btn_widget.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';

class UpgradePlanContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
              radius: 30,
              backgroundColor: signInButtonColor,
              child: SvgPicture.asset(
                AppAssets.crownIcon,
                height: 35,
                width: 35,
              )),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          const Text(
            'פינת סקיצות זמינה למנוי פרימיום',
            style: TextStyle(
                color: titleTextWhiteColor,
                fontSize: 18,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          const Text(
            'לניהול פינת סקיצות יש לשדרג את המנוי.',
            style: TextStyle(
              color: titleTextWhiteColor,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.04),
          CustomGradientButtonWidget(
            width: MediaQuery.sizeOf(context).width * 0.35,
            onTap: () async {
              Get.back();
              if (Platform.isAndroid) {
                await Network.getCheckSubscription().then((value) {
                  Get.to(() => PurchaseScreen(
                        fromRegistration: false,
                        checkstatus: value['status'].toString(),
                      ));
                });
              } else {
                await Network.getCheckSubscription().then((value) {
                  if (value['status'].toString() == "0" ||
                      value['data']['subscription_status'].toString() == "0") {
                    Get.to(IOSPurchaseScreen(
                        checkstatus: value['status'].toString(),
                        purchasename: 'ללא תוכנית קנייה',
                        fromRegistration: false));
                  } else if (value['status'].toString() == "2") {
                    ApiResponse.sessionExpired(msg: "alerts.session_expire");
                  } else {
                    Get.to(IOSPurchaseScreen(
                        checkstatus: value['status'].toString(),
                        fromRegistration: false,
                        purchasename: value['data']['product_id'].toString()));
                  }
                });
              }
            },
            title: 'שדרוג המנוי',
          ),
        ],
      ),
    );
  }
}
