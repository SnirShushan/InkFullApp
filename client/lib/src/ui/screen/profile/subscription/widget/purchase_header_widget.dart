import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ink/src/utils/colors.dart';

class PurchaseHeaderWidget extends StatelessWidget {
  const PurchaseHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Column(
      children: [
        Text(
          // "חבילות עיסקיות",
          "חבילות למקעקעים",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: Platform.isIOS ? 23 : 24,
              color: titleTextColor,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w700),
        ).tr(),
        SizedBox(height: size.height * 0.02),
        Text(
          // "פתחו פרופיל עסקי, שתפו את העבודות שלכם וקבלו פניות מאלפי משתמשים",
         // "פתחו פרופיל עסקי, שתפו את העבודות שלכם והתחילו לקבל פניות מלקוחות חדשים באפליקציה",
         "פתחו פרופיל עסקי, שתפו את העבודות שלכם והתחילו לקבל פניות מלקוחות חדשים דרך האפליקציה", //
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: Platform.isIOS ? 17 : 18,
              color: titleTextWhiteColor,
              fontWeight: FontWeight.w400),
        ).tr(),
        SizedBox(height: size.height * 0.03),
      ],
    );
  }
}
