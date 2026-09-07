import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:ink/src/controller/StartupController.dart';
import 'package:ink/src/controller/userController.dart';
import 'package:ink/src/data/source/network/api.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/business_dashboard.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/bussinessdashboard_binding.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/facebook_events/facebook_events.dart';
import 'package:ink/src/utils/webService.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/source/network/user_api.dart';

class SubscriptionDbService {
  String userId = "";
  bool purchaseData = true;
  static late bool fromRegistration;

  static Dio dio = Dio();

  Future<void> saveSubcriptionsDetails(
      PurchaseDetails purchaseDetails, purchase_status) async {
    final loginToken = await WebService.getUserToken();
    var userid = await WebService.getUserIds();
    GooglePlayPurchaseDetails gpp =
        purchaseDetails as GooglePlayPurchaseDetails;

    Map<String, dynamic> orignalJsonData =
        await jsonDecode(gpp.billingClientPurchase.originalJson);
    print("ABBBC 3");
    String productId = orignalJsonData['productId'];
    print("ABBBC 4");
    if (purchaseData) {
      print("ABBBC 5");
      try {
        final params = {
          'action': 'AndroidSubscription',
          'uid': userid,
          'login_token': loginToken,
          'app_token': WebService.appToken,
          'app_version': WebService.appVersion,
          'device_type': WebService.deviceType,
          // 'developerPayload': gpp.billingClientPurchase.developerPayload,
          // 'isAcknowledged': gpp.billingClientPurchase.isAcknowledged,
          // 'isAutoRenewing': gpp.billingClientPurchase.isAutoRenewing,
          // 'obfuscatedAccountId': gpp.billingClientPurchase.obfuscatedAccountId,
          // 'obfuscatedProfileId': gpp.billingClientPurchase.obfuscatedProfileId,
          // 'orderId': gpp.billingClientPurchase.orderId,
          'originalJson': gpp.billingClientPurchase.originalJson,
          // 'packageName': gpp.billingClientPurchase.packageName,
          // 'purchaseTime': gpp.billingClientPurchase.purchaseTime,
          'purchaseToken': gpp.billingClientPurchase.purchaseToken,
          // 'signature': gpp.billingClientPurchase.signature,
          'sku': productId,
          'purchase_status': purchase_status
        };
        print("ABBBC params$params");
        await dio
            .post(WebService.baseUrl, queryParameters: params)
            .then((value) async {
          print("ABBBC value $value");
          purchaseData = false;
          if (fromRegistration) {
            await registerUser();
          } else {
            try {
              UserController userController = getx.Get.find();

              final purchaseParams = {
                'user_type': userController.userType.value.toString(),
                'business_type': userController.businessType.value.toString(),
                'name': userController.name.value.toString(),
                'amount': WebService.purchasePrice.toString(),
                'currency_code': WebService.purchaseCurrency.toString(),
                'purchaseToken': gpp.billingClientPurchase.purchaseToken,
                'sku': productId,
                'action': 'AndroidSubscription',
                'uid': userid,
                'login_token': loginToken,
                'app_token': WebService.appToken,
                'app_version': WebService.appVersion,
                'device_type': WebService.deviceType,
              };

              /*await FacebookEvents.subscriptionEvent(
                  amount: WebService.purchasePrice,
                  currency: WebService.purchaseCurrency,
                  params: purchaseParams);*/

              if (WebService.selectedPlan == 0) {
                await FacebookEvents.subscriptionBasicEvent(
                    amount: WebService.purchasePrice.toString(),
                    // currency: WebService.purchaseCurrency,
                    params: purchaseParams);
              } else {
                await FacebookEvents.subscriptionPremiumEvent(
                    amount: WebService.purchasePrice.toString(),
                    // currency: WebService.purchaseCurrency,
                    params: purchaseParams);
              }
            } catch (e) {
              displayMessageIcon(
                  message: "Error FB: $e",
                  snackposition: getx.SnackPosition.BOTTOM,
                  color: errorColor,
                  imageData: AppAssets.errorIcon);
            } finally {
              WebService.isTempPremiumPlanPurchase = true;
              WebService.isTempPremiumPlanPurchaseLoading = false;
            }
          }
        });
      } on SocketException catch (_) {
        noIntenetConnectionPopup();
      } on DioError catch (e) {
        ApiResponse.handleError(e);
      } on Exception catch (e) {
        displayMessageIcon(
            snackposition: getx.SnackPosition.BOTTOM,
            message: e.toString(),
            color: errorColor,
            imageData: AppAssets.errorIcon);
      }
    }
    return;
  }

