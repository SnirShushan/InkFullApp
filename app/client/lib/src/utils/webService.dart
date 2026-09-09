import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:ink/src/data/model/ArtistModel.dart';
import 'package:ink/src/data/model/folderImage.dart';
import 'package:ink/src/ui/screen/home/controller/post_details_controller.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/model/currentUser.dart';
import 'common.dart';
import 'firebase_dynamic_link_helper.dart';

class WebService {

  static const String channel = "ink.itapp2u.com/fb_events";
  static const MethodChannel platform = MethodChannel(channel);

  static String countryCode = "972";
  static String purchasePrice = "";
  static String purchaseCurrency = "";
  static int selectedPlan = 0;

  static bool isBodySideFront = true;
  static bool isExecute = true;
  static bool isrestoremessageLoading = false; // Used For Restore purchase loading show

  // static String googleApiKey = "AIzaSyDdTeFwDMiycVp1HyLduCxPxFKSpK0RaK0";
  static String googleApiKey = "AIzaSyCkGvtvc8k8xgRlpfTkczNJtTkMPLuAwww";

  static GlobalKey<ScaffoldState> homeScaffoldKey = GlobalKey<ScaffoldState>();

  //Live  isSandBox="" || debug isSandBox= ="1"
  static String isSandBox="";

  /// Local develop mode: skip OTP and auto-login `0544466912`.
  /// Must stay false for App Store / TestFlight / production builds.
  static bool developerMode = false;
  static const String devSkipPhone = "0544466912";

  /// Until Railway is redeployed with the new `/api` gateway, develop mode can
  /// hit the local Node server (`npm run dev` in `backend/`) via the emulator.
  /// Set false once production Railway has Login/GetHomeData.
  static const bool useLocalNewApiInDev = false;

  // New production API (Railway) + Cloudflare R2 media
  static String get baseUrl => useLocalNewApiInDev && developerMode
      ? "http://10.0.2.2:3000/api/"
      : "https://ink-api-production-2e1d.up.railway.app/api/";

  static String baseAssets =
      "https://pub-feef9d9f566147738bf9ecf90eb22fbd.r2.dev/assets/";

  // Legacy / local fallbacks (keep for reference)
  // static String baseUrl = "http://10.0.2.2:8080/api/"; //local docker/php api
  // static String baseAssets = "http://10.0.2.2:8080/assets/";
  // static String baseUrl = "https://inkisrael.co.il/api/";
  // static String baseAssets = "https://inkisrael.co.il/assets/";
  // static String baseUrl = "https://smartweb-tech.com/apps/ink/api/";
  // static String baseAssets = "https://smartweb-tech.com/apps/ink/assets/";

  // static const defaultImageUrl =
  //     "http://192.168.1.59/tattoo/assets/img/defult.png";

  static String appVersion = Platform.isAndroid ? "1.0.67" : "1.0.87";
  static const appToken = "123456";
  static String deviceType = Platform.isAndroid ? "a" : "i";
  static double locationRadius = 100.0;
  static String isDebug = "0";
  static String followUsers = "0";
  static String unreadnotification = "0";
  static String unreadMessage = "0";

  //Basic Free Plan DB
  static String basicFreePlanDBID = "basic_free_plan";
  // static bool basicPlanTempData = false;
  static bool isTempBasicPurchaseLoading = false;
  static bool isTempPremiumPlanPurchase = false;
  static bool isTempPremiumPlanPurchaseLoading = false;

  static String tempArtistIdList="";

  //
  static String randomPagination="0";
  static int lastRandomPagination=20;
  static List<int> allStartPointsList=[];

  static List<StylesList> selectstylelist = [];
  static bool tempHomeselectstylelist = false;
  // developerMode is defined near the top with API URLs
  static bool tmpStyleList = false;
  static bool isSessionExpire = false;

  static String styleImgUrl = "${baseAssets}images/styles/";
  static String _profileImageUrl = "${baseAssets}uploads/profile_images/";
  static String startupImgUrl = "${baseAssets}uploads/";
  static String bodyImgUrl = "${baseAssets}uploads/body_images/";

  /// Local profile proxy base (`…/proxy_profile.php?f=` + filename).
  static String get localProfileProxyBase =>
      baseAssets.replaceAll("/assets/", "/proxy_profile.php?f=");

  /// Profile image base. On local API always routes through [localProfileProxyBase]
  /// so missing local files can be fetched/cached (or fall back to placeholder).
  static String get profileImageUrl =>
      isLocalApi ? localProfileProxyBase : _profileImageUrl;

  static set profileImageUrl(String value) {
    _profileImageUrl = value;
  }

