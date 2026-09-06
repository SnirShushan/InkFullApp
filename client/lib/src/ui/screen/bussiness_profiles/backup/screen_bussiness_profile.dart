// import 'dart:io';
//
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/controller/businessProfilecontroller.dart';
// import 'package:ink/src/ui/screen/profile/businessUserProfile.dart';
// import 'package:ink/src/utils/webService.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// import '../../../../data/model/business_user.dart';
// import '../../../../utils/colors.dart';
// import '../../../../utils/common.dart';
//
// class BusinessProfiles extends StatelessWidget {
//   BusinessProfiles({super.key});
//
//   final BusinessProfileController controller =
//       Get.put(BusinessProfileController());
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Scaffold(
//         appBar: AppBar(
//             toolbarHeight: Get.height * 0.02,
//             elevation: 0,
//             backgroundColor: appbarBg,
//             automaticallyImplyLeading: false,
//             centerTitle: true,
//             bottom: PreferredSize(
//                 preferredSize: Size.fromHeight(Get.size.height * 0.06),
//                 child: Row(children: [
//                   Expanded(
//                     flex: 1,
//                     child: TabBar(
//                       //tabs
//                       controller: controller.tabController,
//                       labelColor: defaultBlack,
//                       padding: EdgeInsets.zero,
//                       labelPadding: EdgeInsets.zero,
//                       labelStyle: Get.textTheme.bodyMedium!
//                           .copyWith(fontWeight: FontWeight.bold),
//                       indicatorSize: TabBarIndicatorSize.label,
//                       unselectedLabelColor: Colors.grey,
//                       indicator: const UnderlineTabIndicator(
//                           borderSide: BorderSide.none),
//                       isScrollable: false,
//                       onTap: (index) async {
//                         if (Platform.isAndroid) {
//                           if (index == 1) {
//                             var status = await Permission.location.status;
//                             if (status.isGranted || status.isLimited) {
//                               Position position =
//                                   await Geolocator.getCurrentPosition(
//                                       desiredAccuracy: LocationAccuracy.high);
//
//                               await controller.getBusinessList(
//                                   index,
//                                   position.latitude ??
//                                       controller.userController.address_lat,
//                                   position.longitude ??
//                                       controller.userController.address_lng,
//                                   "40",
//                                   "",
//                                   "");
//                             } else if (status.isDenied) {
//                               await openAppSettings();
//                             } else if (status.isPermanentlyDenied) {
//                               await openAppSettings();
//                             } else if (status.isRestricted) {}
//                           } else {
//                             await controller.getBusinessList(
//                                 index, "", "", "", "", "");
//                           }
//                         } else {
//                           if (index == 1) {
//                             try {
//                               _determinePosition().then((value) async {
//                                 await controller.getBusinessList(
//                                     index,
//                                     value.latitude ??
//                                         controller.userController.address_lat,
//                                     value.longitude ??
//                                         controller.userController.address_lng,
//                                     "40",
//                                     "",
//                                     "");
//                               });
//                             } catch (e) {
//                               await controller.getBusinessList(
//                                   index,
//                                   controller.userController.address_lat,
//                                   controller.userController.address_lng,
//                                   "40",
//                                   "",
//                                   "");
//                             }
//                           } else {
//                             await controller.getBusinessList(
//                                 index, "", "", "", "", "");
//                           }
//                         }
//                       },
//                       tabs: const [
//                         Tab(text: "פופולרי"), // 0=popular
//                         Tab(text: "קרוב אלי"), //1=close to me
//                         Tab(text: "סגנון אישי"), //2=personal style
//                         Tab(text: "חדשים"), //3=new one
//                       ],
//                     ),
//                   ),
//                   Padding(
//                       padding: const EdgeInsets.only(
//                           left: 6.0, top: 6.0, bottom: 6.0),
//                       child: Image.asset("assets/images/ink_logo.png",
//                           fit: BoxFit.fitHeight,
//                           width: Get.size.width * 0.05,
//                           height: Get.size.height * 0.06)),
//                 ]))),
//         body: Obx(() => TabBarView(
//                 controller: controller.tabController,
//                 physics: const NeverScrollableScrollPhysics(),
//                 children: [
//                   businessUserList(
//                       size: size,
//                       itemCount: controller.popularList.length,
//                       items: controller.popularList),
//                   businessUserList(
//                       size: size,
//                       itemCount: controller.nearbyList.length,
//                       items: controller.nearbyList),
//                   businessUserList(
//                       size: size,
//                       itemCount: controller.personalStylesList.length,
//                       items: controller.personalStylesList),
//                   businessUserList(
//                       size: size,
//                       itemCount: controller.newUsersList.length,
//                       items: controller.newUsersList)
//                 ])));
//   }
//
//   //business user list
//   Widget businessUserList(
//           {size, itemCount, required List<BusinessUser> items}) =>
//       controller.isLoading.value
//           ? const Center(child: CircularProgressIndicator())
//           : items.isEmpty
//               ? Center(child: Text("alerts.no_business_found").tr())
//               : ListView.builder(
//                   shrinkWrap: true,
//                   scrollDirection: Axis.vertical,
//                   itemCount: itemCount,
//                   itemBuilder: (BuildContext context, int index) {
//                     return InkWell(
//                         onTap: () => Get.to(() => BusinessProfileScreen(
//                             bId: items[index].id, fromPost: true)),
//                         child: Padding(
//                           padding: EdgeInsets.all(size.height * 0.01),
//                           child: Card(
//                             elevation: 6,
//                             child: SizedBox(
//                               height: size.height * 0.3,
//                               child: Stack(
//                                 children: [
//                                   ClipRRect(
//                                       borderRadius: BorderRadius.circular(15),
//                                       child: SizedBox(
//                                           height: size.height * 0.15,
//                                           child: Container(
//                                               decoration: const BoxDecoration(
//                                                   color: defaultBlack)))),
//                                   Center(
//                                     child: ClipOval(
//                                       child: Container(
//                                         height: size.width * 0.22,
//                                         width: size.width * 0.22,
//                                         color: Colors.white,
//                                         child: Padding(
//                                           padding:
//                                               EdgeInsets.all(size.width * 0.01),
//                                           child: items[index]
//                                                   .profileimage
//                                                   .isEmpty
//                                               ? Icon(Icons.person_pin,
//                                                   size: size.width * 0.20)
//                                               : buildCachedNetworkImage(
//                                                   height: size.width * 0.20,
//                                                   width: size.width * 0.20,
//                                                   url: WebService
//                                                           .profileImageUrl +
//                                                       items[index].profileimage,
//                                                   radius: 50),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Positioned(
//                                     left: 0,
//                                     right: 0,
//                                     bottom: 0,
//                                     child: Center(
//                                       child: SizedBox(
//                                         height: size.height * 0.082,
//                                         width: size.width,
//                                         child: Column(
//                                           children: [
//                                             IntrinsicHeight(
//                                                 child: Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .center,
//                                                     children: [
//                                                   SizedBox(
//                                                       width: size.width * 0.02),
//                                                   Text(items[index].followers,
//                                                       style: Theme.of(context)
//                                                           .textTheme
//                                                           .titleMedium),
//                                                   SizedBox(
//                                                       width: size.width * 0.02),
//                                                   const VerticalDivider(
//                                                     width: 2,
//                                                     thickness: 2,
//                                                   ),
//                                                   SizedBox(
//                                                       height: size.width * 0.05,
//                                                       width: size.width * 0.05),
//                                                   buildIconWidget(
//                                                       isFill:
//                                                           items[index].liked ==
//                                                                   "1"
//                                                               ? true
//                                                               : false,
//                                                       size: size.width * 0.05,
//                                                       iconPath: "ic_like.png",
//                                                       afterTapIcon:
//                                                           "ic_like_fill.png",
//                                                       onClick: () async {
//                                                         await controller
//                                                             .likeBusinessUser(
//                                                                 fid:
//                                                                     items[index]
//                                                                         .id,
//                                                                 likeStatus:
//                                                                     items[index].liked ==
//                                                                             "1"
//                                                                         ? "0"
//                                                                         : "1",
//                                                                 type: controller
//                                                                     .tabController!
//                                                                     .index);
//                                                       }),
//                                                   SizedBox(
//                                                       width:
//                                                           size.width * 0.015),
//                                                   Obx(() => Text(
//                                                       items[index].name,
//                                                       style: Theme.of(context)
//                                                           .textTheme
//                                                           .titleMedium!
//                                                           .copyWith(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold))),
//                                                 ])),
//                                             SizedBox(
//                                                 height: size.height * 0.005),
//                                             IntrinsicHeight(
//                                               child: SizedBox(
//                                                 // height: size.height * 0.05,
//                                                 child: Wrap(
//                                                   verticalDirection:
//                                                       VerticalDirection.up,
//                                                   alignment:
//                                                       WrapAlignment.center,
//                                                   crossAxisAlignment:
//                                                       WrapCrossAlignment.center,
//                                                   runAlignment:
//                                                       WrapAlignment.center,
//                                                   direction: Axis.horizontal,
//                                                   children: [
//                                                     buildIconWidget(
//                                                         isFill: false,
//                                                         size: size.width * 0.05,
//                                                         iconPath: "ic_map.png",
//                                                         afterTapIcon: "",
//                                                         onClick: () {}),
//                                                     SizedBox(
//                                                         width:
//                                                             size.width * 0.02),
//                                                     Text(
//                                                       items[index].address,
//                                                       maxLines: 3,
//                                                       softWrap: true,
//                                                       textAlign:
//                                                           TextAlign.center,
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                       style: Theme.of(context)
//                                                           .textTheme
//                                                           .bodySmall
//                                                           ?.copyWith(
//                                                               color:
//                                                                   defaultGrey),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ));
//                   });
//
//   Widget loading() => const Center(child: CircularProgressIndicator());
//
//   Future<Position> _determinePosition() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       // Location services are not enabled don't continue
//       // accessing the position and request users of the
//       // App to enable the location services.
//       return Future.error('Location services are disabled.');
//     }
//
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         // Permissions are denied, next time you could try
//         // requesting permissions again (this is also where
//         // Android's shouldShowRequestPermissionRationale
//         // returned true. According to Android guidelines
//         // your App should show an explanatory UI now.
//         return Future.error('Location permissions are denied');
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       // Permissions are denied forever, handle appropriately.
//       return Future.error(
//           'Location permissions are permanently denied, we cannot request permissions.');
//     }
//     return await Geolocator.getCurrentPosition();
//   }
// }
