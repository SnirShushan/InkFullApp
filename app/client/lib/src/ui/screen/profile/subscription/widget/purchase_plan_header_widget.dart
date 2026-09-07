import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';

class PlanHeader {
  final String title;
  final bool isBoth;

  const PlanHeader({
    required this.title,
    required this.isBoth,
  });
}

class PurchasePlanHeaderWidget extends StatelessWidget {
  final bool isBasicPlan;

   PurchasePlanHeaderWidget({super.key, required this.isBasicPlan});

  // final basicPlan = [
  //   //  "פתיחת פרופיל עסקי לסטודיו ולכל המקעקעים",
  //   "פתיחת פרופיל עסקי לסטודיו או למקעקע",
  //   "חשיפת העסק למשתמשי האפליקציה",
  //   "קבלת לידים היישר לתיבת הפניות",
  //   "תמיכה טכנית ושירות לקוחות",
  // ];
  //
  // final advancePlan = [
  //   //  "פתיחת פרופיל עסקי לסטודיו ולכל המקעקעים",
  //   "פתיחת פרופיל עסקי לסטודיו או למקעקע",
  //   "חשיפת העסק למשתמשי האפליקציה",
  //   "קבלת לידים היישר לתיבת הפניות",
  //   "תמיכה טכנית ושירות לקוחות",
  //   "קידום העסק באפקליציה",
  //   "פינת סקיצות ייחודית משלך"
  // ];

  final basicPlan = [
    const PlanHeader(title: "פניות מלקוחות – ללא הגבלה", isBoth: true),
    const PlanHeader(title: "העלאת עד 5 תמונות גלריה לפרופיל", isBoth: true),
    const PlanHeader(title: "חשיפת העסק למשתמשי האפליקציה", isBoth: true),
    const PlanHeader(title: "פתיחת פרופיל עסקי", isBoth: true),
    const PlanHeader(title: "תמיכה טכנית ושירות לקוחות", isBoth: true),
  ];

  final advancePlan = [
    const PlanHeader(title: "העלאת תמונות וסקיצות – ללא הגבלה", isBoth: false),
    const PlanHeader(title: "קידום הפרופיל והעבודות באפליקציה", isBoth: false),
    const PlanHeader(title: "פינת סקיצות ייחודית משלך", isBoth: false),
    const PlanHeader(title: "שינוי הפרופיל לסטודיו והוספת מקעקעים", isBoth: false),
    const PlanHeader(title: "פניות מלקוחות – ללא הגבלה", isBoth: true),
    const PlanHeader(title: "חשיפת העסק למשתמשי האפליקציה", isBoth: true),
    const PlanHeader(title: "פתיחת פרופיל עסקי", isBoth: true),
    const PlanHeader(title: "תמיכה טכנית ושירות לקוחות", isBoth: true),
  ];

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    final plans = isBasicPlan ? basicPlan : advancePlan;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              isBasicPlan ? "חבילת בייסיק" : "חבילת פרימיום",
              style: TextStyle(
                fontSize: Platform.isIOS ? 21 : 22,
                color: titleTextWhiteColor,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w700,
              ),
            ).tr(),
          ),
        ),
        SizedBox(height: size.height * 0.02),
        SizedBox(
          height: isBasicPlan ? size.height * 0.20 :size.height * 0.3,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: size.height * 0.0025),
                child: Row(
                  children: [
                    Image.asset(
                      isBasicPlan
                          ? AppAssets.purchaseCheckIcon
                          : plans[index].isBoth?AppAssets.purchaseCheckIcon:AppAssets.purchasepremiumCheckIcon,
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: size.width * 0.75,
                      child: Text(
                        plans[index].title, // ✅ Always access .title
                        style: TextStyle(
                          fontSize: Platform.isIOS ? 15 : 16,
                          color: titleTextWhiteColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
