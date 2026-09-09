import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/userController.dart';
import 'package:ink/src/data/model/image_model.dart';
import 'package:ink/src/ui/screen/home/controller/post_details_controller.dart';
import 'package:ink/src/utils/common.dart';
import 'package:path/path.dart';

import '../../../utils/assets.dart';
import '../../../utils/colors.dart';
import '../../../utils/webService.dart';
import '../../model/currentUser.dart';
import '../../model/folderImage.dart';

class FireBaseApi {
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  //business user uploaded images
  static Future uploadBusinessImage({required RequestImages image}) async {
    final docImage = fireStore.collection('images').doc();
    image.imageId = docImage.id;
    final json = image.toJson();
    await docImage.set(json);
  }

  //user requested tattoo images upload
  static Future userRequestImagesUpload(
      {required List imgList, required List<RequestImages> imgNameList}) async {
    AppUser user = await WebService.getCurrentUser();

    for (int i = 0; i < imgList.length; i++) {
      File file = File(imgList[i].path);

      final fileName = basename(file.path);

      final path = "requestTattooImages/${user.profile!.id}/$fileName";

      final ref = FirebaseStorage.instance.ref().child(path);

      final snapshots = await ref.putFile(file).whenComplete(() {});

      final imageUrl = await snapshots.ref.getDownloadURL();

      RequestImages image = RequestImages(
          name: fileName, imageUrl: imageUrl, uid: user.profile!.id!);
      imgNameList.add(image);

      final docImage = fireStore.collection('requestTattooImages').doc();
      image.imageId = docImage.id;
      final json = image.toJson();
      await docImage.set(json);
    }
  }

