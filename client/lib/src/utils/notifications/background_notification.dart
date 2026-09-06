import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/artistsListController.dart';
import 'package:ink/src/controller/notificationController.dart';
import 'package:ink/src/ui/screen/home/imageDetails/post_details.dart';
import 'package:ink/src/ui/screen/notification/notifiacationTypes.dart';
import 'package:ink/src/ui/screen/notification/notifications.dart';
import 'package:ink/src/ui/screen/splash/splashscreen.dart';

class NotificationBackgroundHandler {
  static void handleMessageOpenedApp(RemoteMessage message) async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    if (message.data.isNotEmpty) {
      final Map<String, dynamic> data = message.data;
      if (data['screen'] == "new_post" || data['screen'] == "post_mention") {
        Get.offAll(() => PostDetails(postId: data['pid'], isArtist: false));
      } else if (data['screen'] == "notification" ||
          data['screen'] == NotificationType.requestArtist ||
          data['screen'] == NotificationType.requestStudio ||
          data['screen'] == NotificationType.sentRequestStudio ||
          data['screen'] == NotificationType.sentRequestArtist) {
        // Navigate to notifications screen
        goToNotifications(isRequestScreen: data['is_request'] == "1");
      } else {
        // Navigate to dashboard
        goToDashboard();
      }
    }
    // Show a local notification (optional)
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your_channel_id', 'your_channel_name',
            channelDescription: 'your_channel_description',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon',
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }
}

void goToDashboard() {
  Get.offAll(() => SplashScreen());
}

Future<void> goToNotifications({required bool isRequestScreen}) async {
  final NotificationController notificationController =
      Get.put(NotificationController());

  if (!isRequestScreen) {
    notificationController.startIndexRequest = 0;
    notificationController.tattooRequestsList.clear();
    await notificationController.fetchRequests();
    Get.offAll(() => NotificationScreen(
        isRequest: isRequestScreen, isPushNotification: true));
  } else {
    final ArtistListController artistListController =
        Get.put(ArtistListController());
    notificationController.startNotification = 0;
    notificationController.notificationList.clear();
    await notificationController
        .fetchNotifications()
        .then((value) async => await artistListController.getArtists());
    Get.offAll(() => NotificationScreen(
        isRequest: isRequestScreen, isPushNotification: true));
  }
}

Future<void> handleNotificationNavigation(Map<String, dynamic> data) async {
  if (data['screen'] == "new_post" || data['screen'] == "post_mention") {
    Get.offAll(() => PostDetails(postId: data['pid'], isArtist: false));
  } else {
    goToNotifications(isRequestScreen: data['is_request'] == "1");
  }
}
