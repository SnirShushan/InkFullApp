import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/webService.dart';

import '../model/bsas_model.dart';
import 'purchase_elevated_button.dart';

class PurchaseFooterWidget extends StatelessWidget {
  final Function() onRestorePurchase;
  final Function() onbasicClick;
  final Function() onpremiumClick;
  final bool isLoading;

  const PurchaseFooterWidget(
      {super.key,
      required this.onRestorePurchase,
      required this.onbasicClick,
      this.isLoading = false,
      required this.onpremiumClick});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Column(
      children: [
        const Text(
          "purchases.bsvsps_title",
          style: TextStyle(
              fontSize: 20,
              color: titleTextWhiteColor,
              fontWeight: FontWeight.w700),
        ).tr(),
        SizedBox(height: size.height * 0.03),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
          child: Row(
            children: [
              Expanded(
                  flex: 5,
                  child: const Text(
                    "purchases.bsvsps_subtitle_1",
                    style: TextStyle(
                        fontSize: 14,
                        color: dividerGray,
                        fontWeight: FontWeight.w700),
                  ).tr()),
              Expanded(
                  flex: 2,
                  child: const Text(
                    "purchases.bsvsps_subtitle_2",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        color: titleTextColor,
                        fontWeight: FontWeight.w700),
                  ).tr()),
              Expanded(
                  flex: 2,
                  child: const Text(
                    "purchases.bsvsps_subtitle_3",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        color: advanceplancolor,
                        fontWeight: FontWeight.w700),
                  ).tr()),
            ],
          ),
        ),
        SizedBox(height: size.height * 0.02),
        SizedBox(
            height: size.height * 0.63, //* 0.34,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: purchaseListModel.length,
              itemBuilder: (context, index) {
                final item = purchaseListModel[index];
                return Container(
                  padding: EdgeInsets.symmetric(
                      vertical: size.height * 0.02,
                      horizontal: size.width * 0.04),
                  decoration: BoxDecoration(
                      color:
                          (index % 2 != 0) ? Colors.transparent : socialoginbtn,
                      borderRadius: BorderRadius.circular(9)),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 5,
                          child: Text(
                            item.title,
                            style: const TextStyle(
                                fontSize: 14,
                                color: titleTextWhiteColor,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Arimo'),
                          )),
                      Expanded(
                          flex: 2,
                          child: _buildTrailing(
                            value: item.basicvalue,
                            color: titleTextColor,
                          )),
                      Expanded(
                          flex: 2,
                          child: _buildTrailing(
                            value: item.advancevalue,
                            color: advanceplancolor,
                          )),
                    ],
                  ),
                );
              },
            )),
        SizedBox(height: size.height * 0.02),
        PurchaseElevatedBtnWidget(
            isbasicplan: false,
            ismainscreen: true,
            onTaps: onpremiumClick,
            title: 'purchases.bsvsps_btn_2',
            subtitle: ''),

        SizedBox(height: size.height * 0.02),
        PurchaseElevatedBtnWidget(
            isbasicplan: true,
            ismainscreen: true,
            onTaps: onbasicClick,
            title: 'purchases.bsvsps_btn_1',
            subtitle: ''),
        SizedBox(height: size.height * 0.04),
        const Text(
          "purchases.confusion?",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20, color: whiteTxtColor,fontFamily: 'Arimo', fontWeight: FontWeight.w700),
        ).tr(),
        SizedBox(height: size.height * 0.01),
        const Text(
          "purchases.confusion_description",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontFamily: 'Arimo',
              fontSize: 16,
              color: titleTextWhiteColor,
              fontWeight: FontWeight.w400),
        ).tr(),
        SizedBox(height: size.height * 0.03),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildBottomIcon(
                onTaps: () {
                  var whatsappAndroid =
                      "whatsapp://send?phone=${WebService.whatsappclient2}";
                  WebService.openUrl(whatsappAndroid);
                },
                imagedata: AppAssets.whatsappIcon,
                title: "purchases.whatsapp",
                size: size),
            SizedBox(
              width: size.width * 0.1,
            ),
            buildBottomIcon(
                onTaps: () =>
                    WebService.openUrl("mailto:${WebService.emailclient}"),
                imagedata: AppAssets.emailIcon,
                title: "purchases.email",
                size: size),
            // buildBottomIcon(
            //     onTaps: () =>
            //         WebService.openUrl("tel:${WebService.phonenoclient}"),
            //     imagedata: AppAssets.mobileIcon,
            //     title: "purchases.phone",
            //     size: size),
          ],
        ),
        SizedBox(height: size.height * 0.03),
        //Restore a Purchase
        InkWell(
            splashColor: Colors.grey,
            onTap: () {
              showDialog<String>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) => StatefulBuilder(
                  builder: (context, setState) => AlertDialog(
                    titlePadding: const EdgeInsets.all(1.0),
                    backgroundColor: socialoginbtn,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text("שחזר מנוי",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: titleTextWhiteColor,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 16),
                          const Text("האם אתה רוצה לשחזר את המנוי שלך?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: titleTextWhiteColor,
                                  fontWeight: FontWeight.w400)),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: kWhite,
                                        backgroundColor: titleTextColor,
                                      ),
                                      onPressed: onRestorePurchase,
                                      child: const Text("מְשׁוּחזָר")),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: titleTextWhiteColor,
                                    backgroundColor: const Color(0xFF403D44),
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text("לְבַטֵל")),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            child: Text("שחזר רכישה",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontSize: 16,
                    color: const Color(0xFFC0BCC4),
                    fontWeight: FontWeight.w400))),
        SizedBox(height: size.height * 0.03),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
          child: Text(
            Platform.isIOS
                ? "מנויים בתשלום מתחדשים אוטומטית לפי התקופה והמחיר שמוצגים ליד כפתור הרכישה. התשלום יחויב מחשבון ה‑Apple ID באישור הרכישה. החידוש יתבצע אלא אם תבטל לפחות 24 שעות לפני סוף התקופה. החיוב הבא מתבצע במהלך 24 השעות שלפני סיום התקופה. ניהול וביטול: הגדרות ← Apple ID ← מנויים. אם מוצעת תקופת ניסיון, יתרתה שאינה מנוצלת תפקע עם הרכישה."
                : "מנויים בתשלום מתחדשים אוטומטית לפי התקופה והמחיר שמוצגים ליד כפתור הרכישה. התשלום יחויב מחשבון Google Play. ניתן לבטל בכל עת דרך Google Play ← מנויים.",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Arimo',
              fontSize: 12,
              height: 1.45,
              color: Color(0xFFC0BCC4),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        SizedBox(height: size.height * 0.02),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => WebService.openLegalUrl(WebService.termsOfUseUrl),
              child: buildTextUnderline(
                context,
                "תנאי השימוש",
              ),
            ),
            Text(tr("registration.terms_3"),
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontSize: 16,
                    color: const Color(0xFFC0BCC4),
                    fontWeight: FontWeight.w400)),
            InkWell(
              onTap: () =>
                  WebService.openLegalUrl(WebService.privacyPolicyUrl),
              child: buildTextUnderline(
                context,
                "מדיניות הפרטיות",
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.03),
      ],
    );
  }

  InkWell buildBottomIcon(
      {required String imagedata,
      required String title,
      required Size size,
      required Function() onTaps}) {
    return InkWell(
      onTap: onTaps,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            width: size.width * 0.16,
            height: size.width * 0.16,
            imagedata,
          ),
          SizedBox(height: size.height * 0.01),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Arimo',
                fontSize: 14,
                color: titleTextWhiteColor,
                fontWeight: FontWeight.w400),
          ).tr(),
        ],
      ),
    );
  }

  Widget _buildTrailing({dynamic value, color}) {
    if (value is String) {
      return Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 14.0, color: color, fontWeight: FontWeight.w400),
      );
    } else if (value is bool) {
      return value
          ? Icon(Icons.check, color: color)
          : Icon(Icons.close, color: color);
    } else {
      throw Exception("Unsupported value type: ${value.runtimeType}");
    }
  }

  Text buildTextUnderline(BuildContext context, title) {
    return Text(title,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontSize: 16,
            color: const Color(0xFFC0BCC4),
            fontWeight: FontWeight.w400,
            decoration: TextDecoration.underline));
  }
}
