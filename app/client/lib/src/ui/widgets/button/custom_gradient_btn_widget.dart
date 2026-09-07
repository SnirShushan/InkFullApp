import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ink/src/utils/colors.dart';

class CustomGradientButtonWidget extends StatelessWidget {
  final String title;
  final double width;
  final double height;
  final double radius;
  final double textSize;
  final VoidCallback onTap;

  const CustomGradientButtonWidget(
      {super.key,
        this.width=0.0,
        this.height=0.0,
        this.radius=10.0,
        this.textSize=16.0,
      required this.title,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width==0.0?size.width:width,
        height:height==0.0? size.height * 0.06:height,
        clipBehavior: Clip.antiAlias,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: appLinearGradient,
          borderRadius: BorderRadius.circular((radius)),
        ),
        child: Text(tr(title),
            style: textTheme.titleMedium!.copyWith(
                fontSize: textSize,
                color: titleTextWhiteColor,
                fontWeight: FontWeight.w500)),
      ),
    );
  }
}
