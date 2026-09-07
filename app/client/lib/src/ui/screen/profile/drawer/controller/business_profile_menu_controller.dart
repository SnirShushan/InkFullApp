import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ink/src/controller/myPostController.dart';
import 'package:ink/src/data/model/ArtistModel.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/data/model/followes_model.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/ui/screen/profile/drawer/followers/follower_model.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/permissions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../utils/webService.dart';

class BusinessProfileMenuController extends GetxController {
  // late PackageInfo packageInfo;
  RxList<FollowersModel> followesList = <FollowersModel>[].obs;
  RxList<FollowerModel> userfollowes = <FollowerModel>[].obs;
  Rx<TextEditingController> nameController = TextEditingController().obs;
  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> phoneController = TextEditingController().obs;
  Rx<TextEditingController> addressController = TextEditingController().obs;
  Rx<TextEditingController> aboutController = TextEditingController().obs;
  RxBool isStudioSelected = false.obs;
  RxBool isLoadingCheckSubscription = false.obs;

  //Validation
  RxBool userEmailError = false.obs;
  RxBool userphoneError = false.obs;
  RxBool usernameeEror = false.obs;

  // final FollowedUsersController followUserController =
  //     Get.put(FollowedUsersController());

  Profile? profile;
  RxString id = "".obs;
  RxList<StylesList> listStyles = <StylesList>[].obs;
  RxList<StylesList> matchingItems = <StylesList>[].obs;
  RxList<Artist> artistList = <Artist>[].obs;

  RxBool isLoading = false.obs;
  RxBool issubmitting = false.obs;
  RxBool pushEnable = false.obs;
  RxBool isImageUpload = false.obs;
  RxString businessType = "".obs;
  RxString businessTypeOriginal = "".obs;
  RxString firebaseId = "".obs;
  RxString phoneno = "".obs;
  RxString profileimage = "".obs;
  RxString name = "".obs;
  RxString userType = "".obs;
  bool isApiLoading = false;
  Rx<File?> pikedFileData = Rx<File?>(null);
  RxString pickedFilePath = "".obs;
  final picker = ImagePicker();
  String studioIds = '';
  RxBool isLoadingTeam = false.obs;

  @override
  void onInit() {
    isLoading.value = true;
    userphoneError.value = false;
    usernameeEror.value = false;
    userEmailError.value = false;
    super.onInit();
    Future.microtask(() {
      initPackageInfo();
    });
  }

  Future<void> initPackageInfo() async {
    if (!await WebService.checkConnectionNoMsg()) return;
    if (isApiLoading) return;
    isApiLoading = true;
    isLoading.value = true;
    try {
      Network.getProfileUserApi().then((value) async {
        if (value != false && value != null && value is Map) {
          final profileJson = value["profile"];
          if (profileJson is Map) {
            profile = Profile.fromJson(Map<String, dynamic>.from(profileJson));
          }

          followesList.clear();
          artistList.clear();

          final followers = value["followers_list"] as List?;
          if (followers != null && followers.isNotEmpty) {
            followesList
                .addAll(followers.map((doc) => FollowersModel.fromJson(doc)));
          }

          final artists = value["artist"] as List?;
          if (artists != null && artists.isNotEmpty) {
            artistList.addAll(artists.map((doc) => Artist.fromJson(doc)));
          }

          final studios =
              (value["studios"] as List?) ?? (value["studio"] as List?);

          if (studios != null && studios.isNotEmpty) {
            studioIds =
                studios.map((studio) => studio['id'].toString()).join(',');
          }

          await getData(profile);
        } else {
          isApiLoading = false;
          isLoading.value = false;
        }
        Future.microtask(() => getFollowers());
        try {
          if (value is Map &&
              value["profile"] != null &&
              value["profile"]["city_name"] != null &&
              value["profile"]["city_name"].toString().trim().isNotEmpty) {
            WebService.cityName = value["profile"]["city_name"].toString();
          } else {
            WebService.cityName = "";
          }
        } catch (e) {
          WebService.cityName = "";
        }

        return;
      });
    } catch (e) {
      isApiLoading = false;
      isLoading.value = false;
    } finally {
      isApiLoading = false;
      followesList.refresh();
    }
  }

