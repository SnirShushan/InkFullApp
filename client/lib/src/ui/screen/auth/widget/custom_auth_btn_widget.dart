import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ink/src/utils/colors.dart';

class CustomAuthBtnWidget extends StatelessWidget {
  final String title;
  final Function()? onTap;
  const CustomAuthBtnWidget(
      {super.key, required this.onTap, required this.title});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return InkWell(
      onTap: onTap,
      child: Container(
          width: size.width,
          height: size.height * 0.07,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            gradient: appLinearGradient,
          ),
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: kWhite, fontWeight: FontWeight.w700),
          ).tr()),
    );
  }
}
