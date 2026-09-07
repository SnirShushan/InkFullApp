import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/utils/webService.dart';

import 'assets.dart';
import 'colors.dart';

class Utils {
  static final GlobalKey<NavigatorState> navigationKey =
      GlobalKey<NavigatorState>();

  static bool isDataEmpty(var data) {
    bool isEmpty = false;
    if (data == null) {
      isEmpty = true;
    } else if (data.toString() == "") {
      isEmpty = true;
    } else if (data.toString() == "null") {
      isEmpty = true;
    } else if (data == "") {
      isEmpty = true;
    } else {
      isEmpty = false;
    }
    return isEmpty;
  }

  static buildTitle({String? title, Color? color}) => Padding(
        padding: EdgeInsets.only(right: Get.size.width * 0.05),
        child: Text(
          title ?? "",
          style: Theme.of(Get.context!).textTheme.titleLarge!.copyWith(
              color: color ?? titleTextColor, fontWeight: FontWeight.w700),
        ).tr(),
      );

  //sub title
  static buildSubTitle({String? title, Color? color}) => Padding(
        padding: EdgeInsets.only(right: Get.size.width * 0.05),
        child: Text(
          title ?? "",
          style: Theme.of(Get.context!).textTheme.titleMedium!.copyWith(
                color: color ?? titleTextColor,
              ),
        ).tr(),
      );

  static goToScreen({required Widget screen, required bool isOffAll}) {
    isOffAll ? Get.offAll(screen) : Get.to(screen);
  }

  static buildBtnSubmit(
          {required BuildContext context,
          required Size size,
          required String title,
          required VoidCallback onTap}) =>
      Padding(
        padding: EdgeInsets.all(size.width * 0.02),
        child: InkWell(
          onTap: onTap,
          child: Container(
              width: size.width,
              height: size.height * 0.07,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                gradient: appLinearGradient,
              ),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ).tr()),
        ),
      );

  // static buildBtnSubmitLoadingAnimation(
  //         {required BuildContext context,
  //         required Size size,
  //         bool isLoading = false,
  //         required String title,
  //         required VoidCallback onTap}) =>
  //     Padding(
  //       padding: EdgeInsets.all(size.width * 0.02),
  //       child: InkWell(
  //         onTap: onTap,
  //         child: Container(
  //             width: size.width,
  //             height: size.height * 0.07,
  //             alignment: Alignment.center,
  //             decoration: const BoxDecoration(
  //               borderRadius: BorderRadius.all(Radius.circular(12)),
  //               gradient: LinearGradient(
  //                 begin: Alignment.centerRight, // For RTL, start from right
  //                 end: Alignment.centerLeft, // For RTL, end at left
  //                 colors: [
  //                   linearGradieantColor1,
  //                   linearGradieantColor2,
  //                   linearGradieantColor3,
  //                 ],
  //                 stops: [0.0, 0.001, 0.8937],
  //               ),
  //             ),
  //             child: isLoading
  //                 ? Center(
  //                     child: AnimatedRotation(
  //                       turns:
  //                           1.0, // Rotation in terms of full turns (e.g., 1.0 = 360°)
  //                       duration: const Duration(
  //                           seconds: 3), // Duration of the rotation
  //                       child: Image.asset(
  //                         AppAssets.loadingIcon,
  //                         color: Colors.white,
  //                       ),
  //                     ),
  //                   )
  //                 : Text(
  //                     title,
  //                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
  //                         color: Colors.white, fontWeight: FontWeight.w700),
  //                   ).tr()),
  //       ),
  //     );

  static showProgress() => const Center(child: CircularProgressIndicator());

  static buildHeaderTitle({String? title, Color? color}) => Text(
        title ?? "",
        style: Theme.of(Get.context!).textTheme.titleLarge!.copyWith(
            color: titleTextColor,
            fontSize: 24,
            fontFamily: 'Arimo',
            fontWeight: FontWeight.w700),
      );

  static buildHeaderSubtitle({String? title}) => Text(
        title ?? "",
        style: Theme.of(Get.context!).textTheme.titleLarge!.copyWith(
              color: titleTextWhiteColor,
              fontSize: 18,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w400,
            ),
      );

  //spaces
  static verticalSpace({required double space}) => SizedBox(
      height: MediaQuery.of(navigationKey.currentContext!).size.height * space);
  static horizontalSpace({required double space}) => SizedBox(
      width: MediaQuery.of(navigationKey.currentContext!).size.width *
          space); //spaces

  static verticalSpaceContext(
          {required double space, required BuildContext context}) =>
      SizedBox(height: MediaQuery.of(context).size.height * space);
  static horizontalSpaceContext(
          {required double space, required BuildContext context}) =>
      SizedBox(width: MediaQuery.of(context).size.width * space);

  //appbar v2
  // static buildAppBar({String? title}) => AppBar(
  //       elevation: 0,
  //       // backgroundColor: Colors.black,
  //       automaticallyImplyLeading: false,
  //       leading: Padding(
  //           padding: EdgeInsets.all(
  //               MediaQuery.sizeOf(navigationKey.currentContext!).width * 0.05),
  //           child: InkWell(
  //             onTap: () => Get.back(),
  //             child: SvgPicture.asset(AppAssets.backarrowIcon,
  //                 width: 24, height: 24, color: titleTextColor),
  //           )),
  //       centerTitle: false,
  //       toolbarHeight:
  //           MediaQuery.sizeOf(navigationKey.currentContext!).height * 0.1,
  //       title: Text(title!,
  //           style: Theme.of(navigationKey.currentContext!)
  //               .textTheme
  //               .titleLarge!
  //               .copyWith(color: titleTextColor, fontWeight: FontWeight.bold)),
  //     );

  // static buildAppBarcontext({String? title, required BuildContext context}) =>
  //     AppBar(
  //       elevation: 0,
  //       // backgroundColor: Colors.black,
  //       automaticallyImplyLeading: false,
  //       leading: Padding(
  //           padding: EdgeInsets.all(MediaQuery.sizeOf(context).width * 0.05),
  //           child: InkWell(
  //             onTap: () => Get.back(),
  //             child: SvgPicture.asset(AppAssets.backarrowIcon,
  //                 width: 24, height: 24, color: titleTextColor),
  //           )),
  //       centerTitle: false,
  //       toolbarHeight: MediaQuery.sizeOf(context).height * 0.1,
  //       title: Text(title!,
  //           style: Theme.of(context)
  //               .textTheme
  //               .titleLarge!
  //               .copyWith(color: titleTextColor, fontWeight: FontWeight.bold)),
  //     );

  // //cachedNetwork image
  // static buildCachedImage(
  //         {required String imgUrl, double? height, double? width}) =>
  //     CachedNetworkImage(
  //         alignment: Alignment.center,
  //         imageUrl: imgUrl ?? WebService.tempImageUrl,
  //         width: width,
  //         height: height,
  //         fit: BoxFit.cover,
  //         progressIndicatorBuilder: (context, url, downloadProgress) =>
  //             const Center(child: CircularProgressIndicator()),
  //         errorWidget: (context, url, error) =>
  //             Icon(Icons.photo, size: height, color: kWhite));

  static buildCachedImageRounded(
          {required String imgUrl, double? height, double? width}) =>
      CachedNetworkImage(
          alignment: Alignment.center,
          imageUrl: imgUrl ?? WebService.tempImageUrl,

          imageBuilder: (context, imageProvider) => Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(16),
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) =>
              Icon(Icons.photo, size: height, color: kWhite));



}
