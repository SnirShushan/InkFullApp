import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/google_signin_controller.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/ui/screen/auth/login.dart';
import 'package:ink/src/ui/screen/auth/registration_screen.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/business_dashboard.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/bussinessdashboard_binding.dart';
import 'package:ink/src/ui/screen/home/controller/home_screen_controller.dart';
import 'package:ink/src/ui/screen/profile/select_category.dart';
import 'package:ink/src/ui/widgets/unfocus_widget.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/generate_otp_digit.dart';
import 'package:ink/src/utils/shared_preference_helper.dart';
import 'package:ink/src/utils/webService.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../dashboard/dashboard.dart';
import '../dashboard/dashboard_binding.dart';
import 'otpController.dart';
import 'widget/custom_color_builder_widget.dart';

class CodeVerification extends StatefulWidget {
  final String phoneNumber;
  final String strVerificationId;
  dynamic strResendToken;
  bool isUpSendVerification;

  CodeVerification(
      {Key? key,
      required this.phoneNumber,
      required this.strVerificationId,
      this.isUpSendVerification = false,
      required this.strResendToken})
      : super(key: key);

  @override
  State<CodeVerification> createState() => _CodeVerificationState();
}

class _CodeVerificationState extends State<CodeVerification>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> base;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late final OTPController otpController;
  TextEditingController phoneController = TextEditingController();
  bool isLoading = true;
  String resendVerificationId = "";
  final FocusNode _focusNode = FocusNode();
  int currentPosition = 0;
  bool isupSendAuth = false;

  @override
  void initState() {
    super.initState();
    otpController = Get.isRegistered<OTPController>()
        ? Get.find<OTPController>()
        : Get.put(OTPController());
    isupSendAuth = widget.isUpSendVerification;
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    base = CurvedAnimation(parent: animationController, curve: Curves.easeOut);
    initAutofill();
  }

  void initAutofill() async {
    await SmsAutoFill().listenForCode();
    otpController.startTimer();
    // Ensure the pin field can receive keyboard input on emulator/device.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
        child: UnFocusWidget(
            child: Scaffold(
                backgroundColor: const Color(0xFF897975),
                key: scaffoldKey,
                body: Stack(clipBehavior: Clip.none, children: [
                  Stack(
                    children: [
                      Image.asset(AppAssets.loginBg,
                          width: size.width,
                          height: size.height,
                          fit: BoxFit.cover),
                      // if (otpController.isResendEnabled.value)
                      Positioned(
                        top: size.height * 0.03,
                        right: 20,
                        child: InkWell(
                          onTap: () => Get.back(),
                          child: SvgPicture.asset(AppAssets.backarrowIcon,
                              color: titleTextColor, width: 24, height: 24),
                        ),
                      ),
                    ],
                  ),
                  //back btn
                  // if (otpController.isResendEnabled.value)
                  //   Positioned(
                  //       top: size.height * 0.02,
                  //       right: 20,
                  //       child: TextButton.icon(
                  //           onPressed: () => Get.back(),
                  //           label: const Text("חזרה",
                  //               style: TextStyle(color: dividerGray)),
                  //           icon: SvgPicture.asset(AppAssets.backarrowIcon,
                  //               color: titleTextColor,
                  //               width: size.width * 0.05))),
                  //code view
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                          height: size.height * 0.7,
                          width: size.width,
                          padding: EdgeInsets.only(
                              top: size.height * 0.03,
                              left: size.width * 0.01,
                              right: size.height * 0.01),
                          decoration: const BoxDecoration(
                              color: bgBlack,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(44), //30,30
                                  topLeft: Radius.circular(44))),
                          child: Form(
                              key: _formKey,
                              child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: SingleChildScrollView(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                        Text(
                                          "code_verification.txt_title",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge!
                                              .copyWith(
                                                  fontSize: 24,
                                                  color: titleTextColor,
                                                  fontWeight: FontWeight.w700),
                                        ).tr(),
                                        SizedBox(height: size.height * 0.015),
                                        Text(
                                          "code_verification.We_have_sent_code",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                  fontSize: 18,
                                                  color: titleTextWhiteColor,
                                                  fontWeight: FontWeight.w400),
                                        ).tr(),
                                        SizedBox(height: size.height * 0.01),
                                        Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            InkWell(
                                                onTap: () async {
                                                  final GoogleSignInController
                                                      googleSignInController =
                                                      GoogleSignInController();
                                                  await googleSignInController
                                                      .signOut();
                                                  await FirebaseMessaging
                                                      .instance
                                                      .deleteToken();

                                                  await WebService
                                                      .clearUserData();
                                                  Get.offAll(LoginScreen(
                                                      oldnumber:
                                                          widget.phoneNumber,
                                                      strVerificationId: widget
                                                          .strVerificationId,
                                                      strResendToken: widget
                                                          .strResendToken));
                                                },
                                                child: SvgPicture.asset(
                                                  AppAssets.editIcon,
                                                  color: titleTextColor,
                                                  width: size.width * 0.06,
                                                )),
                                            SizedBox(width: size.width * 0.02),
                                            Text(
                                                "${widget.phoneNumber} ${WebService.countryCode} +",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(
                                                        color:
                                                            titleTextWhiteColor,
                                                        fontWeight:
                                                            FontWeight.bold))
                                          ],
                                        ),

                                        SizedBox(height: size.height * 0.03),
                                        Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              "code_verification.enter_verification_code",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall!
                                                  .copyWith(
                                                      color:
                                                          titleTextWhiteColor,
                                                      fontWeight:
                                                          FontWeight.w400),
                                            ).tr()),
                                        SizedBox(height: size.height * 0.01),
                                        // TextFormField(
                                        //     autofocus: false,
                                        //     controller: phoneController,
                                        //     keyboardType: TextInputType.number,
                                        //     decoration: const InputDecoration(
                                        //       border: OutlineInputBorder(
                                        //           borderSide: BorderSide(
                                        //               color: linearGradieantColor3,
                                        //               width: 12)),
                                        //     )),

                                        //otp code
                                        // Keep PinField outside Obx/currentCode sync so timer
                                        // rebuilds and autofill updates don't block typing.
                                        PinFieldAutoFill(
                                          autoFocus: true,
                                          enableInteractiveSelection: true,
                                          focusNode: _focusNode,
                                          keyboardType: TextInputType.number,
                                          cursor: Cursor(
                                              width: 2,
                                              height: 25,
                                              color: Colors.purple,
                                              radius:
                                                  const Radius.circular(10),
                                              enabled: true),
                                          decoration: BoxLooseDecoration(
                                            errorTextStyle: const TextStyle(
                                                fontSize: 18,
                                                decorationThickness: 12,
                                                letterSpacing: 2,
                                                height: 0,
                                                leadingDistribution:
                                                    TextLeadingDistribution
                                                        .proportional),
                                            gapSpace: 10.0,
                                            radius:
                                                const Radius.circular(10),
                                            bgColorBuilder:
                                                const FixedColorBuilder(
                                                    signInButtonColor),
                                            textStyle: const TextStyle(
                                                fontSize: 20,
                                                color: kWhite),
                                            strokeWidth: 2,
                                            strokeColorBuilder:
                                                CustomColorBuilder(
                                                    Colors.transparent,
                                                    Colors.transparent,
                                                    textEditingColor,
                                                    0,
                                                    5),
                                          ),
                                          controller: otpController
                                              .textEditingController,
                                          onCodeSubmitted: (code) {
                                            FocusScope.of(context).unfocus();
                                          },
                                          onCodeChanged: (code) {
                                            final value = code ?? '';
                                            otpController.errorMsg.value = "";
                                            otpController.messageCode.value =
                                                value;

                                            if (value.length == 6) {
                                              FocusScope.of(context).unfocus();
                                              signInWithPhoneNumber(context);
                                            }
                                          },
                                        ),
                                        SizedBox(height: size.height * 0.02),

                                        //error msg
                                        Obx(() => otpController
                                                .errorMsg.isNotEmpty
                                            ? Row(
                                                children: [
                                                  const Icon(
                                                      Icons.error_outline,
                                                      color: errorColor),
                                                  SizedBox(
                                                      width: size.width * 0.02),
                                                  Text(
                                                          'code_verification.code_enter_incorrect',
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .titleMedium!
                                                              .copyWith(
                                                                  color:
                                                                      errorColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400))
                                                      .tr(),
                                                ],
                                              )
                                            : const SizedBox.shrink()),
                                        SizedBox(height: size.height * 0.04),

                                        //verification btn
                                        Obx(() => buildBtnSubmit(
                                            context: context, size: size)),
                                        SizedBox(height: size.height * 0.04),

                                        //resend code
                                        Obx(() {
                                          if (otpController
                                              .isResendEnabled.value) {
                                            return InkWell(
                                              onTap: _resendVerificationCode,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  otpController
                                                          .isResendLoading.value
                                                      ? RotationTransition(
                                                          turns: base,
                                                          child:
                                                              SvgPicture.asset(
                                                            AppAssets
                                                                .refreshIcon,
                                                            color:
                                                                titleTextColor,
                                                          ))
                                                      : SvgPicture.asset(
                                                          AppAssets.refreshIcon,
                                                          color:
                                                              titleTextColor),
                                                  SizedBox(
                                                      width: size.width * 0.02),
                                                  Text(
                                                    'code_verification.send_new_code',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium!
                                                        .copyWith(
                                                          color:
                                                              titleTextWhiteColor,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                  ).tr(),
                                                ],
                                              ),
                                            );
                                          }
                                          return Text(
                                            "שליחת קוד חדש בעוד 00:${otpController.countDownTime.value}",
                                            style: const TextStyle(
                                              color: defaultWhite,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                        }),
                                      ]),
                                  ),
                              ),
                          ),
                      ),
                  ),
                ]),
            ),
        ),
    );
  }

  Widget buildBtnSubmit({required BuildContext context, required Size size}) {
    final canSubmit = otpController.messageCode.value.length == 6;
    return InkWell(
      onTap: canSubmit ? () => signInWithPhoneNumber(context) : null,
      child: Container(
          width: size.width,
          height: size.height * 0.07,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            gradient: appLinearGradient,
          ),
          child: otpController.isLoading.value
              ? Center(
                  child: RotationTransition(
                      turns: base,
                      child: Image.asset(
                        AppAssets.loadingIcon,
                        color: Colors.white,
                      )))
              : Text(
                  "code_verification.verification_btn",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: canSubmit ? Colors.white : defaultGrey,
                      fontWeight: FontWeight.w700),
                ).tr()),
    );
  }

  Future<void> signInWithPhoneNumber(BuildContext context) async {
    final enteredCode = otpController.messageCode.value.trim();
    if (enteredCode.isEmpty || enteredCode.length < 6) {
      return _showError(tr("code_verification.code_enter_incorrect"));
    }
    _startLoading();
    try {
      final phoneNumber = widget.phoneNumber.replaceAll('-', '');

      if (isupSendAuth == true) {
        // 🔐 Manual OTP verification
        if (enteredCode != WebService.generateTmpOTP) {
          _showError("הקוד אינו תקין, אנא נסה שוב.");
          return;
        }
        if (phoneNumber.length != 10) {
          displayMessageIcon(
              message: tr("alerts.something_went_wrong"),
              color: errorColor,
              snackposition: SnackPosition.BOTTOM,
              imageData: AppAssets.errorIcon);
          return;
        }

        await _anonymousLogin();
      } else {
        // Firebase Auth OTP Verification
        final verificationId = resendVerificationId.isNotEmpty
            ? resendVerificationId
            : widget.strVerificationId;

        final credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: enteredCode,
        );

        final userCredential =
            await firebaseAuth.signInWithCredential(credential);
        if (userCredential.user == null) {
          _showError("אימות נכשל");
          return;
        }

        await _firebaseLogin(userCredential.user!);
      }
    } on FirebaseAuthException catch (e) {
      _handleFirebaseError(e);
    } catch (e) {
      _showError(e.toString());
    } finally {
      _stopAnimation();
      otpController.isLoading.value = false;
      otpController.update();
    }
  }

  void _startLoading() {
    otpController.isLoading.value = true;
    animationController.repeat();
  }

  void _stopAnimation() {
    animationController.stop();
  }

  void _showError(String message) {
    otpController.isLoading.value = false;
    otpController.messageCode.value = "";
    otpController.textEditingController.clear();
    otpController.errorMsg.value = message;

    displayMessageIcon(
      message: message,
      color: errorColor,
      imageData: AppAssets.errorIcon,
    );

    _stopAnimation();
  }

  void _handleFirebaseError(FirebaseAuthException e) {
    if (e.code == "invalid-verification-code") {
      _showError("❌הקוד שהוזן לא תקין");
    } else {
      _showError('${tr('login.error_code')}');
    }
  }

  Future<void> _anonymousLogin() async {
    // Local OTP path previously ran Login + signInAnonymously in Future.wait.
    // On emulator, anonymous Firebase auth often fails (App Check / network),
    // which aborted navigation even after a successful Login API response.
    User? firebaseUser;
    try {
      final cred = await FirebaseAuth.instance
          .signInAnonymously()
          .timeout(const Duration(seconds: 12));
      firebaseUser = cred.user;
    } catch (e) {
      debugPrint('Anonymous Firebase sign-in skipped: $e');
    }

    final ok = await Network.login(
      widget.phoneNumber.replaceAll('-', ''),
      firebaseUser,
    );
    if (ok) {
      await _navigatePostLogin();
    } else {
      _showError(tr('login.error_code'));
    }
  }

  Future<void> _firebaseLogin(User user) async {
    await Network.login(widget.phoneNumber.replaceAll('-', ''), user)
        .then((value) => _navigatePostLogin());
  }

  Future<void> _navigatePostLogin() async {
    final appUser = await WebService.getCurrentUser();

    if (appUser.profile?.isRegister == "1") {
      await WebService.setRegistrationData("false");
      Get.to(RegistrationScreen(
        isphonenumberLogin: true,
        nameReg: appUser.profile!.name ?? "",
        phonenoReg: widget.phoneNumber,
        emailReg: "",
      ));
    } else {
      final currentUser = await WebService.getCurrentUser();

      if (currentUser.stylesList != null &&
          currentUser.stylesList!.isNotEmpty) {
        // Drop stale home state from a previous splash/session fetch so
        // dashboard loads fresh GetHomeData with the new login token.
        await SharedPreferencesHelper.clearData();
        WebService.isSplashHomeScreen = true;
        if (Get.isRegistered<HomeScreenController>()) {
          Get.delete<HomeScreenController>(force: true);
        }

        if (currentUser.profile?.userType == "2") {
          final isBusiness = await WebService.getIsBusiness();
          if (isBusiness) {
            Get.offAll(BusinessDashBoard(initialIndex: 0),
                binding: BusinessDashBoardBinding());
          } else {
            displayMessageIcon(
                message: tr("alerts.something_went_wrong"),
                color: errorColor,
                snackposition: SnackPosition.BOTTOM,
                imageData: AppAssets.errorIcon);
          }
        } else if (currentUser.profile?.styles?.isNotEmpty == true &&
            currentUser.profile?.userType == "1") {
          Get.offAll(const DashBoard(initialIndex: 0),
              binding: DashBoardBinding());
        } else if (currentUser.profile?.userType == "1") {
          Get.offAll(const SelectCategory(fromLogin: true));
        } else {
          displayMessageIcon(
              message: tr("alerts.something_went_wrong"),
              color: errorColor,
              snackposition: SnackPosition.BOTTOM,
              imageData: AppAssets.errorIcon);
        }
      } else {
        displayMessageIcon(
            message: tr("alerts.something_went_wrong"),
            color: errorColor,
            snackposition: SnackPosition.BOTTOM,
            imageData: AppAssets.errorIcon);
      }
    }
  }

