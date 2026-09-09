import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as getx;
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:ink/src/ui/screen/auth/login.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/bottomsheets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/webService.dart';

class ApiResponse {
  int status;
  dynamic data;
  String? message;

  ApiResponse({required this.status, this.data, this.message});

  String noInternetConnection = "אין חיבור אינטרנט";

  factory ApiResponse.fromResponse(Response response) {
    final data = response.data as Map<String, dynamic>;

    return ApiResponse(
        status: int.parse(data["status"].toString()),
        data: data["data"],
        message: data["msg"]);
  }

  //check response status
  // static dynamic checkStatus(ApiResponse response) async {
  //   if (response.status == 0) {
  //     //error occurred
  //
  //     displayMessage(response.message.toString(), errorColor);
  //   } else if (response.status == 1) {
  //     //success
  //     return response.data;
  //   } else if (response.status == 2) {
  //     //session expire
  //     getx.Get.closeAllSnackbars();
  //     await WebService.clearUserData();
  //     displayMessage(response.message.toString(), errorColor);
  //     getx.Get.offAll(() => LoginScreen());
  //   } else if (response.status == 3) {
  //     //app update available
  //     displayMessage(response.message.toString(), errorColor);
  //   }
  //   return null;
  // }

  static bool checkResponseStatus(Response response,
      {bool showSnackbar = true}) {
    try {
      var status = response.data["status"].toString();
      final msg = response.data["msg"].toString();

      // Soft-fail stubs / migrated-gap messages — don't spam snackbars
      final isStub = msg.contains('Action stubbed') ||
          msg.contains('Action not migrated');
      if (isStub) {
        WebService.isSessionExpire = false;
        return false;
      }

      if (status.toString() == "0") {
        WebService.isSessionExpire = false;
        // In develop mode avoid disruptive snackbars for recoverable API gaps
        if (WebService.developerMode || !showSnackbar) {
          WebService.printMsg('API status=0: $msg');
          return false;
        }
        try {
          if (getx.Get.isSnackbarOpen) {
            getx.Get.closeAllSnackbars();
          }
        } catch (_) {}
        displayMessageIcon(
            message: msg.toString(),
            color: errorColor,
            snackposition: SnackPosition.BOTTOM,
            imageData: AppAssets.errorIcon);
        return false;
      } else if (status.toString() == "2") {
        // Don't boot to Login during develop auto-login races
        if (WebService.developerMode) {
          WebService.printMsg('API status=2 (ignored in developerMode): $msg');
          return false;
        }
        WebService.isSessionExpire = true;
        sessionExpired(msg: msg);
        return false;
      } else if (status.toString() == "3") {
        WebService.isSessionExpire = false;
        try {
          if (getx.Get.isSnackbarOpen) {
            getx.Get.closeAllSnackbars();
          }
        } catch (_) {}
        displayMessageIcon(
            message: msg.toString(),
            color: errorColor,
            snackposition: SnackPosition.BOTTOM,
            imageData: AppAssets.errorIcon);
        openStoreRedirectDialog(WebService.homeScaffoldKey.currentContext!);

        return false;
      } else if (status.toString() == "4") {
        Future.delayed(const Duration(seconds: 2), () {
          try {
            if (getx.Get.isSnackbarOpen) {
              getx.Get.closeAllSnackbars();
            }
          } catch (_) {}
          displayMessageIcon(
              message: msg.toString(),
              color: errorColor,
              snackposition: SnackPosition.BOTTOM,
              imageData: AppAssets.errorIcon);
        });

        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static sessionExpired({msg}) async {
    WebService.isSessionExpire = true;
    try {
      getx.Get.closeAllSnackbars();
    } catch (_) {}
    await WebService.clearUserData();
    Future.delayed(const Duration(seconds: 2), () {
      try {
        displayMessageIcon(
            message: msg.toString(),
            color: errorColor,
            imageData: AppAssets.errorIcon);
        if (getx.Get.isSnackbarOpen) {
          getx.Get.closeAllSnackbars();
        }
      } catch (_) {}
    });

    getx.Get.offAll(() => const LoginScreen());
  }

  static openStoreRedirectDialog(BuildContext context) => showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      enableDrag: false,
      isDismissible: false,
      builder: (context) {
        return SizedBox(
          height: getx.Get.height * 0.3,
          child: Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20))),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "A New Version of Ink app available update now",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                          width: getx.Get.width,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  padding: const EdgeInsets.all(10)),
                              onPressed: openStore,
                              child: Text(tr("txt.update")))),
                    )
                  ],
                ),
              )),
        );
      });

  static openStore() {
    // LaunchReview.launch(androidAppId: "com.itapp2u.ink", iOSAppId: "585027354");
  }

  //Exception error
  static handleError(DioError e) {
    if (e.type == DioErrorType.connectTimeout) {
      Future.delayed(const Duration(seconds: 2), () {
        if (getx.Get.isSnackbarOpen) {
          getx.Get.closeAllSnackbars();
        }
        displayMessageIcon(
            message: "txt.not_launch",
            snackposition: SnackPosition.BOTTOM,
            color: errorColor,
            imageData: AppAssets.errorIcon);
      });
    } else if (e.type == DioErrorType.sendTimeout) {
      Future.delayed(const Duration(seconds: 2), () {
        if (getx.Get.isSnackbarOpen) {
          getx.Get.closeAllSnackbars();
        }
        displayMessageIcon(
            message: "alerts.network_error",
            snackposition: SnackPosition.BOTTOM,
            color: errorColor,
            imageData: AppAssets.errorIcon);
      });

      if (getx.Get.isSnackbarOpen) {
        getx.Get.closeAllSnackbars();
      }
    } else if (e.type == DioErrorType.other) {
      if (e.error is SocketException) {
        noIntenetConnectionPopup();
        return false;
      }

      if (getx.Get.isSnackbarOpen) {
        getx.Get.closeAllSnackbars();
      }
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        if (getx.Get.isSnackbarOpen) {
          if (getx.Get.isSnackbarOpen) {
            getx.Get.closeAllSnackbars();
          }
        }
        displayMessageIcon(
            message: e.message,
            snackposition: SnackPosition.BOTTOM,
            color: errorColor,
            imageData: AppAssets.errorIcon);
      });
    }
    return false;
  }
}
