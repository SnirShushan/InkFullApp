import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' as getx;
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:ink/src/controller/change_user_type.dart';
import 'package:ink/src/controller/google_signin_controller.dart';
import 'package:ink/src/data/source/network/firebase_api.dart';
import 'package:ink/src/data/source/network/requests.dart';
import 'package:ink/src/ui/screen/auth/login.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/facebook_events/facebook_events.dart';
import 'package:ink/src/utils/utils.dart';
import 'package:ink/src/utils/webService.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../controller/userController.dart';
import '../../model/currentUser.dart';
import 'api.dart';

class Network {
  static Dio dio = Dio()
    ..interceptors.addAll([
      if (kDebugMode)
        PrettyDioLogger(
          requestHeader: false,
          requestBody: false,
          responseBody: false,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
    ]);

  // static  Dio dio = Dio();
  //init network
  Network() {
    if (dio.options == null) {
      BaseOptions options = BaseOptions(
          baseUrl: WebService.baseUrl,
          receiveDataWhenStatusError: true,
          connectTimeout: 30 * 1000, // 60 seconds
          receiveTimeout: 30 * 1000 // 60 seconds
          );

      dio = Dio(options);
    }
  }

  static printMsg(dynamic msg) {
    WebService.printMsg(msg.toString());
  }

  //launch url
  static Future<void> launchUrl(String url) async {
    final Uri mapUrl = Uri.parse(url);

    if (await canLaunchUrl(mapUrl)) {
      await launchUrl(url);
    } else {
      displayMessageIcon(
          message: "Could not launch $mapUrl",
          color: errorColor,
          snackposition: SnackPosition.BOTTOM,
          imageData: AppAssets.errorIcon);
    }
  }

  static Future<bool> isImageUrlValid({required String url}) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200 &&
          (response.headers['content-type']?.startsWith('image/') ?? false);
    } catch (e) {
      return false;
    }
  }

  //check response status

  static final userController = getx.Get.put(UserController());

  //check phone exist
  static Future sendLogToServer(String phone, String errorMsg) async {
    try {
      var response = await dio.post(WebService.baseUrl,
          queryParameters:
              NetWorkRequest.sendLogToServer(phone: phone, errMsg: errorMsg));

      final isDataEmpty = ApiResponse.checkResponseStatus(response);

      if (!isDataEmpty) {
        displayMessageIcon(
            message: "done",
            color: errorColor,
            snackposition: SnackPosition.BOTTOM,
            imageData: AppAssets.errorIcon);
      }
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  //check phone exist
  static Future checkPhoneExist(String phone) async {
    try {
      var response = await dio.post(WebService.baseUrl,
          queryParameters: NetWorkRequest.checkPhoneExist(phone));

      final isDataEmpty = ApiResponse.checkResponseStatus(response);

      if (!isDataEmpty) {
        final responseData = response.data["data"];
        if (responseData != null && responseData != "") {
          if (responseData['is_exists'].toString() == "1") {
            return responseData['is_exists'];
          } else {
            return responseData['is_exists'];
          }
        }
      }
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  //login
  static Future<bool> login(String phone, User? fuser) async {
    try {
      // Step 1: Get Firebase token (do this in parallel)
      final tokenFuture = FirebaseMessaging.instance.getToken();

      // Step 2: Fire login request in parallel
      final token = await tokenFuture;
      final response = await dio.post(
        WebService.baseUrl,
        queryParameters: NetWorkRequest.login(phone, token),
      );

      // printMsg("response_login : $response");

      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (!isDataNotEmpty) return false;

      final responseData = ApiResponse.fromResponse(response);
      final profile = responseData.data['profile'];

      if (profile == null || profile == "") {
        displayMessageIcon(
          message: "alerts.login_data_empty",
          color: errorColor,
          snackposition: SnackPosition.BOTTOM,
          imageData: AppAssets.errorIcon,
        );
        return false;
      }

      // Clear only once
      await WebService.clearUserData();

      // Step 3: Set URLs (assignment not Future)
      WebService.profileImageUrl = response.data["profile_img_url"];
      WebService.styleImgUrl = response.data["style_img_url"];
      WebService.bodyImgUrl = response.data["body_img_url"];
      WebService.followUsers = response.data['followers'].toString();

      if (profile["user_type"].toString() == "2") {
        await WebService.setIsBusiness(true);
      } else {
        await WebService.setIsBusiness(false);
      }
      WebService.setUserToken(profile['login_token']);

      WebService.setUserIds(profile['id'].toString());

      AppUser newUser = AppUser.fromJson(responseData.data);
      WebService.setCurrentUser(newUser);

      await userController.initUser();

      // Step 5: If no Firebase ID, register on Firestore (needs a signed-in user)
      if (Utils.isDataEmpty(profile["firebase_id"]) && fuser != null) {
        try {
          final docRef =
              FirebaseFirestore.instance.collection("users").doc(fuser.uid);

          await docRef.set({
            "uid": fuser.uid,
            "name": profile["name"],
            "profileImage": profile["profile_image"],
            "id": profile["id"],
            "login_type": profile["login_type"],
            "business_type": profile["business_type"],
          });

          await userController.updateUser(
            name: profile["name"],
            address: profile["address"],
            addressPlaceId: profile["address_place_id"],
            lat: profile["address_lat"],
            lng: profile["address_lng"],
            about: profile["about_text"],
            styles: profile["styles"],
            firebaseId: fuser.uid,
          );
        } catch (e) {
          debugPrint("Firestore error: $e");
        }
      }

      return true;
    } on DioError catch (e) {
      ApiResponse.handleError(e);
      return false;
    }
  }

  /// Develop-mode login: no Firebase Auth / OTP. Uses a fixed device udid.
  static Future<bool> devAutoLogin(String phone) async {
    try {
      final response = await dio.post(
        WebService.baseUrl,
        queryParameters: NetWorkRequest.login(phone, "dev-mode-udid"),
      );
      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (!isDataNotEmpty) return false;

      final responseData = ApiResponse.fromResponse(response);
      final profile = responseData.data['profile'];
      if (profile == null || profile == "") return false;

      await WebService.clearUserData();
      WebService.profileImageUrl = response.data["profile_img_url"];
      WebService.styleImgUrl = response.data["style_img_url"];
      WebService.bodyImgUrl = response.data["body_img_url"];
      WebService.followUsers = (response.data['followers'] ?? "0").toString();

      if (profile["user_type"].toString() == "2") {
        await WebService.setIsBusiness(true);
      } else {
        await WebService.setIsBusiness(false);
      }
      await WebService.setUserToken(profile['login_token'].toString());
      await WebService.setUserIds(profile['id'].toString());
      await WebService.setCurrentUser(AppUser.fromJson(responseData.data));
      await userController.initUser();
      return true;
    } on DioError catch (e) {
      ApiResponse.handleError(e);
      return false;
    } catch (e) {
      debugPrint("devAutoLogin: $e");
      return false;
    }
  }

  //Check Phone Exist For Direct OTP Check
  static Future checkPhoneExistFetchEmail(String phone) async {
    try {
      var response = await dio.post(WebService.baseUrl,
          queryParameters: NetWorkRequest.checkPhoneExist(phone));

      final isDataEmpty = ApiResponse.checkResponseStatus(response);

      if (isDataEmpty) {
        final responseData = response.data["data"];
        if (responseData != null && responseData != "") {
          return responseData;
        }
      } else {
        return false;
      }
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  //Fetch OTP Without Firebase

  static Future fetchOTPApi(phonenumber, otp, email) async {
    try {
      var response = await dio.post(WebService.baseUrl,
          queryParameters: NetWorkRequest.fetchOTPReq(phonenumber, otp, email));
      ApiResponse responseData = ApiResponse.fromResponse(response);

      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);

      if (isDataNotEmpty) {
        return responseData.data;
      }
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  //login
  static Future<bool> signInWithGoogle(User fUser) async {
    try {
      final udid = await FirebaseMessaging.instance.getToken();

      var response = await dio.post(WebService.baseUrl,
          queryParameters:
              NetWorkRequest.googleSignIn(fUser.email ?? "", udid));

      ApiResponse responseData = ApiResponse.fromResponse(response);

      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);

      if (isDataNotEmpty) {
        WebService.profileImageUrl = response.data["profile_img_url"];
        WebService.styleImgUrl = response.data["style_img_url"];
        WebService.bodyImgUrl = response.data["body_img_url"];

        var profile = await responseData.data['profile'];

        //removing old user and data
        await WebService.clearUserData();

        if (profile["user_type"].toString() == "2") {
          await WebService.setIsBusiness(true);
        } else {
          await WebService.setIsBusiness(false);
        }

        await WebService.setUserToken(profile['login_token']!);
        await WebService.setUserIds(profile['id'].toString());
        AppUser newUser = AppUser.fromJson(responseData.data);
        await WebService.setCurrentUser(newUser);
        await userController.initUser();

        // set current user if not set
        if (Utils.isDataEmpty(profile["firebase_id"])) {
          try {
            final firebaseUser =
                FirebaseFirestore.instance.collection("users").doc(fUser.uid);
            await firebaseUser.set({
              "uid": fUser.uid,
              "name": profile["name"],
              "profileImage": profile["profile_image"],
              "id": profile["id"],
              "login_type": profile["login_type"],
              "business_type": profile["business_type"]
            });
            await userController.updateUser(
                name: profile["name"],
                address: profile["address"],
                addressPlaceId: profile["address_place_id"],
                lat: profile["address_lat"],
                lng: profile["address_lng"],
                about: profile["about_text"],
                styles: profile["styles"] ?? "",
                firebaseId: fUser.uid);
          } catch (e) {
            // displayMessage(e.toString(), errorColor);
          }
        }
        return true;
      } else {
        debugPrint("isDataNotEmpty yes: $isDataNotEmpty");
      }
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  static Future<bool> loginwithapple(name, email, idToken, socialId) async {
    try {
      final udid = await FirebaseMessaging.instance.getToken();

      var response = await dio.post(WebService.baseUrl,
          queryParameters:
              NetWorkRequest.loginWithApple(name, email, udid, socialId));

      ApiResponse responseData = ApiResponse.fromResponse(response);

      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);

      if (isDataNotEmpty) {
        // WebService.profileImageUrl = response.data["profile_img_url"];
        // WebService.styleImgUrl = response.data["style_img_url"];
        // WebService.bodyImgUrl = response.data["body_img_url"];

        var profile = responseData.data['profile'];

        //removing old user and data
        await WebService.clearUserData();

        if (profile["user_type"].toString() == "2") {
          await WebService.setIsBusiness(true);
        } else {
          await WebService.setIsBusiness(false);
        }

        await WebService.setUserToken(profile['login_token']!);
        await WebService.setUserIds(profile['id'].toString());
        AppUser newUser = AppUser.fromJson(responseData.data);
        await WebService.setCurrentUser(newUser);
        await userController.initUser();

        // set current user if not set
        if (Utils.isDataEmpty(profile["firebase_id"])) {
          try {
            final firebaseUser =
                FirebaseFirestore.instance.collection("users").doc(socialId);
            await firebaseUser.set({
              "uid": socialId,
              "name": profile["name"],
              "profileImage": profile["profile_image"],
              "id": profile["id"],
              "login_type": profile["login_type"],
              "business_type": profile["business_type"]
            });
            await userController.updateUser(
                name: profile["name"],
                address: profile["address"],
                addressPlaceId: profile["address_place_id"],
                lat: profile["address_lat"],
                lng: profile["address_lng"],
                about: profile["about_text"],
                styles: profile["styles"],
                firebaseId: socialId);
          } catch (e) {
            // displayMessage(e.toString(), errorColor);
          }
        }
        return true;
      }
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  //update styles
  static Future updateStyles({required String styles}) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(NetWorkRequest.updateStyles(
          userController.id.value, loginToken, styles));

      response = await dio.post(WebService.baseUrl, data: formData);

      if (response.statusCode != 200) return false;

      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);

      if (isDataNotEmpty) {
        return response.data["data"];
      }
      return false;

      // final status = response.data["status"].toString();
      // final msg = response.data["msg"].toString();
      // if (status == "0") {
      //   displayMessage(msg, Colors.red);
      //   return false;
      // } else if (status == "1") {
      //   final responseData = response.data["data"];
      //   return responseData;
      // } else if (status == "2") {
      //   sessionExpired(msg: msg);
      // }
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      if (getx.Get.isSnackbarOpen) {
        getx.Get.closeAllSnackbars();
      }
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  static Future getStartupImage() async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(
          NetWorkRequest.StartupImageData(userController.id.value, loginToken));
      // printMsg(formData.fields.toString());
      response = await dio.post(WebService.baseUrl, data: formData);

      if (response.statusCode != 200) return false;

      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);

      if (isDataNotEmpty) {
        return response.data["data"];
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  //delete account
  static Future deleteAccountApi() async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(
          NetWorkRequest.deleteAccount(userController.id.value, loginToken));
      printMsg(formData.fields.toString());
      response = await dio.post(WebService.baseUrl, data: formData);
      printMsg(response.data.toString());
      final status = response.data["status"].toString();
      final msg = response.data["msg"].toString();
      if (status == "0") {
        displayMessageIcon(
            message: msg.toString(),
            color: errorColor,
            snackposition: SnackPosition.BOTTOM,
            imageData: AppAssets.errorIcon);

        return false;
      } else if (status == "1") {
        try {
          await FireBaseApi.deleteAllFoldersBatch(
              fID: userController.firebaseId.value);
        } catch (e) {}

        displayMessageIcon(
            message: msg.toString(),
            snackposition: SnackPosition.BOTTOM,
            color: successGreen,
            imageData: AppAssets.correct_transparentIcon);

        final GoogleSignInController googleSignInController =
            GoogleSignInController();
        await googleSignInController.signOut();
        await FirebaseMessaging.instance.deleteToken();
        await WebService.clearUserData();

        await Future.delayed(const Duration(seconds: 2));

        getx.Get.offAll(() => const LoginScreen());
      } else if (status == "2") {
        ApiResponse.sessionExpired(msg: msg);
      } else {
        displayMessageIcon(
            message: msg.toString(),
            snackposition: SnackPosition.BOTTOM,
            color: successGreen,
            imageData: AppAssets.correct_transparentIcon);
      }
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  //========================= home =================

  // static Future getHomeTopStyleApi() async {
  //   final loginToken = await WebService.getUserToken();
  //   try {
  //     FormData formData = FormData.fromMap(NetWorkRequest.getHomeTopStylesRequest(
  //         userController.id.value,
  //         loginToken));
  //     Response response = await dio.post(WebService.baseUrl, data: formData);
  //     if (response.statusCode != 200) return false;
  //
  //     final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
  //     if (isDataNotEmpty) {
  //       WebService.profileImageUrl =
  //           response.data["profile_img_url"].toString();
  //       WebService.styleImgUrl = response.data["style_img_url"].toString();
  //       WebService.bodyImgUrl = response.data["body_img_url"].toString();
  //
  //       return response.data["data"];
  //     }
  //     return false;
  //   } on SocketException catch (_) {
  //     noIntenetConnectionPopup();
  //     return false;
  //   } on DioError catch (e) {
  //     ApiResponse.handleError(e);
  //
  //     return false;
  //   }
  // }
  static Future getHomeApi(startNotification, limitNotification) async {
    final loginToken = await WebService.getUserToken();
    try {
      FormData formData = FormData.fromMap(NetWorkRequest.getHomeRequest(
          userController.id.value,
          loginToken,
          startNotification,
          limitNotification));
      Response response = await dio.post(WebService.baseUrl, data: formData);
      if (response.statusCode != 200) return false;

      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        if (!WebService.isLocalApi) {
          WebService.profileImageUrl =
              response.data["profile_img_url"].toString();
          WebService.styleImgUrl = response.data["style_img_url"].toString();
          WebService.bodyImgUrl = response.data["body_img_url"].toString();
        }
        WebService.randomPagination =
            response.data["data"]["total_post_count"].toString() ?? "0";
        return response.data["data"];
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  //get Home Posts
  static Future getHomePostsApi(
      {required isRandom,
      required start,
      required limit,
      postIds,
      styles}) async {
    final loginToken = await WebService.getUserToken();

    try {
      FormData formData = FormData.fromMap(NetWorkRequest.getHomePostsReq(
          userController.id.value,
          loginToken,
          isRandom,
          start,
          limit,
          postIds,
          styles));

      printMsg(formData.fields.toString());
      Response response = await dio.post(WebService.baseUrl, data: formData);
      printMsg(WebService.baseUrl.toString());

      if (response.statusCode != 200) return false;

      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);

      if (isDataNotEmpty) {
        WebService.profileImageUrl = response.data["profile_img_url"];
        WebService.styleImgUrl = response.data["style_img_url"];
        WebService.bodyImgUrl = response.data["body_img_url"];

        return response.data["data"];
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  //get Home Posts
  static Future getHomePostsNewApi(
      {required isRandom,
      required start,
      required limit,
      postIds}) async {
    final loginToken = await WebService.getUserToken();

    try {
      FormData formData = FormData.fromMap(NetWorkRequest.getHomePostsNewReq(
          userController.id.value,
          loginToken,
          isRandom,
          start,
          limit,
          postIds));

      printMsg(formData.fields.toString());
      Response response = await dio.post(WebService.baseUrl, data: formData);
      printMsg(WebService.baseUrl.toString());

      if (response.statusCode != 200) return false;

      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);

      if (isDataNotEmpty) {
        WebService.profileImageUrl = response.data["profile_img_url"];
        WebService.styleImgUrl = response.data["style_img_url"];
        WebService.bodyImgUrl = response.data["body_img_url"];

        return response.data["data"];
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  // get Posts
  static Future getPostsApi(
      {required style,
      required start,
      required limit,
      required following}) async {
    final loginToken = await WebService.getUserToken();

    try {
      FormData formData = FormData.fromMap(NetWorkRequest.getPostsReq(
          userController.id.value, loginToken, style, start, limit, following));

      printMsg(formData.fields.toString());
      Response response = await dio.post(WebService.baseUrl, data: formData);
      printMsg(WebService.baseUrl.toString());

      if (response.statusCode != 200) return false;

      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);

      if (isDataNotEmpty) {
        WebService.profileImageUrl = response.data["profile_img_url"];
        WebService.styleImgUrl = response.data["style_img_url"];
        WebService.bodyImgUrl = response.data["body_img_url"];

        return response.data["data"]["posts"];
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  // get Posts
  static Future getInspirationPostsApi(
      {required style,
      required start,
      required limit,
      required searchTxt,
      required isNew,
      required isRecommended,
      required mostView,
      required following}) async {
    final loginToken = await WebService.getUserToken();

    try {
      FormData formData = FormData.fromMap(
          NetWorkRequest.getInspirationPostsRequest(
              uid: userController.id.value,
              loginToken: loginToken,
              style: style,
              start: start,
              limit: limit,
              following: following,
              searchTxt: searchTxt,
              isNew: isNew,
              isRecommended: isRecommended,
              mostView: mostView));

      printMsg(formData.fields.toString());
      Response response = await dio.post(WebService.baseUrl, data: formData);
      printMsg(WebService.baseUrl.toString());

      if (response.statusCode != 200) return false;

      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);

      if (isDataNotEmpty) {
        WebService.profileImageUrl = response.data["profile_img_url"];
        WebService.styleImgUrl = response.data["style_img_url"];
        WebService.bodyImgUrl = response.data["body_img_url"];

        return response.data["data"]["posts"];
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  // add post
  static Future addPost(
      {required String imageType,
      required String description,
      required String imageName,
      required String imageId,
      required String creatorId,
      required String styles}) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(NetWorkRequest.addPost(
          userController.id.value,
          loginToken,
          creatorId,
          imageType,
          styles,
          description,
          imageName,
          imageId,
          userController.businessType.value));

      response = await dio.post(WebService.baseUrl, data: formData);
      printMsg(formData.fields.toString());
      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);

      if (isDataNotEmpty) {
        final responseData = response.data["data"];
        if (responseData != null || responseData != '') {
          return true;
        }
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  // search Posts
  static Future searchPosts(
      {required String searchText, required String following}) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(NetWorkRequest.searchPosts(
          userController.id.value, loginToken, searchText, following));
      printMsg(formData.fields.toString());
      response = await dio.post(WebService.baseUrl, data: formData);

      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        return response.data["data"]["posts"];
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  //report post
  static Future reportPost({required pid, required comment}) async {
    final loginToken = await WebService.getUserToken();
    try {
      FormData formData = FormData.fromMap(NetWorkRequest.reportPost(
          pid, comment, userController.id.value, loginToken));

      WebService.printMsg(formData.fields.toString());
      Response response = await dio.post(WebService.baseUrl, data: formData);
      WebService.printMsg(response.data.toString());
      return response.data;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  //===================== request tattoo ================

  //request for tattoo
  static Future requestTattooApi(
      {required String name,
      required String description,
      required String isContactRequest,
      required String phone,
      required String tattooSize,
      required String frontData,
      required String backData,
      required String artistId,
      required String businessId,
      required requestImages,
      required File? backDataImage,
      required File? frontDataImage,
      required String styles}) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      final params = {
        "action": "RequestForTattoo",
        "uid": userController.id.value,
        "login_token": loginToken,
        "name": name,
        "phone": phone,
        "tattoo_size": tattooSize,
        "styles": styles,
        "front_data": frontData,
        "back_data": backData,
        "is_contact_request": isContactRequest, //1=false 2=true
        "description": description,
        "artists_uid": artistId,
        "business_id": businessId,
        "request_images": requestImages,
        "back_data_image": isContactRequest == "2"
            ? null
            : backDataImage!.existsSync()
                ? await MultipartFile.fromFile(backDataImage.path,
                    filename: backDataImage.uri.toString())
                : null,
        "front_data_image": isContactRequest == "2"
            ? null
            : frontDataImage!.existsSync()
                ? await MultipartFile.fromFile(frontDataImage.path,
                    filename: frontDataImage.uri.toString(),
                    contentType: MediaType('image', 'png'))
                : null,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken,
        // "files": isContactRequest == "2"
        //     ? null
        //     : frontDataImage!.existsSync()
        //         ? await MultipartFile.fromFile(frontDataImage.path,
        //             filename: frontDataImage.uri.toString(),
        //             contentType: MediaType('image', 'png'))
        //         : null,
      };

      FormData formData = FormData.fromMap(params);

      printMsg(formData.fields.toString());
      response = await dio.post(WebService.baseUrl, data: formData);

      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        final responseData = response.data["data"];
        if (responseData != null || responseData != '') {
          final _facebookEvenetParams = {
            "action": "RequestForTattoo",
            "uid": userController.id.value,
            "login_token": loginToken,
            "name": name,
            "phone": phone,
            "tattoo_size": tattooSize,
            "styles": styles,
            "front_data": frontData,
            "back_data": backData,
            "is_contact_request": isContactRequest, //1=false 2=true
            "description": description,
            "artists_uid": artistId,
            "business_id": businessId,
            "request_images": requestImages,
            "device_type": WebService.deviceType,
            "app_version": WebService.appVersion,
            "app_token": WebService.appToken,
          };

          await FacebookEvents.addTattooRequestLog(
              params: _facebookEvenetParams);

          return true;
        }
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  //===================== business tab ================

  //report business
  static Future reportBusiness({required bid, required comment}) async {
    final loginToken = await WebService.getUserToken();
    try {
      FormData formData = FormData.fromMap(NetWorkRequest.reportBusiness(
          bid, comment, userController.id.value, loginToken));
      Response response = await dio.post(WebService.baseUrl, data: formData);
      // final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      return response.data;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  //get businesses
  static Future getBusinessApi(
      {required isStyleEnabled,
      String? selectedStyles,
      // required isNewEnabled,
      required isPopularEnabled,
      required lat,
      required lng,
      required radius,
      required searchText,
      required isClosest,
      required isRecommended,
      required isFilterLocation,
      int? start,
      int? limit}) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(NetWorkRequest.getBusinessReq(
          uid: userController.id.value,
          loginToken: loginToken,
          isStyleEnabled: isStyleEnabled,
          userStyles: selectedStyles ?? "",
          // userController.styles.value,
          // isNewEnabled,
          start: start,
          limit: limit,
          lat: lat,
          lng: lng,
          radius: radius,
          isPopularEnabled: isPopularEnabled,
          searchTxt: searchText,
          isClosest: isClosest,
          isRecommended: isRecommended,
          isFilterLocation: isFilterLocation));

      printMsg("Business" + formData.fields.toString());
      response = await dio.post(WebService.baseUrl, data: formData);

      if (response.statusCode != 200) return false;

      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        final responseData = response.data["data"];
        if (responseData != null || responseData != '') {
          return responseData["business"];
        }
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  //get Business user details
  static Future getBusinessDetails(String bid) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(NetWorkRequest.getBusinessDetails(
          userController.id.value, bid, loginToken));
      printMsg(formData.fields.toString());
      response = await dio.post(WebService.baseUrl, data: formData);
      printMsg(response.data.toString());

      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);

      if (isDataNotEmpty) {
        final responseData = response.data["data"];
        if (responseData != null || responseData != '') {
          WebService.profileImageUrl = response.data["profile_img_url"];
          WebService.styleImgUrl = response.data["style_img_url"];
          WebService.bodyImgUrl = response.data["body_img_url"];
          return response.data["data"];
        }
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  //Get Sketch List Api (For business Detail pagination)
  static Future getSketchListApi(String bid, start, limit) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(NetWorkRequest.getSketchListReq(
          userController.id.value, bid, loginToken, start, limit));
      printMsg(formData.fields.toString());
      response = await dio.post(WebService.baseUrl, data: formData);
      printMsg(response.data.toString());

      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);

      if (isDataNotEmpty) {
        final responseData = response.data["data"];
        if (responseData != null || responseData != '') {
          return response.data["data"];
        }
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  //Get Tattoo List (For business Detail pagination)
  static Future getTattooListApi(String bid, start, limit) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(NetWorkRequest.getTattooListReq(
          userController.id.value, bid, loginToken, start, limit));
      printMsg(formData.fields.toString());
      response = await dio.post(WebService.baseUrl, data: formData);
      printMsg(response.data.toString());

      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);

      if (isDataNotEmpty) {
        final responseData = response.data["data"];
        if (responseData != null || responseData != '') {
          return response.data["data"];
        }
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  //================ registration ================

  //getMy Artists
  static Future getMyArtist() async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(
          NetWorkRequest.getMyArtist(userController.id.value, loginToken));

      response = await dio.post(WebService.baseUrl, data: formData);

      printMsg(formData.fields.toString());
      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        final responseData = response.data["data"];
        if (responseData["users"] != "[]" && responseData["users"] != null) {
          return responseData["users"];
        }
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  //getMy Studios
  static Future getMyStudio() async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(
          NetWorkRequest.getMyStudios(userController.id.value, loginToken));

      response = await dio.post(WebService.baseUrl, data: formData);
      printMsg(formData.fields.toString());
      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        final responseData = response.data["data"];
        if (responseData["users"] != "[]" && responseData["users"] != null) {
          return responseData["users"];
        }
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {

      ApiResponse.handleError(e);

      return false;
    }
  }

  //changeUsertype
  static Future changeUserTypeApi() async {
    final loginToken = await WebService.getUserToken();
    Response response;

    final _changeUserTypeController = getx.Get.find<ChangeUserTypeController>();
    try {
      final params = {
        "action": "UpdateBusinessProfile",
        'uid': userController.id.value,
        'login_token': loginToken,
        'business_type':
            _changeUserTypeController.isStudioSelected.value ? "1" : "2",
        'name': _changeUserTypeController.nameController.text,
        'address': _changeUserTypeController.addressController.text,
        'address_lat': WebService.lat,
        'address_lng': WebService.lang,
        'city_name': WebService.cityName,
        'address_place_id': WebService.placeId,
        'styles': _changeUserTypeController.selectedStyles.isEmpty
            ? ''
            : _changeUserTypeController.selectedStyles
                .map((v) => v.slug)
                .join(','),
        'about_text': _changeUserTypeController.aboutController.text,
        'device_type': WebService.deviceType,
        'app_version': WebService.appVersion,
        'app_token': WebService.appToken,
        'is_convert': "0",
        'member_ids': _changeUserTypeController.selectedNewArtists.isNotEmpty
            ? _changeUserTypeController.selectedNewArtists.join(",")
            : "",
        'signature_image': WebService.signFile.existsSync()
            ? await MultipartFile.fromFile(WebService.signFile.path,
                contentType: MediaType('image', 'png'))
            : null,
        "files": WebService.signFile.existsSync()
            ? await MultipartFile.fromFile(WebService.signFile.path,
                contentType: MediaType('image', 'png'))
            : null,
      };

      FormData formData = await FormData.fromMap(params);

      response = await dio.post(WebService.baseUrl, data: formData);
      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        final eventParams = {
          "action": "UpdateBusinessProfile",
          'uid': userController.id.value,
          'login_token': loginToken,
          'business_type':
              _changeUserTypeController.isStudioSelected.value ? "1" : "2",
          'name': _changeUserTypeController.nameController.text,
          'address': _changeUserTypeController.addressController.text,
          'address_lat': WebService.lat,
          'address_lng': WebService.lang,
          'about_text': _changeUserTypeController.aboutController.text,
          'device_type': WebService.deviceType,
          'app_version': WebService.appVersion,
          'app_token': WebService.appToken,
        };
        if (_changeUserTypeController.isStudioSelected.value == true) {
          await FacebookEvents.studioProfileCreationEvent(params: eventParams);
        } else {
          await FacebookEvents.artistProfileCreationEvent(params: eventParams);
        }
        /* await FacebookEvents.subscriptionEvent(
          amount: WebService.purchasePrice,
          currency: WebService.purchaseCurrency,
          params: eventParams);*/

        if (WebService.selectedPlan == 0) {
          await FacebookEvents.subscriptionBasicEvent(
              amount: WebService.purchasePrice,
              // currency: WebService.purchaseCurrency,
              params: eventParams);
        } else {
          await FacebookEvents.subscriptionPremiumEvent(
              amount: WebService.purchasePrice,
              // currency: WebService.purchaseCurrency,
              params: eventParams);
        }

        await WebService.clearUserData();
        final responseData = await response.data["data"];
        // if (responseData != null || responseData != '') {
        //   if (responseData['profile'] != null &&
        //       responseData['profile'] != "") {
        final profile = await responseData['profile'];
        if (profile["user_type"].toString() == "2") {
          await WebService.setIsBusiness(true);
        } else {
          await WebService.setIsBusiness(false);
        }
        await WebService.setUserToken(profile['login_token']);
        await WebService.setUserIds(profile['id'].toString());
        await WebService.setCurrentUser(AppUser.fromJson(responseData));

        // displayMessage(response.data["msg"].toString(), Colors.blue);
        return true;
        // }
        // }
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  //get BusinessList for change user type
  static Future getBusinessListApi({btype, search_txt}) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(NetWorkRequest.getBusinessListReq(
          userController.id.value, loginToken, btype, search_txt));
      printMsg(formData.fields.toString());
      response = await dio.post(WebService.baseUrl, data: formData);

      final status = response.data["status"].toString();
      final msg = response.data["msg"];

      if (status.toString() == "0") {
        return false;
      } else if (status.toString() == "2") {
        ApiResponse.sessionExpired(msg: msg);
        return false;
      } else if (status.toString() == "3") {
        if (getx.Get.isSnackbarOpen) {
          getx.Get.closeAllSnackbars();
        }
        ApiResponse.openStoreRedirectDialog(
            WebService.homeScaffoldKey.currentContext!);
        return false;
      }

      final responseData = response.data["data"];
      if (responseData != null || responseData != '') {
        return response.data["data"]["business_list"];
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  //================ post details  ================

  //remove Post
  static Future removePostApi({required String postId}) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(NetWorkRequest.removePostRequest(
          userController.id.value, loginToken, postId));
      printMsg(formData.fields.toString());
      response = await dio.post(WebService.baseUrl, data: formData);

      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        Future.delayed(const Duration(seconds: 2), () {
          displayMessageIcon(
              snackposition: SnackPosition.BOTTOM,
              message: "התמונה נמחקה",
              color: successGreen,
              imageData: AppAssets.correct_transparentIcon);
        });
        return true;
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  // get Post details
  static Future getPostDetails({required pid}) async {
    final loginToken = await WebService.getUserToken();
    AppUser user = await WebService.getCurrentUser();

    Response response;
    try {
      FormData formData = FormData.fromMap(
          NetWorkRequest.getPostDetails(user.profile!.id!, loginToken, pid));
      response = await dio.post(WebService.baseUrl, data: formData);

      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        return response.data["data"]["detail"];
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    } catch (e) {
      displayMessageIcon(
          message: e.toString(),
          color: successGreen,
          imageData: AppAssets.correct_transparentIcon);
      return false;
    }
  }

  //like post
  static Future followUser({required fid, required likeStatus}) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(NetWorkRequest.followUser(
          fid, userController.id.value, likeStatus, loginToken));

      printMsg(formData.fields.toList().toString());
      response = await dio.post(WebService.baseUrl, data: formData);

      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        // Future.delayed(const Duration(seconds: 2), () {
        //   displayMessageIcon(
        //       snackposition: SnackPosition.BOTTOM,
        //       message: response.data["msg"].toString(),
        //       color: successGreen,
        //       imageData: AppAssets.correct_transparentIcon);
        // });
        return response.data["data"];
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  //================ profile ================

  // get my Posts
  static Future getMyPostsApi(start, limit) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(NetWorkRequest.getMyPostsReq(
          userController.id.value, loginToken, start, limit));

      response = await dio.post(WebService.baseUrl, data: formData);

      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        return response.data["data"];
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  static Future getUserApi() async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(
          NetWorkRequest.getUserRequest(userController.id.value, loginToken));

      response = await dio.post(WebService.baseUrl, data: formData);
      final isDataNotEmpty = await ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        return response.data['data'];
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  static Future getProfileUserApi() async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(
          NetWorkRequest.getUserRequest(userController.id.value, loginToken));

      response = await dio.post(WebService.baseUrl, data: formData);
      final isDataNotEmpty = await ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        WebService.profileImageUrl = response.data["profile_img_url"];
        WebService.styleImgUrl = response.data["style_img_url"];
        WebService.bodyImgUrl = response.data["body_img_url"];

        return response.data['data'];
      } else {
        return false;
      }
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    } catch (e) {
      if (getx.Get.isSnackbarOpen) {
        getx.Get.closeAllSnackbars();
      }
      noIntenetConnectionPopup();
      return false;
    }
  }

  //update post
  static Future updatePostApi(
      {required String description,
      required String postId,
      required String imageId,
      required String imageName,
      required String artistId,
      required String studioId,
      required String styles}) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(NetWorkRequest.updatePostReq(
          userController.id.value,
          loginToken,
          styles,
          description,
          artistId,
          studioId,
          postId,imageId,imageName));

      response = await dio.post(WebService.baseUrl, data: formData);
      printMsg(formData.fields.toString());

      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        final responseData = response.data["data"];

        if (responseData != null || responseData != '') {
          Future.delayed(const Duration(seconds: 2), () {
            displayMessageIcon(
                snackposition: SnackPosition.BOTTOM,
                message: "הפרטים עודכנו בהצלחה",
                color: successGreen,
                imageData: AppAssets.correct_transparentIcon);
          });
          return true;
        } //Updated Successfully
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  //update post artist
  static Future updatePostMember(
      {required String uid,
      required String memberId,
      required String postId}) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(
          NetWorkRequest.updatePostMember(uid, loginToken, memberId, postId));

      response = await dio.post(WebService.baseUrl, data: formData);
      printMsg(formData.fields.toString());

      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        final responseData = response.data["data"];

        if (responseData != null || responseData != '') {
          displayMessageIcon(
              message: "עודכן בהצלחה",
              snackposition: SnackPosition.BOTTOM,
              color: successGreen,
              imageData: AppAssets.correct_transparentIcon);
          return true;
        } else {
          displayMessageIcon(
              message: "alerts.something_went_wrong",
              color: errorColor,
              snackposition: SnackPosition.BOTTOM,
              imageData: AppAssets.errorIcon);
          // displayMessage("alerts.something_went_wrong", Colors.red);
        }
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  //update profile image
  static Future updateProfileImage({required File profileImage}) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      // FormData formData = FormData.fromMap(NetWorkRequest.updateProfileImage(
      //     userController.id.value, loginToken, profileImage));
      FormData formData = FormData.fromMap({
        "action": "UpdateProfileImage",
        "uid": userController.id.value,
        "login_token": loginToken,
        "profile_image": profileImage.existsSync()
            ? await MultipartFile.fromFile(profileImage.path,
                filename: profileImage.uri.toString())
            : null,
        "files": profileImage.existsSync()
            ? await MultipartFile.fromFile(profileImage.path,
                filename: profileImage.uri.toString())
            : null,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken,
      });
      printMsg(formData.fields.toString());
      response = await dio.post(WebService.baseUrl, data: formData);
      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        final responseData = response.data["data"];
        if (responseData != "") {
          AppUser user = await WebService.getCurrentUser();
          final Profile profile = Profile.fromJson(responseData["profile"]);
          final followers = user.followers!;
          final startup_image = user.startup_image!;

          List<StylesList> styleList = <StylesList>[];
          if (user.stylesList != null) {
            styleList = user.stylesList!;
          }

          // List<Artist> artist = <Artist>[];
          // if (user.artist != null) {
          //   artist = user.artist!;
          // }

          AppUser updatedUser = AppUser(
              profile: profile,
              // artist: artist,
              stylesList: styleList,
              followers: followers,
              startup_image: startup_image);
          await WebService.setCurrentUser(updatedUser);
          await userController.initUser();
          Future.delayed(const Duration(seconds: 2), () {
            displayMessageIcon(
                snackposition: SnackPosition.BOTTOM,
                message: "alerts.profile_image_updated",
                color: successGreen,
                imageData: AppAssets.correct_transparentIcon);
          });
        }
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  //
  static Future userRegistrationApi(
      {required String name,
      required String email,
      required String phone}) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      final params = NetWorkRequest.registrationRequest(
          userController.id.value, loginToken, name, email, phone);

      FormData formData = FormData.fromMap(params);
      printMsg(formData.fields.toString());

      response = await dio.post(WebService.baseUrl, data: formData);
      Map<String, dynamic> data = jsonDecode(response.toString());
      if (data['status'] == 1) {
        await FacebookEvents.registrationEvent(params: params);
        final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
        if (isDataNotEmpty) {
          return response.data["data"];
        }
      } else {
        displayMessageIcon(
            message: data['msg'],
            color: errorColor,
            imageData: AppAssets.errorIcon);
        return false;
      }
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  static Future updateUserDetails({
    String? name,
    String? phone,
    String? email,
  }) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(NetWorkRequest.updateUserDetails(
          userController.id.value, loginToken, name, email, phone));

      response = await dio.post(WebService.baseUrl, data: formData);
      final isDataNotEmpty = await ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        print("isDataNotEmpty $isDataNotEmpty");
        Future.delayed(const Duration(seconds: 2), () {
          displayMessageIcon(
              message: "הפרופיל עודכן",
              color: successGreen,
              snackposition: SnackPosition.BOTTOM,
              imageData: AppAssets.icAdded);
        });

        return response.data["data"];
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  static Future updateProfile({
    required String name,
    required String address,
    required String addressPlaceId,
    required String lat,
    required String lng,
    required String about,
    required String styles,
    required String firebaseId,
    String? email,
  }) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(NetWorkRequest.updateProfile(
          userController.id.value,
          loginToken,
          name,
          address,
          addressPlaceId,
          lat,
          lng,
          about,
          styles,
          firebaseId,
          email));
      printMsg(formData.fields.toString());
      response = await dio.post(WebService.baseUrl, data: formData);
      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        AppUser user = await WebService.getCurrentUser();

        final Profile profile = Profile.fromJson(response.data["profile"]);
        final followers = user.followers;
        final startup_image = user.startup_image;
        final styleList = user.stylesList ?? [];
        // final artist = user.artist!;

        AppUser updatedUser = AppUser(
            profile: profile,
            // artist: artist,
            stylesList: styleList,
            followers: followers,
            startup_image: startup_image);
        await WebService.setCurrentUser(updatedUser);

        return response.data["data"];
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  //update location enabled
  static Future updateLocationEnabled(
      {required String isLocationEnabled}) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(
          NetWorkRequest.updateSettingsLocation(
              userController.id.value, loginToken, isLocationEnabled));

      printMsg(formData.fields.toString());
      response = await dio.post(WebService.baseUrl, data: formData);
      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        return response.data["data"]["profile"];
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  //update profile image
  static Future businessEditProfileImageApi(
      {required File profileImage}) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      // FormData formData = FormData.fromMap(NetWorkRequest.updateProfileImage(
      //     userController.id.value, loginToken, profileImage));
      FormData formData = FormData.fromMap({
        "action": "UpdateProfileImage",
        "uid": userController.id.value,
        "login_token": loginToken,
        "profile_image": profileImage.existsSync()
            ? await MultipartFile.fromFile(profileImage.path,
                filename: profileImage.uri.toString())
            : null,
        "files": profileImage.existsSync()
            ? await MultipartFile.fromFile(profileImage.path,
                filename: profileImage.uri.toString())
            : null,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken,
      });

      response = await dio.post(WebService.baseUrl, data: formData);
      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  //update profile image
  static Future businessEditProfileApi(
      {required String name,
      required String address,
      required String addressPlaceId,
      required String lat,
      required String lng,
      required String styles,
      required String about}) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      // FormData formData = FormData.fromMap(NetWorkRequest.updateProfileImage(
      //     userController.id.value, loginToken, profileImage));
      FormData formData = FormData.fromMap({
        "action": "UpdateProfile",
        "uid": userController.id.value,
        "login_token": loginToken,
        "name": name,
        "about_text": about,
        "address": address,
        "address_place_id": addressPlaceId,
        'city_name': WebService.cityName,
        "address_lat": lat,
        "address_lng": lng,
        "styles": styles,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken,
      });
      response = await dio.post(WebService.baseUrl, data: formData);
      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        final responseData = response.data["data"];
        if (responseData != "") {
          AppUser user = await WebService.getCurrentUser();
          final Profile profile = Profile.fromJson(responseData["profile"]);
          final followers = user.followers!;
          final startup_image = user.startup_image!;

          List<StylesList> styleList = <StylesList>[];
          if (user.stylesList != null) {
            styleList = user.stylesList!;
          }
          WebService.followUsers = responseData['followers'].toString();
          // List<Artist> artist = <Artist>[];
          // if (user.artist != null) {
          //   artist = user.artist!;
          // }

          AppUser updatedUser = AppUser(
              profile: profile,
              // artist: artist,
              stylesList: styleList,
              followers: followers,
              startup_image: startup_image);
          await WebService.setCurrentUser(updatedUser);
          await userController.initUser();
        }
        return true;
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  static Future businessEditStylesApi({required String styles}) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      // FormData formData = FormData.fromMap(NetWorkRequest.updateProfileImage(
      //     userController.id.value, loginToken, profileImage));
      FormData formData = FormData.fromMap({
        "action": "UpdateProfile",
        "uid": userController.id.value,
        "login_token": loginToken,
        "styles": styles,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken,
      });
      response = await dio.post(WebService.baseUrl, data: formData);
      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        final responseData = response.data["data"];
        if (responseData != "") {
          AppUser user = await WebService.getCurrentUser();
          final Profile profile = Profile.fromJson(responseData["profile"]);
          final followers = user.followers!;
          final startup_image = user.startup_image!;

          List<StylesList> styleList = <StylesList>[];
          if (user.stylesList != null) {
            styleList = user.stylesList!;
          }
          WebService.followUsers = responseData['followers'].toString();
          // List<Artist> artist = <Artist>[];
          // if (user.artist != null) {
          //   artist = user.artist!;
          // }

          AppUser updatedUser = AppUser(
              profile: profile,
              // artist: artist,
              stylesList: styleList,
              followers: followers,
              startup_image: startup_image);
          await WebService.setCurrentUser(updatedUser);
          await userController.initUser();
          Future.delayed(const Duration(seconds: 2), () {
            displayMessageIcon(
                snackposition: SnackPosition.BOTTOM,
                message: response.data["msg"],
                color: successGreen,
                imageData: AppAssets.correct_transparentIcon);
          });
        }
        return true;
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  static Future businessEditStyleProfileApi(
      {required String name,
      required String address,
      required String addressPlaceId,
      required String lat,
      required String lng,
      required String styles,
      required String about}) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      // FormData formData = FormData.fromMap(NetWorkRequest.updateProfileImage(
      //     userController.id.value, loginToken, profileImage));
      FormData formData = FormData.fromMap({
        "action": "UpdateProfile",
        "uid": userController.id.value,
        "login_token": loginToken,
        "name": name,
        "about_text": about,
        "address": address,
        "address_place_id": addressPlaceId,
        "address_lat": lat,
        "address_lng": lng,
        "styles": styles,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken,
      });
      response = await dio.post(WebService.baseUrl, data: formData);
      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        final responseData = response.data["data"];
        if (responseData != "") {
          AppUser user = await WebService.getCurrentUser();
          final Profile profile = Profile.fromJson(responseData["profile"]);
          final followers = user.followers!;
          final startupImage = user.startup_image!;

          List<StylesList> styleList = <StylesList>[];
          if (user.stylesList != null) {
            styleList = user.stylesList!;
          }
          WebService.followUsers = responseData['followers'].toString();
          // List<Artist> artist = <Artist>[];
          // if (user.artist != null) {
          //   artist = user.artist!;
          // }

          AppUser updatedUser = AppUser(
              profile: profile,
              // artist: artist,
              stylesList: styleList,
              followers: followers,
              startup_image: startupImage);
          await WebService.setCurrentUser(updatedUser);
          await userController.initUser();
          Future.delayed(const Duration(seconds: 2), () {
            displayMessageIcon(
                snackposition: SnackPosition.BOTTOM,
                message: response.data["msg"],
                color: successGreen,
                imageData: AppAssets.correct_transparentIcon);
          });
        }
        return true;
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  //update push enabled
  static Future updatePushEnabled({required String isPushEnabled}) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(NetWorkRequest.updatePushEnabled(
          userController.id.value, loginToken, isPushEnabled));

      response = await dio.post(WebService.baseUrl, data: formData);
      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        return response.data["data"]["profile"];
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);
    }
  }

  //update artists
  //action status add = 1 , remove = 2
  static Future updateArtistList(
      {required String artistId, required String actionStatus}) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(NetWorkRequest.updateArtistList(
          userController.id.value, loginToken, artistId, actionStatus));

      response = await dio.post(WebService.baseUrl, data: formData);
      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        if (actionStatus == "1") {
          getx.Get.back();
          Future.delayed(const Duration(seconds: 1), () {

            displayMessageIcon(
                snackposition: SnackPosition.BOTTOM,
                // message: "נוסף בהצלחה",
                message: "הזמנה נשלחה למקעקע",
                color: successGreen,
                imageData: AppAssets.correct_transparentIcon);
          });
        } else {
          getx.Get.back();
          Future.delayed(const Duration(seconds: 1), () {

            displayMessageIcon(
                snackposition: SnackPosition.BOTTOM,
                message: "הוסר בהצלחה",
                color: successGreen,
                imageData: AppAssets.correct_transparentIcon);
          });
        }
        return response.data["data"];
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);
      return false;
    }
  }

  static Future updateArtistChangePlanList(
      {required String artistId, required String actionStatus}) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(NetWorkRequest.updateArtistList(
          userController.id.value, loginToken, artistId, actionStatus));

      response = await dio.post(WebService.baseUrl, data: formData);

      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      print("isDataNotEmpty:-> $isDataNotEmpty");

      if (isDataNotEmpty) {
        Future.delayed(const Duration(seconds: 2), () {
          getx.Get.back();
          displayMessageIcon(
              snackposition: SnackPosition.BOTTOM,
              // message: "נוסף בהצלחה",
              message: "הזמנה נשלחה למקעקע",
              color: successGreen,
              imageData: AppAssets.correct_transparentIcon);
        });

        return response.data["data"];
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);
      return false;
    }
  }

  //update studio
  static Future updateStudioList(
      {required String studioId, required String actionStatus}) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(NetWorkRequest.updateStudioList(
          userController.id.value, loginToken, studioId, actionStatus));
      printMsg(formData.fields.toString());
      response = await dio.post(WebService.baseUrl, data: formData);
      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        if (actionStatus == "1") {
          displayMessageIcon(
              message: "נוסף בהצלחה",
              snackposition: SnackPosition.BOTTOM,
              color: successGreen,
              imageData: AppAssets.correct_transparentIcon);
        } else {
          displayMessageIcon(
              message: "נוסף בהצלחה",
              snackposition: SnackPosition.BOTTOM,
              color: successGreen,
              imageData: AppAssets.correct_transparentIcon);
        }
        return response.data["data"];
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);
      return false;
    }
  }

  //contact us
  static Future contactUs({required String comment}) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(NetWorkRequest.contactUs(
          userController.id.value, loginToken, comment));
      printMsg(formData.fields.toString());
      response = await dio.post(WebService.baseUrl, data: formData);
      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        if (response.data["status"].toString() == "1") {
          displayMessageIcon(
              // message: "הפניה נשלחה בהצלחה!",
              message: response.data["msg"].toString(),
              color: successGreen,
              snackposition: SnackPosition.BOTTOM,
              imageData: AppAssets.icAdded);
          // displayMessage(response.data["msg"].toString(), Colors.green);
          return true;
        } else {
          displayMessageIcon(
              snackposition: SnackPosition.BOTTOM,
              message: response.data["msg"].toString(),
              color: errorColor,
              imageData: AppAssets.errorIcon);
          // displayMessage(response.data["msg"].toString(), Colors.red);
          return false;
        }
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);
      return false;
    }
  }

  //================ notification ================

  //fetch notification data
  static Future getNotificationData(start, limit) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap({
        "action": "GetNotificationsNew",
        "uid": userController.id.value,
        "start": start,
        "limit": limit,
        "login_token": loginToken,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken
      });

      printMsg(formData.fields.toString());

      response = await dio.post(WebService.baseUrl, data: formData);
      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        final responseData = response.data["data"];
        if (responseData != null) {
          WebService.unreadnotification =
              responseData["unread_notification_count"].toString();
          return responseData["notification"];
        }
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);
      return false;
    }
  }

  //accept or reject request , action_status : accept = 1 reject = 2
  static Future acceptInvitation({artistId, actionStatus}) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    final bool isArtist =
        userController.businessType.value == "2" ? true : false;

    try {
      FormData formData = FormData.fromMap(NetWorkRequest.acceptInvitation(
          userController.id.value,
          isArtist,
          loginToken,
          artistId,
          actionStatus));
      printMsg(formData.fields.toString());
      response = await dio.post(WebService.baseUrl, data: formData);
      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        final responseData = response.data["data"];

        return responseData;
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);
      return false;
    }
  }

  //Read Notifications , is_read  : Read = 1 UnRead  = 2
  static Future readNotificationApi({notificationId, isRead}) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    final bool isArtist =
        userController.businessType.value == "2" ? true : false;
    try {
      FormData formData = FormData.fromMap(
          NetWorkRequest.readNotificationRequest(userController.id.value,
              isArtist, loginToken, notificationId, isRead));
      printMsg(formData.fields.toString());
      response = await dio.post(WebService.baseUrl, data: formData);
      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        return;
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);
      return false;
    }
  }

  //Read Message Count , is_read  : Read = 1 UnRead  = 2
  static Future readTattooRequestApi({requestId, isRead}) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    final bool isArtist =
        userController.businessType.value == "2" ? true : false;
    final String types = userController.userType.value == "1" ? "sent" : "rcvd";
    try {
      FormData formData = FormData.fromMap(NetWorkRequest.readTattooRequests(
          userController.id.value,
          isArtist,
          loginToken,
          requestId,
          isRead,
          types));
      printMsg(formData.fields.toString());
      response = await dio.post(WebService.baseUrl, data: formData);
      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        return;
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);
      return false;
    }
  }

  //================ request ================

  //get User tattoo requests
  static Future getTattooRequestsData(start, limit) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap({
        "action": "GetTattooRequest",
        "uid": userController.id.value,
        "start": start,
        "limit": limit,
        "login_token": loginToken,
        "device_type": WebService.deviceType,
        "app_version": WebService.appVersion,
        "app_token": WebService.appToken,
        "type": userController.userType.value == "1" ? "sent" : "rcvd",
      });
      response = await dio.post(WebService.baseUrl, data: formData);
      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        final responseData = response.data["data"];
        WebService.unreadMessage =
            responseData["unread_request_count"].toString();

        return responseData["request_list"];
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);
      return false;
    }
  }

  static Future getTattooRequestsList() async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(NetWorkRequest.getTattooRequestsList(
          userController.id.value, loginToken, userController.userType.value));
      printMsg(formData.fields.toString());
      response = await dio.post(WebService.baseUrl, data: formData);
      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        final responseData = response.data["data"];
        return responseData["request_list"];
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);
      return false;
    }
  }

  static bool _isRequestInProgress = false;

  //Check Subscription or not
  static Future getCheckSubscription({int isAddPost = 0}) async {
    if (_isRequestInProgress) {
      print("getCheckSubscription call ignored — already in progress");
      return null;
    }

    _isRequestInProgress = true;

    print("ABC 12333");
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(
          NetWorkRequest.getCheckSubscriptionList(
              userController.id.value, loginToken, isAddPost));

      response = await dio.post(WebService.baseUrl, data: formData);
      var status = response.data["status"].toString();
      if (status.toString() == "0" || status.toString() == "1") {
        final responseData = response.data;
        return responseData;
      } else {
        final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
        if (isDataNotEmpty) {
          final responseData = response.data;
          return responseData;
        }
      }
    } on SocketException catch (_) {
      Future.delayed(const Duration(seconds: 2), () {
        noIntenetConnectionPopup();
      });
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);
      return false;
    } finally {
      _isRequestInProgress = false;
    }
  }

  static Future getCheckSubscriptionRegistration(
      {int isAddPost = 0, String nameCheck = ""}) async {
    if (_isRequestInProgress) {
      print("getCheckSubscription call ignored — already in progress");
      return null;
    }

    _isRequestInProgress = true;

    print("ABC 12333");
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(
          NetWorkRequest.getCheckSubscriptionListName(
              userController.id.value, loginToken, isAddPost, nameCheck));

      response = await dio.post(WebService.baseUrl, data: formData);

      var status = response.data["status"].toString();
      if (status.toString() == "0" || status.toString() == "1") {
        final responseData = response.data;
        debugPrint("Response abc ${response.data}");
        return responseData;
      } else {
        final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
        if (isDataNotEmpty) {
          final responseData = response.data;
          debugPrint("Response abc ${response.data}");
          return responseData;
        }
      }
    } on SocketException catch (_) {
      Future.delayed(const Duration(seconds: 2), () {
        noIntenetConnectionPopup();
      });
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);
      return false;
    } finally {
      _isRequestInProgress = false;
    }
  }

  //Check Subscription
  static Future checkSubscriptionApi({int isAddPost = 0}) async {
    try {
      FormData formData = FormData.fromMap(
          NetWorkRequest.checkSubscriptionListReq(userController.id.value,
              userController.logintoken.value, isAddPost));

      var response = await dio.post(WebService.baseUrl, data: formData);

      if (response != null && response.statusCode == 200) {
        if (response.data != "") {
          var status = response.data["status"].toString();
          final msg = response.data["msg"].toString();

          print(response.data["data"]);
          if (status.toString() == "1") {
            return response.data["data"];
          } else if (status.toString() == "0") {
            return response.data["data"];
          } else if (status.toString() == "2") {
            ApiResponse.sessionExpired(msg: msg);
            return false;
          } else if (status.toString() == "3") {
            if (getx.Get.isSnackbarOpen) {
              getx.Get.closeAllSnackbars();
            }

            ApiResponse.openStoreRedirectDialog(
                WebService.homeScaffoldKey.currentContext!);
            return false;
          }
        }
      } else {
        return false;
      }
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);
      return false;
    }
  }

  //open app or play store

