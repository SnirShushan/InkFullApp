// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/ui/widgets/custom_pdf_viewver.dart';
// import 'package:ink/src/utils/common.dart';
// import 'package:ink/src/utils/webService.dart';
//
// import '../../../widgets/unfocus_widget.dart';
// import 'app_details.dart';
// import 'enterDetail.dart';
//
// class ContactUs extends StatelessWidget {
//   final String userType;
//   const ContactUs({Key? key, required this.userType}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return UnFocusWidget(
//         child: Scaffold(
//       appBar: buildappBarwithback(size: size, title: "מידע נוסף"),
//       body: Column(
//         children: [
//           SizedBox(height: size.height * 0.03),
//           buildListTile(
//               size: size,
//               title: "צור קשר",
//               // title: "שליחת פנייה",
//               onClick: () => Get.to(() => const EnterDetails())),
//           const Divider(thickness: 2),
//           buildListTile(
//               size: size,
//               title: "שאלות תשובות",
//               onClick: () => Get.to(() => CustomPdfViewver(
//                   url: userType == "1"
//                       ? WebService.regularQuestionAndAnswers
//                       : WebService.businessQuestionAndAnswers,
//                   title: "שאלות תשובות"))),
//           //WebService.questionAndAnswers
//           const Divider(thickness: 2),
//
//           buildListTile(
//               size: size,
//               title: "תנאי שימוש ופרטיות",
//               onClick: () => Get.to(() => const CustomPdfViewver(
//                   url: WebService.termAndConditionUrl,
//                   title: "תנאי שימוש ופרטיות"))),
//           const Divider(thickness: 2),
//           buildListTile(
//               size: size,
//               title: "אודות",
//               onClick: () => Get.to(const AboutScreen())),
//           const Divider(thickness: 2)
//         ],
//       ),
//     ));
//   }
//
//   buildListTile({required size, required title, required onClick}) => ListTile(
//       onTap: onClick,
//       title: Text(title),
//       trailing: Icon(Icons.arrow_right, size: size.width * 0.08));
// }
