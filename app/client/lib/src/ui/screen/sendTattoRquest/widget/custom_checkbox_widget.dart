import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ink/src/utils/colors.dart';

class CustomCheckboxWidget extends StatelessWidget {
  final String title;
  final bool ischecked;
  final onChanged;

  CustomCheckboxWidget({
    super.key,
    required this.ischecked,
    required this.onChanged,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: 1.5,
          child: Checkbox(
              value: ischecked,
              fillColor: MaterialStateProperty.resolveWith((states) {
                if (!states.contains(MaterialState.selected)) {
                  return socialoginbtn;
                }
                return null;
              }),
              onChanged: onChanged,
              activeColor: titleTextColor,
              checkColor: const Color(0xFF28272f),
              shape: RoundedRectangleBorder(
                  // Making around shape
                  borderRadius: BorderRadius.circular(4)),
              side: BorderSide(
                  color: ischecked
                      ? titleTextColor
                      : lightGrayColor, //const Color(0xFF807C84),
                  width: 1.0)),
        ),
        Text(title,
                style: textTheme.titleMedium!.copyWith(
                    color: titleTextWhiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w400))
            .tr()
      ],
    );
  }
}
