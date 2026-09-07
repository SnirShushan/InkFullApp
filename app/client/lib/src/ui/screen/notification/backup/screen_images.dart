// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/data/model/image_model.dart';
// import 'package:ink/src/utils/colors.dart';
// import 'package:ink/src/utils/common.dart';
//
// class ScreenImagesV1 extends StatefulWidget {
//   final List<RequestImages> imgList;
//   const ScreenImagesV1({Key? key, required this.imgList}) : super(key: key);
//   @override
//   State<ScreenImagesV1> createState() => _ScreenImagesV1State();
// }
//
// class _ScreenImagesV1State extends State<ScreenImagesV1> {
//   late List<Widget> imageSliders;
//   int _current = 0;
//   final CarouselController _controller = CarouselController();
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     imageSliders = widget.imgList
//         .map(
//           (item) => Stack(
//             children: <Widget>[
//               CachedNetworkImage(
//                 alignment: Alignment.center,
//                 imageUrl: item.imageUrl.toString(),
//                 fit: BoxFit.cover,
//                 progressIndicatorBuilder: (context, url, downloadProgress) =>
//                     Center(
//                   child: CircularProgressIndicator(
//                       value: downloadProgress.progress),
//                 ),
//                 errorWidget: (context, url, error) => const Icon(Icons.photo),
//               ),
//               Positioned(
//                 top: 0.0,
//                 left: 0.0,
//                 right: 0.0,
//                 child: Container(
//                   decoration: const BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         Color.fromARGB(200, 0, 0, 0),
//                         Color.fromARGB(0, 0, 0, 0)
//                       ],
//                       begin: Alignment.bottomCenter,
//                       end: Alignment.topCenter,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         )
//         .toList();
//
//     return Scaffold(
//       appBar: buildappBarwithback(size: size, title: "תמונות מצורפות לפנייה"),
//       body: widget.imgList.isEmpty
//           ? Center(
//               child: SizedBox(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Icon(Icons.photo, size: size.height * 0.2),
//                     const Text("txt.no_image_to_show").tr()
//                   ],
//                 ),
//               ),
//             )
//           : Column(
//               children: [
//                 Hero(
//                   tag: "requestImage",
//                   child: Padding(
//                     padding: EdgeInsets.only(top: size.height * 0.01),
//                     child: CarouselSlider(
//                       carouselController: _controller,
//                       options: CarouselOptions(
//                           height: Get.size.height * 0.75,
//                           autoPlay: false,
//                           viewportFraction: 1,
//                           animateToClosest: true,
//                           enlargeCenterPage: false,
//                           enlargeStrategy: CenterPageEnlargeStrategy.height,
//                           pauseAutoPlayOnManualNavigate: true,
//                           pauseAutoPlayOnTouch: true,
//                           scrollDirection: Axis.horizontal,
//                           onPageChanged: (index, reason) {
//                             setState(() {
//                               _current = index;
//                             });
//                           }),
//                       items: imageSliders,
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.all(size.width * 0.05),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisSize: MainAxisSize.min,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: widget.imgList.asMap().entries.map((entry) {
//                           return GestureDetector(
//                             onTap: () => _controller.animateToPage(entry.key),
//                             child: Container(
//                               width: 12.0,
//                               height: 12.0,
//                               margin: const EdgeInsets.symmetric(
//                                   vertical: 8.0, horizontal: 4.0),
//                               decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: (Theme.of(context).brightness ==
//                                               Brightness.dark
//                                           ? Colors.blue.shade300
//                                           : defaultAppColor)
//                                       .withOpacity(
//                                           _current == entry.key ? 1 : 0.4)),
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }
