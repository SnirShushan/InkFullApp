// import 'dart:io';
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/ui/screen/profile/businessUserProfile.dart';
// import 'package:ink/src/ui/screen/profile/subscription/iosubscription/purchase_ios_screen.dart';
// import 'package:ink/src/ui/screen/profile/subscription/purchase_screen.dart';
// import 'package:ink/src/utils/colors.dart';
// import 'package:ink/src/utils/utils.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import '../../../../controller/StartupController.dart';
// import '../../../../controller/artistsListController.dart';
// import '../../../../controller/myPostController.dart';
// import '../../../../controller/userController.dart';
// import '../../../../data/source/network/user_api.dart';
// import '../../../../utils/common.dart';
// import '../../../../utils/webService.dart';
// import '../../../widgets/side_drawer.dart';
// import '../../home/imageDetails/post_details.dart';
// import '../editProfile/edit_profile_backup.dart';
// import '../editProfile/edit_screen.dart';
//
// class ProfilescreenBackup extends StatefulWidget {
//   final bool isDrawerOpened;
//
//   const ProfilescreenBackup({super.key, required this.isDrawerOpened});
//
//   @override
//   State<ProfilescreenBackup> createState() => _ProfilescreenBackupState();
// }
//
// class _ProfilescreenBackupState extends State<ProfilescreenBackup>
//     with SingleTickerProviderStateMixin {
//   int _selectedIndex = 0;
//   int indexof = 0;
//   var checksubscription;
//   var scaffoldKey = GlobalKey<ScaffoldState>();
//
//   final userController = Get.put(UserController());
//   late final ArtistListController artistController =
//       Get.put(ArtistListController());
//   final myPostsController = Get.put(MyPostsController());
//   final startupController = Get.put(StartupController());
//   TabController? tabController;
//
//   @override
//   void initState() {
//     tabController = TabController(length: 3, vsync: this);
//     super.initState();
//   }
//
//   Future<void> checksubscriptionData({details}) async {
//     if (WebService.isSubscriptionEnable) {
//       await Network.getCheckSubscription().then((value) async {
//         setState(() {
//           checksubscription = value;
//         });
//       });
//
//       if (checksubscription['data']['subscription_status'].toString() == "1" &&
//           details == "profileScreen") {
//         Get.to(() => const EditProfile());
//       } else if (checksubscription['data']['subscription_status'].toString() ==
//               "1" &&
//           details == "profileImage") {
//         Get.to(const EditScreen(editTitle: "עריכת תמונת פרופיל", editIndex: 4));
//       } else {
//         needSubscriptionDialog(context);
//       }
//     } else {
//       Get.to(const EditProfile());
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isArtist = userController.userType.value == "2" ? true : false;
//     var size = MediaQuery.of(context).size;
//     var textTheme = Theme.of(context).textTheme;
//
//     if (!widget.isDrawerOpened) {
//       Scaffold.of(context).openDrawer();
//       // setState(() {
//       //   // WebService.isNotificationBackPressed = false;
//       // });
//     }
//
//     return Obx(() => Scaffold(
//           key: scaffoldKey,
//           drawer: const SideDrawer(),
//           body: Column(
//             children: [
//               //header
//               SizedBox(
//                 height: size.height * 0.3,
//                 child: Stack(
//                   children: [
//                     Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         //cover
//                         Expanded(
//                             flex: 1,
//                             child: Container(
//                                 alignment: Alignment.topCenter,
//                                 decoration:
//                                     const BoxDecoration(color: Colors.black),
//                                 child: SizedBox(
//                                     width: size.width,
//                                     height: size.height * 0.1,
//                                     child: Row(
//                                       // crossAxisAlignment:
//                                       //     CrossAxisAlignment.start,
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         IconButton(
//                                             onPressed: () {
//                                               scaffoldKey.currentState
//                                                   ?.openDrawer();
//                                             },
//                                             icon: const Icon(Icons.menu,
//                                                 color: kWhite)),
//                                         IconButton(
//                                             onPressed: () async =>
//                                                 checksubscriptionData(
//                                                     details: "profileScreen"),
//                                             icon: const Icon(
//                                                 Icons.edit_outlined,
//                                                 color: kWhite)),
//                                       ],
//                                     )))),
//
//                         // name , tabBar
//                         Expanded(
//                             flex: 1,
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 SizedBox(
//                                   width: size.width * 0.47,
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.end,
//                                     crossAxisAlignment: CrossAxisAlignment.end,
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       IntrinsicHeight(
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.start,
//                                           children: [
//                                             SizedBox(width: size.width * 0.03),
//                                             //followers
//                                             Text(
//                                                 Utils.isDataEmpty(userController
//                                                         .followers.value)
//                                                     ? "0"
//                                                     : userController
//                                                         .followers.value,
//                                                 style: TextStyle(
//                                                     fontSize:
//                                                         size.width * 0.04)),
//                                             SizedBox(width: size.width * 0.03),
//                                             Container(
//                                                 width: 1,
//                                                 height: size.width * 0.05,
//                                                 color: Colors.grey),
//                                             SizedBox(width: size.width * 0.03),
//                                             buildIconWidget(
//                                               isFill: false,
//                                               // businessDetailsController.liked.value == "1" ? true: false,
//                                               size: size.width * 0.05,
//                                               iconPath: "ic_like.png",
//                                               afterTapIcon: "ic_like_fill.png",
//                                               onClick: () {},
//                                               //     () async {
//                                               //   await businessDetailsController.followUser(
//                                               //       bid:
//                                               //       businessDetailsController
//                                               //           .id.value,
//                                               //       likeStatus:
//                                               //       businessDetailsController
//                                               //           .liked
//                                               //           .value ==
//                                               //           "1"
//                                               //           ? "0"
//                                               //           : "1");
//                                               // }
//                                             ),
//                                             SizedBox(width: size.width * 0.03),
//                                             Column(
//                                               mainAxisSize: MainAxisSize.min,
//                                               children: [
//                                                 Text(userController.name.value,
//                                                     style: Theme.of(context)
//                                                         .textTheme
//                                                         .bodyMedium!
//                                                         .copyWith(
//                                                             fontWeight:
//                                                                 FontWeight
//                                                                     .bold)),
//                                                 SizedBox(
//                                                     height:
//                                                         size.height * 0.002),
//                                                 userController.businessType
//                                                             .value ==
//                                                         "1"
//                                                     ? Text(
//                                                         "סטודיו",
//                                                         style: Theme.of(context)
//                                                             .textTheme
//                                                             .bodySmall,
//                                                       )
//                                                     : Text(
//                                                         "אמן",
//                                                         style: Theme.of(context)
//                                                             .textTheme
//                                                             .bodySmall,
//                                                       ),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       // SizedBox(height: size.height * 0.01),
//                                       TabBar(
//                                         padding: EdgeInsets.zero,
//                                         labelPadding: EdgeInsets.symmetric(
//                                             vertical: Get.size.width * 0.0001,
//                                             horizontal: Get.size.width * 0.01),
//                                         labelStyle: TextStyle(
//                                             fontSize: size.width * 0.04),
//                                         indicatorSize:
//                                             TabBarIndicatorSize.label,
//                                         controller: tabController,
//                                         onTap: (index) async {
//                                           if (index == 2 || index == 1) {
//                                             await Network.getCheckSubscription()
//                                                 .then((value) async {
//                                               if (value['status'].toString() ==
//                                                       "0" ||
//                                                   value['data'][
//                                                               'subscription_status']
//                                                           .toString() ==
//                                                       "0" ||
//                                                   (index == 2 &&
//                                                       value['data']
//                                                                   ['is_premium']
//                                                               .toString() ==
//                                                           "0")) {
//                                                 tabController!.index =
//                                                     tabController!
//                                                         .previousIndex;
//                                                 _selectedIndex = tabController!
//                                                     .previousIndex;
//                                                 notSubscriptionDialog(context);
//                                               } else {
//                                                 await startupController
//                                                     .checkSubscription()
//                                                     .then((value) {
//                                                   setState(() {
//                                                     tabController!.index =
//                                                         tabController!.index;
//                                                     _selectedIndex =
//                                                         tabController!.index;
//                                                   });
//                                                 });
//                                               }
//                                             });
//                                           } else {
//                                             tabController!.index =
//                                                 tabController!.index;
//                                             _selectedIndex =
//                                                 tabController!.index;
//                                             setState(() {});
//                                           }
//                                         },
//                                         indicator: const UnderlineTabIndicator(
//                                             borderSide: BorderSide.none),
//                                         isScrollable: false,
//                                         tabs: [
//                                           Tab(
//                                             text: 'מידע',
//                                             icon: buildTabIcon(
//                                                 isFill: _selectedIndex == 0
//                                                     ? true
//                                                     : false,
//                                                 size: size,
//                                                 iconPath:
//                                                     "ic_bussines_card.png",
//                                                 afterTapIcon:
//                                                     "ic_bussines_card_dis.png"),
//                                           ),
//                                           Tab(
//                                             text: 'תמונות',
//                                             icon: buildTabIcon(
//                                                 isFill: _selectedIndex == 1
//                                                     ? true
//                                                     : false,
//                                                 size: size,
//                                                 iconPath: "ic_gallary_fill.png",
//                                                 afterTapIcon: "ic_gallary.png"),
//                                           ),
//                                           Tab(
//                                             text: "סקיצות",
//                                             icon: buildTabIcon(
//                                                 isFill: _selectedIndex == 2
//                                                     ? true
//                                                     : false,
//                                                 size: size,
//                                                 iconPath: "ic_creations.png",
//                                                 afterTapIcon:
//                                                     "ic_creations_fill.png"),
//                                           ),
//                                         ],
//                                         unselectedLabelColor:
//                                             Colors.grey.shade300,
//                                         labelColor: Colors.black,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             )),
//                       ],
//                     ),
//                     //profile image
//                     Positioned(
//                       left: size.width * 0.1,
//                       top: isArtist ? -20 : 40,
//                       bottom: 0,
//                       child: GestureDetector(
//                         onTap: () =>
//                             checksubscriptionData(details: "profileImage"),
//                         child: CircleAvatar(
//                             backgroundColor: Colors.white,
//                             radius: size.height * 0.062,
//                             child: CachedNetworkImage(
//                                 imageUrl: WebService.profileImageUrl +
//                                     userController.profileimage.value
//                                         .toString(),
//                                 imageBuilder: (context, imageProvider) =>
//                                     Container(
//                                       height: size.width * 0.25,
//                                       width: size.width * 0.25,
//                                       decoration: BoxDecoration(
//                                         borderRadius: const BorderRadius.all(
//                                             Radius.circular(50)),
//                                         image: DecorationImage(
//                                           image: imageProvider,
//                                           fit: BoxFit.cover,
//                                         ),
//                                       ),
//                                     ),
//                                 placeholder: (context, url) =>
//                                     const CircularProgressIndicator(),
//                                 errorWidget: (context, url, error) => Container(
//                                       height: size.width * 0.25,
//                                       width: size.width * 0.25,
//                                       decoration: const BoxDecoration(
//                                           borderRadius: BorderRadius.all(
//                                               Radius.circular(50)),
//                                           image: DecorationImage(
//                                               image: AssetImage(
//                                                   AppAssets.galleryPlaceholder),
//                                               fit: BoxFit.cover)),
//                                     ))),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//               SizedBox(
//                   width: size.width * 0.9,
//                   child: Divider(thickness: 2, height: size.height * 0.02)),
//               //body
//               Expanded(
//                 flex: 1,
//                 child: Obx(() => TabBarView(
//                         controller: tabController,
//                         physics: const NeverScrollableScrollPhysics(),
//                         children: [
//                           //user details
//                           Padding(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: size.width * 0.05),
//                             child: ListView(
//                               padding: EdgeInsets.zero,
//                               shrinkWrap: true,
//                               children: [
//                                 //description
//                                 Container(
//                                   margin: EdgeInsets.symmetric(
//                                       vertical: size.height * 0.01),
//                                   alignment: Alignment.center,
//                                   child: Text(userController.about_text.value,
//                                       textAlign: TextAlign.center,
//                                       textScaleFactor: 1.2),
//                                 ),
//                                 const Divider(thickness: 2),
//
//                                 //phone number
//                                 Container(
//                                   margin: EdgeInsets.symmetric(
//                                       vertical: size.height * 0.01),
//                                   alignment: Alignment.center,
//                                   child: Text(userController.phone.value,
//                                       textAlign: TextAlign.center,
//                                       textScaleFactor: 1.2),
//                                 ),
//                                 const Divider(thickness: 2),
//
//                                 //location
//                                 Center(
//                                   child: InkWell(
//                                     onTap: _launchUrl,
//                                     child: Container(
//                                       margin: EdgeInsets.symmetric(
//                                           vertical: size.height * 0.01),
//                                       width: size.width,
//                                       alignment: Alignment.center,
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           SizedBox(
//                                               height: size.width * 0.1,
//                                               width: size.width * 0.1,
//                                               child: Image.asset(
//                                                   "assets/icons/ic_map_2.png")),
//                                           Flexible(
//                                               child: Text(
//                                                   userController.address.value,
//                                                   textAlign: TextAlign.center,
//                                                   textScaleFactor: 1.2,
//                                                   style: const TextStyle(
//                                                       color: defaultAppColor)))
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 const Divider(thickness: 2),
//
//                                 //members list
//                                 if (userController.userType.value == "2")
//                                   SizedBox(
//                                       height: size.height * 0.2,
//                                       width: size.width,
//                                       child: artistController.isLoading.value ==
//                                               true
//                                           ? const Center(
//                                               child:
//                                                   CircularProgressIndicator())
//                                           : ListView.builder(
//                                               itemCount: artistController
//                                                   .artistList.length,
//                                               reverse: true,
//                                               shrinkWrap: true,
//                                               scrollDirection: Axis.horizontal,
//                                               itemBuilder:
//                                                   (BuildContext context,
//                                                       int index) {
//                                                 if (artistController
//                                                     .artistList.isEmpty) {
//                                                   return Center(
//                                                       child: userController
//                                                                   .businessType
//                                                                   .value ==
//                                                               "2"
//                                                           ? const Text(
//                                                                   "alerts.no_artist_found")
//                                                               .tr()
//                                                           : const Text(
//                                                                   "alerts.no_studio_found")
//                                                               .tr());
//                                                 }
//
//                                                 return Padding(
//                                                   padding: EdgeInsets.symmetric(
//                                                       vertical:
//                                                           size.width * 0.01,
//                                                       horizontal:
//                                                           size.width * 0.02),
//                                                   child: InkWell(
//                                                     onTap: () => Get.to(() =>
//                                                         BusinessProfileScreen(
//                                                             bId:
//                                                                 artistController
//                                                                     .artistList[
//                                                                         index]
//                                                                     .profile!
//                                                                     .id!,
//                                                             fromPost: false)),
//                                                     child: Row(
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .center,
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .center,
//                                                       children: [
//                                                         Padding(
//                                                           padding: EdgeInsets
//                                                               .symmetric(
//                                                                   horizontal:
//                                                                       size.height *
//                                                                           0.008,
//                                                                   vertical:
//                                                                       size.height *
//                                                                           0.03),
//                                                           child: const SizedBox(
//                                                               child:
//                                                                   VerticalDivider(
//                                                                       thickness:
//                                                                           2)),
//                                                         ),
//                                                         Column(
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .center,
//                                                           crossAxisAlignment:
//                                                               CrossAxisAlignment
//                                                                   .center,
//                                                           children: [
//                                                             SizedBox(
//                                                                 height:
//                                                                     size.height *
//                                                                         0.02),
//                                                             CachedNetworkImage(
//                                                                 imageUrl: WebService
//                                                                         .profileImageUrl +
//                                                                     artistController
//                                                                         .artistList
//                                                                         .value[
//                                                                             index]
//                                                                         .profile!
//                                                                         .profileImage!
//                                                                         .toString(),
//                                                                 imageBuilder:
//                                                                     (context,
//                                                                             imageProvider) =>
//                                                                         Container(
//                                                                           height:
//                                                                               size.width * 0.15,
//                                                                           width:
//                                                                               size.width * 0.15,
//                                                                           decoration:
//                                                                               BoxDecoration(
//                                                                             borderRadius:
//                                                                                 const BorderRadius.all(Radius.circular(50)),
//                                                                             image:
//                                                                                 DecorationImage(
//                                                                               image: imageProvider,
//                                                                               fit: BoxFit.cover,
//                                                                             ),
//                                                                           ),
//                                                                         ),
//                                                                 placeholder: (context,
//                                                                         url) =>
//                                                                     const CircularProgressIndicator(),
//                                                                 errorWidget:
//                                                                     (context,
//                                                                             url,
//                                                                             error) =>
//                                                                         Container(
//                                                                           height:
//                                                                               size.width * 0.15,
//                                                                           width:
//                                                                               size.width * 0.15,
//                                                                           decoration: const BoxDecoration(
//                                                                               borderRadius: BorderRadius.all(Radius.circular(50)),
//                                                                               image: DecorationImage(
//                                                                                 image: AssetImage(AppAssets.galleryPlaceholder),
//                                                                                 fit: BoxFit.cover,
//                                                                               )),
//                                                                         )),
//                                                             SizedBox(
//                                                                 height:
//                                                                     size.height *
//                                                                         0.01),
//                                                             Text(
//                                                               artistController
//                                                                   .artistList[
//                                                                       index]
//                                                                   .profile!
//                                                                   .name!,
//                                                               // "אלעד אלימלך",
//                                                               style: textTheme
//                                                                   .titleMedium!
//                                                                   .copyWith(
//                                                                       color:
//                                                                           kviolet),
//                                                             ),
//                                                             SizedBox(
//                                                               width:
//                                                                   size.width *
//                                                                       0.3,
//                                                               child: Center(
//                                                                 child: Text(
//                                                                   artistController
//                                                                       .artistList[
//                                                                           index]
//                                                                       .profile!
//                                                                       .address!,
//                                                                   // "עקעקמ",
//                                                                   maxLines: 1,
//                                                                   overflow:
//                                                                       TextOverflow
//                                                                           .ellipsis,
//                                                                   style: textTheme
//                                                                       .bodyMedium,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 );
//                                               })),
//                                 // if (userController.userType.value == "2")
//                                 const Divider(thickness: 2),
//
//                                 //edit profile btn
//                                 Center(
//                                   child: InkWell(
//                                     onTap: () => checksubscriptionData(
//                                         details: "profileScreen"),
//                                     child: SizedBox(
//                                       height: size.height * 0.05,
//                                       width: size.width * 0.5,
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: const [
//                                           Icon(Icons.edit_outlined,
//                                               color: defaultAppColor),
//                                           Text(
//                                             "ערוך פרטים אישיים",
//                                             textAlign: TextAlign.center,
//                                             textScaleFactor: 1.2,
//                                             style: TextStyle(
//                                                 color: defaultAppColor),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           //tattoo
//                           myPostsController.tattoo.isEmpty
//                               ? Center(
//                                   child:
//                                       const Text("alerts.no_post_found").tr())
//                               : GridView.builder(
//                                   padding: EdgeInsets.zero,
//                                   itemCount: myPostsController.tattoo.length,
//                                   shrinkWrap: true,
//                                   gridDelegate:
//                                       const SliverGridDelegateWithFixedCrossAxisCount(
//                                           crossAxisCount: 2),
//                                   itemBuilder:
//                                       (BuildContext context, int index) {
//                                     return InkWell(
//                                         onTap: () => Get.to(() => PostDetails(
//                                               postId: myPostsController
//                                                   .tattoo[index].id!,
//                                               isArtist: isArtist,
//                                             )),
//                                         child: buildCachedNetworkImageGrid(
//                                             size: size,
//                                             url: myPostsController
//                                                 .tattoo[index].imageName!));
//                                   }),
//                           //sketch
//                           startupController.subscriptiondata.value ==
//                                   "User_Not_Found"
//                               ? Center(
//                                   child: Column(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Text(
//                                         "אין לך גישה נא הירשם", //"You Have Not Access Please Subscribe",
//                                         style: Get.textTheme.titleMedium),
//                                     SizedBox(height: Get.size.height * 0.02),
//                                     ElevatedButton(
//                                         onPressed: () async {
//                                           Get.back();
//                                           if (Platform.isAndroid) {
//                                             Get.to(() => const PurchaseScreen(
//                                                 sub1Id:
//                                                     'subscription_basic_5day',
//                                                 sub2Id:
//                                                     'subscription_premium_5day',
//                                                 fromRegistration: false));
//                                           } else {
//                                             await Network.getCheckSubscription()
//                                                 .then((value) {
//                                               if (value['status'].toString() ==
//                                                       "0" ||
//                                                   value['data'][
//                                                               'subscription_status']
//                                                           .toString() ==
//                                                       "0") {
//                                                 Get.to(const IOSPurchaseScreen(
//                                                     purchasename:
//                                                         'ללא תוכנית קנייה',
//                                                     fromRegistration: false));
//                                               } else if (value['status']
//                                                       .toString() ==
//                                                   "2") {
//                                                 Network.sessionExpired(
//                                                     msg:
//                                                         "alerts.session_expire");
//                                               } else {
//                                                 Get.to(IOSPurchaseScreen(
//                                                     fromRegistration: false,
//                                                     purchasename: value['data']
//                                                             ['product_id']
//                                                         .toString()));
//                                               }
//                                             });
//                                           }
//                                         },
//                                         child: const Text("קדם את העסק"))
//                                   ],
//                                 ))
//                               : myPostsController.sketch.isEmpty
//                                   ? Center(
//                                       child: const Text("alerts.no_post_found")
//                                           .tr())
//                                   : GridView.builder(
//                                       padding: EdgeInsets.zero,
//                                       itemCount:
//                                           myPostsController.sketch.length,
//                                       shrinkWrap: true,
//                                       gridDelegate:
//                                           const SliverGridDelegateWithFixedCrossAxisCount(
//                                               crossAxisCount: 2),
//                                       itemBuilder:
//                                           (BuildContext context, int index) {
//                                         return InkWell(
//                                             onTap: () =>
//                                                 Get.to(() => PostDetails(
//                                                       postId: myPostsController
//                                                           .sketch[index].id!,
//                                                       isArtist: isArtist,
//                                                     )),
//                                             child: buildCachedNetworkImageGrid(
//                                                 size: size,
//                                                 url: myPostsController
//                                                     .sketch[index].imageName!));
//                                       }),
//                         ])),
//               ),
//             ],
//           ),
//         ));
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
//           errorWidget: (context, url, error) => Container(
//                 decoration: const BoxDecoration(
//                     image: DecorationImage(
//                   image: AssetImage("assets/images/placeholder.png"),
//                   fit: BoxFit.cover,
//                 )),
//               ));
//
//   Future<void> _launchUrl() async {
//     final Uri mapUrl = Uri.parse(
//         'https://www.google.com/maps/search/?api=1&query=${userController.address_lat},${userController.address_lng}');
//
//     if (!await launchUrl(mapUrl)) {
//       throw ' לא ניתן לפתוח קישור זה$mapUrl';
//     }
//   }
//
//   buildContainer(
//           {required size, required text, required color, required onClick}) =>
//       InkWell(
//           onTap: onClick,
//           child: Container(
//               width: size.width,
//               padding: EdgeInsets.symmetric(
//                   horizontal: size.height * 0.05, vertical: size.height * 0.03),
//               decoration: BoxDecoration(
//                   color: color, borderRadius: BorderRadius.circular(10)),
//               child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(text,
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: size.height * 0.02))
//                   ])));
// }
