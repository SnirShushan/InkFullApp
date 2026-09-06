import 'dart:io';
import 'dart:ui' as ui;

import 'package:country_picker/country_picker.dart';
import 'package:easy_localization/easy_localization.dart' as localization;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/ui/screen/profile/drawer/controller/business_profile_menu_controller.dart';
import 'package:ink/src/ui/widgets/unfocus_widget.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';

import '../../../../controller/userController.dart';
import '../../../../utils/common.dart';
import '../../../../utils/utils_styles.dart';
import '../../../../utils/webService.dart';
import '../../../widgets/appbar_back_widget.dart';
import '../../../widgets/button/app_button.dart';
import '../../auth/widget/number_formatter_widget.dart';

class EditingDetails extends StatefulWidget {
  final BusinessProfileMenuController businessProfileMenuController;

  const EditingDetails({Key? key, required this.businessProfileMenuController})
      : super(key: key);

  @override
  State<EditingDetails> createState() => _EditingDetails();
}

class _EditingDetails extends State<EditingDetails>
    with SingleTickerProviderStateMixin {
  bool isStudio = false;
  bool isArtist = false;

  late final AppUser user;
  bool isAddressEmpty = true;

  // final ChangeUserTypeController changeUserTypeController =
  //     Get.put(ChangeUserTypeController());
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final ScrollController scrollController = ScrollController();

  final hintStyle = const TextStyle(color: hintTextColor);
  final userController = Get.put(UserController());
  late AnimationController animationController;
  late Animation<double> base;

  String? loginvalidation = 'login.phone_number_incorrect';
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    widget.businessProfileMenuController.initPackageInfo();
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 10));
    base = CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    // widget.businessProfileMenuController.emailController.value.text =
    //     userController.email.value.toString();
    widget.businessProfileMenuController.phoneController.value.text =
        _formatPhoneNumber(widget.businessProfileMenuController.phoneno.value);

    // widget.businessProfileMenuController.nameController.value.text =
    //     userController.name.value.toString();
    widget.businessProfileMenuController.userphoneError.value = false;
    widget.businessProfileMenuController.usernameeEror.value = false;
    widget.businessProfileMenuController.userEmailError.value = false;
    super.initState();
  }

  String _formatPhoneNumber(String phoneNumber) {
    if (!phoneNumber.isNotEmpty || phoneNumber.length != 10) {
      return '';
    }

    return '${phoneNumber.substring(0, 3)}-${phoneNumber.substring(3, 6)}-${phoneNumber.substring(6)}';
  }

  @override
  void dispose() {
    animationController.stop();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return UnFocusWidget(

      child: Scaffold(
          key: scaffoldKey,
          backgroundColor: bgBlack,
          resizeToAvoidBottomInset: true,
          appBar: const AppBarBackButtonWidget(
              title: "עריכת פרטים",
              titleColor: titleTextWhiteColor,
              iconColor: titleTextWhiteColor),
          bottomSheet: keyboardOpen
              ? null
              : ColoredBox(
                  color: bgBlack,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GradientButton(
                        child: animationController.isAnimating
                            ? Center(
                                child: RotationTransition(
                                    turns: base,
                                    child: Image.asset(
                                      AppAssets.loadingIcon,
                                      color: Colors.white,
                                    )))
                            : Text("שמירת שינויים",
                                style: textStyle14s400w.copyWith(
                                    color: false ? defaultGrey : kWhite)),
                        onPressed: () async {
                          final controller =
                              widget.businessProfileMenuController;

                          final name =
                              controller.nameController.value.text.trim();
                          final email =
                              controller.emailController.value.text.trim();
                          final phone = controller.phoneController.value.text
                              .replaceAll(RegExp(r'\D'), '');
                          bool hasEmailError = false;
                          bool hasPhoneError = false;
                          // Validation
                          final hasNameError = name.isEmpty;
                          controller.usernameeEror.value = hasNameError;
                          if (userController.loginType.value.toString() ==
                              "1") {
                            hasEmailError =
                                !RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,5}$')
                                    .hasMatch(email);
                            controller.userEmailError.value = hasEmailError;
                          } else {
                            hasPhoneError = phone.length != 10;
                            controller.userphoneError.value = hasPhoneError;
                          }

                          // Update error states

                          final isValid =
                              !(hasNameError || hasEmailError || hasPhoneError);

                          if (!isValid) return;

                          try {
                            animationController
                              ..forward()
                              ..repeat();
                            controller.userphoneError.value = false;
                            controller.usernameeEror.value = false;
                            controller.userEmailError.value = false;

                            setState(
                                () {}); // Trigger any UI update for loading state

                            await controller
                                .updateUserDetailsController(
                              businessProfileMenuController: controller,
                              context: context,
                              name: name,
                              phone: phone,
                              email: email,
                            )
                                .then((value) {
                              animationController.stop();
                            });
                          } catch (e) {
                            print("Update failed: $e");
                          } finally {
                            animationController.stop();
                          }
                        },
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: IntrinsicWidth(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'ביטול',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color: titleTextWhiteColor,
                                        fontSize: 16),
                              ).tr(),
                              const SizedBox(height: 4),
                              Container(
                                  height: 1, width: 37, color: titleTextColor),
                            ],
                          ),
                        ),
                      ),

                        SizedBox(height: Platform.isAndroid?size.height * 0.07:size.height * 0.03),
                    ],
                  ),
                ),
          body: Obx(
            () => SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05, vertical: size.height * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.01),

                  Center(
                      child: widget.businessProfileMenuController.pickedFilePath
                                  .value ==
                              ""
                          ? widget.businessProfileMenuController.profileimage.value ==
                                  ""
                              ? Container(
                                  margin:
                                      EdgeInsets.only(left: size.width * 0.01),
                                  height: size.width * 0.25,
                                  width: size.width * 0.25,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: AssetImage(
                                              AppAssets.galleryPlaceholder),
                                          fit: BoxFit.cover)),
                                )
                              : buildCachedNetworkImage(
                                  height: size.width * 0.25,
                                  width: size.width * 0.25,
                                  url: WebService.resolveProfileImage(widget
                                      .businessProfileMenuController
                                      .profileimage.value),
                                  radius: size.width * 0.3)
                          : Container(
                              height: size.width * 0.3,
                              width: size.width * 0.3,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(size.width * 0.3)),
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: FileImage(widget
                                          .businessProfileMenuController
                                          .pikedFileData
                                          .value!))))),
                  SizedBox(height: size.height * 0.01),
                  Center(
                    child: TextButton.icon(
                      icon: SvgPicture.asset(AppAssets.editIcon,
                          color: titleTextColor),
                      onPressed: () => _imageUploadDialogue(
                          context, widget.businessProfileMenuController),
                      label: const Text("העלאת תמונה",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: dividerGray)),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),

                  //name
                  buildName(size, context),
                  SizedBox(height: size.height * 0.03),

                  buildPhoneRow(size: size),
                  SizedBox(height: size.height * 0.03),

                  //email
                  buildEmail(size, context),
                  SizedBox(height: size.height * 0.2),
                ],
              ),
            ),
          )),
    );
  }

  //toggle studio or artist
  // buildArtistOrStudioSelection({required Size size}) =>
  //     Row(mainAxisAlignment: MainAxisAlignment.center, children: [
  //       buildTabBtn(
  //           title: "user_to_business.txt_studio",
  //           onTap: () => {},
  //           icon: AppAssets.iconStudio,
  //           size: size,
  //           isSelected: widget.businessProfileMenuController.isStudioSelected.value == true),
  //       buildTabBtn(
  //           title: "user_to_business.txt_artist",
  //           onTap: () => {},
  //           icon: AppAssets.iconArtist,
  //           size: size,
  //           isSelected: widget.businessProfileMenuController.isStudioSelected.value == false),
  //     ]);

  //build tab btn for business selection
  // buildTabBtn(
  //         {required String title,
  //         required VoidCallback onTap,
  //         required String icon,
  //         required Size size,
  //         required bool isSelected}) =>
  //     Expanded(
  //       child: Container(
  //         decoration: BoxDecoration(
  //           border: Border(
  //             bottom: BorderSide(
  //                 width: size.width * 0.015,
  //                 color: isSelected
  //                     ? Theme.of(context).primaryColor
  //                     : socialoginbtn),
  //           ),
  //         ),
  //         child: TextButton.icon(
  //           icon: Image.asset(icon),
  //           onPressed: onTap,
  //           label: Text(
  //             title,
  //             style: TextStyle(
  //                 color: isSelected ? titleTextWhiteColor : textEditingColor2,
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.w500),
  //           ).tr(),
  //         ),
  //       ),
  //     );

  // Business Name Or Studio Name
  Column buildName(Size size, BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.03),
          Text(
            "שם מלא",
            //  userController.name.value,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: titleTextWhiteColor, fontWeight: FontWeight.w400),
          ).tr(),
          SizedBox(height: size.height * 0.02),
          TextFormField(
              //   initialValue: "ישראל ישראלי",
              // initialValue: userController.name.value,
              autofocus: false,
              controller:
                  widget.businessProfileMenuController.nameController.value,
              //widget.businessProfileMenuController.nameController.value,
              keyboardType: TextInputType.name,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: titleTextWhiteColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w400),
              decoration: InputDecoration(
                hintStyle: hintStyle,
                hintText: "",
                contentPadding: const EdgeInsets.all(8),
                filled: true,
                fillColor: socialoginbtn,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              )),
          if (widget.businessProfileMenuController.usernameeEror.value)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: errorColor),
                  SizedBox(width: size.width * 0.02),
                  Text("registration.full_name_error",
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

  Column buildEmail(Size size, BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SizedBox(height: size.height * 0.03),
          Text(
            "כתובת אימייל",
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: titleTextWhiteColor, fontWeight: FontWeight.w400),
          ).tr(),
          SizedBox(height: size.height * 0.02),
          TextFormField(
              //    initialValue: "mail@mail.com",
              // initialValue: userController.email.value,
              readOnly: userController.loginType.value.toString() == "1"
                  ? false
                  : true,
              enabled: userController.loginType.value.toString() != "1"
                  ? false
                  : true,
              autofocus: false,
              controller:
                  widget.businessProfileMenuController.emailController.value,
              //widget.businessProfileMenuController.nameController.value,
              keyboardType: TextInputType.emailAddress,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: titleTextWhiteColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w400),
              decoration: InputDecoration(
                hintStyle: hintStyle,
                hintText: "",
                contentPadding: const EdgeInsets.all(8),
                filled: true,
                fillColor: socialoginbtn,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              )),
          Container(
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom)),
          if (widget.businessProfileMenuController.userEmailError.value &&
              userController.loginType.value.toString() == "1")
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: errorColor),
                  SizedBox(width: size.width * 0.02),
                  Text("registration.email_address_error",
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

  //build edittext
  buildPhoneRow({required size}) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "מספר טלפון",
            //  userController.name.value,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: titleTextWhiteColor, fontWeight: FontWeight.w400),
          ).tr(),
          SizedBox(height: size.height * 0.02),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.businessProfileMenuController.userphoneError.value
                    ? errorColor
                    : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
              color: socialoginbtn,
            ),
            child: Row(
              children: [
                Flexible(
                    child: TextField(
                  focusNode: _focusNode,
                  enabled: userController.loginType.value.toString() == "1"
                      ? false
                      : true,
                  readOnly: userController.loginType.value.toString() == "1"
                      ? true
                      : false,
                  textDirection: ui.TextDirection.ltr,
                  controller: widget
                      .businessProfileMenuController.phoneController.value,
                  onChanged: (txt) {
                    if (userController.loginType.value.toString() != "1") {
                      var value = txt.replaceAll(new RegExp(r'[^0-9]'), '');
                      if (txt == null || txt == "") {
                        loginvalidation = "login.phone_number_incorrect";
                      } else if (txt.startsWith('0972') ||
                          txt.startsWith('972') ||
                          txt.startsWith('097-2') ||
                          txt.startsWith('97-2')) {
                        // Show error, disable submit, etc.

                        displayMessageIcon(
                            message: "אין צורך להקליד קידומת מדינה 972",
                            color: errorColor,
                            snackposition: SnackPosition.BOTTOM,
                            imageData: AppAssets.errorIcon);
                        txt = "";
                        widget
                            .businessProfileMenuController.phoneController.value
                            .clear();
                      } else if (value.length != 10) {
                        loginvalidation = "מספר הטלפון חייב להיות בן 10 ספרות";
                      } else {
                        loginvalidation = "";

                        widget.businessProfileMenuController.userphoneError
                            .value = false;
                      }

                      widget.businessProfileMenuController.phoneController.value
                          .text = txt;
                      setState(() {});
                    }
                  },
                  maxLines: 1,
                  style: const TextStyle(color: kWhite),
                  autofocus: false,
                  cursorColor: kWhite,
                  keyboardType: TextInputType.phone,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                    NumberFormatterWidget()
                  ],
                  textAlign: TextAlign.left,
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
                )),
                userController.loginType.value.toString() == "1"
                    ? Text(
                        "${WebService.countryCode} +",
                        style: const TextStyle(color: kWhite),
                      )
                    : InkWell(
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
                            if (userController.loginType.value.toString() !=
                                "1") {
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
          SizedBox(width: size.width * 0.03),
          if (widget.businessProfileMenuController.userphoneError.value)
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

// buildPhonenumber({required size}) => Column(
//   mainAxisSize: MainAxisSize.min,
//   children: [
//     Align(
//         alignment: Alignment.centerRight,
//         child: Text("מספר טלפון",
//             style: Theme.of(context).textTheme.titleMedium!.copyWith(
//                 color: titleTextWhiteColor,
//                 fontWeight: FontWeight.w400))
//             .tr()),
//     SizedBox(height: size.height * 0.02),
//     Container(
//       decoration: BoxDecoration(
//           border: Border.all(
//               color:  widget.businessProfileMenuController.userphoneError.value ? errorColor : Colors.transparent,
//               width: 2),
//           borderRadius: BorderRadius.circular(8),
//           color: socialoginbtn),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Flexible(
//               child: TextFormField(
//                 //  readOnly: _readOnlyphone,
//                 style: const TextStyle(color: kWhite),
//                 // autofocus: false,
//                 // enabled: false,
//                 controller: widget
//                     .businessProfileMenuController.phoneController.value,
//                 maxLines: 1,
//                 onChanged: (txt) => setState(() => widget
//                     .businessProfileMenuController
//                     .phoneController
//                     .value
//                     .text = txt),
//                 cursorColor: kWhite,
//                 //  initialValue: "50-123-4534",
//                 // initialValue: widget.businessProfileMenuController.phoneController.value.text ?? userController.phone.value,
//                 keyboardType: TextInputType.phone,
//                 // inputFormatters: <TextInputFormatter>[
//                 //   FilteringTextInputFormatter.digitsOnly,
//                 //   LengthLimitingTextInputFormatter(10),
//                 //   NumberFormatterWidget()
//                 // ],
//                 textAlign: TextAlign.left,
//                 autovalidateMode: AutovalidateMode.onUserInteraction,
//                 validator: (str) {
//                   var value = str?.replaceAll(new RegExp(r'[^0-9]'), '');
//                   if (str == null || str == "") {
//                     _phoneerror = true;
//                     return '';
//                   } else if (value?.length != 10) {
//                     _phoneerror = true;
//                     return '';
//                   } else {
//                     _phoneerror = false;
//                     return null;
//                   }
//                 },
//                 autofillHints: [AutofillHints.telephoneNumber],
//                 decoration: const InputDecoration(
//                     filled: true,
//                     fillColor: Colors.transparent,
//                     contentPadding:
//                     EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//                     border: InputBorder.none,
//                     focusedBorder: InputBorder.none,
//                     enabledBorder: InputBorder.none,
//                     errorBorder: InputBorder.none,
//                     disabledBorder: InputBorder.none,
//                     errorMaxLines: 1,
//                     errorText: '',
//                     errorStyle: TextStyle(
//                       height: 0,
//                       color: Colors.transparent,
//                       fontSize: 0,
//                     ),
//                     labelStyle: TextStyle(color: kWhite),
//                     hintStyle: TextStyle(color: defaultGrey),
//                     hintText: "050-000-0000"),
//                 // hintText: "מספר טלפון"),
//                 textInputAction: TextInputAction.done,
//               )),
//           InkWell(
//               splashColor: Colors.grey,
//               // onTap: () => showCountryPicker(
//               //   context: context,
//               //   countryListTheme: CountryListThemeData(
//               //       bottomSheetHeight: Get.size.height * 0.8,
//               //       backgroundColor: kBlack,
//               //       textStyle: const TextStyle(color: kWhite),
//               //       searchTextStyle: const TextStyle(color: kWhite),
//               //       inputDecoration: InputDecoration(
//               //         // hintText:"txt_search",
//               //           hintStyle: const TextStyle(color: kWhite),
//               //           fillColor: signInButtonColor,
//               //           filled: true,
//               //           isDense: true,
//               //           border: OutlineInputBorder(
//               //               gapPadding: 0.0,
//               //               borderRadius:
//               //               BorderRadius.circular(10)))),
//               //   favorite: <String>['IL'],
//               //   showPhoneCode: true,
//               //   // optional. Shows phone code before the country name.
//               //   onSelect: (Country country) {
//               //     setState(() {
//               //       WebService.countryCode = country.phoneCode;
//               //     });
//               //   },
//               // ),
//
//               // child: Text("972 +",
//               child: Text(userController.cntCode.value + "+",
//                   style: const TextStyle(
//                       color: textEditingColor2, fontSize: 16))),
//           SizedBox(width: size.width * 0.03)
//         ],
//       ),
//     ),
//     if (_phoneerror)
//       Padding(
//         padding: const EdgeInsets.only(top: 3.0),
//         child: Row(
//           children: [
//             const Icon(Icons.error_outline, color: errorColor),
//             SizedBox(width: size.width * 0.02),
//             Text("registration.phone_number_error",
//                 style: Theme.of(context)
//                     .textTheme
//                     .titleMedium!
//                     .copyWith(
//                     color: errorColor,
//                     fontWeight: FontWeight.w400))
//                 .tr(),
//           ],
//         ),
//       ),
//   ],
// );

// buildDetailBtnSubmit(
//         {required BuildContext context, required Size size, required text}) =>
//     InkWell(
//       onTap: () async {
//         // _showBottomSheetNewBoard(context);
//         //  saveDataBtn(context, size);
//       },
//       child: Center(
//         child: Container(
//           width: size.width - 40,
//           height: 52,
//           //size.height * 0.07,
//           alignment: Alignment.center,
//           decoration: const BoxDecoration(
//             borderRadius: BorderRadius.all(Radius.circular(8)),
//             gradient: LinearGradient(
//               begin: Alignment.centerRight, // For RTL, start from right
//               end: Alignment.centerLeft, // For RTL, end at left
//               colors:
//                   // aboutTextController.text.isNotEmpty
//                   //     ?
//                   [
//                 linearGradieantColor1,
//                 linearGradieantColor2,
//                 linearGradieantColor3,
//               ],
//               //     :
//               // colors: [
//               //   lineargrayGradieantColor1,
//               //   lineargrayGradieantColor2,
//               //   lineargrayGradieantColor3,
//               // ],
//               stops: [0.0, 0.001, 0.8937],
//             ),
//           ),
//           child: Text(
//             text,
//             // "+ אוסף חדש",
//             // style: Theme.of(context).textTheme.titleMedium?.copyWith(
//             //     color: aboutTextController.text.isEmpty ? defaultGrey : kWhite,
//             //     fontWeight: FontWeight.w700),
//             style: Theme.of(context)
//                 .textTheme
//                 .titleMedium
//                 ?.copyWith(color: kWhite, fontWeight: FontWeight.w500),
//           ),
//         ),
//       ),
//     );
}

// Future<void> saveDataBtn(BuildContext context, Size size,BusinessProfileMenuController businessProfileMenuController) async {
//   showDialog<String>(
//     context: context,
//     builder: (BuildContext context) =>
//         StatefulBuilder(builder: (builder, setstate) {
//       return AlertDialog(
//         titlePadding: const EdgeInsets.all(1.0),
//         backgroundColor: socialoginbtn,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         actionsAlignment: MainAxisAlignment.center,
//         title: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
//           child: Column(
//             children: [
//               const Text("בטוחים שתרצו לבטל את\n השינויים שבוצעו?",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                       fontSize: 18,
//                       color: titleTextWhiteColor,
//                       fontWeight: FontWeight.w700)),
//               SizedBox(height: size.height * 0.03),
//               Text("לשמירה חזרו למצב עריכה ולחצו  על כפתור ‘שמירת שינויים’",
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.titleSmall!.copyWith(
//                       fontSize: 16,
//                       color: titleTextWhiteColor,
//                       fontWeight: FontWeight.w400)),
//               SizedBox(height: size.height * 0.03),
//               SizedBox(
//                 width: size.width,
//                 height: size.height * 0.06,
//                 child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       foregroundColor: bgBlack,
//                       backgroundColor: titleTextColor,
//                     ),
//                     onPressed: () async {
//                       // animationController.stop();
//                       Get.back();
//
//                       Get.find<BusinessProfileMenuController>()
//                           .businessEditProfileController();
//                     },
//                     child: const Text('כן, בטל שינויים',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w400,
//                         ))),
//               ),
//               SizedBox(height: size.height * 0.015),
//               SizedBox(
//                 width: size.width,
//                 height: size.height * 0.06,
//                 child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       foregroundColor: titleTextWhiteColor,
//                       backgroundColor: const Color(0xFF403D44),
//                     ),
//                     onPressed: () async {
//                       // animationController.stop();
//                       Get.back();
//                     },
//                     child: const Text(
//                       "לא, חזרה לעריכה",
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     )),
//               ),
//             ],
//           ),
//         ),
//       );
//     }),
//   );
// }

_imageUploadDialogue(BuildContext context,
    BusinessProfileMenuController businessProfileMenuController) {
  businessProfileMenuController.selectImage(
      context, ImageSource.gallery);
  // return showModalBottomSheet<dynamic>(
  //     useRootNavigator: true,
  //     isScrollControlled: true,
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Container(
  //         decoration: const BoxDecoration(
  //             color: signInButtonColor,
  //             borderRadius: BorderRadius.only(
  //                 topLeft: Radius.circular(16), topRight: Radius.circular(16))),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             //close
  //             InkWell(
  //                 onTap: () => Get.back(),
  //                 child: Padding(
  //                     padding: EdgeInsets.symmetric(
  //                         vertical: MediaQuery.of(context).size.height * 0.03,
  //                         horizontal: MediaQuery.of(context).size.width * 0.4),
  //                     child: ClipRRect(
  //                       borderRadius: BorderRadius.circular(20.0),
  //                       child: Container(
  //                         margin: const EdgeInsetsDirectional.only(
  //                             start: 1.0, end: 1.0),
  //                         height: MediaQuery.of(context).size.height * 0.005,
  //                         width: MediaQuery.of(context).size.width * 0.2,
  //                         decoration: BoxDecoration(
  //                           color: kDivider,
  //                           borderRadius: BorderRadius.circular(
  //                               10.0), // Adjust the radius as needed
  //                         ),
  //                       ),
  //                     ))),
  //
  //             //sketch
  //             InkWell(
  //               onTap: () async {
  //                 Navigator.of(context).pop();
  //
  //                 businessProfileMenuController.selectImage(
  //                     context, ImageSource.gallery);
  //               },
  //               child: Container(
  //                 padding: const EdgeInsets.all(16),
  //                 width: double.infinity,
  //                 color: signInButtonColor,
  //                 height: MediaQuery.of(context).size.height * 0.08,
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.start,
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   children: [
  //                     SvgPicture.asset(AppAssets.photoIcon),
  //                     const SizedBox(width: 8),
  //                     // const Text("העלאת תמונה",
  //                     const Text("העלאת תמונה",
  //                         style: TextStyle(
  //                             color: titleTextWhiteColor, fontSize: 18)),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //
  //             //sketch
  //             InkWell(
  //               onTap: () async {
  //                 Navigator.of(context).pop();
  //                 businessProfileMenuController.selectImage(
  //                     context, ImageSource.camera);
  //               },
  //               child: Container(
  //                 padding: const EdgeInsets.all(16),
  //                 width: double.infinity,
  //                 color: signInButtonColor,
  //                 height: MediaQuery.of(context).size.height * 0.09,
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.start,
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   children: [
  //                     SvgPicture.asset(AppAssets.cameraIcon),
  //                     const SizedBox(width: 8),
  //                     // const Text("צילום תמונה",
  //                     const Text("צילום תמונה",
  //                         style: TextStyle(
  //                             color: titleTextWhiteColor, fontSize: 18)),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             SizedBox(
  //               height: MediaQuery.of(context).size.height * 0.03,
  //             )
  //           ],
  //         ),
  //       );
  //     });
}

//select image

class Style {
  final String name;

  Style({required this.name});
}