  static Future<String> getFirebaseToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      WebService.setDeviceToken(token!);
      return token;
    } catch (e) {
      return "";
    }
  }

  //creating folder
  static Future createFolder({name, fImageUrl}) async {
    final userController = Get.put(UserController());
    final folderObject = fireStore.collection("/folders").doc();
    final fid = folderObject.id;
    dynamic isCreated = false;
    await isAlreadyExist(name: name.toString().trim()).then((value) async {
      if (value != true) {
        await folderObject.set({
          "fid": fid,
          "fname": name,
          "image_url": fImageUrl ?? "",
          "uid": userController.firebaseId.value,
        });

        displayMessageIcon(
            message: " נוצר בהצלחה $name האלבום ",
            color: successGreen,
            imageData: AppAssets.correct_transparentIcon);

        isCreated = fid;
        return fid;
      } else {
        isCreated = false;
        return false;
      }
    });
    return isCreated;
  }

  //add folder image
  static Future addFolderImage(
      {fid, pid, imageId, fimageUrl, folderName}) async {
    try {
      var usersRef = fireStore.collection("/foldersImages").doc("$imageId");

      await usersRef.get().then((docSnapshot) async {
        await FirebaseFirestore.instance
            .collection('foldersImages')
            .where('fid', isEqualTo: fid)
            .where('pid', isEqualTo: pid)
            // .where('uid', isEqualTo: userController.id)
            .get()
            .then((QuerySnapshot snapshot) async {
          if (snapshot.docs.isNotEmpty) {
            // displayMessageIcon(message: "alerts.post_already_exist",color: errorColor,imageData: AppAssets.errorIcon);
            await removeFolderImage(postIndex: 0, imageId: imageId, fid: fid)
                .then((value) => displayMessageIcon(
                    message: " הפוסט הוסר מ$folderName",
                    color: successGreen,
                    imageData: AppAssets.correct_transparentIcon));
          } else {
            var folderObject = fireStore.collection("/foldersImages");
            final userController = Get.put(UserController());

            final FolderImage image = FolderImage(
                imageId: imageId,
                fid: fid,
                pId: pid,
                imageUrl: fimageUrl,
                firebaseId: userController.firebaseId.value);

            await folderObject.add(image.toJson());

            final updateFolder = fireStore.collection("/folders").doc(fid);
            await updateFolder.update({"image_url": fimageUrl});
            final PostDetailsController postDetailsController =
                Get.find<PostDetailsController>();

            postDetailsController.savedFolderList.add(fid);

            //The image has been saved in the collection '[collection name]
            displayMessageIcon(
                message: " התמונה נשמרה באוסף $folderName ",
                color: successGreen,
                imageData: AppAssets.correct_transparentIcon);
          }
        });
      });
    } catch (e) {
      displayMessageIcon(
          message: "בעקבות בעיה טכנית לא הצלחנו לשמור את התמונה",
          color: errorColor,
          imageData: AppAssets.errorIcon);
    }
  }

  //remove folder image
  static Future removeFolderImage({postIndex, fid, imageId}) async {
    String newImgUrl = "";
    if (postIndex != null) {
      if (postIndex == 0) {
        if (WebService.folderList.isEmpty) {
          newImgUrl = "";
        } else {
          newImgUrl = WebService.folderList[0].imageUrl;
        }
      } else {
        newImgUrl = WebService.folderList[postIndex - 1].imageUrl;
      }
    }

    final userController = Get.find<UserController>();

    final folderObject = await fireStore
        .collection("/foldersImages")
        .where('fid', isEqualTo: fid)
        .where('imageId', isEqualTo: imageId)
        .get();

    //WebService.printMsg(folderObject.docs[0].id.toString());
    var obj =
        fireStore.collection("/foldersImages").doc(folderObject.docs[0].id);

    obj.delete().then((value) async {
      final postDetailsController = Get.find<PostDetailsController>();
      postDetailsController.savedFolderList.remove(fid);
      final updateFolder = fireStore.collection("folders").doc(fid);
      await updateFolder.update({"image_url": newImgUrl});
    });
  }

  //delete image
  static Future deleteImage({imageId, fid}) async {
    String newImgUrl = "";
    final folderObject = await fireStore
        .collection("/foldersImages")
        .where('fid', isEqualTo: fid)
        .where('imageId', isEqualTo: imageId)
        .get();

    WebService.printMsg(folderObject.docs[0].id.toString());

    var obj =
        fireStore.collection("/foldersImages").doc(folderObject.docs[0].id);

    obj.delete().then((value) async {
      final updateFolder = fireStore.collection("folders").doc(fid);
      await updateFolder.update({"image_url": newImgUrl});
    }).then((datas) {
      getRandomImageUrlFromFoldersImages(fid).then((value) async {
        if (value != null) {
          final updateFolder = fireStore.collection("folders").doc(fid);
          await updateFolder.update({"image_url": value});
        }
      });
    });
  }

  //delete image
  static Future deletePostImage({imageId}) async {
    final folderObject = await fireStore
        .collection("/foldersImages")
        .where('imageId', isEqualTo: imageId)
        .get();

    WebService.printMsg(folderObject.docs[0].id.toString());

    var obj =
        fireStore.collection("/foldersImages").doc(folderObject.docs[0].id);

    obj.delete();
  }

  //delete collection
  static Future deleteCollection({fid}) async {
    await fireStore.collection("/folders").doc(fid).delete().then((value) {
      //The collection has been removed
      displayMessageIcon(
          message: "האוסף הוסר",
          color: successGreen,
          imageData: AppAssets.icAdded,
          snackposition: SnackPosition.BOTTOM);
    });
  }

  static Future deleteAllFoldersBatch({fID}) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    var querySnapshot = await FirebaseFirestore.instance
        .collection('folders')
        .where('uid', isEqualTo: fID)
        .get();

    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  //rename collection
  static Future renameCollection(
      {required String fid, required String name}) async {
    await fireStore
        .collection("/folders")
        .doc(fid)
        .update({"fname": "${name.toString()}"});
  }

  static Future isAlreadyExist({required name}) async {
    try {
      final userController = Get.find<UserController>();
      return await FirebaseFirestore.instance
          .collection('folders')
          .where('fname', isEqualTo: name.toString().replaceAll(" ", ""))
          .where('uid', isEqualTo: userController.firebaseId.value)
          .get()
          .then((QuerySnapshot snapshot) {
        if (snapshot.docs.isNotEmpty) {
          displayMessageIcon(
              message: "התיקיה כבר קיימת",
              color: errorColor,
              imageData: AppAssets.errorIcon); //The folder already exists
          return true;
        } else {
          return false;
        }
      });
    } catch (e) {
      return false;
    }
  }

  //image
  static Future deletestorageImage({String? imageUrl}) async {
    try {
      // Extract the path from the URL (more robust approach)
      final reference = FirebaseStorage.instance.refFromURL(imageUrl!);

      // Ensure the path matches your expected structure
      if (reference.fullPath.startsWith('creatorImages')) {
        await reference.delete();
        return;
      }
    } catch (error) {
      print('Error deleting image: $error');
    }
  }

  static Future removeImageFromFolderImages({required String pid}) async {
    try {
      QuerySnapshot tempquerySnapshot = await FirebaseFirestore.instance
          .collection('foldersImages') // Replace with your collection name
          .where('pid', isEqualTo: pid)
          .get();

      for (QueryDocumentSnapshot doc in tempquerySnapshot.docs) {
        await doc.reference.delete();
      }
    } on FirebaseException catch (e) {
      print('Error deleting image from storage: $e');
    }
  }

  Future<void> removeImageFromFolders({required String imageUrl}) async {
    try {
      final target = imageUrl.trim(); // image to remove

      // We must get all folders because Firestore cannot search inside string lists
      final query = await FirebaseFirestore.instance
          .collection('folders')
          .get();

      final batch = FirebaseFirestore.instance.batch();

      for (final doc in query.docs) {
        final dynamic rawValue = doc['image_url'];

        if (rawValue == null) continue;

        String raw = rawValue.toString().trim();

        // CASE 1: Single string: "image1"
        if (!raw.contains('[') && !raw.contains(']')) {
          if (raw == target) {
            batch.update(doc.reference, {'image_url': ''});
          }
          continue;
        }

        // CASE 2: String list: "[image1,image2, image3]"
        String cleaned = raw.replaceAll('[', '').replaceAll(']', '');
        List<String> images = cleaned
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        if (images.contains(target)) {
          images.remove(target);

          // Recreate list format
          String updated =
          images.isEmpty ? '' : '[${images.join(',')}]';

          batch.update(doc.reference, {'image_url': updated});
        }
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      print('Error removing image: $e');
    }
  }


  static Future removeImageFromSpecificFolders({required String fid}) async {
    try {
      final userController = Get.find<UserController>();
      final query = FirebaseFirestore.instance
          .collection('folders')
          .where('fid', isEqualTo: fid)
          .where('uid', isEqualTo: userController.firebaseId.value);
      final batch = FirebaseFirestore.instance.batch();
      await query.get().then((querySnapshot) {
        for (final doc in querySnapshot.docs) {
          batch.update(doc.reference, {'image_url': ''});
        }
      });
      await batch.commit();
    } on FirebaseException catch (e) {
      print('Error deleting image from storage: $e');
    }
  }

  static Future<String?> getRandomImageUrlFromFoldersImages(String fId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('foldersImages')
          .where('fid', isEqualTo: fId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final randomIndex = Random().nextInt(querySnapshot.docs.length);
        final doc = querySnapshot.docs[randomIndex];
        final folderImage = FolderImage.fromJson(doc.data());
        return folderImage.imageUrl;
      } else {
        return null; // No images found
      }
    } catch (e) {
      print('Error fetching image URL: $e');
      return null; // Error occurred
    }
  }

  static Future removeFolderImageFromPostSpecificUser(
      {required String postid, required String foldersId}) async {
    try {
      QuerySnapshot tempquerySnapshot = await FirebaseFirestore.instance
          .collection('foldersImages') // Replace with your collection name
          .where('pid', isEqualTo: postid)
          .where('fid', isEqualTo: foldersId)
          .get();

      for (QueryDocumentSnapshot doc in tempquerySnapshot.docs) {
        await doc.reference.delete();
      }
    } on FirebaseException catch (e) {
      print('Error deleting image from storage: $e');
    }
  }

  static Future removeFolderFromPostSpecificUser(
      {required String imageurl, required String fid}) async {
    QuerySnapshot folderimagereplace = await FirebaseFirestore.instance
        .collection('folders')
        .where('fid', isEqualTo: fid)
        .where('image_url', isEqualTo: imageurl)
        .get();
    for (QueryDocumentSnapshot doc in folderimagereplace.docs) {
      getRandomImageUrlFromFoldersImages(fid).then((value) async {
        if (value != null) {
          final updateFolder = fireStore.collection("folders").doc(fid);
          await updateFolder.update({"image_url": value});
        }
      });
    }
  }

  String? getFirstImageUrl(dynamic imageUrlField) {
    if (imageUrlField == null) return null;

    String urlString = imageUrlField.toString().trim();

    // Handle JSON array string:  '["https://...","https://..."]'
    if (urlString.startsWith('[') && urlString.endsWith(']')) {
      urlString = urlString.substring(1, urlString.length - 1);
      final List<String> urls = urlString
          .split(',')
          .map((e) => e.trim().replaceAll('"', '').replaceAll("'", ""))
          .where((e) => e.isNotEmpty)
          .toList();

      return urls.isNotEmpty ? urls.first : null;
    }

    // Single URL (or any non-array string)
    return urlString.isEmpty ? null : urlString;
  }
}
