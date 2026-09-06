import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ink/src/data/model/check_subscription_model.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/image_picker.dart';
import 'package:ink/src/ui/screen/inspiration/inspirations_screen.dart';
import 'package:ink/src/ui/widgets/fixed_ad_card.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../../controller/bussiness_dashboard_controller.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/common.dart';
import '../../../../utils/permissions.dart';
import '../../../../utils/webService.dart';
import '../../../widgets/unfocus_widget.dart';
import '../../bussiness_profiles/screen_bussiness_profiles.dart';
import '../../home/homescreen.dart';
import '../../profile/currentUserProfile.dart';
import '../new_post.dart';

enum ImageFrom { gallery, camera }

class BusinessDashBoard extends StatelessWidget {
  final int initialIndex;

  BusinessDashBoard({super.key, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return GetBuilder<BusinessDashBoardController>(builder: (controller) {
      // Run only once when screen first builds
      if (controller.init.value) {
        controller.init.value = false;
        controller.changeTabIndex(initialIndex);
      }

      return UnFocusWidget(
          child: Obx(() => SafeArea(
                child: controller.isFixedAdClosed.value
                    ? Scaffold(
                        backgroundColor: scaffoldBg,
                        body: Obx(() => FixedAdCard(
                            ad: WebService.startupImgUrl +
                                controller.startupImageDashboard.value,
                            onClose: () {
                              controller.isFixedAdClosed.value = false;
                              controller.onAdClose();
                            })),
                      )
                    : Scaffold(
                        body:
                            IndexedStack(index: controller.tabIndex, children: [
                          //home screen
                          const HomeScreen(),
                          // Scaffold(),
                          //business profiles
                          //notification
                          InspirationScreen(),

                          const SizedBox.shrink(),
                          BusinessProfiles(),
                          //profile
                          Profilescreen(
                              key: const PageStorageKey("profile"),
                              isDrawerOpened:
                                  WebService.isNotificationBackPressed
                                      ? true
                                      : false),
                        ]),
                        bottomNavigationBar: BottomNavigationBar(
                            elevation: 0,
                            type: BottomNavigationBarType.fixed,
                            currentIndex: controller.tabIndex,
                            onTap: controller.changeTabIndex,
                            showSelectedLabels: true,
                            showUnselectedLabels: true,
                            selectedItemColor: titleTextWhiteColor,
                            unselectedItemColor: hintTextColor,
                            backgroundColor: Colors.black,
                            items: [
                              bottomNavigationBarItem(
                                  size: size,
                                  iconName: AppAssets.homedashboard,
                                  activeIconName:
                                      AppAssets.home_filled_dashboard,
                                  label: 'בית'), //Home
                              bottomNavigationBarItem(
                                  size: size,
                                  iconName: AppAssets.searchdashboard,
                                  activeIconName:
                                      AppAssets.search_filled_dashboard,
                                  label: 'השראה'), //favorites
                              buildAddIconBtn(
                                  context: context,
                                  controller: controller,
                                  size: size),
                              bottomNavigationBarItem(
                                  size: size,
                                  iconName: AppAssets.artistsdashboard,
                                  activeIconName:
                                      AppAssets.artists_filled_dashboard,
                                  label: 'מקעקעים'), //notification
                              bottomNavigationBarItem(
                                  size: size,
                                  iconName: AppAssets.profiledashboard,
                                  activeIconName:
                                      AppAssets.profile_filled_dashboard,
                                  label: 'פרופיל')
                            ])),
              )));
    });
  }

  bottomNavigationBarItem(
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
  buildAddIconBtn(
          {required BuildContext context,
          required BusinessDashBoardController controller,
          required Size size}) =>
      BottomNavigationBarItem(
          icon: Obx(() => controller.isImageLoading.value == true
              ? const CircularProgressIndicator()
              : InkWell(
                  splashColor: Colors.grey,
                  onTap: () async {
                    controller.isImageLoading.value = true;

                    Network.checkSubscriptionApi(isAddPost: 1).then((value) {
                      if (value != false && value != null) {
                        try {
                          final subscriptionModel =
                              CheckSubscriptionModel.fromJson(value);

                          if (subscriptionModel.subscriptionStatus.toString() ==
                              "1") {
                            if (subscriptionModel.isPostLimit.toString() ==
                                    "1" &&
                                subscriptionModel.isPremium.toString() != "1") {
                              controller.isImageLoading.value = false;
                              Get.back();
                              reachedImageLimitDialogCommon(
                                size: MediaQuery.of(context).size,
                                context: context,
                                title:
                                    subscriptionModel.popupTextTitle.toString(),
                                subtitle: subscriptionModel.popupTextSubtitle
                                    .toString(),
                              );
                            } else {
                              controller.isImageLoading.value = false;
                              _showCoverOrProfileImgUpload(
                                context: context,
                                controller: controller,
                                subscriptionModel:
                                    subscriptionModel, // Use the already parsed model
                              );
                            }
                          } else {
                            controller.isImageLoading.value = false;
                            needSubscriptionUploadDialog(context: context);
                          }
                        } catch (e) {
                          print('Error parsing subscription model: $e');
                          controller.isImageLoading.value = false;
                        }
                      } else {
                        print('Value is false or null: $value'); // Debug print
                        controller.isImageLoading.value = false;
                      }
                    }).catchError((error) {
                      print('API Error: $error'); // Debug print
                      controller.isImageLoading.value = false;
                    });
                    // controller.changeTabIndex(2);
                  },
                  // onTap: () async => await controller.changeTabIndex(2),
                  child: SizedBox(
                      height: size.width * 0.1,
                      width: size.width,
                      child: SvgPicture.asset(AppAssets.uploaddashboard)))),
          label: "",
          backgroundColor: defaultBlack);

  //is tattoo or sketch
  _showCoverOrProfileImgUpload(
      {required BuildContext context,
      required CheckSubscriptionModel subscriptionModel,
      required BusinessDashBoardController controller}) {
    var size = MediaQuery.of(context).size;
    return showModalBottomSheet<dynamic>(
        useRootNavigator: true,
        isScrollControlled: false,
        context: context,
        builder: (BuildContext bc) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom +
                  (Platform.isIOS ? 102.0 : 62.0),
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

                      _selectImage(
                          subscriptionModel: subscriptionModel,
                          context: context,
                          controller: controller,
                          source: ImageSource.gallery);
                    },
                    child: buildBottomBarIconTitleMethod(
                        context: context,
                        title: "העלאת קעקוע",
                        // title: "העלאת תמונה",
                        imageName: AppAssets.photoIcon),
                  ),

                  Visibility(
                    visible: WebService.isEnableCameraUpload,
                    child: InkWell(
                      onTap: () async {
                        controller.imageType = "0";
                        PermissionStatus status =
                            await Permission.camera.status;
                        if (status.isGranted || status.isLimited) {
                          _selectImage(
                              subscriptionModel: subscriptionModel,
                              context: context,
                              controller: controller,
                              source: ImageSource.camera);
                        } else if (status.isDenied) {
                          status = await Permission.camera.request();
                        } else {
                          await openAppSettings();
                        }
                      },
                      child: buildBottomBarIconTitleMethod(
                          context: context,
                          title: "צילום תמונה",
                          imageName: AppAssets.cameraIcon),
                    ),
                  ),
                  InkWell(
                      onTap: () async {
                        controller.imageType = "1";
                        if (subscriptionModel.subscriptionStatus.toString() ==
                                "1" &&
                            subscriptionModel.isPremium.toString() == "1") {
                          _selectImage(
                              subscriptionModel: subscriptionModel,
                              context: context,
                              controller: controller,
                              source: ImageSource.gallery);
                        } else {
                          needSubscriptionUploadDialog(context: context);
                        }
                      },
                      child: buildBottomBarIconTitleMethod(
                          context: context,
                          title: "העלאת סקיצה",
                          imageName: AppAssets.flashIcon)),

                  Visibility(
                    visible: WebService.isEnableCameraUpload,
                    child: InkWell(
                      onTap: () async {
                        if (subscriptionModel.subscriptionStatus.toString() ==
                                "1" &&
                            subscriptionModel.isPremium.toString() == "1") {
                          PermissionStatus status =
                              await Permission.camera.status;
                          if (status.isGranted || status.isLimited) {
                            controller.imageType = "1";
                            _selectImage(
                                context: context,
                                subscriptionModel: subscriptionModel,
                                controller: controller,
                                source: ImageSource.camera);
                          } else if (status.isDenied) {
                            status = await Permission.camera.request();
                          } else {
                            await openAppSettings();
                          }
                        } else {
                          needSubscriptionUploadDialog(context: context);
                        }
                      },
                      child: buildBottomBarIconTitleMethod(
                          imageName: AppAssets.cameraFlashIcon,
                          context: context,
                          title: "צילום סקיצה"),
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

  Container buildBottomBarIconTitleMethod(
      {required BuildContext context,
      required String title,
      required String imageName}) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      color: signInButtonColor,
      height: MediaQuery.of(context).size.height * 0.08,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(imageName),
          // Icon(Icons.photo_outlined,
          //     size: 24, color: titleTextWhiteColor),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(color: titleTextWhiteColor, fontSize: 18)),
        ],
      ),
    );
  }

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

