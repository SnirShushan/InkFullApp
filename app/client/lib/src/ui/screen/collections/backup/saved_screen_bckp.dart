// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/controller/userController.dart';
// import 'package:ink/src/utils/webService.dart';
//
// import '../../../utils/bottomsheets.dart';
// import '../../../utils/common.dart';
// import '../../widgets/side_drawer.dart';
// import 'folderimages.dart';
//
// class SavedTattooScreen extends StatefulWidget {
//   const SavedTattooScreen({Key? key}) : super(key: key);
//
//   @override
//   State<SavedTattooScreen> createState() => _SavedTattooScreenState();
// }
//
// class _SavedTattooScreenState extends State<SavedTattooScreen> {
//   final userController = Get.put(UserController());
//
//   final TextEditingController fNameController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Obx(() => Scaffold(
//           appBar: buildappBar(
//               isEnabled: true,
//               context: context,
//               size: size,
//               title: "הפרופיל שלי"),
//           drawer: const SideDrawer(),
//           body: Column(
//             children: [
//               Container(
//                 width: double.infinity,
//                 alignment: Alignment.center,
//                 height: size.height * 0.07,
//                 decoration: const BoxDecoration(boxShadow: [
//                   BoxShadow(
//                       color: Colors.black,
//                       blurRadius: 5.0,
//                       offset: Offset(0.0, 0.45))
//                 ], color: Colors.white),
//                 child: InkWell(
//                   onTap: showAddNewFolder(
//                       context: context,
//                       size: size,
//                       controller: fNameController,
//                       fimageUrl: ""),
//                   child: Container(
//                     alignment: Alignment.centerRight,
//                     width: size.width,
//                     height: size.height * 0.06,
//                     child: Padding(
//                       padding: EdgeInsets.all(size.width * 0.03),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.max,
//                         children: [
//                           SizedBox(
//                               height: size.width * 0.05,
//                               width: size.width * 0.05,
//                               child: Image.asset(
//                                   "assets/icons/ic_multi_add.png",
//                                   fit: BoxFit.cover)),
//                           SizedBox(width: size.width * 0.05),
//                           Text("צור תיקייה",
//                               style: Theme.of(context).textTheme.titleMedium)
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: size.height * 0.01),
//               StreamBuilder<QuerySnapshot>(
//                   stream: FirebaseFirestore.instance
//                       .collection('folders')
//                       .where('uid', isEqualTo: userController.firebaseId.value)
//                       .snapshots(),
//                   builder: (BuildContext context,
//                       AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
//                     if (snapshot.hasError) {
//                       return Center(
//                           child: Text('alerts.something_went_wrong').tr());
//                     }
//
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator());
//                     }
//
//                     if (snapshot.data!.docs.isEmpty) {
//                       return Expanded(
//                           child: Center(
//                               child: const Text("alerts.no_folder").tr()));
//                     }
//                     WebService.printMsg(snapshot.data!.docs.asMap());
//                     return GridView(
//                       shrinkWrap: true,
//                       scrollDirection: Axis.vertical,
//                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 3,
//                           mainAxisExtent: size.height * 0.22,
//                           crossAxisSpacing: 3),
//                       children:
//                           snapshot.data!.docs.map((DocumentSnapshot document) {
//                         return GestureDetector(
//                           onTap: () => Get.to(() => FolderImages(
//                               fname: document["fname"], fid: document["fid"])),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                               Container(
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(30),
//                                   boxShadow: const [
//                                     BoxShadow(
//                                         color: Colors.black54,
//                                         blurRadius: 10.0,
//                                         spreadRadius: 2,
//                                         offset: Offset(4, 4))
//                                   ],
//                                 ),
//                                 child: document["image_url"] == ""
//                                     ? ClipRRect(
//                                         borderRadius: BorderRadius.circular(30),
//                                         child: Image.asset(
//                                             "assets/images/placeholder.png",
//                                             height: size.width * 0.27,
//                                             width: size.width * 0.27,
//                                             fit: BoxFit.cover),
//                                       )
//                                     : buildCachedNetworkImage(
//                                         height: size.width * 0.27,
//                                         width: size.width * 0.27,
//                                         url: document["image_url"],
//                                         radius: 30),
//                               ),
//                               Text(document["fname"])
//                             ],
//                           ),
//                         );
//                       }).toList(),
//                     );
//                   }),
//
//               //category list
//             ],
//           ),
//         ));
//   }
// }
