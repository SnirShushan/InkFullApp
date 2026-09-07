// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/controller/userController.dart';
// import 'package:ink/src/data/model/currentUser.dart';
// import 'package:ink/src/ui/screen/sendTattoRquest/sending_request_success.dart';
// import 'package:path_provider/path_provider.dart';
//
// import '../../../../controller/notificationController.dart';
// import '../../../../data/model/image_model.dart';
// import '../../../../data/source/network/user_api.dart';
// import '../../../../utils/common.dart';
// import '../../../../utils/webService.dart';
// import '../../../widgets/bodyparts/bodyparts.dart';
//
// class ImgListController extends GetxController {
//   RxList imgList = [].obs;
//   final nameController = TextEditingController();
//   final phoneController = TextEditingController();
//   final aboutController = TextEditingController();
//
//   final userController = Get.put(UserController());
//
//   Rx<BodyParts> bodyParts = const BodyParts().obs;
//   Rx<BodyParts> blankBodyParts = const BodyParts().obs;
//
//   Rx<File> frontImage = File("").obs;
//   Rx<File> backImage = File("").obs;
//   var directoryName = "bodyPartImage";
//   final String fileName = WebService.generateRandomString(20);
//   String styleList = "";
//   RxBool isNewRequestLoading = false.obs;
//
//   addImage(item) {
//     imgList.add(item);
//     update();
//   }
//
//   deleteImage(index) {
//     imgList.removeAt(index);
//     update();
//   }
//
//   Future captureImage(
//       {screenshotController,
//       selectedCreatorId,
//       tattooSize,
//       required List<RequestImages> imgListDetails,
//       bid}) async {
//     Directory? directory = await getTemporaryDirectory();
//     String path = directory.path;
//     await Directory('$path/$directoryName').create(recursive: true);
//
//     await screenshotController
//         .capture(delay: const Duration(milliseconds: 10))
//         .then((capturedImage) async {
//       File("$path/$directoryName/$fileName.png")
//           .writeAsBytesSync(capturedImage!);
//
//       final File file = File("$path/$directoryName/$fileName.png");
//
//       if (WebService.changeUserStyleList != null) {
//         styleList = "";
//         WebService.changeUserStyleList.forEach((v) async {
//           if (v == WebService.changeUserStyleList.last) {
//             styleList += "${v.name}";
//             try {
//               AppUser user = await WebService.getCurrentUser();
//               final NotificationController requestListController =
//                   Get.put(NotificationController());
//
//               await Network.requestTattoo(
//                       name: user.profile!.name!,
//                       description: aboutController.text,
//                       phone: user.profile!.phone!,
//                       tattooSize: tattooSize,
//                       frontData: WebService.isBodySideFront
//                           ? bodyParts.value.toJson().toString()
//                           : "",
//                       backData: WebService.isBodySideFront
//                           ? ""
//                           : bodyParts.value.toJson().toString(),
//                       artistId: selectedCreatorId,
//                       businessId: bid,
//                       requestImages: jsonEncode(imgListDetails),
//                       backDataImage: File(""),
//                       frontDataImage: file,
//                       styles: styleList,
//                       isContactRequest: '1')
//                   .then((value) async {
//                 await requestListController.getTattooRequestsList();
//               });
//               displayMessage("alerts.request_sent", Colors.green);
//               await Future.delayed(const Duration(seconds: 2))
//                   .then((value) => Get.offAll(SendingRequestSuccess()));
//             } catch (e) {
//               WebService.printMsg(e.toString());
//               displayMessage("$e", Colors.green);
//             }
//           } else {
//             styleList += "${v.name} ,";
//           }
//         });
//       }
//     }).catchError((onError) {
//       WebService.printMsg(onError);
//     });
//   }
//
//   Future directSendRequest({bid}) async {
//     try {
//       final NotificationController requestListController =
//           Get.put(NotificationController());
//       AppUser user = await WebService.getCurrentUser();
//       await Network.requestTattoo(
//               name: user.profile!.name!,
//               description: "",
//               phone: user.profile!.phone!,
//               tattooSize: "",
//               frontData: "",
//               backData: "",
//               artistId: "",
//               businessId: bid,
//               requestImages: "",
//               backDataImage: File(""),
//               frontDataImage: File(""),
//               styles: "",
//               isContactRequest: '2')
//           .then((value) async {
//         isNewRequestLoading.value = false;
//         await requestListController.getTattooRequestsList();
//       });
//       displayMessage("alerts.request_sent", Colors.green);
//       await Future.delayed(const Duration(seconds: 2))
//           .then((value) => Get.offAll(SendingRequestSuccess()));
//     } catch (e) {
//       WebService.printMsg(e.toString());
//       displayMessage("$e", Colors.green);
//     }
//   }
// }
