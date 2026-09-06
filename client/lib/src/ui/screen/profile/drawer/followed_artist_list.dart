import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/ui/screen/profile/drawer/widget/no_following_widget.dart';
import 'package:ink/src/ui/widgets/bottomenu/business_dashboard_bottomenu.dart';
import 'package:ink/src/ui/widgets/bottomenu/dashboard_bottomenu.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/utils.dart';

import '../../../../utils/colors.dart';
import '../../../widgets/appbar_back_widget.dart';
import 'followers/followed_users_controller.dart';
import 'followers/follower_model.dart';

class FollowedArtistList extends StatelessWidget {
  final String currentUserType;

  FollowedArtistList({Key? key, required this.currentUserType})
      : super(key: key);

  final FollowedUsersController followersController = Get.put(FollowedUsersController());
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return RefreshIndicator(
      onRefresh: () => followersController.getFollowers(),
      child: Scaffold(
          backgroundColor: bgBlack,
          bottomNavigationBar: currentUserType == "2"
              ? BusinessDashboardBottomBar(
                  currentIndex: 4,
                )
              : DashboardBottomBar(currentIndex: 3),
          appBar: const AppBarBackButtonWidget(
              title: 'מקעקעים במעקב',
              titleColor: titleTextWhiteColor,
              iconColor: titleTextWhiteColor),
          body: Obx(() => Column(children: [
                // const SizedBox(height: 50),
                // Row(children: [
                //   const SizedBox(width: 8),
                //   IconButton(
                //       icon: SvgPicture.asset(AppAssets.backarrowIcon,
                //           height: 20, color: titleTextWhiteColor),
                //       onPressed: () => Navigator.pop(context)),
                //   const SizedBox(width: 8),
                //   const Text('מקעקעים במעקב',
                //       style: TextStyle(
                //           color: titleTextWhiteColor,
                //           fontSize: 20,
                //           fontWeight: FontWeight.w700))
                // ]),
                followersController.isLoading.value
                    ? Utils.showProgress()
                    : followersController.followersList.isEmpty
                        ? NoFollowingWidget(
                            size: size, currentUserType: currentUserType)
                        : Expanded(
                            child: ListView.builder(
                                itemCount:
                                    followersController.followersList.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemBuilder: (BuildContext context, int index) {
                                  final FollowerModel follower =
                                      followersController.followersList[index];

                                  return Padding(
                                    // padding: EdgeInsets.all(size.height * 0.01),
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        size.height * 0.02,
                                        size.height * 0.01,
                                        1,
                                        size.height * 0.01),
                                    child: ListTile(
                                      dense: true,
                                      onTap: () async {},
                                      // leading: const CircleAvatar(
                                      //   radius: 26,
                                      //   backgroundImage: AssetImage(
                                      //       'assets/images/userplaceholder.png'), // Replace with actual image asset
                                      // ),
                                      leading: buildOwnerProfileImage(
                                          size: size,
                                          width: size.width * 0.12,
                                          ownerImage:
                                              follower.profileImage == ""
                                                  ? ""
                                                  : follower.profileImage!),
                                      title: Text(
                                        follower.name.toString(),
                                        style: const TextStyle(
                                            color: titleTextWhiteColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      subtitle: Text(
                                        follower.cityname.toString(),
                                        style: const TextStyle(
                                            color: lightGrayColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      trailing: ElevatedButton(
                                        onPressed: () async {
                                          await followersController
                                              .unFollowArtists(
                                                  bid: follower.id.toString(),
                                                  likeStatus: "2");
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              signInButtonColor, // Button background color
                                          foregroundColor:
                                              titleTextWhiteColor, // Button text color
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical:
                                                  4), // Adjust horizontal padding to fit text in one line
                                        ),
                                        child: const Text(
                                          'ביטול מעקב',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          )
              ]))),
    );
  }
}
