import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:country_picker/country_picker.dart';
import 'package:crypto/crypto.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/google_signin_controller.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/data/source/network/firebase_api.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/ui/screen/auth/registration_screen.dart';
import 'package:ink/src/ui/screen/auth/verification.dart';
import 'package:ink/src/ui/screen/auth/widget/number_formatter_widget.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard_binding.dart';
import 'package:ink/src/ui/screen/profile/select_category.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/generate_otp_digit.dart';
import 'package:ink/src/utils/webService.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../utils/common.dart';
import '../../widgets/unfocus_widget.dart';
import '../business_user/dashboard/business_dashboard.dart';
import '../business_user/dashboard/bussinessdashboard_binding.dart';
import 'OTPBinding.dart';
import 'widget/social_button_widgets.dart';

class LoginScreen extends StatefulWidget {
  final String oldnumber;
  final String strVerificationId;
  final dynamic strResendToken;

  const LoginScreen(
      {Key? key,
      this.oldnumber = "",
      this.strVerificationId = "",
      this.strResendToken = ""})
      : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  TextEditingController phoneController = TextEditingController();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String? strVerificationId;
  bool? isLoading = false;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String? loginvalidation = 'login.phone_number_incorrect';
  bool _hasError1 = false;
  late Animation<double> base;
  late Animation inverted;
  late Animation<Offset> slidAnimation;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.signOut();
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    base = CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    inverted = Tween<double>(begin: 0.0, end: -1.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.linear));

    slidAnimation =
        Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(
            CurvedAnimation(
                parent: animationController, curve: Curves.easeInOut));

    // Repeat the fade animation indefinitely
    // animationController.repeat();

    // Play the slide animation once
    animationController.forward();

    // slideAnimationController = AnimationController(vsync: this, duration: Duration(seconds: 2));

    super.initState();
  }

  final GoogleSignInController googleSignInController =
      GoogleSignInController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return UnFocusWidget(
        child: SafeArea(
            child: Scaffold(
                backgroundColor: const Color(0xFF897975),
                key: scaffoldKey,
                body: Stack(children: [
                  Image.asset(AppAssets.loginBg,
                      width: size.width,
                      height: size.height,
                      fit: BoxFit.cover),
                  Align(
                    alignment: Alignment.bottomCenter,
                    // child: SlideTransition(
                    //   position: slidAnimation,
                    child: Container(
                        height: size.height * 0.56, //size.height * 0.7,
                        decoration: const BoxDecoration(
                            color: bgBlack,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(44), //25
                                topRight: Radius.circular(44))), //25
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              flex: 6,
                              child: Container(
                                width: size.width,
                                padding: EdgeInsets.only(
                                    top: size.height * 0.03,
                                    left: size.width * 0.01,
                                    right: size.height * 0.01),
                                decoration: const BoxDecoration(
                                    color: bgBlack,
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(44),
                                        topLeft: Radius.circular(44))),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Text(
                                          "login.glad_u_r_hear",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall!
                                              .copyWith(
                                                  color: titleTextColor,
                                                  fontWeight: FontWeight.w700),
                                        ).tr(),
                                        SizedBox(height: size.height * 0.015),
                                        Text(
                                          "login.before_u_start",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge!
                                              .copyWith(
                                                  fontSize: 18,
                                                  color: titleTextWhiteColor,
                                                  fontWeight: FontWeight.w400),
                                        ).tr(),
                                        SizedBox(height: size.height * 0.04),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            "login.phone_number",
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall!
                                                .copyWith(
                                                    color: titleTextWhiteColor,
                                                    fontWeight:
                                                        FontWeight.w400),
                                          ).tr(),
                                        ),
                                        SizedBox(height: size.height * 0.01),
                                        buildRow(size: size),
                                        SizedBox(height: size.height * 0.04),
                                        buildBtnSubmit(
                                            context: context, size: size),
                                        SizedBox(height: size.height * 0.03),
                                        buildHorizontalDivider(size, context),
                                        SizedBox(height: size.height * 0.04),
                                        if (Platform.isIOS)
                                          // buildsocialBtnSubmit(
                                          SocialButtonWidgets(
                                              onpressed: () {
                                                if (isLoading == false) {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  checkDeviceToken();
                                                }
                                              },
                                              title: 'Sign in with Apple',
                                              images: AppAssets.appleLogo),
                                        if (Platform.isIOS)
                                          SizedBox(height: size.height * 0.02),
                                        SocialButtonWidgets(
                                            onpressed: () async {
                                              if (isLoading == false) {
                                                FocusScope.of(context)
                                                    .unfocus();
                                                await googleSignInController
                                                    .signInWithGoogle();
                                              }
                                            },
                                            title: 'Sign in with Google',
                                            images: AppAssets.googleLogo),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                    // ),
                  )
                ]))));
  }

  Row buildHorizontalDivider(Size size, BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
            width: size.width * 0.3,
            child: const Divider(thickness: 2, color: dividerGray),
          ),
          Text(
            "login.or_connect_with",
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: dividerGray, fontWeight: FontWeight.w400),
          ).tr(),
          SizedBox(
              width: size.width * 0.3,
              child: const Divider(
                thickness: 2,
                color: dividerGray,
              )),
        ]);
  }

  InkWell buildBtnSubmit({required BuildContext context, required Size size}) =>
      InkWell(
        onTap: phoneController.text.isEmpty
            ? () {
                setState(() {
                  loginvalidation = 'login.phone_number_incorrect';
                });
              }
            : () async {
                if (widget.oldnumber != "") {
                  if (widget.oldnumber == phoneController.text) {
                    Get.to(() => CodeVerification(
                        phoneNumber: phoneController.text,
                        strVerificationId: widget.strVerificationId,
                        strResendToken: widget.strResendToken));
                  } else {
                    await _startLogin();
                  }
                } else {
                  await _startLogin();
                }
              },
        child: Container(
            width: size.width,
            height: size.height * 0.07,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              gradient: appLinearGradient,
            ),
            child: isLoading!
                ? Center(
                    child: RotationTransition(
                        turns: base, child: Image.asset(AppAssets.loadingIcon)),
                  )
                : Text(
                    "login.continue_to_verify_code",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color:
                            phoneController.text.isEmpty ? defaultGrey : kWhite,
                        fontWeight: FontWeight.w700),
                  ).tr()),
      );

  SizedBox buildsocialBtnSubmit(
          {required BuildContext context,
          required Size size,
          required Function() onpressed,
          title,
          images}) =>
      SizedBox(
        width: size.width * 0.9,
        height: size.height * 0.06,
        child: ElevatedButton(
          onPressed: onpressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: socialoginbtn, // Google Red
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // <-- Radius
            ), // Rounded corners
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // Center contents
            children: [
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: titleTextWhiteColor)),
              const SizedBox(width: 8.0),
              // Image.asset(
              //   images,
              //   height: 20.0,
              //   width: 20.0,
              // ),
              SvgPicture.asset(
                images,
                height: 20.0,
                width: 20.0,
              ),
            ],
          ),
        ),
      );

  //login method
  _startLogin() async {
    FocusScope.of(context).unfocus();
    if (loginvalidation == "") {
      if (Platform.isIOS) {
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            isLoading = true;
            _hasError1 = false;
            animationController.repeat();
          });
          Future.delayed(const Duration(milliseconds: 300), () {
            _upSendSMS();
          });
        });
      } else {
        setState(() {
          isLoading = true;
          _hasError1 = false;
          animationController.repeat();
        });
        Future.delayed(const Duration(milliseconds: 300), () {
          _upSendSMS();
        });
      }
    } else {
      _validateInputs();
    }
  }

  void _validateInputs() {
    setState(() {
      _hasError1 = true;
    });
  }

  //build edittext
  buildRow({required size}) => Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                border: Border.all(
                    color: _hasError1 ? errorColor : defaultGrey, width: 2),
                borderRadius: BorderRadius.circular(12),
                color: textEditingColor),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                    child: TextField(
                  style: const TextStyle(color: kWhite),
                  autofocus: false,
                  controller: phoneController,
                  maxLines: 1,
                  enableInteractiveSelection: true,
                  onChanged: (txt) async {
                    final value = txt.replaceAll(RegExp(r'[^0-9]'), '');
                    if (txt.isEmpty) {
                      setState(() {
                        loginvalidation = "login.phone_number_incorrect";
                      });
                      return;
                    }
                    // Block typing country code into the local number field
                    if (WebService.countryCode == "972" &&
                        ['0972', '972'].any(value.startsWith)) {
                      phoneController.value = const TextEditingValue(
                        text: '',
                        selection: TextSelection.collapsed(offset: 0),
                      );
                      setState(() {
                        loginvalidation = "login.phone_number_incorrect";
                      });
                      return;
                    }

                    setState(() {
                      if (value.length != 10) {
                        loginvalidation = "login.phone_number_invalid";
                      } else {
                        loginvalidation = "";
                        _hasError1 = false;
                      }
                    });

                    // Do not assign phoneController.text here — it resets
                    // selection to -1 and breaks further typing on Android.
                    if (value.length == 10 && isLoading != true) {
                      if (widget.oldnumber != "") {
                        if (widget.oldnumber == phoneController.text) {
                          Get.to(() => CodeVerification(
                              phoneNumber: phoneController.text,
                              strVerificationId: widget.strVerificationId,
                              strResendToken: widget.strResendToken));
                        } else {
                          await _startLogin();
                        }
                      } else {
                        await _startLogin();
                      }
                    }
                  },
                  textDirection: ui.TextDirection.ltr,

                  cursorColor: kWhite,

                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                    NumberFormatterWidget()
                  ],
                  textAlign: TextAlign.left,

                  decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorMaxLines: 1,
                      errorText: null,
                      errorStyle: TextStyle(
                        height: 0,
                        color: Colors.transparent,
                        fontSize: 0,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      labelStyle: TextStyle(color: kWhite),
                      hintStyle: TextStyle(color: defaultGrey),
                      hintText: "050-000-0000"),
                  // hintText: "מספר טלפון"),
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) {
                    FocusScope.of(context).unfocus(); // closes the keyboard
                  },
                )),
                InkWell(
                    splashColor: Colors.grey,
                    onTap: () => showCountryPicker(
                          context: context,
                          countryListTheme: CountryListThemeData(
                              bottomSheetHeight:
                                  MediaQuery.of(context).size.height * 0.8,
                              backgroundColor: kBlack,
                              textStyle: const TextStyle(color: kWhite),
                              searchTextStyle: const TextStyle(color: kWhite),
                              inputDecoration: InputDecoration(
                                  // hintText:"txt_search",
                                  hintStyle: const TextStyle(color: kWhite),
                                  fillColor: signInButtonColor,
                                  filled: true,
                                  isDense: true,
                                  border: OutlineInputBorder(
                                      gapPadding: 0.0,
                                      borderRadius:
                                          BorderRadius.circular(10)))),
                          favorite: <String>['IL'],
                          showPhoneCode: true,
                          // optional. Shows phone code before the country name.
                          onSelect: (Country country) {
                            setState(() {
                              WebService.countryCode = country.phoneCode;
                            });
                          },
                        ),
                    child: Text("${WebService.countryCode} +",
                        style: const TextStyle(color: textEditingColor2))),
                SizedBox(width: size.width * 0.03)
              ],
            ),
          ),
          if (_hasError1)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: errorColor),
                  SizedBox(width: size.width * 0.02),
                  Text(loginvalidation!,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                  color: errorColor,
                                  fontWeight: FontWeight.w400))
                      .tr(),
                ],
              ),
            ),
        ],
      );

  //border
  buildBorder() => OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(15));

  //login btn
  loginBtn({required size}) => isLoading!
      ? const Center(child: CircularProgressIndicator())
      : buildButton(
          align: Alignment.center,
          size: size,
          width: size.width * 0.5,
          text: "sign_in.sending_code",
          onClick: _startLogin);

  //check apple token
  checkDeviceToken() {
    WebService.getDeviceToken().then((token) {
      if (token == null) {
        FireBaseApi.getFirebaseToken().then((deviceToken) {
          appleSignIn(deviceToken);
        });
      } else {
        appleSignIn(token);
      }
    });
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  } //sign in with apple

  // apple sign in
  appleSignIn(token) async {
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      final credential = await SignInWithApple.getAppleIDCredential(scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ], nonce: nonce);

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        rawNonce: rawNonce,
      );

      UserCredential? userdata =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      String? email = userdata.user?.email ?? '';
      String? name = credential.givenName ??
          userdata.user?.displayName ??
          userdata.user?.email!.split('@')[0];
      String? idToken = credential.identityToken ?? '';
      String? socialId = userdata.user?.uid ?? '';

      await Network.loginwithapple(name, email, idToken, socialId)
          .then((value) async {
        animationController.stop();
        if (value == true) {
          AppUser currentUser = await WebService.getCurrentUser();

          if (currentUser.stylesList != null &&
              currentUser.stylesList!.isNotEmpty) {
            if (currentUser.profile?.isRegister == "1") {
              WebService.setRegistrationData("false");
              Get.to(RegistrationScreen(
                  isphonenumberLogin: false,
                  nameReg: currentUser.profile!.name.toString() == ""
                      ? name ?? ""
                      : currentUser.profile!.name.toString(),
                  phonenoReg: userdata.user!.phoneNumber.toString(),
                  emailReg: userdata.user!.email.toString()));
            } else {
              if (currentUser.profile!.userType == "2") {
                scaffoldKey.currentState!.setState(() {
                  isLoading = false;
                  Get.offAll(BusinessDashBoard(initialIndex: 0),
                      binding: BusinessDashBoardBinding());
                });
              } else {
                scaffoldKey.currentState!.setState(() {
                  isLoading = false;
                  currentUser.profile!.styles!.isNotEmpty
                      ? Get.offAll(const DashBoard(initialIndex: 0),
                          binding: DashBoardBinding())
                      : Get.offAll(const SelectCategory(
                          fromLogin: true,
                        ));
                });
              }
            }
          } else {
            scaffoldKey.currentState!.setState(() {
              isLoading = false;
            });
          }
        } else {
          displayMessageIcon(
              message: tr("alerts.something_went_wrong"),
              color: errorColor,
              snackposition: SnackPosition.BOTTOM,
              imageData: AppAssets.errorIcon);
        }
      });
    } catch (error) {
      if (error is SignInWithAppleAuthorizationException &&
          error.code == AuthorizationErrorCode.canceled) {
        // Inform the user that sign-in was canceled (optional)
      } else {
        displayMessageIcon(
            message: error.toString(), //Location permissions are denied
            color: errorColor,
            imageData: AppAssets.errorIcon);
      }

      animationController.stop();
      // WebService.printMsg(e.toString());
    }
  }

  Future<void> phoneNumberVerification() async {
    try {
      // FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);
      // FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);

      phoneVerificationCompleted(
          PhoneAuthCredential phoneAuthCredential) async {
        setState(() {
          isLoading = false;
        });
        animationController.stop();
      }

      phoneVerificationFailed(FirebaseAuthException authException) {
        if (mounted) {
          animationController.stop();
        }

        setState(() {
          isLoading = false;
          _hasError1 = true;
        });
        if (authException.code == "invalid-phone-number") {
          loginvalidation = "login.phone_number_incorrect";
          displayMessageIcon(
              message: "alerts.invalid_number",
              color: errorColor,
              imageData: AppAssets.errorIcon);
        } else {
          loginvalidation = authException.code;

          displayMessageIcon(
              message: authException.code,
              color: errorColor,
              imageData: AppAssets.errorIcon);
          // displayMessage('alerts.verification_failed', errorColor);
        }
      }

      phoneCodeSent(String verificationId, [int? forceResendingToken]) {
        animationController.stop();
        setState(() {
          isLoading = false;
          _hasError1 = false;
        });
        displayMessageIcon(
            message: 'login.correct_message',
            color: successGreen,
            imageData: AppAssets.correct_transparentIcon);
        Get.to(
            CodeVerification(
                phoneNumber:
                    '+${WebService.countryCode}${phoneController.text.replaceAll('-', '')}',
                strVerificationId: verificationId,
                strResendToken: forceResendingToken),
            binding: OTPBinding());
      }

      phoneCodeAutoRetrievalTimeout(String verificationId) {
        if (!_isDisposed) {
          animationController.stop();
        }
        isLoading = false;
        strVerificationId = verificationId;
      }

      // WebService.printMsg('+${WebService.countryCode}${phoneController.text.replaceAll('-', '')}');

      await firebaseAuth.verifyPhoneNumber(
        phoneNumber:
            '+${WebService.countryCode}${phoneController.text.replaceAll('-', '')}',
        timeout: const Duration(seconds: 60),
        verificationCompleted: phoneVerificationCompleted,
        verificationFailed: phoneVerificationFailed,
        codeSent: phoneCodeSent,
        codeAutoRetrievalTimeout: phoneCodeAutoRetrievalTimeout,
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      displayMessageIcon(
          message: e.toString(),
          color: errorColor,
          imageData: AppAssets.errorIcon);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    animationController.stop();
    animationController.dispose();
    super.dispose();
  }

  Future<void> _upSendSMS() async {
    try {
      bool isConnected = await WebService.checkConnection();
      if (!isConnected) {
        if (!_isDisposed) {
          animationController.stop();
          setState(() => isLoading = false);
        }
        return;
      }
      var phoneNumbers = phoneController.text.replaceAll('-', '');
      WebService.generateTmpOTP = "";
      String otp;
      if (isTestNumber(phoneNumbers)) {
        otp = generateOtp(phoneNumber: phoneNumbers);

        WebService.generateTmpOTP = await otp;
        Get.to(
            CodeVerification(
              phoneNumber: phoneController.text,
              strVerificationId: "",
              strResendToken: "",
              isUpSendVerification: true,
            ),
            binding: OTPBinding());
      } else {
        otp = generateOtp(phoneNumber: phoneNumbers);
      }

      final value = await Network.checkPhoneExistFetchEmail(phoneNumbers);
      if (value != false) {
        try {
          String email = "";
          if (value.containsKey('email') &&
              value['email'] != null &&
              value['email'].toString().isNotEmpty) {
            if (value['email'].toString() != "" &&
                value['email'].toString() != "null") email = value['email'];
          }

          WebService.generateTmpOTP = await otp;
          // ignore: avoid_print
          print('LOCAL OTP for $phoneNumbers => $otp');
          await Network.fetchOTPApi(
              '${WebService.countryCode}$phoneNumbers', otp, email);

          Get.to(
              CodeVerification(
                phoneNumber: phoneController.text,
                strVerificationId: "",
                strResendToken: "",
                isUpSendVerification: true,
              ),
              binding: OTPBinding());
        } catch (e) {
          if (!isTestNumber(phoneNumbers)) phoneNumberVerification();
        }
      } else {
        if (!_isDisposed) {
          animationController.stop();
          setState(() => isLoading = false);
        }
        displayMessageIcon(
            message: "alerts.something_went_wrong",
            snackposition: SnackPosition.BOTTOM,
            color: errorColor,
            imageData: AppAssets.errorIcon);
      }
    } catch (e) {
      phoneNumberVerification();
      if (!_isDisposed) {
        animationController.stop();
      }
      displayMessageIcon(
          message: e.toString(),
          snackposition: SnackPosition.BOTTOM,
          color: errorColor,
          imageData: AppAssets.errorIcon);
    } finally {
      if (!_isDisposed) {
        animationController.stop();
        setState(() => isLoading = false);
      }
    }
  }
}
