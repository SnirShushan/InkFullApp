import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/data/source/network/api.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/ui/screen/profile/subscription/iosubscription/purchase_ios_screen.dart';
import 'package:ink/src/ui/screen/profile/subscription/purchase_screen.dart';
import 'package:ink/src/ui/widgets/button/custom_gradient_btn_widget.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/webService.dart';

import 'colors.dart';

//placeholder images
const String imgUrl =
    "https://cdn.pixabay.com/photo/2020/01/29/17/09/snowboard-4803050_960_720.jpg";
const String imgUrl2 =
    "https://cdn.pixabay.com/photo/2020/12/15/16/25/clock-5834193__340.jpg";
const String imgUrl3 =
    'https://st3.depositphotos.com/6672868/13701/v/450/depositphotos_137014128-stock-illustration-user-profile-icon.jpg';

//background
buildBackground() => Container(
      decoration: const BoxDecoration(
          gradient:
              LinearGradient(colors: [Color(0xff3E6482), Color(0xff6B98BA)])),
    );

//appbar
buildappBar(
        {required bool isEnabled,
        required BuildContext context,
        required size,
        required String title}) =>
    AppBar(
      elevation: 0,
      backgroundColor: appbarBg,
      automaticallyImplyLeading: false,
      leading: isEnabled
          ? Builder(
              builder: (context) => InkWell(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: const Icon(Icons.menu, color: Colors.black)))
          : const SizedBox(),
      centerTitle: true,
      toolbarHeight: size.height * 0.1,
      title: Text(title,
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: size.height * 0.02)),
    );

//appbar with close btn
buildappBarwithClose({required size, required title}) => AppBar(
      elevation: 0,
      backgroundColor: appbarBg,
      automaticallyImplyLeading: false,
      actions: [CloseButton(color: Colors.black, onPressed: () => Get.back())],
      centerTitle: true,
      toolbarHeight: size.height * 0.1,
      title: Text(title,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: size.height * 0.02))
          .tr(),
    );

// buildRegistrationAppbar(
//         {required size,
//         required title,
//         required BuildContext context,
//         isback = false}) =>
//     AppBar(
//       elevation: 0,
//       backgroundColor: appbar2Bg,
//       automaticallyImplyLeading: false,
//       leading: isback
//           ? Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: InkWell(
//                 onTap: () => Get.back(),
//                 child: const Icon(Icons.arrow_back_ios, color: Colors.white),
//               ))
//           : const SizedBox(),
//       actions: [
//         CloseButton(
//             color: Colors.white,
//             onPressed: () => exitRegistrationDialog(size, context))
//       ],
//       centerTitle: true,
//       toolbarHeight: size.height * 0.1,
//       title: Text(title,
//               style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: size.height * 0.02))
//           .tr(),
//     );

// exitRegistrationDialog(size, context) {
//   showDialog<String>(
//       context: context,
//       builder: (BuildContext context) =>
//           StatefulBuilder(builder: (builder, setState) {
//             return AlertDialog(
//                 titlePadding: const EdgeInsets.all(1.0),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20)),
//                 title: ClipRRect(
//                     borderRadius: BorderRadius.circular(20),
//                     child: Container(
//                         color: defaultWhite,
//                         child: Center(
//                             child: Padding(
//                                 padding: EdgeInsets.all(size.width * 0.01),
//                                 child: const Text("בטוח? לצאת מההרשמה?"))))),
//                 actionsAlignment: MainAxisAlignment.center,
//                 actions: <Widget>[
//                   TextButton(
//                       style: TextButton.styleFrom(
//                           foregroundColor: defaultAppColor,
//                           side: const BorderSide(color: defaultAppColor)),
//                       onPressed: () async {
//                         PushNotificationsManager().goToDashboard();
//                       },
//                       child: const Text('כן')),
//                   TextButton(
//                       style: TextButton.styleFrom(
//                           backgroundColor: defaultAppColor),
//                       onPressed: () => Navigator.pop(context, 'לא'),
//                       child: const Text('לא',
//                           style: TextStyle(color: Colors.white)))
//                 ]);
//           }));
// }

buildappBarwithback({required size, required title}) => AppBar(
      elevation: 0,
      backgroundColor: Colors.black,
      automaticallyImplyLeading: false,
      leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Get.back(),
            child: const Icon(Icons.arrow_back_ios, color: Colors.white),
          )),
      centerTitle: true,
      toolbarHeight: size.height * 0.1,
      title: Text(title,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: size.height * 0.02)),
    );