  Future<void> toggleIsEnabled(BuildContext context, bool newValue) async {
    bool isConnected = await WebService.checkConnection2();
    if (!isConnected) return;
    if (newValue) {
      PermissionStatus status = await Permission.notification.status;
      if (Platform.isIOS) {
        FirebaseMessaging messaging = FirebaseMessaging.instance;

        // Check current permission status
        NotificationSettings settings =
            await messaging.getNotificationSettings();
        if (settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional) {
          pushEnable.value = newValue;
          await Network.updatePushEnabled(isPushEnabled: newValue ? "1" : "2");
        } else {
          showNotificationDIalog(context, MediaQuery.of(context).size);
        }
      } else {
        if (status.isPermanentlyDenied || status.isRestricted) {
          showNotificationDIalog(context, MediaQuery.of(context).size);
        } else if (status.isDenied) {
          if (context.mounted) {
            showNotificationDIalog(context, MediaQuery.of(context).size);
          }
        } else {
          pushEnable.value = newValue;
          await Network.updatePushEnabled(isPushEnabled: newValue ? "1" : "2");
        }
      }
    } else {
      pushEnable.value = newValue;
      await Network.updatePushEnabled(
          isPushEnabled: newValue == true ? "1" : "2");
    }
  }

  // Future<void> toggleIsEnabled(BuildContext context, bool newValue) async {
  //   bool isConnected = await WebService.checkConnection2();
  //   if (!isConnected) return;
  //
  //   if (newValue == true) {
  //     PermissionStatus status = await Permission.notification.status;
  //     if (Platform.isAndroid) {
  //       const platform = MethodChannel('deviceInfoChannel');
  //
  //       final int result = await platform.invokeMethod('getAndroidVersion');
  //
  //       if (Platform.isAndroid && result >= 33 && status.isDenied) {
  //         Permission.notification.request();
  //       } else if (status.isDenied ||
  //           status.isPermanentlyDenied ||
  //           status.isRestricted) {
  //         showNotificationDIalog(context, MediaQuery.of(context).size);
  //       } else {
  //         pushEnable.value = newValue;
  //         await Network.updatePushEnabled(
  //             isPushEnabled: newValue == true ? "1" : "2");
  //       }
  //     } else {
  //       if (status.isDenied ||
  //           status.isPermanentlyDenied ||
  //           status.isRestricted) {
  //         showNotificationDIalog(context, MediaQuery.of(context).size);
  //       } else {
  //         pushEnable.value = newValue;
  //         await Network.updatePushEnabled(
  //             isPushEnabled: newValue == true ? "1" : "2");
  //       }
  //     }
  //   } else {
  //     pushEnable.value = newValue;
  //     await Network.updatePushEnabled(
  //         isPushEnabled: newValue == true ? "1" : "2");
  //   }
  // }

  Future<void> getData(profile) async {
    try {
      if (profile == null) return;
      matchingItems.clear();
      id.value = profile.id?.toString() ?? "";
      firebaseId.value = profile.firebaseId?.toString() ?? "";
      userType.value = profile.userType?.toString() ?? "";
      name.value = profile.name?.toString() ?? "";
      profileimage.value = profile.profileImage?.toString() ?? "";
      pushEnable.value = (profile.pushEnable?.toString() == "1");
      isStudioSelected.value = profile.businessType?.toString() == "1";

      businessType.value = profile.businessType?.toString() ?? "";
      businessTypeOriginal.value = profile.businessType?.toString() ?? "";
      WebService.placeId = profile.addressPlaceId?.toString() ?? "";
      if (profile.addressLat != null &&
          profile.addressLat.toString().isNotEmpty &&
          profile.addressLat.toString() != "null") {
        WebService.lat = double.tryParse(profile.addressLat.toString()) ?? 0.0;
        WebService.lang = double.tryParse(profile.addressLng.toString()) ?? 0.0;
      }

      nameController.value.text = profile.name?.toString() ?? "";
      emailController.value.text = profile.email?.toString() ?? "";
      phoneno.value = profile.phone?.toString() ?? "";
      aboutController.value.text = profile.aboutText?.toString() ?? "";
      addressController.value.text = profile.address?.toString() ?? "";

      AppUser user = await WebService.getCurrentUser();
      final stylesString = profile.styles?.toString() ?? "";
      if (stylesString.isNotEmpty &&
          stylesString != "null" &&
          stylesString != "[]") {
        listStyles.clear();

        final styleSlugs = stylesString.split(',').toSet();

        for (final doc in user.stylesList ?? []) {
          listStyles.add(doc);
          if (styleSlugs.contains(doc.slug)) {
            matchingItems.add(doc);
          }
        }
      } else {
        listStyles.clear();
        listStyles.addAll(user.stylesList ?? []);
      }
      matchingItems.refresh();
    } catch (e) {
      debugPrint('getData profile error: $e');
      isApiLoading = false;
      isLoading.value = false;
    } finally {
      isApiLoading = false;
      isLoading.value = false;
      update();
    }
  }

