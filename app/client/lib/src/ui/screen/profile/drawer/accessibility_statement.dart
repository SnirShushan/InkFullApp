import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/ui/widgets/appbar_back_widget.dart';
import 'package:ink/src/ui/widgets/bottomenu/business_dashboard_bottomenu.dart';
import 'package:ink/src/ui/widgets/bottomenu/dashboard_bottomenu.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/webService.dart';
import 'package:url_launcher/url_launcher.dart';

class AccessibilityStatementScreen extends StatefulWidget {
  const AccessibilityStatementScreen({super.key});

  @override
  State<AccessibilityStatementScreen> createState() =>
      _AccessibilityStatementScreenState();
}

class _AccessibilityStatementScreenState
    extends State<AccessibilityStatementScreen> {
  String? userTypes = "";

  @override
  void initState() {
    _initialization();
    super.initState();
  }
  Future<void> _initialization() async {
    AppUser user = await WebService.getCurrentUser();

    setState(() {
      userTypes = user.profile!.userType!.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bgBlack,
      appBar: const AppBarBackButtonWidget(
          title: 'הצהרת נגישות',
          titleColor: titleTextWhiteColor,
          iconColor: titleTextWhiteColor),
      bottomNavigationBar: userTypes == "2"
          ? BusinessDashboardBottomBar(
              currentIndex: 4,
            )
          : DashboardBottomBar(currentIndex: 3),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [

              buildTextDescription(title: "accessibility.accessibility_desc_1"),
              buildTextTitle(
                  size: size, title: "accessibility.accessibility_title_1"),
              buildTextDescription(
                  title: "accessibility.accessibility_point_1",
                  isBulletText: true),
              buildTextDescription(
                  title: "accessibility.accessibility_point_2",
                  isBulletText: true),
              buildTextDescription(
                  title: "accessibility.accessibility_point_3",
                  isBulletText: true),
              buildTextDescription(
                  title: "accessibility.accessibility_point_4",
                  isBulletText: true),
              buildTextDescription(
                  title: "accessibility.accessibility_point_5",
                  isBulletText: true),
              buildTextTitle(
                  size: size, title: "accessibility.accessibility_title_2"),
              buildTextDescription(title: "accessibility.accessibility_desc_2"),
              buildTextTitle(
                  size: size, title: "accessibility.accessibility_title_3"),
              InkWell(
                onTap: () => launchEmailSubmission(),
                child: buildTextDescription(
                    title: "accessibility.accessibility_email",
                    isBulletText: true),
              ),
              SizedBox(height: size.height * 0.01),
              InkWell(
                onTap: () {
                  String whatsapp = WebService.whatsappclient2;

                  String textMessage = "";
                  if (Platform.isAndroid) {
                    var whatsappAndroid =
                        "whatsapp://send?phone=$whatsapp&text=$textMessage";
                    WebService.openUrl(whatsappAndroid);
                  } else {
                    var whatsappIOS =
                        "https://wa.me/$whatsapp/?text=${Uri.encodeFull(textMessage)}";
                    WebService.openUrl(whatsappIOS);
                  }
                },
                child:buildTextDescription(
                    title: "accessibility.accessibility_phone",
                    isBulletText: true),
              ),

              SizedBox(height: size.height * 0.03),
              buildTextDescription(title: "accessibility.accessibility_last"),
              SizedBox(height: size.height*0.02),
            ],
          ),
        ),
      ),
    );
  }

  Row buildTextDescription({required String title, bool isBulletText = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isBulletText)
          const Text(
            '•  ',
            style: TextStyle(
              color: Color(0xFFDFDCE3),
              fontSize: 16,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w400,
            ),
          ), // Bullet
        Expanded(
            child: Text(
          tr(title),
          style: const TextStyle(
              color: Color(0xFFDFDCE3),
              fontSize: 16,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w400,
              height: 1.3),
        )),
      ],
    );
  }

  buildTextTitle({required String title, required Size size}) => Padding(
        padding: EdgeInsets.symmetric(vertical: size.height * 0.03),
        child: Text(
          tr(title),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFDFDCE3),
            fontSize: 16,
            fontFamily: 'Arimo',
            fontWeight: FontWeight.w400,
            letterSpacing: 0.56,
          ),
        ),
      );

  Future<void> launchEmailSubmission() async {
    try {
      AppUser user = await WebService.getCurrentUser();
      user.profile!.name.toString();
      final Uri params = Uri(
          scheme: 'mailto',
          path: 'inkraelco@gmail.com',
          query:
              'subject=אודות&body=Hello Team ink,\ni am ${user.profile!.name.toString()}');

      // if (await canLaunchUrl(params)) {
      await launchUrl(params);
      // } else {
      //   log('Could not launch $params');
      // }
    } catch (e) {
      displayMessageIcon(
          message: e.toString(),
          color: errorColor,
          imageData: AppAssets.errorIcon);
    }
  }
}
