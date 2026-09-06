// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../auth/login.dart';
// import '../profile/changeUserType/change_user_type.dart';
//
// class WelcomeV1Screen extends StatefulWidget {
//   final bool isFromChangeUserScreen;
//   const WelcomeV1Screen({Key? key, required this.isFromChangeUserScreen})
//       : super(key: key);
//
//   @override
//   State<WelcomeV1Screen> createState() => _WelcomeV1ScreenState();
// }
//
// class _WelcomeV1ScreenState extends State<WelcomeV1Screen>
//     with SingleTickerProviderStateMixin {
//   late TabController _controller;
//   int currentPage = 0;
//   List<String> imgList = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = TabController(length: 3, vsync: this);
//     imgList = widget.isFromChangeUserScreen
//         ? [
//             'assets/images/business_intro/1.png',
//             'assets/images/business_intro/2.png',
//             'assets/images/business_intro/3.png',
//           ]
//         : [
//             'assets/images/first_intro/i1.png',
//             'assets/images/first_intro/i2.png',
//             'assets/images/first_intro/i3.png',
//           ];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         TabBarView(
//             controller: _controller,
//             physics: const NeverScrollableScrollPhysics(),
//             children: imgList
//                 .map((e) => GestureDetector(
//                     onHorizontalDragEnd: (details) {
//                       if (details.primaryVelocity! >=
//                           -details.primaryVelocity!) {
//                         setState(() {
//                           if (currentPage <= 2) {
//                             currentPage += 1;
//                             if (currentPage == 3) {
//                               if (widget.isFromChangeUserScreen) {
//                                 Get.off(() => const ScreenChangeUserType());
//                               } else {
//                                 Get.offAll(() => const LoginScreen());
//                               }
//                             } else {
//                               _controller.animateTo(currentPage);
//                             }
//                           }
//                         });
//                       }
//                     },
//                     child: Image.asset(e,
//                         height: double.infinity,
//                         width: double.infinity,
//                         fit: BoxFit.cover)))
//                 .toList()),
//         Positioned(
//           left: 0,
//           right: 0,
//           bottom: Get.size.height * 0.05,
//           child: Column(
//             children: [
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: imgList.asMap().entries.map((entry) {
//                   return Container(
//                     width: currentPage == entry.key ? 32.0 : 20.0,
//                     height: 8.0,
//                     margin: const EdgeInsets.symmetric(
//                         vertical: 8.0, horizontal: 4.0),
//                     decoration: BoxDecoration(
//                         shape: BoxShape.rectangle,
//                         borderRadius: BorderRadius.circular(20),
//                         color: (currentPage == entry.key
//                             ? Colors.white
//                             : Colors.white.withOpacity(0.6))),
//                   );
//                 }).toList(),
//               ),
//             ],
//           ),
//         )
//       ],
//     );
//   }
// }
