// import 'dart:io';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:ink/src/utils/assets.dart';
//
// class EditPostImagesScreen extends StatefulWidget {
//   final String imgUrl;
//   final bool isFileImage;
//   final String isMultipleImages;
//   final File? imageFile;
//
//   const EditPostImagesScreen({
//     Key? key,
//     this.imageFile,
//     required this.imgUrl,
//     this.isFileImage = false,
//     required this.isMultipleImages,
//   }) : super(key: key);
//
//   @override
//   State<EditPostImagesScreen> createState() => _EditPostImagesScreenState();
// }
//
// class _EditPostImagesScreenState extends State<EditPostImagesScreen> {
//   List<String> imageList = [];
//   int _currentIndex = 0;
//
//   final CarouselSliderController _carouselController = CarouselSliderController();
//   final List<TransformationController> _controllers = [];
//   final List<double> _scales = [];
//
//   Offset _doubleTapPos = Offset.zero;
//
//   @override
//   void initState() {
//     super.initState();
//
//     if (widget.isFileImage) {
//       imageList = [widget.imageFile!.path];
//     } else if (widget.isMultipleImages == "1") {
//       imageList = widget.imgUrl
//           .substring(1, widget.imgUrl.length - 1)
//           .split(',')
//           .map((e) => e.trim())
//           .toList();
//     } else {
//       imageList = [widget.imgUrl.replaceAll('[', '').replaceAll(']', '')];
//     }
//
//     for (var _ in imageList) {
//       _controllers.add(TransformationController());
//       _scales.add(1.0);
//     }
//   }
//
//   void _handleDoubleTap(int index) {
//     final ctrl = _controllers[index];
//
//     if (_scales[index] != 1) {
//       ctrl.value = Matrix4.identity();
//       _scales[index] = 1;
//       setState(() {});
//       return;
//     }
//
//     const zoom = 2.0;
//     final dx = _doubleTapPos.dx;
//     final dy = _doubleTapPos.dy;
//
//     ctrl.value = Matrix4.identity()
//       ..translate(-dx * (zoom - 1), -dy * (zoom - 1))
//       ..scale(zoom);
//
//     _scales[index] = zoom;
//     setState(() {});
//   }
//
//   Widget _buildZoomImage(String url, int index) {
//     return GestureDetector(
//       onDoubleTapDown: (d) => _doubleTapPos = d.localPosition,
//       onDoubleTap: () => _handleDoubleTap(index),
//
//       child: InteractiveViewer(
//         transformationController: _controllers[index],
//         minScale: 1.0,
//         maxScale: 2.0,
//         panEnabled: _scales[index] > 1,
//         scaleEnabled: true,
//         boundaryMargin: const EdgeInsets.all(20),
//
//         child: widget.isFileImage
//             ? Image.file(File(url), fit: BoxFit.contain)
//             : CachedNetworkImage(
//           imageUrl: url,
//           fit: BoxFit.contain,
//           placeholder: (_, __) =>
//           const Center(child: CircularProgressIndicator()),
//           errorWidget: (_, __, ___) => const Icon(Icons.error),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.sizeOf(context);
//
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: InkWell(
//           onTap: () => Navigator.of(context).pop(),
//           child: Align(
//             alignment: Alignment.centerRight,
//             child: SvgPicture.asset(
//               AppAssets.closeIcon,
//               height: 20,
//               width: 20,
//             ),
//           ),
//         ),
//       ),
//
//       body: CarouselSlider(
//         carouselController: _carouselController,
//         options: CarouselOptions(
//           height: size.height,
//           viewportFraction: 1,
//           enableInfiniteScroll: false,
//           onPageChanged: (i, _) => setState(() => _currentIndex = i),
//         ),
//         items: List.generate(
//           imageList.length,
//               (i) => _buildZoomImage(imageList[i], i),
//         ),
//       ),
//     );
//   }
// }