  // static const String registerpdf = "${baseAssets}uploads/regipdf.pdf";

  static String generateTmpOTP = "";
  static String tempImageUrl =
      "${baseAssets}img/defult.png";

  /// Local/emulator fallback when an image file is missing.
  static String get localPlaceholderUrl => "${baseAssets}img/defult.png";

  /// True when there is no real uploaded profile photo.
  static bool isMissingProfileImage(String? url) {
    final raw = (url ?? "").trim();
    if (raw.isEmpty || raw == "null" || raw == "undefined") return true;
    if (raw.contains("/img/defult.png") || raw.contains("/img/default.png")) {
      return true;
    }
    return false;
  }

  /// Resolve a profile photo. Accepts filename OR absolute URL (never double-prefix).
  static String resolveProfileImage(String? url) {
    return resolveImageUrl(url, base: profileImageUrl);
  }

  static String _profileProxyUrl(String fileName) {
    final name = fileName.split("/").last.split("?").first.trim();
    if (name.isEmpty) return localPlaceholderUrl;
    return "$localProfileProxyBase${Uri.encodeComponent(name)}";
  }

  /// Resolve media URLs for the current environment.
  /// Production uses absolute R2 / CDN URLs from the API — keep them as-is.
  static String resolveImageUrl(String? url, {String? base}) {
    var raw = (url ?? "").trim();
    if (raw.isEmpty || raw == "null" || raw == "undefined") {
      return localPlaceholderUrl;
    }

    // Undo accidental base+absolute concatenation:
    // ".../profile_images/https://cdn/.../file.jpg" → "https://cdn/.../file.jpg"
    final match = RegExp(r'https?://\S+$').firstMatch(raw);
    if (raw.contains('http') && match != null && !raw.startsWith('http')) {
      raw = match.group(0)!;
    } else if (RegExp(r'https?://.*https?://').hasMatch(raw)) {
      raw = raw.substring(raw.indexOf('http', 1));
    }

    // Already the default avatar logo
    if (raw.contains("/img/defult.png") || raw.contains("/img/default.png")) {
      return localPlaceholderUrl;
    }

    if (raw.startsWith("http://") || raw.startsWith("https://")) {
      // Prefer Cloudflare R2 / https CDN URLs unchanged (fast path)
      if (!isLocalApi) {
        // Rewrite dead legacy host to R2 when possible
        if (raw.contains("inkisrael.co.il")) {
          return raw.replaceFirst(
              RegExp(r'https?://inkisrael\.co\.il', caseSensitive: false),
              baseAssets.replaceAll(RegExp(r'/assets/?$'), ''));
        }
        return raw;
      }
      raw = raw.replaceAll("127.0.0.1", "10.0.2.2");
      if (raw.contains("proxy_profile.php") || raw.contains("proxy_image.php")) {
        return raw;
      }
      // Local profile path → profile proxy (files are often missing on disk)
      if (raw.contains("/profile_images/")) {
        return _profileProxyUrl(raw);
      }
      if (raw.contains("10.0.2.2:8080") || raw.contains("localhost:8080")) {
        return raw;
      }
      // Firebase / Google storage: fetch via host-side proxy (downscaled)
      if (raw.contains("googleapis.com") ||
          raw.contains("firebasestorage") ||
          raw.contains("googleusercontent.com")) {
        return "http://10.0.2.2:8080/proxy_image.php?w=720&u=${Uri.encodeComponent(raw)}";
      }
      // Emulator may have internet — keep remote URL instead of forcing placeholder
      return raw;
    }

    final prefix = base ?? "";
    final full = "$prefix$raw";
    if (!isLocalApi) return full;

    // Style icons exist under local assets.
    if (prefix.contains("styles") || full.contains("/styles/")) {
      return prefix.isNotEmpty ? full : "$styleImgUrl$raw";
    }
    // Profile images: use local/remote proxy (do not force placeholder)
    if (prefix.contains("profile") ||
        full.contains("profile_images") ||
        prefix.contains("proxy_profile.php")) {
      return _profileProxyUrl(raw);
    }
    // Body / other uploads: try real local URL; widgets show errorWidget if missing
    if (prefix.contains("body") || prefix.contains("uploads")) {
      return prefix.isNotEmpty ? full : "$bodyImgUrl$raw";
    }
    return full;
  }

  static String docUrl = "${baseAssets}uploads/";

  static String get registerpdf => "${docUrl}reg-data-1.pdf";
  static String get termAndConditionUrl => "${docUrl}terms-data.pdf";
  static String get regularQuestionAndAnswers =>
      "${docUrl}Regular-account-questions-and-answers.pdf";
  static String get businessQuestionAndAnswers =>
      "${docUrl}Business-account-questions-and-answers.pdf";

