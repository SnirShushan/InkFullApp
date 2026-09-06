// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/ui/screen/auth/login.dart';
// import 'package:ink/src/ui/screen/profile/changeUserType/change_user_type.dart';
// import 'package:ink/src/utils/assets.dart';
// import 'package:ink/src/utils/colors.dart';
//
// class WelcomeScreenv2 extends StatefulWidget {
//   final bool isFromChangeUserScreen;
//   const WelcomeScreenv2({Key? key, required this.isFromChangeUserScreen})
//       : super(key: key);
//
//   @override
//   State<WelcomeScreenv2> createState() => _WelcomeScreenv2State();
// }
//
// class _WelcomeScreenv2State extends State<WelcomeScreenv2>
//     with SingleTickerProviderStateMixin {
//   late TabController _controller;
//   int currentPage = 0;
//   bool? isshowing = false;
//   List<OnBoardingModel> onBoardingList = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = TabController(length: 3, vsync: this);
//     onBoardingList = widget.isFromChangeUserScreen
//         ? [
//             OnBoardingModel(
//                 name: 'onboarding.user_to_business_title_1',
//                 subtitle: 'onboarding.user_to_business_subtitle_1',
//                 imgname: AppAssets.onboarding1),
//             OnBoardingModel(
//                 name: 'onboarding.user_to_business_title_2',
//                 subtitle: 'onboarding.user_to_business_subtitle_2',
//                 imgname: AppAssets.onboarding2),
//             OnBoardingModel(
//                 name: 'onboarding.user_to_business_title_3',
//                 subtitle: 'onboarding.user_to_business_subtitle_3',
//                 imgname: AppAssets.onboarding3)
//           ]
//         : [
//             OnBoardingModel(
//                 name: 'onboarding.screen1_title',
//                 subtitle: 'onboarding.screen1_subtitle',
//                 imgname: AppAssets.onboarding1),
//             OnBoardingModel(
//                 name: 'onboarding.screen2_title',
//                 subtitle: 'onboarding.screen2_subtitle',
//                 imgname: AppAssets.onboarding2),
//             OnBoardingModel(
//                 name: 'onboarding.screen3_title',
//                 subtitle: 'onboarding.screen3_subtitle',
//                 imgname: AppAssets.onboarding3)
//           ];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     return Scaffold(
//       body: isshowing == true
//           ? Stack(
//               children: [
//                 Image.asset(AppAssets.onboarding4,
//                     height: double.infinity,
//                     width: double.infinity,
//                     fit: BoxFit.cover),
//                 Positioned(
//                     left: 0,
//                     right: 0,
//                     bottom: size.height * 0.05,
//                     child: Column(
//                       children: [
//                         buildTititleText(title: 'onboarding.screen4_title'),
//                         SizedBox(height: size.height * 0.01),
//                         buildsubTititleText(
//                             subtitle: 'onboarding.screen4_subtitle'),
//                         SizedBox(height: size.height * 0.06),
//                         buildBtnSubmit(
//                             isshowings: true,
//                             ontap: () => Get.offAll(const LoginScreen()),
//                             size: size,
//                             title: 'onboarding.btn_sign_up_free'),
//                         SizedBox(height: size.height * 0.03),
//                         buildTextButton2()
//                       ],
//                     ))
//               ],
//             )
//           : TabBarView(
//               controller: _controller,
//               physics: const NeverScrollableScrollPhysics(),
//               children: onBoardingList
//                   .map((e) => GestureDetector(
//                         onHorizontalDragEnd: (details) {
//                           if (details.primaryVelocity! >=
//                               -details.primaryVelocity!) {
//                             setState(() {
//                               if (currentPage <= 1) {
//                                 currentPage += 1;
//                                 _controller.animateTo(currentPage);
//                               } else {
//                                 if (widget.isFromChangeUserScreen) {
//                                   Get.off(() => const ScreenChangeUserType());
//                                 } else {
//                                   isshowing = true;
//                                   currentPage = 2;
//                                   _controller.animateTo(currentPage);
//                                 }
//                               }
//                             });
//                           }
//                         },
//                         child: Stack(
//                           children: [
//                             Image.asset(e.imgname!,
//                                 height: double.infinity,
//                                 width: double.infinity,
//                                 fit: BoxFit.cover),
//                             Positioned(
//                                 left: 0,
//                                 right: 0,
//                                 bottom: size.height * 0.05,
//                                 child: Column(
//                                   children: [
//                                     buildTititleText(title: e.name!),
//                                     SizedBox(height: size.height * 0.01),
//                                     buildsubTititleText(subtitle: e.subtitle!),
//                                     SizedBox(height: size.height * 0.04),
//                                     buildsliderRow(),
//                                     SizedBox(height: size.height * 0.04),
//                                     buildBtnSubmit(
//                                         ontap: () {
//                                           setState(() {
//                                             if (currentPage <= 1) {
//                                               currentPage += 1;
//                                               _controller
//                                                   .animateTo(currentPage);
//                                             } else {
//                                               if (widget
//                                                   .isFromChangeUserScreen) {
//                                                 Get.off(() =>
//                                                     const ScreenChangeUserType());
//                                               } else {
//                                                 isshowing = true;
//                                                 currentPage = 2;
//                                                 _controller
//                                                     .animateTo(currentPage);
//                                               }
//                                             }
//                                           });
//                                         },
//                                         size: size,
//                                         title: currentPage == 2
//                                             ? "onboarding.btn_lets_go_start"
//                                             : "onboarding.btn_next"),
//                                     SizedBox(height: size.height * 0.02),
//                                     currentPage != 2
//                                         ? buildTextButton(
//                                             title: "onboarding.btn_skip",
//                                             ontaps: () {
//                                               setState(() {
//                                                 currentPage = 2;
//                                                 _controller
//                                                     .animateTo(currentPage);
//                                               });
//                                             })
//                                         : buildTextButton(
//                                             title: "", ontaps: () {})
//                                   ],
//                                 ))
//                           ],
//                         ),
//                       ))
//                   .toList()),
//     );
//   }
//
//   Row buildsliderRow() {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: onBoardingList.asMap().entries.map((entry) {
//         return Container(
//           width: currentPage == entry.key ? 32.0 : 20.0,
//           height: 8.0,
//           margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
//           decoration: BoxDecoration(
//               shape: BoxShape.rectangle,
//               borderRadius: BorderRadius.circular(20),
//               color: (currentPage == entry.key
//                   ? titleTextWhiteColor
//                   : titleTextWhiteColor.withOpacity(0.4))),
//         );
//       }).toList(),
//     );
//   }
//
//   InkWell buildTextButton(
//           {required String title, required Function() ontaps}) =>
//       InkWell(
//           onTap: ontaps,
//           child: Text(
//             title,
//             style: const TextStyle(color: titleTextWhiteColor),
//           ).tr());
//
//   InkWell buildTextButton2() => InkWell(
//       onTap: () => Get.offAll(const LoginScreen()),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             'onboarding.do_u_existing_screen',
//             style: Theme.of(context)
//                 .textTheme
//                 .bodyMedium!
//                 .copyWith(color: titleTextWhiteColor, fontSize: 16),
//           ).tr(),
//           const SizedBox(width: 8),
//           IntrinsicWidth(
//             child: Column(
//               children: [
//                 Text(
//                   'onboarding.connect',
//                   style: Theme.of(context)
//                       .textTheme
//                       .bodyMedium!
//                       .copyWith(color: titleTextWhiteColor, fontSize: 16),
//                 ).tr(),
//                 SizedBox(height: 4),
//                 Container(height: 1, color: titleTextColor),
//               ],
//             ),
//           ),
//         ],
//       ));
//
//   //Title Text
//   InkWell buildBtnSubmit(
//           {required Size size,
//           required String title,
//           required ontap,
//           bool isshowings = false}) =>
//       InkWell(
//         onTap: ontap,
//         child: Container(
//             padding: EdgeInsets.symmetric(
//                 vertical: size.height * 0.015,
//                 horizontal: isshowings ? size.width * 0.3 : size.width * 0.14),
//             decoration: const BoxDecoration(
//               borderRadius: BorderRadius.all(Radius.circular(12)),
//               gradient: LinearGradient(
//                 begin: Alignment.centerRight, // For RTL, start from right
//                 end: Alignment.centerLeft, // For RTL, end at left
//                 colors: [
//                   linearGradieantColor1,
//                   linearGradieantColor2,
//                   linearGradieantColor3,
//                 ],
//                 stops: [0.0, 0.001, 0.8937],
//               ),
//             ),
//             child: Text(
//               currentPage == 2
//                   ? "onboarding.btn_lets_go_start"
//                   : "onboarding.btn_next",
//               style: const TextStyle(color: titleTextWhiteColor),
//             ).tr()),
//       );
//
//   //Title Text
//   Text buildTititleText({required String title}) {
//     return Text(
//       title,
//       textAlign: TextAlign.center,
//       style: Theme.of(context)
//           .textTheme
//           .headlineSmall
//           ?.copyWith(color: titleTextWhiteColor, fontWeight: FontWeight.w700),
//     ).tr();
//   }
//
//   //Sub Title Text
//   Text buildsubTititleText({required String subtitle}) {
//     return Text(
//       subtitle,
//       textAlign: TextAlign.center,
//       style: Theme.of(context)
//           .textTheme
//           .titleSmall
//           ?.copyWith(color: titleTextWhiteColor),
//     ).tr();
//   }
// }
//
// class OnBoardingModel {
//   String? name;
//   String? subtitle;
//   String? imgname;
//
//   OnBoardingModel(
//       {required this.name, required this.subtitle, required this.imgname});
// }
