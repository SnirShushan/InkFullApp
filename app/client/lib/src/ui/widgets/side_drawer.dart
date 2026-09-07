// import 'dart:io';
//
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/controller/google_signin_controller.dart';
// import 'package:ink/src/data/source/network/user_api.dart';
// import 'package:ink/src/ui/screen/auth/login.dart';
// import 'package:ink/src/ui/screen/dashboard/dashboard.dart';
// import 'package:ink/src/ui/screen/dashboard/dashboard_binding.dart';
// import 'package:ink/src/ui/screen/profile/contactus/contact_us_backup.dart';
// import 'package:ink/src/ui/screen/profile/settings.dart';
// import 'package:ink/src/ui/screen/profile/subscription/iosubscription/purchase_ios_screen.dart';
// import 'package:ink/src/ui/screen/profile/subscription/purchase_screen.dart';
// import 'package:ink/src/utils/webService.dart';
//
// import '../../controller/dashboard_controller.dart';
// import '../../controller/userController.dart';
// import '../../utils/common.dart';
// import '../screen/business_user/dashboard/business_dashboard_backup.dart';
// import '../screen/business_user/dashboard/bussinessdashboard_binding.dart';
// import '../screen/splash/welcome_screen.dart';
//
// class SideDrawer extends StatefulWidget {
//   const SideDrawer({Key? key}) : super(key: key);
//
//   @override
//   State<SideDrawer> createState() => _SideDrawerState();
// }
//
// class _SideDrawerState extends State<SideDrawer> {
//   final userController = Get.put(UserController());
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Drawer(
//       width: size.width * 0.5,
//       shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(size.width * 0.05),
//               bottomLeft: Radius.circular(size.width * 0.05))),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               margin: EdgeInsets.symmetric(vertical: size.height * 0.02),
//               height: size.height * 0.15,
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(30),
//                   image: const DecorationImage(
//                       image:
//                           AssetImage("assets/images/logo_White background.png"),
//                       fit: BoxFit.contain)),
//             ),
//             // if (userController.userType.value == "2")
//             //   const Divider(thickness: 2),
//             // if (userController.userType.value == "2")
//             //   buildMenuItem(
//             //       size: size,
//             //       imagePath: "assets/icons/ic_pin.png",
//             //       title: "השראות שלי",
//             //       onClick: () {}),
//             // onClick: () => Get.to(const ScreenMyInspirations())),
//             const Divider(thickness: 2),
//
//             buildMenuItem(
//                 size: size,
//                 imagePath: "assets/icons/ic_email.png",
//                 title: "תיבת פניות",
//                 onClick: () {
//                   GetBuilder<DashBoardController>(builder: (controller) {
//                     setState(() {
//                       controller.tabIndex = 1;
//                     });
//                     return Container();
//                   });
//                   if (userController.userType.value == "2") {
//                     Get.offAll(
//                         BusinessDashBoard(
//                           initialIndex: 1,
//                         ),
//                         binding: BusinessDashBoardBinding());
//                   } else {
//                     Get.offAll(
//                         const DashBoard(
//                           initialIndex: 2,
//                         ),
//                         binding: DashBoardBinding());
//                   }
//                 }),
//             userController.userType.value == "1"
//                 ? SizedBox()
//                 : const Divider(thickness: 2),
//             userController.userType.value == "1"
//                 ? SizedBox()
//                 : buildMenuItem(
//                     size: size,
//                     imagePath: "assets/icons/ic_gallary.png",
//                     title: "ההשראות שלי", //my inspiration
//                     onClick: () {
//                       Navigator.pop(context);
//                       // Get.to(const SavedTattooScreen());
//                     }),
//             const Divider(thickness: 2),
//             buildMenuItem(
//                 size: size,
//                 imagePath: "assets/icons/ic_setting.png",
//                 title: "הגדרות",
//                 onClick: () {
//                   Navigator.pop(context);
//                   Get.to(const Settings());
//                 }),
//             const Divider(thickness: 2),
//             buildMenuItem(
//                 size: size,
//                 imagePath: "assets/icons/ic_chat.png",
//                 title: "מידע נוסף",
//                 // title: "צור קשר",
//                 onClick: () {
//                   Navigator.pop(context);
//                   Get.to(ContactUs(userType: userController.userType.value));
//                 }),
//             const Divider(thickness: 2),
//             // Opening a business profile
//             if (userController.userType.value == "1")
//               Padding(
//                   padding: EdgeInsets.symmetric(
//                       vertical: size.height * 0.01,
//                       horizontal: size.width * 0.06),
//                   child: buildButton(
//                       align: Alignment.centerRight,
//                       size: size,
//                       width: size.width * 0.4,
//                       text: "פתיחת פרופיל עסק",
//                       onClick: () {
//                         Navigator.pop(context);
//                         Get.to(() =>
//                             const WelcomeScreen(isFromChangeUserScreen: true));
//                       })),
//             // const ScreenChangeUserType()))), //change user type
//             if (userController.userType.value == "2")
//               Padding(
//                   padding: EdgeInsets.symmetric(
//                       vertical: size.height * 0.01,
//                       horizontal: size.width * 0.06),
//                   child: buildButton(
//                       align: Alignment.centerRight,
//                       size: size,
//                       width: size.width * 0.4,
//                       // text: "אודות",
//                       text: "קדם את העסק",
//                       onClick: () async {
//                         Navigator.pop(context);
//                         if (Platform.isAndroid) {
//                           Get.to(const PurchaseScreen(
//                               sub1Id: 'subscription_basic_5day',
//                               sub2Id: 'subscription_premium_5day',
//                               fromRegistration: false));
//                         } else {
//                           await Network.getCheckSubscription().then((value) {
//                             if (value['status'].toString() == "0" ||
//                                 value['data']['subscription_status']
//                                         .toString() ==
//                                     "0") {
//                               Get.to(const IOSPurchaseScreen(
//                                   purchasename: 'ללא תוכנית קנייה',
//                                   fromRegistration: false));
//                             } else if (value['status'].toString() == "2") {
//                               Network.sessionExpired(
//                                   msg: "alerts.session_expire");
//                             } else {
//                               Get.to(IOSPurchaseScreen(
//                                   fromRegistration: false,
//                                   purchasename:
//                                       value['data']['product_id'].toString()));
//                             }
//                           });
//                         }
//                       })), //change //upgrade plan btn
//             const Divider(thickness: 2),
//             buildMenuItem(
//                 size: size,
//                 imagePath: "assets/icons/ic_arrow_do.png",
//                 title: "התנתק",
//                 onClick: _logout()),
//             const Divider(thickness: 2),
//           ],
//         ),
//       ),
//     );
//   }
//
//   buildMenuItem(
//           {required size,
//           required imagePath,
//           required String title,
//           required onClick}) =>
//       InkWell(
//         onTap: onClick,
//         child: Padding(
//           padding: EdgeInsets.symmetric(
//               vertical: size.height * 0.005, horizontal: size.width * 0.06),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               title == "התנתק"
//                   ? const Icon(Icons.logout)
//                   : Image.asset(imagePath, height: size.width * 0.07),
//               SizedBox(width: size.width * 0.03),
//               Text(title,
//                   textDirection: TextDirection.rtl,
//                   style: Theme.of(context).textTheme.titleMedium)
//             ],
//           ),
//         ),
//       );
//
//   _logout() => () async {
//         final GoogleSignInController googleSignInController =
//             GoogleSignInController();
//         await googleSignInController.signOut();
//         await FirebaseMessaging.instance.deleteToken();
//         await WebService.clearUserData();
//         Get.offAll(LoginScreen());
//       };
// }
