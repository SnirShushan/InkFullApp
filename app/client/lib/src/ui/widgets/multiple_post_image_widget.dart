import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/webService.dart';

import '../../data/model/MultiPost.dart';

class MultiplePostImageWidget extends StatefulWidget {
  final bool isNewPost;
  final List<MultiPostSlider> multiPostSlider;

  const MultiplePostImageWidget({
    Key? key,
    required this.multiPostSlider,
    this.isNewPost = false,
  }) : super(key: key);

  @override
  State<MultiplePostImageWidget> createState() =>
      _MultiplePostImageScreenState();
}

class _MultiplePostImageScreenState extends State<MultiplePostImageWidget> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  final List<TransformationController> _controllers = [];
  final List<double> _scales = [];
  int currentIndex = 0;
  Offset _doubleTapPos = Offset.zero;
  List<MultiPostSlider> images = [];

  @override
  void initState() {
    super.initState();

    if (widget.isNewPost) {
      images = widget.multiPostSlider.map((e) {
        return MultiPostSlider(
          imageName: e.imageName,
          imageType: ImageSourceType.file,
        );
      }).toList();
    } else {
      images = widget.multiPostSlider;
    }

    /// IMPORTANT: initialize controllers & scales
    for (int i = 0; i < images.length; i++) {
      _controllers.add(TransformationController());
      _scales.add(1.0);
    }
  }

  void _handleDoubleTap(int index) {
    final ctrl = _controllers[index];

    if (_scales[index] != 1) {
      ctrl.value = Matrix4.identity();
      _scales[index] = 1;
      setState(() {});
      return;
    }

    const zoom = 2.0;
    final dx = _doubleTapPos.dx;
    final dy = _doubleTapPos.dy;

    ctrl.value = Matrix4.identity()
      ..translate(-dx * (zoom - 1), -dy * (zoom - 1))
      ..scale(zoom);

    _scales[index] = zoom;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: Align(
            alignment: Alignment.centerRight,
            child: SvgPicture.asset(
              AppAssets.closeIcon,
              height: 20,
              width: 20,
            ),
          ),
        ),
      ),
      body: images.length == 1
          ? _buildSingleImage()
          : _buildCarouselSlider(MediaQuery.sizeOf(context)),
    );
  }

  _buildSingleImage() {
    final img = images.first;

    return GestureDetector(
      onDoubleTapDown: (d) => _doubleTapPos = d.localPosition,
      onDoubleTap: () => _handleDoubleTap(0),
      child: InteractiveViewer(
        transformationController: _controllers[0],
        minScale: 1.0,
        maxScale: 2.0,
        panEnabled: _scales[0] > 1,
        scaleEnabled: true,
        boundaryMargin: const EdgeInsets.all(20),
        child: LayoutBuilder(builder: (context, constraints) {
          // virtual canvas size (2x to allow room for scaling and panning)
          final double w = constraints.maxWidth * 2;
          final double h = constraints.maxHeight * 2;

          return Center(
            child: SizedBox(
              width: w,
              height: h,
              child: FittedBox(
                fit: BoxFit.contain,
                // keeps the image visually the same before zoom
                child: img.imageType == ImageSourceType.file
                    ? Image.file(File(img.imageName))
                    : CachedNetworkImage(
                        imageUrl: WebService.resolveImageUrl(img.imageName),
                        fit: BoxFit.contain,
                        placeholder: (_, __) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (_, __, ___) => const Icon(Icons.error),
                      ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCarouselSlider(size) {
    return Column(
      children: [
        Expanded(
          child: CarouselSlider(
            carouselController: _carouselController,
            options: CarouselOptions(
              height: size.height,
              viewportFraction: 1,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() {
                  currentIndex = index;
                });
              },
            ),
            items: images.asMap().entries.map((entry) {
              int index = entry.key;
              var img = entry.value;

              return GestureDetector(
                onDoubleTapDown: (details) {
                  _doubleTapPos = details.localPosition;
                },
                onDoubleTap: () => _handleDoubleTap(index),
                // 👈 index passed here
                child: InteractiveViewer(
                  transformationController: _controllers[index],
                  // 👈 separate controller per image
                  minScale: 1.0,
                  maxScale: 2.0,
                  panEnabled: _scales[index] > 1,
                  // 👈 allow pan only zoomed
                  scaleEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  child: img.imageType == ImageSourceType.file
                      ? Image.file(
                          File(img.imageName),
                          fit: BoxFit.contain,
                        )
                      : CachedNetworkImage(
                          imageUrl: WebService.resolveImageUrl(img.imageName),
                          fit: BoxFit.contain,
                          placeholder: (_, __) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (_, __, ___) => const Icon(Icons.error),
                        ),
                ),
              );
            }).toList(),
          ),
        ),
        // INDICATORS
        Padding(
          padding: EdgeInsets.only(bottom: size.height * 0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (i) => Container(
                width: currentIndex == i ? 32.0 : 28.0,
                height: 8,
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(20),
                    color: (currentIndex == i
                        ? titleTextWhiteColor
                        : titleTextWhiteColor.withOpacity(0.4))),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
