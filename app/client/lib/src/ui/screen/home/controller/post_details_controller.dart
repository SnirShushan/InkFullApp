import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/myPostController.dart';
import 'package:ink/src/controller/notificationController.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/data/source/network/firebase_api.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/business_dashboard.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/bussinessdashboard_binding.dart';
import 'package:ink/src/ui/screen/collections/collection_view.dart';
import 'package:ink/src/ui/screen/notification/notifications.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../data/model/postDetails.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/common.dart';
import '../../../../utils/webService.dart';
import '../../auth/login.dart';

class PostDetailsController extends GetxController {
  //set post model
  Rx<MPostDetails> postModel = MPostDetails().obs;

  RxBool isLoading = true.obs;
  RxBool isDeleteLoading = false.obs;
  RxBool isShareLoading = false.obs;
  RxBool isFollowLoading = false.obs;
  RxBool isEditPostLoading = false.obs;
  RxBool isFirebaseLoading = false.obs;
  RxInt currentCarouselSliderPage = 0.obs;
  var historyStack = <MPostDetails>[].obs;
  static const reportMsg1 = "דיווח על עסק לא קיים";
  static const reportMsg2 = "תמונות שלא עומדת בנהלים";
  final myPostController = Get.put(MyPostsController());
  RxList<String> savedFolderList = <String>[].obs;
  Rx<AppUser> appUser = AppUser().obs;
  RxList<String> collectionsList = <String>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _initialized();
  }

  static sessionExpired({msg}) async {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    await WebService.clearUserData();
    displayMessageIcon(
        message: msg.toString(),
        snackposition: SnackPosition.BOTTOM,
        color: errorColor,
        imageData: AppAssets.errorIcon);
    Get.offAll(() => const LoginScreen());
  }

  //get post details
  Future getPostDetailsController(
      {required String pid,
      required String foldersid,
      bool isStyles = false}) async {
    await Future.microtask(() {
      savedFolderList.clear();
      postModel.value = MPostDetails();
      isLoading.value = true;
    });

    try {
      await Network.getPostDetails(pid: pid).then((value) async {
        if (value != false && value != null) {
          postModel.value = await MPostDetails.fromJson(value);

          if (postModel.value != null) {
            if (postModel.value.owner == null) {
              if (foldersid != "") {
                await FireBaseApi.removeFolderImageFromPostSpecificUser(
                    postid: postModel.value.id!, foldersId: foldersid);
                await FireBaseApi.removeFolderFromPostSpecificUser(
                    imageurl: postModel.value.imageName!, fid: foldersid);
                Get.back();
              } else {
                Get.back();
              }
            } else {
              await getCollectionList().then((value) async {
                AppUser user = await WebService.getCurrentUser();
                await FirebaseFirestore.instance
                    .collection('foldersImages')
                    .where('imageId', isEqualTo: postModel.value.imageId)
                    .where('pid', isEqualTo: pid)
                    .where('firebase_id',
                        isEqualTo: user.profile!.firebaseId.toString())
                    .get()
                    .then((value) {
                  value.docs.map((e) {
                    if (e.exists) {
                      if (collectionsList.contains(e.data()["fid"])) {
                        savedFolderList.add(e.data()["fid"]);
                      }
                    }
                  }).toList();
                });
              });
            }
          }
        }
      });
    } finally {
      savedFolderList.refresh();
      postModel.refresh();
      isLoading.value = false;
    }
  }

  //update post member
  Future updatePostMemberController({memberId, postId, foldersid}) async {
    final uid = Network.userController.id.value;
    await Network.updatePostMember(
        uid: uid, memberId: memberId, postId: postId);
    await getPostDetailsController(pid: postId, foldersid: foldersid);
  }

  //report post
  Future reportPost(
      {pid, required int reportMsg, required String reportMsgDetails}) async {
    await Network.reportPost(
            pid: pid,
            comment: reportMsg == 1
                ? reportMsg1 + reportMsgDetails
                : reportMsg2 + reportMsgDetails)
        .then((value) {
      WebService.printMsg(value.toString());
      final status = value["status"].toString();
      final msg = value["msg"].toString();
      if (status == "1") {
        displayMessageIcon(
            message: "הדיווח נשלח בהצלחה!",
            color: successGreen,
            imageData: AppAssets.correct_transparentIcon);
        // Get.back();
        // Get.back();
        // displayReportMessage(msg, Colors.purple);
      } else if (status == "2") {
        displayReportMessage(msg, Colors.white);
        sessionExpired(msg: msg);
      } else {
        // displayReportMessage(msg, Colors.white);
      }
    });
  }

  Future reportUsers(
      {bid, required int reportMsg, required String reportMsgDetails}) async {
    await Network.reportBusiness(comment: reportMsgDetails, bid: bid)
        .then((value) {
      WebService.printMsg(value.toString());
      final status = value["status"].toString();
      final msg = value["msg"].toString();
      if (status == "1") {
        Get.back();
        Get.back();
        displayReportMessage(msg, Colors.purple);
      } else if (status == "2") {
        Get.back();
        Get.back();
        displayReportMessage(msg, Colors.white);
        sessionExpired(msg: msg);
      } else {
        displayReportMessage(msg, Colors.white);
      }
    });
  }

  //update post
  Future updatePostController(
      {context,
      imageId,
      imageNmae,
      artistId,
      styles,
      description,
      postId,
      studioId}) async {
    try {
      await Network.updatePostApi(
          styles: styles ?? "",
          description: description ?? "",
          postId: postId,
          artistId: artistId ?? "",
          studioId: studioId ?? "",
          imageId: imageId ?? "",
          imageName: imageNmae ?? "");

      await getPostDetailsController(pid: postId, foldersid: "");
      await myPostController.getMyPosts();
      isEditPostLoading.value = false;
      getBack(context);
    } catch (e) {
      displayMessageIcon(
          message: e.toString(),
          snackposition: SnackPosition.BOTTOM,
          color: errorColor,
          imageData: AppAssets.errorIcon);
    }
  }

  // sharedPost(
  //     {required String userid,
  //     required BuildContext context,
  //     required String imageUrl}) async {
  //   isShareLoading.value = true;
  //   try {
  //     final response = await http.get(Uri.parse(imageUrl));
  //     final temporaryFile = await _saveImageToTemp(response.bodyBytes);
  //
  //     await Future.delayed(const Duration(
  //         seconds: 1)); // Consider removing this delay if unnecessary
  //
  //     final box = context.findRenderObject() as RenderBox?;
  //
  //     final shareFiles = [
  //       XFile(temporaryFile.path, name: DateTime.now().toIso8601String()),
  //     ];
  //     await Share.shareXFiles(shareFiles,
  //         text:
  //             "https://inkapp.page.link/?link=https://itapp2u.com/apps/Inkapp/api/$userid&apn=com.itapp2u.ink",
  //         sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error sharing post: $e');
  //     }
  //   } finally {
  //     isShareLoading.value = false;
  //   }
  //
  //   // isShareLoading.value = true;
  //   //
  //   // var response = await http.get(Uri.parse(imageUrl));
  //   //
  //   // final directory = await getTemporaryDirectory();
  //   // final path = directory.path;
  //   // final fileName = WebService.generateRandomString(10);
  //   // final file = File('$path/$fileName.png');
  //   //
  //   // file.writeAsBytes(response.bodyBytes);
  //   //
  //   // await Future.delayed(const Duration(seconds: 1));
  //   //
  //   // final box = context.findRenderObject() as RenderBox?;
  //   //
  //   // final files = <XFile>[];
  //   // files.add(XFile(file.path, name: DateTime.now().toIso8601String()));
  //   // await Share.shareXFiles(files,
  //   //     text:
  //   //         "https://inkapp.page.link/?link=https://itapp2u.com/apps/Inkapp/api/$userid&apn=com.itapp2u.ink",
  //   //
  //   //     // subject: "subject",
  //   //     sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
  //   //
  //   // isShareLoading.value = false;
  // }

  Future<File> _saveImageToTemp(List<int> imageBytes) async {
    final directory = await getTemporaryDirectory();
    final path = directory.path;
    final fileName =
        '${DateTime.now().toIso8601String()}.png'; // Add .png extension
    final file = File('$path/$fileName');

    await file.writeAsBytes(imageBytes);
    return file;
  }

  void navigateToPost({
    required MPostDetails post,
    required String postid,
    required String foldersid,
    required String wpostId,
  }) {
    historyStack.add(post); // Set the new post as the current post
    getPostDetailsController(
        pid: postid,
        foldersid: foldersid); // Fetch related items for the new post
  }

  Future<void> navigateBack({
    required BuildContext context,
    required bool isNotificationscreen,
    required bool isNotification,
    required String foldersid,
    String imageUrlsCollection = "",
    currentUserTypeCollection = "",
    String fidCollection = "",
    String fNameCollection = "",
  }) async {
    if (historyStack.isNotEmpty) {
      postModel.value =
          historyStack.removeLast(); // Go back to the last post in history
      getPostDetailsController(
          pid: postModel.value.id!,
          foldersid: foldersid); // Fetch related items for the previous post
    } else {
      if (isNotificationscreen == true) {
        final NotificationController notificationController =
            Get.find<NotificationController>();
        await notificationController.clearNotificationData();
        await notificationController.fetchNotifications();
        Get.off(const NotificationScreen());
      } else {
        if (imageUrlsCollection != "") {
          Get.off(CollectionView(
            isback2time: true,
            imageUrls: imageUrlsCollection,
            currentUserType: currentUserTypeCollection,
            fid: fidCollection,
            fName: fNameCollection,
          ));
        } else if (WebService.shouldRefresh &&
            appUser.value.profile?.id == postModel.value.owner?.id) {
          WebService.shouldRefresh=false;
          Get.offAll(
              () => BusinessDashBoard(
                    initialIndex: 4,
                  ),
              binding: BusinessDashBoardBinding());
        } else {
          try {
            if (!context.mounted) {
              Get.back();
              return;
            }
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).maybePop();
            } else {
              Get.back();
            }
          } catch (_) {
            if (Get.key?.currentState?.canPop() ?? false) {
              Get.back();
            }
          }
        }
      }
      // Navigator.of(context).pop();
    }
  }

  Future<void> _initialized() async {
    appUser.value = await WebService.getCurrentUser();
    if (!WebService.isSplashHomeScreen) {
      WebService.isSplashHomeScreen = true;
    }
  }

  Future getCollectionList() async {
    collectionsList.clear();
    AppUser user = await WebService.getCurrentUser();
    await FirebaseFirestore.instance
        .collection('folders')
        .where('uid', isEqualTo: user.profile!.firebaseId.toString())
        .get()
        .then((value) {
      value.docs.map((e) {
        collectionsList.add(e.data()['fid']);
      }).toList();
    });
  }

  Future removePostController({pid, imageId, baseUrl, isMultipleImage}) async {
    try {
      await Network.removePostApi(postId: pid).then((value) async {
        if (value != false) {
          if (isMultipleImage == "1") {
            final baseUrlList = baseUrl;
            final baseIdList = imageId;
            int imageListLength = 0;
            if (baseUrlList is String && baseUrlList.isNotEmpty) {
              // Remove [ and ]
              final cleaned =
                  baseUrlList.replaceAll('[', '').replaceAll(']', '');

              // Split into list and trim each item
              final imageList = cleaned
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
              imageListLength = imageList.length;
              if (imageList.length > 0) {
                await FireBaseApi.deletestorageImage(imageUrl: imageList[0]);
              }

              if (imageList.length > 1) {
                await FireBaseApi.deletestorageImage(imageUrl: imageList[1]);
              }
              if (imageList.length > 2) {
                await FireBaseApi.deletestorageImage(imageUrl: imageList[2]);
              }
            }

            if (baseIdList is String && baseIdList.isNotEmpty) {
              // Remove [ and ]
              final cleaned =
                  baseIdList.replaceAll('[', '').replaceAll(']', '');

              // Split into list and trim each item
              final imageIdList = cleaned
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();

              if (imageIdList.length > 0) {
                try {
                  await FirebaseFirestore.instance
                      .collection("images")
                      .doc(imageIdList[0])
                      .delete();
                } on FirebaseException catch (e) {
                  print('Error deleting image record from database: $e');
                }
              }
              if (imageIdList.length > 1) {
                try {
                  await FirebaseFirestore.instance
                      .collection("images")
                      .doc(imageIdList[1])
                      .delete();
                } on FirebaseException catch (e) {
                  print('Error deleting image record from database: $e');
                }
              }
              if (imageIdList.length > 2) {
                try {
                  await FirebaseFirestore.instance
                      .collection("images")
                      .doc(imageIdList[2])
                      .delete();
                } on FirebaseException catch (e) {
                  print('Error deleting image record from database: $e');
                }
              }
            }
          } else {
            try {
              if (baseUrl != "[]") {
                // Remove [ and ]
                final cleaned = baseUrl.replaceAll('[', '').replaceAll(']', '');
                await FireBaseApi.deletestorageImage(imageUrl: cleaned);
              }
              final cleanedId = imageId.replaceAll('[', '').replaceAll(']', '');
              await FirebaseFirestore.instance
                  .collection("images")
                  .doc(cleanedId)
                  .delete();
            } on FirebaseException catch (e) {
              print('Error deleting image record from database: $e');
            }
            await FireBaseApi.removeImageFromFolderImages(pid: pid);
            await FireBaseApi().removeImageFromFolders(imageUrl: baseUrl);
          }
        }
      });
      return;
    } catch (e) {
      displayMessageIcon(
          message: e.toString(),
          snackposition: SnackPosition.BOTTOM,
          color: errorColor,
          imageData: AppAssets.errorIcon);
    }
  }
}
