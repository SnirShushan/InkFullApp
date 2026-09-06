import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/dashboard_controller.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard_binding.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';

class DashboardBottomBar extends StatelessWidget {
  final int currentIndex;

  DashboardBottomBar({super.key, required this.currentIndex});

  final DashBoardController _dashBoardController =
      Get.put(DashBoardController());
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BottomNavigationBar(
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) {
        _dashBoardController.changeTabIndex(index);
        Get.offAll(DashBoard(initialIndex: index), binding: DashBoardBinding());
      },
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
            label: 'בית'),
        _bottomNavigationBarItem(
            size: size,
            iconName: AppAssets.searchdashboard,
            activeIconName: AppAssets.search_filled_dashboard,
            label: 'השראה'), //inspiration
        _bottomNavigationBarItem(
            size: size,
            iconName: AppAssets.artistsdashboard,
            activeIconName: AppAssets.artists_filled_dashboard,
            label: 'מקעקעים'), //notification
        _bottomNavigationBarItem(
            size: size,
            iconName: AppAssets.profiledashboard,
            activeIconName: AppAssets.profile_filled_dashboard,
            label: 'פרופיל'),
      ],
    );
  }

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
