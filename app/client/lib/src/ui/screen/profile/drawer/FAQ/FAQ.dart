import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/ui/screen/profile/drawer/TAC/terme_of_use.dart';
import 'package:ink/src/ui/screen/profile/drawer/contact_us.dart';
import 'package:ink/src/ui/widgets/appbar_back_widget.dart';
import 'package:ink/src/ui/widgets/bottomenu/business_dashboard_bottomenu.dart';
import 'package:ink/src/ui/widgets/bottomenu/dashboard_bottomenu.dart';
import 'package:ink/src/utils/colors.dart';

import 'FAQ_container.dart';
import 'toggle_button.dart';

class FAQ extends StatefulWidget {
  final String currentUserType;

  const FAQ({super.key, required this.currentUserType});

  @override
  _FAQState createState() => _FAQState();
}

class _FAQState extends State<FAQ> with SingleTickerProviderStateMixin {
  bool general = true;
  bool business = false;
  final List<Item> _generalData = [
    Item(headerValue: 'מה קורה אחרי ששלחתי טופס פנייה למקעקע?', expandedValue: [
      'לאחר שליחת טופס הפנייה למקעקע, הוא יקבל התראה לגבי הפניה שלך ויוכל לצפות בה דרך האפליקציה.\n',
      'לאחר שהמקעקע יעבור על הפרטים שמילאת לגבי הקעקוע, הוא ייצור איתך קשר בווטסאפ למסירת פרטים נוספים ולהמשך התהליך.'
    ]),
    Item(
        headerValue: 'אני אוכל לעדכן את הסגנונות האהובים עלי לאחר ההרשמה?',
        expandedValue: [
          'בטח! אפשר לשנות את הסגנונות האהובים עלייך בכל זמן דרך "עריכת סגנונות" במסך הגדרות.'
        ]),
    Item(headerValue: 'איך אפשר ליצור קשר עם שירות הלקוחות?', expandedValue: [
      'בתפריט הפעולות שמופיע בעמוד הפרופיל יש ללחוץ על צור קשר ולשלוח פנייה לשירות הלקוחות של אינק.'
    ]),
    Item(headerValue: 'איפה מופיעים תנאי השימוש באפליקציה?', expandedValue: [
      'בעמוד הפרופיל יש את תנאי השימוש והפרטיות של האפליקציה.'
    ]),
    Item(headerValue: 'איזה התראות אקבל מהאפליקציה?', expandedValue: [
      'התראות על עדכונים של האפליקציה.\n',
      'התראות על פוסטים חדשים שמקעקעים וסטודיואים במעקב העלו.'
    ]),
  ];
  final List<Item> _businessData = [
    Item(
        headerValue: 'מה יקרה לחשבון העסקי שלי אם אחליט לבטל את התשלום למנוי?',
        expandedValue: [
          "החשבון העסקי שלך יישמר ביחד עם כל התמונות והפרטים, אך ללא אפשרויות עריכה והעלאת תכנים חדשים. בנוסף, העמוד העסקי לא יהיה גלוי לשאר משתמשי האפליקציה.\n",
          "לאחר חידוש החבילה העסקית העמוד יחזור להיות גלוי לכל משתמשי האפליקציה ויהיה ניתן לניהול באופן מלא."
        ]),
    Item(
        headerValue: 'מה יקרה לדף הסקיצות שלי אם אעבור מתכנית פרימיום לבסיסית?',
        expandedValue: [
          'הסקיצות שהועלו יישארו שמורות במערכת, אך ללא אפשרות עריכה.\n',
          "עמוד הסקיצות יוסתר משאר משתמשי האפליקציה, כך שבעמוד העסקי יופיעו תמונות ופרטים על העסק."
        ]),
    Item(
        headerValue: 'מה יקרה אם אבטל את המנוי לתכנית העסקית לפני מועד הסיום?',
        expandedValue: [
          'המנוי יישאר פעיל עד לסוף תקופת ההתחייבות ולאחר מכן המנוי לא יחודש אוטומטית.'
        ]),
    Item(
        headerValue:
            'אחת ההטבות בחבילת הפרימיום היא קידום העסק באפליקציה. איך זה עובד?',
        expandedValue: [
          'בחבילת הפרימיום תהנו מ-2 הטבות משמעותיות: ניהול עמוד סקיצות וקידום העסק שלכם באפליקציה. \n',
          'חשבונות הפרימיום מקודמים באפליקציה באופן זהה - כל עסק זוכה לזמן קידום שווה שמחושב באופן אוטומטי כל פרק זמן מוגדר.',
        ]),
    // Item(headerValue: 'איפה מופיעים תנאי השימוש באפליקציה?', expandedValue: [
    //   'פינת הסקיצות מאפשרת לך לנהל אזור בעמוד העסקי בו יופיעו איורים ושרטוטים שכבר יצרת ומוכנים לקעקוע מיידי. \n',
    //   'לקוחות יכולים לבחור קעקוע מתוך הסקיצות הקיימות אצל האמן, מה שחוסך את שלב השרטוט ומאפשר תהליך הרבה יותר מהיר וספונטני.'
    // ]),
    Item(
        headerValue: 'מה ההבדל בין העלאת תמונה לבין העלאת סקיצה?',
        expandedValue: [
          'אזור התמונות מאפשר ללקוחות להתרשם מהעבודות שלכם ולקבל השראה. לכן, במידה ותרצו לשתף בקעקוע חדש שצילמתם, יש להעלות אותו כתמונה.\n',
          'אזור הסקיצות (זמין למנוי פרימיום בלבד) מאפשר ללקוחות שלכם לבחור סקיצה מוכנה ולהתקעקע בה על ידיכם. לכן, אם תרצו להעלות איור או שרטוט של קעקוע, יש להעלות אותו כסקיצה.\n',
          'לחווית שימוש מיטבית באפליקציה יש להקפיד להעלות את התכנים בהתאם.'
        ]),
    Item(headerValue: 'מה קורה אחרי שנשלחה אלי פניה מלקוח?', expandedValue: [
      'לאחר שנשלחה אליך פניה מלקוח, תופיע התראה במסך הפניות (אייקון הפעמון בעמוד הבית). \n',
      'בטופס הפניה יהיה אפשר לצפות בכל הפרטים על הקעקוע המבוקש ואפשרויות יצירת קשר עם הלקוח להמשך התהליך.'
    ]),
    Item(
        headerValue: 'מה יקרה לפרופיל שלי אחרי שאפתח חשבון עסקי?',
        expandedValue: [
          'הפרופיל שלך יישמר כמו שהוא ויתווספו אליו אפשרויות נוספות כחלק מהחשבון העסקי: ניהול עמוד עסקי, העלאת תכנים, קבלת פניות מלקוחות ועוד... \n',
          'גם בתור משתמש עסקי אפשר לשלוח פניות למקעקעים אחרים, לצפות בפוסטים ולשמור אותם לאוספים.'
        ]),
    Item(
        headerValue: 'איזה התראות אקבל מהאפליקציה בתור משתמש עסקי?',
        expandedValue: [
          'התראות על עדכונים של האפליקציה \n',
          'התראות על פניות חדשות שהתקבלו מלקוחות באפליקציה. \n',
          'התראות על פוסטים חדשים שמקעקעים וסטודיואים במעקב העלו.'
        ]),
  ];

