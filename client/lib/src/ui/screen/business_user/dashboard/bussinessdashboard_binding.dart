import 'package:get/get.dart';
import 'package:ink/src/controller/businessProfilecontroller.dart';
import 'package:ink/src/controller/myPostController.dart';
import 'package:ink/src/ui/screen/home/controller/home_screen_controller.dart';
import 'package:ink/src/ui/screen/inspiration/controller/inspiration_controller.dart';

import '../../../../controller/artistsListController.dart';
import '../../../../controller/bussiness_dashboard_controller.dart';

class BusinessDashBoardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BusinessDashBoardController>(
        () => BusinessDashBoardController());
    Get.lazyPut<ArtistListController>(() => ArtistListController());
    Get.lazyPut<InspirationController>(() => InspirationController());

    Get.lazyPut<HomeScreenController>(() => HomeScreenController());
    Get.lazyPut<BusinessProfileController>(() => BusinessProfileController());

    Get.lazyPut<MyPostsController>(() => MyPostsController()); // Add this


  }
}
