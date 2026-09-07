// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/data/model/postDetails.dart';
// import 'package:ink/src/utils/assets.dart';
//
// import '../../../../utils/colors.dart';
//
// class AddCollection extends StatelessWidget {
//   final MPostDetails postModel;
//   const AddCollection({Key? key, required this.postModel}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Bottom Sheet Example'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () =>
//               showBottomSheet(context: context, postModel: postModel),
//           child: const Text('Show Bottom Sheet'),
//         ),
//       ),
//     );
//   }
//
//   static showBottomSheet(
//       {required BuildContext context, required MPostDetails postModel}) {
//     var size = MediaQuery.of(context).size;
//     return showModalBottomSheet<dynamic>(
//         useRootNavigator: true,
//         isScrollControlled: true,
//         context: context,
//         builder: (BuildContext context) {
//           return Container(
//             decoration: const BoxDecoration(
//                 color: signInButtonColor,
//                 borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(16),
//                     topRight: Radius.circular(16))),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 //close
//                 InkWell(
//                     onTap: () => Get.back(),
//                     child: Padding(
//                         padding: EdgeInsets.symmetric(
//                             vertical: MediaQuery.of(context).size.height * 0.03,
//                             horizontal:
//                                 MediaQuery.of(context).size.width * 0.4),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(20.0),
//                           child: Container(
//                             margin: const EdgeInsetsDirectional.only(
//                                 start: 1.0, end: 1.0),
//                             height: MediaQuery.of(context).size.height * 0.005,
//                             width: MediaQuery.of(context).size.width * 0.2,
//                             decoration: BoxDecoration(
//                               color: kDivider,
//                               borderRadius: BorderRadius.circular(
//                                   10.0), // Adjust the radius as needed
//                             ),
//                           ),
//                         ))),
//
//                 //sketch
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     //  SizedBox(width: 10),
//                     const SizedBox(width: 20),
//                     const Expanded(
//                       child: Text(
//                         'שמרת התמונה באוסף',
//                         style:
//                             TextStyle(color: titleTextWhiteColor, fontSize: 18),
//                       ),
//                     ),
//                     Container(
//                       width: 60,
//                       height: 60,
//                       decoration: BoxDecoration(
//                         image: DecorationImage(
//                           image: NetworkImage(postModel.imageName!),
//                           // 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQHUuFkQRfJ9ZF3zW2C6wJT3nfHBvIGswq0iw&s'), // replace with your image URL
//                           fit: BoxFit.cover,
//                         ),
//                         borderRadius: BorderRadius.circular(8.0),
//                       ),
//                     ),
//                     const SizedBox(width: 20),
//                   ],
//                 ),
//
//                 const SizedBox(height: 10),
//
//                 buildDetailBtnSubmit(
//                     context: context, size: size, text: "+ אוסף חדש"),
//
//                 SizedBox(
//                   height: MediaQuery.of(context).size.height * 0.03,
//                 )
//               ],
//             ),
//           );
//         });
//   }
//
//   static _showBottomSheetNewBoard(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     return showModalBottomSheet<dynamic>(
//         useRootNavigator: true,
//         isScrollControlled: true,
//         context: context,
//         builder: (BuildContext context) {
//           return Container(
//             decoration: const BoxDecoration(
//                 color: bgBlack, //signInButtonColor,
//                 borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(16),
//                     topRight: Radius.circular(16))),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   mainAxisSize: MainAxisSize.max,
//                   children: [
//                     //close
//                     InkWell(
//                         onTap: () => Get.back(),
//                         child: Padding(
//                             padding: EdgeInsets.symmetric(
//                                 vertical:
//                                     MediaQuery.of(context).size.height * 0.03,
//                                 horizontal:
//                                     MediaQuery.of(context).size.width * 0.4),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(20.0),
//                               child: Container(
//                                 margin: const EdgeInsetsDirectional.only(
//                                     start: 1.0, end: 1.0),
//                                 height:
//                                     MediaQuery.of(context).size.height * 0.005,
//                                 width: MediaQuery.of(context).size.width * 0.2,
//                                 decoration: BoxDecoration(
//                                   color: kDivider,
//                                   borderRadius: BorderRadius.circular(
//                                       10.0), // Adjust the radius as needed
//                                 ),
//                               ),
//                             ))),
//
//                     Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         // crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Row(
//                             children: [
//                               IconButton(
//                                   icon: SvgPicture.asset(
//                                     AppAssets.backarrowIcon,
//                                     color: titleTextWhiteColor,
//                                   ),
//                                   onPressed: () => Navigator.pop(context)),
// //                 Text(
// //                   'סגנון הקעקוע',
// //                   style: TextStyle(color: titleTextColor, fontSize: 20),
// //                 ),
//                               const SizedBox(width: 8),
//                               const Text(
//                                 'אוסף חדש',
//                                 style: TextStyle(
//                                     color: Colors.white, fontSize: 20),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 50),
//                           const CircleAvatar(
//                             radius: 100,
//                             backgroundImage: NetworkImage(
//                                 'https://i.pinimg.com/236x/64/ba/31/64ba312f375f74f7c2f4a79555e332ab.jpg'), // replace with your image URL
//                           ),
//                           const SizedBox(height: 50),
//                           const Align(
//                             alignment: Alignment.centerRight,
//                             child: Text(
//                               "שם האוסף",
//                               style: TextStyle(
//                                   color: titleTextWhiteColor, fontSize: 16),
//                               textAlign: TextAlign.right,
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           SizedBox(
//                             height: 48,
//                             child: TextField(
//                               textAlignVertical: TextAlignVertical.center,
//                               style:
//                                   const TextStyle(color: titleTextWhiteColor),
//                               decoration: InputDecoration(
//                                 filled: true,
//                                 fillColor: signInButtonColor,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(8.0),
//                                 ),
//                                 hintText: 'בחר שם לאוסף החדש',
//                                 hintStyle:
//                                     const TextStyle(color: placeholdertxtColor),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 20),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 buildDetailBtnSubmit(
//                     context: context, size: size, text: "יצירת אוסף"),
//               ],
//             ),
//           );
//         });
//   }
//
//   static buildDetailBtnSubmit(
//           {required BuildContext context, required Size size, required text}) =>
//       InkWell(
//         onTap: () => _showBottomSheetNewBoard(context),
//         child: Container(
//           width: (size.width) - 20,
//           height: 52, //size.height * 0.07,
//           alignment: Alignment.center,
//           decoration: const BoxDecoration(
//             borderRadius: BorderRadius.all(Radius.circular(12)),
//             gradient: LinearGradient(
//               begin: Alignment.centerRight, // For RTL, start from right
//               end: Alignment.centerLeft, // For RTL, end at left
//               colors:
//                   // aboutTextController.text.isNotEmpty
//                   //     ?
//                   [
//                 linearGradieantColor1,
//                 linearGradieantColor2,
//                 linearGradieantColor3,
//               ],
//               //     :
//               // colors: [
//               //   lineargrayGradieantColor1,
//               //   lineargrayGradieantColor2,
//               //   lineargrayGradieantColor3,
//               // ],
//               stops: [0.0, 0.001, 0.8937],
//             ),
//           ),
//           child: Text(
//             text,
//             // "+ אוסף חדש",
//             // style: Theme.of(context).textTheme.titleMedium?.copyWith(
//             //     color: aboutTextController.text.isEmpty ? defaultGrey : kWhite,
//             //     fontWeight: FontWeight.w700),
//             style: Theme.of(context)
//                 .textTheme
//                 .titleMedium
//                 ?.copyWith(color: kWhite, fontWeight: FontWeight.w500),
//           ),
//         ),
//       );
// }
