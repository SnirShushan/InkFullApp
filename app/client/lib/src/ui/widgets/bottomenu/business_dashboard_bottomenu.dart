import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ink/src/controller/bussiness_dashboard_controller.dart';
import 'package:ink/src/data/model/check_subscription_model.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/business_dashboard.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/bussinessdashboard_binding.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/image_picker.dart';
import 'package:ink/src/ui/screen/business_user/new_post.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/permissions.dart';
import 'package:ink/src/utils/webService.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

class BusinessDashboardBottomBar extends StatelessWidget {
  final int currentIndex;

  BusinessDashboardBottomBar({super.key, required this.currentIndex});

  final BusinessDashBoardController _businessDashBoard =
      Get.put(BusinessDashBoardController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BottomNavigationBar(
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) async {
        _businessDashBoard.changeTabIndex(index);
        Get.offAll(() => BusinessDashBoard(initialIndex: index),
            binding: BusinessDashBoardBinding());
      },
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedItemColor: defaultWhite,
      unselectedItemColor: defaultGrey,
      backgroundColor: Colors.black,
      items: [
        _bottomNavigationBarItem(
            size: size,
            iconName: AppAssets.homedashboard,
            activeIconName: AppAssets.home_filled_dashboard,
            label: 'בית'),
        _bottomNavigationBarItem(
            size: size,
            iconName: AppAssets.searchdashboard,
            activeIconName: AppAssets.search_filled_dashboard,
            label: 'השראה'),
        buildAddIconBtn(context, _businessDashBoard, size), //inspiration
        _bottomNavigationBarItem(
            size: size,
            iconName: AppAssets.artistsdashboard,
            activeIconName: AppAssets.artists_filled_dashboard,
            label: 'מקעקעים'), //notification
        _bottomNavigationBarItem(
            size: size,
            iconName: AppAssets.profiledashboard,
            activeIconName: AppAssets.profile_filled_dashboard,
            label: 'פרופיל'),
      ],
    );
  }

  _bottomNavigationBarItem(
      {required size,
      required String iconName,
      required String activeIconName,
      required String label}) {
    return BottomNavigationBarItem(
      icon: SizedBox(
          height: size.width * 0.07,
          width: size.width * 0.07,
          child: SvgPicture.asset(
            iconName,
          )),
      label: label,
      activeIcon: SizedBox(
          height: size.width * 0.07,
          width: size.width * 0.07,
          child: SvgPicture.asset(
            activeIconName,
          )),
    );
  }

  //bottom navigation bar item button
  buildAddIconBtn(context, controller, size) => BottomNavigationBarItem(
      icon: InkWell(
          splashColor: Colors.grey,
          onTap: () async {
            _showCoverOrProfileImgUpload(
                context: context, controller: controller);
            // controller.changeTabIndex(2);
          },
          child: SizedBox(
              height: size.width * 0.1,
              width: size.width,
              child: SvgPicture.asset(AppAssets.uploaddashboard))),
      label: "",
      backgroundColor: defaultBlack);

  _showCoverOrProfileImgUpload(
      {required BuildContext context,
      required BusinessDashBoardController controller}) {
    var size = MediaQuery.of(context).size;
    return showModalBottomSheet<dynamic>(
        useRootNavigator: true,
        isScrollControlled: false,
        context: context,
        builder: (BuildContext bc) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: Platform.isIOS
                  ? MediaQuery.of(context).viewInsets.bottom + 102.0
                  : MediaQuery.of(context).viewInsets.bottom + 62.0,
            ),
            child: Container(
              decoration: const BoxDecoration(
                  color: signInButtonColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //close
                  SizedBox(height: size.height * 0.03),
                  InkWell(
                      onTap: () => Get.back(),
                      child: Container(
                        width: size.width * 0.2,
                        height: size.height * 0.007,
                        decoration: BoxDecoration(
                          color: textEditingColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      )),
                  SizedBox(height: size.height * 0.02),

                  //sketch
                  InkWell(
                    onTap: () async {
                      controller.imageType = "0";

                      Network.checkSubscriptionApi(isAddPost: 1).then((value) {
                        if (value != false) {
                          CheckSubscriptionModel subscriptionModel =
                              CheckSubscriptionModel.fromJson(value);

                          if (subscriptionModel.subscriptionStatus.toString() ==
                              "1") {
                            if (subscriptionModel.isPostLimit.toString() ==
                                    "1" &&
                                subscriptionModel.isPremium.toString() != "1") {
                              Get.back();
                              reachedImageLimitDialogCommon(
                                  size: MediaQuery.of(context).size,
                                  context: context,
                                  title: subscriptionModel.popupTextTitle
                                      .toString(),
                                  subtitle: subscriptionModel.popupTextSubtitle
                                      .toString());

                              //You have reached the upload post limit
                            } else {
                              _selectImage(
                                  context: context,
                                  subscriptionModel: subscriptionModel,
                                  controller: controller,
                                  source: ImageSource.gallery);
                            }
                          } else {
                            needSubscriptionUploadDialog(context:context);
                          }
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      color: signInButtonColor,
                      height: MediaQuery.of(context).size.height * 0.08,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(AppAssets.photoIcon),
                          // Icon(Icons.photo_outlined,
                          //     size: 24, color: titleTextWhiteColor),
                          const SizedBox(width: 8),
                          const Text("העלאת תמונה",
                              style: TextStyle(
                                  color: titleTextWhiteColor, fontSize: 18)),
                        ],
                      ),
                    ),
                  ),

                  Visibility(
                    visible: WebService.isEnableCameraUpload,
                    child: InkWell(
                      onTap: () async {
                        controller.imageType = "0";
                        Network.checkSubscriptionApi(isAddPost: 1)
                            .then((value) async {
                          if (value != false) {
                            CheckSubscriptionModel subscriptionModel =
                                CheckSubscriptionModel.fromJson(value);
                            if (subscriptionModel.subscriptionStatus.toString() ==
                                "1") {
                              if (subscriptionModel.isPostLimit.toString() ==
                                  "1" &&
                                  subscriptionModel.isPremium.toString() != "1") {
                                Get.back();
                                reachedImageLimitDialogCommon(
                                    size: MediaQuery.of(context).size,
                                    context: context,
                                    title: subscriptionModel.popupTextTitle
                                        .toString(),
                                    subtitle: subscriptionModel.popupTextSubtitle
                                        .toString());

                                //You have reached the upload post limit
                              } else {
                                PermissionStatus status =
                                    await Permission.camera.status;
                                if (status.isGranted || status.isLimited) {
                                  _selectImage(
                                      subscriptionModel: subscriptionModel,
                                      context: context,
                                      controller: controller,
                                      source: ImageSource.camera);
                                } else if (status.isDenied) {
                                  await openAppSettings();
                                } else if (!status.isGranted) {
                                  status = await Permission.camera.request();
                                }
                              }
                            } else {
                              needSubscriptionUploadDialog(context:context);
                            }
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        width: double.infinity,
                        color: signInButtonColor,
                        height: MediaQuery.of(context).size.height * 0.09,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(AppAssets.cameraIcon),
                            const SizedBox(width: 8),
                            const Text("צילום תמונה",
                                style: TextStyle(
                                    color: titleTextWhiteColor, fontSize: 18)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      controller.imageType = "1";
                      Network.checkSubscriptionApi(isAddPost: 1).then((value) {
                        if (value != false) {
                          CheckSubscriptionModel subscriptionModel =
                              CheckSubscriptionModel.fromJson(value);

                          if (subscriptionModel.subscriptionStatus.toString() ==
                                  "1" &&
                              subscriptionModel.isPremium.toString() == "1") {
                            if (subscriptionModel.isPostLimit.toString() ==
                                "1" &&
                                subscriptionModel.isPremium.toString() != "1") {
                              Get.back();
                              reachedImageLimitDialogCommon(
                                  size: MediaQuery.of(context).size,
                                  context: context,
                                  title: subscriptionModel.popupTextTitle
                                      .toString(),
                                  subtitle: subscriptionModel.popupTextSubtitle
                                      .toString());

                              //You have reached the upload post limit
                            } else {
                              _selectImage(
                                subscriptionModel: subscriptionModel,
                                  context: context,
                                  controller: controller,
                                  source: ImageSource.gallery);
                            }
                          } else {
                            needSubscriptionUploadDialog(context:context,backCurrentScreen: true);
                          }
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      color: signInButtonColor,
                      height: MediaQuery.of(context).size.height * 0.08,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(AppAssets.flashIcon),
                          const SizedBox(width: 8),
                          const Text("העלאת סקיצה",
                              style: TextStyle(
                                  color: titleTextWhiteColor, fontSize: 18)),
                        ],
                      ),
                    ),
                  ),

              Visibility(
                  visible: WebService.isEnableCameraUpload,
                    child: InkWell(
                      onTap: () async {
                        controller.imageType = "1";
                        Network.checkSubscriptionApi(isAddPost: 1)
                            .then((value) async {
                          if (value != false) {
                            CheckSubscriptionModel subscriptionModel =
                                CheckSubscriptionModel.fromJson(value);
                            if (subscriptionModel.subscriptionStatus.toString() ==
                                    "1") {
                              if (subscriptionModel.isPostLimit.toString() ==
                                  "1" &&
                                  subscriptionModel.isPremium.toString() != "1") {
                                Get.back();
                                reachedImageLimitDialogCommon(
                                    size: MediaQuery.of(context).size,
                                    context: context,
                                    title: subscriptionModel.popupTextTitle
                                        .toString(),
                                    subtitle: subscriptionModel.popupTextSubtitle
                                        .toString());

                                //You have reached the upload post limit
                              } else {
                                PermissionStatus status =
                                    await Permission.camera.status;
                                if (status.isGranted || status.isLimited) {
                                  _selectImage(
                                      context: context,
                                      subscriptionModel:subscriptionModel,
                                      controller: controller,
                                      source: ImageSource.camera);
                                } else if (status.isDenied) {
                                  await openAppSettings();
                                } else if (!status.isGranted) {
                                  status = await Permission.camera.request();
                                }
                              }
                            } else {

                              needSubscriptionUploadDialog(context:context,backCurrentScreen: true);
                            }
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        width: double.infinity,
                        color: signInButtonColor,
                        height: MediaQuery.of(context).size.height * 0.09,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(AppAssets.cameraFlashIcon),
                            const SizedBox(width: 8),
                            const Text("צילום סקיצה",
                                style: TextStyle(
                                    color: titleTextWhiteColor, fontSize: 18)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  )
                ],
              ),
            ),
          );
        });
  }

  // _selectImage(
  //     {required BuildContext context,
  //     required BusinessDashBoardController controller,
  //       required CheckSubscriptionModel  subscriptionModel,
  //     source}) async {
  //   final picker = ImagePicker();
  //   if (source == ImageSource.gallery) {
  //     if (!(await checkPermission())) await requestPermission();
  //   }
  //   Navigator.of(context).pop();
  //   final pickedFile = await picker.pickImage(
  //     source: source,
  //     imageQuality: 70,
  //   );
  //   if (pickedFile == null) return;
  //   final file = File(pickedFile.path);
  //   Get.to(() =>
  //       SketchImageScreen(subscriptionModel:subscriptionModel,pickedFile: file, imageType: controller.imageType));
  // }

  _selectImage({
    required BuildContext context,
    required BusinessDashBoardController controller,
    required CheckSubscriptionModel subscriptionModel,
    ImageSource? source,
  }) async {

    final hasPermission = await ensurePhotoPermission();

    if (!hasPermission) {
      return; // ⛔ STOP if denied
    }

    List<File> files = [];
    Navigator.of(context).pop();
    final result = await Get.to(const CustomImagePicker(maxImages: 3));
    if (result == null) return;
    final List<AssetEntity> filesFromPicker = result;
    files.clear();
    final pickedImages =
    await Future.wait(filesFromPicker.map((e) => e.file));
    files.addAll(pickedImages.whereType<File>());
    if (files.isEmpty) return;
    Get.to(() => SketchImageScreen(
        pickedFiles: files,
        subscriptionModel: subscriptionModel,
        imageType: controller.imageType));


    // final picker = ImagePicker();
    //
    // if (source == ImageSource.gallery) {
    //   if ((await checkPermission())) await requestPermission();
    // }
    //
    // Navigator.of(context).pop();
    //
    // List<XFile>? pickedFiles = [];
    //
    // if (source == ImageSource.camera) {
    //   final file = await picker.pickImage(
    //     source: ImageSource.camera,
    //     imageQuality: 70,
    //   );
    //   if (file != null) pickedFiles.add(file);
    //
    // } else {
    //   pickedFiles = await picker.pickMultiImage(
    //     imageQuality: 70,
    //   );
    //
    //
    //   // ⭐ LIMIT TO MAX 3 IMAGES
    //   if (pickedFiles.length > 3) {
    //     pickedFiles = pickedFiles.take(3).toList();
    //
    //
    //     displayMessageIcon(
    //         message: "לא ניתן לבחור יותר מ-3 תמונות.",
    //         color: errorColor,
    //         snackposition: SnackPosition.BOTTOM,
    //         imageData: AppAssets.errorIcon);
    //     return; // ❌ Stop navigation
    //   }
    // }
    //
    // if (pickedFiles.isEmpty) return;
    //
    // final files = pickedFiles.map((img) => File(img.path)).toList();
    //
    // Get.to(() => SketchImageScreen(
    //   pickedFiles: files,
    //   subscriptionModel: subscriptionModel,
    //   imageType: controller.imageType,
    // ));
  }
}
