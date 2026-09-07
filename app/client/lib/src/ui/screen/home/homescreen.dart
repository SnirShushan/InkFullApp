
import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/business_dashboard.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/bussinessdashboard_binding.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard_binding.dart';
import 'package:ink/src/ui/screen/home/controller/home_screen_controller.dart';
import 'package:ink/src/ui/screen/home/imageDetails/post_details.dart';
import 'package:ink/src/ui/screen/home/widgets/home_styles_widget.dart';
import 'package:ink/src/ui/screen/home/widgets/tatto_styles_widget.dart';
import 'package:ink/src/ui/screen/notification/notifications.dart';
import 'package:ink/src/utils/DynamicLinkService.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/shared_preference_helper.dart';
import 'package:ink/src/utils/webService.dart';

import '../../../utils/colors.dart';
import 'widgets/business_card_widget.dart';
import 'widgets/new_user_widget.dart';
import 'widgets/home_post_grid_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final DynamicLinkService _dynamicLinkService = DynamicLinkService();
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  Timer? _timer;
  final HomeScreenController _homeScreenController =
      Get.put(HomeScreenController());

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _checkLaunchMode();
    _setupFCM();
    super.initState();
  }

  void _setupFCM() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("Foreground message: $message");
      // Optional: Show a dialog/snackbar or direct navigation
    });
  }

  Future<void> _checkLaunchMode() async {
    final isApiHoldTime = await SharedPreferencesHelper.getHomeApiHoldTime();

    if (isApiHoldTime == null) {
      await SharedPreferencesHelper.saveHomeApiHoldTime();
    }

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print("Firebase message initialMessage:-> $initialMessage");
      _handleMessage(initialMessage);
    } else {}
  }

  void _handleMessage(RemoteMessage message) async {
    final data = message.data;

    if (data.containsKey('screen')) {
      try {
        if (!WebService.isSplashHomeScreen) {
          WebService.isSplashHomeScreen = true;
        }

        final screen = data['screen']?.toString();
        final pid = data['pid']?.toString() ?? '';
        final isRequest = data['is_request']?.toString() == "1";

        if (screen == "new_post" || screen == "post_mention") {
          print(screen.toString());
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.to(() => PostDetails(postId: pid, isArtist: false));
          });
        } else {
          Get.to(() => NotificationScreen(
                isRequest: isRequest,
                isPushNotification: false,
              ));
        }
      } catch (e) {
        displayMessageIcon(
          message: e.toString(),
          color: errorColor,
          snackposition: SnackPosition.BOTTOM,
          imageData: AppAssets.errorIcon,
        );
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _timer = Timer(
        const Duration(milliseconds: 100),
        () => _dynamicLinkService.retrieveDynamicLink(context),
      );
    } else if (state == AppLifecycleState.paused && _timer?.isActive == true) {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      key: _key,
      backgroundColor: scaffoldBg,
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        controller: _homeScreenController.scrollController,
        child: Padding(
          padding: EdgeInsets.only(
              left: size.width * 0.045,
              right: size.width * 0.045,
              bottom: 12.0,
              top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildtitlebackbold(
                  title: "home_screen.tatto_styles",
                  context: context,
                  onTap: () async {
                    AppUser user = await WebService.getCurrentUser();
                    final isBusiness = await WebService.getIsBusiness();

                    if (user.profile?.styles?.isEmpty == false) {
                      final selectedList = user.stylesList!
                          .where((style) =>
                              user.profile!.styles!.contains(style.slug!))
                          .toList();
                      WebService.selectstylelist.addAll(selectedList);
                    }

                    if (isBusiness) {
                      Get.offAll(BusinessDashBoard(initialIndex: 1),
                          binding: BusinessDashBoardBinding());
                    } else {
                      Get.offAll(const DashBoard(initialIndex: 1),
                          binding: DashBoardBinding());
                    }
                  }),
              TattoStylesWidget(homeScreenController: _homeScreenController),
              dividerHome(size),
              buildtitlebackbold(
                  title: "home_screen.recommended_tatto",
                  context: context,
                  onTap: () async {
                    final isBusiness = await WebService.getIsBusiness();

                    if (isBusiness) {
                      Get.offAll(BusinessDashBoard(initialIndex: 3),
                          binding: BusinessDashBoardBinding());
                    } else {
                      Get.offAll(const DashBoard(initialIndex: 2),
                          binding: DashBoardBinding());
                    }
                  }),
              BusinessCardWidget(homeScreenController: _homeScreenController),
              dividerHome(size),
              buildtitlebold(
                title: "home_screen.tatto_by_style",
                context: context,
              ),
              const HomeStylesWidget(),
              dividerHome(size),
              buildtitlebold(
                title: "home_screen.new_tatto",
                context: context,
              ),
              NewUserWidget(homeScreenController: _homeScreenController),
              dividerHome(size),

              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),

              HomePostGridWidget(homeScreenController: _homeScreenController)
            ],
          ),
        ),
      ),
    );
  }

  PreferredSize buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.12),
      child: AppBar(
          elevation: 0,
          backgroundColor: scaffoldBg,
          flexibleSpace: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        if (!WebService.isSplashHomeScreen) {
                          WebService.isSplashHomeScreen = true;
                        }
                        _homeScreenController.scrollController.animateTo(
                          0,
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeInOut,
                        );

                        _homeScreenController.scrollController.jumpTo(0.0);
                        _homeScreenController.stylePosts.clear();
                        _homeScreenController.getHomeController();
                      },
                      child: SvgPicture.asset(
                        AppAssets.homeLogoSVG,
                        height: MediaQuery.of(context).size.height * 0.08,
                        width: MediaQuery.of(context).size.height * 0.08,
                      ),
                    ),
                    InkWell(
                      onTap: () => Get.to(const NotificationScreen()),
                      child: Obx(() => SvgPicture.asset(
                          _homeScreenController.isNewNotification.value ==
                                      "0" ||
                                  _homeScreenController
                                          .isNewNotification.value ==
                                      "2" ||
                                  _homeScreenController
                                          .isNewNotification.value ==
                                      ""
                              ? AppAssets.bellInactiveIcon
                              : AppAssets.bellActiveIcon,
                          height: MediaQuery.of(context).size.height * 0.04,
                          width: MediaQuery.of(context).size.height * 0.04)),
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }

  Padding buildtitlebackbold(
      {required BuildContext context,
      required String title,
      required VoidCallback onTap}) {
    var size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
      child: InkWell(
        splashColor: Colors.grey,
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              tr(title),
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: 20,
                  color: titleTextWhiteColor,
                  fontWeight: FontWeight.w700),
            ),
            SvgPicture.asset(
              AppAssets.backside,
            ),
          ],
        ),
      ),
    );
  }

  Padding buildtitlebold(
      {required BuildContext context, required String title}) {
    var size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
      child: Text(
        tr(title),
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontSize: 20,
            color: titleTextWhiteColor,
            fontWeight: FontWeight.w700),
      ),
    );
  }

  dividerHome(Size size) => Padding(
        padding: EdgeInsets.only(top: size.height * 0.01),
        child: const Divider(thickness: 2, color: dividerGray),
      );
}