  TabController? tabController;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    tabController =
        TabController(length: 2, vsync: this, animationDuration: Duration.zero);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bgBlack,
      bottomNavigationBar: widget.currentUserType == "2"
          ? BusinessDashboardBottomBar(
              currentIndex: 4,
            )
          : DashboardBottomBar(currentIndex: 3),
      appBar: const AppBarBackButtonWidget(
          title: 'שאלות ותשובות',
          titleColor: titleTextWhiteColor,
          iconColor: titleTextWhiteColor),
      body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: tabController,
          children: [
            generalView(),
            businessView(),
          ]),
    );
  }

  generalView() => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ToggleButton(
                      isSelected: true,
                      text: 'כללי',
                      onPressed: () {
                        tabController!.index = 0;
                        tabController!.notifyListeners();
                      }),
                  const SizedBox(width: 5),
                  ToggleButton(
                      isSelected: false,
                      text: 'חשבון עסקי',
                      onPressed: () {
                        tabController!.index = 1;
                        tabController!.notifyListeners();
                      }),
                ],
              ),
              const SizedBox(height: 16),
              FAQContainer(
                  questions: _generalData[0].headerValue,
                  responses: _generalData[0].expandedValue),

              FAQContainer(
                  questions: _generalData[1].headerValue,
                  responses: _generalData[1].expandedValue),

              FAQContainer(
                questions: _generalData[2].headerValue,
                responses: [],
                isRichText: true,
                responseData: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text:
                            'בתפריט הפעולות שמופיע בעמוד הפרופיל יש ללחוץ על ',
                        style: TextStyle(
                          color: Color(0xFFC0BCC4),
                          fontSize: 16,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextSpan(
                        text: 'צור קשר',
                        style: const TextStyle(
                          color: Color(0xFF9792E8),
                          fontSize: 16,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Get.to(() => const Contactus()),
                      ),
                      const TextSpan(
                        text: ' ולשלוח פנייה לשירות הלקוחות של אינק.',
                        style: TextStyle(
                          color: Color(0xFFC0BCC4),
                          fontSize: 16,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.right,
                ),
              ),

              FAQContainer(
                questions: _generalData[3].headerValue,
                responses: [],
                isRichText: true,
                responseData: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'בעמוד הפרופיל יש את ',
                        style: TextStyle(
                          color: Color(0xFFC0BCC4),
                          fontSize: 16,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextSpan(
                        text: 'תנאי השימוש והפרטיות',
                        style: const TextStyle(
                          color: Color(0xFF9792E8),
                          fontSize: 16,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Get.to(() => const TermsOfUse()),
                      ),
                      const TextSpan(
                        text: ' של האפליקציה.',
                        style: TextStyle(
                          color: Color(0xFFC0BCC4),
                          fontSize: 16,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.right,
                ),
              ),

              FAQContainer(
                  questions: _generalData[4].headerValue,
                  responses: [],
                  isRichText: true,
                  responseData: const Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: 4.0), // Add space between items
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'Arimo',
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFFC0BCC4))), // Bullet point
                            Expanded(
                                child: Text(
                              'התראות על עדכונים של האפליקציה',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Arimo',
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFFC0BCC4)),
                            )),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'Arimo',
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFFC0BCC4))), // Bullet point
                            Expanded(
                                child: Text(
                              'התראות על פוסטים חדשים שמקעקעים וסטודיואים במעקב העלו.',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Arimo',
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFFC0BCC4)),
                            )),
                          ],
                        ),
                      ],
                    ),
                  ))
              // ListView.builder(
              //   shrinkWrap: true,
              //   physics: const NeverScrollableScrollPhysics(),
              //   itemCount: _generalData.length,
              //   itemBuilder: (context, index) {
              //     return FAQContainer(
              //         questions: _generalData[index].headerValue,
              //         responses: _generalData[index].expandedValue);
              //   },
              // ),
            ],
          ),
        ),
      );
  businessView() => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ToggleButton(
                      isSelected: false,
                      text: 'כללי',
                      onPressed: () {
                        tabController!.index = 0;
                        tabController!.notifyListeners();
                      }),
                  const SizedBox(width: 5),
                  ToggleButton(
                      isSelected: true,
                      text: 'חשבון עסקי',
                      onPressed: () {
                        tabController!.index = 1;
                        tabController!.notifyListeners();
                      }),
                ],
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _businessData.length,
                itemBuilder: (context, index) {
                  return FAQContainer(
                      questions: _businessData[index].headerValue,
                      responses: _businessData[index].expandedValue);
                },
              ),
            ],
          ),
        ),
      );
}

class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
  });

  List<String> expandedValue;
  String headerValue;
}
