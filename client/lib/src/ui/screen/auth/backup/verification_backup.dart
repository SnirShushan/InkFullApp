// import 'package:easy_localization/easy_localization.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/data/model/currentUser.dart';
// import 'package:ink/src/ui/screen/profile/select_category.dart';
// import 'package:ink/src/utils/colors.dart';
// import 'package:sms_autofill/sms_autofill.dart';
//
// import '../../../data/source/network/user_api.dart';
// import '../../../utils/common.dart';
// import '../../../utils/webService.dart';
// import '../../widgets/login_bg.dart';
// import '../../widgets/unfocus_widget.dart';
// import '../business_user/dashboard/business_dashboard_backup.dart';
// import '../business_user/dashboard/bussinessdashboard_binding.dart';
// import '../dashboard/dashboard.dart';
// import '../dashboard/dashboard_binding.dart';
// import 'otpController.dart';
//
// // class CodeVerification extends StatefulWidget {
// class CodeVerificationBackup extends StatefulWidget {
//   final String phoneNumber;
//   final String strVerificationId;
//   final dynamic strResendToken;
//
//   const CodeVerificationBackup(
//       {Key? key,
//       required this.phoneNumber,
//       required this.strVerificationId,
//       required this.strResendToken})
//       : super(key: key);
//
//   @override
//   State<CodeVerificationBackup> createState() => _CodeVerificationBackupState();
// }
//
// class _CodeVerificationBackupState extends State<CodeVerificationBackup> {
//   FirebaseAuth firebaseAuth = FirebaseAuth.instance;
//
//   final _formKey = GlobalKey<FormState>();
//   bool? isLoading = false;
//   String resendVerificationId = "";
//
//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//
//   final OTPController otpController = OTPController();
//
//   @override
//   void initState() {
//     //sms autofill
//     initAutofill();
//     super.initState();
//   }
//
//   void initAutofill() async {
//     await SmsAutoFill().listenForCode();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return UnFocusWidget(
//         child: Scaffold(
//             key: scaffoldKey,
//             backgroundColor: Colors.black,
//             body: SafeArea(
//                 child: SingleChildScrollView(
//                     child: Column(children: [
//               const LoginBackground(),
//               buildHeading(),
//               body()
//             ])))));
//   }
//
//   Widget buildHeading() => Column(
//         children: [
//           //heading text first
//           Text("כבר מסיימים",
//               style: Theme.of(context)
//                   .textTheme
//                   .headline4!
//                   .copyWith(color: Colors.purple.shade300)),
//           SizedBox(height: Get.size.height * 0.02),
//           Text("שלחנו קוד אימות למספר",
//               style: Theme.of(context)
//                   .textTheme
//                   .titleMedium!
//                   .copyWith(color: Colors.white)),
//           SizedBox(height: Get.size.height * 0.01),
//           Center(
//               child: Text(
//             "${widget.phoneNumber} ${WebService.countryCode}+",
//             style: Theme.of(context)
//                 .textTheme
//                 .titleMedium!
//                 .copyWith(color: Colors.white),
//           )),
//         ],
//       );
//
//   buildBorder() => OutlineInputBorder(
//       borderSide: const BorderSide(color: Colors.white),
//       borderRadius: BorderRadius.circular(50));
//
//   screenBackground({required Size size}) => Container(
//       height: size.height,
//       decoration: BoxDecoration(
//           image: DecorationImage(
//               colorFilter: ColorFilter.mode(
//                   Colors.black.withOpacity(0.5), BlendMode.dstATop),
//               fit: BoxFit.cover,
//               image: const AssetImage("assets/images/bg_login_old.jpg"))));
//
//   verificationBtn({required size, required context}) =>
//       otpController.isLoading.value
//           ? const Center(child: CircularProgressIndicator())
//           : buildButton(
//               align: Alignment.center,
//               size: size,
//               width: size.width * 0.5,
//               text: "code_verification.send_otp",
//               onClick: () => signInWithPhoneNumber(context));
//
//   buildText(String txt, bool isUnderline) => Text(txt,
//           style: Theme.of(context).textTheme.titleMedium!.copyWith(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: Get.size.height * 0.02,
//               decoration:
//                   isUnderline ? TextDecoration.underline : TextDecoration.none))
//       .tr();
//
//   loginBtn() => buildButton(
//       align: Alignment.center,
//       size: Get.size,
//       width: Get.size.width * 0.5,
//       text: "code_verification.send_otp",
//       onClick: () async => await signInWithPhoneNumber(context));
//
//   Widget body() => Container(
//       padding: EdgeInsets.symmetric(horizontal: Get.size.width * 0.05),
//       child: Obx(() => Form(
//             key: _formKey,
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   //otp fields
//                   SizedBox(height: Get.size.height * 0.05),
//                   PinFieldAutoFill(
//                     cursor: Cursor(
//                         width: 2,
//                         height: 25,
//                         color: Colors.purple,
//                         radius: const Radius.circular(10),
//                         enabled: true),
//                     decoration: BoxLooseDecoration(
//                         errorText: otpController.errorMsg.value,
//                         errorTextStyle: const TextStyle(
//                             fontSize: 18,
//                             decorationThickness: 12,
//                             letterSpacing: 2,
//                             height: 0,
//                             leadingDistribution:
//                                 TextLeadingDistribution.proportional),
//                         gapSpace: 10.0,
//                         radius: const Radius.circular(10),
//                         bgColorBuilder: const FixedColorBuilder(Colors.white),
//                         textStyle:
//                             const TextStyle(fontSize: 20, color: Colors.black),
//                         strokeColorBuilder:
//                             const FixedColorBuilder(Colors.white)),
//                     controller: otpController.textEditingController,
//                     currentCode: otpController.textEditingController.text,
//                     onCodeSubmitted: (code) {
//                       FocusScope.of(context).unfocus();
//                     },
//                     onCodeChanged: (code) {
//                       otpController.errorMsg.value = "";
//                       otpController.messageCode.value = code!;
//                       if (code.length == 6) {
//                         FocusScope.of(context).unfocus();
//                         signInWithPhoneNumber(context);
//                       }
//                     },
//                   ),
//
//                   //verification button
//                   SizedBox(height: Get.size.height * 0.02),
//                   otpController.isLoading.value
//                       ? const Center(child: CircularProgressIndicator())
//                       : loginBtn(),
//                   SizedBox(height: Get.size.height * 0.1),
//
//                   //resend code
//                   Center(
//                       child: buildText(
//                           "code_verification.not_received_code", false)),
//                   SizedBox(height: Get.size.height * 0.02),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       InkWell(
//                           onTap: _resendVerificationCode,
//                           child: buildText(
//                               "code_verification.send_new_code", false)),
//                       InkWell(
//                           onTap: () => Get.back(),
//                           child: buildText(
//                               "code_verification.change_number", false)),
//                     ],
//                   ),
//                   SizedBox(height: Get.size.height * 0.02),
//                 ]),
//           )));
//
//   Future _resendVerificationCode() async {
//     try {
//       phoneVerificationCompleted(
//           PhoneAuthCredential phoneAuthCredential) async {
//         /*displayMessage(
//             "Phone number is automatically verified and user signed in: ${firebaseAuth.currentUser?.uid}",
//             Theme.of(context).primaryColor);*/
//       }
//
//       phoneVerificationFailed(FirebaseAuthException authException) {
//         displayMessage('alerts.verification_failed', errorColor);
//         // displayMessage('Phone number verification is failed. Code: ${authException.code}. Message: ${authException.message}',errorColor);
//       }
//
//       phoneCodeSent(String verificationId, [int? forceResendingToken]) async {
//         displayMessage(
//             'הזן את הקוד שקיבלת בהודעה', Theme.of(context).primaryColor);
//       }
//
//       phoneCodeAutoRetrievalTimeout(String verificationId) {
//         resendVerificationId = verificationId;
//       }
//
//       await firebaseAuth.verifyPhoneNumber(
//           phoneNumber:
//               '+${WebService.countryCode}${widget.phoneNumber.replaceAll('-', '')}',
//           timeout: const Duration(seconds: 60),
//           verificationCompleted: phoneVerificationCompleted,
//           verificationFailed: phoneVerificationFailed,
//           codeSent: phoneCodeSent,
//           codeAutoRetrievalTimeout: phoneCodeAutoRetrievalTimeout,
//           forceResendingToken: widget.strResendToken);
//     } catch (e) {
//       displayMessage("alerts.verification_failed", errorColor);
//     }
//   }
//
//   Future signInWithPhoneNumber(BuildContext context) async {
//     try {
//       otpController.isLoading.value = true;
//
//       WebService.printMsg(otpController.messageCode.value.toString());
//       final AuthCredential credential = PhoneAuthProvider.credential(
//         verificationId: widget.strVerificationId,
//         smsCode: otpController.textEditingController.text,
//       );
//
//       User? user;
//       await firebaseAuth.signInWithCredential(credential).then((value) async {
//         user = value.user;
//         if (user != null) {
//           //start login using API
//           await Network.login(widget.phoneNumber.replaceAll('-', ''), user)
//               .then((value) async {
//             otpController.isLoading.value = false;
//             WebService.printMsg(value.toString());
//             //if login success
//             if (value == true) {
//               // displayMessage("נכנס בהצלחה", Theme.of(context).primaryColor);
//               AppUser currentUser = await WebService.getCurrentUser();
//
//               //check user type is user studio/artist or normal user
//               if (currentUser.profile!.userType == "2") {
//                 Get.offAll(BusinessDashBoard(initialIndex: 0,),
//                     binding: BusinessDashBoardBinding());
//               } else {
//                 currentUser.profile!.styles.toString().isNotEmpty
//                     ? Get.offAll(const DashBoard(initialIndex: 3),
//                         binding: DashBoardBinding())
//                     : Get.offAll(SelectCategory(fromProfile: false));
//               }
//             } else {
//               WebService.printMsg("login not successful");
//             }
//           });
//         } else {
//           WebService.printMsg("user is null");
//         }
//       });
//     } on FirebaseAuthException catch (e, stackTrace) {
//       WebService.printMsg("Firebase Error $e");
//       otpController.isLoading.value = false;
//       otpController.update();
//       if (e.code == "invalid-verification-code") {
//         otpController.errorMsg.value = "❌הקוד שהוזן לא תקין";
//       } else {
//         displayMessage(e.message!, Colors.red);
//       }
//     } catch (e) {
//       otpController.isLoading.value = false;
//       otpController.update();
//       WebService.printMsg(e.toString());
//     }
//   }
// }
