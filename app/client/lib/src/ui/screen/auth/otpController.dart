import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../../utils/webService.dart';

class OTPController extends GetxController {
  TextEditingController textEditingController = TextEditingController();
  var messageCode = "".obs;
  var isLoading = false.obs;
  var errorMsg = "".obs;
  String resendVerificationId = "";

  late Timer timer;
  RxBool isResendEnabled = false.obs;
  RxBool isResendLoading = false.obs;
  RxInt countDownTime = 60.obs;

  @override
  void onInit() {
    super.onInit();
    SmsAutoFill().listenForCode();
    SmsAutoFill().getAppSignature.then((value) {
      WebService.printMsg("appSigneture :$value");
    });
  }

  //timer countdown
  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer1) {
      if (countDownTime.value == 0) {
        timer1.cancel();
        isResendEnabled.value = true;
      } else {
        countDownTime.value--;
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    timer.cancel();
    textEditingController.dispose();
    SmsAutoFill().unregisterListener();
  }
}