//edittextDecoration
buildInputDecoration({required InputBorder border, required String hint}) =>
    InputDecoration(border: border, hintText: hint);

//edittext
buildEditText(
        {required controller,
        required inputType,
        required format,
        required validation,
        required inputAction}) =>
    TextFormField(
      controller: controller,
      keyboardType: inputType,
      inputFormatters: <TextInputFormatter>[format],
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validation,
      decoration:
          buildInputDecoration(border: InputBorder.none, hint: "שליחת קוד"),
      textInputAction: inputAction,
    );

//snackBar
// void displayMessage(String message, Color color) {
//   Get.rawSnackbar(
//     messageText:
//         Text(message, style: const TextStyle(color: Colors.white, fontSize: 16))
//             .tr(),
//     // snackPosition: SnackPosition.BOTTOM,
//     backgroundColor: color,
//     borderRadius: 20,
//     margin: const EdgeInsets.all(20.0),
//     padding: const EdgeInsets.all(20.0),
//     duration: const Duration(seconds: 1),
//     isDismissible: true,
//     // forwardAnimationCurve: Curves.easeOutBack,
//   ); //snackBar
// }

void displayMessageIcon(
        {required String message,
        required Color color,
        snackposition = SnackPosition.TOP,
        required String imageData}) =>
    Get.rawSnackbar(
      messageText: Text(message,
          style: const TextStyle(
            fontFamily: 'Arimo', // Assuming you have the Arimo font included
            fontSize: 14.0, // Logical pixels, may need adjustment
            fontWeight: FontWeight.normal,
            color: titleTextWhiteColor,
          )).tr(),
      snackPosition: snackposition,
      backgroundColor: color,
      borderRadius: 8,
      margin: const EdgeInsets.all(30.0),
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 0),
      duration: const Duration(seconds: 2),
      icon: SvgPicture.asset(
        imageData,
      ),
      // forwardAnimationCurve: Curves.easeOutBack,
    );

void displayMessageShareIcon(
    {required String message,
      required Color color,
      snackposition = SnackPosition.TOP,
      required String imageData}) =>
    Get.rawSnackbar(
      messageText: Text(message,
          style: const TextStyle(
            fontFamily: 'Arimo', // Assuming you have the Arimo font included
            fontSize: 14.0, // Logical pixels, may need adjustment
            fontWeight: FontWeight.normal,
            color: titleTextWhiteColor,
          )).tr(),
      snackPosition: snackposition,
      backgroundColor: color,
      borderRadius: 8,
      margin: const EdgeInsets.symmetric(horizontal: 30.0),
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0),
      duration: const Duration(seconds: 4),
      icon: SvgPicture.asset(
        imageData,
      ),
      // forwardAnimationCurve: Curves.easeOutBack,
    );

void noIntenetConnectionPopup() {
  Future.delayed(Duration.zero, () {
    Get.rawSnackbar(
      messageText: const Text(
          "בעקבות בעיה טכנית הפנייה לא נשלחה.\nלתמיכה טכנית חייגו: 053-356-2686",
          style: TextStyle(
            fontSize: 14.0, // Logical pixels, may need adjustment
            fontWeight: FontWeight.normal,
            color: titleTextWhiteColor,
          )).tr(),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: errorColor,
      borderRadius: 8,
      margin: const EdgeInsets.all(30.0),
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 0),
      duration: const Duration(seconds: 2),
      icon: SvgPicture.asset(
        AppAssets.errorIcon,
      ),
      // forwardAnimationCurve: Curves.easeOutBack,
    );
  });
}

void displayReportMessage(String message, Color color) {
  Get.rawSnackbar(
    messageText: Text(message,
        style: const TextStyle(color: Colors.black, fontSize: 16)),
    // snackPosition: SnackPosition.BOTTOM,
    backgroundColor: color,
    borderRadius: 20,
    margin: const EdgeInsets.all(20.0),
    padding: const EdgeInsets.all(20.0),
    duration: const Duration(seconds: 1),
    isDismissible: true,
    // forwardAnimationCurve: Curves.easeOutBack,
  );
}

