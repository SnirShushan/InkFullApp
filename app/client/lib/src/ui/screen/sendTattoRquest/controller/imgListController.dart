import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/userController.dart';
import 'package:ink/src/data/model/currentUser.dart';
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

  String _selectedStyles() {
    final names = WebService.changeUserStyleList
        .map((v) => (v?.name ?? '').toString().trim())
        .where((name) => name.isNotEmpty)
        .toList();
    return names.join(',');
  }

  String _bodyPartsJson() {
    try {
      return jsonEncode(bodyParts.value.toJson());
    } catch (e) {
      WebService.printMsg('body parts json failed: $e');
      return '';
    }
  }

  Future<File?> _tryCaptureBody(screenshotController) async {
    if (screenshotController == null) return null;
    try {
      final capturedImage = await screenshotController.capture(
          delay: const Duration(milliseconds: 80));
      if (capturedImage == null || capturedImage.isEmpty) return null;
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$directoryName/$fileName.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(capturedImage, flush: true);
      return file;
    } catch (e) {
      WebService.printMsg('body screenshot failed: $e');
      return null;
    }
  }

  List<File> _exampleImageFiles() {
    final files = <File>[];
    for (final item in imgList) {
      final path = (item?.path ?? '').toString();
      if (path.isEmpty) continue;
      final file = File(path);
      if (file.existsSync()) files.add(file);
    }
    return files;
  }

  Future sendFullRequest({
    screenshotController,
    selectedCreatorId,
    tattooSize,
    List<RequestImages>? imgListDetails,
    bid,
  }) async {
    final bidStr = (bid ?? '').toString().trim();
    if (bidStr.isEmpty || bidStr == '0') {
      displayMessageIcon(
          message: "לא ניתן לשלוח את הפנייה",
          snackposition: SnackPosition.BOTTOM,
          color: errorColor,
          imageData: AppAssets.errorIcon);
      return false;
    }

    styleList = _selectedStyles();
    final isFront = WebService.isBodySideFront;
    final bodyJson = _bodyPartsJson();
    final shot = await _tryCaptureBody(screenshotController);
    final exampleImages = _exampleImageFiles();
    final requestImages = imgListDetails ?? <RequestImages>[];

    try {
      AppUser user = await WebService.getCurrentUser();
      final sent = await Network.requestTattooApi(
          name: user.profile?.name ?? "",
          phone: user.profile?.phone ?? "",
          description: aboutController.text,
          tattooSize: tattooSize ?? "",
          frontData: isFront ? bodyJson : "",
          backData: isFront ? "" : bodyJson,
          artistId: selectedCreatorId ?? "",
          businessId: bidStr,
          requestImages: jsonEncode(requestImages),
          exampleImages: exampleImages,
          backDataImage: isFront ? File("") : (shot ?? File("")),
          frontDataImage: isFront ? (shot ?? File("")) : File(""),
          styles: styleList,
          isContactRequest: "1");
      if (sent == true) {
        Get.off(const SendingRequestSuccess());
        return true;
      }
      displayMessageIcon(
          message: "לא ניתן לשלוח את הפנייה",
          snackposition: SnackPosition.BOTTOM,
          color: errorColor,
          imageData: AppAssets.errorIcon);
      return false;
    } catch (e) {
      WebService.printMsg(e.toString());
      displayMessageIcon(
          message: "לא ניתן לשלוח את הפנייה",
          snackposition: SnackPosition.BOTTOM,
          color: errorColor,
          imageData: AppAssets.errorIcon);
      return false;
    }
  }

  Future WithcaptureImage(
      {screenshotController,
      selectedCreatorId,
      tattooSize,
      required List<RequestImages> imgListDetails,
      bid}) {
    return sendFullRequest(
        screenshotController: screenshotController,
        selectedCreatorId: selectedCreatorId,
        tattooSize: tattooSize,
        imgListDetails: imgListDetails,
        bid: bid);
  }

  Future captureImage(
      {screenshotController,
      selectedCreatorId,
      tattooSize,
      required List<RequestImages> imgListDetails,
      bid}) {
    return sendFullRequest(
        screenshotController: screenshotController,
        selectedCreatorId: selectedCreatorId,
        tattooSize: tattooSize,
        imgListDetails: imgListDetails,
        bid: bid);
  }

  Future directSendRequest({bid}) async {
    try {
      // final NotificationController requestListController =
      //     Get.put(NotificationController());
      AppUser user = await WebService.getCurrentUser();
      final bidStr = (bid ?? '').toString().trim();
      if (bidStr.isEmpty || bidStr == '0') {
        isNewRequestLoading.value = false;
        displayMessageIcon(
            message: "לא ניתן לשלוח את הפנייה",
            snackposition: SnackPosition.BOTTOM,
            color: errorColor,
            imageData: AppAssets.errorIcon);
        return false;
      }
      await Network.requestTattooApi(
              name: user.profile?.name ?? "",
              description: "",
              phone: user.profile?.phone ?? "",
              tattooSize: "",
              frontData: "",
              backData: "",
              artistId: "",
              businessId: bidStr,
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
