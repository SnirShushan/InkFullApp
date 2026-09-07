import 'package:get/get.dart';
import 'package:ink/src/data/model/ArtistModel.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/business_dashboard.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/bussinessdashboard_binding.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard_binding.dart';
import 'package:ink/src/ui/screen/profile/select_category.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/webService.dart';

class UserController extends GetxController {
  RxString id = "".obs;
  RxString firebaseId = "".obs;
  RxString name = "".obs;
  RxString followers = "".obs;
  RxString startup_image = "".obs;
  RxString email = "".obs;
  RxString phone = "".obs;
  RxString styles = "".obs;
  RxString cntCode = "".obs;
  RxString udid = "".obs;
  RxString logintoken = "".obs;
  RxString profileimage = "".obs;
  RxString about_text = "".obs;
  RxString userType = "".obs;
  RxString businessType = "".obs;
  RxString loginType = "".obs;
  RxString address = "".obs;
  RxString address_lat = "".obs;
  RxString address_lng = "".obs;
  RxString address_place_id = "".obs;
  RxBool locationEnable = true.obs;
  RxBool pushEnabl = true.obs;
  RxList<StylesList> style_list = <StylesList>[].obs;
  RxList<Artist> artistList = <Artist>[].obs;
  RxBool internetAvailable = false.obs;

  Future initUser() async {
    try {
      AppUser user = await WebService.getCurrentUser();
      id.value = user.profile!.id.toString();
      firebaseId.value = user.profile!.firebaseId.toString();
      name.value = user.profile!.name.toString();
      followers.value = user.followers.toString();
      startup_image.value = user.startup_image.toString();
      email.value = user.profile!.email.toString();
      about_text.value = user.profile!.aboutText.toString();
      profileimage.value = user.profile!.profileImage.toString();
      address.value = user.profile!.address.toString();
      address_place_id.value = user.profile!.addressPlaceId.toString();
      address_lat.value = user.profile!.addressLat!.toString();
      address_lng.value = user.profile!.addressLng!.toString();
      phone.value = user.profile!.phone!.toString();
      cntCode.value = user.profile!.cntCode!.toString();
      udid.value = user.profile!.udId!.toString();
      styles.value = user.profile!.styles!.toString();
      logintoken.value = user.profile!.loginToken!.toString();
      userType.value = user.profile!.userType!.toString();
      businessType.value = user.profile!.businessType!.toString();
      loginType.value = user.profile!.loginType!.toString();
      locationEnable.value =
          (user.profile!.locationEnable!.toString() == "1") ? true : false;
      pushEnabl.value =
          (user.profile!.pushEnable!.toString() == "1") ? true : false;

      style_list.clear();
      user.stylesList!.map((e) => style_list.value.add(e)).toList();
      update();
    } catch (e) {}
  }

  Future userRegistration({name, email, phone}) async {
    await Network.userRegistrationApi(name: name, email: email, phone: phone)
        .then((responseData) async {
      if (responseData != false) {
        final sharedPreferences = await SharedPreferences.getInstance();
        await sharedPreferences.remove("registrationmobile");
        AppUser user = await WebService.getCurrentUser();

        final Profile profile = Profile.fromJson(responseData["profile"]);
        final followers = user.followers;
        final startup_image = user.startup_image;
        final styleList = user.stylesList ?? [];
        // final artist = user.artist!;

        AppUser updatedUser = AppUser(
            profile: profile,
            // artist: artist,
            stylesList: styleList,
            followers: followers,
            startup_image: startup_image);
        await WebService.setCurrentUser(updatedUser);

        AppUser currentUser = await WebService.getCurrentUser();

        //check user type is user studio/artist or normal user

        if (currentUser.profile!.userType == "2") {
          Get.offAll(
              BusinessDashBoard(
                initialIndex: 0,
              ),
              binding: BusinessDashBoardBinding());
        } else {
          currentUser.profile!.styles.toString().isNotEmpty
              ? Get.offAll(
                  const DashBoard(
                    initialIndex: 3,
                  ),
                  binding: DashBoardBinding())
              : Get.offAll(SelectCategory(
                  fromLogin: true,
                ));
        }
      }
      return responseData;
    });
  }

  Future updateUser(
      {name,
      address,
      addressPlaceId,
      lat,
      lng,
      about,
      styles,
      firebaseId,
      email}) async {
    await Network.updateProfile(
            name: name,
            address: address,
            addressPlaceId: addressPlaceId,
            lat: lat.toString(),
            lng: lng.toString(),
            about: about,
            styles: styles,
            firebaseId: firebaseId,
            email: email)
        .then((responseData) async {
      AppUser user = await WebService.getCurrentUser();

      final Profile profile = Profile.fromJson(responseData["profile"]);
      final followers = user.followers;
      final startup_image = user.startup_image;
      final styleList = user.stylesList ?? [];
      // final artist = user.artist!;

      AppUser updatedUser = AppUser(
          profile: profile,
          // artist: artist,
          stylesList: styleList,
          followers: followers,
          startup_image: startup_image);
      await WebService.setCurrentUser(updatedUser);

      await initUser();
    });
  }

  Future updateUserDetails({name, phone, email}) async {
    await Network.updateUserDetails(name: name, phone: phone, email: email)
        .then((responseData) async {
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
        await initUser();
      } else {
        return false;
      }
    });
  }

  //update styles
  Future updateStyles({styles, fromProfile}) async {
    await Network.updateStyles(styles: styles).then((value) async {
      AppUser updatedUser = AppUser(
          profile: Profile.fromJson(value["profile"]),
          // artist: artistList.value,
          stylesList: style_list.value,
          startup_image: startup_image.value,
          followers: followers.value);
      await WebService.setCurrentUser(updatedUser);
      initUser();
      update();
      /*if (userType.value == "2") {
        Get.offAll(BusinessDashBoard(initialIndex: 4),
            binding: BusinessDashBoardBinding());
      } else {
        Get.offAll(const DashBoard(initialIndex: 3),
            binding: DashBoardBinding());
      }*/

      Get.back();
    });
  }

  //delete account
  Future deleteAccount({styles}) async {
    await Network.deleteAccountApi();
  }

  Future updateLocationEnabled({required String isLocationEnabled}) async {
    await Network.updateLocationEnabled(isLocationEnabled: isLocationEnabled)
        .then((value) async {
      AppUser user = await WebService.getCurrentUser();

      final followers = user.followers!;
      final styleList = user.stylesList!;

      AppUser updatedUser = AppUser(
          profile: Profile.fromJson(value),
          // artist: artistList.value,
          stylesList: styleList,
          startup_image: user.startup_image!,
          followers: followers);

      await WebService.setCurrentUser(updatedUser);
      await initUser();
    });
    update();
  }

  Future updatePushEnabled({required String isPushEnabled}) async {
    await Network.updatePushEnabled(isPushEnabled: isPushEnabled)
        .then((value) async {
      AppUser user = await WebService.getCurrentUser();

      final followers = user.followers!;
      final styleList = user.stylesList!;

      AppUser updatedUser = AppUser(
          profile: Profile.fromJson(value),
          // artist: artistList.value,
          stylesList: styleList,
          followers: followers);
      await WebService.setCurrentUser(updatedUser);
      initUser();
    });
    update();
  }
}