buildRequestForTattoImage(
        {required height,
        required width,
        required bool isclickable,
        required url,
        required double radius}) =>
    Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                  width: isclickable ? 4 : 0,
                  color: isclickable
                      ? const Color(0xff6851B3)
                      : Colors.transparent)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: url == ""
                ? Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: AssetImage(AppAssets.userPlaceHolder),
                            fit: BoxFit.cover)),
                  )
                : CachedNetworkImage(
                    alignment: Alignment.center,
                    imageUrl: WebService.resolveImageUrl(url),
                    fit: BoxFit.cover,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => SizedBox(
                      height: height,
                      width: width,
                      child: Center(
                          child: CircularProgressIndicator(
                              value: downloadProgress.progress)),
                    ),
                    errorWidget: (context, url, error) => Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: AssetImage(AppAssets.userPlaceHolder),
                              fit: BoxFit.cover)),
                    ),
                  ),
          ),
        ),
        if (isclickable)
          Positioned(
            right: -4,
            top: -2,
            child: SvgPicture.asset(
              AppAssets.clickableViolet,
              width: 30,
              height: 30,
            ),
          ),
      ],
    );

buildCachedNetworkImage(
        {required height,
        required width,
        required url,
        Widget? errorWidget,
        String? errorImgUrl,
        required double radius}) =>
    Builder(builder: (context) {
      final dpr = MediaQuery.devicePixelRatioOf(context);
      final w = (width is num) ? width.toDouble() : 120.0;
      final h = (height is num) ? height.toDouble() : 120.0;
      final cacheW = (w * dpr).round().clamp(64, 1200);
      final cacheH = (h * dpr).round().clamp(64, 1200);
      final resolved = WebService.resolveImageUrl(url?.toString());
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius)),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: url == "" || url == null || url.toString().isEmpty
                ? errorWidget ??
                    Image.asset(AppAssets.galleryPlaceholder,
                        width: width, fit: BoxFit.cover)
                : CachedNetworkImage(
                    alignment: Alignment.center,
                    imageUrl: resolved,
                    fit: BoxFit.cover,
                    fadeInDuration: Duration.zero,
                    fadeOutDuration: Duration.zero,
                    filterQuality: FilterQuality.low,
                    memCacheWidth: cacheW,
                    memCacheHeight: cacheH,
                    maxWidthDiskCache: cacheW,
                    maxHeightDiskCache: cacheH,
                    placeholder: (context, url) => ColoredBox(
                          color: const Color(0xFF2A262E),
                          child: SizedBox(height: height, width: width),
                        ),
                    errorWidget: (context, url, error) =>
                        errorWidget ??
                        Image.asset(AppAssets.galleryPlaceholder,
                            width: width, fit: BoxFit.cover))),
      );
    });

buildCachedNetworkImage2(
        {required height,
        required width,
        required url,
        Widget? errorWidget,
        String? errorImgUrl,
        required double radius}) =>
    buildCachedNetworkImage(
        height: height,
        width: width,
        url: url,
        errorWidget: errorWidget,
        errorImgUrl: errorImgUrl,
        radius: radius);

buildOwnerProfileImage(
        {required Size size, required String ownerImage, double? width}) =>
    WebService.isMissingProfileImage(ownerImage)
        ? Container(
            margin: EdgeInsets.only(left: size.width * 0.01),
            height: width ?? size.width * 0.1,
            width: width ?? size.width * 0.1,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: AssetImage(AppAssets.userPlaceHolder),
                    fit: BoxFit.cover)),
          )
        : CachedNetworkImage(
            imageUrl: WebService.resolveImageUrl(ownerImage,
                base: WebService.profileImageUrl),
            imageBuilder: (context, imageprovider) => Container(
                  margin: EdgeInsets.only(left: size.width * 0.01),
                  height: width ?? size.width * 0.1,
                  width: width ?? size.width * 0.1,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: imageprovider, fit: BoxFit.cover)),
                ),
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                SizedBox(
                  height: width ?? size.width * 0.05,
                  width: width ?? size.width * 0.05,
                  child: Center(
                      child: CircularProgressIndicator(
                          value: downloadProgress.progress)),
                ),
            errorWidget: (context, url, error) => Container(
                  margin: EdgeInsets.only(left: size.width * 0.01),
                  height: width ?? size.width * 0.1,
                  width: width ?? size.width * 0.1,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: AssetImage(AppAssets.userPlaceHolder),
                          fit: BoxFit.cover)),
                ));