  Future<void> businessEditProfileImage(profileImage) async {
    isImageUpload.value = true;
    try {
      Network.updateProfileImage(profileImage: profileImage ?? File(""))
          .then((imageUpdate) async {
        if (imageUpdate != false) {
          await initPackageInfo();
          final MyPostsController myPostsController =
              Get.put(MyPostsController());
          await myPostsController.getMyPosts();
        }
      });
    } catch (e) {
      displayMessageIcon(
          message: e.toString(),
          snackposition: SnackPosition.BOTTOM,
          color: errorColor,
          imageData: AppAssets.errorIcon);
    }
  }

  Future<void> selectImage(context, ImageSource source) async {
    try {
      if (!(await checkPermission())) await requestPermission();

      // if (source == ImageSource.camera) {
      //   String osVersion = Platform.operatingSystemVersion;
      //   if (osVersion.contains('12') || osVersion.compareTo('12') < 0) {
      //     if (!(await checkPermission())) await requestPermission();
      //   } else {
      //     if (!(await checkPermission13())) await requestPermission13();
      //   }
      // }

      XFile? pickedFile = await picker.pickImage(
          source: source, imageQuality: 70, maxHeight: 800, maxWidth: 800);
      // if (pickedFile == null) displayMessage("message", Colors.red);
      if (pickedFile == null) return;

      final picked = File(pickedFile.path);
      pickedFilePath.value = pickedFile.path;
      pikedFileData.value = picked;

      await businessEditProfileImage(File(pickedFile.path)!);
    } catch (e) {
      displayMessageIcon(
          message: e.toString(),
          color: errorColor,
          imageData: AppAssets.errorIcon);
    }
  }

