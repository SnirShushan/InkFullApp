import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/business_dashboard.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/bussinessdashboard_binding.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard_binding.dart';
import 'package:ink/src/ui/screen/home/controller/home_screen_controller.dart';
import 'package:ink/src/ui/screen/profile/businessUserProfile.dart';
import 'package:ink/src/ui/widgets/build_custom_catched_image.dart';
import 'package:ink/src/ui/widgets/shimmer_effect.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/webService.dart';

class BusinessCardWidget extends StatelessWidget {
  final HomeScreenController homeScreenController;

  const BusinessCardWidget({super.key, required this.homeScreenController});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textheme = Theme.of(context).textTheme;
    return Obx(() => homeScreenController.businessList.isEmpty
        ? SizedBox(
            height: size.height * 0.42,
            child: ListView.builder(
              itemCount: 6,
              shrinkWrap: true,
              padding: EdgeInsets.only(left: size.width * 0.03),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: SizedBox(
                    width: size.width * 0.8,
                    child: Card(
                      elevation: 0,
                      color: cardBgColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: size.height * 0.01),
                            // Shimmer for images
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List<Widget>.generate(
                                  3, // Simulate 3 image placeholders
                                  (int index) => ShimmerEffect(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 3.0, right: 3),
                                      child: Container(
                                        height: 120.0,
                                        width: 120.0,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: size.height * 0.02),
                            // Shimmer for owner profile and text details
                            Row(
                              children: <Widget>[
                                ShimmerEffect(
                                  child: Container(
                                    width: size.width * 0.12,
                                    height: size.width * 0.12,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: 150, // Placeholder for name
                                      height: 18,
                                      color: Colors.grey[300],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          width:
                                              80, // Placeholder for type + address
                                          height: 14,
                                          color: Colors.grey[300],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: size.height * 0.02),
                            // Shimmer for styles
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 2.0,
                              children: List<Widget>.generate(
                                3, // Simulate 3 style button placeholders
                                (int index) => ShimmerEffect(
                                  child: Container(
                                    width: 60 + (index * 10).toDouble(),
                                    // Vary width slightly
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: size.height * 0.01),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        : SizedBox(
            height: Platform.isIOS ? size.height * 0.42 : size.height * 0.45,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: homeScreenController.businessList!.length,
                cacheExtent: 1000,
                itemBuilder: (BuildContext context, int index) {
                  var data = homeScreenController.businessList![index];

                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: SizedBox(
                      width: size.width * 0.82,
                      child: InkWell(
                        onTap: () {
                          final id = data.id?.toString() ?? "";
                          if (id.isEmpty || id == "null") return;
                          Get.to(() => BusinessProfileScreen(
                              bId: id, fromPost: true));
                        },
                        child: Card(
                          elevation: 0,
                          color: cardBgColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: size.height * 0.01),
                                data.businessimg!.isEmpty
                                    ? SizedBox(
                                        height: size.width * 0.34,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 6.0, right: 4),
                                          child: Image.asset(
                                            AppAssets.galleryPlaceholder,
                                          ),
                                        ))
                                    : SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children:
                                              data.businessimg!.map((datas) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 3.0, right: 3),
                                              child: Stack(
                                                children: [
                                                  BuildCachedNetworkImage(
                                                      height: 120.0,
                                                      width: 120.0,
                                                      errorWidget: Image.asset(
                                                          width: 120.0,
                                                          AppAssets
                                                              .userPlaceHolder,
                                                          fit: BoxFit.cover),
                                                      url: datas.imageUrl!,
                                                      radius: 8),
                                                  if (datas.isMultipleImages ==
                                                      "1")
                                                    Positioned(
                                                      top: 10,
                                                      right: 10,
                                                      child: SvgPicture.asset(
                                                          AppAssets
                                                              .multiImageicon,
                                                          width: 20,
                                                          height: 20),
                                                    )
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                SizedBox(height: size.height * 0.02),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        buildOwnerProfileImage(
                                            size: size,
                                            width: size.width * 0.12,
                                            ownerImage: data.profileImage == ""
                                                ? ""
                                                : data.profileImage!),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data.name == ""
                                                  ? ""
                                                  : data.name!.length > 20
                                                      ? '${data.name!.substring(0, 20)}...'
                                                      : data.name!,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: [
                                                SvgPicture.asset(
                                                  AppAssets.homeIcon,
                                                  color: dividerGray,
                                                ),
                                                const SizedBox(
                                                  width: 4,
                                                ),
                                                Text(
                                                  data.businessType == "1"
                                                      ? 'סטודיו'
                                                      : "אמן",
                                                  style: textheme.titleSmall!
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: dividerGray),
                                                ),
                                                const Text(
                                                  '  |  ',
                                                  style: TextStyle(
                                                      color: dividerGray),
                                                ),
                                                SvgPicture.asset(
                                                  width: 12,
                                                  height: 16,
                                                  AppAssets.locationIcon,
                                                  color: dividerGray,
                                                ),
                                                const SizedBox(
                                                  width: 4,
                                                ),
                                                Text(
                                                  data.address!.length > 13
                                                      ? '${data.address!.substring(0, 13)}...'
                                                      : data.address!,
                                                  style: textheme.titleSmall!
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: dividerGray),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                SizedBox(height: size.height * 0.02),
                                if (data.stylesHe != null)
                                  Wrap(
                                    spacing: 8.0,
                                    runSpacing: 2.0,
                                    alignment: WrapAlignment.start,
                                    children: data.stylesHe!
                                        .where((style) => style
                                            .isNotEmpty) // filter out empty strings
                                        .take(5)
                                        .map((style) {
                                      return style == ""
                                          ? const SizedBox()
                                          : ElevatedButton(
                                              onPressed: () async {
                                                final isBusiness =
                                                    await WebService
                                                        .getIsBusiness();
                                                AppUser user = await WebService
                                                    .getCurrentUser();
                                                WebService.selectstylelist = [];
                                                user.stylesList
                                                    ?.forEach((stylesList) {
                                                  if (stylesList.name ==
                                                      style) {
                                                    WebService.selectstylelist
                                                        .add(stylesList);
                                                  }
                                                });
                                                print("stylesList $isBusiness");
                                                if (isBusiness) {
                                                  Get.offAll(
                                                      BusinessDashBoard(
                                                          initialIndex: 1),
                                                      binding:
                                                          BusinessDashBoardBinding());
                                                } else {
                                                  Get.offAll(
                                                      const DashBoard(
                                                          initialIndex: 1),
                                                      binding:
                                                          DashBoardBinding());
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 4,
                                                        vertical: 3),
                                                backgroundColor: styleBgColor,
                                                foregroundColor:
                                                    titleTextWhiteColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4.0),
                                                ),
                                              ),
                                              child: Text(
                                                style,
                                                textAlign: TextAlign.center,
                                                style: textheme.titleSmall!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color:
                                                            titleTextWhiteColor),
                                              ),
                                            );
                                    }).toList(),
                                  ),
                                SizedBox(height: size.height * 0.01),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                })));
  }
}
