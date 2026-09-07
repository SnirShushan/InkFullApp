// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../../utils/common.dart';
// import '../../business_user/dashboard/business_dashboard_backup.dart';
// import '../../business_user/dashboard/bussinessdashboard_binding.dart';
//
// class ScreenSuccess extends StatelessWidget {
//   const ScreenSuccess({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Scaffold(
//       bottomSheet: buildContinueBtn(size: size),
//       body: SizedBox(
//           height: size.height,
//           width: size.width,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               Container(
//                 padding: EdgeInsets.only(bottom: size.height * 0.05),
//                 height: size.width * 0.6,
//                 width: size.width * 0.6,
//                 decoration: const BoxDecoration(
//                     image: DecorationImage(
//                         image: AssetImage("assets/images/bg_thankyou.png"),
//                         fit: BoxFit.fitHeight)),
//               ),
//             ],
//           )),
//     );
//   }
//
//   buildContinueBtn({required Size size}) => SizedBox(
//       height: size.height * 0.1,
//       child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
//           child: Center(
//               child: buildButton(
//                   align: Alignment.centerRight,
//                   size: size,
//                   width: size.width,
//                   // text: "business",
//                   text: "לבית העסק",
//                   onClick: () async {
//                     SharedPreferences prefs =
//                         await SharedPreferences.getInstance();
//                     prefs.setBool("isBusiness", true);
//                     Get.offAll(
//                         BusinessDashBoard(
//                           initialIndex: 0,
//                         ),
//                         binding: BusinessDashBoardBinding());
//                   }))));
// }
