import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';

class NotificationListEmptyWidget extends StatelessWidget {
  final bool isAlertList;

  const NotificationListEmptyWidget({super.key, required this.isAlertList});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        SizedBox(height: size.height * 0.04),
        Container(
          padding: const EdgeInsets.all(16),
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: Color(0xFF211D25),
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            isAlertList ? AppAssets.bellOffIcon : AppAssets.messageOffIcon,
            width: size.width * 0.1,
            color: lightGrayColor,
          ),
        ),
        SizedBox(height: size.height * 0.03),
        Text(
          isAlertList ? "אין התראות חדשות" : 'לא נשלחו פניות למקעקעים',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: titleTextWhiteColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: size.height * 0.02),
        Text(
          isAlertList
              ? "עקבו אחרי מקעקעים וקבלו התראות  ועדכונים ברגע שיעלו תכנים חדשים"
              : 'לאחר שתשלחו פנייה למקעקע, תוכלו לצפות בה כאן',
          textAlign: TextAlign.center,
          style: textTheme.titleMedium!.copyWith(
            color: titleTextWhiteColor,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        )
      ],
    );
  }
}
