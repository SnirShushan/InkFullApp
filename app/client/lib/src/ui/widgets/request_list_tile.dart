import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/StartupController.dart';
import 'package:ink/src/ui/screen/notification/models/tattooRequest.dart';
import 'package:ink/src/utils/webService.dart';

import '../../utils/common.dart';
import '../screen/notification/detail_page.dart';

class RequestListTile extends StatelessWidget {
  final String title;
  final String tattooSize;
  final String imgUrl;
  final TattooRequest tattooRequest;

  RequestListTile(
      {Key? key,
      required this.title,
      required this.tattooSize,
      required this.imgUrl,
      required this.tattooRequest})
      : super(key: key);

  final StartupController startupController = Get.put(StartupController());

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ListTile(
          onTap: () async {
            if(WebService.isSubscriptionEnable){
            final isBusiness = await WebService.getIsBusiness();
            if (isBusiness == true) {
              // print(startupController.subscriptionModel.subscriptionStatus);
              if (startupController.subscriptionModel.subscriptionStatus.toString() != "1") {
                needSubscriptionDialog(context);
              } else {
                Get.to(() => RequestDetailPage(tattooRequest: tattooRequest));
              }
            } else {
              Get.to(() => RequestDetailPage(tattooRequest: tattooRequest));
            }
          }else{
              Get.to(() => RequestDetailPage(tattooRequest: tattooRequest));
      }},
          contentPadding: EdgeInsets.symmetric(
              horizontal: Get.size.width * 0.02,
              vertical: Get.size.width * 0.02),
          leading: buildCachedNetworkImage(
              height: Get.size.width * 0.12,
              width: Get.size.width * 0.12,
              url: imgUrl,
              radius: 50),
          title: SizedBox(
              height: Get.size.width * 0.12,
              width: Get.size.width * 0.1,
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: Get.size.width * 0.12,
                        width: Get.width * 0.35,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(fontWeight: FontWeight.bold)),
                              // buildNotificationMsg(
                              //     type: listController
                              //         .notificationList[index].notiType,
                              //     index: index),
                            ])),
                    const VerticalDivider(thickness: 2),
                    SizedBox(
                        height: Get.size.width * 0.12,
                        width: Get.width * 0.37,
                        child: Center(child: Text(tattooSize)))
                  ]))),
      const Divider()
    ]);
  }
}
