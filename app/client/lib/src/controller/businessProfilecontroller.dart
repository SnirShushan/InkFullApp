import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/userController.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/webService.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/model/currentUser.dart';
import '../ui/screen/bussiness_profiles/model_business_user.dart';

class BusinessProfileController extends GetxController
    with GetSingleTickerProviderStateMixin {
  var businessList = <BusinessUserListModel>[].obs;
  final ScrollController scrollControllerBusinessProfile = ScrollController();
  TabController? tabController;
  RxBool isLoading = false.obs;
  bool isApiLoading = false;
  final userController = Get.put(UserController());
  RxBool isPopularEnabled = false.obs;
  RxBool isStyleEnabled = false.obs;

  //For Sort by Location Popup Handler
  RxBool isLocationPopupOpen = false.obs;
  RxBool isOkButton = false.obs;

  // RxBool isNewEnabled = false.obs;
  RxBool isSorting = false.obs;
  RxBool isAsPerLocation = false.obs;
  RxBool isAsPerLocationClickable = false.obs;
  RxBool isRecommended = true.obs;
  RxBool isClosest = false.obs;
  RxBool isClosestSelectReset = false.obs;
  RxBool isCurrentLocationSelected = false.obs;
  RxString lat = "".obs;
  RxString lng = "".obs;
  RxString previousId = "1".obs;
  TextEditingController addressController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  RxList<StylesList>? stylesList = <StylesList>[].obs;
  RxList<StylesList>? selectedStyles = <StylesList>[].obs;
  String radius = "100";
  RxBool hasMoreBusinessProfile = true.obs;
  RxBool hasMoreBusinessProfileLoading = false.obs;
  RxInt startBusinessProfile = 0.obs;
  int limitBusinessProfile = 5;

  //'is_recommended': isRecommended,

  //sorting
  // final RxList<SortOption> sortOptionsList = [
  //   SortOption(
  //       name: "מומלצים עבורכם", type: sortings.recommended, isSelected: true),
  //   SortOption(
  //       name: "הכי קרובים אליכם", type: sortings.closest, isSelected: false),
  //   SortOption(
  //       name: "הפופולרים ביותר", type: sortings.popular, isSelected: false),
  // ].obs;
  RxString isselected = "מומלצים עבורכם".obs;

  final List<String> options = [
    "מומלצים עבורכם",
    "הכי קרובים אליכם",
    "הפופולרים ביותר"
  ];

  Future<void> initStyles() async {
    try {
      final AppUser? user = await WebService.getCurrentUser();
      if (user != null) {
        await userController.initUser();
        stylesList?.value = user.stylesList ?? [];
        update();
      }
    } catch (e) {
      debugPrint('Error in initStyles: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize values
    startBusinessProfile.value = 0;
    isRecommended.value = true;
    isPopularEnabled.value = false;
    isClosest.value = false;

    // Clear existing business list if any
    businessList.clear();

    tabController = TabController(length: 4, vsync: this);

    // Initialize search and scroll listeners
    searchController.addListener(_searchListener);
    scrollControllerBusinessProfile.addListener(requestListener);

    Future.microtask(() {
      getBusinessList();
      initStyles();
    });
  }

  _searchListener() {
    if (searchController.text.length > 3) {
      getBusinessList();
    }

    if (searchController.text.isEmpty) {
      getBusinessList();
    }
  }

  // 0=popular 1=close to me 2=personal style 3=new one
  Future getBusinessList() async {
    isOkButton = false.obs;
    isLoading.value = true;
    if (isApiLoading) return;
    isApiLoading = true;

    try {
      String styles = "";
      if (selectedStyles != [])
        styles = selectedStyles?.map((e) => e.slug!).join(",") ?? "";

      print(startBusinessProfile.value);
      await Network.getBusinessApi(
              isFilterLocation:
                  (isAsPerLocation.value || isCurrentLocationSelected.value)
                      ? isClosestSelectReset.value == true
                          ? "2"
                          : "1"
                      : "2",
              isPopularEnabled: isPopularEnabled.value == true ? "1" : "",
              isStyleEnabled: isStyleEnabled.value == true ? "1" : "",
              selectedStyles: styles,
              start: startBusinessProfile.value,
              limit: limitBusinessProfile,
              // isNewEnabled: isNewEnabled.value == true ? "1" : "",
              // isAsPerLocation: isAsPerLocation.value == true ? "1" : "",
              isClosest: isClosest.value == true ? "1" : "2",
              isRecommended: isRecommended.value == true ? "1" : "2",
              lat: lat.value ?? "",
              lng: lng.value ?? "",
              radius: radius,
              searchText: searchController.text)
          .then((res) {
        if (res != false) {
          final List newList = List.from(res);
          if (res.toString() == "[]" || res == []) {
            hasMoreBusinessProfile.value = false;
          } else {
            if (newList.length < limitBusinessProfile) {
              hasMoreBusinessProfile.value = false;
            } else {
              startBusinessProfile += limitBusinessProfile;
            }
          }
          hasMoreBusinessProfileLoading.value = false;
          for (var doc in newList) {
            final post = BusinessUserListModel.fromJson(doc);
            if (!businessList.any((p) => p.id == post.id))
              businessList.add(post);
          }
          businessList.refresh();
        } else {
          if (isClosest.value == true) {
            isSorting.value = true;
          }
        }
        isLoading.value = false;
        // }
      });
    } catch (e) {
      hasMoreBusinessProfileLoading.value = false;
      hasMoreBusinessProfile.value = false;
    } finally {
      isApiLoading = false;
      hasMoreBusinessProfileLoading = false.obs;
    }
  }

  Future likeBusinessUser({fid, likeStatus, required int type}) async {
    await Network.followUser(fid: fid, likeStatus: likeStatus);
    // if (type == 1) {
    //   await getBusinessList(type, userController.address_lat,
    //       userController.address_lng, "1", "", "likes");
    // } else {
    //   await getBusinessList(type, "", "", "", "", "likes");
    // }
    update();
  }

  //manage location
  setCurrentLocation(
      {required bool isEnabled, String locationType = ""}) async {
    if (isEnabled) {
      if (Platform.isAndroid) {
        var status = await Permission.location.status;
        if (status.isGranted || status.isLimited) {
          if (locationType != "") {

           startBusinessProfile.value = 0;
           hasMoreBusinessProfile.value=true;
           businessList.clear();
            isAsPerLocation.value = true;
            addressController.text = "";
            isRecommended.value = false;
            isClosest.value = true;
            isPopularEnabled.value = false;
            isselected.value = "הכי קרובים אליכם";
            isClosestSelectReset.value = true;
            Navigator.of(Get.context!).pop();
            isLoading.value = true;
          }
          Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          lat.value = position.latitude.toString();
          lng.value = position.longitude.toString();


          isCurrentLocationSelected.value = isEnabled;

          if (locationType != "" && lat.value != "" && lng.value != "") {
            getBusinessList();
          }
        } else if (status.isDenied) {
          locationRawSnackbar();

          Timer(
              const Duration(seconds: 4), () async => await openAppSettings());
        } else if (status.isPermanentlyDenied) {
          locationRawSnackbar();

          Timer(
              const Duration(seconds: 4), () async => await openAppSettings());
        } else if (status.isRestricted) {}
      } else {
        try {
          await _determinePosition(locationType: locationType)
              .then((value) async {
            lat.value = value.latitude.toString();
            lng.value = value.longitude.toString();
            isCurrentLocationSelected.value = isEnabled;
            isAsPerLocation.value = true;
            addressController.text = "";
            if (locationType != "" && lat.value != "" && lng.value != "") {
              startBusinessProfile.value = 0;
              hasMoreBusinessProfile.value=true;
              businessList.clear();
              isAsPerLocation.value = true;
              addressController.text = "";
              isRecommended.value = false;
              isClosest.value = true;
              isPopularEnabled.value = false;
              isselected.value = "הכי קרובים אליכם";
              isClosestSelectReset.value = true;
              getBusinessList();
            }
          });
        } catch (e) {}
      }
    } else {
      lat.value = "";
      lng.value = "";
      isAsPerLocation.value = false;
      isCurrentLocationSelected.value = isEnabled;
    }
  }

  SnackbarController locationRawSnackbar() {
    return Get.rawSnackbar(
      messageText: const Text(
          "יש לאפשר לאפליקציה גישה למיקום, מיד תועבר למסך ההגדרות",
          // "יש לאפשר לאפליקציה גישה למיקום , מייד תועבר למסך ההגדרות",
          style: TextStyle(
            fontFamily: 'Arimo', // Assuming you have the Arimo font included
            fontSize: 14.0, // Logical pixels, may need adjustment
            fontWeight: FontWeight.normal,
            color: titleTextWhiteColor,
          )),
      snackPosition: SnackPosition.TOP,
      backgroundColor: errorColor,
      borderRadius: 8,
      margin: const EdgeInsets.all(30.0),
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 0),
      duration: const Duration(seconds: 3),
      icon: SvgPicture.asset(
        AppAssets.errorIcon,
      ),
      // forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  //manage address

  //select styles
  selectStyle(StylesList style) {
    if (selectedStyles!.isEmpty) {
      selectedStyles?.value.add(style);
    } else {
      if (selectedStyles!.contains(style)) {
        selectedStyles?.value.remove(style);
      } else {
        selectedStyles?.value.add(style);
      }
    }
    if (selectedStyles!.isNotEmpty) {
      isStyleEnabled.value = true;
    } else {
      isStyleEnabled.value = false;
    }
    selectedStyles?.refresh();
  }

  //check is filter applied
  bool isFilterApplied() {
    if (isAsPerLocationClickable.value ||
        isStyleEnabled.value ||
        selectedStyles!.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  //clear filters
  clearFilters() {
    try {
      businessList.clear();
     hasMoreBusinessProfile.value=true;
      startBusinessProfile.value = 0;
      selectedStyles?.clear();
      selectedStyles?.refresh();
      isStyleEnabled.value = false;
      addressController.text = "";
      isAsPerLocationClickable.value = false;
      isCurrentLocationSelected.value = false;
      isAsPerLocation.value = false;
      lat.value = "";
      lng.value = "";
    } finally {
      getBusinessList();
    }
  }

  // manageSorting(SortOption option) {
  //   if (option.type == sortings.recommended) {
  //     isRecommended.value = true;
  //     isPopularEnabled.value = false;
  //     isClosest.value = false;
  //     sortOptionsList.map((element) {
  //       if (element.type == sortings.recommended) {
  //         element.isSelected = true;
  //       } else {
  //         element.isSelected = false;
  //       }
  //     }).toList();
  //   } else if (option.type == sortings.popular) {
  //     isRecommended.value = false;
  //     isPopularEnabled.value = true;
  //     isClosest.value = false;
  //     isAsPerLocation.value = false;
  //     sortOptionsList.map((element) {
  //       if (element.type == sortings.popular) {
  //         element.isSelected = true;
  //       } else {
  //         element.isSelected = false;
  //       }
  //     }).toList();
  //   } else if (option.type == sortings.closest) {
  //     isRecommended.value = false;
  //     isPopularEnabled.value = false;
  //     isClosest.value = true;
  //     sortOptionsList.map((element) {
  //       if (element.type == sortings.closest) {
  //         element.isSelected = true;
  //       } else {
  //         element.isSelected = false;
  //       }
  //     }).toList();
  //   }
  //   update();
  //
  //   getBusinessList();
  //
  //   // sortOptionsList.map((element) {
  //   //   if (element.name == option.name) {
  //   //     element.isSelected = !element.isSelected!;
  //   //     if (element.isSelected == true) {
  //   //       if (element.type == sortings.popular) {
  //   //         isPopularEnabled.value = true;
  //   //       } else if (element.type == sortings.recommended) {
  //   //         isAsPerLocation.value = true;
  //   //       } else if (element.type == sortings.newUsers) {
  //   //         isNewEnabled.value = true;
  //   //       }
  //   //     } else {
  //   //       if (element.type == sortings.popular) {
  //   //         isPopularEnabled.value = false;
  //   //       } else if (element.type == sortings.recommended) {
  //   //         isAsPerLocation.value = false;
  //   //       } else if (element.type == sortings.newUsers) {
  //   //         isNewEnabled.value = false;
  //   //       }
  //   //     }
  //   //     getBusinessList();
  //   //   }
  //   // }).toList();
  //   sortOptionsList.refresh();
  // }

  Future<Position> _determinePosition({String locationType = ""}) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      if (locationType != "") {
        isAsPerLocation.value = true;
        addressController.text = "";
        isRecommended.value = false;
        isClosest.value = true;
        isPopularEnabled.value = false;
        isselected.value = "הכי קרובים אליכם";
        isClosestSelectReset.value = true;
        Navigator.of(Get.context!).pop();
        isLoading.value = true;
      }
      return await Geolocator.getCurrentPosition();
    } else if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        locationRawSnackbar();
        Timer(const Duration(seconds: 4), () async => await openAppSettings());
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      locationRawSnackbar();
      Timer(const Duration(seconds: 4), () async => await openAppSettings());
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  sortingsData(
      {required BuildContext context,
      required String option,
      bool iscloseTime = true}) async {
    if (option == "הכי קרובים אליכם") {
      if (isClosest.value == false) {
        await setCurrentLocation(isEnabled: true, locationType: "SortLocation");
      }
    } else if (option == "הפופולרים ביותר") {
      if (isPopularEnabled.value == false) {
        previousId.value = "2";
        isRecommended.value = false;

        isPopularEnabled.value = true;
        isselected.value = option;

        if (isClosest.value == true) {
          lat.value = "";
          lng.value = "";
          isClosest.value = false;
          isAsPerLocation.value = false;
          isCurrentLocationSelected.value = false;
          addressController.text = "";
        }
        getBusinessList();
        if (iscloseTime) {
          Navigator.of(context).pop();
        }
      }
    } else {
      if (isRecommended.value == false) {
        previousId.value = "1";
        isRecommended.value = true;

        isPopularEnabled.value = false;
        isselected.value = option;

        if (isClosest.value == true) {
          isClosest.value = false;
          lat.value = "";
          lng.value = "";
          isCurrentLocationSelected.value = false;
          isAsPerLocation.value = false;
          addressController.text = "";
        }
        getBusinessList();
        if (iscloseTime) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  void requestListener() {
    if (scrollControllerBusinessProfile.position.maxScrollExtent ==
            scrollControllerBusinessProfile.offset &&
        hasMoreBusinessProfile.value) {
      hasMoreBusinessProfileLoading.value = true;
      getBusinessList();
    } else {
      hasMoreBusinessProfileLoading = false.obs;
    }
  }

  @override
  void dispose() {
    scrollControllerBusinessProfile.dispose();
    addressController.text = "";
    searchController.text = "";

    super.dispose();
  }
}

//sorting
enum sortings { recommended, popular, newUsers, closest }

class SortOption {
  final String name;
  final sortings type;
  bool? isSelected;

  SortOption({required this.name, required this.type, this.isSelected = false});
}
