// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/controller/myPostController.dart';
// import 'package:ink/src/controller/userController.dart';
// import 'package:ink/src/ui/screen/business_user/dashboard/business_dashboard_backup.dart';
// import 'package:ink/src/ui/screen/business_user/dashboard/bussinessdashboard_binding.dart';
// import 'package:ink/src/ui/screen/dashboard/dashboard.dart';
// import 'package:ink/src/ui/screen/dashboard/dashboard_binding.dart';
// import 'package:ink/src/ui/screen/home/imageDetails/edit_post_backup.dart';
// import 'package:ink/src/ui/screen/home/imageDetails/post_image.dart';
// import 'package:ink/src/utils/common.dart';
// import 'package:ink/src/utils/webService.dart';
//
// import '../../../../../controller/post_controller.dart';
// import '../../../../../utils/bottomsheets.dart';
// import '../../../../../utils/colors.dart';
// import '../../../../widgets/custom_button.dart';
// import '../../../../widgets/text_form_field_widgets.dart';
// import '../../../profile/businessUserProfile.dart';
// import '../../../sendTattoRquest/request_for_tattoo.dart';
// import '../../controller/post_details_controller.dart';
//
// class PostDetailsBacup extends StatefulWidget {
//   final String dynamictxt;
//   final String postId;
//   final bool isArtist;
//   const PostDetailsBacup(
//       {Key? key,
//       required this.postId,
//       required this.isArtist,
//       this.dynamictxt = "dynamicNot"})
//       : super(key: key);
//
//   @override
//   State<PostDetailsBacup> createState() => _PostDetailsBacupState();
// }
//
// class _PostDetailsBacupState extends State<PostDetailsBacup> {
//   late ScrollController scrollController;
//   final TextEditingController fNameController = TextEditingController();
//   final TextEditingController commentTxtController = TextEditingController();
//   final userController = Get.put(UserController());
//
//   //see creator
//   bool? isCreatorViewOpened = false;
//
//   final postDetailsController = Get.put(PostDetailsController());
//   final myPostController = Get.put(MyPostsController());
//   final postController = Get.put(PostController());
//   bool isShareLoading = false;
//
//   Future getPostDetails() async =>
//       await postDetailsController.getPostDetails(pid: widget.postId);
//
//   @override
//   void initState() {
//     super.initState();
//     scrollController = ScrollController();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       getPostDetails();
//     });
//     // postDetailsController.refresh();
//   }
//
//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//
//   Future<bool> redirectTo() async {
//     if (identical(widget.dynamictxt, "DYNAMICTEXT")) {
//       userController.initUser().then((value) async {
//         try {
//           final isBusiness = await WebService.getIsBusiness();
//           if (userController.userType.value == "1" || isBusiness == false) {
//             Get.offAll(const DashBoard(initialIndex: 3, ),
//                 binding: DashBoardBinding());
//           } else {
//             Get.offAll(BusinessDashBoard(initialIndex: 0, ),
//                 binding: BusinessDashBoardBinding());
//           }
//         } catch (e) {
//           displayMessage(e.toString(), Colors.deepOrange);
//           WebService.printMsg(e.toString());
//         }
//       });
//     } else {
//       Get.back();
//     }
//
//     return true;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return PopScope(
//       canPop: true,
//       onPopInvoked: (bool didPop) => redirectTo,
//       child: SafeArea(
//           child: Obx(() => Scaffold(
//               backgroundColor: Colors.white10,
//               key: scaffoldKey,
//               appBar: AppBar(
//                 elevation: 0,
//                 backgroundColor: Colors.black,
//                 actions: [
//                   InkWell(
//                       onTap: () => _showReportDialog(context),
//                       child: Padding(
//                           padding: EdgeInsets.only(
//                               left: size.width * 0.05, top: size.width * 0.05),
//                           child: const Icon(Icons.more_horiz)))
//                 ],
//                 leadingWidth: size.width * 0.15,
//                 leading: GestureDetector(
//                     onTap: redirectTo,
//                     child: Container(
//                         margin: EdgeInsets.only(
//                             right: size.width * 0.05, top: size.width * 0.05),
//                         height: size.width * 0.05,
//                         width: size.width * 0.05,
//                         child: const Icon(Icons.arrow_back_ios))),
//                 // child: Image.asset("assets/icons/ic_back.png"))),
//               ),
//               body: postDetailsController.isLoading.value
//                   ? const Center(child: CircularProgressIndicator())
//                   : Column(
//                       children: [
//                         SizedBox(
//                             height: Get.size.height * 0.45,
//                             child: InkWell(
//                               onTap: () => Get.to(PostImageScreen(
//                                   imgUrl: postDetailsController
//                                       .postModel.value.imageName!,
//                                   posTitle:
//                                       postDetailsController
//                                                   .postModel.value.artist !=
//                                               null
//                                           ? postDetailsController
//                                               .postModel.value.artist!.name!
//                                           : postDetailsController
//                                               .postModel.value.owner!.name!)),
//                               child: CachedNetworkImage(
//                                   imageUrl: postDetailsController
//                                       .postModel.value.imageName!,
//                                   imageBuilder: (context, imageProvider) =>
//                                       Container(
//                                         width: Get.width,
//                                         height: Get.height,
//                                         alignment: Alignment.center,
//                                         decoration: BoxDecoration(
//                                           color: Colors.black87,
//                                           image: DecorationImage(
//                                               image: imageProvider,
//                                               fit: BoxFit.contain),
//                                         ),
//                                       ),
//                                   fit: BoxFit.fitHeight,
//                                   progressIndicatorBuilder: (context, url,
//                                           downloadProgress) =>
//                                       SizedBox(
//                                           height: size.height * 0.1,
//                                           width: size.width * 0.1,
//                                           child: Center(
//                                               child: CircularProgressIndicator(
//                                                   value: downloadProgress
//                                                       .progress))),
//                                   errorWidget: (context, url, error) =>
//                                       Image.asset(
//                                           "assets/images/placeholder.png",
//                                           fit: BoxFit.cover)),
//                             )),
//                         Expanded(
//                           child: Container(
//                             width: size.width,
//                             padding: EdgeInsets.only(
//                                 top: Get.size.height * 0.03,
//                                 left: Get.size.width * 0.01,
//                                 right: Get.size.height * 0.01),
//                             decoration: const BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.only(
//                                     topRight: Radius.circular(30),
//                                     topLeft: Radius.circular(30))),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 buildInfoRow(size),
//                                 buildDivider(size),
//                                 buildDescription(size),
//                                 if (postDetailsController
//                                             .postModel.value.artist !=
//                                         null &&
//                                     postDetailsController
//                                             .postModel.value.artist!.id !=
//                                         postDetailsController
//                                             .postModel.value.owner!.id)
//                                   buildCreatorPopUp(size),
//                                 buildTags(size),
//                                 buildDivider(size),
//                                 if (!widget.isArtist &&
//                                     userController.id.value !=
//                                         postDetailsController
//                                             .postModel.value.owner!.id)
//                                   buildButton(
//                                       align: Alignment.bottomRight,
//                                       size: size,
//                                       width: size.width * 0.5,
//                                       text: "פנה לסטודיו/מקעקע",
//                                       onClick: () => Get.to(() =>
//                                           ScreenTattooRequest(
//                                               bId: postDetailsController
//                                                   .postModel
//                                                   .value
//                                                   .owner!
//                                                   .id!))),
//                                 SizedBox(
//                                   height: Get.size.height * 0.02,
//                                 )
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     )))),
//     );
//   }
//
//   buildDescription(Size size) => Container(
//       width: size.width,
//       padding: const EdgeInsets.all(5.0),
//       child: Text(postDetailsController.postModel.value.description!));
//
//   buildTags(Size size) => Container(
//       width: size.width,
//       padding: const EdgeInsets.all(5.0),
//       child: Text(postDetailsController.postModel.value.tagStr.toString(),
//           style: const TextStyle(color: Colors.blueAccent)));
//
//   buildCreatorPopUp(Size size) => Container(
//         margin: EdgeInsets.symmetric(vertical: size.height * 0.01),
//         width: size.width,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             SizedBox(
//                 width:
//                     isCreatorViewOpened! ? size.width * 0.3 : size.width * 0.7,
//                 child: const Divider(thickness: 2)),
//             if (isCreatorViewOpened!)
//               Container(
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                     color: defaultWhite,
//                     borderRadius: BorderRadius.circular(20)),
//                 height: size.height * 0.08,
//                 width: size.width * 0.4,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     InkWell(
//                       onTap: () => Get.to(() => BusinessProfileScreen(
//                           bId: postDetailsController.postModel.value.artist !=
//                                   null
//                               ? postDetailsController
//                                   .postModel.value.artist!.id!
//                               : postDetailsController
//                                   .postModel.value.owner!.id!,
//                           fromPost: true)),
//                       child: buildOwnerProfileImage(
//                           size: size,
//                           ownerImage:
//                               ((postDetailsController.postModel.value.artist !=
//                                       null)
//                                   ? postDetailsController
//                                       .postModel.value.artist!.profileImage!
//                                   : postDetailsController
//                                       .postModel.value.owner!.profileImage!)),
//                     ),
//                     SizedBox(width: size.width * 0.01),
//                     Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         FittedBox(
//                             fit: BoxFit.fitWidth,
//                             child: Text(
//                                 postDetailsController.postModel.value.artist !=
//                                         null
//                                     ? postDetailsController
//                                         .postModel.value.artist!.name!
//                                     : postDetailsController
//                                         .postModel.value.owner!.name!,
//                                 style: Theme.of(context).textTheme.bodySmall)),
//                         if (postDetailsController
//                                 .postModel.value.owner!.userType! ==
//                             "1")
//                           Text("סטודיו",
//                               style: Theme.of(context).textTheme.bodySmall)
//                       ],
//                     ),
//                     SizedBox(width: size.width * 0.01),
//                   ],
//                 ),
//               ),
//             InkWell(
//                 onTap: () => setState(() {
//                       if (!isCreatorViewOpened!) {
//                         isCreatorViewOpened = true;
//                       } else {
//                         isCreatorViewOpened = false;
//                       }
//                     }),
//                 child: buildOwnerProfileImage(
//                     size: size,
//                     ownerImage:
//                         ((postDetailsController.postModel.value.artist != null)
//                             ? postDetailsController
//                                 .postModel.value.artist!.profileImage!
//                             : postDetailsController
//                                 .postModel.value.owner!.profileImage!))),
//             /*child: isCreatorViewOpened!
//                     ? Image.asset("assets/icons/ic_hor_user.png")
//                     : Image.asset("assets/icons/ic_vir_user.png"))*/
//           ],
//         ),
//       );
//
//   _showReportDialog(BuildContext context) {
//     return showModalBottomSheet<dynamic>(
//         useRootNavigator: true,
//         isScrollControlled: true,
//         context: context,
//         builder: (BuildContext bc) {
//           return FractionallySizedBox(
//             heightFactor: 0.2,
//             child: Container(
//               decoration: const BoxDecoration(
//                   color: appbarBg,
//                   borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(16),
//                       topRight: Radius.circular(16))),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   InkWell(
//                       onTap: () => Get.back(),
//                       child: Padding(
//                           padding: EdgeInsets.symmetric(
//                               vertical:
//                                   MediaQuery.of(context).size.height * 0.03,
//                               horizontal:
//                                   MediaQuery.of(context).size.width * 0.4),
//                           child: Container(
//                               margin: const EdgeInsetsDirectional.only(
//                                   start: 1.0, end: 1.0),
//                               height:
//                                   MediaQuery.of(context).size.height * 0.005,
//                               width: MediaQuery.of(context).size.width * 0.2,
//                               color: kDivider))),
//                   InkWell(
//                       onTap: () {
//                         Get.back();
//                         showDialog<String>(
//                           context: context,
//                           builder: (BuildContext context) =>
//                               StatefulBuilder(builder: (builder, setstate) {
//                             return AlertDialog(
//                                 titlePadding: const EdgeInsets.all(1.0),
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(20)),
//                                 title: Padding(
//                                     padding:
//                                         EdgeInsets.all(Get.size.width * 0.05),
//                                     child: Stack(
//                                       clipBehavior: Clip.none,
//                                       children: [
//                                         Column(
//                                           children: [
//                                             const Text("postDetail.repostLbl")
//                                                 .tr(),
//                                             SizedBox(
//                                                 height: Get.size.height * 0.02),
//                                             TextFormFieldWidget(
//                                                 controller:
//                                                     commentTxtController,
//                                                 minlines: 5,
//                                                 maxlines: 7,
//                                                 titleText: 'הערות', //comments
//                                                 hintText:
//                                                     'ניתן להוסיף הערה כאן', //You can add a comment here
//                                                 keyboardType:
//                                                     TextInputType.multiline),
//                                             SizedBox(
//                                                 height: Get.size.height * 0.02),
//                                             CustomButton(
//                                                 customtitle: 'שלח', //Send
//                                                 txtColor: Colors.white,
//                                                 customcolor: Theme.of(context)
//                                                     .primaryColor,
//                                                 onPressed: () async {
//                                                   // if (commentTxtController.text.isNotEmpty) {
//                                                   Get.back();
//                                                   await postDetailsController
//                                                       .reportPost(
//                                                           pid:
//                                                               postDetailsController
//                                                                   .postModel
//                                                                   .value
//                                                                   .id,
//                                                           reportMsg: 2,
//                                                           reportMsgDetails:
//                                                               commentTxtController
//                                                                   .text)
//                                                       .then((value) async {
//                                                     commentTxtController.text =
//                                                         "";
//                                                   });
//                                                 })
//                                           ],
//                                         ),
//                                         Positioned(
//                                           right: -Get.size.width * 0.08,
//                                           top: -Get.size.width * 0.08,
//                                           child: InkWell(
//                                             onTap: () => Get.back(),
//                                             child: const CircleAvatar(
//                                                 backgroundColor: defaultGrey,
//                                                 child: Icon(Icons.close,
//                                                     color: defaultWhite)),
//                                           ),
//                                         )
//                                       ],
//                                     )));
//                           }),
//                         );
//                       },
//                       child: Container(
//                           color: defaultWhite,
//                           width: double.infinity,
//                           height: MediaQuery.of(context).size.height * 0.1,
//                           child: Center(
//                               child: Text("דיווח על תמונה",
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .titleMedium)))),
//                   //תמונות שלא עומדת בנהלים
//                 ],
//               ),
//             ),
//           );
//         });
//   }
//
//   buildInfoRow(Size size) => SizedBox(
//       height: size.height * 0.05,
//       width: size.width,
//       child: Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             //delete post
//             if (widget.isArtist ||
//                 userController.id.value ==
//                     postDetailsController.postModel.value.owner!.id)
//               buildIconWidget(
//                   isFill: true,
//                   size: size.width * 0.07,
//                   iconPath: "ic_delete.png",
//                   afterTapIcon: "ic_delete.png",
//                   onClick: () => buildDeleteDialog(context, () async {
//                         await myPostController.removePostController(
//                             pid: postDetailsController.postModel.value.id,
//                             imageId:
//                                 postDetailsController.postModel.value.imageId);
//                       })),
//             //edit post
//             if (widget.isArtist ||
//                 userController.id.value ==
//                     postDetailsController.postModel.value.owner!.id)
//               buildIconWidget(
//                 isFill: false,
//                 size: size.width * 0.07,
//                 iconPath: "ic_edit.png",
//                 afterTapIcon: "ic_edit_fill.png",
//                 onClick: () => Get.to(() => EditImage(
//                       postModel: postDetailsController.postModel.value!,
//                       businesstype: userController.businessType.value,
//                     )),
//               ),
//             //save post
//             if (!widget.isArtist &&
//                 userController.id.value !=
//                     postDetailsController.postModel.value.owner!.id)
//               buildIconWidget(
//                 isFill: true,
//                 size: size.width * 0.07,
//                 iconPath: "ic_bookmark.png",
//                 afterTapIcon: "ic_bookmark_fill.png",
//                 onClick: showBookmarkBottomSheet(
//                     size: size,
//                     context: context,
//                     fNameController: fNameController,
//                     pid: postDetailsController.postModel.value.id,
//                     imageId: postDetailsController.postModel.value.imageId,
//                     url: postDetailsController.postModel.value.imageName),
//               ),
//             //share
//             if (!widget.isArtist &&
//                 userController.id.value !=
//                     postDetailsController.postModel.value.owner!.id)
//               postDetailsController.isShareLoading.value
//                   ? Center(
//                       child: SizedBox(
//                           height: Get.width * 0.07,
//                           width: Get.width * 0.07,
//                           child: const CircularProgressIndicator()),
//                     )
//                   : buildIconWidget(
//                       isFill: false,
//                       size: size.width * 0.07,
//                       iconPath: "ic_share.png",
//                       afterTapIcon: "ic_share_fill.png",
//                       onClick: () => WebService.sharePost(
//                           userid: postDetailsController.postModel.value.id,
//                           context: context,
//                           imageUrl:
//                               postDetailsController.postModel.value.imageName)),
//             const VerticalDivider(thickness: 2),
//
//             //follow or like user
//             if (!widget.isArtist &&
//                 userController.id.value !=
//                     postDetailsController.postModel.value.owner!.id)
//               SizedBox(
//                   width: size.width * 0.07,
//                   height: size.width * 0.07,
//                   child: Obx(() => postDetailsController
//                               .isFollowLoading.value ==
//                           true
//                       ? const Center(child: CircularProgressIndicator())
//                       : InkWell(
//                           onTap: () async {
//                             await postDetailsController.followPostUser(
//                                 pid: postDetailsController.postModel.value.id,
//                                 bid: postDetailsController
//                                     .postModel.value.owner!.id,
//                                 likeStatus: postDetailsController
//                                             .postModel.value.liked ==
//                                         "1"
//                                     ? "0"
//                                     : "1");
//                           },
//                           child: (postDetailsController.postModel.value.liked ==
//                                       "1"
//                                   ? true
//                                   : false)
//                               ? Image.asset("assets/icons/ic_like_fill.png",
//                                   color: defaultAppColor)
//                               : Image.asset("assets/icons/ic_like.png",
//                                   color: defaultAppColor)))),
//             InkWell(
//                 onTap: () => Get.to(() => BusinessProfileScreen(
//                     bId: postDetailsController.postModel.value.owner!.id!,
//                     fromPost: true)),
//                 child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text(postDetailsController.postModel.value.owner!.name!,
//                           style: Theme.of(context).textTheme.titleLarge),
//                       if (postDetailsController
//                               .postModel.value.owner!.userType! ==
//                           "1")
//                         Text("סטודיו",
//                             style: Theme.of(context).textTheme.bodySmall)
//                     ])),
//             InkWell(
//                 onTap: () => Get.to(() => BusinessProfileScreen(
//                     bId: postDetailsController.postModel.value.owner!.id!,
//                     fromPost: true)),
//                 child: buildOwnerProfileImage(
//                     size: size,
//                     ownerImage: postDetailsController
//                         .postModel.value.owner!.profileImage!))
//           ]));
// }
