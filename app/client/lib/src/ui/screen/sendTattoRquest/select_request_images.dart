import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';

import '../../../data/model/bodypart_images.dart';
import '../../../utils/common.dart';
import 'controller/imgListController.dart';

class BodyPartsImageScreens extends StatefulWidget {
  const BodyPartsImageScreens({Key? key}) : super(key: key);

  @override
  State<BodyPartsImageScreens> createState() => _BodyPartsImageScreensState();
}

class _BodyPartsImageScreensState extends State<BodyPartsImageScreens> {
  late List<Widget> imageSliders;
  final picker = ImagePicker();
  final imgListController = Get.put(ImgListController());

  Future getImage() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      imgListController.imgList
          .add(AddBodyPartsImages(source: "file", path: pickedFile!.path));
    });
  }

  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    imageSliders = imgListController.imgList
        .map(
          (item) => Container(
            margin: const EdgeInsets.all(5.0),
            child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                child: Stack(
                  children: <Widget>[
                    Image.file(
                      File(item.path),
                      fit: BoxFit.cover,
                      width: size.width,
                      height: size.height * 0.5,
                    ),
                    Positioned(
                      top: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(200, 0, 0, 0),
                              Color.fromARGB(0, 0, 0, 0)
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                      ),
                    ),
                  ],
                )),
          ),
        )
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                imgListController.imgList.isEmpty
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: Get.size.height * 0.15),
                          Icon(
                            Icons.image_not_supported_outlined,
                            size: size.height * 0.05,
                          ),
                        ],
                      )
                    : CarouselSlider(
                        carouselController: _controller,
                        options: CarouselOptions(
                            autoPlay: false,
                            aspectRatio: 1,
                            viewportFraction: 1.0,
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
                Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: size.width,
                          height: size.height * 0.1,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              color: defaultWhite,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12))),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: imgListController.imgList
                                .asMap()
                                .entries
                                .map((entry) {
                              return GestureDetector(
                                onTap: () =>
                                    _controller.animateToPage(entry.key),
                                child: Container(
                                  width: 12.0,
                                  height: 12.0,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 4.0),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black)
                                          .withOpacity(_current == entry.key
                                              ? 0.9
                                              : 0.4)),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        InkWell(
                          onTap: () => imgListController.imgList.length > 2
                              ? displayMessageIcon(
                                  snackposition: SnackPosition.BOTTOM,
                                  message: "alerts.can_choose_only_3_images",
                                  color: successGreen,
                                  imageData: AppAssets.correct_transparentIcon)
                              : getImage(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "הוספת תמונה ",
                                style: textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                              Icon(
                                Icons.add_circle,
                                size: size.width * 0.08,
                              )
                            ],
                          ),
                        ),
                        const Divider(),
                        InkWell(
                          onTap: () => setState(() {
                            imgListController.deleteImage(_current);
                          }),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "מחיקת תמונה ",
                                style: textTheme.titleLarge,
                              ),
                              Icon(
                                Icons.delete,
                                size: size.width * 0.08,
                              )
                            ],
                          ),
                        ),
                        const Divider(),
                        Container(
                          child: ElevatedButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("שמור")),
                        ),
                      ],
                    )),
              ],
            ),
            Positioned(
                right: 16,
                top: 16,
                child: IconButton(
                    onPressed: () => Get.back(),
                    iconSize: 40,
                    icon: Image.asset('assets/icons/ic_close.png')))
          ],
        ),
      ),
    );
  }
}
