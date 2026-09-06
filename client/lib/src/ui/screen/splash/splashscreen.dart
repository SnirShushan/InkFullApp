import 'dart:async';
import 'dart:io';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/ui/screen/auth/login.dart';
import 'package:ink/src/ui/screen/auth/registration_screen.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/business_dashboard.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/bussinessdashboard_binding.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard_binding.dart';
import 'package:ink/src/ui/screen/home/controller/home_screen_controller.dart';
import 'package:ink/src/ui/screen/home/imageDetails/post_details.dart';
import 'package:ink/src/ui/screen/profile/businessStudioProfile.dart';
import 'package:ink/src/ui/screen/profile/businessUserProfile.dart';
import 'package:ink/src/ui/screen/splash/welcome_screen.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/shared_preference_helper.dart';
import 'package:ink/src/utils/webService.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../controller/userController.dart';
import '../../../data/source/network/user_api.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  UserController userController = Get.put(UserController());
  // static const String businessUserProfileLink =
  //     "https://itapp2u.com/apps/Inkapp/api/profile/businessUserProfile";
  // static const String businessStudioProfileLink =
  //     "https://itapp2u.com/apps/Inkapp/api/profile/businessStudioProfile";
  // static const String mainprofileLink =
  //     "https://itapp2u.com/apps/Inkapp/api/profile/mainprofile";
  //
  // static const String businessUserProfileLink2 =
  //     "https://inkisrael.co.il/api/profile/businessUserProfile";
  // static const String businessStudioProfileLink2 =
  //     "https://inkisrael.co.il/api/profile/businessStudioProfile";
  // static const String mainprofileLink2 =
  //     "https://inkisrael.co.il/api/profile/mainprofile";

  // Future initUser() async => await userController.initUser();
  Uri? dynamiclink;
  String checklink = "";
  String user_dynamic_id = "";

  @override
  void initState() {
    super.initState();
    // Don't block startup for 7s — navigate as soon as init finishes (min ~1.2s for splash feel).
    _bootAndNavigate();
  }

  Future<void> _bootAndNavigate() async {
    final started = DateTime.now();
    try {
      await _initialization();
    } catch (_) {}
    final elapsed = DateTime.now().difference(started);
    final remaining = const Duration(milliseconds: 1200) - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }
    if (!mounted) return;
    await _checkFirstScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF16121A),
        body: Center(
          child: Image.asset("assets/images/Splash.gif"),
        ));
  }

  Future<void> _initialization() async {
    PendingDynamicLinkData? data;

    if (Platform.isIOS) {
      FirebaseDynamicLinks.instance.onLink
          .listen((PendingDynamicLinkData dynamicLinkData) async {
        if (dynamicLinkData.link != null) {
          dynamiclink = dynamicLinkData.link;
          String link = dynamicLinkData.link.toString();
          checklink = await extractBaseUrl(link);
          user_dynamic_id =
              extractLastSlashValue(dynamicLinkData.link.toString());
        } else {
          dynamiclink = null;
          checklink = "";
          user_dynamic_id = "";
        }
      }).onError((error) {
        print('Error getting dynamic link: $error');
      });
    } else {
      data = await FirebaseDynamicLinks.instance.getInitialLink();
      dynamiclink = data?.link;
      if (dynamiclink != null) {
        // String link = dynamiclink.toString();
        // checklink = await extractBaseUrl(link);
        // user_dynamic_id = extractLastSlashValue(dynamiclink.toString());
        checklink = "";
        user_dynamic_id = "";
      } else {
        dynamiclink = null;
        checklink = "";
        user_dynamic_id = "";
      }
    }
    _getHomeData();
    setState(() {});
  }

  Future<void> _getHomeData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String users = prefs.getString('user') ?? "";
      if (users != null && users != '') {
        userController.initUser().then((value) async {
          WebService.isSplashHomeScreen = false;
          final HomeScreenController _homeScreenController =
              Get.put(HomeScreenController());
          _homeScreenController.getHomeController();
        });
      }
    } catch (e) {
      WebService.isSplashHomeScreen = true;
    }
  }

  Future _checkFirstScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Develop mode: skip welcome + OTP, login as fixed phone, open Home.
    if (WebService.developerMode) {
      await prefs.setBool("intro_screen", true);
      try {
        // Always re-login against the new API so login_token is fresh.
        final ready = await Network.devAutoLogin(WebService.devSkipPhone);
        if (ready) {
          WebService.isSplashHomeScreen = false;
          final HomeScreenController home = Get.put(HomeScreenController());
          home.getHomeController();
          Get.offAll(
              () => const DashBoard(initialIndex: 0),
              binding: DashBoardBinding());
          return;
        }
      } catch (e) {
        WebService.printMsg("dev auto-login failed: $e");
      }
    }

    bool introScreen = (prefs.getBool('intro_screen') ?? false);
    String user = prefs.getString('user') ?? "";
    if (introScreen) {
      if (user == null || user == '') {
        Get.offAll(() => const LoginScreen());
      } else {
        await SharedPreferencesHelper.clearData();
        AppUser _appuser = await WebService.getCurrentUser();
        if (dynamiclink != null) {

          String action = "";
          String userDynamicId = "";

          if (dynamiclink != null) {
            try {
              String link = dynamiclink.toString();
              final Uri parsedUri = Uri.parse(link);

              action = parsedUri.queryParameters['action'] ?? "";
              userDynamicId = parsedUri.queryParameters['pid'] ?? "";

              userController.initUser().then((value) {
                if (action == "mainprofile") {
                  if (_appuser.profile!.id.toString() == userDynamicId) {
                    if (_appuser.profile!.userType.toString() == "1") {
                      Get.offAll(() => BusinessProfileScreen(
                          dynamictxt: "DYNAMICTEXT",
                          bId: userDynamicId,
                          fromPost: true));
                    } else {
                      Get.offAll(
                          () => BusinessDashBoard(
                                initialIndex: 4,
                              ),
                          binding: BusinessDashBoardBinding());
                    }
                  } else {
                    Get.offAll(() => BusinessProfileScreen(
                        dynamictxt: "DYNAMICTEXT",
                        bId: userDynamicId,
                        fromPost: true));
                  }
                } else if (action == "businessUserProfile") {
                  Get.to(() => BusinessProfileScreen(
                      dynamictxt: "DYNAMICTEXT",
                      bId: userDynamicId,
                      fromPost: true));
                } else if (action == "businessStudioProfile") {
                  Get.offAll(() => StudioProfileScreen(
                      dynamictxt: "DYNAMICTEXT",
                      bId: userDynamicId,
                      fromPost: true));
                } else {
                  Get.offAll(() => PostDetails(
                      dynamictxt: "DYNAMICTEXT",
                      postId: userDynamicId,
                      isArtist: false));
                }
              });
            } catch (e) {
              if (userDynamicId != "" && userDynamicId != null) {
                Get.to(() => PostDetails(
                    dynamictxt: "DYNAMICTEXT",
                    postId: userDynamicId,
                    isArtist: false));
              }
            }
          }
        } else {
          userController.initUser().then((value) async {
            try {
              final isBusiness = await WebService.getIsBusiness();
              AppUser user = await WebService.getCurrentUser();
              print("user $user");

              if (user.profile?.isRegister == "1") {
                var data = await WebService.getRegistrationData();
                bool ismobile = data == "false" ? false : true;
                Get.offAll(() => RegistrationScreen(
                    phonenoReg: user.profile?.phone ?? "",
                    nameReg: user.profile?.name ?? "",
                    emailReg: user.profile?.email ?? "",
                    isphonenumberLogin: ismobile));
              } else {
                if (userController.userType.value == "1" ||
                    isBusiness == false) {
                  Get.offAll(
                      () => const DashBoard(
                            initialIndex: 0,
                          ),
                      binding: DashBoardBinding());
                } else {
                  Get.offAll(() => BusinessDashBoard(initialIndex: 0),
                      binding: BusinessDashBoardBinding());
                }
              }
            } catch (e) {
              displayMessageIcon(
                  message: e.toString(),
                  snackposition: SnackPosition.BOTTOM,
                  color: errorColor,
                  imageData: AppAssets.errorIcon);
              // displayMessage(e.toString(), Colors.deepOrange);
              WebService.printMsg(e.toString());
            }
          });
        }
      }
    } else {
      await prefs.setBool("intro_screen", true);
      Get.offAll(const WelcomeScreen(isFromChangeUserScreen: false));
    }

    // Get.offAll(BusinessProfileMenuScreen());
  }

  String extractLastSlashValue(String url) {
    final parts = url.split('/');
    return parts.last.isNotEmpty
        ? parts.last
        : (parts.length > 1 ? parts[parts.length - 2] : '');
  }

  String extractBaseUrl(String url) {
    Uri uri = Uri.parse(url);
    return '${uri.scheme}://${uri.host}${uri.path.split('/').take(6).join('/')}';
  }
}