buildTabIcon(
        {required bool isFill,
        required Size size,
        required String iconPath,
        required String afterTapIcon}) =>
    SizedBox(
        height: size.width * 0.07,
        width: size.width * 0.07,
        child: isFill
            ? Image.asset(
                "assets/icons/$afterTapIcon",
              )
            : Image.asset(
                "assets/icons/$iconPath",
              ));

// buildDivider(size) => Padding(
//       padding: EdgeInsets.all(size.width * 0.02),
//       child: const Divider(thickness: 2),
//     );

// //icon toggle button
// buildIconWidget(
//         {required isFill,
//         required size,
//         required iconPath,
//         required afterTapIcon,
//         required onClick}) =>
//     InkWell(
//         splashColor: Colors.grey,
//         onTap: onClick,
//         child: SizedBox(
//             child: isFill
//                 ? Image.asset(
//                     "assets/icons/$afterTapIcon",
//                     height: size,
//                     width: size,
//                     color: iconPath == "ic_like.png" ? defaultAppColor : null,
//                   )
//                 : Image.asset(
//                     "assets/icons/$iconPath",
//                     height: size,
//                     width: size,
//                   )));

buildIconWidgetNonClickable(
        {required isFill,
        required size,
        required iconPath,
        required afterTapIcon}) =>
    SizedBox(
        height: size.width * 0.05,
        width: size.width * 0.05,
        child: isFill
            ? Image.asset("assets/icons/$afterTapIcon", color: defaultAppColor)
            : Image.asset("assets/icons/$iconPath", color: defaultAppColor));

//btn with purple background
buildButton(
        {required align,
        required size,
        required width,
        required text,
        required onClick}) =>
    Align(
      alignment: align,
      child: InkWell(
        onTap: onClick,
        child: Container(
          decoration: BoxDecoration(
              gradient: defaultPurple, borderRadius: BorderRadius.circular(13)),
          height: size.height * 0.06,
          width: width,
          padding: EdgeInsets.all(size.width * 0.02),
          child: Center(
            child: Text(text,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: const TextStyle(color: Colors.white))
                .tr(),
          ),
        ),
      ),
    );

//No Internet Connection
// widgetNoInternet(onClick) => Center(
//         child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Text("אין חיבור לאינטרנט"),
//         ElevatedButton(onPressed: onClick, child: const Text("נסה שוב"))
//       ],
//     ));

//delete dialog
Future<void> buildDeleteDialog(
    BuildContext context, VoidCallback onDelete) async {
  showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        titlePadding: const EdgeInsets.all(1.0),
        backgroundColor: socialoginbtn,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text("האם אתה בטוח רוצה למחוק?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      color: titleTextWhiteColor,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: titleTextWhiteColor,
                        backgroundColor: const Color(0xFF403D44),
                      ),
                      onPressed: () => Navigator.pop(context, 'אל'),
                      child: const Text("לא")),
                  const SizedBox(width: 8),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: kWhite,
                        backgroundColor: errorColor,
                      ),
                      onPressed: onDelete,
                      child: const Text("כן")),
                ],
              )
            ],
          ),
        ),
      ),
    ),
  );
}

