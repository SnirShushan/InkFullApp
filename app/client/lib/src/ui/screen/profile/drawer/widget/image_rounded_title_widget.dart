import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/ui/screen/profile/businessUserProfile.dart';
import 'package:ink/src/ui/screen/profile/drawer/controller/business_profile_menu_controller.dart';
import 'package:ink/src/ui/screen/profile/drawer/followers/follower_model.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/webService.dart';

class ImageRoundedTitleWidget extends StatelessWidget {
  final BusinessProfileMenuController controller;


  const ImageRoundedTitleWidget(
      {super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Obx(() => controller.userfollowes.isEmpty
        ? const SizedBox.shrink()
        : SizedBox(
            height: size.height * 0.17,
            child: ListView.builder(
                itemCount: controller.userfollowes.length > 5 ? 5 : controller.userfollowes.length,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () => Get.to(() => BusinessProfileScreen(
                        bId: controller.userfollowes[index].id.toString(),
                        fromPost: true)),
                    child: Padding(
                      padding: EdgeInsets.only(left: size.width * 0.03),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildRequestForTattoImage(
                              isclickable: false,
                              height: size.width * 0.2,
                              width: size.width * 0.2,
                              url: WebService.resolveProfileImage(
                                  controller.userfollowes[index].profileImage),
                              radius: 50),
                          SizedBox(height: size.height * 0.02),
                          Text(controller.userfollowes[index].name ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: titleTextWhiteColor,
                                    fontWeight: FontWeight.w400,
                                  )),
                        ],
                      ),
                    ),
                  );
                })));
  }
}
