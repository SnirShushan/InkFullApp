import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:ink/src/ui/screen/home/imageDetails/post_details.dart';
import 'package:ink/src/ui/screen/notification/notifiacationTypes.dart';
import 'package:ink/src/ui/screen/notification/notifications.dart';
import 'package:ink/src/utils/webService.dart';

import '../controller/artistsListController.dart';
import '../controller/notificationController.dart';

class PushNotificationsManager {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  var user;
  var messages;

  Future<void> init() async {
    // For iOS request permission first.
    try {
      await _firebaseMessaging.requestPermission(
          alert: true, badge: true, sound: true);

      String? token = await _firebaseMessaging.getToken();

      WebService.setDeviceToken(token!);

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_notification');
      const InitializationSettings initializationSettings =
          InitializationSettings(
              android: initializationSettingsAndroid,
              iOS: DarwinInitializationSettings());
      await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: selectNotification,
      );

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        navigateToNotifyScreen(message.data);
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
        showNotification(message!.notification!);
        messages = message.data;

        refreshNotificationPage(message);
      });
    } catch (e) {
      if (kDebugMode) {
        print("Firebase Push Notification ${e.toString()}");
      }
    }
  }

  refreshNotificationPage(message) async {
    if (message.data['screen'].toString() == "notification" ||
        messages['screen'].toString() == NotificationType.requestArtist ||
        messages['screen'].toString() == NotificationType.requestStudio ||
        messages['screen'].toString() == NotificationType.sentRequestStudio ||
        messages['screen'].toString() == NotificationType.sentRequestArtist) {
      goToNotificationsRefresh(
          isRequestScreen:
              messages['is_request'].toString() == "1" ? true : false);
    }
  }

  Future selectNotification(NotificationResponse notificationResponse) async {
    WebService.printMsg(messages['screen'].toString());
    if (messages['screen'].toString() == "new_post" ||
        messages['screen'].toString() == "post_mention") {
      Get.offAll(() => PostDetails(postId: messages['pid'], isArtist: false));
    } else {
      goToNotifications(
          isRequestScreen:
              messages['is_request'].toString() == "1" ? true : false);
    }
  }

  navigateToNotifyScreen(notification) {
    if (notification['screen'].toString() == "new_post" ||
        messages['screen'].toString() == "post_mention") {
      Get.offAll(
          () => PostDetails(postId: notification['pid'], isArtist: false));
    } else {
      goToNotifications(
          isRequestScreen:
              messages['is_request'].toString() == "1" ? true : false);
    }
  }

  showNotification(RemoteNotification notification) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'high_importance_channel', 'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_notification'),
            icon: '@mipmap/ic_notification');

    const iOSChannelSpecifics = DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: platformChannelSpecifics);
  }

  // Future<void> goToDashboard() async {
  //   AppUser user = await WebService.getCurrentUser();
  //   if (user.profile!.userType!.toString() == "1") {
  //     Get.offAll(
  //         () => const DashBoard(
  //               initialIndex: 0,
  //             ),
  //         binding: DashBoardBinding());
  //   } else {
  //     Get.offAll(
  //         () => BusinessDashBoard(
  //               initialIndex: 0,
  //             ),
  //         binding: BusinessDashBoardBinding());
  //   }
  // }

  void goToNotifications({required bool isRequestScreen}) async {
    final NotificationController notificationController =
        Get.put(NotificationController());
    if (!isRequestScreen) {
      notificationController.startNotification = 0;
      notificationController.notificationList.clear();
      await notificationController.fetchNotifications();
    } else {
      notificationController.startIndexRequest = 0;
      notificationController.tattooRequestsList.clear();
      await notificationController.fetchRequests();
    }

    Get.offAll(() => NotificationScreen(
        isRequest: isRequestScreen, isPushNotification: true));
  }

  Future<void> goToNotificationsRefresh({required bool isRequestScreen}) async {
    final NotificationController notificationController =
        Get.put(NotificationController());

    if (!isRequestScreen) {
      notificationController.startIndexRequest = 0;
      notificationController.tattooRequestsList.clear();
      await notificationController.fetchRequests();
      // Get.offAll(() => NotificationScreen(
      //     isRequest: isRequestScreen, isPushNotification: true));
    } else {
      final ArtistListController artistListController =
          Get.put(ArtistListController());
      notificationController.startNotification = 0;
      notificationController.notificationList.clear();
      await notificationController
          .fetchNotifications()
          .then((value) async => await artistListController.getArtists());
      // Get.offAll(() => NotificationScreen(
      //     isRequest: isRequestScreen, isPushNotification: true));
    }
  }
}
