import 'package:get/get.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/utils/webService.dart';

import '../data/model/check_subscription_model.dart';

class StartupController extends GetxController {
  RxString startup_image = "".obs;
  RxString subscriptiondata = "".obs;
  CheckSubscriptionModel subscriptionModel =
      CheckSubscriptionModel(subscriptionStatus: 0);
  RxBool isLoading = false.obs;
  bool isNewLoading = false;
  RxBool isFixedAdClosed = true.obs;

  @override
  void onInit() {
    super.onInit();
    // getStartupImage();
  }

  Future getStartupImage() async {
    if (isNewLoading) return;
    isNewLoading = true;
    try{
      final isAdClosed = await WebService.getAdClosed();

      if (isAdClosed == null) {
        await Network.getStartupImage().then((value) async {
          if (value != false && value != null) {
            startup_image.value = value['startup_image'];
          }
        });
      }
    }catch(e){

    }finally{
      isNewLoading = false;
    }
  }

  Future getStartupImage6() async {
    await Network.getStartupImage().then((value) async {
      if (value != false && value != null) {
        print("startup_image.value ${startup_image.value}");
        startup_image.value = value['startup_image'];
      }
    });
  }

  Future checkSubscription({int isAddPost = 0}) async {
    await Network.checkSubscriptionApi(isAddPost: isAddPost).then((value) {
      if (value != false) {
        subscriptionModel = CheckSubscriptionModel.fromJson(value);
        print("Startup subscriptionModel:-> $subscriptionModel");
        print("Startup subscriptionModel:-> ${subscriptionModel.isPremium}");
        update();
      }
    });
  }
}