  static const String whatsappclient2 = "+972525401620";
  static const String emailclient = "inkraelco@gmail.com";
  static const String phonenoclient = "0508821562";

  static const String legalPublicBase =
      "https://ink-api-production-2e1d.up.railway.app";
  static String get privacyPolicyUrl => "$legalPublicBase/privacy";
  static String get termsOfUseUrl => "$legalPublicBase/terms";

  static Future<void> openLegalUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(uri);
      }
    } catch (e) {
      displayMessageIcon(
          message: e.toString(),
          snackposition: SnackPosition.BOTTOM,
          color: errorColor,
          imageData: AppAssets.errorIcon);
    }
  }
  //qna
  // static const String questionAndAnswers = "${baseUrl}index.php?action=GetPages&page_name=question_answer";

  static AppUser user = AppUser();

  static bool isSubscriptionEnable = true;

  static bool isEnableCameraUpload = false;
  static bool isPhotoSelectionLimit = true;

  /// True only for the legacy PHP docker stack (needs local image proxies).
  /// New Node API (local :3000 or Railway) serves absolute R2 URLs — not local.
  static bool get isLocalApi =>
      (baseUrl.contains('10.0.2.2:8080') ||
          baseUrl.contains('127.0.0.1:8080') ||
          baseUrl.contains('localhost:8080')) &&
      !baseAssets.contains('r2.dev');

  static Future<bool> checkConnection() async {
    // Emulator often has no public DNS; local API still works via 10.0.2.2.
    if (isLocalApi) return true;
    try {
      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      //  displayMessage("alerts.network_error", Colors.red);
      // displayMessageIcon(
      //     message: "alerts.network_error",
      //     snackposition: SnackPosition.BOTTOM,
      //     color: errorColor,
      //     imageData: AppAssets.errorIcon);
      return false;
    }
  }

  static Future<bool> checkConnection2() async {
    if (isLocalApi) return true;
    try {
      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      //  displayMessage("alerts.network_error", Colors.red);

      // displayMessageIcon(
      //     message:
      //         "בעקבות בעיה טכנית הפנייה לא נשלחה.\nלתמיכה טכנית חייגו: 053-356-2686",
      //     snackposition: SnackPosition.BOTTOM,
      //     color: errorColor,
      //     imageData: AppAssets.errorIcon);

      return false;
    }
  }

  static Future<bool> checkConnectionNoMsg() async {
    if (isLocalApi) return true;
    try {
      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      //  displayMessage("alerts.network_error", Colors.red);

      return false;
    }
  }

  static Future<bool> checkConnectionShowMsg() async {
    if (isLocalApi) return true;
    try {
      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        displayMessageIcon(
            message:
            "בעקבות בעיה טכנית הפנייה לא נשלחה.\nלתמיכה טכנית חייגו: 053-356-2686",
            snackposition: SnackPosition.BOTTOM,
            color: errorColor,
            imageData: AppAssets.errorIcon);
        return false;
      }
    } on SocketException catch (_) {
      displayMessageIcon(
          message:
          "בעקבות בעיה טכנית הפנייה לא נשלחה.\nלתמיכה טכנית חייגו: 053-356-2686",
          snackposition: SnackPosition.BOTTOM,
          color: errorColor,
          imageData: AppAssets.errorIcon);

      return false;
    }
  }

  static const String nothingDisplayMSG = "עדיין אין פוסטים להציג כאן";

  static printMsg(dynamic msg) {
    if (developerMode) {
      dev.log(msg.toString());
    }
  }

  // static isImageOpen

  static Future setAdClosed() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setBool('isClosed', true);
    await _prefs.setString('time', DateTime.now().toString());
  }

  static Future getAdClosed() async {
    final pref = await SharedPreferences.getInstance();
    // bool isBusiness = (pref.getBool('isClosed') ?? false);
    String? time = pref.getString('time');
    return time;
  }

  static Future<dynamic> removeAdClosed() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove("isClosed");
  }

  static Future setIsBusiness(bool isBusiness) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setBool('isBusiness', isBusiness);
  }

  static Future getIsBusiness() async {
    final pref = await SharedPreferences.getInstance();
    bool isBusiness = (pref.getBool('isBusiness') ?? false);
    return isBusiness;
  }


  static Future setCurrentUser(AppUser user) async {
    final pref = await SharedPreferences.getInstance();
    final json = jsonEncode(user.toJson());

    await pref.setString('user', json);
  }

  static Future<AppUser> getCurrentUser() async {
    final pref = await SharedPreferences.getInstance();
    final json = pref.getString('user');
    if (json == null) {
      return AppUser();
    }
    return AppUser.fromJson(jsonDecode(json));
  }

  static setRegistrationData(String token) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString("registrationmobile", token);
  }

  static Future<String?> getRegistrationData() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String? token = _prefs.getString("registrationmobile");
    return token;
  }

  static setUserToken(String token) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString("tokenid", token);
  }

  static Future<String?> getUserToken() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String? token = _prefs.getString("tokenid");
    return token;
  }

  static void setUserBusinessType(String token) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString("userBusinessType", token);
  }

  static Future<String?> getUserBusinessType() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String? token = _prefs.getString("userBusinessType");
    return token;
  }

  static setUserIds(String token) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString("userids", token);
  }

  static Future<String?> getUserIds() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String? token = _prefs.getString("userids");
    return token;
  }

  static void setDeviceToken(String? token) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString("DEVICE_TOKEN", token!);
  }

  static Future<String?> getDeviceToken() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String? token = _prefs.getString("DEVICE_TOKEN");
    return token;
  }

  static Future<String?> getNotificationData() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String? notification = _prefs.getString("NOTIFICATION");
    return notification;
  }

  static void setNotificationData(String? notification) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString("NOTIFICATION", notification!);
  }

  static Future clearUserData() async {
    final prefs = await SharedPreferences.getInstance();

    const keysToRemove = [
      'user',
      'styles',
      'DEVICE_TOKEN',
      'homeScreenApiHold',
      'inspirationScreenApiHold',
      'businessScreenApiHold',
    ];

    for (final key in keysToRemove) {
      await prefs.remove(key);
    }
  }

  //change user type params
  static String? isArtist = "1";
  static late String name;
  static late String email;
  static late String address;
  static String cityName = "";
  static late String placeId;
  static late double lat;
  static late double lang;
  static late String aboutText;
  static late List<String> memberList = [];
  static late List<StylesList> changeUserStyleList = [];
  static List<Artist> artistList = [];
  static late File signFile;

  //uploading image
  static File pickedFile = File("");
  static String artist_uid = "";
  static String studio_uid = '';
  static bool isSplashHomeScreen=true;
  static bool shouldRefresh=false;

  //generate random string
  static String generateRandomString(int len) {
    var r = Random();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => chars[r.nextInt(chars.length)]).join();
  }

  //share image


  //folder
  static List<FolderImage> folderList = <FolderImage>[];

  //email validator
  static bool isValidEmail(str) {
    return RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(str);
  }

  static Future<void> openUrl(String url) async {
    final Uri mapUrl = Uri.parse(url);
    try {
      if (!await launchUrl(mapUrl)) {
        displayMessageIcon(
            message: 'לא ניתן לפתוח קישור זה $mapUrl',
            snackposition: SnackPosition.BOTTOM,
            color: errorColor,
            imageData: AppAssets.errorIcon);
      }
    } catch (e) {
      displayMessageIcon(
          message: e.toString(),
          snackposition: SnackPosition.BOTTOM,
          color: errorColor,
          imageData: AppAssets.errorIcon);
    }
  }

  //tattoo size
  static String tattooSizeLittle = "קטן";
  static String tattooSizeMedium = "בינוני";
  static String tattooSizeBig = "גדול";

  static String setTattooSize(String str) {
    if (str == "L") {
      return tattooSizeLittle;
    } else if (str == "M") {
      return tattooSizeMedium;
    } else {
      return tattooSizeBig;
    }
  }

  static bool isNotificationBackPressed = false;

  // static Future<bool> isImageDeleted(imageUrl) async {
  //   http.Response res;
  //   try {
  //     res = await http.get(Uri.parse(imageUrl));
  //   } catch (e) {
  //     return true;
  //   }
  //   if (res.statusCode != 200) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  //check is data blank or not
  static bool checkBlankData(dynamic data) {
    if (data == null) {
      return true;
    } else if (data == "") {
      return true;
    } else if (data.toString().isEmpty == "") {
      return true;
    }
    return false;
  }

  static void setPrice(

      {required List<ProductDetails> products,
        required String pID,
        required int plan}) {
    var price = products.lastWhere((product) => product.id == pID).price;
    selectedPlan = plan; //0=basic 1=premium
    purchaseCurrency =
        products.lastWhere((product) => product.id == pID).currencyCode;
    purchasePrice =
        price.replaceAll(RegExp(r'[^\d,.]'), '').replaceAll(',', '');
  }
}
