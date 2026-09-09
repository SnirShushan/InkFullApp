import 'dart:ui' as ui;

import 'package:country_picker/country_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/userController.dart';
import 'package:ink/src/ui/screen/auth/login.dart';
import 'package:ink/src/ui/screen/auth/widget/number_formatter_widget.dart';
import 'package:ink/src/ui/widgets/unfocus_widget.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/webService.dart';

import 'widget/custom_registration_textformfield_widget.dart';

class RegistrationScreen extends StatefulWidget {
  final String phonenoReg;
  final String nameReg;
  final bool isphonenumberLogin;
  final String emailReg;

  const RegistrationScreen(
      {super.key,
      required this.phonenoReg,
      required this.nameReg,
      required this.emailReg,
      required this.isphonenumberLogin});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  late Animation<double> base;
  late Animation inverted;
  late Animation<Offset> slidAnimation;
  TextEditingController signController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final userController = Get.put(UserController());
  bool _nameerror = false;
  bool _emailerror = false;
  bool _phoneerror = false;
  bool isvalidate = false;
  bool? isLoading = false;
  bool _readOnlyphone = false;
  bool _readOnlyemail = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = "";
    _emailController.text = "";
    _phoneController.text = "";

    if (widget.isphonenumberLogin) {
      if (widget.phonenoReg != "") {
        _readOnlyphone = true;
        _readOnlyemail = false;
        _phoneController.text = widget.phonenoReg;
      }
    } else {
      if (widget.emailReg != ""&& widget.emailReg.toString() != "null") {
        _readOnlyemail = true;
        _readOnlyphone = false;
        _emailController.text = widget.emailReg;
      }

      if (widget.phonenoReg != "" && widget.phonenoReg.toString() != "null") {
        _readOnlyphone = true;
        _readOnlyemail = false;
        _phoneController.text = widget.phonenoReg;
      }
    }
    if (widget.nameReg != "" && widget.nameReg.toString() != "null") {
      _nameController.text = widget.nameReg;
    }

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
    animationController.repeat();

    // Play the slide animation once
    animationController.forward();

    // slideAnimationController = AnimationController(vsync: this, duration: Duration(seconds: 2));

