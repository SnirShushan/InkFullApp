import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/business_dashboard.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/bussinessdashboard_binding.dart';
import 'package:ink/src/ui/screen/home/controller/home_screen_controller.dart';
import 'package:ink/src/ui/screen/profile/businessUserProfile.dart';
import 'package:ink/src/ui/widgets/shimmer_effect.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/webService.dart';

class NewUserWidget extends StatelessWidget {
  final HomeScreenController homeScreenController;

  const NewUserWidget({super.key, required this.homeScreenController});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Obx(() => homeScreenController.newUserLists.isEmpty
        ?SizedBox(
      height: size.height * 0.17,
          child: ListView.builder(
                itemCount: 6,
                shrinkWrap: true,
                padding: EdgeInsets.only(left: size.width * 0.03),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
          return ShimmerEffect(
            baseColor: Colors.white10,
            highlightColor: Colors.white70,
            child: Padding(
              padding: EdgeInsets.only(left: size.width * 0.03),
              child: Column(
                children: [
                  Container(
                    width: size.width * 0.2,
                    height: size.width*0.2,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Container(
                    width:  size.width * 0.13, // Placeholder for name
                    height: 18,
                    color: Colors.grey[300],
                  ),


                ],
              ),
            ),
          );
                },
              ),
        )
        : SizedBox(
            height: size.height * 0.17,
            child: Obx(() => ListView.builder(
                controller: homeScreenController.userscrollControllerRequest,
                itemCount: homeScreenController.newUserLists.length,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemBuilder: (BuildContext context, int index) {
                  var data = homeScreenController.newUserLists[index];

                  if (index < homeScreenController.newUserLists.length) {
                    return InkWell(
                      onTap: () async {
                        AppUser user = await WebService.getCurrentUser();
                        if (user.profile!.id.toString() == data.id!) {
                          Get.offAll(
                              () => BusinessDashBoard(
                                    initialIndex: 4,
                                  ),
                              binding: BusinessDashBoardBinding());
                        } else {
                          Get.to(() => BusinessProfileScreen(
                              bId: data.id!, fromPost: true));
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.only(left: size.width * 0.03),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildOwnerProfileImage(
                                size: size,
                                width: size.width * 0.2,
                                ownerImage: data.profileImage == ""
                                    ? ""
                                    : data.profileImage.toString()),
                            SizedBox(height: size.height * 0.02),
                            Text(
                                data.name == ""
                                    ? ""
                                    : data.name!.length > 17
                                        ? '${data.name!.substring(0, 17)}...'
                                        : data.name!,
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
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Obx(() => Center(
                          child: homeScreenController.hasMoreUsers.value
                              ? const CircularProgressIndicator()
                              : const SizedBox())),
                    );
                  }
                }))));
  }
}
