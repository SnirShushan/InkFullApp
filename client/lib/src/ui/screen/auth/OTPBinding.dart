import 'package:get/get.dart';

import 'otpController.dart';

class OTPBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut<OTPController>(() => OTPController());
  }
}
