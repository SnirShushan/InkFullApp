import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/userController.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/business_dashboard.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/bussinessdashboard_binding.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard_binding.dart';
import 'package:ink/src/ui/screen/home/controller/home_screen_controller.dart';
import 'package:ink/src/ui/screen/home/imageDetails/post_details.dart';
import 'package:ink/src/ui/widgets/button/custom_gradient_btn_widget.dart';
import 'package:ink/src/ui/widgets/shimmer_effect.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/webService.dart';

class HomePostGridWidget extends StatefulWidget {
  final HomeScreenController homeScreenController;

  const HomePostGridWidget({super.key, required this.homeScreenController});

  @override
  State<HomePostGridWidget> createState() => _HomePostGridWidgetState();
}

class _HomePostGridWidgetState extends State<HomePostGridWidget> {
  final UserController _userController = Get.find();

  @override
  void initState() {
    // TODO: implement initState
    _userController.initUser();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Obx(() {
      final stylePosts = widget.homeScreenController.stylePosts;

      // Handle empty states
      if (stylePosts.isEmpty &&
          widget.homeScreenController.isHasMoreEmpty.value) {
        return const SizedBox.shrink();
      }

      if (stylePosts.isEmpty) {
        // 🔸 shimmer while loading
        return GridView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 6, mainAxisSpacing: 8),
          itemCount: 6,
          itemBuilder: (_, __) => ShimmerEffect(
            baseColor: Colors.white10,
            highlightColor: Colors.white70,
            child: Container(
              width: size.width * 0.35,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[300],
              ),
            ),
          ),
        );
      }

      // 🔹 Build multiple style sections
      return Column(
        children: stylePosts.entries.map((entry) {
          final styleKey = entry.key;
          final posts = entry.value;

          return posts.length == 0
              ? const SizedBox.shrink()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildTitleBold(
                        context: context, title: posts[0].styles ?? ""),
                    // 🔸 Grid for each style
                    GridView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: posts.length > 6 ? 6 : posts.length,
                      itemBuilder: (context, index) {
                        final data = posts[index];
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            InkWell(
                              onTap: () => Get.to(() => PostDetails(
                                  postId: data.id ?? "", isArtist: false)),
                              child: Container(
                                width: size.width * 0.44,
                                height:size.height*0.22,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: CachedNetworkImage(
                                    imageUrl: WebService.resolveImageUrl(
                                        data.imageName),
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.low,
                                    memCacheWidth: (size.width *
                                            0.35 *
                                            MediaQuery.of(context).devicePixelRatio)
                                        .round(),
                                    progressIndicatorBuilder:
                                        (context, url, downloadProgress) => Center(
                                      child: CircularProgressIndicator(
                                          value: downloadProgress.progress),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      decoration: const BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                              "assets/images/placeholder.png"),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if(posts[index].isMultipleImages=="1")Positioned(
                              top: 10,
                              right: 10,
                              child: SvgPicture.asset(
                                AppAssets.multiImageicon,
                                  width: 20,
                                  height:20
                              ),)
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    CustomGradientButtonWidget(
                      title: tr("home_screen.geo_style_tatto_btn"),
                      onTap: () async {
                        try {
                          // Guard: empty list
                          if (_userController.style_list.isEmpty) return;

                          final styleSlug = styleKey.toString().trim().toLowerCase();

                          final found = _userController.style_list.firstWhereOrNull(
                                (s) => s.slug?.toString().trim().toLowerCase() == styleSlug,
                          );

                          if (found == null) return;

                          // Set state once
                          WebService.selectstylelist = [found];
                          WebService.tempHomeselectstylelist = true;

                          final isBusiness = await WebService.getIsBusiness() ?? false;

                          if (isBusiness) {
                            Get.offAll(
                                  () => BusinessDashBoard(initialIndex: 1),
                              binding: BusinessDashBoardBinding(),
                            );
                          } else {
                            Get.offAll(
                                  () => const DashBoard(initialIndex: 1),
                              binding: DashBoardBinding(),
                            );
                          }
                        } catch (e, st) {
                          debugPrint("Style tap error: $e");
                          debugPrintStack(stackTrace: st);
                        }
                      },

                      // onTap: () async {
                      //
                      //   WebService.selectstylelist = [];
                      //   StylesList? found;
                      //   for (final s in _userController.style_list) {
                      //     if (s.slug.toString().trim().toLowerCase() == styleKey.toString().trim().toLowerCase()) {
                      //       found = s;
                      //       break;
                      //     }
                      //   }
                      //   if (found != null) {
                      //     WebService.selectstylelist = [found];
                      //     WebService.tempHomeselectstylelist = true;
                      //     final isBusiness = await WebService.getIsBusiness();
                      //     if (isBusiness) {
                      //       Get.offAll(BusinessDashBoard(initialIndex: 1),
                      //           binding: BusinessDashBoardBinding());
                      //     } else {
                      //       Get.offAll(const DashBoard(initialIndex: 1),
                      //           binding: DashBoardBinding());
                      //     }
                      //   }
                      // },
                    ),
                    // 🔸 Button

                    const SizedBox(height: 24),
                  ],
                );
        }).toList(),
      );
    });
  }

  Padding buildTitleBold(
      {required BuildContext context, required String title}) {
    var size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
      child: Text(
        tr(title),
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontSize: 20,
            color: titleTextWhiteColor,
            fontWeight: FontWeight.w700),
      ),
    );
  }
}
