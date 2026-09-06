import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' as getx;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ink/src/data/model/check_subscription_model.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/image_picker.dart';
import 'package:ink/src/ui/screen/business_user/new_post.dart';
import 'package:ink/src/ui/widgets/button/custom_gradient_btn_widget.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/permissions.dart';
import 'package:photo_manager/photo_manager.dart';

class NoImageDataContent extends StatefulWidget {
  const NoImageDataContent({super.key});

  @override
  State<NoImageDataContent> createState() => _NoImageDataContentState();
}

class _NoImageDataContentState extends State<NoImageDataContent> {
  late String imageType = "0";
  bool isDataAlreadyLoad = false;
  CheckSubscriptionModel subscriptionModel =
      CheckSubscriptionModel(subscriptionStatus: 0);

  final picker = ImagePicker();

  @override
  void initState() {
    isDataAlreadyLoad = false;
    _initialization();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: signInButtonColor,
            child: SvgPicture.asset(
              AppAssets.cameraPlusIcon,
              height: 35,
              width: 35,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          const Text(
            'לא הועלו תמונות עדיין',
            style: TextStyle(
                color: titleTextWhiteColor,
                fontSize: 18,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          const Text(
            'העלו תמונות ושתפו את העבודה שלכם עם\n משתמשי האפליקציה.',
            style: TextStyle(
              color: titleTextWhiteColor,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.04),
          CustomGradientButtonWidget(
            width: MediaQuery.sizeOf(context).width * 0.4,
            onTap: () {
              _selectImage(context, subscriptionModel, ImageSource.gallery);
              // _showBottomSheet(context);
            },
            title: 'העלאת תמונה',
          ),
        ],
      ),
    );
  }

  // _showBottomSheet(BuildContext context) {
  //   return showModalBottomSheet<dynamic>(
  //       useRootNavigator: true,
  //       isScrollControlled: true,
  //       context: context,
  //       builder: (BuildContext context) {
  //         return Container(
  //           decoration: const BoxDecoration(
  //               color: signInButtonColor,
  //               borderRadius: BorderRadius.only(
  //                   topLeft: Radius.circular(16),
  //                   topRight: Radius.circular(16))),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               //close
  //               InkWell(
  //                   onTap: () => Navigator.of(context).pop(),
  //                   child: Padding(
  //                       padding: EdgeInsets.symmetric(
  //                           vertical: MediaQuery.of(context).size.height * 0.03,
  //                           horizontal:
  //                               MediaQuery.of(context).size.width * 0.4),
  //                       child: ClipRRect(
  //                         borderRadius: BorderRadius.circular(20.0),
  //                         child: Container(
  //                           margin: const EdgeInsetsDirectional.only(
  //                               start: 1.0, end: 1.0),
  //                           height: MediaQuery.of(context).size.height * 0.005,
  //                           width: MediaQuery.of(context).size.width * 0.2,
  //                           decoration: BoxDecoration(
  //                             color: kDivider,
  //                             borderRadius: BorderRadius.circular(
  //                                 10.0), // Adjust the radius as needed
  //                           ),
  //                         ),
  //                       ))),
  //
  //
  //               InkWell(
  //                 onTap: () async {
  //                   imageType = "0";
  //                   if (isDataAlreadyLoad) {
  //                     print(
  //                         "subscriptionModel ${subscriptionModel.subscriptionStatus.toString()}");
  //                     if (subscriptionModel.subscriptionStatus.toString() ==
  //                         "1") {
  //                       if (subscriptionModel.isPostLimit.toString() == "1" &&
  //                           subscriptionModel.isPremium.toString() != "1") {
  //                         Navigator.of(context).pop();
  //                         reachedImageLimitDialogCommon(
  //                             size: MediaQuery.of(context).size,
  //                             context: context,
  //                             title:
  //                                 subscriptionModel.popupTextTitle.toString(),
  //                             subtitle: subscriptionModel.popupTextSubtitle
  //                                 .toString());
  //
  //                         //You have reached the upload post limit
  //                       } else {
  //                         _selectImage(context,subscriptionModel, ImageSource.gallery);
  //                       }
  //                     } else {
  //                       notSubscriptionDialog(
  //                           context: context, title: "העלאת תמונה חסומה");
  //                     }
  //                   }
  //                 },
  //                 child: Container(
  //                   padding: const EdgeInsets.all(16),
  //                   width: double.infinity,
  //                   color: signInButtonColor,
  //                   height: MediaQuery.of(context).size.height * 0.08,
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.start,
  //                     crossAxisAlignment: CrossAxisAlignment.center,
  //                     children: [
  //                       SvgPicture.asset(AppAssets.photoIcon),
  //                       const SizedBox(width: 8),
  //                       const Text("העלאת תמונה",
  //                           style: TextStyle(
  //                               color: titleTextWhiteColor, fontSize: 18)),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //
  //               //sketch
  //               InkWell(
  //                 onTap: () async {
  //                   imageType = "0";
  //                   if (isDataAlreadyLoad) {
  //                     if (subscriptionModel.subscriptionStatus.toString() ==
  //                         "1") {
  //                       if (subscriptionModel.isPostLimit.toString() == "1" &&
  //                           subscriptionModel.isPremium.toString() != "1") {
  //                         Navigator.of(context).pop();
  //                         reachedImageLimitDialogCommon(
  //                             size: MediaQuery.of(context).size,
  //                             context: context,
  //                             title:
  //                                 subscriptionModel.popupTextTitle.toString(),
  //                             subtitle: subscriptionModel.popupTextSubtitle
  //                                 .toString());
  //                       } else {
  //                         PermissionStatus status =
  //                             await Permission.camera.status;
  //                         if (status.isGranted || status.isLimited) {
  //                           _selectImage(context,subscriptionModel, ImageSource.camera);
  //                         } else if (status.isDenied) {
  //                           await openAppSettings();
  //                         } else if (!status.isGranted) {
  //                           status = await Permission.camera.request();
  //                         }
  //                       }
  //                     } else {
  //                       notSubscriptionDialog(
  //                           context: context, title: "העלאת תמונה חסומה");
  //                     }
  //                   }
  //                 },
  //                 child: Container(
  //                   padding: const EdgeInsets.all(16),
  //                   width: double.infinity,
  //                   color: signInButtonColor,
  //                   height: MediaQuery.of(context).size.height * 0.09,
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.start,
  //                     crossAxisAlignment: CrossAxisAlignment.center,
  //                     children: [
  //                       SvgPicture.asset(AppAssets.cameraIcon),
  //                       const SizedBox(width: 8),
  //                       const Text("צילום תמונה",
  //                           style: TextStyle(
  //                               color: titleTextWhiteColor, fontSize: 18)),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //               if(Platform.isAndroid) SizedBox(
  //                 height: MediaQuery.of(context).size.height * 0.07,
  //               )
  //
  //             ],
  //           ),
  //         );
  //       });
  // }

  void _selectImage(context, subscriptionModel, ImageSource source) async {
    final hasPermission = await ensurePhotoPermission();

    if (!hasPermission) {
      return; // ⛔ STOP if denied
    }
    List<File> files = [];
    // Navigator.of(context).pop();
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
        imageType: imageType));