//open store

  //get followers list
  static Future getFollowers({start, limit}) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(NetWorkRequest.getFollowers(
          uid: userController.id.value,
          loginToken: loginToken,
          start: start,
          limit: limit,
          isFollowing: "1"));

      response = await dio.post(WebService.baseUrl, data: formData);
      printMsg(formData.fields.toString());
      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        final responseData = response.data["data"];
        if (responseData["followers_list"] != "[]" &&
            responseData["followers_list"] != null) {
          return responseData["followers_list"];
        }
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  //get followers list
  static Future userToUpgradeApi() async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(NetWorkRequest.postUserToUpgradeReq(
          uid: userController.id.value, loginToken: loginToken));

      response = await dio.post(WebService.baseUrl, data: formData);
      printMsg(formData.fields.toString());
      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        Future.delayed(const Duration(seconds: 2), () {
          displayMessageIcon(
              snackposition: SnackPosition.BOTTOM,
              message: response.data["msg"].toString(),
              color: successGreen,
              imageData: AppAssets.correct_transparentIcon);
        });
        return true;
      }
      return false;
    } on SocketException catch (_) {
      Future.delayed(const Duration(seconds: 2), () {
        noIntenetConnectionPopup();
      });

      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  static Future nameCheckBusinessRegistrationApi({required String name}) async {
    final loginToken = await WebService.getUserToken();
    Response response;
    try {
      FormData formData = FormData.fromMap(
          NetWorkRequest.nameCheckBusinessRegistrationRequest(
              uid: userController.id.value,
              loginToken: loginToken,
              name: name));
      printMsg(formData.fields.toString());

      response = await dio.post(WebService.baseUrl, data: formData);
      Map<String, dynamic> data = jsonDecode(response.toString());
      if (data['status'] == 1) {
        final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
        if (isDataNotEmpty) {
          return response.data["data"];
        }
      } else {
        Future.delayed(const Duration(seconds: 2), () {
          displayMessageIcon(
              snackposition: SnackPosition.BOTTOM,
              message: data['msg'],
              color: errorColor,
              imageData: AppAssets.errorIcon);
        });
        return false;
      }
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  static Future getPostCountApi() async {
    final loginToken = await WebService.getUserToken();
    try {
      FormData formData = FormData.fromMap(NetWorkRequest.getPostCountRequest(
          userController.id.value, loginToken));
      Response response = await dio.post(WebService.baseUrl, data: formData);
      if (response.statusCode != 200) return false;

      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        WebService.randomPagination =
            response.data["data"]["total_post_count"].toString() ?? "0";

        return;
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  static Future testServerApi() async {
    try {
      FormData formData = FormData.fromMap(NetWorkRequest.testServerReq());
      Response response = await dio.post(WebService.baseUrl, data: formData);
      if (response.statusCode != 200) return false;

      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        return;
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  static Future basicFreePlanApi() async {
    try {
      final loginToken = await WebService.getUserToken();
      FormData formData = FormData.fromMap(NetWorkRequest.basicFreePlanReq(
          loginToken: loginToken, uid: userController.id.value));
      Response response = await dio.post(WebService.baseUrl, data: formData);
      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        return response.data["data"];
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }

  static Future changeBusinessUserTypeApi(
      {required String name,
      required String address,
      required String newUserType,
      required String addressPlaceId,
      required String lat,
      required String lng,
      required String styles,
      required String membersid,
      required String about}) async {
    final loginToken = await WebService.getUserToken();
    Response response;

    try {
      final params = {
        "action": "UpdateBusinessProfile",
        'uid': userController.id.value,
        'login_token': loginToken,
        'business_type': newUserType,
        'name': name,
        'address': address,
        'address_lat': lat,
        'address_lng': lng,
        'city_name': WebService.cityName,
        'address_place_id': addressPlaceId,
        'styles': styles,
        'about_text': about,
        'device_type': WebService.deviceType,
        'app_version': WebService.appVersion,
        'app_token': WebService.appToken,
        'is_convert': "1",
        'member_ids': membersid,
        'signature_image': null,
        "files": null,
      };

      print("TESTED 1234 $params");
      FormData formData = await FormData.fromMap(params);

      response = await dio.post(WebService.baseUrl, data: formData);
      final isDataNotEmpty = ApiResponse.checkResponseStatus(response);
      if (isDataNotEmpty) {
        final eventParams = {
          "action": "UpdateBusinessProfile",
          'uid': userController.id.value,
          'login_token': loginToken,
          'business_type': newUserType,
          'name': name,
          'address': address,
          'address_lat': lat,
          'address_lng': lng,
          'about_text': about,
          'device_type': WebService.deviceType,
          'app_version': WebService.appVersion,
          'app_token': WebService.appToken,
        };
        if (newUserType == "1") {
          await FacebookEvents.studioProfileCreationEvent(params: eventParams);
        } else {
          await FacebookEvents.artistProfileCreationEvent(params: eventParams);
        }
        /* await FacebookEvents.subscriptionEvent(
          amount: WebService.purchasePrice,
          currency: WebService.purchaseCurrency,
          params: eventParams);*/

        if (WebService.selectedPlan == 0) {
          await FacebookEvents.subscriptionBasicEvent(
              amount: WebService.purchasePrice,
              // currency: WebService.purchaseCurrency,
              params: eventParams);
        } else {
          await FacebookEvents.subscriptionPremiumEvent(
              amount: WebService.purchasePrice,
              // currency: WebService.purchaseCurrency,
              params: eventParams);
        }

        await WebService.clearUserData();
        final responseData = await response.data["data"];
        // if (responseData != null || responseData != '') {
        //   if (responseData['profile'] != null &&
        //       responseData['profile'] != "") {
        final profile = await responseData['profile'];
        if (profile["user_type"].toString() == "2") {
          await WebService.setIsBusiness(true);
        } else {
          await WebService.setIsBusiness(false);
        }
        await WebService.setUserToken(profile['login_token']);
        await WebService.setUserIds(profile['id'].toString());
        await WebService.setCurrentUser(AppUser.fromJson(responseData));

        // displayMessage(response.data["msg"].toString(), Colors.blue);
        return true;
        // }
        // }
      }
      return false;
    } on SocketException catch (_) {
      noIntenetConnectionPopup();
      return false;
    } on DioError catch (e) {
      ApiResponse.handleError(e);

      return false;
    }
  }
}