//only premium plan show popup
Future<void> notSubscriptionDialog(
    {required BuildContext context,
    String title = "צפייה בפנייה חסומה"}) async {
  showDialog<String>(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) =>
        StatefulBuilder(builder: (builder, setstate) {
      return AlertDialog(
        titlePadding: const EdgeInsets.all(1.0),
        backgroundColor: socialoginbtn,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(tr("no_premium_plan.no_premium_plan_title"),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18,
                      color: titleTextWhiteColor,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Text(tr("no_premium_plan.no_premium_plan_sub_title"),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16,
                      color: titleTextWhiteColor,
                      fontWeight: FontWeight.w400)),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: titleTextWhiteColor,
                        backgroundColor: const Color(0xFF403D44),
                      ),
                      onPressed: () async {
                        Get.back();
                      },
                      child: Text(tr("no_premium_plan.back_btn"))),
                  const SizedBox(width: 8),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: bgBlack,
                        backgroundColor: titleTextColor,
                      ),
                      onPressed: () async {
                        Get.back();
                        if (Platform.isAndroid) {
                          await Network.getCheckSubscription().then((value) {
                            Get.to(PurchaseScreen(
                                fromRegistration: false,
                                checkstatus: value['status'].toString()));
                          });
                        } else {
                          await Network.getCheckSubscription().then((value) {
                            WebService.printMsg("getvalue123 $value");

                            if (value['status'].toString() == "0" ||
                                value['data']['subscription_status']
                                        .toString() ==
                                    "0") {
                              Get.to(IOSPurchaseScreen(
                                  checkstatus: value['status'].toString(),
                                  purchasename: 'ללא תוכנית קנייה',
                                  fromRegistration: false));
                            } else if (value['status'].toString() == "2") {
                              ApiResponse.sessionExpired(
                                  msg: "alerts.session_expire");
                            } else {
                              Get.to(IOSPurchaseScreen(
                                  checkstatus: value['status'].toString(),
                                  fromRegistration: false,
                                  purchasename:
                                      value['data']['product_id'].toString()));
                            }
                          });
                        }
                      },
                      child: Text(tr("no_premium_plan.upgrade_btn"))),
                ],
              )
            ],
          ),
        ),
      );
    }),
  );
}

Future<void> needSubscriptionUploadDialog(
    {required BuildContext context, bool backCurrentScreen = false}) async {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) =>
        StatefulBuilder(builder: (builder, setstate) {
      return AlertDialog(
          titlePadding: const EdgeInsets.all(1.0),
          backgroundColor: socialoginbtn,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // const Text("דף האייורים חסום",
                // const Text("צפייה בפנייה חסומה",
                // const Text("העלאת תמונה חסומה", // https://3.basecamp.com/3338141/buckets/29955561/todos/9354299190#__recording_9363323661
                const Text("רוצה להעלות סקיצות לפרופיל שלך?", //09-12-25
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        color: titleTextWhiteColor,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                // const Text("המנוי העיסקי כרגע לא פעיל, יש לבחור מסלול עיסקי",
                const Text("העלאת סקיצה זמינה רק למקעקעים במסלול מתקדם",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        color: titleTextWhiteColor,
                        fontWeight: FontWeight.w400)),
                const SizedBox(height: 24),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: titleTextWhiteColor,
                          backgroundColor: const Color(0xFF403D44),
                        ),
                        onPressed: () async {
                          Get.back();
                        },
                        child: Text(tr("no_premium_plan.back_btn"))),
                    const SizedBox(width: 8),
                    CustomGradientButtonWidget(
                      width: MediaQuery.of(context).size.width*0.35,
                      height: 35,
                      radius: 4,

                      onTap: () async {
                      if (backCurrentScreen) {
                        Get.back();
                      }
                      Get.back();
                      if (Platform.isAndroid) {
                        Network.getCheckSubscription().then((value) {
                          Get.to(PurchaseScreen(
                              fromRegistration: false,
                              checkstatus: value['status'].toString()));
                        });
                      } else {
                        await Network.getCheckSubscription().then((value) {
                          if (value['status'].toString() == "0" ||
                              value['data']['subscription_status']
                                  .toString() ==
                                  "0") {
                            Get.to(IOSPurchaseScreen(
                                checkstatus: value['status'].toString(),
                                purchasename: 'ללא תוכנית קנייה',
                                fromRegistration: false));
                          } else if (value['status'].toString() == "2") {
                            ApiResponse.sessionExpired(
                                msg: "alerts.session_expire");
                          } else {
                            Get.to(IOSPurchaseScreen(
                                checkstatus: value['status'].toString(),
                                fromRegistration: false,
                                purchasename: value['data']['product_id']
                                    .toString()));
                          }
                        });
                      }
                    },
                    title: 'לבחירת מסלול',
                    ),
                  ],
                )
              ],
            ),
          ));
    }),
  );
}