    // if (!WebService.isEnableCameraUpload) {
    List<File> files = [];
    Navigator.of(context).pop();
    final result = await Get.to(const CustomImagePicker(maxImages: 3));
    if (result == null) return;
    final List<AssetEntity> filesFromPicker = result;
    files.clear();
    final pickedImages = await Future.wait(filesFromPicker.map((e) => e.file));
    files.addAll(pickedImages.whereType<File>());
    if (files.isEmpty) return;
    Get.to(() => SketchImageScreen(
        pickedFiles: files,
        subscriptionModel: subscriptionModel,
        imageType: controller.imageType));
    // } else {
    //   final picker = ImagePicker();
    //

    //
    //   Navigator.of(context).pop();
    //
    //   List<XFile>? pickedFiles = [];
    //
    //   if (source == ImageSource.camera) {
    //     final file = await picker.pickImage(
    //       source: ImageSource.camera,
    //       imageQuality: 70,
    //     );
    //     if (file != null) pickedFiles.add(file);
    //
    //   } else {
    //     pickedFiles = await picker.pickMultiImage(
    //       imageQuality: 70,
    //     );
    //
    //
    //     // ⭐ LIMIT TO MAX 3 IMAGES
    //     if (pickedFiles.length > 3) {
    //       pickedFiles = pickedFiles.take(3).toList();
    //
    //
    //       displayMessageIcon(
    //           message: "לא ניתן לבחור יותר מ-3 תמונות.",
    //           color: errorColor,
    //           snackposition: SnackPosition.BOTTOM,
    //           imageData: AppAssets.errorIcon);
    //       return; // ❌ Stop navigation
    //     }
    //   }
    //
    //   if (pickedFiles.isEmpty) return;
    //
    //   final files = pickedFiles.map((img) => File(img.path)).toList();
    //
    //   Get.to(() => SketchImageScreen(
    //     pickedFiles: files,
    //     subscriptionModel: subscriptionModel,
    //     imageType: controller.imageType,
    //   ));
    // }
  }
}
