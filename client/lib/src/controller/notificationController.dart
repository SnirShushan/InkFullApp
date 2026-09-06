import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/artistsListController.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/utils/webService.dart';

import '../ui/screen/notification/models/notificationModel.dart';
import '../ui/screen/notification/models/tattooRequest.dart';

class NotificationController extends GetxController {
  final artistController = Get.put(ArtistListController());
  RxBool isLoading = true.obs;
  RxInt activeIndex = 0.obs;
  //notification
  int startNotification = 0;
  int limitNotification = 10;
  RxBool hasMoreNotification = true.obs;
  RxBool isLoadingNotification = false.obs;
  final scrollControllerNotification = ScrollController();
  RxList<NotificationModelNew> notificationList = <NotificationModelNew>[].obs;
  bool isNotificationApiLoading = false;
  bool isMessageApiLoading = false;

  RxString notificationUnreadCount = "0".obs;
  RxString messageUnreadCount = "0".obs;
  RxString userTypes = "".obs;
  //request
  int startIndexRequest = 0;
  int limitRequest = 10;
  RxBool hasMoreRequest = true.obs;
  RxBool isLoadingRequest = true.obs;
  final scrollControllerRequest = ScrollController();
  RxList<TattooRequest> tattooRequestsList = <TattooRequest>[].obs;
  @override
  void onInit() {
    clearNotificationData();
    clearRequestData();
    hasMoreNotification.value = true;
    hasMoreRequest.value = true;
    scrollControllerNotification.addListener(notificationListener);
    scrollControllerRequest.addListener(requestListener);
    // fetchData();
    super.onInit();
  }

  //================= notification ===============

  //fetch notification
  fetchNotifications({bool isTempLoading = true}) async {
    if (isNotificationApiLoading) return;

    isNotificationApiLoading = true;
    isLoadingNotification.value = isTempLoading;
    try {
      await Network.getNotificationData(startNotification, limitNotification)
          .then((res) async {
        if (res != "" && res != null && res != false && res != "false") {
          AppUser currentUser = await WebService.getCurrentUser();
          userTypes.value = currentUser.profile!.userType!.toString();

          // final List newList = jsonDecode(res);

          final List newList = List.from(res);
          if (res.toString() == "[]" || res == []) {
            hasMoreNotification.value = false;
          } else {
            if (newList.length < limitNotification) {
              hasMoreNotification.value = false;
            } else {
              startNotification += 10;
            }
          }

          notificationList.addAll(newList.map((item) {
            return NotificationModelNew.fromJson(item as Map<String, dynamic>);
          }).toList());

          notificationUnreadCount.value = "0";
          notificationUnreadCount.value = WebService.unreadnotification;
        }
      });
    } finally {
      isLoading.value = false;
      isNotificationApiLoading = false;
      isLoadingNotification.value = false;
      notificationList.refresh();
    }
  }

  //accept request
  Future acceptInvitation({artistId, actionStatus}) async {
    await Network.acceptInvitation(
            artistId: artistId, actionStatus: actionStatus)
        .then((res) async {
      AppUser currentUser = await WebService.getCurrentUser();
      userTypes.value = currentUser.profile!.userType!.toString();
      startNotification = 0;
      notificationUnreadCount.value = "0";
      notificationList.clear();
      await fetchNotifications();
      await artistController.getArtists();
    });
  }

  //Update Read Notification Count
  Future readNotificationController(
      {notificationId, isRead, bool isRefreshpage = false}) async {
    await Network.readNotificationApi(
            notificationId: notificationId, isRead: isRead)
        .then((value) async {
      if (isRefreshpage == true) {
        startNotification = 0;
        notificationList.clear();
        notificationUnreadCount.value = "0";
        await fetchNotifications();
      }
      return;
    });
  }

  //================= request ===============

  //tattoo requests
  Future fetchRequests({bool isTempLoading = true}) async {
    if (isMessageApiLoading) return;
    isMessageApiLoading = true;

    try {
      isLoadingRequest.value = isTempLoading;
      await Network.getTattooRequestsData(startIndexRequest, limitRequest)
          .then((res) async {
        if (res != "" && res != null && res != false && res != "false") {
          final List newList = res;
          if (res.toString() == "[]" || res == []) {
            hasMoreRequest.value = false;
          } else {
            if (newList.length < limitNotification) {
              hasMoreRequest.value = false;
            } else {
              startIndexRequest += 10;
            }
          }
          tattooRequestsList.addAll(newList.map((item) {
            return TattooRequest.fromJson(item as Map<String, dynamic>);
          }).toList());

          tattooRequestsList.refresh();

          messageUnreadCount.value = "0";
          messageUnreadCount.value = WebService.unreadMessage;
        }
      });
    } finally {
      isMessageApiLoading = false;
      isLoadingRequest.value = false;
    }
  }

  //Update Message Count
  Future readMessageController({requestId, isRead}) async {
    await Network.readTattooRequestApi(requestId: requestId, isRead: isRead);
    return;
  }

  //old
  Future getTattooRequestsList() async {
    await Network.getTattooRequestsList().then((res) async {
      if (res != null) {
        tattooRequestsList.clear();
        await res
            .map((doc) => tattooRequestsList.add(TattooRequest.fromJson(doc)))
            .toList();
        isLoading.value = false;
      }
    });
  }

  //listeners
  notificationListener() {
    if (scrollControllerNotification.position.maxScrollExtent ==
        scrollControllerNotification.offset) {
      if (hasMoreNotification.value == true) {
        fetchNotifications(isTempLoading: false);
      }
    }
  }

  requestListener() {
    if (scrollControllerRequest.position.maxScrollExtent ==
        scrollControllerRequest.offset) {
      if (hasMoreRequest.value == true) {
        fetchRequests(isTempLoading: false);
      }
    }
  }

  //clear data
  clearNotificationData() async {
    AppUser currentUser = await WebService.getCurrentUser();
    userTypes.value = currentUser.profile!.userType!.toString();
    startNotification = 0;
    isLoadingNotification.value = true;
    notificationUnreadCount.value = "0";
    notificationList.clear();
  }

  clearRequestData() {
    startIndexRequest = 0;
    messageUnreadCount.value = "0";
    isLoadingRequest.value = true;
    tattooRequestsList.clear();
  }

  @override
  void dispose() {
    scrollControllerNotification.dispose();
    scrollControllerRequest.dispose();
    super.dispose();
  }

  Future fetchData() async {
    await fetchNotifications();
    await fetchRequests();
  }
}