  Future<void> saveSubcriptionsDetailsIOS(
      PurchaseDetails purchaseDetails, purchaseStatus) async {
    var userid = await WebService.getUserIds();
    final loginToken = await WebService.getUserToken();

    AppStorePurchaseDetails appledata =
        purchaseDetails as AppStorePurchaseDetails;

    if (purchaseData) {
      try {
        final params = {
          'action': 'SuccessPurchaseIphone',
          'uid': userid,
          'login_token': loginToken,
          'app_token': WebService.appToken,
          'app_version': WebService.appVersion,
          'device_type': WebService.deviceType,
          'purchaseID': appledata.purchaseID,
          'productID': appledata.productID,
          'transactionDate': appledata.transactionDate,
          'skPaymentTransaction': appledata.skPaymentTransaction.toString(),
          'original_transaction_id': appledata
              .skPaymentTransaction.originalTransaction?.transactionIdentifier
              .toString(),
          'purchase_status': purchaseStatus,
          'is_sandbox': WebService.isSandBox
        };
        print("ABBBC params$params");

        var response = await dio
            .post(
          WebService.baseUrl,
          data: jsonEncode({
            'receipt_data': appledata.verificationData.serverVerificationData,
          }),
          queryParameters: params,
          options: Options(
            contentType: Headers.jsonContentType,
          ),
        )
            .then((value) async {
          purchaseData = false;
          if (fromRegistration) {
            await registerUser();
          } else {
            UserController userController = getx.Get.find();

            final purchaseParams = {
              'action': 'SuccessPurchaseIphone',
              'user_type': userController.userType.value.toString(),
              'business_type': userController.businessType.value.toString(),
              'name': userController.name.value.toString(),
              'amount': WebService.purchasePrice,
              'currency_code': WebService.purchaseCurrency,
              'purchaseID': appledata.purchaseID,
              'productID': appledata.productID,
              'uid': userid,
              'login_token': loginToken,
              'app_token': WebService.appToken,
              'app_version': WebService.appVersion,
              'device_type': WebService.deviceType,
            };

            /*  await FacebookEvents.subscriptionEvent(
                amount: WebService.purchasePrice,
                currency: WebService.purchaseCurrency,
                params: purchaseParams);*/

            if (WebService.selectedPlan == 0) {
              await FacebookEvents.subscriptionBasicEvent(
                  amount: WebService.purchasePrice.toString(),
                  // currency: WebService.purchaseCurrency,
                  params: purchaseParams);
            } else {
              await FacebookEvents.subscriptionPremiumEvent(
                  amount: WebService.purchasePrice.toString(),
                  // currency: WebService.purchaseCurrency,
                  params: purchaseParams);
            }
          }
        });
        return response;
      } on Exception catch (e) {
        displayMessageIcon(
            snackposition: getx.SnackPosition.BOTTOM,
            message: e.toString(),
            color: errorColor,
            imageData: AppAssets.errorIcon);
      } finally {
        WebService.isTempPremiumPlanPurchaseLoading = false;
      }
    }
  }

  //register user
  Future registerUser() async {
    try {
      Network.changeUserTypeApi().then((value) async {
        if (value == true) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool("isBusiness", true);
          getx.Get.offAll(
              BusinessDashBoard(
                initialIndex: 0,
              ),
              binding: BusinessDashBoardBinding());
        }
      });
    } on Exception catch (e) {
      displayMessageIcon(
          snackposition: getx.SnackPosition.BOTTOM,
          message: e.toString(),
          color: errorColor,
          imageData: AppAssets.errorIcon);
    }
  }

  //basicFreePlanBuyUser
  Future<void> basicFreePlanDbServer() async {
    try {
      final value = await Network.basicFreePlanApi();

      if (value != false) {
        if (fromRegistration) {
          final changed = await Network.changeUserTypeApi();
          if (changed == true) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool("isBusiness", true);
            getx.Get.offAll(
              BusinessDashBoard(initialIndex: 0),
              binding: BusinessDashBoardBinding(),
            );
          }
        } else {
          final StartupController startupController =
              Get.find<StartupController>();

          await startupController.checkSubscription(); // ✅ wait for refresh

          // ✅ Force UI update
          startupController.update();

          return;
        }
      }
    } catch (e) {
      displayMessageIcon(
        snackposition: getx.SnackPosition.BOTTOM,
        message: e.toString(),
        color: errorColor,
        imageData: AppAssets.errorIcon,
      );
    }
  }
}
