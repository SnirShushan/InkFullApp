import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/ui/screen/profile/select_category.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../../data/source/network/user_api.dart';
import '../../../utils/common.dart';
import '../../../utils/webService.dart';
import '../business_user/dashboard/business_dashboard.dart';
import '../business_user/dashboard/bussinessdashboard_binding.dart';
import '../dashboard/dashboard.dart';
import '../dashboard/dashboard_binding.dart';
import 'otpController.dart';

class CodeVerification extends StatefulWidget {
  final String phoneNumber;
  final String strVerificationId;

  const CodeVerification(
      {Key? key, required this.phoneNumber, required this.strVerificationId})
      : super(key: key);

  @override
  State<CodeVerification> createState() => _CodeVerificationState();
}

class _CodeVerificationState extends State<CodeVerification> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  bool? isLoading = false;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final OTPController otpController = OTPController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.black,
      body: Stack(children: [
        screenBackground(size: size),
        Container(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: Form(
            key: _formKey,
            child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      //otp verification heading
                      SizedBox(height: size.height * 0.02),
                      Center(
                          child: Text(
                        "code_verification.txt_verification",
                        style: Theme.of(context)
                            .textTheme
                            .headline5!
                            .copyWith(color: Colors.white),
                      ).tr()),

                      SizedBox(height: size.height * 0.02),
                      Center(
                          child: Text(
                        "code_verification.txt_subtitle",
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2!
                            .copyWith(color: Colors.white),
                      ).tr()),

                      SizedBox(height: size.height * 0.02),
                      Center(
                          child: Text(
                        "${widget.phoneNumber} ${WebService.countryCode}+",
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2!
                            .copyWith(color: Colors.white),
                      )),

                      SizedBox(height: size.height * 0.02),
                      PinFieldAutoFill(
                        decoration: CirclePinDecoration(
                          bgColorBuilder:
                              FixedColorBuilder(Colors.white.withOpacity(0.3)),
                          textStyle: const TextStyle(
                              fontSize: 20, color: Colors.white),
                          strokeColorBuilder:
                              FixedColorBuilder(Colors.white.withOpacity(0.5)),
                        ),
                        controller: otpController.textEditingController,
                        currentCode: otpController.messageCode.value,
                        onCodeSubmitted: (code) {
                          FocusScope.of(context).unfocus();
                          WebService.printMsg("onCodeSubmit");
                          WebService.printMsg(otpController.messageCode.value);
                        },
                        onCodeChanged: (code) {
                          otpController.messageCode.value = code!;
                        },
                      ),
                      SizedBox(height: size.height * 0.02),
                      verificationBtn(size: size, context: context),
                      SizedBox(height: size.height * 0.2),
                    ])),
          ),
        ),
      ]),
    );
  }

  buildBorder() => OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white),
      borderRadius: BorderRadius.circular(50));

  screenBackground({required Size size}) => Container(
      height: size.height,
      decoration: BoxDecoration(
          image: DecorationImage(
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5), BlendMode.dstATop),
              fit: BoxFit.cover,
              image: const AssetImage("assets/images/bg_login.jpg"))));

  verificationBtn({required size, required context}) => isLoading!
      ? const Center(child: CircularProgressIndicator())
      : Center(
          child: InkWell(
          onTap: () async {
            WebService.printMsg("verfy btn click");
            FocusScope.of(context).unfocus();
            if (_formKey.currentState!.validate()) {
              WebService.printMsg("if form valid");
// scaffoldKey.currentState!.setState(() {
//   isLoading = true;
// });
              try {
                WebService.printMsg("widget.strVerificationId");
                WebService.printMsg(widget.strVerificationId);
                WebService.printMsg(otpController.messageCode.value.toString());

                final AuthCredential credential = PhoneAuthProvider.credential(
                  verificationId: widget.strVerificationId,
                  smsCode: otpController.messageCode.value,
                );

                WebService.printMsg(credential.toString());

                final User? user =
                    (await firebaseAuth.signInWithCredential(credential)).user;

                if (user != null) {
                  await Network.login(widget.phoneNumber, user)
                      .then((value) async {
                    scaffoldKey.currentState!.setState(() {
                      isLoading = false;
                    });
                    WebService.printMsg(value.toString());
                    if (value == true) {
                      AppUser currentUser = await WebService.getCurrentUser();
                      if (currentUser.profile!.userType == "2") {
                        Get.offAll(const BusinessDashBoard(initialIndex: 4),
                            binding: BusinessDashBoardBinding());
                      } else {
                        currentUser.profile!.styles.toString().isNotEmpty
                            ? Get.offAll(const DashBoard(initialIndex: 3),
                                binding: DashBoardBinding())
                            : Get.offAll(
                                const SelectCategory(fromProfile: false));
                      }
                    } else {
                      WebService.printMsg("login not successful");
                      displayMessage("alerts.something_went_wrong", Colors.red);
                    }
                  });
                } else {
                  WebService.printMsg("user is null");
                  displayMessage("alerts.something_went_wrong", Colors.red);
                }

                displayMessage("נכנס בהצלחה", Theme.of(context).primaryColor);
              } catch (e) {
                scaffoldKey.currentState!.setState(() {
                  isLoading = false;
                });
                displayMessage("Failed to sign in: " + e.toString(),
                    Theme.of(context).errorColor);
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.8))),
            padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05, vertical: size.height * 0.015),
            child: Text("code_verification.send_otp",
                style: TextStyle(
                  fontSize: size.height * 0.02,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )).tr(),
          ),
        ));

  void signInWithPhoneNumber(BuildContext context) async {
    try {
      WebService.printMsg(otpController.messageCode.value.toString());
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.strVerificationId,
        smsCode: otpController.messageCode.value,
      );

      WebService.printMsg(credential.toString());

      final User? user =
          (await firebaseAuth.signInWithCredential(credential)).user;

      if (user != null) {
        await Network.login(widget.phoneNumber, user).then((value) async {
          scaffoldKey.currentState!.setState(() {
            isLoading = false;
          });
          WebService.printMsg(value.toString());
          if (value == true) {
            AppUser currentUser = await WebService.getCurrentUser();
            if (currentUser.profile!.userType == "2") {
              Get.offAll(const BusinessDashBoard(initialIndex: 4),
                  binding: BusinessDashBoardBinding());
            } else {
              currentUser.profile!.styles.toString().isNotEmpty
                  ? Get.offAll(const DashBoard(initialIndex: 3),
                      binding: DashBoardBinding())
                  : Get.offAll(const SelectCategory(fromProfile: false));
            }
          } else {
            WebService.printMsg("login not successful");
            displayMessage("Somthing went wrong", Colors.red);
          }
        });
      } else {
        WebService.printMsg("user is null");
        displayMessage("alerts.something_went_wrong", Colors.red);
      }

      displayMessage("נכנס בהצלחה", Theme.of(context).primaryColor);
    } catch (e) {
      scaffoldKey.currentState!.setState(() {
        isLoading = false;
      });
      displayMessage(
          "Failed to sign in: " + e.toString(), Theme.of(context).errorColor);
    }
  }
}

