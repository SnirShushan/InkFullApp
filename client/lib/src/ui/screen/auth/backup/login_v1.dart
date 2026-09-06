// import 'dart:convert';
// import 'dart:io';
//
// import 'package:country_picker/country_picker.dart';
// import 'package:crypto/crypto.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/controller/google_signin_controller.dart';
// import 'package:ink/src/data/model/currentUser.dart';
// import 'package:ink/src/data/source/network/firebase_api.dart';
// import 'package:ink/src/data/source/network/user_api.dart';
// import 'package:ink/src/ui/screen/auth/verification.dart';
// import 'package:ink/src/ui/screen/dashboard/dashboard.dart';
// import 'package:ink/src/ui/screen/dashboard/dashboard_binding.dart';
// import 'package:ink/src/ui/screen/profile/select_category.dart';
// import 'package:ink/src/utils/assets.dart';
// import 'package:ink/src/utils/colors.dart';
// import 'package:ink/src/utils/webService.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
//
// import '../../../utils/common.dart';
// import '../../widgets/login_bg.dart';
// import '../../widgets/unfocus_widget.dart';
// import '../business_user/dashboard/business_dashboard_backup.dart';
// import '../business_user/dashboard/bussinessdashboard_binding.dart';
// import 'OTPBinding.dart';
//
// class Loginv1Screen extends StatefulWidget {
//   const Loginv1Screen({Key? key}) : super(key: key);
//
//   @override
//   State<Loginv1Screen> createState() => _Loginv1ScreenState();
// }
//
// class _Loginv1ScreenState extends State<Loginv1Screen> {
//   TextEditingController phoneController = TextEditingController();
//   FirebaseAuth firebaseAuth = FirebaseAuth.instance;
//   String? strVerificationId;
//   bool? isLoading = false;
//   final _formKey = GlobalKey<FormState>();
//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//
//   @override
//   void initState() {
//     super.initState();
//     _getPermission();
//   }
//
//   //permission
//   void _getPermission() async {
//     await Permission.location.request().isGranted;
//   }
//
//   final GoogleSignInController googleSignInController =
//       GoogleSignInController();
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return UnFocusWidget(
//         child: Scaffold(
//             key: scaffoldKey,
//             backgroundColor: Colors.black,
//             body: SafeArea(
//                 child: SingleChildScrollView(
//                     child: Column(children: [
//               const LoginBackground(),
//               buildHeading(),
//               body(size: size)
//             ])))));
//   }
//
//   // heading
//   Widget buildHeading() => Column(children: [
//         //heading text first
//         Text("כיף שאתם כאן!",
//             style: Theme.of(context)
//                 .textTheme
//                 .headline4!
//                 .copyWith(color: Colors.purple.shade300)),
//         SizedBox(height: Get.size.height * 0.01),
//         Text("לפני שמתחילים, התחברו לחשבון",
//             style: Theme.of(context)
//                 .textTheme
//                 .titleMedium!
//                 .copyWith(color: Colors.white))
//       ]);
//
//   //login method
//   _startLogin() async {
//     if (_formKey.currentState!.validate()) {
//       FocusScope.of(context).unfocus();
//       setState(() {
//         isLoading = true;
//       });
//       await phoneNumberVerification();
//     }
//   }
//
//   //build edittext
//   buildRow({required size}) => Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           //phone number
//           SizedBox(
//               width: size.width * 0.7,
//               child: TextFormField(
//                 style: const TextStyle(color: Colors.black),
//                 autofocus: false,
//                 controller: phoneController,
//                 keyboardType: TextInputType.number,
//                 inputFormatters: <TextInputFormatter>[
//                   FilteringTextInputFormatter.digitsOnly,
//                   new LengthLimitingTextInputFormatter(10),
//                   new NumberFormatter()
//                 ],
//                 autovalidateMode: AutovalidateMode.onUserInteraction,
//                 validator: (str) {
//                   if (str == null || str == "") {
//                     return "נא להזין מספר טלפון";
//                   }
//                   return null;
//                 },
//                 decoration: InputDecoration(
//                     filled: true,
//                     fillColor: Colors.white,
//                     enabledBorder: buildBorder(),
//                     focusedBorder: buildBorder(),
//                     border: buildBorder(),
//                     errorStyle: const TextStyle(color: Colors.white),
//                     labelStyle: const TextStyle(color: Colors.black),
//                     hintStyle: const TextStyle(color: Colors.black45),
//                     hintText: "050-000-0000"),
//                 // hintText: "מספר טלפון"),
//                 textInputAction: TextInputAction.done,
//               )),
//           //country code
//           TextButton(
//               style: TextButton.styleFrom(
//                 backgroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                     side: BorderSide(color: Colors.white.withOpacity(0.8)),
//                     borderRadius: BorderRadius.circular(15)),
//                 alignment: Alignment.center,
//                 minimumSize: Size(size.width * 0.15, size.height * 0.07),
//               ),
//               onPressed: () => showCountryPicker(
//                     context: context,
//                     countryListTheme: CountryListThemeData(
//                         bottomSheetHeight: Get.size.height * 0.8,
//                         backgroundColor: kWhite,
//                         inputDecoration: InputDecoration(
//                             border: OutlineInputBorder(
//                                 gapPadding: 0.0,
//                                 borderRadius: BorderRadius.circular(20)))),
//                     favorite: <String>['IL'],
//                     showPhoneCode: true,
//                     // optional. Shows phone code before the country name.
//                     onSelect: (Country country) {
//                       setState(() {
//                         WebService.countryCode = country.phoneCode;
//                       });
//                     },
//                   ),
//               child: Text("${WebService.countryCode} +",
//                   style: const TextStyle(color: Colors.black54))),
//         ],
//       );
//
//   //border
//   buildBorder() => OutlineInputBorder(
//       borderSide: BorderSide(color: Colors.purple.shade300),
//       borderRadius: BorderRadius.circular(15));
//
//   //login btn
//   loginBtn({required size}) => isLoading!
//       ? const Center(child: CircularProgressIndicator())
//       : buildButton(
//           align: Alignment.center,
//           size: size,
//           width: size.width * 0.5,
//           text: "sign_in.sending_code",
//           onClick: _startLogin);
//
//   //page body
//   body({required Size size}) => Padding(
//         padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
//         child: Center(
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 //heading text
//                 const Text('sign_in.login_text',
//                         style: TextStyle(color: Colors.white))
//                     .tr(),
//
//                 SizedBox(height: size.height * 0.02),
//
//                 buildRow(size: size),
//
//                 SizedBox(height: size.height * 0.04),
//
//                 //btn login
//                 loginBtn(size: size),
//
//                 SizedBox(height: size.height * 0.02),
//
//                 const Center(
//                     child: Text("או",
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                             color: Colors.white))),
//
//                 if (Platform.isIOS) SizedBox(height: size.height * 0.01),
//
//                 if (Platform.isIOS)
//                   Center(
//                       child: InkWell(
//                     onTap: () => checkDeviceToken(),
//                     child: SizedBox(
//                         width: size.width * 0.6,
//                         child: Image.asset("assets/images/bg_apple_login.png")),
//                   )),
//
//                 SizedBox(height: size.height * 0.05),
//
//                 Center(
//                     child: Material(
//                   color: Colors.transparent,
//                   child: InkWell(
//                     onTap: () async =>
//                         await googleSignInController.signInWithGoogle(),
//                     child: Container(
//                         width: size.width * 0.6,
//                         padding: EdgeInsets.all(size.width * 0.02),
//                         decoration: BoxDecoration(
//                             color: signInButtonColor,
//                             borderRadius: BorderRadius.circular(10.0)),
//                         child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               Text("Sign In with Google",
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .titleMedium!
//                                       .copyWith(color: defaultWhite)),
//                               Image.asset(AppAssets.googleLogo,
//                                   width: size.width * 0.08)
//                             ])),
//                   ),
//                 )),
//
//                 SizedBox(height: size.height * 0.1),
//               ],
//             ),
//           ),
//         ),
//       );
//
//   //check apple token
//   checkDeviceToken() {
//     WebService.getDeviceToken().then((token) {
//       if (token == null) {
//         FireBaseApi.getFirebaseToken().then((deviceToken) {
//           appleSignIn(deviceToken);
//         });
//       } else {
//         appleSignIn(token);
//       }
//     });
//   }
//
//   String sha256ofString(String input) {
//     final bytes = utf8.encode(input);
//     final digest = sha256.convert(bytes);
//     return digest.toString();
//   }
//
//   // apple sign in
//   appleSignIn(token) async {
//     WebService.printMsg(token.toString());
//     try {
//       final rawNonce = generateNonce();
//       final nonce = sha256ofString(rawNonce);
//
//       final credential = await SignInWithApple.getAppleIDCredential(scopes: [
//         AppleIDAuthorizationScopes.email,
//         AppleIDAuthorizationScopes.fullName,
//       ], nonce: nonce);
//
//       final oauthCredential = OAuthProvider("apple.com").credential(
//         idToken: credential.identityToken,
//         rawNonce: rawNonce,
//       );
//
//       WebService.printMsg("oauthCredential $oauthCredential");
//
//       UserCredential? userdata =
//           await FirebaseAuth.instance.signInWithCredential(oauthCredential);
//
//       String? email = userdata.user?.email != null ? userdata.user?.email : '';
//       String? name =
//           userdata.user?.displayName != null ? userdata.user?.displayName : '';
//       String? idToken =
//           credential.identityToken != null ? credential.identityToken : '';
//       String? socialId = userdata.user?.uid != null ? userdata.user?.uid : '';
//
//       await Network.loginwithapple(name, email, idToken, socialId)
//           .then((value) async {
//         if (value == true) {
//           AppUser currentUser = await WebService.getCurrentUser();
//           if (currentUser.profile!.userType == "2") {
//             scaffoldKey.currentState!.setState(() {
//               isLoading = false;
//               Get.offAll(BusinessDashBoard(initialIndex: 0,),
//                   binding: BusinessDashBoardBinding());
//             });
//           } else {
//             scaffoldKey.currentState!.setState(() {
//               isLoading = false;
//               currentUser.profile!.styles!.isNotEmpty
//                   ? Get.offAll(const DashBoard(initialIndex: 3),
//                       binding: DashBoardBinding())
//                   : Get.offAll(SelectCategory(fromProfile: false));
//             });
//           }
//         } else {
//           scaffoldKey.currentState!.setState(() {
//             isLoading = false;
//           });
//         }
//       });
//     } catch (e) {
//       WebService.printMsg(e.toString());
//     }
//   }
//
//   //start verification
//   Future<void> phoneNumberVerification() async {
//     try {
//       phoneVerificationCompleted(
//           PhoneAuthCredential phoneAuthCredential) async {
//         setState(() {
//           isLoading = false;
//         });
//       }
//
//       phoneVerificationFailed(FirebaseAuthException authException) {
//         setState(() {
//           isLoading = false;
//         });
//         if (authException.code == "invalid-phone-number") {
//           displayMessage("alerts.invalid_number", Colors.red);
//         } else {
//           print("exception$authException");
//           displayMessage("$authException", errorColor);
//           // displayMessage('alerts.verification_failed', errorColor);
//         }
//       }
//
//       phoneCodeSent(String verificationId, [int? forceResendingToken]) {
//         setState(() {
//           isLoading = false;
//         });
//         displayMessage(
//             'הזן את הקוד שקיבלת בהודעה', Theme.of(context).primaryColor);
//         Get.to(
//             CodeVerification(
//                 phoneNumber: phoneController.text,
//                 strVerificationId: verificationId,
//                 strResendToken: forceResendingToken),
//             binding: OTPBinding());
//       }
//
//       phoneCodeAutoRetrievalTimeout(String verificationId) {
//         setState(() {
//           isLoading = false;
//         });
//         strVerificationId = verificationId;
//       }
//
//       // WebService.printMsg('+${WebService.countryCode}${phoneController.text.replaceAll('-', '')}');
//
//       await firebaseAuth.verifyPhoneNumber(
//         phoneNumber:
//             '+${WebService.countryCode}${phoneController.text.replaceAll('-', '')}',
//         timeout: const Duration(seconds: 120),
//         verificationCompleted: phoneVerificationCompleted,
//         verificationFailed: phoneVerificationFailed,
//         codeSent: phoneCodeSent,
//         codeAutoRetrievalTimeout: phoneCodeAutoRetrievalTimeout,
//       );
//     } catch (e) {
//       print("exception e$e");
//       setState(() {
//         isLoading = false;
//       });
//       displayMessage("alerts.verification_failed", errorColor);
//     }
//   }
// }
//
// //Custom InputFormatter
// class NumberFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue, TextEditingValue newValue) {
//     var text = newValue.text;
//
//     if (newValue.selection.baseOffset == 0) {
//       return newValue;
//     }
//
//     var buffer = new StringBuffer();
//     for (int i = 0; i < text.length; i++) {
//       buffer.write(text[i]);
//       var nonZeroIndex = i + 1;
//       if (nonZeroIndex <= 6) {
//         if (nonZeroIndex % 3 == 0 && nonZeroIndex != text.length) {
//           buffer.write('-'); // Add double spaces.
//         }
//       } else {
//         if (nonZeroIndex % 12 == 0 && nonZeroIndex != text.length) {
//           buffer.write('-'); // Add double spaces.
//         }
//       }
//     }
//
//     var string = buffer.toString();
//     return newValue.copyWith(
//         text: string,
//         selection: new TextSelection.collapsed(offset: string.length));
//   }
// }
