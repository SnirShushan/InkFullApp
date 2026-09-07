import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ink/src/apps.dart';
import 'package:ink/src/ui/screen/home/imageDetails/post_details.dart';
import 'package:ink/src/ui/screen/notification/notifications.dart';
import 'package:ink/src/utils/push_notification.dart';
import 'package:ink/src/utils/webService.dart';

import 'dependency_injection.dart';
import 'src/utils/facebook_events/facebook_events.dart';

Future<void> _initializeFirebaseMessaging() async {
  RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();
  DependencyInjection.init();
  WebService.setNotificationData(json.encode(message?.data));
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  await PushNotificationsManager().init();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize essential servicesn
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();
  await FacebookEvents.facebookAppEvents.setAutoLogAppEventsEnabled(false);
  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(backgroundNotificationMessageHandler);

  // Decode images at display size; keep a larger RAM cache for R2 grids
  PaintingBinding.instance.imageCache.maximumSize = 200;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 160 * 1024 * 1024;

// Initialize Dependency Injection immediately
  Future.microtask(() => _initializeFirebaseMessaging());
  if (Platform.isAndroid) {
    _configureAndroidSystemUI();
  }

  runApp(EasyLocalization(
      supportedLocales: const [Locale('he', 'HE')],
      path: 'assets/resources',
      fallbackLocale: const Locale('he', 'HE'),
      child: const MyApp()));
}

void _configureAndroidSystemUI() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.black,
    systemNavigationBarDividerColor: Colors.transparent,
    statusBarColor: Colors.black,
    statusBarBrightness: Brightness.light,
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarContrastEnforced: false,

  ));

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);


  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: SystemUiOverlay.values,
  );
}

Future<void> backgroundNotificationMessageHandler(RemoteMessage message) async {
  try {
    if (message.data.isEmpty) return;

    if (message.data.containsKey('screen')) {
      String screen = message.data['screen'].toString();
      if (screen == "new_post" || screen == "post_mention") {
        Get.offAll(
            () => PostDetails(postId: message.data['pid'], isArtist: false));
      } else {

        Get.offAll(() => NotificationScreen(
            isRequest:
                message.data['is_request'].toString() == "1" ? true : false,
            isPushNotification: true));
      }
    }
  } catch (e, stack) {
    debugPrint('Error in backgroundNotificationMessageHandler: $e');
    debugPrint('Stack trace: $stack');
  }
}
