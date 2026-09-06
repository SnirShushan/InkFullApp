// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:ink/src/utils/colors.dart';
//
// import '../../../utils/assets.dart';
//
// class SavedCollection extends StatelessWidget {
//   const SavedCollection({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     return Scaffold(
//       backgroundColor: bgBlack,
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(children: [
//           SizedBox(height: size.height * 0.03),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               IconButton(
//                   icon: SvgPicture.asset(
//                     AppAssets.backarrowIcon,
//                     color: titleTextWhiteColor,
//                     height: 20,
//                     width: 20,
//                   ),
//                   onPressed: () {}),
//               Text(
//                 'שמורים',
//                 style: TextStyle(
//                     color: titleTextWhiteColor,
//                     fontSize: 20,
//                     fontWeight: FontWeight.w700),
//               ),
//               Spacer(),
//               IconButton(
//                   icon: SvgPicture.asset(
//                     AppAssets.plusIcon,
//                     color: titleTextWhiteColor,
//                     // height: 20,
//                     // width: 20,
//                   ),
//                   onPressed: () {}),
//             ],
//           ),
//           Expanded(child: TattooGridScreen()),
//         ]),
//       ),
//     );
//   }
// }
//
// class TattooGridScreen extends StatelessWidget {
//   final List<Map<String, String>> tattoos = [
//     {
//       'image':
//           'https://i.pinimg.com/236x/64/ba/31/64ba312f375f74f7c2f4a79555e332ab.jpg',
//       'title': 'קעקועים ליד'
//     },
//     {
//       'image':
//           'https://i.pinimg.com/236x/64/ba/31/64ba312f375f74f7c2f4a79555e332ab.jpg',
//       'title': 'קעקועים יפים'
//     },
//     {
//       'image':
//           'https://i.pinimg.com/236x/64/ba/31/64ba312f375f74f7c2f4a79555e332ab.jpg',
//       'title': 'קעקועים מיוחדים'
//     },
//     {
//       'image':
//           'https://i.pinimg.com/236x/64/ba/31/64ba312f375f74f7c2f4a79555e332ab.jpg',
//       'title': 'קעקועים לרגל'
//     },
//     {
//       'image':
//           'https://i.pinimg.com/236x/64/ba/31/64ba312f375f74f7c2f4a79555e332ab.jpg',
//       'title': 'קעקועים לפנים'
//     },
//     {
//       'image':
//           'https://i.pinimg.com/236x/64/ba/31/64ba312f375f74f7c2f4a79555e332ab.jpg',
//       'title': 'קעקועים מיוחדים'
//     },
//     {
//       'image':
//           'https://i.pinimg.com/236x/64/ba/31/64ba312f375f74f7c2f4a79555e332ab.jpg',
//       'title': 'קעקועים לרגל'
//     },
//     {
//       'image':
//           'https://i.pinimg.com/236x/64/ba/31/64ba312f375f74f7c2f4a79555e332ab.jpg',
//       'title': 'קעקועים לפנים'
//     },
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       // padding: EdgeInsets.all(10.0),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 0.88, //0.75,
//         mainAxisSpacing: 10, //10.0,
//         crossAxisSpacing: 10.0,
//       ),
//       itemCount: tattoos.length,
//       itemBuilder: (context, index) {
//         return ImageCard(
//           imagePath: tattoos[index]['image']!,
//           title: tattoos[index]['title']!,
//         );
//       },
//     );
//   }
// }
//
// class ImageCard extends StatelessWidget {
//   final String imagePath;
//   final String title;
//
//   ImageCard({required this.imagePath, required this.title});
//
//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 0),
//       child: Container(
//         //  width: 160,
//         height: 192,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // Container(
//             //   width: 60,
//             //   height: 60,
//             //   decoration: BoxDecoration(
//             //     image: DecorationImage(
//             //       image: NetworkImage(
//             //           'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQHUuFkQRfJ9ZF3zW2C6wJT3nfHBvIGswq0iw&s'), // replace with your image URL
//             //       fit: BoxFit.cover,
//             //     ),
//             //     borderRadius: BorderRadius.circular(8.0),
//             //   ),
//             // ),
//             ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: CachedNetworkImage(
//                 imageUrl: imagePath,
//                 height: size.width * 0.4,
//                 width: size.width * 0.4,
//                 fit: BoxFit.cover,
//               ),
//               // child: Image.network(
//               //   imagePath,
//               //   height: 160,
//               //   width: 160,
//               //   fit: BoxFit.cover,
//               // ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               title,
//               style: TextStyle(
//                   color: titleTextWhiteColor,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