  Future<void> businessConvertController(BuildContext context) async {
    try {
      issubmitting.value = true;
      String newStyles = "";
      if (matchingItems.isNotEmpty) {
        List<String> userNames =
            await matchingItems.map((datas) => datas.slug!).toList();
        newStyles = userNames.join(',');
      }

      String membersid = "";

      if (businessType.value.isEmpty) {
        membersid = "";
      } else if (businessType.value == "2") {
        membersid = artistList.isNotEmpty
            ? artistList.where((a) => a.id != null).map((a) => a.id!).join(",")
            : "";
      } else if (businessType.value == "1") {
        membersid = studioIds.isNotEmpty ? studioIds : "";
      } else {
        membersid = "";
      }

      Network.changeBusinessUserTypeApi(
        name: nameController.value.text.toString(),
        address: addressController.value.text.toString(),
        addressPlaceId: WebService.placeId.toString(),
        lat: WebService.lat.toString(),
        lng: WebService.lang.toString(),
        styles: newStyles,
        membersid: membersid,
        about: aboutController.value.text.toString(),
        newUserType: businessType.value,
      ).then((value) async {
        issubmitting.value = false;
        if (value == true) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool("isBusiness", true);
          if (WebService.tempArtistIdList != "") {
            await Network.updateArtistChangePlanList(
                artistId: WebService.tempArtistIdList, actionStatus: "1");
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          } else {
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          }
        }
      });
    } catch (e) {
      displayMessageIcon(
          message: e.toString(),
          snackposition: SnackPosition.BOTTOM,
          color: errorColor,
          imageData: AppAssets.errorIcon);
    } finally {
      safePop();
    }
  }

  void safePop({Duration delay = const Duration(milliseconds: 300)}) {
    Future.delayed(delay, () {
      final navigator = Get.key.currentState;

      if (navigator != null && navigator.canPop()) {
        navigator.pop();
      } else if (Get.isOverlaysOpen ?? false) {
        Get.back();
      } else {
        try {
          // Last fallback — handles native navigator cases
          Navigator.of(Get.context!).maybePop();
        } catch (_) {}
      }
    });
  }

  Future<void> businessEditProfileController(BuildContext context) async {
    issubmitting.value = true;
    String newStyles = "";
    if (matchingItems.isNotEmpty) {
      List<String> userNames =
          await matchingItems.map((datas) => datas.slug!).toList();
      newStyles = userNames.join(',');
    }

    try {
      Network.businessEditProfileApi(
        name: nameController.value.text.toString(),
        address: addressController.value.text.toString(),
        addressPlaceId: WebService.placeId.toString(),
        lat: WebService.lat.toString(),
        lng: WebService.lang.toString(),
        styles: newStyles,
        about: aboutController.value.text.toString(),
      ).then((value) async {
        issubmitting.value = false;
        if (value == true) {
          final MyPostsController myPostsController =
              Get.put(MyPostsController());
          myPostsController.isDataLoading.value = true;
          await myPostsController.getMyPosts();
        }
      });
    } catch (e) {
      displayMessageIcon(
          message: e.toString(),
          snackposition: SnackPosition.BOTTOM,
          color: errorColor,
          imageData: AppAssets.errorIcon);
    } finally {
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
  }

  Future updateUserDetailsController(
      {context,
      name,
      phone,
      email,
      required BusinessProfileMenuController
          businessProfileMenuController}) async {
    try {
      await Network.updateUserDetails(name: name, phone: phone, email: email)
          .then((responseData) async {
        print("responseData $responseData");
        if (responseData != false) {
          AppUser user = await WebService.getCurrentUser();

          final Profile profile = Profile.fromJson(responseData["profile"]);
          final followers = user.followers;
          final startup_image = user.startup_image;
          final styleList = user.stylesList ?? [];

          AppUser updatedUser = AppUser(
              profile: profile,
              // artist: artist,
              stylesList: styleList,
              followers: followers,
              startup_image: startup_image);

          await WebService.setCurrentUser(updatedUser);
          businessProfileMenuController.initPackageInfo();
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
        } else {
          return false;
        }
      });
    } catch (e) {}
  }

  @override
  void dispose() {
    super.dispose();

    nameController.value.text = "";
    emailController.value.text = "";
    phoneController.value.text = "";
    addressController.value.text = "";
    aboutController.value.text = "";
  }

  // void _showPermissionDialog(context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text("Camera Permission"),
  //         content: Text("This app needs camera access to function properly."),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Close the dialog
  //             },
  //             child: Text("Deny"),
  //           ),
  //           TextButton(
  //             onPressed: () async {
  //               Navigator.of(context).pop(); // Close the dialog
  //               var status = await Permission.camera.request();
  //               if (status.isGranted) {
  //                 print("Permission granted!");
  //               } else if (status.isPermanentlyDenied) {
  //                 openAppSettings(); // Direct user to settings if permanently denied
  //               }
  //             },
  //             child: Text("Allow"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  getFollowers() async {
    try {
      final res = await Network.getFollowers(start: 0, limit: 5);

      // Null / false / empty check (API may return false on soft-fail)
      if (res == null || res == false) return;
      if (res is! List || res.isEmpty) return;
      userfollowes.clear();

      for (final doc in res) {
        userfollowes.add(FollowerModel.fromJson(doc));
      }

      userfollowes.refresh();
    } catch (e, stackTrace) {
      debugPrint('getFollowers error: $e');
    }
  }
}
