// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/ui/screen/profile/subscription/iosubscription/purchase_ios_screen.dart';
// import 'package:ink/src/ui/widgets/custom_pdf_viewver.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:signature/signature.dart';
//
// import '../../../../utils/colors.dart';
// import '../../../../utils/common.dart';
// import '../../../../utils/webService.dart';
// import '../subscription/purchase_screen.dart';
//
// class SignInTerms extends StatefulWidget {
//   const SignInTerms({Key? key}) : super(key: key);
//
//   @override
//   State<SignInTerms> createState() => _SignInTermsState();
// }
//
// class _SignInTermsState extends State<SignInTerms> {
//   final SignatureController _controller = SignatureController(
//     penStrokeWidth: 5,
//     penColor: defaultAppColor,
//     exportPenColor: defaultAppColor,
//   );
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return WillPopScope(
//         onWillPop: () => exitRegistrationDialog(size, context),
//         child: Scaffold(
//           appBar: buildRegistrationAppbar(
//               isback: true, size: size, title: "הסכם ספקים", context: context),
//           // size: size, title: "פתיחת פרופיל עסקי", context: context),
//           bottomSheet: buildContinueBtn(size: size),
//           body: Column(
//             children: [
//               SizedBox(height: size.height * 0.02),
//               InkWell(
//                   onTap: () => Get.to(() => const CustomPdfViewver(
//                       url: WebService.registerpdf,
//                       // url: WebService.registerpdf,
//                       title: "הסכם בין ספקים")),
//                   child: Padding(
//                     padding: EdgeInsets.all(size.height * 0.02),
//                     child: const Center(
//                         child: Text("חתימה על הסכם ספקים",
//                             // "חתימה על הסכמה לתנאי שימוש",
//                             style: TextStyle(
//                                 decoration: TextDecoration.underline,
//                                 color: Colors.blueAccent))),
//                     // child: Text("תייג את הצוות שלך בפרופיל העסקי")),
//                   )),
//               SizedBox(height: size.height * 0.02),
//               const Center(
//                   child: Text("יש לחתום כאן לאישור ההסכם:",
//                       // "חתימה על הסכמה לתנאי שימוש",
//                       style: TextStyle(color: Colors.black))),
//               SizedBox(height: size.height * 0.02),
//               Signature(
//                 controller: _controller,
//                 width: 300,
//                 height: 300,
//                 backgroundColor: defaultWhite,
//               ),
//               SizedBox(height: size.height * 0.05),
//               buildResetBtn(size: size),
//               SizedBox(height: size.height * 0.05),
//             ],
//           ),
//         ));
//   }
//
//   buildSearchbar({required Size size}) => SizedBox(
//         height: size.height * 0.1,
//         child: Padding(
//           padding: EdgeInsets.symmetric(
//               horizontal: size.width * 0.1, vertical: size.height * 0.02),
//           child: TextFormField(
//             autofocus: false,
//             // textAlign: TextAlign.center,
//             decoration: InputDecoration(
//               contentPadding: const EdgeInsets.all(0.0),
//               filled: true,
//               focusColor: defaultWhite,
//               border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(15),
//                   gapPadding: 0.0,
//                   borderSide: const BorderSide(color: Colors.black)),
//               prefixIcon: const Icon(Icons.search),
//             ),
//           ),
//         ),
//       );
//
//   buildResetBtn({required Size size}) => InkWell(
//         onTap: () => _controller.clear(),
//         child: Container(
//           decoration: BoxDecoration(
//               color: defaultAppColor, borderRadius: BorderRadius.circular(10)),
//           height: size.height * 0.05,
//           width: size.width * 0.2,
//           child: const Center(
//               child: Text("איפוס", style: TextStyle(color: defaultWhite))),
//         ),
//       );
//
//   buildContinueBtn({required Size size}) => SizedBox(
//       height: size.height * 0.1,
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
//         child: Center(
//             child: buildButton(
//                 align: Alignment.centerRight,
//                 size: size,
//                 width: size.width,
//                 // text: "business",
//                 text: "שמור",
//                 onClick: _exportImage)),
//       ));
//
//   _exportImage() async {
//     if (_controller.isEmpty) {
//       displayMessage("alerts.no_sign", Colors.red);
//       return;
//     }
//     var pngBytes = await _controller.toPngBytes();
//
//     if (!(await checkPermission())) await requestPermission();
//
//     Directory? directory = await getTemporaryDirectory();
//     String path = directory.path;
//
//     var directoryName = "signatures";
//
//     await Directory('$path/$directoryName').create(recursive: true);
//
//     File("$path/$directoryName/signature_image.png")
//         .writeAsBytesSync(pngBytes!.buffer.asInt8List());
//
//     WebService.signFile = File("$path/$directoryName/signature_image.png");
//
//     if (await WebService.signFile.exists()) {
//       if (Platform.isAndroid) {
//         Get.to(const PurchaseScreen(fromRegistration: true));
//       } else {
//         Get.to(const IOSPurchaseScreen(
//             purchasename: 'ללא תוכנית קנייה', fromRegistration: true));
//       }
//     } else {
//       print("file not exist");
//     }
//   }
//
//   requestPermission() async {
//     final result = await Permission.storage.request();
//     return result;
//   }
//
//   checkPermission() async {
//     Map<Permission, PermissionStatus> statuses =
//         await [Permission.storage].request();
//
//     return statuses == true;
//   }
// }
