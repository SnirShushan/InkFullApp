import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/ui/screen/profile/drawer/TAC/term_model.dart';
import 'package:ink/src/ui/widgets/appbar_back_widget.dart';
import 'package:ink/src/ui/widgets/bottomenu/business_dashboard_bottomenu.dart';
import 'package:ink/src/ui/widgets/bottomenu/dashboard_bottomenu.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/utils_styles.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../utils/webService.dart';
import '../FAQ/toggle_button.dart';

class TermsOfUse extends StatefulWidget {
  final initialIndex;
  final bool isRegistrationScreen;

  const TermsOfUse(
      {super.key, this.initialIndex = 0, this.isRegistrationScreen = false});
  @override
  State<TermsOfUse> createState() => _TermsOfUseState();
}

class _TermsOfUseState extends State<TermsOfUse>
    with SingleTickerProviderStateMixin {
  bool conditions = true;
  final List<String> terms = [
    "1. כללי\n1.1. ברוכים הבאים לאפליקציה \"אינק ישראל\" (להלן: \"האפליקציה\").\n1.2. האפליקציה הינה בבעלות אינק ישראל ח\"פ 434564515 (להלן: \"הבעלים\") וכל שימוש בה על ידך כפוף להוראות תנאי השימוש להלן.\n1.3. בהעדר הסכמה לאילו מהתנאים הכלולים בתנאי שימוש אלו, עליך להימנע מלעשות כל שימוש באפליקציה.\n1.4. בבחירתך לעשות שימוש כלשהו באפליקציה הנך להסכים לתנאי שימוש אלו במלואם.\n1.5. הבעלים שומרים לעצמם את הזכות לשנות תנאי שימוש אלו, והנך להסכים בזאת כי בכל שימוש שלך באפליקציה לאחר המועד שבו תנאים אלו השתנו עליך לקבל על עצמך את הגרסה המעודכנת.\n1.6. אם הנך מתחת לגיל 13, אינך מורשה להשתמש באפליקציה זו או לבצע כל פעילות בה ללא הסכמת הוריך. על ידי לחיצה על \"אני מסכים\", אתה מאשר שהם קראו ומסכימים להוראות תנאי שימוש אלה.\n1.7. האפליקציה נועדה לשימושך, בכפוף לתנאי שימוש אלו.\n1.8. תנאי שימוש אלו חלים על האפליקציה ו/או חלקים ממנה ועל השימוש בה ובתכנים הכלולים בה, לרבות על עיצובים, קוד מקור, מודולי תוכנה ותכנים ו/או מוצרים ו/או שירותים כלשהם של האפליקציה ו/או שהאפליקציה מאפשרת נגישות ו/או הורדה שלהם, והם מהווים חלק בלתי נפרד מהם ומתפקוד האפליקציה ו/או משירותים המוצעים בה ו/או באמצעותה, בתמורה או שלא בתמורה (להלן, ביחד ולחוד: \"השירותים\").\n1.9. הסדרת רישיונות כלשהם לצורך שימוש באפליקציה (כגון רישיון נהיגה, רישיון עסק, רישיון לעסוק בתיווך וכו') כמו גם ביטוח מכל סוג, תשלומי מיסים והוצאות והסדרה של עניינים אחרים הנובעים מהוראות החוק לצורך ביצוע פעילות עסקית או אחרת באמצעות אפליקציה זו, הנם באחריותך בלבד.\n1.10. השימוש במידע, במוצרים ו/או בשירותים כלשהם באמצעות האפליקציה ובכלל הינם באחריותך הבלעדית ובכפוף להוראות תנאי שימוש אלו.\n1.11. הנך להסכים בזאת במפורש כי הבעלים פטורים לחלוטין מכל אחריות, נזק או אי נוחות, לך או לאחרים, לגבי כל היבט של שימוש באפליקציה/במוצרים/בשירותים באמצעות האפליקציה או שיסופקו לך באמצעותה והנך לקחת את כל האחריות לכך על עצמך בלבד ולבצע את כל הבדיקות הדרושות.",
    // Ajoutez d'autres sections ici
  ];

  final termListModel = [];
  TabController? tabController;
  final ScrollController scrollController = ScrollController();
  String userTypes = "";
  @override
  void initState() {
    tabController = TabController(
        length: 2,
        vsync: this,
        animationDuration: Duration.zero,
        initialIndex: widget.initialIndex);
    super.initState();
    if (widget.isRegistrationScreen == false) {
      _initialization();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: bgBlack,
      bottomNavigationBar: widget.isRegistrationScreen == true
          ? null
          : userTypes == "2"
              ? BusinessDashboardBottomBar(
                  currentIndex: 4,
                )
              : DashboardBottomBar(currentIndex: 3),
      appBar: const AppBarBackButtonWidget(
          title: 'תנאי שימוש ופרטיות',
          titleColor: titleTextWhiteColor,
          iconColor: titleTextWhiteColor),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.03, vertical: size.height * 0.04),
        child: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: tabController,
            children: [
              Terms(size: size),
              Privacy(size: size),
              // View2(size:size)
            ]),
      ),
    );
  }

  //terms
  Terms({size}) => SizedBox(
        height: size.height * 0.8,
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //toggle terms & privacy
              Row(
                children: [
                  ToggleButton(
                      onPressed: () {
                        tabController!.index = 0;
                        tabController!.notifyListeners();
                      },
                      isSelected: true,
                      text: 'תנאי שימוש'),
                  const SizedBox(width: 5),
                  ToggleButton(
                      onPressed: () {
                        tabController!.index = 1;
                        tabController!.notifyListeners();
                      },
                      isSelected: false,
                      // text: 'מדיניות פרטית'
                      text: 'מדיניות פרטיות'),
                ],
              ),
              const SizedBox(height: 16),
              //title
              Padding(
                padding: EdgeInsets.all(size.width * 0.04),
                child:
                    Text("תנאי שימוש “אינק ישראל”", style: bigBoldWhiteStyle),
              ),
              //const SizedBox(height: 4),
              //terms
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: termList.length,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //point
                      Padding(
                        padding: EdgeInsets.all(size.width * 0.02),
                        child: Text(termList[index].mainTitle.toString(),
                            style: bigBoldWhiteStyle),
                      ),

                      //description
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: termList[index].description!.length,
                        itemBuilder: (context, i) {
                          return Padding(
                            padding: EdgeInsets.all(size.width * 0.02),
                            child: Text(
                                termList[index].description![i].toString(),
                                style: textStyle14s400w.copyWith(fontSize: 16),
                                textAlign: TextAlign.right),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              //contact info
              contactInfo(size)
            ],
          ),
        ),
      );

  //privacy
  Privacy({size}) => SizedBox(
        height: size.height * 0.8,
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //toggle terms & privacy
              Row(
                children: [
                  ToggleButton(
                      onPressed: () {
                        tabController!.index = 0;
                        tabController!.notifyListeners();
                      },
                      isSelected: false,
                      text: 'תנאי שימוש'),
                  const SizedBox(width: 5),
                  ToggleButton(
                      onPressed: () {
                        tabController!.index = 1;
                        tabController!.notifyListeners();
                        // setState(() {
                        //   conditions = !conditions;
                        // });
                      },
                      isSelected: true,
                      text: 'מדיניות הפרטיות'),
                ],
              ),

              const SizedBox(height: 16),

              //title
              Padding(
                padding: EdgeInsets.all(size.width * 0.04),
                child: Text("מדיניות פרטיות “אינק ישראל”",
                    style: bigBoldWhiteStyle),
              ),

              //  const SizedBox(height: 8),

              //privacy list
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: privacyList.length,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //point
                      Padding(
                        padding: EdgeInsets.all(size.width * 0.02),
                        child: Text(privacyList[index].mainTitle.toString(),
                            style: bigBoldWhiteStyle),
                      ),

                      //  SizedBox(height: size.height * 0.02),

                      //description
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: privacyList[index].description!.length,
                        itemBuilder: (context, i) {
                          return Padding(
                            padding: EdgeInsets.all(size.width * 0.02),
                            child: Text(
                                privacyList[index].description![i].toString(),
                                style: textStyle14s400w.copyWith(fontSize: 16),
                                textAlign: TextAlign.right),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),

              //contact info
              contactInfo(size)
            ],
          ),
        ),
      );

  //contact us
  contactInfo(size) => Padding(
        padding: EdgeInsets.all(size.width * 0.03),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          bottomRowMethod(
              title: "שם", desc: "אינק ישראל", type: "Normal", ontap: () {}),
          SizedBox(height: size.height * 0.02),
          bottomRowMethod(
              title: "ווטסאפ",
              // desc: "053-356-2686",
              desc: "052-540-1620",
              type: "phone",
              ontap: () {
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
              underline: true),
          SizedBox(height: size.height * 0.02),
          bottomRowMethod(
              title: "Email",
              desc: WebService.emailclient,
              type: "Email",
              ontap: () => launchEmailSubmission(),
              underline: true),
        ]),
      );

  InkWell bottomRowMethod(
      {required String title,
      required String desc,
      bool underline = false,
      required String type,
      required Function() ontap}) {
    return InkWell(
      onTap: ontap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$title:",
            style: normalWhiteStyle16width700,
          ),
          const SizedBox(width: 4),
          Text(desc,
              style: underline
                  ? normalWhiteStyle.copyWith(
                      color: titleTextColor,
                      decoration: TextDecoration.underline,
                    )
                  : normalWhiteStyle.copyWith(color: titleTextWhiteColor)),
        ],
      ),
    );
  }

  Future<void> _initialization() async {
    AppUser user = await WebService.getCurrentUser();

    setState(() {
      userTypes = user.profile!.userType!.toString();
    });
  }

  Future<void> launchEmailSubmission() async {
    try {
      AppUser user = await WebService.getCurrentUser();
      user.profile!.name.toString();
      final Uri params = Uri(
          scheme: 'mailto',
          path: WebService.emailclient,
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
