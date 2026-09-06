import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/userController.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/data/source/network/firebase_api.dart';
import 'package:ink/src/ui/screen/sendTattoRquest/sending_request_success.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../../../data/model/image_model.dart';
import '../../../../data/source/network/user_api.dart';
import '../../../../utils/common.dart';
import '../../../../utils/webService.dart';
import '../../../widgets/bodyparts/bodyparts.dart';

class ImgListController extends GetxController {
  RxList imgList = [].obs;
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final aboutController = TextEditingController();

  RxBool isbodyFrontPart = true.obs;
  RxBool isNotLoading = true.obs;
  final userController = Get.put(UserController());

  Rx<BodyParts> bodyParts = const BodyParts().obs;
  Rx<BodyParts> blankBodyParts = const BodyParts().obs;

  Rx<File> frontImage = File("").obs;
  Rx<File> backImage = File("").obs;
  var directoryName = "bodyPartImage";
  final String fileName = WebService.generateRandomString(20);
  String styleList = "";
  RxBool isNewRequestLoading = false.obs;

  ScreenshotController screenshotController = ScreenshotController();

  addImage(item) {
    imgList.add(item);
    imgList.refresh();
  }

  deleteImage(index) {
    imgList.removeAt(index);
    imgList.refresh();
  }

  Future WithcaptureImage(
      {screenshotController,
      selectedCreatorId,
      tattooSize,
      required List<RequestImages> imgListDetails,
      bid}) async {
    Directory? directory = await getTemporaryDirectory();
    String path = directory.path;
    await Directory('$path/$directoryName').create(recursive: true);
    await screenshotController
        .capture(delay: const Duration(milliseconds: 100))
        .then((capturedImage) async {
      File("$path/$directoryName/$fileName.png")
          .writeAsBytesSync(capturedImage!);

      final File file = File("$path/$directoryName/$fileName.png");
      styleList = "";
      if (WebService.changeUserStyleList != []) {
        WebService.changeUserStyleList.forEach((v) async {
          if (v == WebService.changeUserStyleList.last) {
            styleList += "${v.name}";
          } else {
            styleList += "${v.name} ,";
          }
        });
      }

      Get.off(const SendingRequestSuccess());
      await FireBaseApi.userRequestImagesUpload(
              imgList: imgList, imgNameList: imgListDetails)
          .then((value) async {
        try {
          // final NotificationController requestListController =
          //     Get.put(NotificationController());
          AppUser user = await WebService.getCurrentUser();
          await Network.requestTattooApi(
              name: user.profile!.name!,
              phone: user.profile!.phone!,
              description: aboutController.text,
              tattooSize: tattooSize,
              frontData: WebService.isBodySideFront
                  ? bodyParts.value.toJson().toString()
                  : "",
              backData: WebService.isBodySideFront
                  ? ""
                  : bodyParts.value.toJson().toString(),
              artistId: selectedCreatorId,
              businessId: bid,
              requestImages: jsonEncode(imgListDetails),
              backDataImage: File(""),
              frontDataImage: file,
              styles: styleList,
              isContactRequest: "1");
        } catch (e) {
          WebService.printMsg(e.toString());
          displayMessageIcon(
              message: "$e",
              snackposition: SnackPosition.BOTTOM,
              color: errorColor,
              imageData: AppAssets.errorIcon);
        }
      }).catchError((onError) {
        WebService.printMsg(onError);
      });
    });
  }

  Future captureImage(
      {screenshotController,
      selectedCreatorId,
      tattooSize,
      required List<RequestImages> imgListDetails,
      bid}) async {
    Directory? directory = await getTemporaryDirectory();
    String path = directory.path;
    await Directory('$path/$directoryName').create(recursive: true);

    await screenshotController
        .capture(delay: const Duration(milliseconds: 100))
        .then((capturedImage) async {
      File("$path/$directoryName/$fileName.png")
          .writeAsBytesSync(capturedImage!);

      final File file = File("$path/$directoryName/$fileName.png");
      styleList = "";
      WebService.changeUserStyleList.forEach((v) async {
        if (v == WebService.changeUserStyleList.last) {
          styleList += "${v.name}";
        } else {
          styleList += "${v.name} ,";
        }
      });

      try {
        AppUser user = await WebService.getCurrentUser();
        await Network.requestTattooApi(
                name: user.profile!.name!,
                phone: user.profile!.phone!,
                description: aboutController.text,
                tattooSize: tattooSize,
                frontData: WebService.isBodySideFront
                    ? bodyParts.value.toJson().toString()
                    : "",
                backData: WebService.isBodySideFront
                    ? ""
                    : bodyParts.value.toJson().toString(),
                artistId: selectedCreatorId,
                businessId: bid,
                requestImages: jsonEncode(imgListDetails),
                backDataImage: File(""),
                frontDataImage: file,
                styles: styleList,
                isContactRequest: "1")
            .then((value) => Get.off(const SendingRequestSuccess()));
      } catch (e) {
        WebService.printMsg(e.toString());
        displayMessageIcon(
            message: "$e",
            snackposition: SnackPosition.BOTTOM,
            color: errorColor,
            imageData: AppAssets.errorIcon);
      }
    }).catchError((onError) {
      WebService.printMsg(onError);
    });
  }

  Future directSendRequest({bid}) async {
    try {
      // final NotificationController requestListController =
      //     Get.put(NotificationController());
      AppUser user = await WebService.getCurrentUser();
      await Network.requestTattooApi(
              name: user.profile!.name!,
              description: "",
              phone: user.profile!.phone!,
              tattooSize: "",
              frontData: "",
              backData: "",
              artistId: "",
              businessId: bid,
              requestImages: "",
              backDataImage: File(""),
              frontDataImage: File(""),
              styles: "",
              isContactRequest: '2')
          .then((value) async {
        if (value != false && value != null) {
          Get.off(const SendingRequestSuccess());
        } else {
          isNewRequestLoading.value = false;
          return false;
        }
      });
      // displayMessage("alerts.request_sent", Colors.green);
    } catch (e) {
      WebService.printMsg(e.toString());

      displayMessageIcon(
          message: e.toString(),
          snackposition: SnackPosition.BOTTOM,
          color: errorColor,
          imageData: AppAssets.errorIcon);
      // displayMessage("$e", Colors.redAccent);
    }
  }
}
