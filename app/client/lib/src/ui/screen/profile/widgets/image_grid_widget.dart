import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/data/model/post_inspiration_model.dart';
import 'package:ink/src/ui/screen/home/imageDetails/post_details.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/webService.dart';

class ImageGrid extends StatelessWidget {
  final bool isArtist;
  final List<PostInspirationModel> myPostList;
  final controller;
  final ScrollController scrollController;

  const ImageGrid(
      {super.key,
      required this.myPostList,
      required this.isArtist,
      required this.scrollController,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      color: bgBlack,
      child: Column(
        children: [
          Expanded(
            child: Obx(() => GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  cacheExtent: 500,
                  itemBuilder: (context, index) {
                    final post = myPostList[index];
                    final imageUrl = WebService.resolveImageUrl(post.imageName);
                    if (imageUrl.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return InkWell(
                      onTap: () => Get.to(() => PostDetails(
                            postId: post.id!,
                            isArtist: isArtist,
                          )),
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            width: size.width *
                                0.29,
                            height: size.height *
                                0.29,
                            imageUrl: imageUrl,
                            fadeInDuration: const Duration(milliseconds: 100),
                            filterQuality: FilterQuality.low,
                            memCacheWidth:
                            (size.width*0.2 * MediaQuery.of(context).devicePixelRatio).round(),

                            placeholder: (context, url) => Container(
                              color: Colors.grey[800], // Placeholder color
                              child: const Center(
                                  child:
                                      CircularProgressIndicator()), // Placeholder color
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              AppAssets.galleryPlaceholder,
                              width: size.width * 0.29,
                              height: size.height * 0.29,
                              fit: BoxFit.cover,
                            ),
                            fit: BoxFit.cover,
                          ),
                          if(post.isMultipleImages=="1")  Positioned(
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
                  },
                  itemCount: myPostList.length,
                )),
          ),
          Obx(() => controller.hasMoreSketchesLoading.value ||
                  controller.hasMoreTattosLoading.value
              ? const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
