// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/utils/colors.dart';
// import 'package:ink/src/utils/utils.dart';
// import 'package:ink/src/utils/webService.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import '../../../controller/StartupController.dart';
// import '../../../controller/userController.dart';
// import '../../../utils/common.dart';
// import '../../widgets/custom_button.dart';
// import '../../widgets/side_drawer.dart';
// import '../../widgets/text_form_field_widgets.dart';
// import '../home/imageDetails/post_details.dart';
// import '../sendTattoRquest/request_for_tattoo.dart';
// import 'businessUserProfile.dart';
// import 'controller/studioDetailControllor.dart';
//
// class StudioProfileScreenBackup extends StatefulWidget {
//   final String bId;
//   final bool fromPost;
//   const StudioProfileScreenBackup(
//       {super.key, required this.bId, required this.fromPost});
//
//   @override
//   State<StudioProfileScreenBackup> createState() =>
//       _StudioProfileScreenBackupState();
// }
//
// class _StudioProfileScreenBackupState extends State<StudioProfileScreenBackup>
//     with SingleTickerProviderStateMixin {
//   int _selectedIndex = 0;
//   var scaffoldKey = GlobalKey<ScaffoldState>();
//   final studioDetailsController = Get.put(StudioDetailController());
//   final userController = Get.put(UserController());
//   final TextEditingController commentTxtController = TextEditingController();
//   final startupController = Get.put(StartupController());
//   TabController? tabController;
//
//   //get business details
//   getDetails() async =>
//       await studioDetailsController.getBusinessInfo(bid: widget.bId);
//
//   @override
//   void initState() {
//     super.initState();
//     tabController = TabController(length: 3, vsync: this);
//     getDetails();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     var textTheme = Theme.of(context).textTheme;
//
//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//           key: scaffoldKey,
//           drawer: const SideDrawer(),
//           body: Obx(() => studioDetailsController.isLoading.value
//               ? const Center(child: CircularProgressIndicator())
//               : Column(
//                   children: [
//                     //header
//                     SizedBox(
//                       height: size.height * 0.3,
//                       child: Stack(
//                         children: [
//                           Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               //cover
//                               Expanded(
//                                 flex: 1,
//                                 child: Container(
//                                     padding: EdgeInsets.all(12.0),
//                                     decoration: const BoxDecoration(
//                                         color: Colors.black),
//                                     child: Column(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         SizedBox(height: size.height * 0.04),
//                                         SizedBox(
//                                           height: size.height * 0.05,
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               IconButton(
//                                                   onPressed: () => Get.back(),
//                                                   icon: const Icon(
//                                                     Icons.arrow_back_ios,
//                                                     color: Colors.white,
//                                                   )),
//                                               SizedBox(width: size.width * 0.1),
//                                               (userController.id.value
//                                                           .toString() !=
//                                                       studioDetailsController
//                                                           .id.value
//                                                           .toString())
//                                                   ? IconButton(
//                                                       onPressed: () =>
//                                                           _showReportDialog(
//                                                               context),
//                                                       icon: const Icon(
//                                                           Icons.more_horiz,
//                                                           color: kWhite))
//                                                   : const SizedBox()
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     )),
//                               ),
//                               //body
//                               Expanded(
//                                   flex: 1,
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.end,
//                                     crossAxisAlignment: CrossAxisAlignment.end,
//                                     children: [
//                                       SizedBox(
//                                         width: size.width * 0.5,
//                                         child: Column(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.end,
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.end,
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: [
//                                             IntrinsicHeight(
//                                               child: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.start,
//                                                 children: [
//                                                   SizedBox(
//                                                       width: size.width * 0.05),
//                                                   SizedBox(
//                                                     child: Center(
//                                                         child: Text(
//                                                             Utils.isDataEmpty(
//                                                                     studioDetailsController
//                                                                         .followers
//                                                                         .value)
//                                                                 ? "0"
//                                                                 : studioDetailsController
//                                                                     .followers
//                                                                     .value,
//                                                             style: Theme.of(
//                                                                     context)
//                                                                 .textTheme
//                                                                 .titleMedium)),
//                                                   ),
//                                                   SizedBox(
//                                                       width: size.width * 0.03),
//                                                   const VerticalDivider(
//                                                       width: 2, thickness: 2),
//                                                   SizedBox(
//                                                       width: size.width * 0.03),
//                                                   buildIconWidget(
//                                                       isFill:
//                                                           studioDetailsController
//                                                                       .liked
//                                                                       .value ==
//                                                                   "1"
//                                                               ? true
//                                                               : false,
//                                                       size: size.width * 0.05,
//                                                       iconPath: "ic_like.png",
//                                                       afterTapIcon:
//                                                           "ic_like_fill.png",
//                                                       onClick: () async {
//                                                         await studioDetailsController.followUser(
//                                                             bid:
//                                                                 studioDetailsController
//                                                                     .id.value,
//                                                             likeStatus:
//                                                                 studioDetailsController
//                                                                             .liked
//                                                                             .value ==
//                                                                         "1"
//                                                                     ? "0"
//                                                                     : "1");
//                                                       }),
//                                                   SizedBox(
//                                                       width: size.width * 0.03),
//                                                   Column(
//                                                     mainAxisSize:
//                                                         MainAxisSize.max,
//                                                     children: [
//                                                       Text(
//                                                           studioDetailsController
//                                                               .name.value,
//                                                           style: TextStyle(
//                                                               fontSize:
//                                                                   size.width *
//                                                                       0.03,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold)),
//                                                       SizedBox(
//                                                           height: size.height *
//                                                               0.002),
//                                                       studioDetailsController
//                                                                   .business_type
//                                                                   .value ==
//                                                               1
//                                                           ? Text(
//                                                               "סטודיו",
//                                                               style: Theme.of(
//                                                                       context)
//                                                                   .textTheme
//                                                                   .caption,
//                                                             )
//                                                           : Text(
//                                                               "אמן",
//                                                               style: Theme.of(
//                                                                       context)
//                                                                   .textTheme
//                                                                   .caption,
//                                                             ),
//                                                     ],
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                             // SizedBox(height: size.height * 0.01),
//                                             TabBar(
//                                               padding: EdgeInsets.zero,
//                                               labelPadding:
//                                                   EdgeInsets.symmetric(
//                                                       vertical: Get.size.width *
//                                                           0.0001,
//                                                       horizontal:
//                                                           Get.size.width *
//                                                               0.01),
//                                               labelStyle: TextStyle(
//                                                   fontSize: size.width * 0.04),
//                                               indicatorSize:
//                                                   TabBarIndicatorSize.label,
//                                               controller: tabController,
//                                               onTap: (index) => setState(() {
//                                                 tabController!.index =
//                                                     tabController!.index;
//                                                 _selectedIndex =
//                                                     tabController!.index;
//                                               }),
//                                               indicator:
//                                                   const UnderlineTabIndicator(
//                                                       borderSide:
//                                                           BorderSide.none),
//                                               tabs: [
//                                                 Tab(
//                                                   text: 'מידע',
//                                                   icon: buildTabIcon(
//                                                       isFill:
//                                                           _selectedIndex == 0
//                                                               ? true
//                                                               : false,
//                                                       size: size,
//                                                       iconPath:
//                                                           "ic_bussines_card.png",
//                                                       afterTapIcon:
//                                                           "ic_bussines_card_dis.png"),
//                                                 ),
//                                                 Tab(
//                                                   text: 'תמונות',
//                                                   icon: buildTabIcon(
//                                                       isFill:
//                                                           _selectedIndex == 1
//                                                               ? true
//                                                               : false,
//                                                       size: size,
//                                                       iconPath:
//                                                           "ic_gallary_fill.png",
//                                                       afterTapIcon:
//                                                           "ic_gallary.png"),
//                                                 ),
//                                                 Tab(
//                                                   text: "סקיצות",
//                                                   icon: buildTabIcon(
//                                                       isFill:
//                                                           _selectedIndex == 2
//                                                               ? true
//                                                               : false,
//                                                       size: size,
//                                                       iconPath:
//                                                           "ic_creations.png",
//                                                       afterTapIcon:
//                                                           "ic_creations_fill.png"),
//                                                 ),
//                                               ],
//                                               unselectedLabelColor:
//                                                   Colors.grey.shade300,
//                                               labelColor: Colors.black,
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       (userController.id.value.toString() !=
//                                               studioDetailsController.id.value
//                                                   .toString())
//                                           ? Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.center,
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.end,
//                                               children: [
//                                                 Padding(
//                                                   padding: EdgeInsets.symmetric(
//                                                       horizontal:
//                                                           size.width * 0.05),
//                                                   child: SizedBox(
//                                                       width: size.width * 0.4,
//                                                       child: buildButton(
//                                                           align: Alignment
//                                                               .centerLeft,
//                                                           size: size,
//                                                           width:
//                                                               size.width * 0.6,
//                                                           text:
//                                                               "פנה לסטודיו/מקעקע",
//                                                           onClick: () => Get.to(() =>
//                                                               ScreenTattooRequest(
//                                                                   bId: widget
//                                                                       .bId)))),
//                                                 )
//                                               ],
//                                             )
//                                           : const SizedBox(),
//                                     ],
//                                   )),
//                             ],
//                           ),
//                           //profile Image
//                           Positioned(
//                             left: size.width * 0.1,
//                             top: 40,
//                             bottom: 0,
//                             child: CircleAvatar(
//                                 backgroundColor: Colors.white,
//                                 radius: size.height * 0.062,
//                                 child: CachedNetworkImage(
//                                     imageUrl: studioDetailsController
//                                         .profile_image.value,
//                                     imageBuilder: (context, imageProvider) =>
//                                         Container(
//                                           height: size.width * 0.25,
//                                           width: size.width * 0.25,
//                                           decoration: BoxDecoration(
//                                             borderRadius:
//                                                 const BorderRadius.all(
//                                                     Radius.circular(50)),
//                                             image: DecorationImage(
//                                               image: imageProvider,
//                                               fit: BoxFit.cover,
//                                             ),
//                                           ),
//                                         ),
//                                     placeholder: (context, url) =>
//                                         const CircularProgressIndicator(),
//                                     errorWidget: (context, url, error) =>
//                                         Container(
//                                           height: size.width * 0.25,
//                                           width: size.width * 0.25,
//                                           decoration: const BoxDecoration(
//                                               borderRadius: BorderRadius.all(
//                                                   Radius.circular(50)),
//                                               image: DecorationImage(
//                                                 image: AssetImage(
//                                                     AppAssets.galleryPlaceholder),
//                                                 fit: BoxFit.cover,
//                                               )),
//                                         ))),
//                           )
//                         ],
//                       ),
//                     ),
//                     //divider
//                     SizedBox(
//                         width: size.width * 0.9,
//                         child:
//                             Divider(thickness: 2, height: size.height * 0.02)),
//                     //tabs : user info , sketch ,tattoo
//                     Expanded(
//                       flex: 1,
//                       child: TabBarView(
//                           controller: tabController,
//                           physics: const NeverScrollableScrollPhysics(),
//                           children: [
//                             //user details
//                             Padding(
//                               padding: EdgeInsets.symmetric(
//                                   horizontal: size.width * 0.05),
//                               child: ListView(
//                                 padding: EdgeInsets.zero,
//                                 shrinkWrap: true,
//                                 children: [
//                                   //description
//                                   Container(
//                                     margin: EdgeInsets.symmetric(
//                                         vertical: size.height * 0.02),
//                                     alignment: Alignment.center,
//                                     child: Text(
//                                       studioDetailsController.about_text.value,
//                                       textAlign: TextAlign.center,
//                                       textScaleFactor: 1.2,
//                                     ),
//                                   ),
//                                   const Divider(thickness: 2),
//
//                                   //phone number
//                                   Container(
//                                     margin: EdgeInsets.symmetric(
//                                         vertical: size.height * 0.02),
//                                     alignment: Alignment.center,
//                                     child: Text(
//                                         studioDetailsController.phone.value,
//                                         textAlign: TextAlign.center,
//                                         textScaleFactor: 1.2),
//                                   ),
//                                   const Divider(thickness: 2),
//
//                                   //location
//                                   //location
//                                   Center(
//                                     child: InkWell(
//                                       onTap: _launchUrl,
//                                       child: Container(
//                                         margin: EdgeInsets.symmetric(
//                                             vertical: size.height * 0.01),
//                                         width: size.width,
//                                         alignment: Alignment.center,
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: [
//                                             SizedBox(
//                                                 height: size.width * 0.1,
//                                                 width: size.width * 0.1,
//                                                 child: Image.asset(
//                                                     "assets/icons/ic_map_2.png")),
//                                             Flexible(
//                                                 child: Text(
//                                                     studioDetailsController
//                                                         .address.value,
//                                                     textAlign: TextAlign.center,
//                                                     textScaleFactor: 1.2,
//                                                     style: const TextStyle(
//                                                         color:
//                                                             defaultAppColor)))
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   const Divider(thickness: 2),
//                                   //members list
//                                   // if (studioDetailsController
//                                   //         .business_type.value !=
//                                   //     "2")
//                                   SizedBox(
//                                       height: size.height * 0.2,
//                                       child: ListView.builder(
//                                           itemCount: studioDetailsController
//                                               .artistsList.length,
//                                           reverse: true,
//                                           shrinkWrap: true,
//                                           scrollDirection: Axis.horizontal,
//                                           itemBuilder: (BuildContext context,
//                                               int index) {
//                                             return InkWell(
//                                               onTap: () {
//                                                 Navigator.push(
//                                                   context,
//                                                   MaterialPageRoute(
//                                                       builder: (context) =>
//                                                           BusinessProfileScreen(
//                                                               bId: studioDetailsController
//                                                                   .artistsList[
//                                                                       index]
//                                                                   .id!,
//                                                               fromPost: true)),
//                                                 );
//                                                 // Get.to(() =>
//                                                 //     BusinessProfileScreen(
//                                                 //         bId:
//                                                 //         studioDetailsController
//                                                 //             .artistsList[
//                                                 //         index]
//                                                 //             .id!,
//                                                 //         fromPost: true))
//                                               },
//                                               child: Padding(
//                                                 padding: EdgeInsets.symmetric(
//                                                     vertical: size.width * 0.01,
//                                                     horizontal:
//                                                         size.width * 0.02),
//                                                 child: Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment.center,
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.center,
//                                                   children: [
//                                                     Padding(
//                                                         padding: EdgeInsets
//                                                             .symmetric(
//                                                                 horizontal:
//                                                                     size.height *
//                                                                         0.008,
//                                                                 vertical:
//                                                                     size.height *
//                                                                         0.03),
//                                                         child: const SizedBox(
//                                                             child:
//                                                                 VerticalDivider(
//                                                                     thickness:
//                                                                         2))),
//                                                     Column(
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .center,
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .center,
//                                                       children: [
//                                                         SizedBox(
//                                                             height:
//                                                                 size.height *
//                                                                     0.02),
//                                                         CachedNetworkImage(
//                                                             imageUrl: WebService.profileImageUrl +
//                                                                 studioDetailsController
//                                                                     .artistsList
//                                                                     .value[
//                                                                         index]
//                                                                     .profileImage!,
//                                                             imageBuilder: (context, imageProvider) => Container(
//                                                                 height: size.width *
//                                                                     0.15,
//                                                                 width: size.width *
//                                                                     0.15,
//                                                                 decoration: BoxDecoration(
//                                                                     borderRadius:
//                                                                         const BorderRadius.all(Radius.circular(
//                                                                             50)),
//                                                                     image: DecorationImage(
//                                                                         image:
//                                                                             imageProvider,
//                                                                         fit: BoxFit
//                                                                             .cover))),
//                                                             placeholder: (context, url) =>
//                                                                 const CircularProgressIndicator(),
//                                                             errorWidget: (context, url, error) => Container(height: size.width * 0.15, width: size.width * 0.15, decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(50)), image: DecorationImage(image: AssetImage(AppAssets.galleryPlaceholder), fit: BoxFit.cover)))),
//                                                         SizedBox(
//                                                             width: size.height *
//                                                                 0.1,
//                                                             height:
//                                                                 size.height *
//                                                                     0.01),
//                                                         SizedBox(
//                                                             width: size.width *
//                                                                 0.25,
//                                                             child: Column(
//                                                                 children: [
//                                                                   Text(
//                                                                     studioDetailsController
//                                                                         .artistsList[
//                                                                             index]
//                                                                         .name!,
//                                                                     // "אלעד אלימלך",
//                                                                     maxLines: 1,
//                                                                     style: textTheme
//                                                                         .titleMedium!
//                                                                         .copyWith(
//                                                                             color:
//                                                                                 kviolet),
//                                                                   ),
//                                                                   Text(
//                                                                     studioDetailsController
//                                                                         .artistsList[
//                                                                             index]
//                                                                         .address!,
//                                                                     // "עקעקמ",
//                                                                     maxLines: 1,
//                                                                     style: textTheme
//                                                                         .bodyText2,
//                                                                   )
//                                                                 ]))
//                                                       ],
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             );
//                                           })),
//                                   if (studioDetailsController
//                                           .business_type.value !=
//                                       "2")
//                                     const Divider(thickness: 2),
//                                 ],
//                               ),
//                             ),
//                             //tattoo
//                             studioDetailsController.tattoo.isEmpty
//                                 ? const Center(
//                                     child: Text(WebService.nothingDisplayMSG))
//                                 : GridView.builder(
//                                     padding: EdgeInsets.zero,
//                                     itemCount:
//                                         studioDetailsController.tattoo.length,
//                                     shrinkWrap: true,
//                                     gridDelegate:
//                                         const SliverGridDelegateWithFixedCrossAxisCount(
//                                             crossAxisCount: 2),
//                                     itemBuilder:
//                                         (BuildContext context, int index) {
//                                       return InkWell(
//                                           onTap: () => Get.to(() => PostDetails(
//                                                 postId: studioDetailsController
//                                                     .tattoo[index].id!,
//                                                 isArtist: false,
//                                               )),
//                                           child: buildCachedNetworkImageGrid(
//                                               size: size,
//                                               url: studioDetailsController
//                                                   .tattoo[index].imageName!));
//                                     }),
//                             //sketch
//                             studioDetailsController.sketch.isEmpty
//                                 ? const Center(
//                                     child: Text(WebService.nothingDisplayMSG))
//                                 : GridView.builder(
//                                     padding: EdgeInsets.zero,
//                                     itemCount:
//                                         studioDetailsController.sketch.length,
//                                     shrinkWrap: true,
//                                     gridDelegate:
//                                         const SliverGridDelegateWithFixedCrossAxisCount(
//                                       crossAxisCount: 2,
//                                     ),
//                                     itemBuilder:
//                                         (BuildContext context, int index) {
//                                       return InkWell(
//                                           onTap: () => Get.to(() => PostDetails(
//                                               postId: studioDetailsController
//                                                   .sketch[index].id!,
//                                               isArtist: false)),
//                                           child: buildCachedNetworkImageGrid(
//                                               size: size,
//                                               url: studioDetailsController
//                                                   .sketch[index].imageName!));
//                                     }),
//                           ]),
//                     ),
//                   ],
//                 ))),
//     );
//   }
//
//   buildCachedNetworkImageGrid({required size, required String url}) =>
//       CachedNetworkImage(
//           imageUrl: url,
//           imageBuilder: (context, imageProvider) => Container(
//                 margin: EdgeInsets.all(size.width * 0.002),
//                 height: size.width * 0.1,
//                 width: size.width * 0.1,
//                 decoration: BoxDecoration(
//                     image: DecorationImage(
//                         image: imageProvider, fit: BoxFit.cover)),
//               ),
//           progressIndicatorBuilder: (context, url, downloadProgress) =>
//               SizedBox(
//                 height: size.height * 0.1,
//                 width: size.width * 0.1,
//                 child: Center(
//                     child: CircularProgressIndicator(
//                         value: downloadProgress.progress)),
//               ),
//           errorWidget: (context, url, error) => const Icon(Icons.error));
//
//   Future<void> _launchUrl() async {
//     final Uri mapUrl = Uri.parse(
//         'https://www.google.com/maps/search/?api=1&query=${studioDetailsController.address_lat.value},${studioDetailsController.address_lng.value}');
//     if (!await launchUrl(mapUrl)) {
//       throw 'Could not launch $mapUrl';
//     }
//   }
//
//   _openContactDialog(size) => () {
//         showModalBottomSheet(
//             context: context,
//             isScrollControlled: true,
//             builder: (context) {
//               return StatefulBuilder(
//                   builder: (BuildContext context, StateSetter state) {
//                 return FractionallySizedBox(
//                   heightFactor: 0.5,
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(30),
//                     child: Container(
//                       height: size.height * 0.85,
//                       decoration: const BoxDecoration(color: Colors.white),
//                       child: Column(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           mainAxisSize: MainAxisSize.min,
//                           children: <Widget>[
//                             Container(
//                               width: size.width,
//                               height: size.height * 0.1,
//                               color: defaultWhite,
//                               child: Center(
//                                 child: SizedBox(
//                                     width: size.width * 0.05,
//                                     child: Divider(
//                                         thickness: 4,
//                                         height: size.height * 0.01)),
//                               ),
//                             ),
//                             buildContainer(
//                                 size: size,
//                                 text: "םייק אל קסע לע חוויד",
//                                 color: Colors.white,
//                                 onClick: () => Get.to(() =>
//                                     ScreenTattooRequest(bId: widget.bId))),
//                             const Divider(thickness: 4),
//                             buildContainer(
//                                 size: size,
//                                 text: "םילהנב תדמוע אלש תונומת",
//                                 color: Colors.white,
//                                 onClick: () => Get.to(() =>
//                                     ScreenTattooRequest(bId: widget.bId))),
//                             const Divider(thickness: 4),
//                           ]),
//                     ),
//                   ),
//                 );
//               });
//             });
//       };
//
//   buildContainer(
//           {required size, required text, required color, required onClick}) =>
//       InkWell(
//         onTap: onClick,
//         child: Container(
//           width: size.width,
//           padding: EdgeInsets.symmetric(
//               horizontal: size.height * 0.05, vertical: size.height * 0.03),
//           decoration: BoxDecoration(
//               color: color, borderRadius: BorderRadius.circular(10)),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Text(text,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: size.height * 0.02))
//             ],
//           ),
//         ),
//       );
//
//   //report dialog
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
//                   // InkWell(
//                   //     onTap: () async => await postDetailsController
//                   //         .reportPost(
//                   //             pid: postDetailsController.postModel.value.id,
//                   //             reportMsg: 1)
//                   //         .then((value) => Get.back()),
//                   //     child: Container(
//                   //         width: double.infinity,
//                   //         color: Colors.white,
//                   //         height: MediaQuery.of(context).size.height * 0.1,
//                   //         child: Center(
//                   //             child: Text("דיווח על עסק לא קיים",
//                   //                 style:
//                   //                     Theme.of(context).textTheme.titleMedium)))),
//                   InkWell(
//                       onTap: () {
//                         Get.back();
//                         showDialog<String>(
//                           context: context,
//                           builder: (BuildContext context) =>
//                               StatefulBuilder(builder: (builder, setstate) {
//                             return AlertDialog(
//                               titlePadding: const EdgeInsets.all(1.0),
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(20)),
//                               title: Padding(
//                                 padding: EdgeInsets.all(Get.size.width * 0.05),
//                                 child: Stack(
//                                   clipBehavior: Clip.none,
//                                   children: [
//                                     Column(
//                                       children: [
//                                         const Text("דיווח על עסק לא קיים"),
//                                         SizedBox(
//                                             height: Get.size.height * 0.02),
//                                         TextFormFieldWidget(
//                                             controller: commentTxtController,
//                                             minlines: 5,
//                                             maxlines: 7,
//                                             titleText: 'הערות', //comments
//                                             hintText:
//                                                 'ניתן להוסיף הערה כאן', //You can add a comment here
//                                             keyboardType:
//                                                 TextInputType.multiline),
//                                         SizedBox(
//                                             height: Get.size.height * 0.02),
//                                         CustomButton(
//                                             customtitle: 'שלח', //Send
//                                             txtColor: Colors.white,
//                                             customcolor:
//                                                 Theme.of(context).primaryColor,
//                                             onPressed: () async {
//                                               Get.back();
//                                               // if (commentTxtController.text.isNotEmpty) {
//                                               await studioDetailsController
//                                                   .reportBusiness(
//                                                       bid:
//                                                           studioDetailsController
//                                                               .id,
//                                                       comment:
//                                                           commentTxtController
//                                                               .text)
//                                                   .then((value) {
//                                                 commentTxtController.text = "";
//                                               });
//                                               // }
//                                             }),
//                                       ],
//                                     ),
//                                     Positioned(
//                                       right: -Get.size.width * 0.08,
//                                       top: -Get.size.width * 0.08,
//                                       child: InkWell(
//                                         onTap: () => Get.back(),
//                                         child: CircleAvatar(
//                                             backgroundColor: defaultGrey,
//                                             child: Icon(Icons.close,
//                                                 color: defaultWhite)),
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             );
//                           }),
//                         );
//                       },
//                       child: Container(
//                           color: defaultWhite,
//                           width: double.infinity,
//                           height: MediaQuery.of(context).size.height * 0.1,
//                           child: Center(
//                               child: Text("דיווח על עסק",
//                                   style:
//                                       Theme.of(context).textTheme.titleMedium)))),
//                 ],
//               ),
//             ),
//           );
//         });
//   }
// }
