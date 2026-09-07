// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:ink/src/controller/StartupController.dart';
// import 'package:ink/src/controller/post_controller.dart';
// import 'package:ink/src/ui/screen/notification/notifications.dart';
// import 'package:ink/src/ui/widgets/fixed_ad_card.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:webview_flutter/webview_flutter.dart';
//
// import '../../../../controller/bussiness_dashboard_controller.dart';
// import '../../../../utils/colors.dart';
// import '../../../../utils/common.dart';
// import '../../../../utils/lifecycle_handler.dart';
// import '../../../../utils/permissions.dart';
// import '../../../../utils/webService.dart';
// import '../../../widgets/unfocus_widget.dart';
// import '../../bussiness_profiles/screen_bussiness_profiles.dart';
// import '../../home/homescreen.dart';
// import '../../profile/currentUserProfile.dart';
// import '../new_post.dart';
//
// enum ImageFrom { gallery, camera }
//
// class BusinessDashBoard extends StatefulWidget {
//   final int initialIndex;
//
//   const BusinessDashBoard({Key? key, required this.initialIndex})
//       : super(key: key);
//
//   @override
//   State<BusinessDashBoard> createState() => BusinessDashBoardState();
// }
//
// class BusinessDashBoardState extends State<BusinessDashBoard> {
//   bool? init = true;
//   final picker = ImagePicker();
//   bool isFixedAdClosed = false;
//   late final StartupController startupController;
//   final PostController postController = Get.put(PostController());
//   late final WebViewController webController = WebViewController();
//   late final WebViewCookieManager cookieManager = WebViewCookieManager();
//
//   //image details fields
//   late String imageType;
//   late String imageId;
//   late String styles;
//   late String imageDescription;
//   late String studioUid;
//   late String artistUid;
//
//   @override
//   void initState() {
//     super.initState();
//     startupController = Get.put(StartupController());
//     //set is add visible or not
//     setAdClosed();
//     WidgetsBinding.instance.addObserver(LifecycleEventHandler(
//         // detachedCallBack: () async => await WebService.removeAdClosed(),
//         resumeCallBack: () async {
//       WebService.printMsg('resume...');
//     }));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return GetBuilder<BusinessDashBoardController>(builder: (controller) {
//       if (init!) {
//         if (widget.initialIndex != null && widget.initialIndex != 4) {
//           controller.tabIndex = 3;
//         }
//         init = false;
//       }
//
//       return UnFocusWidget(
//           child: Scaffold(
//               body: isFixedAdClosed
//                   ?
//                   //add widget
//                   Obx(() => SafeArea(
//                         child: FixedAdCard(
//                             ad: WebService.startupImgUrl +
//                                 startupController.startup_image.value,
//                             onClose: onAdClose)))
//                   : SafeArea(
//                       child:
//                           IndexedStack(index: controller.tabIndex, children: [
//                       //home screen
//                       const HomeScreen(),
//                       //business profiles
//                       BusinessProfiles(),
//                       //add new post btn
//                       SizedBox(child: InkWell(onTap: () async {
//                         if (startupController
//                                 .subscriptionModel.subscriptionStatus.toString() ==
//                             "1") {
//                           _showCoverOrProfileImgUpload;
//                         } else {
//                           controller.changeTabIndex(2);
//                           if (startupController
//                                   .subscriptionModel.subscriptionStatus.toString() ==
//                               "1") {
//                             _showCoverOrProfileImgUpload;
//                           }
//                         }
//                       })),
//                       //notification
//                       const NotificationScreen(
//                           key: PageStorageKey("notification")),
//                       //profile
//                       Profilescreen(
//                           key: const PageStorageKey("profile"),
//                           isDrawerOpened: WebService.isNotificationBackPressed
//                               ? true
//                               : false),
//                     ])),
//               bottomNavigationBar: BottomNavigationBar(
//                   elevation: 0,
//                   type: BottomNavigationBarType.fixed,
//                   currentIndex: controller.tabIndex,
//                   onTap: controller.changeTabIndex,
//                   showSelectedLabels: true,
//                   showUnselectedLabels: true,
//                   selectedItemColor: defaultWhite,
//                   unselectedItemColor: defaultGrey,
//                   backgroundColor: Colors.black,
//                   items: [
//                     _bottomNavigationBarItem(
//                         size: size,
//                         iconName: "ic_home",
//                         activeIconName: "ic_home_white",
//                         label: 'בית'), //Home
//                     _bottomNavigationBarItem(
//                         size: size,
//                         iconName: "ic_fav",
//                         activeIconName: "ic_fav_white",
//                         label: 'מקעקעים'), //favorites
//                     buildAddIconBtn(controller, size),
//                     _bottomNavigationBarItem(
//                         size: size,
//                         iconName: "ic_notification",
//                         activeIconName: "ic_notification_white",
//                         label: 'התראות'), //notification
//                     _bottomNavigationBarItem(
//                         size: size,
//                         iconName: "ic_user",
//                         activeIconName: "ic_user_white",
//                         label: 'פרופיל')
//                   ])));
//     });
//   }
//
//   _bottomNavigationBarItem(
//       {required size,
//       required String iconName,
//       required String activeIconName,
//       required String label}) {
//     return BottomNavigationBarItem(
//         icon: SizedBox(
//             height: size.width * 0.05,
//             width: iconName == "ic_multi_add"
//                 ? size.width * 0.2
//                 : size.width * 0.05,
//             child: Image.asset('assets/icons/$iconName.png')),
//         label: label,
//         backgroundColor: defaultBlack,
//         activeIcon: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SizedBox(
//                 height: size.width * 0.05,
//                 width: size.width * 0.05,
//                 child: Image.asset('assets/icons/$activeIconName.png')),
//             SizedBox(
//               width: size.width * 0.05,
//               child: const Divider(
//                 thickness: 2,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ));
//   }
//
//   //bottom navigation bar item button
//   buildAddIconBtn(controller, size) => BottomNavigationBarItem(
//       icon: InkWell(
//           onTap: () async {
//             await startupController
//                 .checkSubscription(isAddPost: 1)
//                 .then((value) {
//               if (startupController.subscriptionModel.subscriptionStatus.toString() == "1") {
//                 _showCoverOrProfileImgUpload(context);
//               } else {
//                 controller.changeTabIndex(2);
//               }
//             });
//           },
//           // onTap: () async => await controller.changeTabIndex(2),
//           child: SizedBox(
//               height: size.width * 0.1,
//               width: size.width,
//               child: Image.asset('assets/icons/ic_multi_add.png'))),
//       label: "",
//       backgroundColor: defaultBlack);
//
//   //is tattoo or sketch
//   _showCoverOrProfileImgUpload(BuildContext context) {
//     return showModalBottomSheet<dynamic>(
//         useRootNavigator: true,
//         isScrollControlled: true,
//         context: context,
//         builder: (BuildContext bc) {
//           return Container(
//             decoration: const BoxDecoration(
//                 color: appbarBg,
//                 borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(16),
//                     topRight: Radius.circular(16))),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 //close
//                 InkWell(
//                     onTap: () => Get.back(),
//                     child: Padding(
//                         padding: EdgeInsets.symmetric(
//                             vertical: MediaQuery.of(context).size.height * 0.03,
//                             horizontal:
//                                 MediaQuery.of(context).size.width * 0.4),
//                         child: Container(
//                             margin: EdgeInsetsDirectional.only(
//                                 start: 1.0, end: 1.0),
//                             height: MediaQuery.of(context).size.height * 0.005,
//                             width: MediaQuery.of(context).size.width * 0.2,
//                             color: kDivider))),
//
//                 //sketch
//                 InkWell(
//                   onTap: () async {
//                     imageType = "0";
//                     if (startupController
//                             .subscriptionModel.subscriptionStatus.toString() ==
//                         "1") {
//                       if (startupController.subscriptionModel.isPostLimit
//                               .toString() ==
//                           "1") {
//                         Get.back();
//                         reachedImageLimitDialog(
//                             MediaQuery.of(context).size,
//                             context,
//                             startupController.subscriptionModel.popupText
//                                 .toString());
//
//                         //You have reached the upload post limit
//                       } else {
//                         _showAddPostDialogue(context);
//                       }
//                     } else {
//                       needSubscriptionDialog(context);
//                     }
//                   },
//                   child: Container(
//                     width: double.infinity,
//                     color: Colors.white,
//                     height: MediaQuery.of(context).size.height * 0.1,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Image.asset('assets/icons/ic_gallary.png',
//                             width: Get.width * 0.1),
//                         const SizedBox(width: 8),
//                         Text(" קעקוע",
//                             style: Theme.of(context).textTheme.titleMedium),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 //sketch
//                 InkWell(
//                   onTap: () async {
//                     imageType = "1";
//                     if (startupController
//                                 .subscriptionModel.subscriptionStatus.toString() ==
//                             "1" &&
//                         startupController.subscriptionModel.isPremium.toString() == "1") {
//                       if (startupController.subscriptionModel.isPostLimit
//                               .toString() ==
//                           "1") {
//                         Get.back();
//                         reachedImageLimitDialog(
//                             MediaQuery.of(context).size,
//                             context,
//                             startupController.subscriptionModel.popupText
//                                 .toString());
//
//                         //You have reached the upload post limit
//                       } else {
//                         _showAddPostDialogue(context);
//                       }
//                     } else {
//                       notSubscriptionDialog(context);
//                     }
//                   },
//                   child: SizedBox(
//                     height: MediaQuery.of(context).size.height * 0.1,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Image.asset('assets/icons/ic_edit.png',
//                             width: Get.width * 0.1),
//                         const SizedBox(width: 8),
//                         Text("סקיצה",
//                             style: Theme.of(context).textTheme.titleMedium),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         });
//   }
//
//   //select is from gallery,camera or instagram
//   _showAddPostDialogue(BuildContext context) {
//     Navigator.of(context).pop();
//     return showModalBottomSheet<dynamic>(
//         useRootNavigator: true,
//         isScrollControlled: true,
//         context: context,
//         builder: (BuildContext bc) {
//           return Container(
//             decoration: const BoxDecoration(
//                 color: appbarBg,
//                 borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(16),
//                     topRight: Radius.circular(16))),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 //close
//                 InkWell(
//                   onTap: () => Get.back(),
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(
//                         vertical: MediaQuery.of(context).size.height * 0.03,
//                         horizontal: MediaQuery.of(context).size.width * 0.4),
//                     child: Container(
//                         margin: const EdgeInsetsDirectional.only(
//                             start: 1.0, end: 1.0),
//                         height: MediaQuery.of(context).size.height * 0.005,
//                         width: MediaQuery.of(context).size.width * 0.2,
//                         color: kDivider),
//                   ),
//                 ),
//                 //gallery
//                 InkWell(
//                   onTap: () => _selectImage(context, ImageSource.gallery),
//                   child: Container(
//                     width: double.infinity,
//                     color: Colors.white,
//                     height: MediaQuery.of(context).size.height * 0.1,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Image.asset('assets/icons/ic_gallary.png',
//                             width: Get.width * 0.1),
//                         const SizedBox(width: 8),
//                         Text("העלה תמונה",
//                             style:
//                                 Theme.of(context).textTheme.titleMedium) //קעקוע
//                       ],
//                     ),
//                   ),
//                 ),
//                 //camera
//                 InkWell(
//                   onTap: () async {
//                     PermissionStatus status = await Permission.camera.status;
//                     if (status.isGranted || status.isLimited) {
//                       _selectImage(context, ImageSource.camera);
//                     } else if (status.isDenied) {
//                       await openAppSettings();
//                     } else if (!status.isGranted) {
//                       status = await Permission.camera.request();
//                     }
//                   },
//                   child: SizedBox(
//                     width: double.infinity,
//                     height: MediaQuery.of(context).size.height * 0.1,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         // Image.asset('assets/icons/ic_edit.png'),
//                         Icon(Icons.camera_alt_outlined, size: Get.width * 0.1),
//                         const SizedBox(width: 8),
//                         Text("צלם תמונה",
//                             style:
//                                 Theme.of(context).textTheme.titleMedium) //סקיצה
//                       ],
//                     ),
//                   ),
//                 ),
//                 //from instagram
//                 // InkWell(
//                 //   onTap: () async {
//                 //     await webController.clearCache();
//                 //     await webController.clearLocalStorage();
//                 //     await cookieManager.clearCookies();
//                 //     Get.back();
//                 //     Get.to(() => InstagramMedia(
//                 //         appID: '242427598381818',
//                 //         appSecret: '8e07a584d77f1ca5e18d9b783bc6e7ee',
//                 //         mediaTypes: 0,
//                 //         imageType: imageType));
//                 //   },
//                 //   child: Container(
//                 //     height: MediaQuery.of(context).size.height * 0.1,
//                 //     padding: const EdgeInsets.all(16),
//                 //     color: Colors.white,
//                 //     child: Row(
//                 //       crossAxisAlignment: CrossAxisAlignment.center,
//                 //       mainAxisAlignment: MainAxisAlignment.center,
//                 //       children: [
//                 //         Image.asset("assets/icons/ic_insta.png",
//                 //             width: Get.width * 0.1,
//                 //             height: Get.width * 0.1,
//                 //             color: defaultAppColor),
//                 //         SizedBox(width: 8),
//                 //         Text(
//                 //           "בחר מאינסטגרם",
//                 //           style: TextStyle(color: defaultAppColor),
//                 //         ),
//                 //       ],
//                 //     ),
//                 //   ),
//                 // )
//               ],
//             ),
//           );
//         });
//   }
//
//   _selectImage(context, source) async {
//     if (source == ImageSource.gallery) {
//       if (!(await checkPermission())) await requestPermission();
//     }
//     Navigator.of(context).pop();
//     final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
//     if (pickedFile == null) return;
//     final file = File(pickedFile.path);
//     Get.to(() => SketchImageScreen(pickedFile: file, imageType: imageType));
//   }
//
//   void onAdClose() async {
//     await WebService.setAdClosed();
//     setState(() {
//       isFixedAdClosed = false;
//     });
//   }
//
//   setAdClosed() async {
//     final isAdClosed = await WebService.getAdClosed();
//
//     if (isAdClosed != null) {
//       // final DateTime current = DateTime.now().add(const Duration(hours: 144));
//       final DateTime current = DateTime.now();
//       final DateTime closedDate = DateTime.parse(isAdClosed);
//       final difference = current.difference(closedDate).inDays;
//
//       WebService.printMsg("isAdClosed");
//       WebService.printMsg("closed time : $isAdClosed");
//       WebService.printMsg("current time : ${current.toString()}");
//       WebService.printMsg("difference : ${difference.toString()}");
//
//       if (difference >= 6) {
//         setState(() {
//           isFixedAdClosed = true;
//         });
//       } else {
//         setState(() {
//           isFixedAdClosed = false;
//         });
//       }
//     }
//   }
// }
