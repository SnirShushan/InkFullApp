import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/myPostController.dart';
import 'package:ink/src/data/model/post_inspiration_model.dart';
import 'package:ink/src/ui/screen/home/imageDetails/post_details.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/webService.dart';

class OwnImageGrid extends StatelessWidget {
  final bool isArtist;
  final List<PostInspirationModel> myPostList;
  final MyPostsController controller;

  const OwnImageGrid(
      {super.key,
      required this.myPostList,
      required this.isArtist,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return ColoredBox(
        color: bgBlack,
        child: Column(
          children: [
            Expanded(
              child: Obx(() => GridView.builder(
                    shrinkWrap: true,
                    controller: controller.scrollControllerMyPosts,
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                    ),
                    cacheExtent: 500,
                    itemBuilder: (context, index) {
                      var data = myPostList[index];
                      return InkWell(
                        onTap: () {
                          WebService.shouldRefresh = true;
                          Get.to(() => PostDetails(
                                postId: data.id!,
                                isArtist: isArtist,
                              ));
                        },
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              width: size.width * 0.29,
                              height: size.width * 0.29,
                              imageUrl: WebService.resolveImageUrl(data.imageName),
                              fadeInDuration: const Duration(milliseconds: 100),
                              filterQuality: FilterQuality.low,
                              memCacheWidth: (size.width *
                                      0.2 *
                                      MediaQuery.of(context).devicePixelRatio)
                                  .round(),
                              placeholder: (context, url) => Container(
                                color: Colors.grey[800],
                                // Placeholder color
                                child: const Center(
                                    child:
                                        CircularProgressIndicator()), // Placeholder color
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              fit: BoxFit.cover,
                            ),
                            if (data.isMultipleImages == "1")
                              Positioned(
                                top: 10,
                                right: 10,
                                child: SvgPicture.asset(
                                    AppAssets.multiImageicon,
                                    width: 20,
                                    height: 20),
                              )
                          ],
                        ),
                      );
                    },
                    itemCount: myPostList
                        .length, // Adjust this to the number of items you want
                  )),
            ),
            Obx(() => controller.hasMorePostsLoading.value
                ? const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : const SizedBox.shrink()),
          ],
        ));
  }
}
