import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/ui/screen/home/imageDetails/post_details.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/webService.dart';

import '../../../../utils/colors.dart';
import '../controller/inspiration_controller.dart';

class InspiriationGridWidget extends StatelessWidget {
  final InspirationController controller;

  const InspiriationGridWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Obx(
        () => controller.isLoading.value && controller.postsInspiration.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : controller.postsInspiration.isEmpty
                ? Column(
                    children: [
                      SizedBox(height: size.height * 0.04),
                      Container(
                        padding: const EdgeInsets.all(16),
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          color: Color(0xFF211D25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cloud_off_outlined,
                            color: titleTextWhiteColor),
                      ),
                      SizedBox(height: size.height * 0.03),
                      const Text(
                        "מידע לא נמצא",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: titleTextWhiteColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                : InkWell(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child:Obx(()=> GridView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      padding: EdgeInsets.zero,
                      // physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.0),
                      controller: controller.scrollControllerPosts,
                      // padding: EdgeInsets.all(10.0),
                      cacheExtent: 1000,
                      itemCount: controller.postsInspiration.length < (int.parse(WebService.randomPagination) - 5)
                          ? controller.postsInspiration.length + 1
                          : controller.postsInspiration.length,


                      itemBuilder: (context, index) {


                        if (index == controller.postsInspiration.length) {
                          return Obx(() => controller.isPostApiLoading.value
                              ? MediaQuery.removePadding(
                            context: context,
                            removeBottom: true, // 👈 prevent GridView from allocating vertical space
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  left: -size.width * 0.5,
                                  right: 0,
                                  top: size.height * 0.05,

                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ],
                            ),
                          )
                              : const SizedBox.shrink());
                        }
                        var data = controller.postsInspiration[index];
                        return InkWell(
                          onTap: () => Get.to(() =>
                              PostDetails(postId: data.id!, isArtist: false,isInspirationScreen: true)),
                          child: LayoutBuilder(builder: (context, constraints) {
                            return Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    CachedNetworkImage(
                                      width: size.height*0.22,
                                      height: size.height*0.28,
                                      alignment: Alignment.center,
                                      imageUrl:
                                          WebService.resolveImageUrl(data.imageName),
                                      fit: BoxFit.cover,
                                      filterQuality: FilterQuality.low,
                                      memCacheWidth: (size.height *
                                          0.1 *
                                          MediaQuery.of(context)
                                              .devicePixelRatio)
                                          .round(),
                                      placeholderFadeInDuration:
                                      const Duration(seconds: 0),
                                      progressIndicatorBuilder:
                                          (context, url, downloadProgress) =>
                                          SizedBox(
                                            height: size.height * 0.1,
                                            width: size.height * 0.1,
                                            child: Center(
                                                child: CircularProgressIndicator(
                                                    value: downloadProgress.progress)),
                                          ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: AssetImage(
                                                        AppAssets.imagePlaceHolder),
                                                    fit: BoxFit.cover)),
                                          ),
                                    ),
                                   if(data.isMultipleImages.toString() =="1") Positioned(
                                      top: 10,
                                      right: 10,
                                      child: SvgPicture.asset(
                                          AppAssets.multiImageicon,
                                          width: 20,
                                          height:20
                                      ),)
                                  ],
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ))),

        // Column(
        //             children: [
        //               Expanded(
        //                 child: InkWell(
        //                   onTap: () => FocusScope.of(context).unfocus(),
        //                   child: GridView.builder(
        //                     shrinkWrap: true,
        //                     scrollDirection: Axis.vertical,
        //                     // physics: const NeverScrollableScrollPhysics(),
        //                     gridDelegate:
        //                         const SliverGridDelegateWithFixedCrossAxisCount(
        //                             crossAxisCount: 2,
        //                             crossAxisSpacing: 6,
        //                             mainAxisSpacing: 8,
        //                             childAspectRatio: 1.0),
        //                     controller: controller.scrollControllerPosts,
        //                     // padding: EdgeInsets.all(10.0),
        //                     cacheExtent: 1000,
        //                     itemCount: controller.postsInspiration.length,
        //
        //                     itemBuilder: (context, index) {
        //                       var data = controller.postsInspiration[index];
        //                       return InkWell(
        //                         onTap: () => Get.to(() => PostDetails(
        //                             postId: data.id!, isArtist: false)),
        //                         child: LayoutBuilder(
        //                             builder: (context, constraints) {
        //                           return Container(
        //                             decoration: BoxDecoration(
        //                                 borderRadius: BorderRadius.circular(16)),
        //                             child: ClipRRect(
        //                               borderRadius: BorderRadius.circular(16),
        //                               child: CachedNetworkImage(
        //                                 alignment: Alignment.center,
        //                                 imageUrl: data.imageName!,
        //                                 fit: BoxFit.cover,
        //                                 filterQuality: FilterQuality.low,
        //                                 memCacheWidth: (size.height *
        //                                         0.1 *
        //                                         MediaQuery.of(context)
        //                                             .devicePixelRatio)
        //                                     .round(),
        //                                 placeholderFadeInDuration:
        //                                     const Duration(seconds: 0),
        //                                 progressIndicatorBuilder:
        //                                     (context, url, downloadProgress) =>
        //                                         SizedBox(
        //                                   height: size.height * 0.1,
        //                                   width: size.height * 0.1,
        //                                   child: Center(
        //                                       child: CircularProgressIndicator(
        //                                           value:
        //                                               downloadProgress.progress)),
        //                                 ),
        //                                 errorWidget: (context, url, error) =>
        //                                     Container(
        //                                   decoration: BoxDecoration(
        //                                       image: DecorationImage(
        //                                           image: AssetImage(
        //                                               AppAssets.imagePlaceHolder),
        //                                           fit: BoxFit.cover)),
        //                                 ),
        //                               ),
        //                             ),
        //                           );
        //                         }),
        //                       );
        //                     },
        //                   ),
        //                 ),
        //               ),
        //               Obx(() => controller.isPostApiLoading.value
        //                   ? const Padding(
        //                       padding: EdgeInsets.all(10.0),
        //                       child: Center(
        //                         child: CircularProgressIndicator(),
        //                       ),
        //                     )
        //                   : const SizedBox.shrink()),
        //             ],
        //           )
      ),
    );
  }
}
