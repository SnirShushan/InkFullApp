import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/dashboard_controller.dart';
import 'package:ink/src/ui/screen/bussiness_profiles/screen_bussiness_profiles.dart';
import 'package:ink/src/ui/screen/home/homescreen.dart';
import 'package:ink/src/ui/screen/inspiration/inspirations_screen.dart';
import 'package:ink/src/ui/screen/profile/drawer/business_profile_menu_screen.dart';
import 'package:ink/src/ui/widgets/fixed_ad_card.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/webService.dart';

import '../../../utils/colors.dart';
import '../../widgets/unfocus_widget.dart';

class DashBoard extends StatefulWidget {
  final int initialIndex;

  const DashBoard({Key? key, required this.initialIndex}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GetBuilder<DashBoardController>(builder: (controller) {
      if (controller.init.value) {
        controller.setAdClosed();
        controller.tabIndex = widget.initialIndex;
        controller.init.value = false;
      }
      controller.attachPageController();

      return UnFocusWidget(
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
                backgroundColor: scaffoldBg,
                body: PageView(
                  controller: controller.pageController,
                  onPageChanged: (index) {
                    if (controller.tabIndex != index) {
                      controller.changeTabIndex(index, fromSwipe: true);
                    }
                  },
                  children: [
                    const HomeScreen(),
                    InspirationScreen(),
                    BusinessProfiles(),
                    const BusinessProfileMenuScreen()
                  ],
                ),
                bottomNavigationBar: SafeArea(
                  top: false,
                  child: BottomNavigationBar(
                  elevation: 0,
                  type: BottomNavigationBarType.fixed,
                  currentIndex: controller.tabIndex,
                  onTap: controller.changeTabIndex,
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
                        label: 'בית'), //Home
                    _bottomNavigationBarItem(
                        size: size,
                        iconName: AppAssets.searchdashboard,
                        activeIconName: AppAssets.search_filled_dashboard,
                        label: 'השראה'), //inspiration
                    _bottomNavigationBarItem(
                        size: size,
                        iconName: AppAssets.artistsdashboard,
                        activeIconName: AppAssets.artists_filled_dashboard,
                        label: 'מקעקעים'), //tattoos
                    _bottomNavigationBarItem(
                        size: size,
                        iconName: AppAssets.profiledashboard,
                        activeIconName: AppAssets.profile_filled_dashboard,
                        label: 'פרופיל'), //profile
                  ],
                ),
                ),
              ),
      );
    });
  }

  //bottom item
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
}