    // if (source == ImageSource.gallery) {
    //   if (!(await checkPermission())) await requestPermission();
    // }
    //
    // Navigator.of(context).pop();
    //
    // List<XFile>? pickedFiles = [];
    //
    // if (source == ImageSource.camera) {
    //   // Single image from camera
    //   final pickedFile = await picker.pickImage(
    //     source: ImageSource.camera,
    //     imageQuality: 80,
    //   );
    //   if (pickedFile != null) pickedFiles.add(pickedFile);
    // } else {
    //   // MULTIPLE IMAGES FROM GALLERY
    //   pickedFiles = await picker.pickMultiImage(
    //     imageQuality: 80,
    //   );
    //
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
    // // Convert XFile → File
    // final files = pickedFiles.map((e) => File(e.path)).toList();
    //
    // getx.Get.to(() => SketchImageScreen(
    //   subscriptionModel: subscriptionModel,
    //   pickedFiles: files,        // 👈 PASS LIST OF IMAGES
    //   imageType: imageType,
    //   isProfileUpload: true,
    // ));
  }

  void _initialization() {
    Network.checkSubscriptionApi(isAddPost: 1).then((value) {
      if (value != false) {
        subscriptionModel = CheckSubscriptionModel.fromJson(value);
        if (mounted) {
          setState(() {
            isDataAlreadyLoad = true;
          });
        }
      }
    });
  }
}
