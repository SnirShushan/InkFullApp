import 'package:get/get.dart';
import 'package:ink/src/controller/network_controller.dart';
import 'package:ink/src/ui/screen/sendTattoRquest/controller/imgListController.dart';

class DependencyInjection {
  static void init() {
    Get.put<NetworkController>(NetworkController(), permanent: true);

    Get.lazyPut<ImgListController>(() => ImgListController());
    // Get.lazyPut<FollowedUsersController>(() => FollowedUsersController());
  }
}
