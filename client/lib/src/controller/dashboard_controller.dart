import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/StartupController.dart';
import 'package:ink/src/controller/businessProfilecontroller.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/ui/screen/home/controller/home_screen_controller.dart';
import 'package:ink/src/ui/screen/inspiration/controller/inspiration_controller.dart';
import 'package:ink/src/ui/screen/inspiration/controller/random_pagination.dart';
import 'package:ink/src/ui/screen/profile/drawer/controller/business_profile_menu_controller.dart';
import 'package:ink/src/utils/shared_preference_helper.dart';
import 'package:ink/src/utils/webService.dart';

class DashBoardController extends GetxController {
  var tabIndex = 0;
  RxBool init = true.obs;

  RxBool isFixedAdClosed = false.obs;
  RxString startupImageDashboard = "".obs;

  // final BusinessProfileController businessProfileController =
  //     Get.find<BusinessProfileController>();

  @override
  void onInit() {
    setAdClosed();
    // After OTP login (or a failed splash fetch), home lists can stay empty
    // because HomeScreenController was already created and never refreshed.
    _ensureHomeLoaded();
    super.onInit();
  }

  Future<void> _ensureHomeLoaded() async {
    final home = Get.put(HomeScreenController());
    if (home.businessList.isEmpty &&
        home.tattosInStyle.isEmpty &&
        home.stylePosts.isEmpty) {
      await getHomeData();
    }
  }

  // Future<void> changeTabIndex(int index) async {
  //   print("Change Index $index");
  //   print("Change Index: ${index.runtimeType}");
  //   try {
  //     if (index == 0) {
  //       tabIndex = index;
  //       final isApiHoldTime =
  //           await SharedPreferencesHelper.getHomeApiHoldTime();
  //
  //       if (isApiHoldTime != null) {
  //         final DateTime current = DateTime.now();
  //         final DateTime closedDate = DateTime.parse(isApiHoldTime);
  //         final difference = current.difference(closedDate).inMinutes;
  //         if (difference >= 10) {
  //           getHomeData();
  //         }
  //       } else {
  //         getHomeData();
  //       }
  //     } else if (index == 1) {
  //       if (!WebService.isSplashHomeScreen) {
  //         WebService.isSplashHomeScreen = true;
  //       }
  //       tabIndex = index;
  //
  //       // getInspirationData();
  //       if (WebService.randomPagination == "0" &&
  //           WebService.randomPagination == null) {
  //         final isApiInspirationHoldTime =
  //             await SharedPreferencesHelper.getInspirationApiHoldTime();
  //
  //         if (isApiInspirationHoldTime != null) {
  //           final DateTime current = DateTime.now();
  //           final DateTime closedDate =
  //               DateTime.parse(isApiInspirationHoldTime);
  //           final difference = current.difference(closedDate).inMinutes;
  //           if (difference >= 10) {
  //             getInspirationData();
  //           }
  //         } else {
  //           getInspirationData();
  //         }
  //       } else {
  //         Network.getPostCountApi().then((value) async {
  //           if (WebService.randomPagination != "0" &&
  //               WebService.randomPagination != null) {
  //             final isApiHoldTime =
  //                 await SharedPreferencesHelper.getInspirationApiHoldTime();
  //
  //             if (isApiHoldTime != null) {
  //               final DateTime current = DateTime.now();
  //               final DateTime closedDate = DateTime.parse(isApiHoldTime);
  //               final difference = current.difference(closedDate).inMinutes;
  //               if (difference >= 10) {
  //                 getInspirationData();
  //               }
  //             } else {
  //               getInspirationData();
  //             }
  //           }
  //         });
  //       }
  //     }
  //     if (index == 3) {
  //       if (!WebService.isSplashHomeScreen) {
  //         WebService.isSplashHomeScreen = true;
  //       }
  //       tabIndex = index;
  //
  //       final controller = Get.put(BusinessProfileMenuController());
  //       await controller.initPackageInfo();
  //     } else if (index == 2) {
  //       if (!WebService.isSplashHomeScreen) {
  //         WebService.isSplashHomeScreen = true;
  //       }
  //       tabIndex = index;
  //       final isApiBusinessHoldTime =
  //           await SharedPreferencesHelper.getBusinessScreenApiHoldTime();
  //
  //       if (isApiBusinessHoldTime != null) {
  //         final DateTime current = DateTime.now();
  //         final DateTime closedDate = DateTime.parse(isApiBusinessHoldTime);
  //         final difference = current.difference(closedDate).inMinutes;
  //         if (difference >= 10) {
  //           getBusinessData();
  //         }
  //       } else {
  //         getBusinessData();
  //       }
  //     }
  //   } finally {
  //     update();
  //   }
  // }

