import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';

class SendingRequestSuccess extends StatelessWidget {
  const SendingRequestSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: bgBlack,
        body: Padding(
          padding: EdgeInsets.all(size.height * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.07),
              Text('sending_request_success.sending_request_success_title',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    color: titleTextColor,
                    fontWeight: FontWeight.w700,
                  )).tr(),
              SizedBox(height: size.height * 0.02),
              Text('sending_request_success.sending_request_success_subtitle',
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge?.copyWith(
                    color: titleTextWhiteColor,
                    fontWeight: FontWeight.w400,
                  )).tr(),
              const Spacer(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
                child: Image.asset(AppAssets.requestSuccess),
              ),
              const Spacer(),
              Text('sending_request_success.sending_request_success_note',
                  textAlign: TextAlign.center,
                  style: textTheme.titleSmall?.copyWith(
                    fontSize: 14,
                    color: lightGrayColor,
                    fontWeight: FontWeight.w400,
                  )).tr(),
              SizedBox(height: size.height * 0.04),
              buildBtnSubmit(context: context, size: size),

              SizedBox(height: Platform.isAndroid?size.height * 0.06:size.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  InkWell buildBtnSubmit({required BuildContext context, required Size size}) =>
      InkWell(
        onTap: () async {
          if (!Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Get.back();
              }
            });
          }
        },
        child: Container(
            width: size.width,
            height: size.height * 0.07,
            alignment: Alignment.center,
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
            child: Text(
              "sending_request_success.sending_request_success_btn",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: kWhite, fontWeight: FontWeight.w700),
            ).tr()),
      );
}
