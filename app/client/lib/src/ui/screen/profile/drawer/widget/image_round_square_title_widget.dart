// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/ui/screen/collections/collection_view.dart';
// import 'package:ink/src/ui/screen/profile/drawer/controller/business_profile_menu_controller.dart';
// import 'package:ink/src/ui/screen/collections/folderimages.dart';
// import 'package:ink/src/utils/assets.dart';
// import 'package:ink/src/utils/colors.dart';
// import 'package:ink/src/utils/webService.dart';
//
// import '../../../../../controller/userController.dart';
//
// class ImageRoundSquareTitleWidget extends StatelessWidget {
//   final BusinessProfileMenuController businessProfileMenuController;
//
//     ImageRoundSquareTitleWidget(
//       {super.key, required this.businessProfileMenuController});
//   final UserController userController = Get.put(UserController());
//
//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     return SizedBox(
//       height: size.height * 0.22,
//       child: StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection('folders')
//               .where('uid',
//                   isEqualTo: userController.firebaseId.value)
//               .snapshots(),
//           builder: (BuildContext context,
//               AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
//             if (snapshot.hasError) {
//               return Center(child: Text('alerts.something_went_wrong').tr());
//             }
//
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//
//             if (snapshot.data!.docs.isEmpty) {
//               return Expanded(
//                   child: Center(child: const Text("alerts.no_folder").tr()));
//             }
//             WebService.printMsg(snapshot.data!.docs.asMap());
//             return ListView(
//               shrinkWrap: true,
//               scrollDirection: Axis.horizontal,
//               children: snapshot.data!.docs.map((DocumentSnapshot document) {
//                 return GestureDetector(
//                   onTap: ()=>Get.to(CollectionView(fid: document["fid"],fName: document["fname"])),
//                   // onTap: () => Get.to(() => FolderImages(
//                   //     fname: document["fname"], fid: document["fid"])),
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         Container(
//                           height: size.height * 0.15,
//                           width: size.height * 0.15,
//                           decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(16)),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(16),
//                             child: CachedNetworkImage(
//                               alignment: Alignment.center,
//                               imageUrl: document["image_url"],
//                               fit: BoxFit.cover,
//                               progressIndicatorBuilder:
//                                   (context, url, downloadProgress) => SizedBox(
//                                 height: size.height * 0.1,
//                                 width: size.height * 0.1,
//                                 child: Center(
//                                     child: CircularProgressIndicator(
//                                         value: downloadProgress.progress)),
//                               ),
//                               errorWidget: (context, url, error) => Container(
//                                 decoration:  BoxDecoration(
//                                       borderRadius: BorderRadius.circular(16),
//                                     image: DecorationImage(
//                                         image: AssetImage(AppAssets.imagePlaceHolder),
//                                         fit: BoxFit.cover)),
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: size.height * 0.02),
//                         Text(document["fname"],
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .titleMedium!
//                                 .copyWith(
//                                     fontSize: 16,
//                                     color: dividerGray,
//                                     fontWeight: FontWeight.w400))
//                       ],
//                     ),
//                   ),
//                 );
//               }).toList(),
//             );
//           }),
//     );
//   }
// }
