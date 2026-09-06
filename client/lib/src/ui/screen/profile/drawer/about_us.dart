import 'package:flutter/material.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/ui/widgets/appbar_back_widget.dart';
import 'package:ink/src/ui/widgets/bottomenu/business_dashboard_bottomenu.dart';
import 'package:ink/src/ui/widgets/bottomenu/dashboard_bottomenu.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/utils_styles.dart';
import 'package:ink/src/utils/webService.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
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
    return Scaffold(
      backgroundColor: bgBlack,
      appBar: const AppBarBackButtonWidget(
          title: 'אודות',
          titleColor: titleTextWhiteColor,
          iconColor: titleTextWhiteColor),
      bottomNavigationBar: userTypes == "2"
          ? BusinessDashboardBottomBar(
              currentIndex: 4,
            )
          : DashboardBottomBar(currentIndex: 3),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'ברוכים הבאים לאינק!\nאפליקציית הקעקועים של ישראל.',
                style: bigBoldWhiteStyle,
              ),
              const SizedBox(height: 24),
              Text(
                'פלטפורמת "אינק" הוקמה מתוך רצון לתת מענה למקעקעים ולמקועקעים ברחבי הארץ.',
                style: normalWhiteStyle,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 16),
              Text(
                'חזון האפליקציה הוא להנגיש את חווית ההתקעקעות והחיפוש לדבר פשוט, החל מהשלב של חיפוש השראה ראשונית לקעקוע, שלב מציאת המקעקע שמתאים לסגנון שלכם ועד ביצוע הקעקוע.',
                style: normalWhiteStyle,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 16),
              Text(
                'האפליקציה נותנת במה וחיפוש לאמני קעקועים בכל הרמות, מתחילים ועד ותיקים מתוך רצון לקדם את תחום הקעקועים ואת המקעקעים בארץ.',
                style: normalWhiteStyle,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 16),
              Text(
                'לכל פניה, בקשה, שאלה או הצעה לשיפור ניתן לשלוח מייל:',
                style: normalWhiteStyle,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => launchEmailSubmission(),
                child: IntrinsicWidth(
                  child: Column(
                    children: [
                      Text(
                        'inkraelco@gmail.com',
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: dividerGray,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                          height: 1,
                          decoration: const ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                strokeAlign: BorderSide.strokeAlignCenter,
                                color: titleTextColor,
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
