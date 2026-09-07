import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/ui/screen/home/controller/home_screen_controller.dart';
import 'package:ink/src/ui/widgets/shimmer_effect.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/webService.dart';

import '../imageDetails/post_details.dart';

class TattoStylesWidget extends StatelessWidget {
  final HomeScreenController homeScreenController;

  const TattoStylesWidget({super.key, required this.homeScreenController});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 0.19,
      child: Obx(() => homeScreenController.tattosInStyle!.isEmpty &&
              homeScreenController.isTattoStyleEmpty.value
          ? const SizedBox.shrink()
          : homeScreenController.tattosInStyle!.isEmpty
              ? ListView.builder(
                  itemCount: 6,
                  shrinkWrap: true,
                  padding: EdgeInsets.only(left: size.width * 0.03),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return ShimmerEffect(
                      baseColor: Colors.white10,
                      highlightColor: Colors.white70,
                      child: Container(
                        width: size.width * 0.4,
                        margin: EdgeInsets.only(left: size.width * 0.03),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    );
                  },
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: homeScreenController.tattosInStyle!.length,
                  itemBuilder: (BuildContext context, int index) {
                    var data = homeScreenController.tattosInStyle![index];
                    return InkWell(
                      onTap: () => Get.to(
                          PostDetails(postId: data.id!, isArtist: false)),
                      child: Stack(children: [
                        Container(
                          width: size.width * 0.4,

                          height: size.height * 0.18,
                          padding: EdgeInsets.only(left: size.width * 0.03),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CachedNetworkImage(
                              alignment: Alignment.center,
                              imageUrl: WebService.resolveImageUrl(data.imageName),
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.low,
                              memCacheWidth: (size.width *
                                  0.4 *
                                  MediaQuery.of(context).devicePixelRatio)
                                  .round(),
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) => SizedBox(
                                height: size.height * 0.1,
                                width: size.height * 0.1,
                                child: Center(
                                    child: CircularProgressIndicator(
                                        value: downloadProgress.progress)),
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                  AppAssets.userPlaceHolder,
                                  fit: BoxFit.cover),
                            ),
                          ),
                        ),

                        if (data.isMultipleImages == "1")
                          Positioned(
                          top: 10,
                          right: 10,
                          child: SvgPicture.asset(
                          AppAssets.multiImageicon,
                              width: 20,
                              height:20
                        ),)
                      ],)
                    );
                  })),
    );
  }
}
