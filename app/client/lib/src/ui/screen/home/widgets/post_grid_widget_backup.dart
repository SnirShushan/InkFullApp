// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/ui/screen/business_user/dashboard/business_dashboard.dart';
// import 'package:ink/src/ui/screen/business_user/dashboard/bussinessdashboard_binding.dart';
// import 'package:ink/src/ui/screen/dashboard/dashboard.dart';
// import 'package:ink/src/ui/screen/dashboard/dashboard_binding.dart';
// import 'package:ink/src/ui/screen/home/controller/home_screen_controller.dart';
// import 'package:ink/src/ui/screen/home/imageDetails/post_details.dart';
// import 'package:ink/src/ui/widgets/shimmer_effect.dart';
// import 'package:ink/src/utils/colors.dart';
// import 'package:ink/src/utils/webService.dart';
//
// class PostGridWidget extends StatelessWidget {
//   final HomeScreenController homeScreenController;
//
//   const PostGridWidget({super.key, required this.homeScreenController});
//
//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     return Obx(() => Column(
//       children: [
//         homeScreenController.posts.isEmpty &&
//             homeScreenController.isHasMoreEmpty.value
//             ? SizedBox.shrink()
//             : homeScreenController.posts.isEmpty
//             ? GridView.builder(
//             shrinkWrap: true,
//             scrollDirection: Axis.vertical,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate:
//             const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 6,
//                 mainAxisSpacing: 8),
//             itemCount: 6,
//             itemBuilder: (BuildContext context, int index) {
//               return ShimmerEffect(
//                 baseColor: Colors.white10,
//                 highlightColor: Colors.white70,
//                 child: Container(
//                   width: size.width * 0.35,
//                   decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(16)),
//                   child: ClipRRect(
//                       borderRadius: BorderRadius.circular(16),
//                       child: ShimmerEffect(
//                         baseColor: Colors.white10,
//                         highlightColor: Colors.white70,
//                         child: Container(
//                           width: size.width * 0.4,
//                           margin: EdgeInsets.only(
//                               left: size.width * 0.03),
//                           decoration: BoxDecoration(
//                             color: Colors.grey[300],
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                         ),
//                       )),
//                 ),
//               );
//             })
//             : GridView.builder(
//             shrinkWrap: true,
//             scrollDirection: Axis.vertical,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate:
//             const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 6,
//                 mainAxisSpacing: 8),
//             itemCount: homeScreenController.posts.length,
//             itemBuilder: (BuildContext context, int index) {
//               var data = homeScreenController.posts![index];
//
//               return InkWell(
//                 onTap: () => Get.to(() =>
//                     PostDetails(postId: data.id!, isArtist: false)),
//                 child: Container(
//                   width: size.width * 0.35,
//                   decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(16)),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(16),
//                     child: CachedNetworkImage(
//                       alignment: Alignment.center,
//                       imageUrl: data.imageName!,
//                       fit: BoxFit.cover,
//                       filterQuality: FilterQuality.low,
//                       memCacheWidth: (size.width *
//                           0.35 *
//                           MediaQuery.of(context)
//                               .devicePixelRatio)
//                           .round(),
//                       progressIndicatorBuilder:
//                           (context, url, downloadProgress) =>
//                           SizedBox(
//                             height: size.height * 0.1,
//                             width: size.height * 0.1,
//                             child: Center(
//                                 child: CircularProgressIndicator(
//                                     value: downloadProgress.progress)),
//                           ),
//                       errorWidget: (context, url, error) =>
//                           Container(
//                             decoration: const BoxDecoration(
//                                 image: DecorationImage(
//                                     image: AssetImage(
//                                         "assets/images/placeholder.png"),
//                                     fit: BoxFit.cover)),
//                           ),
//                       errorListener: (e) => Container(
//                         decoration: const BoxDecoration(
//                             image: DecorationImage(
//                                 image: AssetImage(
//                                     "assets/images/placeholder.png"),
//                                 fit: BoxFit.cover)),
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             }),
//         SizedBox(
//           height: size.height * 0.03,
//         ),
//         // if (homeScreenController.hasMoreHomePostLimit.value)
//         SizedBox(
//           width: size.width,
//           height: size.height * 0.06,
//           child: ElevatedButton(
//               onPressed: () async {
//                 final isBusiness = await WebService.getIsBusiness();
//
//                 WebService.selectstylelist =
//                 await homeScreenController.selectHomestylelist;
//
//                 if (isBusiness) {
//                   Get.offAll(BusinessDashBoard(initialIndex: 1),
//                       binding: BusinessDashBoardBinding());
//                 } else {
//                   Get.offAll(const DashBoard(initialIndex: 1),
//                       binding: DashBoardBinding());
//                 }
//                 // homeScreenController.getPostsList();
//               },
//               style: ElevatedButton.styleFrom(
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8.0)),
//                 backgroundColor: titleTextColor,
//                 foregroundColor: bgBlack,
//               ),
//               child: Text(
//                 tr("home_screen.geo_style_tatto_btn"),
//                 style: Theme.of(context)
//                     .textTheme
//                     .titleMedium
//                     ?.copyWith(color: bgBlack, fontWeight: FontWeight.w500),
//               )),
//         )
//       ],
//     ));
//   }
// }
