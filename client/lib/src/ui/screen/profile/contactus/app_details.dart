import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/userController.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildappBarwithback(
            size: MediaQuery.of(context).size, title: "אודות"),
        body: Padding(
            padding: EdgeInsets.all(Get.size.width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Text(
                //   "about.first_about",
                //   style: Get.textTheme.titleLarge!.copyWith(color: kBlack),
                // ).tr(),

                customText("about.second_about"),
                SizedBox(
                  height: Get.size.height * 0.02,
                ),
                customText("about.third_about"),
                SizedBox(
                  height: Get.size.height * 0.02,
                ),
                customText("about.fourth_about"),
                SizedBox(
                  height: Get.size.height * 0.02,
                ),
                customText("about.fifth_about"),
                SizedBox(
                  height: Get.size.height * 0.02,
                ),
                InkWell(
                    onTap: launchEmailSubmission,
                    child: Text.rich(TextSpan(
                      text:
                          "לכל פניה, בקשה, שאלה או הצעת שיפור ניתן לשלוח מייל - ",
                      style: Get.textTheme.titleMedium!
                          .copyWith(color: kBlack, wordSpacing: 1.4),
                      children: <TextSpan>[
                        TextSpan(
                            text: 'inkraelco@gmail.com',
                            style: Get.textTheme.titleMedium!.copyWith(
                                color: kviolet,
                                wordSpacing: 1.4,
                                decoration: TextDecoration.underline)),
                        // can add more TextSpans here...
                      ],
                    ))),
              ],
            )));
  }

  Text customText(texts) {
    return Text(
      texts,
      textAlign: TextAlign.justify,
      style: Get.textTheme.titleMedium!.copyWith(color: kBlack),
    ).tr();
  }

  Future<void> launchEmailSubmission() async {
    try {
      final userController = Get.put(UserController());
      final Uri params = Uri(
          scheme: 'mailto',
          path: 'inkraelco@gmail.com',
          query:
              'subject=אודות&body=Hello Team ink,\ni am ${userController.name.value}');

      // if (await canLaunchUrl(params)) {
      await launchUrl(params);
      // } else {
      //   log('Could not launch $params');
      // }
    } catch (e) {
      displayMessage('not launch $e', Colors.orange);
    }
  }
}
