// import 'package:easy_localization/easy_localization.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/controller/artistsListController.dart';
// import 'package:ink/src/controller/userController.dart';
// import 'package:ink/src/data/model/currentUser.dart';
// import 'package:ink/src/data/model/postDetails.dart';
// import 'package:ink/src/ui/screen/home/controller/post_details_controller.dart';
// import 'package:ink/src/ui/widgets/unfocus_widget.dart';
// import 'package:ink/src/utils/assets.dart';
// import 'package:ink/src/utils/colors.dart';
// import 'package:ink/src/utils/common.dart';
// import 'package:ink/src/utils/webService.dart';
//
// class EditPostScreen extends StatefulWidget {
//   final MPostDetails postModel;
//
//   const EditPostScreen({super.key, required this.postModel});
//
//   @override
//   State<EditPostScreen> createState() => _EditPostScreenState();
// }
//
// class _EditPostScreenState extends State<EditPostScreen>
//     with SingleTickerProviderStateMixin {
//   bool firstScreenVisible = true;
//   bool secondScreenVisible = false;
//   bool thirdScreenVisible = false;
//   UploadTask? uploadTask;
//
//   List<StylesList> listStyles = [];
//   List<StylesList> filteredListStyles = [];
//   List<StylesList> selectedList = [];
//   List<String> selectedMemberList = [];
//   late AppUser user;
//
//   final artistController = Get.put(ArtistListController());
//
//   TextEditingController aboutTextController = TextEditingController();
//   TextEditingController searchTxtController = TextEditingController();
//   TextEditingController searchUserTxtController = TextEditingController();
//
//   Future getArtists() async => await artistController.getArtists();
//   bool isSearched = false;
//   late AnimationController animationController;
//   late Animation<double> base;
//   final postDetailController = Get.put(PostDetailsController());
//
//   @override
//   void initState() {
//     super.initState();
//     animationController =
//         AnimationController(vsync: this, duration: const Duration(seconds: 2));
//     base = CurvedAnimation(parent: animationController, curve: Curves.easeOut);
//
//     if (widget.postModel.artistUid != "") {
//       selectedMemberList.add(widget.postModel.artistUid!);
//     }
//
//     aboutTextController.text = widget.postModel.description!;
//     getUserStyles();
//     getArtists();
//   }
//
//   //get userStyles
//   Future getUserStyles() async {
//     user = await WebService.getCurrentUser();
//     user.stylesList?.map((doc) {
//       if (widget.postModel.styles!.contains(doc.slug!)) {
//         selectedList.add(doc);
//       }
//       listStyles.add(doc);
//     }).toList();
//     user.stylesList?.map((doc) {
//       filteredListStyles.add(doc);
//     }).toList();
//
//     setState(() {});
//   }
//
//   @override
//   void dispose() {
//     if (animationController.isAnimating) {
//       animationController.stop();
//     }
//     animationController.dispose();
//     aboutTextController.dispose();
//     searchTxtController.dispose();
//     searchUserTxtController.dispose();
//     super.dispose();
//   }
//
//   //search styles
//   searchQuery(query) {
//     if (query.toString().length > 1) {
//       var filterData = listStyles
//           .where((e) => e.name.toString().toLowerCase().contains(query))
//           .toList();
//       setState(() {
//         isSearched = true;
//         listStyles = filterData;
//       });
//     } else if (query.toString().isEmpty) {
//       setState(() {
//         isSearched = false;
//         listStyles = filteredListStyles;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     var textTheme = Theme.of(context).textTheme;
//
//     return UnFocusWidget(
//         child: SafeArea(
//       child: Scaffold(
//         backgroundColor: bgBlack,
//         body: firstScreenVisible
//             ? Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     SizedBox(
//                       height: size.height * 0.03,
//                     ),
//
//                     buildTopBackRow(
//                         textTheme: textTheme,
//                         title: 'סגנון הקעקוע',
//                         onPressed: () => Get.back()),
//                     const SizedBox(height: 16.0),
//                     // Add some spacing between the title and the buttons
//                     Expanded(
//                       child: Wrap(
//                         spacing: 12.0,
//                         runSpacing: 2.0,
//                         verticalDirection: VerticalDirection.down,
//                         children: listStyles.map((option) {
//                           return ElevatedButton(
//                             onPressed: () => setState(() {
//                               if (!selectedList.contains(option)) {
//                                 if (selectedList.length < 3) {
//                                   selectedList.add(option);
//                                 } else {
//                                   displayMessageIcon(
//                                       message: 'ניתן לבחור עד 3 סגנונות.',
//                                       color: errorColor,
//                                       snackposition: SnackPosition.BOTTOM,
//                                       imageData: AppAssets.errorIcon);
//                                 }
//                               } else {
//                                 selectedList.remove(option);
//                               }
//                             }),
//                             style: ElevatedButton.styleFrom(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: selectedList.contains(option)
//                                     ? 12.0
//                                     : 22.0, // Adjust padding as needed
//                                 vertical: 12.0, // Adjust padding as needed
//                               ),
//                               backgroundColor: selectedList.contains(option)
//                                   ? titleTextWhiteColor
//                                   : bgBlack,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(30.0),
//                                 side: BorderSide(
//                                     color: selectedList.contains(option)
//                                         ? titleTextWhiteColor
//                                         : Colors.white), // Border color
//                               ),
//                             ),
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               mainAxisSize: MainAxisSize
//                                   .min, // Ensure the row takes up minimum space
//                               children: [
//                                 if (selectedList
//                                     .contains(option)) // Add icon if selected
//                                   const Icon(
//                                     Icons.check,
//                                     color: bgBlack,
//                                     size: 15,
//                                   ),
//                                 if (selectedList.contains(option))
//                                   const SizedBox(width: 4),
//                                 Text(
//                                   option.name!,
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     color: selectedList.contains(option)
//                                         ? bgBlack
//                                         : titleTextWhiteColor,
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w400,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                     const SizedBox(height: 16.0),
//                     buildStyleBtnSubmit(context: context, size: size),
//                   ],
//                 ),
//               )
//             : secondScreenVisible
//                 ?
//                 //image description screen
//                 Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           height: size.height * 0.03,
//                         ),
//                         buildTopBackRow(
//                             textTheme: textTheme,
//                             title: 'תיאור',
//                             onPressed: () {
//                               setState(() {
//                                 firstScreenVisible = true;
//                                 secondScreenVisible = false;
//                                 thirdScreenVisible = false;
//                               });
//                             }),
//                         SizedBox(
//                           height: size.height * 0.03,
//                         ),
//                         const Align(
//                           alignment: Alignment.centerRight,
//                           child: Text(
//                             'כמה מילים על הקעקוע',
//                             style: TextStyle(
//                                 color: titleTextWhiteColor, fontSize: 14),
//                           ),
//                         ),
//                         SizedBox(
//                           height: size.height * 0.01,
//                         ),
//                         Expanded(
//                           child: Column(
//                             mainAxisSize: MainAxisSize
//                                 .min, // Make the Column shrink-wrap its children
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.all(16.0),
//                                 decoration: BoxDecoration(
//                                   color: signInButtonColor,
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: TextFormField(
//                                   controller: aboutTextController,
//                                   minLines: 5,
//                                   maxLines: null,
//                                   keyboardType: TextInputType.multiline,
//                                   onTapOutside: (event) {
//                                     FocusManager.instance.primaryFocus
//                                         ?.unfocus();
//                                   },
//                                   style: textTheme.titleMedium!.copyWith(
//                                       color: titleTextWhiteColor,
//                                       fontWeight: FontWeight.w400),
//                                   // Allows the text field to grow as the user types
//                                   decoration: const InputDecoration(
//                                     border: InputBorder.none,
//                                   ),
//                                   onChanged: (txt) {
//                                     aboutTextController.text = txt;
//                                     setState(() {});
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 16.0),
//                         Obx(() =>
//                             (postDetailController.isEditPostLoading.value ==
//                                     true)
//                                 ? buildIsLoading(size)
//                                 : buildDetailBtnSubmit(
//                                     context: context, size: size))
//                       ],
//                     ))
//                 : Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(
//                         height: size.height * 0.03,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           SizedBox(
//                             width: size.width * 0.03,
//                           ),
//                           IconButton(
//                               icon: SvgPicture.asset(
//                                 AppAssets.backarrowIcon,
//                                 color: titleTextColor,
//                                 height: 20,
//                                 width: 20,
//                               ),
//                               onPressed: () {
//                                 setState(() {
//                                   firstScreenVisible = false;
//                                   secondScreenVisible = true;
//                                   thirdScreenVisible = false;
//                                 });
//                               }),
//                           Text(
//                             'תיוג המקעקע',
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .headlineSmall!
//                                 .copyWith(
//                                     color: titleTextColor,
//                                     fontSize: 24,
//                                     fontWeight: FontWeight.w700),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height: size.height * 0.04,
//                       ),
//                       _buildSearchbar(size: size),
//                       Padding(
//                         padding:
//                             EdgeInsets.symmetric(horizontal: size.width * 0.04),
//                         child: Text(
//                           'המקעקעים בסטודיו:',
//                           textAlign: TextAlign.center,
//                           style: textTheme.titleSmall!.copyWith(
//                             color: const Color(0xFF807C84),
//                             fontWeight: FontWeight.w500,
//                             height: 0.10,
//                           ),
//                         ),
//                       ),
//                       SizedBox(
//                         height: size.height * 0.04,
//                       ),
//                       Expanded(
//                           flex: 1,
//                           child: artistController.artistList.isEmpty
//                               ? Center(
//                                   child: user.profile!.businessType == "1"
//                                       ? const Text("alerts.no_artist_found")
//                                           .tr()
//                                       : const Text("alerts.no_studio_found")
//                                           .tr())
//                               : ListView.builder(
//                                   shrinkWrap: true,
//                                   itemCount: artistController.artistList.length,
//                                   itemBuilder:
//                                       (BuildContext context, int index) {
//                                     final id = artistController
//                                         .artistList[index].profile!.id;
//                                     // WebService.printMsg(selectedMemberList.toString());
//                                     return Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         ListTile(
//                                             contentPadding: EdgeInsets.zero,
//                                             onTap: () => setState(() {
//                                                   if (!selectedMemberList
//                                                       .contains(id)) {
//                                                     if (selectedMemberList
//                                                         .isEmpty) {
//                                                       selectedMemberList
//                                                           .add(id!);
//                                                     } else {
//                                                       selectedMemberList
//                                                           .clear();
//                                                       selectedMemberList
//                                                           .add(id!);
//                                                     }
//                                                   } else {
//                                                     selectedMemberList.clear();
//                                                   }
//                                                   WebService.printMsg(
//                                                       selectedMemberList
//                                                           .toString());
//                                                 }),
//                                             selected:
//                                                 selectedMemberList.contains(id)
//                                                     ? true
//                                                     : false,
//                                             selectedTileColor: purchasebgcolor,
//                                             title: Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                               children: [
//                                                 Row(
//                                                   mainAxisSize:
//                                                       MainAxisSize.min,
//                                                   children: [
//                                                     SizedBox(
//                                                         width:
//                                                             size.width * 0.04),
//                                                     buildOwnerProfileImage(
//                                                         size: size,
//                                                         width:
//                                                             size.width * 0.14,
//                                                         ownerImage: artistController
//                                                                     .artistList[
//                                                                         index]
//                                                                     .profile!
//                                                                     .profileImage! ==
//                                                                 ""
//                                                             ? ""
//                                                             : artistController
//                                                                 .artistList[
//                                                                     index]
//                                                                 .profile!
//                                                                 .profileImage!),
//                                                     SizedBox(
//                                                         width:
//                                                             size.width * 0.015),
//                                                     Column(
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .start,
//                                                       children: [
//                                                         Text(
//                                                             artistController
//                                                                 .artistList[
//                                                                     index]
//                                                                 .profile!
//                                                                 .name!,
//                                                             style: textTheme
//                                                                 .titleMedium!
//                                                                 .copyWith(
//                                                                     color:
//                                                                         titleTextWhiteColor,
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .w700)),
//                                                         SizedBox(
//                                                             height:
//                                                                 size.height *
//                                                                     0.01),
//                                                         SizedBox(
//                                                           width:
//                                                               size.width * 0.7,
//                                                           child: Text(
//                                                             artistController
//                                                                 .artistList[
//                                                                     index]
//                                                                 .profile!
//                                                                 .address!,
//                                                             overflow:
//                                                                 TextOverflow
//                                                                     .clip,
//                                                             maxLines: 1,
//                                                             style: textTheme
//                                                                 .titleMedium!
//                                                                 .copyWith(
//                                                               color:
//                                                                   lightGrayColor,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .w400,
//                                                             ),
//                                                           ),
//                                                         )
//                                                       ],
//                                                     ),
//                                                   ],
//                                                 ),
//                                                 if (selectedMemberList
//                                                     .contains(id))
//                                                   Row(
//                                                     mainAxisSize:
//                                                         MainAxisSize.min,
//                                                     children: [
//                                                       SvgPicture.asset(
//                                                         AppAssets.closeIcon,
//                                                       ),
//                                                       SizedBox(
//                                                           width: size.width *
//                                                               0.04),
//                                                     ],
//                                                   ),
//                                               ],
//                                             )),
//                                         const Divider(),
//                                       ],
//                                     );
//                                   })),
//                       const Divider(),
//                       Obx(() => Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: InkWell(
//                             onTap: () => updatePostDetail(context),
//                             child: Container(
//                               width: size.width,
//                               height: size.height * 0.07,
//                               alignment: Alignment.center,
//                               decoration: const BoxDecoration(
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(12)),
//                                 gradient: LinearGradient(
//                                   begin: Alignment
//                                       .centerRight, // For RTL, start from right
//                                   end: Alignment
//                                       .centerLeft, // For RTL, end at left
//                                   colors: [
//                                     linearGradieantColor1,
//                                     linearGradieantColor2,
//                                     linearGradieantColor3,
//                                   ],
//                                   stops: [0.0, 0.001, 0.8937],
//                                 ),
//                               ),
//                               child: postDetailController
//                                           .isEditPostLoading.value ==
//                                       true
//                                   ? Center(
//                                       child: RotationTransition(
//                                           turns: base,
//                                           child: Image.asset(
//                                             AppAssets.loadingIcon,
//                                             color: Colors.white,
//                                           )))
//                                   : Text(
//                                       "הבא",
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleMedium
//                                           ?.copyWith(
//                                               color: kWhite,
//                                               fontWeight: FontWeight.w700),
//                                     ),
//                             ),
//                           )))
//                     ],
//                   ),
//       ),
//     ));
//   }
//
//   InkWell buildTopBackRow(
//       {required TextTheme textTheme,
//       required String title,
//       required VoidCallback onPressed}) {
//     return InkWell(
//       onTap: onPressed,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           const SizedBox(width: 4),
//           SvgPicture.asset(
//             AppAssets.backarrowIcon,
//             color: titleTextColor,
//             height: 20,
//             width: 20,
//           ),
//           const SizedBox(width: 8),
//           Text(
//             title,
//             style: textTheme.headlineSmall!
//                 .copyWith(color: titleTextColor, fontWeight: FontWeight.w700),
//           ),
//         ],
//       ),
//     );
//   }
//
//   //appbar
//   customAppBar(
//           String title, BuildContext context, Size size, TextTheme textTheme) =>
//       Container(
//         color: defaultBlack,
//         width: size.width,
//         height: size.height * 0.1,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Visibility(
//               visible: false,
//               child: InkWell(
//                   onTap: () => Get.back(),
//                   child: const Icon(Icons.arrow_circle_right_sharp)),
//             ),
//             Text(
//               title,
//               style: textTheme.titleMedium!.copyWith(color: defaultWhite),
//             ),
//             Padding(
//               padding: EdgeInsets.only(left: size.width * 0.02),
//               child: InkWell(
//                 onTap: () => Get.back(),
//                 child: const Icon(Icons.close_rounded, color: defaultWhite),
//               ),
//             ),
//           ],
//         ),
//       );
//
//   //image uploading progress
//   buildProgress() => StreamBuilder<TaskSnapshot>(
//       stream: uploadTask?.snapshotEvents,
//       builder: (context, snapshots) {
//         final data = snapshots.data!;
//         double progress = data.bytesTransferred / data.totalBytes;
//
//         return SizedBox(
//             height: 50,
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 LinearProgressIndicator(
//                     value: progress,
//                     backgroundColor: Colors.grey,
//                     color: Colors.green),
//                 Center(
//                     child: Text(
//                         'Please Wait..  ${(100 * progress).roundToDouble()} %',
//                         style: const TextStyle(color: Colors.white)))
//               ],
//             ));
//       });
//
//   //upload image to firebase
//   updatePostDetail(BuildContext context) async {
//     setState(() {
//       animationController.forward().whenComplete(() {
//         animationController.repeat();
//       });
//     });
//     postDetailController.isEditPostLoading.value = true;
//     bool isConnected = await WebService.checkConnection2();
//
//     if (!isConnected) {
//       return;
//     } else {
//       try {
//         String styleList = "";
//         if (selectedList != null) {
//           selectedList.forEach((v) {
//             styleList += v == selectedList.last ? v.slug! : "${v.slug},";
//           });
//         }
//
//         if (artistController.artistList.isNotEmpty) {
//           postDetailController.updatePostController(
//               context: context,
//               styles: styleList,
//               description: aboutTextController.text.toString(),
//               postId: widget.postModel.id,
//               artistId:
//                   selectedMemberList.isNotEmpty ? selectedMemberList[0] : "");
//         } else {
//           postDetailController.updatePostController(
//               context: context,
//               styles: styleList,
//               description: aboutTextController.text.toString(),
//               postId: widget.postModel.id);
//         }
//       } catch (e) {
//         postDetailController.isEditPostLoading.value = false;
//       } finally {
//         if (animationController.isAnimating) {
//           animationController.stop();
//         }
//       }
//     }
//   }
//
//   _buildSearchbar({required Size size}) => Padding(
//         padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
//         child: SizedBox(
//           height: size.height * 0.1,
//           child: TextFormField(
//               autofocus: false,
//               controller: searchUserTxtController,
//               keyboardType: TextInputType.name,
//               textInputAction: TextInputAction.search,
//               style: const TextStyle(color: titleTextWhiteColor),
//               onTapOutside: (event) {
//                 FocusManager.instance.primaryFocus?.unfocus();
//               },
//               decoration: InputDecoration(
//                   hintStyle: const TextStyle(color: Color(0xFF6B676F)),
//                   hintText: "חפשו את המקעקע/ת",
//                   contentPadding: const EdgeInsets.all(8),
//                   filled: true,
//                   fillColor: socialoginbtn,
//                   focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8)),
//                   prefixIcon:
//                       const Icon(Icons.search, color: titleTextWhiteColor),
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8)))),
//         ),
//       );
//
//   buildStyleBtnSubmit({required BuildContext context, required Size size}) =>
//       InkWell(
//         onTap: () {
//           if (selectedList.isNotEmpty) {
//             if (selectedList.length > 3) {
//               displayMessageIcon(
//                   message: 'ניתן לבחור עד 3 סגנונות.',
//                   color: errorColor,
//                   snackposition: SnackPosition.BOTTOM,
//                   imageData: AppAssets.errorIcon);
//             } else {
//               setState(() {
//                 firstScreenVisible = false;
//                 secondScreenVisible = true;
//                 thirdScreenVisible = false;
//               });
//             }
//           }
//         },
//         child: Container(
//           width: size.width,
//           height: size.height * 0.07,
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//             borderRadius: const BorderRadius.all(Radius.circular(12)),
//             gradient: LinearGradient(
//               begin: Alignment.centerRight, // For RTL, start from right
//               end: Alignment.centerLeft, // For RTL, end at left
//               colors: selectedList.isNotEmpty
//                   ? [
//                       linearGradieantColor1,
//                       linearGradieantColor2,
//                       linearGradieantColor3,
//                     ]
//                   : [
//                       lineargrayGradieantColor1,
//                       lineargrayGradieantColor2,
//                       lineargrayGradieantColor3,
//                     ],
//               stops: const [0.0, 0.001, 0.8937],
//             ),
//           ),
//           child: Text(
//             "הבא",
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 color: selectedList.isEmpty ? defaultGrey : kWhite,
//                 fontWeight: FontWeight.w700),
//           ),
//         ),
//       );
//
//   buildDetailBtnSubmit({required BuildContext context, required Size size}) =>
//       InkWell(
//         onTap: () async {
//           if (aboutTextController.text.trim().isNotEmpty) {
//             FocusScope.of(context).unfocus();
//             final userController = Get.put(UserController());
//             if (userController.businessType.value == "1" &&
//                 artistController.artistList.isNotEmpty) {
//               setState(() {
//                 firstScreenVisible = false;
//                 secondScreenVisible = false;
//                 thirdScreenVisible = true;
//               });
//             } else {
//               await updatePostDetail(context);
//             }
//           }
//         },
//         child: Container(
//           width: size.width,
//           height: size.height * 0.07,
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//             borderRadius: const BorderRadius.all(Radius.circular(12)),
//             gradient: LinearGradient(
//               begin: Alignment.centerRight, // For RTL, start from right
//               end: Alignment.centerLeft, // For RTL, end at left
//               colors: aboutTextController.text.trim().isNotEmpty
//                   ? [
//                       linearGradieantColor1,
//                       linearGradieantColor2,
//                       linearGradieantColor3,
//                     ]
//                   : [
//                       lineargrayGradieantColor1,
//                       lineargrayGradieantColor2,
//                       lineargrayGradieantColor3,
//                     ],
//               stops: const [0.0, 0.001, 0.8937],
//             ),
//           ),
//           child: Text(
//             "הבא",
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 color: aboutTextController.text.trim().isEmpty
//                     ? defaultGrey
//                     : kWhite,
//                 fontWeight: FontWeight.w700),
//           ),
//         ),
//       );
//
//   Align buildIsLoading(Size size) {
//     return Align(
//       alignment: Alignment.center,
//       child: Container(
//           width: size.width,
//           height: size.height * 0.07,
//           alignment: Alignment.center,
//           decoration: const BoxDecoration(
//             borderRadius: BorderRadius.all(Radius.circular(12)),
//             gradient: LinearGradient(
//               begin: Alignment.centerRight, // For RTL, start from right
//               end: Alignment.centerLeft, // For RTL, end at left
//               colors: [
//                 linearGradieantColor1,
//                 linearGradieantColor2,
//                 linearGradieantColor3,
//               ],
//               stops: [0.0, 0.001, 0.8937],
//             ),
//           ),
//           child: Center(
//             child: RotationTransition(
//                 turns: base, child: Image.asset(AppAssets.loadingIcon)),
//           )),
//     );
//   }
// }