//resend code
  Future _resendVerificationCode() async {
    otpController.startTimer();
    otpController.isResendLoading.value = false;
    otpController.countDownTime.value = 60;
    otpController.isResendEnabled.value = false;
    animationController.forward().whenComplete(() {
      animationController.repeat();
    });
    try {
      phoneVerificationCompleted(
          PhoneAuthCredential phoneAuthCredential) async {
        otpController.isResendLoading.value = false;

        /*displayMessage(
            "Phone number is automatically verified and user signed in: ${firebaseAuth.currentUser?.uid}",
            Theme.of(context).primaryColor);*/
      }
      phoneVerificationFailed(FirebaseAuthException authException) {
        otpController.isResendLoading.value = false;
        animationController.stop();
        if (authException.code == "invalid-verification-code") {

          displayMessageIcon(
              message: '${tr('login.error_code')}',
              color: errorColor,
              imageData: AppAssets.errorIcon);
          otpController.errorMsg.value = "❌הקוד שהוזן לא תקין";
          _upSendSMS();
        } else {

          displayMessageIcon(
              message: '${tr('login.error_code')}',
              color: errorColor,
              imageData: AppAssets.errorIcon);
          _upSendSMS();
          otpController.errorMsg.value = authException.message!;
        }

      }

      phoneCodeSent(String verificationId, [int? forceResendingToken]) async {
        otpController.isResendLoading.value = false;
        otpController.countDownTime.value = 60;
        otpController.isResendEnabled.value = false;
        otpController.isLoading.value = false;
        otpController.messageCode.value = "";
        otpController.textEditingController.text = "";
        otpController.errorMsg.value = "";
        otpController.startTimer();
        animationController.stop();

        // ✅ Store the new verification ID & resend token
        resendVerificationId = verificationId;
        if (forceResendingToken != null) {
          print ("forceResendingToken -> $forceResendingToken");
          widget.strResendToken = forceResendingToken.toString();
        }else{
          print ("forceResendingToken -> Not Found");
        }
        isupSendAuth = false;

        displayMessageIcon(
            message: 'login.correct_message',
            color: const Color(0xFF2E602E),
            imageData: AppAssets.correct_transparentIcon);
      }
      phoneCodeAutoRetrievalTimeout(String verificationId) {
        otpController.isResendLoading.value = false;
        animationController.stop();
        resendVerificationId = verificationId;
      }

      await firebaseAuth.verifyPhoneNumber(
        phoneNumber:
            '+${WebService.countryCode}${widget.phoneNumber.replaceAll('-', '')}',
        timeout: const Duration(seconds: 60),
        verificationCompleted: phoneVerificationCompleted,
        verificationFailed: phoneVerificationFailed,
        codeSent: phoneCodeSent,
        codeAutoRetrievalTimeout: phoneCodeAutoRetrievalTimeout,
        forceResendingToken:
            widget.strResendToken != null ? widget.strResendToken : null,
      );
    } catch (e,stackTrace) {
      _upSendSMS();

      displayMessageIcon(
          message: "alerts.verification_failed",
          snackposition: SnackPosition.BOTTOM,
          color: errorColor,
          imageData: AppAssets.errorIcon);

    } finally {
      otpController.isResendLoading.value = false;
      animationController.stop();
    }
  }

  Future<void> _upSendSMS() async {
    var phoneNumbers = '${widget.phoneNumber.replaceAll('-', '')}';

    WebService.generateTmpOTP = "";
    String otp = generateOtp(phoneNumber: phoneNumbers);
    Network.checkPhoneExistFetchEmail(phoneNumbers).then((value) async {
      String email = "";

      if (value['email'].toString() != "" &&
          value['email'].toString() != "null") email = value['email'];

      WebService.generateTmpOTP = await otp;
      Network.fetchOTPApi('${WebService.countryCode}$phoneNumbers', otp, email)
          .then((value2) async {
        try {
          final data = value2['res']?['data'];
          final requestId = data?['RequestId'];

          if (requestId != null && requestId.toString().isNotEmpty) {
            isupSendAuth = true;
            otpController.isResendLoading.value = false;
            otpController.countDownTime.value = 60;
            otpController.isResendEnabled.value = false;
            otpController.isLoading.value = false;
            otpController.messageCode.value = "";
            otpController.textEditingController.text = "";
            otpController.errorMsg.value = "";
            otpController.startTimer();
            animationController.stop();
          }
        } catch (e) {}
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    animationController.stop();
  }
}
