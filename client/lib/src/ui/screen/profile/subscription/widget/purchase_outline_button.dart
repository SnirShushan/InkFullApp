import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ink/src/utils/colors.dart';

class PurchaseOutlineWidget extends StatefulWidget {
  final String? title;
  final String? subtitle;
  final bool isbasicplan;
  final Function() onTaps;

  const PurchaseOutlineWidget(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.onTaps,
      required this.isbasicplan});

  @override
  State<PurchaseOutlineWidget> createState() => _PurchaseOutlineWidgetState();
}

class _PurchaseOutlineWidgetState extends State<PurchaseOutlineWidget> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
          style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(
                  width: 2.0,
                  color:
                      widget.isbasicplan ? titleTextColor : advanceplancolor),
              padding: const EdgeInsets.symmetric(vertical: 18.0)),
          onPressed: widget.onTaps,
          child: Column(
            children: [
              Text(
                widget.title!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    color:
                        widget.isbasicplan ? titleTextColor : advanceplancolor,
                    fontWeight: FontWeight.w700),
              ).tr(),
              SizedBox(
                height: size.height * 0.01,
              ),
              Text(
                widget.subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color:
                        widget.isbasicplan ? titleTextColor : advanceplancolor,
                    fontWeight: FontWeight.w400),
              ).tr()
            ],
          )),
    );
  }
}
