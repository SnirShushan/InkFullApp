import 'package:get/get.dart';
import 'package:ink/src/controller/businessProfilecontroller.dart';
import 'package:ink/src/ui/screen/home/controller/home_screen_controller.dart';
import 'package:ink/src/ui/screen/profile/drawer/followers/followed_users_controller.dart';

import '../../../controller/dashboard_controller.dart';

class DashBoardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashBoardController>(() => DashBoardController());
    Get.lazyPut<HomeScreenController>(() => HomeScreenController());
    Get.lazyPut<FollowedUsersController>(() => FollowedUsersController());
    Get.lazyPut<BusinessProfileController>(() => BusinessProfileController());

  }
}
