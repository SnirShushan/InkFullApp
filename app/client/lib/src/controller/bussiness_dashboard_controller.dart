import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ink/src/controller/StartupController.dart';
import 'package:ink/src/controller/myPostController.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/ui/screen/home/controller/home_screen_controller.dart';
import 'package:ink/src/ui/screen/inspiration/controller/inspiration_controller.dart';
import 'package:ink/src/ui/screen/inspiration/controller/random_pagination.dart';
import 'package:ink/src/utils/shared_preference_helper.dart';
import 'package:ink/src/utils/webService.dart';

import 'businessProfilecontroller.dart';

class BusinessDashBoardController extends GetxController {
  var tabIndex = 0;
  List<int> subCheckList = [1, 2];
  bool isNotificationInit = false;
  bool isHomeInit = false;
  bool isProfileInit = false;
  bool isBusinessListInit = false;
  RxBool isImageLoading = false.obs;
  RxBool init = true.obs;
  RxString startupImageDashboard = "".obs;
  RxString tempimageType = "".obs;
  bool isLoading = false;

  //init controllers

  @override
  void onInit() {
    setAdClosed();

    super.onInit();
  }

  // Future getBusinessList() async =>
  //     await businessProfileController.getBusinessList(0, "", "", "", "", "");

  // Future checkSubscription() async =>
  //     await startupController.checkSubscription();

  //change index
  void changeTabIndex(int index) async {
    try {
      switch (index) {
        case 2:
          break;
        case 3:
          if (!WebService.isSplashHomeScreen) {
            WebService.isSplashHomeScreen = true;
          }
          if (isLoading) return;
          isLoading = true;
          try {
            tabIndex = index;
            final isApiHoldTime =
                await SharedPreferencesHelper.getBusinessScreenApiHoldTime();

            if (isApiHoldTime != null) {
              final DateTime current = DateTime.now();
              final DateTime closedDate = DateTime.parse(isApiHoldTime);
              final difference = current.difference(closedDate).inMinutes;
              if (difference >= 10) {
                getBusinessData();
              }
            } else {
              getBusinessData();
            }
          } finally {
            isLoading = false;
          }
          break;
        case 4:
          if (!WebService.isSplashHomeScreen) {
            WebService.isSplashHomeScreen = true;
          }
          if (isLoading) return;
          isLoading = true;
          tabIndex = index;

          final MyPostsController myPostsController =
              Get.put(MyPostsController());
          myPostsController.startPost = 0.obs;
          myPostsController.hasMorePosts.value = false;
          myPostsController.isDataLoading.value = true;

          try {
            if (isProfileInit == false) {
              isProfileInit = true;
            }
            bool isConnected = await WebService.checkConnectionNoMsg();
            if (!isConnected) return;

            myPostsController.getMyPosts();
          } finally {
            isLoading = false;
          }
          break;

        case 1:
          if (!WebService.isSplashHomeScreen) {
            WebService.isSplashHomeScreen = true;
          }
          tabIndex = index;
          if (WebService.randomPagination != "0" &&
              WebService.randomPagination != null) {
            final isApiHoldTime =
                await SharedPreferencesHelper.getInspirationApiHoldTime();

            if (isApiHoldTime != null) {
              final DateTime current = DateTime.now();
              final DateTime closedDate = DateTime.parse(isApiHoldTime);
              final difference = current.difference(closedDate).inMinutes;
              if (difference >= 10) {
                getInspirationData();
              }
            } else {
              getInspirationData();
            }
          } else {
            Network.getPostCountApi().then((value) async {
              if (WebService.randomPagination != "0" &&
                  WebService.randomPagination != null) {
                final isApiHoldTime =
                    await SharedPreferencesHelper.getInspirationApiHoldTime();

                if (isApiHoldTime != null) {
                  final DateTime current = DateTime.now();
                  final DateTime closedDate = DateTime.parse(isApiHoldTime);
                  final difference = current.difference(closedDate).inMinutes;
                  if (difference >= 10) {
                    getInspirationData();
                  }
                } else {
                  getInspirationData();
                }
              }
            });
          }
          break;
        default:
          tabIndex = index;
          final isApiHoldTime =
              await SharedPreferencesHelper.getHomeApiHoldTime();

          if (isApiHoldTime != null) {
            final DateTime current = DateTime.now();
            final DateTime closedDate = DateTime.parse(isApiHoldTime);
            final difference = current.difference(closedDate).inMinutes;
            if (difference >= 10) {
              getHomeData();
            }
          } else {
            getHomeData();
          }
          break;
      }

      notifyChildrens();
    } finally {
      update();
    }
  }

  // ========== Ad =========
  RxBool isFixedAdClosed = false.obs;

  //on close ad
  void onAdClose() async {
    await WebService.setAdClosed();
    isFixedAdClosed.value = false;
    update();
  }

