// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/ui/screen/home/controller/post_details_controller.dart';
//
// import '../../../../controller/post_controller.dart';
// import '../../../../data/model/post_model.dart';
// import '../../../../utils/bottomsheets.dart';
// import '../../../../utils/common.dart';
// import '../../../../utils/webService.dart';
// import '../imageDetails/post_details.dart';
//
// class FollowingPostWidget extends StatefulWidget {
//   final PostModel postModel;
//   final TextEditingController fNameController;
//   final List<String> folderIdList;
//   FollowingPostWidget(
//       {super.key,
//       required this.postModel,
//       required this.fNameController,
//       required this.folderIdList});
//
//   @override
//   State<FollowingPostWidget> createState() => _FollowingPostWidgetState();
// }
//
// class _FollowingPostWidgetState extends State<FollowingPostWidget> {
//   final PostDetailsController postDetailsController =
//       Get.put(PostDetailsController());
//
//   final PostController postController = Get.put(PostController());
//   bool isImageDeleted = false;
//   @override
//   void initState() {
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       checkImage(widget.postModel.imageName!);
//     });
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final ownerImage = widget.postModel.owner!.profileImage;
//     final postImage = widget.postModel.imageName!;
//
//     return isImageDeleted
//         ? const SizedBox()
//         : SizedBox(
//             child: Column(
//               children: [
//                 SizedBox(
//                   height: size.height * 0.1,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       SizedBox(
//                           width: size.width,
//                           child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 SizedBox(width: size.width * 0.01),
//                                 //save to gallery
//                                 buildIconWidget(
//                                     isFill: widget.folderIdList
//                                             .contains(widget.postModel.imageId)
//                                         ? true
//                                         : false,
//                                     size: size.width * 0.05,
//                                     iconPath: "ic_bookmark.png",
//                                     afterTapIcon: "ic_bookmark_fill.png",
//                                     onClick: showBookmarkBottomSheet(
//                                         size: size,
//                                         context: context,
//                                         fNameController: widget.fNameController,
//                                         pid: widget.postModel.id,
//                                         imageId: widget.postModel.imageId,
//                                         url: widget.postModel.imageName)),
//                                 //share
//                                 postDetailsController.isShareLoading.value
//                                     ? Center(
//                                         child: SizedBox(
//                                             height: Get.width * 0.08,
//                                             width: Get.width * 0.08,
//                                             child:
//                                                 const CircularProgressIndicator()))
//                                     : buildIconWidget(
//                                         isFill: false,
//                                         size: size.width * 0.05,
//                                         iconPath: "ic_share.png",
//                                         afterTapIcon: "ic_share_fill.png",
//                                         onClick: () => WebService.sharePost(
//                                             userid: widget.postModel.id,
//                                             context: context,
//                                             imageUrl: WebService
//                                                     .profileImageUrl +
//                                                 widget.postModel.imageName!)),
//                                 SizedBox(
//                                     height: size.height * 0.04,
//                                     child: const VerticalDivider(thickness: 2)),
//                                 //like || follow button
//                                 SizedBox(
//                                     width: size.width * 0.05,
//                                     height: size.width * 0.05,
//                                     child: postController.isLikeLoading
//                                         ? const Center(
//                                             child: CircularProgressIndicator())
//                                         : InkWell(
//                                             onTap: () async {
//                                               await postController
//                                                   .followPostUser(
//                                                       fid: widget
//                                                           .postModel.owner!.id,
//                                                       likeStatus: widget
//                                                                   .postModel
//                                                                   .liked ==
//                                                               "1"
//                                                           ? "0"
//                                                           : "1");
//                                             },
//                                             child: (widget.postModel.liked ==
//                                                         "1"
//                                                     ? true
//                                                     : false)
//                                                 ? Image.asset(
//                                                     "assets/icons/ic_like_fill.png",
//                                                     color: Theme.of(context)
//                                                         .primaryColor)
//                                                 : Image.asset(
//                                                     "assets/icons/ic_like.png",
//                                                     color: Theme.of(context)
//                                                         .primaryColor))),
//                                 //creator name & is artist or studio
//                                 Container(
//                                   margin:
//                                       EdgeInsets.only(left: size.width * 0.01),
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     crossAxisAlignment: CrossAxisAlignment.end,
//                                     children: [
//                                       Text(widget.postModel.owner!.name!,
//                                           style: Theme.of(context)
//                                               .textTheme
//                                               .titleMedium),
//                                       if (widget.postModel.owner!.userType! ==
//                                           "1")
//                                         Text("סטודיו",
//                                             style: Theme.of(context)
//                                                 .textTheme
//                                                 .bodySmall)
//                                     ],
//                                   ),
//                                 ),
//                                 //creator profileImage
//                                 buildOwnerProfileImage(
//                                     size: size, ownerImage: ownerImage ?? ""),
//                               ])),
//                       SizedBox(
//                           width: size.width * 0.9,
//                           child: const Divider(thickness: 2))
//                     ],
//                   ),
//                 ),
//                 //post image
//                 SizedBox(
//                     height: Get.size.height * 0.4,
//                     child: InkWell(
//                       onTap: () => Get.to(() => PostDetails(
//                           postId: widget.postModel.id!, isArtist: false)),
//                       child: CachedNetworkImage(
//                           imageUrl: postImage,
//                           fit: BoxFit.fitHeight,
//                           imageBuilder: (context, imageProvider) => Container(
//                                 width: Get.width,
//                                 height: Get.height,
//                                 alignment: Alignment.center,
//                                 decoration: BoxDecoration(
//                                   color: Colors.black87,
//                                   image: DecorationImage(
//                                       image: imageProvider,
//                                       fit: BoxFit.contain),
//                                 ),
//                               ),
//                           progressIndicatorBuilder:
//                               (context, url, downloadProgress) =>
//                                   const SizedBox(),
//                           errorWidget: (context, url, error) => const SizedBox()
//                           // Image.asset("assets/images/placeholder.png")),
//                           ),
//                     ))
//               ],
//             ),
//           );
//   }
//
//   Future checkImage(url) async {
//     await WebService.isImageDeleted(url).then((value) {
//       setState(() {
//         isImageDeleted = value;
//       });
//     });
//   }
// }
