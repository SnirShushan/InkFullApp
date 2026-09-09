import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/business_dashboard.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/bussinessdashboard_binding.dart';
import 'package:ink/src/ui/screen/bussiness_profiles/model_business_user.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard_binding.dart';
import 'package:ink/src/ui/screen/profile/businessUserProfile.dart';
import 'package:ink/src/ui/widgets/build_custom_catched_image.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/webService.dart';

class TattooArtistCard extends StatelessWidget {
  final BusinessUserListModel businessUserListModel;

  TattooArtistCard({super.key, required this.businessUserListModel});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return InkWell(
      onTap: () {
        final id = businessUserListModel.id?.toString() ?? "";
        if (id.isEmpty || id == "null") return;
        Get.to(() => BusinessProfileScreen(bId: id, fromPost: false));
      },
      child: Card(
        color: cardBgColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.01),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child:  businessUserListModel.businessImg.toString()=="[]"? Image.asset(
                    height: 120.0,
                    width: 120.0,
                    AppAssets.galleryPlaceholder,
                    fit: BoxFit.cover):Row(
                  children:businessUserListModel.businessImg!.map((image) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 3.0, right: 3),
                      child: Stack(
                        children: [
                          BuildCachedNetworkImage(
                              height: 120.0,
                              width: 120.0,
                              url: image.imageUrl ?? WebService.tempImageUrl,
                              radius: 8),

                         if(image.isMultipleImages=="1")Positioned(
                            top: 10,
                            right: 10,
                            child: SvgPicture.asset(
                              AppAssets.multiImageicon,
                              width: 20,
                              height:20
                            ),)
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Column(
                children: [
                  Row(
                    children: [
                      // const CircleAvatar(radius: 26),
                      businessUserListModel.profileImage==""?ClipRRect(
                        borderRadius: BorderRadius.circular(26),

                        child: Image.asset(
                            height: size.width * 0.13,
                            width: size.width * 0.13,
                            AppAssets.userPlaceHolder,
                            fit: BoxFit.cover),
                      ): buildCachedNetworkImage(
                          height: size.width * 0.13,
                          width: size.width * 0.13,
                          errorWidget: Image.asset(AppAssets.userPlaceHolder,
                              fit: BoxFit.cover),
                          url: WebService.resolveProfileImage(
                              businessUserListModel.profileImage),
                          radius: 26),
                      const SizedBox(width: 5),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                businessUserListModel.name!.length > 27
                                    ? '${businessUserListModel.name!.substring(0, 27)}...'
                                    : businessUserListModel.name!,
                                maxLines: 1,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18)
                            ),
                            const SizedBox(height: 5),
                            Row(children: [
                              SvgPicture.asset(
                                AppAssets.homeIcon,
                                // size: 16
                              ),
                              const SizedBox(width: 4),
                              Text(
                                  businessUserListModel.businessType == "1"
                                      ? 'סטודיו'
                                      : "אמן",
                                  style: const TextStyle(
                                      color: titleTextWhiteColor)),
                              const Text('  |  ',
                                  style: TextStyle(color: titleTextWhiteColor)),
                              SvgPicture.asset(
                                  width: 12,
                                  height: 16,
                                  AppAssets.locationIcon,
                                  color: titleTextWhiteColor),
                              const SizedBox(width: 4),
                              Text(
                                  businessUserListModel.address!.length > 20
                                      ? '${businessUserListModel.address!.substring(0, 20)}...'
                                      : businessUserListModel.address!,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      color: titleTextWhiteColor)),
                            ])
                          ])
                    ],
                  )
                ],
              ),
              const SizedBox(height: 8),
              //styles
              if (businessUserListModel.stylesHe != null)
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    // Aligns items to the center horizontally
                    child: Row(
                        children: businessUserListModel.stylesHe!.map((style) {
                          // children: UserController().style_list!.map((style) {
                          return Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: SizedBox(
                                height: 24,
                                child: ElevatedButton(
                                    onPressed: () async {
                                      final isBusiness =
                                      await WebService.getIsBusiness();
                                      AppUser user =
                                      await WebService.getCurrentUser();
                                      WebService.selectstylelist = [];
                                      user.stylesList?.forEach((stylesList) {
                                        if (stylesList.name == style) {
                                          print("stylesList $stylesList");
                                          WebService.selectstylelist
                                              .add(stylesList);
                                        }
                                      });
                                      print("stylesList $isBusiness");
                                      if (isBusiness) {
                                        Get.offAll(
                                            BusinessDashBoard(initialIndex: 1),
                                            binding: BusinessDashBoardBinding());
                                      } else {
                                        Get.offAll(const DashBoard(initialIndex: 1),
                                            binding: DashBoardBinding());
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: styleBgColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(4.0))),
                                    child: Text(style.toString(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: titleTextWhiteColor)))),
                          );
                        }).toList())),
              SizedBox(height: size.height * 0.01),
              // Wrap(
              //   spacing: 8.0,
              //   children: businessUserListModel.styles.map((style) {
              //     return Container(
              //       height: 24,
              //       child: Chip(
              //         label: Text(
              //           style,
              //           textAlign: TextAlign.center,
              //         ),
              //         backgroundColor: styleBgColor,
              //         labelStyle: TextStyle(color: titleTextWhiteColor),
              //         shape: RoundedRectangleBorder(
              //           side: BorderSide.none,
              //           borderRadius: BorderRadius.circular(
              //               4.0), // Adjust the radius as needed
              //         ),
              //       ),
              //     );
              //   }).toList(),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}