import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/notificationController.dart';
import 'package:ink/src/ui/screen/home/imageDetails/post_details.dart';
import 'package:ink/src/ui/screen/notification/notifiacationTypes.dart';
import 'package:ink/src/ui/screen/profile/businessUserProfile.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/webService.dart';

import '../models/notificationModel.dart';

class NotificationListWidget extends StatefulWidget {
  final NotificationController notificationController;
  final NotificationModelNew notificationModelNew;
  final int index;

  const NotificationListWidget({super.key,
    required this.notificationController,
    required this.notificationModelNew,
    required this.index});

  @override
  State<NotificationListWidget> createState() => _NotificationListWidgetState();
}

class _NotificationListWidgetState extends State<NotificationListWidget> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.02, vertical: size.width * 0.02),
      child: Column(
        children: [
          InkWell(
              onTap: () async {
                if (widget.notificationModelNew.isread == "2") {
                  await widget.notificationController
                      .readNotificationController(
                      notificationId: widget.notificationModelNew.id,
                      isRead: "1");
                }
                final notificationType = widget.notificationModelNew.notiType;
                switch (notificationType) {
                  case NotificationType.requestArtist:
                    Get.to(() =>
                        BusinessProfileScreen(
                          isNotificationscreen:
                          widget.notificationModelNew.isread == "2"
                              ? true
                              : false,
                          bId: widget.notificationModelNew.custid ?? "",
                          // Use null-safety
                          fromPost: false,
                        ));

                  case NotificationType.requestStudio:
                    Get.to(() =>
                        BusinessProfileScreen(
                          isNotificationscreen:
                          widget.notificationModelNew.isread == "2"
                              ? true
                              : false,

                          bId: widget.notificationModelNew.custid ?? "",
                          // Use null-safety
                          fromPost: false,
                        ));
                    break;
                  default:
                  // Navigate based on notification data
                    if (widget.notificationModelNew.pid != "0") {
                      Get.to(PostDetails(
                        postId: widget.notificationModelNew.pid!,
                        isArtist: false,
                        isNotification: true,
                        isNotificationscreen: true,
                      ));
                    } else {
                      Get.to(() =>
                          BusinessProfileScreen(
                            bId: widget.notificationModelNew.custid ??
                                "", // Use null-safety
                            fromPost: false,
                            isNotificationscreen:
                            widget.notificationModelNew.isread == "2"
                                ? true
                                : false,
                          ));
                    }
                }
              },
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widget.notificationModelNew.notiType ==
                        NotificationType.giftnotification ||
                        widget.notificationModelNew.notiType ==
                            NotificationType.infonotification
                        ? CircleAvatar(
                      radius: size.width * 0.06,
                      backgroundColor: bodyBg,
                      child: Padding(
                        padding: const EdgeInsets.all(8), // Border radius
                        child: ClipOval(
                            child: SvgPicture.asset(
                              widget.notificationModelNew.notiType ==
                                  NotificationType.giftnotification
                                  ? AppAssets.giftIcon
                                  : AppAssets
                                  .notificationInfoIcon, // Replace with your asset path
                            )),
                      ),
                    )
                        : buildOwnerProfileImage(
                        size: size,
                        width: size.width * 0.12,
                        ownerImage:
                        widget.notificationModelNew.custprofileImage == null ||
                            widget.notificationModelNew.custprofileImage == ""
                            ? ""
                            : widget.notificationModelNew.custprofileImage!),
                    SizedBox(width: size.width * 0.02),
                    Expanded(
                        child: buildNotificationMsg(
                            notificationindex: widget.notificationModelNew,
                            context: context,
                            type: widget.notificationModelNew.notiType,
                            index: widget.index)),
                  ])),
          const Divider(),
        ],
      ),
    );
  }

  buildNotificationMsg({String? type,
    required int index,
    required BuildContext context,
    required NotificationModelNew notificationindex}) {
    // String msg = "";
    //
    // if (type == NotificationType.postMention) {
    //   msg = "notification.mentioned_in_post"; //mentioned you in post
    // } else if (type == NotificationType.giftnotification) {
    //   msg = "GiftMsg"; //mentioned you in post
    // } else if (type == NotificationType.infonotification) {
    //   msg = "Information"; //mentioned you in post
    // } else if (type == NotificationType.newPost) {
    //   msg = "notification.new_post"; //Upload a new photo
    // } else if (type == NotificationType.requestArtist ||
    //     type == NotificationType.requestStudio) {
    //   if (notificationController.notificationList[index].status! == "1") {
    //     msg = "notification.you_accepted_request"; //you approved request
    //   } else if (notificationController.notificationList[index].status! == "2") {
    //     msg = "notification.you_declined_request";
    //   } else if (notificationController.notificationList[index].status! == "0") {
    //     msg = "notification.sent_request"; //Tag you as a tattoo artist
    //   }
    // }
    //
    // if (type == NotificationType.sentRequestArtist ||
    //     type == NotificationType.sentRequestStudio) {
    //   if (notificationController.notificationList[index].status! == "1") {
    //     msg = "notification.accepted_request";
    //   } else if (notificationController.notificationList[index].status! == "2") {
    //     msg = "notification.declined_request"; //Declined request
    //   } else if (notificationController.notificationList[index].status! == "0") {
    //     msg = "notification.received_request"; //A new request has been received
    //   }
    // }

    // print(msg);

    return (type == NotificationType.newPost ||
        type == NotificationType.postMention)
        ? Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: MediaQuery
              .of(context)
              .size
              .width * 0.55,
          child: RichText(
            textAlign: TextAlign.right,
            text: TextSpan(
              children: [
                buildNotificationNameTextSpan(index, context),
                TextSpan(
                  text:
                  "${type == NotificationType.newPost
                      ? " הוסיפה תמונה חדשה "
                      : " תייגו אותך בתמונה "}. ",
                  style:
                  Theme
                      .of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(
                    color: titleTextWhiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                buildNotificationDateTextSpan(index, context),
                if (notificationindex.isread.toString() == "2")
                  buildDottedTextSpan(context),
              ],
            ),
          ),
        ),
        Container(
          height: MediaQuery
              .of(context)
              .size
              .width * 0.13,
          width: MediaQuery
              .of(context)
              .size
              .width * 0.13,
          decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              alignment: Alignment.center,
              imageUrl: notificationindex.postimages == ""
                  ? ""
                  : notificationindex.postimages!,
              fit: BoxFit.cover,
              progressIndicatorBuilder:
                  (context, url, downloadProgress) =>
                  SizedBox(
                    height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.05,
                    width: MediaQuery
                        .of(context)
                        .size
                        .height * 0.05,
                    child: Center(
                        child: CircularProgressIndicator(
                            value: downloadProgress.progress)),
                  ),
              errorWidget: (context, url, error) =>
                  Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(AppAssets.imagePlaceHolder),
                            fit: BoxFit.cover)),
                  ),
            ),
          ),
        ),
      ],
    )
        : (type == NotificationType.requestArtist ||
        type == NotificationType.requestStudio)
        ? Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: widget.notificationController.notificationList[index]
              .status ==
              "0"
              ? MediaQuery
              .of(context)
              .size
              .width * 0.45
              : MediaQuery
              .of(context)
              .size
              .width * 0.65,
          child: RichText(
            textAlign: TextAlign.right,
            text: TextSpan(
              children: [
                buildNotificationNameTextSpan(index, context),
                TextSpan(
                  text: widget.notificationController
                      .notificationList[index].status ==
                      "0"
                      ? "${" הוסיפו אותך לסטודיו "}. "
                      : "${"  אישר את בקשת ההצטרפות לסטודיו "}. ",
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(
                    color: titleTextWhiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                buildNotificationDateTextSpan(index, context),
                if (notificationindex.isread.toString() == "2")
                  buildDottedTextSpan(context),
              ],
            ),
          ),
        ),
        if (widget.notificationController.notificationList[index]
            .status ==
            "0")
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () async {
                  bool isConnected =
                  await WebService.checkConnection2();

                  if (!isConnected) {
                    return;
                  } else {
                    if (widget.notificationModelNew.isread == "2") {
                      await widget.notificationController
                          .readNotificationController(
                          isRefreshpage: true,
                          notificationId:
                          widget.notificationModelNew.id,
                          isRead: "1");
                    }
                    widget.notificationController.acceptInvitation(
                        artistId: widget.notificationController
                            .notificationList[index].custid,
                        actionStatus: "1");
                  }
                },
                child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal:
                        MediaQuery
                            .of(context)
                            .size
                            .width * 0.03,
                        vertical: MediaQuery
                            .of(context)
                            .size
                            .height *
                            0.012),
                    decoration: BoxDecoration(
                        gradient: appLinearGradient,
                        borderRadius: BorderRadius.circular(
                            8) // use instead of BorderRadius.all(Radius.circular(20))
                    ),
                    child: Text(
                      "אישור",
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(color: titleTextWhiteColor,fontWeight: FontWeight.w400),
                    )),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () async {
                  bool isConnected =
                  await WebService.checkConnection2();

                  if (!isConnected) {
                    return;
                  } else {
                    if (widget.notificationModelNew.isread == "2") {
                      await widget.notificationController
                          .readNotificationController(
                          notificationId:
                          widget.notificationModelNew.id,
                          isRead: "1",
                          isRefreshpage: true);
                    }
                    widget.notificationController.acceptInvitation(
                        artistId: widget.notificationController
                            .notificationList[index].custid??"",
                        actionStatus: "2");
                  }
                },
                child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal:
                        MediaQuery
                            .of(context)
                            .size
                            .width * 0.03,
                        vertical: MediaQuery
                            .of(context)
                            .size
                            .height *
                            0.013),
                    decoration: BoxDecoration(
                        color: signInButtonColor,
                        borderRadius: BorderRadius.circular(
                            8) // use instead of BorderRadius.all(Radius.circular(20))
                    ),
                    child: SvgPicture.asset(
                      AppAssets.closeIcon,
                      color: titleTextWhiteColor,
                    )),
              ),
            ],
          )
      ],
    )
        : type == NotificationType.giftnotification
        ? SizedBox(
      width: MediaQuery
          .of(context)
          .size
          .width * 0.65,
      child: RichText(
        maxLines: 2,
        textAlign: TextAlign.right,
        text: TextSpan(
          children: [
            buildNotificationNameTextSpan(index, context),
            buildNotificationDateTextSpan(index, context),
            if (notificationindex.isread.toString() == "2")
              buildDottedTextSpan(context),
          ],
        ),
      ),
    )
        : type == NotificationType.infonotification
        ? Row(
      children: [
        SizedBox(
          width: MediaQuery
              .of(context)
              .size
              .width * 0.65,
          child: RichText(
            maxLines: 2,
            textAlign: TextAlign.right,
            text: TextSpan(
              children: [
                buildNotificationNameTextSpan(index, context),
                buildNotificationDateTextSpan(index, context),
                if (notificationindex.isread.toString() ==
                    "2")
                  buildDottedTextSpan(context),
              ],
            ),
          ),
        )
      ],
    )
        : Row(
      children: [
        SizedBox(
          width: MediaQuery
              .of(context)
              .size
              .width * 0.65,
          child: RichText(
            maxLines: 2,
            textAlign: TextAlign.right,
            text: TextSpan(
              children: [
                buildNotificationNameTextSpan(index, context),
                TextSpan(
                  text: widget
                      .notificationController
                      .notificationList[index]
                      .status ==
                      "2"
                      ? tr("notification.declined_request")
                      : "${" אישר את בקשת ההצטרפות לסטודיו "}. ",
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(
                    color: titleTextWhiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                buildNotificationDateTextSpan(index, context),
                if (notificationindex.isread.toString() ==
                    "2")
                  buildDottedTextSpan(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  TextSpan buildDottedTextSpan(BuildContext context) {
    return TextSpan(
      text: ' ● ',
      style: Theme
          .of(context)
          .textTheme
          .titleMedium!
          .copyWith(
        color: linearGradieantColor1,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  //Notification Name
  TextSpan buildNotificationNameTextSpan(int index, BuildContext context) {
    return TextSpan(
      text: widget.notificationController.notificationList[index].custname??"",
      style: Theme
          .of(context)
          .textTheme
          .titleMedium!
          .copyWith(
        color: titleTextWhiteColor,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  TextSpan buildNotificationDateTextSpan(int index, BuildContext context) {
    return TextSpan(
      text:
      " ${formatDate(DateTime.parse(!WebService.checkBlankData(
          widget.notificationController.notificationList[index].notiDate)
          ? widget.notificationController.notificationList[index].notiDate!
          : ""))} ",
      style: Theme
          .of(context)
          .textTheme
          .titleMedium!
          .copyWith(
        color: lightGrayColor,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  String formatDate(DateTime inputDate) {
    DateTime now = DateTime.now();

    // Normalize dates to ignore time (keep only year, month, day)
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime tomorrow = today.subtract(const Duration(days: 1));
    DateTime thridDay = today.subtract(const Duration(days: 2));
    DateTime inputDateOnly =
    DateTime(inputDate.year, inputDate.month, inputDate.day);

    if (inputDateOnly == today) {
      return "היום";
    } else if (inputDateOnly.isAtSameMomentAs(tomorrow)) {
      return "אתמול";
    } else if (inputDateOnly.isAtSameMomentAs(thridDay)) {
      return "3 ימים";
    } else {
      // Show date only if more than 3 days from now
      return DateFormat('dd.MM.y').format(inputDate);
    }
  }
}

