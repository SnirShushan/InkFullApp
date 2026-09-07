import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ink/src/data/model/image_model.dart';

import '../../../utils/colors.dart';

class ScreenImages extends StatefulWidget {
  final List<RequestImages> imgList;
  const ScreenImages({Key? key, required this.imgList}) : super(key: key);
  @override
  State<ScreenImages> createState() => _ScreenImagesState();
}

class _ScreenImagesState extends State<ScreenImages> {
  late List<Widget> imageSliders;
  int _current = 0;
  TransformationController _transformationController =
      TransformationController();
  final CarouselSliderController _controller = CarouselSliderController();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    imageSliders = widget.imgList
        .map(
          (item) => InteractiveViewer(
            transformationController: _transformationController,
            minScale: 1.0,
            maxScale: 2.0,
            onInteractionUpdate: (details) {
              // Limit the zoom scale to a maximum of 2.0
              double currentScale =
                  _transformationController.value.getMaxScaleOnAxis();
              if (currentScale > 2.0) {
                _transformationController.value = Matrix4.identity()
                  ..scale(2.0); // Lock scale to 2.0
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                alignment: Alignment.center,
                imageUrl: item.imageUrl.toString(),
                fit: BoxFit.contain,
                // fit: BoxFit.cover,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    SizedBox(
                        height: size.height * 0.1,
                        width: size.width * 0.1,
                        child: Center(
                            child: CircularProgressIndicator(
                                value: downloadProgress.progress))),
                errorWidget: (context, url, error) => const Icon(Icons.photo),
              ),
            ),
          ),
        )
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
          leading: const CloseButton(color: kWhite)),
      body: widget.imgList.isEmpty
          ? Center(
              child: SizedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.photo, size: size.height * 0.2),
                    const Text("txt.no_image_to_show").tr()
                  ],
                ),
              ),
            )
          : widget.imgList.length == 1
              ? Hero(
                  tag: "requestImage",
                  child: Padding(
                    padding: EdgeInsets.all(size.height * 0.03),
                    child: SizedBox(
                      height: size.height * 0.7,
                      child:
                          Image.network(widget.imgList[0].imageUrl.toString()),
                    ),
                  ),
                )
              : Stack(
                  children: [
                    Hero(
                      tag: "requestImage",
                      child: SizedBox(
                        height: size.height,
                        width: size.width,
                        child: CarouselSlider(
                          carouselController: _controller,
                          options: CarouselOptions(
                              height: size.height,
                              autoPlay: false,
                              viewportFraction: 1,
                              animateToClosest: true,
                              enlargeCenterPage: false,
                              enlargeStrategy: CenterPageEnlargeStrategy.height,
                              pauseAutoPlayOnManualNavigate: true,
                              pauseAutoPlayOnTouch: true,
                              scrollDirection: Axis.horizontal,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _current = index;
                                });
                              }),
                          items: imageSliders,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: size.height * 0.1,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: widget.imgList.asMap().entries.map((entry) {
                          return GestureDetector(
                            onTap: () => _controller.animateToPage(entry.key),
                            child: Container(
                              width: _current == entry.key ? 30.0 : 15.0,
                              height: 8.0,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 4.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  // shape: BoxShape.circle,
                                  color: (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? kWhite
                                          : kWhite)
                                      .withOpacity(
                                          _current == entry.key ? 1 : 0.4)),
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  ],
                ),
    );
  }
}
