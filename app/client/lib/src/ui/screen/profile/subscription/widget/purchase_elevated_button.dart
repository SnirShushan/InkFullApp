import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ink/src/utils/colors.dart';

class PurchaseElevatedBtnWidget extends StatefulWidget {
  final String? title;
  final String? subtitle;
  final bool isbasicplan;
  final bool ismainscreen;
  final Function() onTaps;

  const PurchaseElevatedBtnWidget(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.onTaps,
      this.ismainscreen = false,
      required this.isbasicplan});

  @override
  State<PurchaseElevatedBtnWidget> createState() =>
      _PurchaseElevatedBtnWidgetState();
}

class _PurchaseElevatedBtnWidgetState extends State<PurchaseElevatedBtnWidget> {
  @override
  Widget build(BuildContext context) {
    double textScaleFactor = MediaQuery.textScalerOf(context).scale(1);
    var size = MediaQuery.of(context).size;
    return SizedBox(
      width: double.infinity,
      child: widget.isbasicplan
          ? InkWell(
        onTap: widget.onTaps,
            child: Container(
                width: size.width,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 18.0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  gradient: LinearGradient(
                    begin: Alignment.centerRight, // For RTL, start from right
                    end: Alignment.centerLeft, // For RTL, end at left
                    colors: [
                      linearGradieantColor1,
                      linearGradieantColor2,
                      linearGradieantColor3,
                    ],
                    stops: [0.0, 0.001, 0.8937],
                  ),
                ),
                child: widget.ismainscreen
                    ? Text(
                        tr(widget.title!),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16 * textScaleFactor,
                            color: widget.isbasicplan ? dialogTxtColor : bgBlack,
                            fontWeight: FontWeight.w700),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            tr(widget.title!),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16 * textScaleFactor,
                                color:
                                    widget.isbasicplan ? dialogTxtColor : bgBlack,
                                fontWeight: FontWeight.w700),
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          Text(
                            tr(widget.subtitle!),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14 * textScaleFactor,
                                color: bgBlack,
                                fontWeight: FontWeight.w400),
                          )
                        ],
                      )),
          )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                  alignment: Alignment.center,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // <-- Radius
                  ), // Rounded corners
                  padding: EdgeInsets.symmetric(
                      vertical:18.0),
                  backgroundColor:
                      widget.isbasicplan ? titleTextColor : advanceplancolor),
              onPressed: widget.onTaps,
              child: widget.ismainscreen
                  ? Text(
                      widget.title!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16 * textScaleFactor,
                          color: widget.isbasicplan ? dialogTxtColor : bgBlack,
                          fontWeight: FontWeight.w700),
                    ).tr()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.title!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16 * textScaleFactor,
                              color:
                                  widget.isbasicplan ? dialogTxtColor : bgBlack,
                              fontWeight: FontWeight.w700),
                        ).tr(),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        Text(
                          widget.subtitle!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14 * textScaleFactor,
                              color: bgBlack,
                              fontWeight: FontWeight.w400),
                        ).tr()
                      ],
                    )),
    );
  }
}