  Future<void> changeTabIndex(int index) async {


    try {
      // Ensure only one branch executes
      if (index == 0) {
        tabIndex = index;
        await _handleHomeTab();
      } else if (index == 1) {
        tabIndex = index;
        await _handleInspirationTab();
      } else if (index == 2) {
        tabIndex = index;
        await _handleBusinessTab();
      } else if (index == 3) {
        tabIndex = index;
        await _handleProfileTab();
      }
    } catch (e, st) {
      print("Error in changeTabIndex: $e\n$st");
    } finally {
      update(); // Always update at the end
    }
  }

  Future<void> _handleHomeTab() async {
    final isApiHoldTime = await SharedPreferencesHelper.getHomeApiHoldTime();
    if (isApiHoldTime == null) {
      await getHomeData();
      return;
    }

    final current = DateTime.now();
    final closedDate = DateTime.parse(isApiHoldTime);
    if (current.difference(closedDate).inMinutes >= 10) {
      await getHomeData();
    }
  }

  Future<void> _handleInspirationTab() async {
    if (!WebService.isSplashHomeScreen) {
      WebService.isSplashHomeScreen = true;
    }

    if (WebService.randomPagination == null ||
        WebService.randomPagination == "0") {
      await _checkInspirationHoldTime();
    } else {
      final _ = await Network.getPostCountApi();
      await _checkInspirationHoldTime();
    }
  }

  Future<void> _checkInspirationHoldTime() async {
    final holdTime = await SharedPreferencesHelper.getInspirationApiHoldTime();
    if (holdTime == null) {
      await getInspirationData();
      return;
    }

    final current = DateTime.now();
    final closedDate = DateTime.parse(holdTime);
    if (current.difference(closedDate).inMinutes >= 10) {
      await getInspirationData();
    }
  }

  Future<void> _handleBusinessTab() async {
    if (!WebService.isSplashHomeScreen) {
      WebService.isSplashHomeScreen = true;
    }

    final holdTime =
    await SharedPreferencesHelper.getBusinessScreenApiHoldTime();

    if (holdTime == null) {
      await getBusinessData();
      return;
    }

    final current = DateTime.now();
    final closedDate = DateTime.parse(holdTime);
    if (current.difference(closedDate).inMinutes >= 10) {
      await getBusinessData();
    }
  }

  Future<void> _handleProfileTab() async {
    if (!WebService.isSplashHomeScreen) {
      WebService.isSplashHomeScreen = true;
    }
    final controller = Get.put(BusinessProfileMenuController());
    await controller.initPackageInfo();
  }
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

  Future<void> getHomeData() async {
    final homeScreenController = Get.put(HomeScreenController());

    await SharedPreferencesHelper.saveHomeApiHoldTime();
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

    await businessProfileController.getBusinessList();
    await SharedPreferencesHelper.saveBusinessScreenApiHoldTime();
  }

  Future<void> getInspirationData() async {
    final InspirationController inspirationController =
        Get.put(InspirationController());
    inspirationController.pagination = RandomPagination(
        totalPosts: int.parse(WebService.randomPagination ?? "0"), limit: 20);

    inspirationController.postsInspiration.clear();
    inspirationController.isRandomAutoLoad.value = true;
    inspirationController.startInspiration.value = 0;
    inspirationController.searchController.text = "";
    inspirationController.styles="";
    WebService.selectstylelist = [];
    inspirationController.selectedStyles?.clear();
    inspirationController.isStyleEnabled.value = false;
    inspirationController.isselected = "מומלצים עבורכם".obs;
    inspirationController.getInspirationController();
    await SharedPreferencesHelper.saveInspirationApiHoldTime();
  }

// Future getBusinessList() async =>
//     await businessProfileController.getBusinessList(0, "", "", "", "", "");
}
