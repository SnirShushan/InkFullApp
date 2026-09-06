import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/StartupController.dart';
import 'package:ink/src/controller/notificationController.dart';
import 'package:ink/src/data/model/check_subscription_model.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/ui/screen/notification/models/tattooRequest.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/webService.dart';

import '../../../../utils/common.dart';
import '../../../widgets/upgrade_dialog.dart';
import '../detail_page.dart';

class RequestListTile extends StatelessWidget {
  final String title;
  final String tattooSize;
  final String imgUrl;
  final NotificationController notificationController;
  final TattooRequest tattooRequest;

  RequestListTile(
      {Key? key,
      required this.title,
      required this.tattooSize,
      required this.imgUrl,
      required this.tattooRequest,
      required this.notificationController})
      : super(key: key);

  final StartupController startupController = Get.put(StartupController());
  CheckSubscriptionModel subscriptionModel =
      CheckSubscriptionModel(subscriptionStatus: 0);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Column(
      children: [
        ListTile(
            onTap: () async {
              if (tattooRequest.isread == "2") {
                await notificationController.readMessageController(
                    requestId: tattooRequest.id, isRead: "1");
              }
              if (WebService.isSubscriptionEnable) {
                final isBusiness = await WebService.getIsBusiness();
                if (isBusiness == true) {
                  Network.checkSubscriptionApi(isAddPost: 0).then((value) {
                    if (value != false) {
                      subscriptionModel =
                          CheckSubscriptionModel.fromJson(value);
                      if (subscriptionModel.subscriptionStatus.toString() !=
                          "1") {
                        needSubscriptionDialog(context);
                      } else {
                        Get.to(() => RequestDetailPage(
                              tattooRequest: tattooRequest,
                              controller: notificationController,
                              readRequest:
                                  tattooRequest.isread == "2" ? true : false,
                            ));
                      }
                    }
                  });
                } else {
                  Get.to(() => RequestDetailPage(
                        tattooRequest: tattooRequest,
                        controller: notificationController,
                        readRequest: tattooRequest.isread == "2" ? true : false,
                      ));
                }
              } else {
                Get.to(() => RequestDetailPage(
                      tattooRequest: tattooRequest,
                      controller: notificationController,
                      readRequest: tattooRequest.isread == "2" ? true : false,
                    ));
              }
            },
            contentPadding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
            leading: buildOwnerProfileImage(
                size: size,
                width: size.width * 0.12,
                ownerImage: imgUrl == "" ? "" : imgUrl),
            title: SizedBox(
                height: size.width * 0.12,
                width: size.width * 0.1,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                          height: size.width * 0.12,
                          width: size.width * 0.35,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                        title.length > 10
                                            ? '${title.substring(0, 10)}...'
                                            : title,
                                        maxLines: 1,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                              color: const Color(0xFFDFDCE3),
                                              fontWeight: FontWeight.w700,
                                            )),
                                    if (tattooRequest.isread.toString() == "2")
                                      buildDottedTextSpan(context),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                    formatDate(DateTime.parse(
                                        tattooRequest.dateAdded!)),
                                    // formatDate(
                                    //     DateTime.parse(tattooRequest.dateAdded!)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          color: lightGrayColor,
                                          fontWeight: FontWeight.w500,
                                        )),
                                // buildNotificationMsg(
                                //     type: listController
                                //         .notificationList[index].notiType,
                                //     index: index),
                              ])),
                      Row(
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: signInButtonColor,
                                foregroundColor: titleTextWhiteColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(8), // <-- Radius
                                ),
                              ),
                              onPressed: () async {
                                if (tattooRequest.isread == "2") {
                                  await notificationController
                                      .readMessageController(
                                          requestId: tattooRequest.id,
                                          isRead: "1");
                                }
                                if (WebService.isSubscriptionEnable) {
                                  final isBusiness =
                                      await WebService.getIsBusiness();
                                  if (isBusiness == true) {
                                    Network.checkSubscriptionApi(isAddPost: 0)
                                        .then((value) {
                                      if (value != false) {
                                        subscriptionModel =
                                            CheckSubscriptionModel.fromJson(
                                                value);
                                        if (subscriptionModel.subscriptionStatus
                                                .toString() !=
                                            "1") {
                                          needSubscriptionDialog(context);
                                        } else {
                                          Get.to(() => RequestDetailPage(
                                              controller:
                                                  notificationController,
                                              tattooRequest: tattooRequest,
                                              readRequest:
                                                  tattooRequest.isread == "2"
                                                      ? true
                                                      : false));
                                        }
                                      }
                                    });
                                    // print(startupController.subscriptionModel.subscriptionStatus);
                                  } else {
                                    Get.to(() => RequestDetailPage(
                                        controller: notificationController,
                                        tattooRequest: tattooRequest,
                                        readRequest: tattooRequest.isread == "2"
                                            ? true
                                            : false));
                                  }
                                } else {
                                  Get.to(() => RequestDetailPage(
                                      controller: notificationController,
                                      tattooRequest: tattooRequest,
                                      readRequest: tattooRequest.isread == "2"
                                          ? true
                                          : false));
                                }
                              },
                              child: const Text(
                                "צפייה",
                                style: TextStyle(
                                  color: Color(0xFFDFDCE3),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              )),
                        ],
                      )
                    ]))),
        SizedBox(height: size.height * 0.015)
      ],
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

  Text buildDottedTextSpan(BuildContext context) {
    return Text(
      ' ● ',
      style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: titleTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}
