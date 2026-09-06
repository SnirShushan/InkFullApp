import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/ui/screen/inspiration/controller/random_pagination.dart';
import 'package:ink/src/ui/widgets/button/custom_gradient_btn_widget.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/webService.dart';

import '../controller/inspiration_controller.dart';

class FilterInspirationWidget extends StatelessWidget {
  final InspirationController controller;

  const FilterInspirationWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: signInButtonColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16))),
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //close
            InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height * 0.03,
                        horizontal: MediaQuery.of(context).size.width * 0.4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Container(
                        margin: const EdgeInsetsDirectional.only(
                            start: 1.0, end: 1.0),
                        height: MediaQuery.of(context).size.height * 0.005,
                        width: MediaQuery.of(context).size.width * 0.2,
                        decoration: BoxDecoration(
                          color: kDivider,
                          borderRadius: BorderRadius.circular(
                              10.0), // Adjust the radius as needed
                        ),
                      ),
                    ))),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(AppAssets.filterIcon),
                    const SizedBox(width: 10),
                    const Text('סינון',
                        style: TextStyle(
                            color: titleTextWhiteColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                InkWell(
                  onTap: () {
                    Get.back();
                    controller.resetData();
                  },
                  child: const Text('איפוס',
                      style: TextStyle(
                          color: titleTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w400)),
                )
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            const Text("סגנון",
                style: TextStyle(
                    color: dividerGray,
                    fontSize: 16,
                    fontWeight: FontWeight.w400)),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(() => Row(
                    children: controller.styleList.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () => controller.selectStyle(category),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Stack(
                                    children: [
                                      ColoredBox(
                                          color: kWhite,
                                          child: buildCachedNetworkImage(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.25,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.25,
                                              url: WebService.resolveImageUrl(
                                                  category.imageName,
                                                  base: WebService.styleImgUrl),
                                              radius: 8)),
                                      if (controller.selectedStyles!
                                          .contains(category))
                                        ColoredBox(
                                            color: Colors.black45,
                                            child: SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.25,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.25,
                                            )),
                                      if (controller.selectedStyles!
                                          .contains(category))
                                        Positioned(
                                            top: 8,
                                            right: 3,
                                            child: SizedBox(
                                                height: 20.0,
                                                width: 20.0,
                                                child: SvgPicture.asset(
                                                    AppAssets.icSelected))),
                                    ],
                                  )),
                            ),
                            // CachedNetworkImage(
                            //       imageUrl: WebService.styleImgUrl +category.imageName!,
                            //       height: MediaQuery.of(context).size.width * 0.2,
                            //       width: MediaQuery.of(context).size.width * 0.2,
                            //       fit: BoxFit.cover)),
                            const SizedBox(height: 5),
                            Text(
                              category.name!,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  )),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),

            CustomGradientButtonWidget(
              title: 'סינון',
              onTap: () {
                controller.pagination = RandomPagination(
                    totalPosts: int.parse(WebService.randomPagination ?? "0"),
                    limit: 10);
                controller.pagination!.reset();
                controller.postsInspiration!.clear();
                controller.startInspiration = 0.obs;
                controller.getInspirationController();
                Navigator.of(context).pop();
              },
            ),

             SizedBox(
              height:Platform.isAndroid? MediaQuery.of(context).size.height * 0.07:MediaQuery.of(context).size.height * 0.03,
            ),
          ],
        ),
      ),
    );
  }
}