    super.initState();
  }

  Future<bool> redirectTo() async {
    Get.offAll(() => const LoginScreen());
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return UnFocusWidget(
      child: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) => redirectTo(),
        child: SafeArea(
          child: Scaffold(
            backgroundColor: const Color(0xFF897975),
            key: _scaffoldKey,
            body: Stack(
              clipBehavior: Clip.none,
              children: [
                Stack(
                  children: [
                    Image.asset(
                      AppAssets.loginBg,
                      width: size.width,
                      height: size.height,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: size.height * 0.03,
                      right: 20,
                      child: InkWell(
                        onTap: () => Get.offAll(() => const LoginScreen()),
                        child: SvgPicture.asset(AppAssets.backarrowIcon,
                            color: titleTextColor, width: 24, height: 24),
                      ),
                    ),
                  ],
                ),
                // Align(
                //   alignment: Alignment.bottomCenter,
                //   child: Container(
                //     height: size.height * 0.78, //size.height * 0.7,
                //     decoration: const BoxDecoration(
                //         color: bgBlack,
                //         borderRadius: BorderRadius.only(
                //             topLeft: Radius.circular(44), //25
                //             topRight: Radius.circular(44))),
                //     child: Container(
                //       width: size.width,
                //       padding: EdgeInsets.only(
                //           top: size.height * 0.03,
                //           left: size.width * 0.01,
                //           right: size.height * 0.01),
                //       decoration: const BoxDecoration(
                //           color: bgBlack,
                //           borderRadius: BorderRadius.only(
                //               topRight: Radius.circular(44),
                //               topLeft: Radius.circular(44))),
                //       child: Form(
                //         key: _formKey,
                //         child: Padding(
                //           padding: const EdgeInsets.all(12.0),
                //           child: SingleChildScrollView(
                //             child: Column(
                //               children: [
                //                 Text(
                //                   "registration.registration_title",
                //                   style: Theme.of(context)
                //                       .textTheme
                //                       .titleLarge!
                //                       .copyWith(
                //                           color: titleTextColor,
                //                           fontWeight: FontWeight.w700),
                //                 ).tr(),
                //                 SizedBox(height: size.height * 0.015),
                //                 Text(
                //                   "registration.registration_subtitle",
                //                   textAlign: TextAlign.center,
                //                   style: Theme.of(context)
                //                       .textTheme
                //                       .titleMedium!
                //                       .copyWith(
                //                           color: titleTextWhiteColor,
                //                           fontWeight: FontWeight.w400),
                //                 ).tr(),
                //                 SizedBox(height: size.height * 0.03),
                //                 CustomRegistrationTextForm(
                //                   keyboardType: TextInputType.name,
                //                   title: "registration.full_name",
                //                   errormsg: "registration.full_name_error",
                //                   txtvalidation: (str) {
                //                     if (str == null || str == "") {
                //                       setState(() {
                //                         _nameerror = true;
                //                       });
                //                       return "registration.full_name_error";
                //                     } else {
                //                       setState(() {
                //                         _nameerror = false;
                //                       });
                //                       return null;
                //                     }
                //                   },
                //                   textEditingController: _nameController,
                //                   showError: _nameerror,
                //                   onChanged: (value) {
                //                     // <-- Added this onChanged property
                //                     setState(() {
                //                       _nameerror = _nameController.text.isEmpty;
                //                     });
                //                   },
                //                 ),
                //                 SizedBox(height: size.height * 0.015),
                //                 buildPhonenumber(size: size),
                //                 SizedBox(height: size.height * 0.015),
                //                 CustomRegistrationTextForm(
                //                     keyboardType: TextInputType.emailAddress,
                //                     title: "registration.email_address",
                //                     isreadonly: _readOnlyemail,
                //                     txtvalidation: (str) {
                //                       if (str == null || str == "") {
                //                         setState(() {
                //                           _emailerror = true;
                //                         });
                //
                //                         return "registration.email_address_error";
                //                       } else if (!RegExp(
                //                               r"^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$")
                //                           .hasMatch(str)) {
                //                         setState(() {
                //                           _emailerror = true;
                //                         });
                //                       } else {
                //                         setState(() {
                //                           _emailerror = false;
                //                         });
                //                         return null;
                //                       }
                //                     },
                //                     errormsg:
                //                         "registration.email_address_error",
                //                     textEditingController: _emailController,
                //                     showError: _emailerror),
                //                 SizedBox(height: size.height * 0.03),
                //                 Align(
                //                     alignment: Alignment.centerRight,
                //                     child: buildText(
                //                         context, "registration.terms_1")),
                //                 Row(
                //                   children: [
                //                     InkWell(
                //                       onTap: () => Get.to(() => TermsOfUse()),
                //                       // const CustomPdfViewver(
                //                       //     url: WebService
                //                       //         .termAndConditionUrl,
                //                       //     title: "תנאי השימוש")),
                //                       child: buildTextUnderline(
                //                           context, "registration.terms_2"),
                //                     ),
                //                     buildText(context, "registration.terms_3"),
                //                     InkWell(
                //                       onTap: () => Get.to(() => TermsOfUse()),
                //                       // const CustomPdfViewver(
                //                       //     url: WebService
                //                       //         .termAndConditionUrl,
                //                       //     title: "מדיניות הפרטיות שלנו")),
                //                       child: buildTextUnderline(
                //                           context, "registration.terms_4"),
                //                     ),
                //                   ],
                //                 ),
                //                 SizedBox(height: size.height * 0.04),
                //                 buildBtnSubmit(context: context, size: size),
                //               ],
                //             ),
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // )

                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: size.height * 0.78,
                    decoration: const BoxDecoration(
                      color: bgBlack,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(44),
                        topRight: Radius.circular(44),
                      ),
                    ),
                    child: Container(
                      width: size.width,
                      padding: EdgeInsets.only(
                        top: size.height * 0.03,
                        left: size.width * 0.01,
                        right: size.height * 0.01,
                      ),
                      decoration: const BoxDecoration(
                        color: bgBlack,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(44),
                          topLeft: Radius.circular(44),
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Text(
                                  "registration.registration_title",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(
                                          color: titleTextColor,
                                          fontWeight: FontWeight.w700),
                                ).tr(),
                                SizedBox(height: size.height * 0.015),
                                Text(
                                  "registration.registration_subtitle",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                          color: titleTextWhiteColor,
                                          fontWeight: FontWeight.w400),
                                ).tr(),
                                SizedBox(height: size.height * 0.03),

                                // Updated CustomRegistrationTextForm for Name
                                // CustomRegistrationTextForm(
                                //   keyboardType: TextInputType.name,
                                //   title: "registration.full_name",
                                //   errormsg: "registration.full_name_error",
                                //   // The validation function is optional if handled in `onChanged`
                                //   txtvalidation: (str) {
                                //     if (str == null || str.isEmpty) {
                                //       setState(() {
                                //         _nameerror = true;
                                //       });
                                //       return "registration.full_name_error";
                                //     } else {
                                //       setState(() {
                                //         _nameerror = false;
                                //       });
                                //       return null;
                                //     }
                                //   },
                                //   textEditingController: _nameController,
                                //   showError: _nameerror,
                                //   onChanged: (value) {
                                //     setState(() {
                                //       _nameerror = value.isEmpty;
                                //     });
                                //   },
                                // ),

                                CustomRegistrationTextForm(
                                  keyboardType: TextInputType.name,
                                  title: "registration.full_name",
                                  errormsg: "registration.full_name_error",
                                  txtvalidation: (str) {
                                    if (str == null || str.isEmpty || str==" ") {
                                      return "registration.full_name_error";
                                    }
                                    return null;
                                  },
                                  textEditingController: _nameController,
                                  showError: _nameerror,
                                  onChanged: (value) {
                                    setState(() {
                                      // Update _nameerror based on validation
                                      _nameerror = _nameController.text.toString().trim().isEmpty;
                                    });
                                  },
                                ),

                                SizedBox(height: size.height * 0.015),

                                // Phone number field remains unchanged
                                buildPhonenumber(size: size),

                                SizedBox(height: size.height * 0.015),

                                // Updated CustomRegistrationTextForm for Email
                                CustomRegistrationTextForm(
                                  isreadonly: _readOnlyemail,
                                  keyboardType: TextInputType.emailAddress,
                                  title: "registration.email_address",
                                  errormsg: "registration.email_address_error",
                                  txtvalidation: (str) {
                                    if (str == null || str.isEmpty) {
                                      return "registration.email_address_error";
                                    } else if (!RegExp(
                                            r"^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$")
                                        .hasMatch(str)) {
                                      return "Invalid email address";
                                    }
                                    return null;
                                  },
                                  textEditingController: _emailController,
                                  showError: _emailerror,
                                  onChanged: (value) {
                                    setState(() {
                                      // Update _emailerror based on validation
                                      _emailerror = !RegExp(
                                              r"^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$")
                                          .hasMatch(_emailController.text);
                                    });
                                  },
                                ),

                                SizedBox(height: size.height * 0.03),

                                RichText(
                                  text: TextSpan(text: tr("registration.terms_1")+" " ,style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: const Color(0xFFC0BCC4),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ), children: [
                                    TextSpan(
                                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                          fontSize: 16,
                                          color: const Color(0xFFC0BCC4),
                                          fontWeight: FontWeight.w400,
                                          decoration: TextDecoration.underline),
                                      text: "תנאי השימוש",
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => WebService.openLegalUrl(
                                            WebService.termsOfUseUrl),
                                    ),
                                    TextSpan(text: tr("registration.terms_3")),
                                    TextSpan(
                                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                          fontSize: 16,
                                          color: const Color(0xFFC0BCC4),
                                          fontWeight: FontWeight.w400,
                                          decoration: TextDecoration.underline),
                                      text: " מדיניות הפרטיות",
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => WebService.openLegalUrl(
                                            WebService.privacyPolicyUrl),
                                    ),
                                  ]),
                                ),

                                /*Align(
                                  alignment: Alignment.centerRight,
                                  child: buildText(
                                      context, "registration.terms_1"),
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () =>
                                          Get.to(() => const TermsOfUse(
                                                initialIndex: 0,
                                                isRegistrationScreen: true,
                                              )),
                                      child: buildTextUnderline(
                                        context,
                                        "תנאי השימוש",
                                      ),
                                    ),
                                    Text(tr("registration.terms_3"),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                                fontSize: 16,
                                                color: const Color(0xFFC0BCC4),
                                                fontWeight: FontWeight.w400)),
                                    InkWell(
                                      onTap: () =>
                                          Get.to(() => const TermsOfUse(
                                                initialIndex: 1,
                                                isRegistrationScreen: true,
                                              )),
                                      child: buildTextUnderline(
                                        context,
                                        "מדיניות הפרטיות",
                                      ),
                                    ),
                                  ],
                                ),*/
                                // Row(
                                //   children: [
                                //     InkWell(
                                //       onTap: () =>
                                //           Get.to(() => const TermsOfUse(
                                //                 initialIndex: 1,
                                //                 isRegistrationScreen: true,
                                //               )),
                                //       child: buildTextUnderline(
                                //         context,
                                //         "registration.terms_2",
                                //       ),
                                //     ),
                                //     buildText(context, "registration.terms_3"),
                                //     InkWell(
                                //       onTap: () =>
                                //           Get.to(() => const TermsOfUse(
                                //                 initialIndex: 0,
                                //                 isRegistrationScreen: true,
                                //               )),
                                //       child: buildTextUnderline(
                                //         context,
                                //         "registration.terms_4",
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                SizedBox(height: size.height * 0.04),

                                // Submit Button remains unchanged
                                buildBtnSubmit(context: context, size: size),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Text buildText(BuildContext context, title) {
    return Text(title,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: const Color(0xFFC0BCC4),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            )).tr();
  }

  Text buildTextUnderline(BuildContext context, title) {
    return Text(title,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontSize: 16,
                color: const Color(0xFFC0BCC4),
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.underline))
        .tr();
  }

  Widget buildPhonenumber({required Size size}) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "registration.phone_number",
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: titleTextWhiteColor, fontWeight: FontWeight.w400),
            ).tr(),
          ),
          SizedBox(height: size.height * 0.01),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: _phoneerror ? errorColor : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
              color: socialoginbtn,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: TextFormField(
                    readOnly: _readOnlyphone,
                    textDirection: ui.TextDirection.ltr,
                    style: const TextStyle(color: kWhite),
                    autofocus: false,
                    controller: _phoneController,
                    maxLines: 1,
                    onChanged: (txt) {

                      if (txt.startsWith('0972') || txt.startsWith('972')||txt.startsWith('097-2') || txt.startsWith('97-2')) {
                        // Show error, disable submit, etc.

                        displayMessageIcon(
                            message: "אין צורך להקליד קידומת מדינה 972",
                            color: errorColor,
                            snackposition: SnackPosition.BOTTOM,
                            imageData: AppAssets.errorIcon);

                        _phoneController.text="";
                      }
                      setState(() {
                        // Update the error state based on the input
                        var value = txt.replaceAll(RegExp(r'[^0-9]'), '');
                        _phoneerror = value.length != 10;
                      });
                    },
                    cursorColor: kWhite,
                    keyboardType: TextInputType.phone,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                      NumberFormatterWidget()
                    ],
                    textAlign: TextAlign.left,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (str) {

                      var value = str?.replaceAll(RegExp(r'[^0-9]'), '');
                      if (str == null || str.isEmpty) {
                        _phoneerror = true;

                        return '';
                      } else if (value?.length != 10) {
                        _phoneerror = true;

                        return '';
                      } else if (value!.startsWith('972') ||
                          value.startsWith('0972')||value.startsWith('97-2') ||
                          value.startsWith('097-2')) {
                        return  "אין צורך להקליד קידומת מדינה 972";
                      } else {
                        _phoneerror = false;

                        return null;
                      }
                    },
                    autofillHints: [AutofillHints.telephoneNumber],
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorMaxLines: 1,
                      errorText: '',
                      errorStyle: TextStyle(
                        height: 0,
                        color: Colors.transparent,
                        fontSize: 0,
                      ),
                      labelStyle: TextStyle(color: kWhite),
                      hintStyle: TextStyle(color: defaultGrey),
                      hintText: "050-000-0000",
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                ),
                InkWell(

                  splashColor: Colors.grey,
                  onTap: () => showCountryPicker(
                    context: context,
                    countryListTheme: CountryListThemeData(
                      bottomSheetHeight: Get.size.height * 0.8,
                      backgroundColor: kBlack,
                      textStyle: const TextStyle(color: kWhite),
                      searchTextStyle: const TextStyle(color: kWhite),
                      inputDecoration: InputDecoration(
                        hintStyle: const TextStyle(color: kWhite),
                        fillColor: signInButtonColor,
                        filled: true,
                        isDense: true,
                        border: OutlineInputBorder(
                          gapPadding: 0.0,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    favorite: <String>['IL'],
                    showPhoneCode: true,
                    onSelect: (Country country) {
                      if (_readOnlyphone == false) {
                        setState(() {
                          WebService.countryCode = country.phoneCode;
                        });
                      }
                    },
                  ),
                  child: Text(
                    "${WebService.countryCode} +",
                    style: const TextStyle(color: kWhite),
                  ),
                ),
                SizedBox(width: size.width * 0.03),
              ],
            ),
          ),
          if (_phoneerror)
            Padding(
              padding: const EdgeInsets.only(top: 3.0),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: errorColor),
                  SizedBox(width: size.width * 0.02),
                  Text(
                    "registration.phone_number_error",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: errorColor, fontWeight: FontWeight.w400),
                  ).tr(),
                ],
              ),
            ),
        ],
      );

  // InkWell buildBtnSubmit({required BuildContext context, required Size size}) =>
  //     InkWell(
  //       onTap: () {
  //         if (_formKey.currentState!.validate() &&
  //             _nameerror == false &&
  //             _emailerror == false &&
  //             _phoneerror == false) {
  //           setState(() {
  //             isvalidate = true;
  //             isLoading = true;
  //             animationController.forward();
  //             animationController.repeat();
  //             userController
  //                 .userRegistration(
  //                     name: _nameController.text.trim(),
  //                     phone: _phoneController.text.replaceAll('-', ''),
  //                     email: _emailController.text.trim())
  //                 .then((value) async {
  //               isLoading = false;
  //               setState(() {});
  //             });
  //           });
  //         } else {
  //           setState(() {
  //             isvalidate = false;
  //           });
  //         }
  //       },
  //       child: Container(
  //           width: size.width,
  //           height: size.height * 0.07,
  //           alignment: Alignment.center,
  //           decoration: BoxDecoration(
  //             borderRadius: const BorderRadius.all(Radius.circular(12)),
  //             gradient: LinearGradient(
  //               begin: Alignment.centerRight, // For RTL, start from right
  //               end: Alignment.centerLeft, // For RTL, end at left
  //               colors: _phoneController.text.isNotEmpty &&
  //                       _nameController.text.isNotEmpty &&
  //                       _emailController.text.isNotEmpty
  //                   ? [
  //                       linearGradieantColor1,
  //                       linearGradieantColor2,
  //                       linearGradieantColor3,
  //                     ]
  //                   : [
  //                       lineargrayGradieantColor1,
  //                       lineargrayGradieantColor2,
  //                       lineargrayGradieantColor3,
  //                     ],
  //               stops: [0.0, 0.001, 0.8937],
  //             ),
  //           ),
  //           child: isLoading!
  //               ? Center(
  //                   child: RotationTransition(
  //                       turns: base, child: Image.asset(AppAssets.loadingIcon)),
  //                 )
  //               : Text(
  //                   "registration.registration_button",
  //                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
  //                       color: _phoneController.text.isNotEmpty &&
  //                               _nameController.text.isNotEmpty &&
  //                               _emailController.text.isNotEmpty
  //                           ? kWhite
  //                           : defaultGrey,
  //                       fontWeight: FontWeight.w700),
  //                 ).tr()),
  //     );

  InkWell buildBtnSubmit({required BuildContext context, required Size size}) =>
      InkWell(
        onTap: () {
          // Validate the form and set error states
          final nameError = _nameController.text.toString().trim().isEmpty;
          final emailError = !RegExp(
                  r"^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$")
              .hasMatch(_emailController.text);
          final phoneError =
              _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '').length !=
                  10;

          setState(() {
            _nameerror = nameError;
            _emailerror = emailError;
            _phoneerror = phoneError;
            isvalidate = !nameError && !emailError && !phoneError;
          });

          if (isvalidate) {
            setState(() {
              isLoading = true;
              animationController.forward();
              animationController.repeat();
              userController
                  .userRegistration(
                      name: _nameController.text.trim(),
                      phone: _phoneController.text.replaceAll('-', ''),
                      email: _emailController.text.trim())
                  .then((value) async {
                isLoading = false;
                setState(() {});
              });
            });
          }
        },
        child: Container(
            width: size.width,
            height: size.height * 0.07,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              gradient: LinearGradient(
                begin: Alignment.centerRight, // For RTL, start from right
                end: Alignment.centerLeft, // For RTL, end at left
                colors: _phoneController.text.isNotEmpty &&
                        _nameController.text.isNotEmpty &&
                        _emailController.text.isNotEmpty
                    ? [
                        linearGradieantColor1,
                        linearGradieantColor2,
                        linearGradieantColor3,
                      ]
                    : [
                        lineargrayGradieantColor1,
                        lineargrayGradieantColor2,
                        lineargrayGradieantColor3,
                      ],
                stops: [0.0, 0.001, 0.8937],
              ),
            ),
            child: isLoading!
                ? Center(
                    child: RotationTransition(
                        turns: base, child: Image.asset(AppAssets.loadingIcon)),
                  )
                : Text(
                    "registration.registration_button",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _phoneController.text.isNotEmpty &&
                                _nameController.text.isNotEmpty &&
                                _emailController.text.isNotEmpty
                            ? kWhite
                            : defaultGrey,
                        fontWeight: FontWeight.w700),
                  ).tr()),
      );

  @override
  void dispose() {
    super.dispose();
    animationController.stop();
    animationController.dispose();
  }
}
