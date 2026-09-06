import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ink/src/utils/colors.dart';

class CustomButtonWidget extends StatelessWidget {
  final Color btnColor;
  final Color txtColor;
  final String title;
  final VoidCallback onTap;

  const CustomButtonWidget(
      {super.key,
      required this.btnColor,
      required this.txtColor,
      required this.title,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: size.width,
        height: size.height * 0.06,
        clipBehavior: Clip.antiAlias,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: btnColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(tr(title),
            style: textTheme.titleMedium!.copyWith(
                fontSize: 16, color: txtColor, fontWeight: FontWeight.w500)),
      )
    );
  }
}