  //init add
  Future setAdClosed() async {
    final isAdClosed = await WebService.getAdClosed();

    if (isAdClosed != null) {
      final DateTime current = DateTime.now();
      final DateTime closedDate = DateTime.parse(isAdClosed);
      final difference = current.difference(closedDate).inDays;

      if (difference >= 6) {
        final StartupController startupController =
            Get.put(StartupController());
        startupController.getStartupImage6().then((value) =>
            startupImageDashboard.value =
                startupController.startup_image.value);
        isFixedAdClosed.value = true;
        update();
      } else {
        isFixedAdClosed.value = false;
      }
    } else {
      final StartupController startupController = Get.put(StartupController());
      startupController.getStartupImage().then((value) =>
          startupImageDashboard.value = startupController.startup_image.value);
      isFixedAdClosed.value = true;
      update();
    }
  }

  //========== Add new post ======
  final picker = ImagePicker();
  late String imageType;
  late String imageId;
  late String styles;
  late String imageDescription;
  late String studioUid;
  late String artistUid;

  Future<void> getHomeData() async {
    final homeScreenController = Get.put(HomeScreenController());

    homeScreenController.stylePosts.clear();
    homeScreenController.getPostsIds = "";
    homeScreenController.stylename.value = "";
    homeScreenController.stylenameheb.value = "";
    homeScreenController.scrollController.animateTo(
      0.0,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
    homeScreenController.scrollController.jumpTo(0.0);
    homeScreenController.getHomeController();
    await SharedPreferencesHelper.saveHomeApiHoldTime();
  }

  Future<void> getInspirationData() async {
    final inspirationController = Get.put(InspirationController());
    inspirationController.pagination = RandomPagination(
        totalPosts: int.parse(WebService.randomPagination ?? "0"), limit: 20);
    inspirationController.postsInspiration.clear();
    inspirationController.isRandomAutoLoad.value = true;
    inspirationController.startInspiration.value = 0;
    inspirationController.postsInspiration.clear();
    inspirationController.searchController.text = "";
    inspirationController.styles = "";
    if(WebService.tempHomeselectstylelist){
      WebService.tempHomeselectstylelist=false;
    }else{
      WebService.selectstylelist = [];

    }
    inspirationController.selectedStyles?.clear();
    inspirationController.isStyleEnabled.value = false;
    inspirationController.isselected = "מומלצים עבורכם".obs;
    inspirationController.getInspirationController();
    await SharedPreferencesHelper.saveInspirationApiHoldTime();
  }

  Future<void> getBusinessData() async {
    final BusinessProfileController businessProfileController =
        Get.put(BusinessProfileController());
    businessProfileController.startBusinessProfile.value = 0;
    businessProfileController.businessList.clear();
    businessProfileController.addressController.text = "";
    businessProfileController.lat.value = "";
    businessProfileController.lng.value = "";
    businessProfileController.searchController.text = "";
    businessProfileController.selectedStyles?.clear();
    businessProfileController.isRecommended.value = true;
    businessProfileController.isClosest.value = false;
    businessProfileController.isPopularEnabled.value = false;
    businessProfileController.isStyleEnabled.value = false;
    businessProfileController.isCurrentLocationSelected.value = false;
    businessProfileController.isAsPerLocation.value = false;
    businessProfileController.isselected = "מומלצים עבורכם".obs;
    // await getBusinessList();

    await businessProfileController.getBusinessList();
    await SharedPreferencesHelper.saveBusinessScreenApiHoldTime();
  }

// _selectImage(context, source) async {
//   if (source == ImageSource.gallery) {
//     if (!(await checkPermission())) await requestPermission();
//   }
//   Navigator.of(context).pop();
//   final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
//   if (pickedFile == null) return;
//   final file = File(pickedFile.path);
//   Get.to(() => SketchImageScreen(pickedFile: file, imageType: imageType));
// }

//is tattoo or sketch
//   showCoverOrProfileImgUpload(BuildContext context) {
//     return showModalBottomSheet<dynamic>(
//         useRootNavigator: true,
//         isScrollControlled: true,
//         context: context,
//         builder: (BuildContext bc) {
//           return Container(
//             decoration: const BoxDecoration(
//                 color: appbarBg,
//                 borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(16),
//                     topRight: Radius.circular(16))),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 //close
//                 InkWell(
//                     onTap: () => Get.back(),
//                     child: Padding(
//                         padding: EdgeInsets.symmetric(
//                             vertical: MediaQuery.of(context).size.height * 0.03,
//                             horizontal:
//                                 MediaQuery.of(context).size.width * 0.4),
//                         child: Container(
//                             margin: const EdgeInsetsDirectional.only(
//                                 start: 1.0, end: 1.0),
//                             height: MediaQuery.of(context).size.height * 0.005,
//                             width: MediaQuery.of(context).size.width * 0.2,
//                             color: kDivider))),
//
//                 //sketch
//                 InkWell(
//                   onTap: () async {
//                     imageType = "0";
//                     if (startupController.subscriptionModel.subscriptionStatus
//                             .toString() ==
//                         "1") {
//                       if (startupController.subscriptionModel.isPostLimit
//                               .toString() ==
//                           "1") {
//                         Get.back();
//
//                         reachedImageLimitDialog(
//                             size: MediaQuery.of(context).size,
//                             context: context,
//                             title: startupController
//                                 .subscriptionModel.popupTextTitle
//                                 .toString(),
//                             subtitle: startupController
//                                 .subscriptionModel.popupTextSubtitle
//                                 .toString());
//
//                         //You have reached the upload post limit
//                       } else {
//                         _showAddPostDialogue(context);
//                       }
//                     } else {
//                       needSubscriptionDialog(context);
//                     }
//                   },
//                   child: Container(
//                     width: double.infinity,
//                     color: Colors.white,
//                     height: MediaQuery.of(context).size.height * 0.1,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Image.asset('assets/icons/ic_gallary.png',
//                             width: Get.width * 0.1),
//                         const SizedBox(width: 8),
//                         Text(" קעקוע",
//                             style: Theme.of(context).textTheme.titleMedium),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 //sketch
//                 InkWell(
//                   onTap: () async {
//                     imageType = "1";
//                     if (startupController.subscriptionModel.subscriptionStatus
//                                 .toString() ==
//                             "1" &&
//                         startupController.subscriptionModel.isPremium
//                                 .toString() ==
//                             "1") {
//                       if (startupController.subscriptionModel.isPostLimit
//                               .toString() ==
//                           "1") {
//                         Get.back();
//                         reachedImageLimitDialog(
//                             size: MediaQuery.of(context).size,
//                             context: context,
//                             title: startupController
//                                 .subscriptionModel.popupTextTitle
//                                 .toString(),
//                             subtitle: startupController
//                                 .subscriptionModel.popupTextSubtitle
//                                 .toString());
//                         //You have reached the upload post limit
//                       } else {
//                         _showAddPostDialogue(context);
//                       }
//                     } else {
//                       notSubscriptionDialog(context);
//                     }
//                   },
//                   child: SizedBox(
//                     height: MediaQuery.of(context).size.height * 0.1,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Image.asset('assets/icons/ic_edit.png',
//                             width: Get.width * 0.1),
//                         const SizedBox(width: 8),
//                         Text("סקיצה",
//                             style: Theme.of(context).textTheme.titleMedium),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         });
//   }

//select is from gallery,camera or instagram
//   _showAddPostDialogue(BuildContext context) {
//     Navigator.of(context).pop();
//     return showModalBottomSheet<dynamic>(
//         useRootNavigator: true,
//         isScrollControlled: true,
//         context: context,
//         builder: (BuildContext bc) {
//           return Container(
//             decoration: const BoxDecoration(
//                 color: appbarBg,
//                 borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(16),
//                     topRight: Radius.circular(16))),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 //close
//                 InkWell(
//                   onTap: () => Get.back(),
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(
//                         vertical: MediaQuery.of(context).size.height * 0.03,
//                         horizontal: MediaQuery.of(context).size.width * 0.4),
//                     child: Container(
//                         margin: const EdgeInsetsDirectional.only(
//                             start: 1.0, end: 1.0),
//                         height: MediaQuery.of(context).size.height * 0.005,
//                         width: MediaQuery.of(context).size.width * 0.2,
//                         color: kDivider),
//                   ),
//                 ),
//                 //gallery
//                 InkWell(
//                   onTap: () => _selectImage(context, ImageSource.gallery),
//                   child: Container(
//                     width: double.infinity,
//                     color: Colors.white,
//                     height: MediaQuery.of(context).size.height * 0.1,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Image.asset('assets/icons/ic_gallary.png',
//                             width: Get.width * 0.1),
//                         const SizedBox(width: 8),
//                         Text("העלה תמונה",
//                             style:
//                                 Theme.of(context).textTheme.titleMedium) //קעקוע
//                       ],
//                     ),
//                   ),
//                 ),
//                 //camera
//                 InkWell(
//                   onTap: () async {
//                     PermissionStatus status = await Permission.camera.status;
//                     if (status.isGranted || status.isLimited) {
//                       _selectImage(context, ImageSource.camera);
//                     } else if (status.isDenied) {
//                       await openAppSettings();
//                     } else if (!status.isGranted) {
//                       status = await Permission.camera.request();
//                     }
//                   },
//                   child: SizedBox(
//                     width: double.infinity,
//                     height: MediaQuery.of(context).size.height * 0.1,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         // Image.asset('assets/icons/ic_edit.png'),
//                         Icon(Icons.camera_alt_outlined, size: Get.width * 0.1),
//                         const SizedBox(width: 8),
//                         Text("צלם תמונה",
//                             style:
//                                 Theme.of(context).textTheme.titleMedium) //סקיצה
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         });
//   }
}