Future<void> needSubscriptionDialog(BuildContext context) async {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) =>
        StatefulBuilder(builder: (builder, setstate) {
      return AlertDialog(
          titlePadding: const EdgeInsets.all(1.0),
          backgroundColor: socialoginbtn,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // const Text("דף האייורים חסום",
                const Text("צפייה בפנייה חסומה",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        color: titleTextWhiteColor,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                const Text("המנוי העיסקי כרגע לא פעיל, יש לבחור מסלול עיסקי",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        color: titleTextWhiteColor,
                        fontWeight: FontWeight.w400)),
                const SizedBox(height: 24),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: titleTextWhiteColor,
                          backgroundColor: const Color(0xFF403D44),
                        ),
                        onPressed: () async {
                          Get.back();
                        },
                        child: Text(tr("no_premium_plan.back_btn"))),
                    const SizedBox(width: 8),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: bgBlack,
                          backgroundColor: titleTextColor,
                        ),
                        onPressed: () async {
                          Get.back();
                          if (Platform.isAndroid) {
                            Network.getCheckSubscription().then((value) {
                              Get.to(PurchaseScreen(
                                  fromRegistration: false,
                                  checkstatus: value['status'].toString()));
                            });
                          } else {
                            await Network.getCheckSubscription().then((value) {
                              if (value['status'].toString() == "0" ||
                                  value['data']['subscription_status']
                                          .toString() ==
                                      "0") {
                                Get.to(IOSPurchaseScreen(
                                    checkstatus: value['status'].toString(),
                                    purchasename: 'ללא תוכנית קנייה',
                                    fromRegistration: false));
                              } else if (value['status'].toString() == "2") {
                                ApiResponse.sessionExpired(
                                    msg: "alerts.session_expire");
                              } else {
                                Get.to(IOSPurchaseScreen(
                                    checkstatus: value['status'].toString(),
                                    fromRegistration: false,
                                    purchasename: value['data']['product_id']
                                        .toString()));
                              }
                            });
                          }
                        },
                        child: const Text('לבחירת מסלול')),
                  ],
                )
              ],
            ),
          ));
    }),
  );
}
// No plan Buy show popup

// Future<void> needSubscriptionDialog(BuildContext context) async {
//   showDialog<String>(
//     context: context,
//     builder: (BuildContext context) =>
//         StatefulBuilder(builder: (builder, setstate) {
//       return AlertDialog(
//         titlePadding: const EdgeInsets.all(1.0),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: ClipRRect(
//           borderRadius: BorderRadius.circular(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                   color: defaultWhite,
//                   child: Center(
//                     child: Padding(
//                       padding: EdgeInsets.all(Get.size.width * 0.01),
//                       child: const Text("דף האייורים חסום"),
//                     ),
//                   )),
//               Padding(
//                 padding: EdgeInsets.symmetric(
//                     vertical: 12.0, horizontal: Get.size.width * 0.005),
//                 child: Text("המנוי העיסקי כרגע לא פעיל, יש לבחור מסלול עיסקי",
//                     textAlign: TextAlign.center,
//                     style: Get.textTheme.bodyLarge),
//               )
//             ],
//           ),
//         ),
//         actionsAlignment: MainAxisAlignment.center,
//         actions: <Widget>[
//           TextButton(
//             style: TextButton.styleFrom(backgroundColor: defaultAppColor),
//             onPressed: () async {
//               Get.back();
//               if (Platform.isAndroid) {
//                 Get.to(const PurchaseScreen(
//                     sub1Id: 'subscription_basic_5day',
//                     sub2Id: 'subscription_premium_5day',
//                     fromRegistration: false));
//               } else {
//                 await Network.getCheckSubscription().then((value) {
//                   WebService.printMsg("getvalue123 $value");
//
//                   if (value['status'].toString() == "0" ||
//                       value['data']['subscription_status'].toString() == "0") {
//                     Get.to(const IOSPurchaseScreen(
//                         purchasename: 'ללא תוכנית קנייה',
//                         fromRegistration: false));
//                   } else if (value['status'].toString() == "2") {
//                     Network.sessionExpired(msg: "alerts.session_expire");
//                   } else {
//                     Get.to(IOSPurchaseScreen(
//                         fromRegistration: false,
//                         purchasename: value['data']['product_id'].toString()));
//                   }
//                 });
//               }
//             },
//             // onPressed: () => Navigator.pop(context, 'אל'),
//             child: const Text('לבחירת מסלול',
//                 style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       );
//     }),
//   );
// }

Future<void> purchaseSuccessDialog(size, context, text) async {
  showDialog<String>(
      context: context,
      builder: (BuildContext context) =>
          StatefulBuilder(builder: (builder, setState) {
            return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                actionsAlignment: MainAxisAlignment.center,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Text(text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: defaultAppColor,
                            side: const BorderSide(color: defaultAppColor)),
                        onPressed: () async {
                          Get.back();
                        },
                        child: const Text('כן')),
                  ],
                ));
          }));
}

