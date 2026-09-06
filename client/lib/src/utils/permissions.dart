import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

requestPermission({bool isCameraUpload = true}) async {
  final storage = await Permission.storage.request();
  var result;

  // if (!isCameraUpload) {
    // if (Platform.isAndroid) {
    //      final androidInfo = await DeviceInfoPlugin().androidInfo;
    //      if (androidInfo.version.sdkInt <= 32) {
    //        use [Permission.storage.status]
    //      }  else {
    //        use [Permission.photos.status]
    //      }
    //    }

    final photos = await Permission.photos.request();
    if (storage.isPermanentlyDenied ||
        storage.isDenied ||
        photos.isPermanentlyDenied ||
        photos.isDenied) {
      openAppSettings();
    }
    result = storage.isGranted;
  // } else {
  //   final camera = await Permission.camera.request();
  //   if (storage.isPermanentlyDenied ||
  //       storage.isDenied ||
  //       camera.isPermanentlyDenied ||
  //       camera.isDenied) {
  //     openAppSettings();
  //     result = storage.isGranted && camera.isGranted;
  //   }
  // }

  return result;
}

// checkPermission({bool isEnableCamera = true}) async {
//   Map<Permission, PermissionStatus> statuses = await [
//     Permission.storage,
//     if (isEnableCamera == true) Permission.camera
//     //https://3.basecamp.com/3338141/buckets/29955561/todos/9259517548#__recording_9364202626
//   ].request();
//
//   final bool sts = statuses.isEmpty ? false : true;
//   return sts;
// }

checkPermission() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.storage,
    //https://3.basecamp.com/3338141/buckets/29955561/todos/9259517548#__recording_9364202626
  ].request();

  final bool sts = statuses.isEmpty ? false : true;
  return sts;
}

requestPermission13() async {
  final photos = await Permission.photos.request();
  // final camera = await Permission.camera.request();
  if (photos.isPermanentlyDenied ||
      photos.isDenied
      // camera.isPermanentlyDenied ||
      // camera.isDenied
  ) {
    openAppSettings();
  }

  final result = photos.isGranted;
  // final result = photos.isGranted && camera.isGranted;

  return result;
}

// Future<bool> checkPhotoPermission() async {
//   Map<Permission, PermissionStatus> statuses = await [
//     Permission.photos, // iOS + Android 13+
//   ].request();
//
//   return statuses.values.every((status) => status.isGranted);
// }

Future<bool> checkPhotoPermission() async {
  final status = await Permission.photos.status;
  return status.isGranted;
}

Future<bool> requestPermissionPhotos() async {
  final photos = await Permission.photos.request();

  if (photos.isPermanentlyDenied) {
    openAppSettings();
    return false;
  }

  return photos.isGranted;
}

Future<bool> ensurePhotoPermission() async {
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;

    if (androidInfo.version.sdkInt >= 33) {
      // Android 13+
      return await _requestPermission(Permission.photos);
    } else {
      // Android 12 and below
      return await _requestPermission(Permission.storage);
    }


  }

  // iOS
  return await _requestPermission(Permission.photos);
}

Future<bool> _requestPermission(Permission permission) async {
  var status = await permission.status;

  if (status.isGranted) return true;

  if (status.isPermanentlyDenied) {
    await openAppSettings();
    return false;
  }

  status = await permission.request();

  if (status.isGranted||status.isLimited) return true;

  if (status.isPermanentlyDenied) {
    await openAppSettings();
    return false;
  }

  return false;
}


checkPermission13() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.photos,
    // Permission.camera,
  ].request();

  final bool sts = statuses.isEmpty ? false : true;
  return sts;
}

Future<bool> locationPermission() async {
  final isNotGranted = await Permission.location.isDenied ||
      await Permission.location.isPermanentlyDenied;
  final PermissionStatus status = await Permission.location.request();
  return status.isGranted;
}

checkNotificationPermission() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.notification,
  ].request();

  final bool sts = statuses.isEmpty ? false : true;
  return sts;
}

requestNotificationPermission(context, size) async {
  final notification = await Permission.notification.request();

  if (Platform.isIOS && notification.isDenied) {
    Permission.notification.request();
  }
  if (notification.isDenied ||
      notification.isPermanentlyDenied ||
      notification.isRestricted) {
    await Permission.notification.request();
  }

  return notification.isGranted;
}

Future<dynamic> showNotificationDIalog(context, size) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: signInButtonColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          contentPadding: const EdgeInsets.all(20.0),
          alignment: Alignment.center,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: size.height * 0.01,
              ),
              const Text(
                "הודעות מושבתות",
                // "למחוק את התמונות מהאוסף?",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: titleTextWhiteColor),
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              const Text(
                "אפשר התראות בהגדרות האפליקציה כדי לקבל עדכונים.",
                // "התמונות שסומנו ימחקו\nמהאוסף ללא אפשרות שחזור.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: titleTextWhiteColor,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: styleBgColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    child: const Text('פתח את ההגדרות'),
                    onPressed: () {
                      openAppSettings();
                      Navigator.of(ctx).pop();
                    },
                  ),
                  SizedBox(width: size.width * 0.02),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: errorColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('ביטול'),
                  ),
                ],
              ),
            ),
          ],
        );
      });
}
