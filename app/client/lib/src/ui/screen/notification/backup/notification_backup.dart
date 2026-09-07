// import 'dart:developer';
//
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/data/model/currentUser.dart';
// import 'package:ink/src/ui/screen/profile/businessUserProfile.dart';
// import 'package:ink/src/utils/webService.dart';
//
// import '../../../controller/notificationController.dart';
// import '../../../utils/colors.dart';
// import '../../../utils/common.dart';
// import '../../widgets/request_list_tile.dart';
// import '../home/imageDetails/post_details.dart';
// import 'notifiacationTypes.dart';
//
// class NotificationScreen extends StatefulWidget {
//   final bool isRequest;
//   const NotificationScreen({Key? key, required this.isRequest})
//       : super(key: key);
//
//   @override
//   State<NotificationScreen> createState() => _NotificationScreenState();
// }
//
// class _NotificationScreenState extends State<NotificationScreen>
//     with SingleTickerProviderStateMixin {
//   int selected = 0;
//
//   final NotificationController listController =
//       Get.put(NotificationController());
//   TabController? tabController;
//
//   final notificationController = Get.put(NotificationController());
//   final notificationScrollController = ScrollController();
//   bool? isNotBusiness;
//
//   @override
//   void initState() {
//     super.initState();
//     tabController = TabController(
//         length: 2, vsync: this, initialIndex: widget.isRequest ? 1 : 0);
//     _initialization();
//   }
//
//   Future<void> _initialization() async {
//     AppUser currentUser = await WebService.getCurrentUser();
//
//     isNotBusiness = currentUser.profile!.userType != "1";
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Scaffold(
//         appBar: AppBar(
//             toolbarHeight: Get.height * 0.02,
//             elevation: 0,
//             backgroundColor: appbarBg,
//             automaticallyImplyLeading: false,
//             centerTitle: true,
//             leading:
//                 IconButton(onPressed: () {}, icon: const Icon(Icons.close)),
//             bottom: PreferredSize(
//                 preferredSize: Size.fromHeight(Get.size.height * 0.06),
//                 child: Row(children: [
//                   Expanded(
//                       flex: 5,
//                       child: TabBar(
//                           controller: tabController,
//                           labelColor: defaultBlack,
//                           labelStyle: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: size.width * 0.04),
//                           indicatorWeight: 5,
//                           indicatorSize: TabBarIndicatorSize.label,
//                           unselectedLabelColor: Colors.grey,
//                           indicator: const UnderlineTabIndicator(
//                               borderSide: BorderSide.none),
//                           isScrollable: false,
//                           onTap: (index) async {
//                             listController.isLoading.value = true;
//                             if (index == 0) {
//                               notificationController.startNotification = 0;
//                               notificationController.notificationList.clear();
//                               await listController.fetchNotifications();
//                             } else {
//                               notificationController.startIndexRequest = 0;
//                               notificationController.tattooRequestsList.clear();
//                               await listController.fetchRequests();
//                             }
//                           },
//                           tabs: const [
//                             Tab(text: "התראות"), // Notifications
//                             Tab(text: "תיבת פניות"), //inquiry box
//                           ])),
//                   Padding(
//                       padding: const EdgeInsets.only(
//                           left: 6.0, top: 6.0, bottom: 6.0),
//                       child: Image.asset("assets/images/ink_logo.png",
//                           fit: BoxFit.fitHeight,
//                           width: Get.size.width * 0.05,
//                           height: Get.size.height * 0.06))
//                 ]))),
//         body: TabBarView(
//             controller: tabController,
//             physics: const NeverScrollableScrollPhysics(),
//             children: [
//               //notifications
//               Obx(() => listController.isLoading.value
//                   ? const Center(child: CircularProgressIndicator())
//                   : listController.notificationList.isEmpty
//                       ? Center(
//                           child: const Text("alerts.no_new_notifications").tr())
//                       : ListView.builder(
//                           controller:
//                               listController.scrollControllerNotification,
//                           shrinkWrap: true,
//                           itemCount: listController.notificationList.length + 1,
//                           itemBuilder: (BuildContext context, int index) {
//                             if (index <
//                                 listController.notificationList.length) {
//                               final profileImage = listController
//                                           .notificationList[index].notiUser !=
//                                       null
//                                   ? listController.notificationList[index]
//                                       .notiUser!.profileImage!
//                                   : '';
//                               return listController
//                                           .notificationList[index].notiUser ==
//                                       null
//                                   ? const SizedBox()
//                                   : Column(
//                                       children: [
//                                         InkWell(
//                                             onTap: () {
//                                               if (listController
//                                                       .notificationList[index]
//                                                       .pid !=
//                                                   "0") {
//                                                 Get.to(PostDetails(
//                                                     postId: listController
//                                                         .notificationList[index]
//                                                         .pid!,
//                                                     isArtist: false));
//                                               } else {
//                                                 Get.to(() => BusinessProfileScreen(
//                                                     bId: listController
//                                                                 .notificationList[
//                                                                     index]
//                                                                 .notiUser !=
//                                                             null
//                                                         ? listController
//                                                             .notificationList[
//                                                                 index]
//                                                             .notiUser!
//                                                             .id!
//                                                         : "",
//                                                     fromPost: false));
//                                               }
//                                             },
//                                             child: IntrinsicHeight(
//                                                 child: Padding(
//                                                     padding:
//                                                         const EdgeInsets.all(
//                                                             8.0),
//                                                     child: Row(
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .center,
//                                                         mainAxisAlignment:
//                                                             MainAxisAlignment
//                                                                 .center,
//                                                         children: [
//                                                           buildCachedNetworkImage(
//                                                               height:
//                                                                   size.width *
//                                                                       0.12,
//                                                               width:
//                                                                   size.width *
//                                                                       0.12,
//                                                               url: WebService
//                                                                       .profileImageUrl +
//                                                                   profileImage,
//                                                               radius: 50),
//                                                           SizedBox(
//                                                               height:
//                                                                   size.width *
//                                                                       0.12,
//                                                               width: Get.width *
//                                                                   0.35,
//                                                               child: Column(
//                                                                   mainAxisAlignment:
//                                                                       MainAxisAlignment
//                                                                           .center,
//                                                                   crossAxisAlignment:
//                                                                       CrossAxisAlignment
//                                                                           .start,
//                                                                   children: [
//                                                                     Text(
//                                                                         listController.notificationList[index].notiUser !=
//                                                                                 null
//                                                                             ? listController
//                                                                                 .notificationList[
//                                                                                     index]
//                                                                                 .notiUser!
//                                                                                 .name!
//                                                                             : "",
//                                                                         maxLines:
//                                                                             1,
//                                                                         overflow:
//                                                                             TextOverflow
//                                                                                 .ellipsis,
//                                                                         style: Theme.of(context)
//                                                                             .textTheme
//                                                                             .titleMedium!
//                                                                             .copyWith(fontWeight: FontWeight.bold)),
//                                                                     buildNotificationMsg(
//                                                                         type: listController
//                                                                             .notificationList[
//                                                                                 index]
//                                                                             .notiType,
//                                                                         index:
//                                                                             index)
//                                                                   ])),
//                                                           const VerticalDivider(
//                                                               thickness: 2),
//                                                           SizedBox(
//                                                               width: Get.width *
//                                                                   0.37,
//                                                               child: Center(
//                                                                   child: buildNotificationTimeWidget(
//                                                                       index:
//                                                                           index,
//                                                                       type: listController
//                                                                           .notificationList[
//                                                                               index]
//                                                                           .notiType!,
//                                                                       time: !WebService.checkBlankData(listController
//                                                                               .notificationList[
//                                                                                   index]
//                                                                               .dateUpdated)
//                                                                           ? listController
//                                                                               .notificationList[
//                                                                                   index]
//                                                                               .dateUpdated
//                                                                           : listController
//                                                                               .notificationList[index]
//                                                                               .dateAdded)))
//                                                         ])))),
//                                         const Divider(),
//                                       ],
//                                     );
//                             } else {
//                               return Padding(
//                                 padding: const EdgeInsets.all(10.0),
//                                 child: Center(
//                                     child: listController.hasMoreNotification
//                                         ? const CircularProgressIndicator()
//                                         : const SizedBox()),
//                               );
//                             }
//                           })),
//               //tattoo requests
//               Obx(() => listController.isLoadingRequest.value
//                   ? const Center(child: CircularProgressIndicator())
//                   : listController.tattooRequestsList.isEmpty
//                       ? const Center(child: Text("עדיין לא התקבלו פניות"))
//                       : ListView.builder(
//                           shrinkWrap: true,
//                           controller: listController.scrollControllerRequest,
//                           itemCount:
//                               listController.tattooRequestsList.length + 1,
//                           itemBuilder: (BuildContext context, int index) {
//                             if (index <
//                                 listController.tattooRequestsList.length) {
//                               return RequestListTile(
//                                   title: isNotBusiness!
//                                       ? listController
//                                           .tattooRequestsList[index].name!
//                                       : listController.tattooRequestsList[index]
//                                               .businessRow!.name! ??
//                                           "",
//                                   tattooSize: WebService.setTattooSize(
//                                       listController.tattooRequestsList[index]
//                                           .tattooSize!),
//                                   imgUrl: (isNotBusiness!
//                                       ? listController.tattooRequestsList[index]
//                                                   .senderRow ==
//                                               null
//                                           ? ""
//                                           : listController
//                                               .tattooRequestsList[index]
//                                               .senderRow!
//                                               .profileImage!
//                                       : listController.tattooRequestsList[index]
//                                                   .businessRow ==
//                                               null
//                                           ? ""
//                                           : listController
//                                               .tattooRequestsList[index]
//                                               .businessRow!
//                                               .profileImage!),
//                                   tattooRequest:
//                                       listController.tattooRequestsList[index]);
//                             } else {
//                               return Padding(
//                                 padding: const EdgeInsets.all(10.0),
//                                 child: Center(
//                                     child: listController.hasMoreRequest
//                                         ? const CircularProgressIndicator()
//                                         : const SizedBox()),
//                               );
//                             }
//                           })),
//             ]));
//   }
//
//   //request accept-reject
//   buildNotificationTimeWidget({index, type, time}) {
//     final postedOn = getPostedOnText(time);
//
//     if (type == "studio_request_sent") {
//     } else if (type == "post_mention") {
//     } else if (type == "new_post") {
//     } else if (type == NotificationType.requestArtist ||
//         type == NotificationType.requestStudio) {
//       if (listController.notificationList[index].status == "0") {
//         return SizedBox(
//           width: Get.width * 0.4,
//           child: Column(
//             mainAxisSize: MainAxisSize.max,
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               Flexible(
//                   child: Text(postedOn,
//                       style: Theme.of(context).textTheme.titleSmall)),
//               SizedBox(height: Get.size.height * 0.01),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   SizedBox(
//                       width: Get.width * 0.15,
//                       height: Get.height * 0.035,
//                       child: ElevatedButton(
//                           onPressed: () => listController.acceptInvitation(
//                               artistId: listController
//                                   .notificationList[index].notiUser!.id,
//                               actionStatus: "1"),
//                           style: ElevatedButton.styleFrom(
//                               elevation: 0.0,
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.all(
//                                       Radius.circular(Get.width * 0.03))),
//                               backgroundColor: defaultAppColor),
//                           child: const FittedBox(child: Text("אישור")))),
//                   const SizedBox(width: 3),
//                   SizedBox(
//                     width: Get.width * 0.18,
//                     height: Get.height * 0.035,
//                     child: ElevatedButton(
//                         onPressed: () => listController.acceptInvitation(
//                             artistId: listController
//                                 .notificationList[index].notiUser!.id,
//                             actionStatus: "2"),
//                         style: ElevatedButton.styleFrom(
//                             elevation: 0.0,
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.all(
//                                     Radius.circular(Get.width * 0.03))),
//                             backgroundColor: Colors.red),
//                         child: const FittedBox(
//                             child: Text(
//                           "לא מאשר",
//                         ))),
//                   )
//                 ],
//               ),
//             ],
//           ),
//         );
//       }
//     }
//     return Text(postedOn, style: Theme.of(context).textTheme.titleSmall);
//   }
//
//   //notification msg
//   buildNotificationMsg({String? type, required int index}) {
//     String msg = "";
//
//     if (type == NotificationType.postMention) {
//       msg = "notification.mentioned_in_post"; //mentioned you in post
//     } else if (type == NotificationType.newPost) {
//       msg = "notification.new_post"; //Upload a new photo
//     } else if (type == NotificationType.requestArtist ||
//         type == NotificationType.requestStudio) {
//       if (listController.notificationList[index].status! == "1") {
//         msg = "notification.you_accepted_request"; //you approved request
//       } else if (listController.notificationList[index].status! == "2") {
//         msg = "notification.you_declined_request";
//       } else if (listController.notificationList[index].status! == "0") {
//         msg = "notification.sent_request"; //Tag you as a tattoo artist
//       }
//     } else if (type == NotificationType.sentRequestArtist ||
//         type == NotificationType.sentRequestStudio) {
//       if (listController.notificationList[index].status! == "1") {
//         msg = "notification.accepted_request";
//       } else if (listController.notificationList[index].status! == "2") {
//         msg = "notification.declined_request"; //Declined request
//       } else if (listController.notificationList[index].status! == "0") {
//         msg = "notification.received_request"; //A new request has been received
//       }
//     }
//     // print(msg);
//     return Text(msg, style: Theme.of(context).textTheme.titleSmall, maxLines: 1)
//         .tr();
//   }
//
//   //today tomorrow or date
//   getPostedOnText(String date) {
//     log("given date  : $date");
//
//     var now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = DateTime(now.year, now.month, now.day - 1);
//     var testrcvdDate = DateTime.parse(date);
//     final rcvdDate =
//         DateTime(testrcvdDate.year, testrcvdDate.month, testrcvdDate.day);
//
//     log("created date  : ${DateFormat('dd.MM.yyyy').format(rcvdDate).toString()}");
//
//     if (rcvdDate == today) {
//       return "היום"; //today
//     } else if (rcvdDate == yesterday) {
//       return "אתמול"; //yesterday
//     } else {
//       // final finalDate = date
//       return DateFormat('dd.MM.yyyy').format(rcvdDate).toString();
//     }
//   }
// }