/*
  void setUserDetails({context}) async {
    CurrentUser currentUser = await WebService.getCurrentUser();

    if (currentUser.userType == 2) {
      context.setState(() {
        WebService.isArtistOrStudio = true;
      });
      Get.offAll(const BusinessDashBoard(initialIndex: 4),
          binding: BusinessDashBoardBinding());
    } else {
      context.setState(() {
        WebService.isArtistOrStudio = false;
      });
      Get.offAll(const SelectCategory());
    }
  }

  userTypeDialog(size, context) {
    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          titlePadding: const EdgeInsets.all(1.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          actionsAlignment: MainAxisAlignment.center,
          title: Padding(
            padding: EdgeInsets.symmetric(
              vertical: size.height * 0.03,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text("בחר סוג חשבון"),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                  child: const Divider(thickness: 2),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(backgroundColor: defaultBlue),
                      onPressed: () {
                        setUserDetails("business");
                        setState(() {
                          WebService.isArtistOrStudio = true;
                          WebService.printMsg(
                              "isArtistOrStudio buss :${WebService.isArtistOrStudio}");
                        });
                      },
                      // onPressed: () => Navigator.pop(context, 'אל'),
                      child: const Text('משתמש עסק',
                          style: TextStyle(color: Colors.white)),
                      // child: const Text('business user'),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: defaultBlue,
                          side: const BorderSide(color: defaultBlue)),
                      onPressed: () {
                        setUserDetails("user");
                        setState(() {
                          WebService.isArtistOrStudio = false;
                          WebService.printMsg(
                              "isArtistOrStudio${WebService.isArtistOrStudio}");
                        });
                      },
                      child: const Text('משתמש רגיל'),
                      // child: const Text('user'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
* */