buildDivider({size, Color? color, isPadding}) => Padding(
      padding: isPadding ? EdgeInsets.all(size.width * 0.02) : EdgeInsets.zero,
      child: Divider(thickness: 2, color: color ?? const Color(0XFF56525A)),
    );

//icon toggle button
buildIconWidget(
        {required isFill,
        required size,
        required iconPath,
        required afterTapIcon,
        required onClick}) =>
    InkWell(
        splashColor: Colors.grey,
        onTap: onClick,
        child: SizedBox(
            child: isFill
                ? Image.asset(
                    "assets/icons/$afterTapIcon",
                    height: size,
                    width: size,
                    color: iconPath == "ic_like.png" ? defaultAppColor : null,
                  )
                : Image.asset(
                    "assets/icons/$iconPath",
                    height: size,
                    width: size,
                  )));

buildSvgIcon(
        {required isFill,
        required size,
        required iconPath,
        required afterTapIcon,
        required double borderRadius,
        Color? bgColor,
        double? padding,
        required onClick}) =>
    InkWell(
        onTap: onClick,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: ColoredBox(
              color: bgColor ?? const Color(0xCC2B272F),
              child: Padding(
                  padding: EdgeInsets.all(padding ?? 0.0),
                  child: isFill
                      ? SizedBox(
                          height: size ?? 44,
                          width: size ?? 44,
                          child: SvgPicture.asset(afterTapIcon))
                      : SizedBox(
                          height: size ?? 44,
                          width: size ?? 44,
                          child: SvgPicture.asset(iconPath))),
            )));

//Image Limit Dialog
reachedImageLimitDialogCommon(
        {required Size size,
        required BuildContext context,
        required String title,
        required String subtitle}) =>
    showDialog<String>(
        context: context,
        builder: (BuildContext context) =>
            StatefulBuilder(builder: (builder, setState) {
              return AlertDialog(
                  insetPadding:
                      EdgeInsets.symmetric(horizontal: size.width * 0.1),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                  backgroundColor: socialoginbtn,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  actionsAlignment: MainAxisAlignment.center,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 18,
                              color: titleTextWhiteColor,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 16),
                      Text(subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 16,
                              color: titleTextWhiteColor,
                              fontWeight: FontWeight.w400)),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: titleTextWhiteColor,
                                backgroundColor: const Color(0xFF403D44),
                              ),
                              onPressed: () async {
                                Get.back();
                              },
                              child: Text(tr("no_premium_plan.back_btn"),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                          color: titleTextWhiteColor,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14))),
                          const SizedBox(width: 8),
                          CustomGradientButtonWidget(
                            title: tr("no_premium_plan.upgrade_btn"),
                            width: size.width * 0.35,
                            height: size.height * 0.05,
                            radius: 6,
                            textSize: 14,
                            onTap: () async {
                              // Network.userToUpgradeApi();
                              // Get.back();
                              if (Platform.isAndroid) {
                                await Network.getCheckSubscription()
                                    .then((value) {
                                  Get.back();
                                  Get.to(PurchaseScreen(
                                      fromRegistration: false,
                                      checkstatus: value['status'].toString()));
                                });
                              } else {
                                await Network.getCheckSubscription()
                                    .then((value) {
                                  Get.back();

                                  if (value['status'].toString() == "0" ||
                                      value['data']['subscription_status']
                                              .toString() ==
                                          "0") {
                                    Get.to(IOSPurchaseScreen(
                                        checkstatus: value['status'].toString(),
                                        purchasename: 'ללא תוכנית קנייה',
                                        fromRegistration: false));
                                  } else if (value['status'].toString() ==
                                      "2") {
                                    ApiResponse.sessionExpired(
                                        msg: "alerts.session_expire");
                                  } else {
                                    Get.to(IOSPurchaseScreen(
                                        checkstatus: value['status'].toString(),
                                        fromRegistration: false,
                                        purchasename: value['data']
                                                ['product_id']
                                            .toString()));
                                  }
                                });
                              }
                            },
                          ),
                        ],
                      )
                    ],
                  ));
            }));

void getBack(BuildContext context) {
  if (!Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  } else {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Get.back();
      }
    });
  }
}
