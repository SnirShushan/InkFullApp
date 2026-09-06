import 'package:get/get.dart';

class ProgressController extends GetxController{

  RxDouble currentProgress = 0.0.obs;

  updateProgress(double progress){
    currentProgress.value = progress;
    update();
  }

}