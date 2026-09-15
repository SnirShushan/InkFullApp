import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/businessProfilecontroller.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/utils.dart';
import 'package:ink/src/utils/utils_styles.dart';

import 'widget/search_business_user_widget.dart';
import 'widget/tatto_artist_card.dart';

class BusinessProfiles extends StatefulWidget {
  const BusinessProfiles({Key? key}) : super(key: key);

  @override
  State<BusinessProfiles> createState() => _BusinessProfilesState();
}

class _BusinessProfilesState extends State<BusinessProfiles> {
  final BusinessProfileController controller =
      Get.put(BusinessProfileController());
  bool _showHeader = true;
  double _lastPixels = 0;

  bool _onScroll(ScrollNotification n) {
    if (n is! ScrollUpdateNotification) return false;
    if (n.metrics.axis != Axis.vertical) return false;
    final pixels = n.metrics.pixels;
    final delta = pixels - _lastPixels;
    if (delta > 8 && _showHeader && pixels > 24) {
      setState(() => _showHeader = false);
    } else if (delta < -8 && !_showHeader) {
      setState(() => _showHeader = true);
    }
    _lastPixels = pixels;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bgBlack,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: _showHeader
                  ? SearchBusinessUserWidget(
                      businessProfileController: controller)
                  : const SizedBox(width: double.infinity),
            ),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: _onScroll,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Obx(
                    () => controller.isLoading.value &&
                            controller.businessList.isEmpty
                        ? Utils.showProgress()
                        : controller.businessList.isEmpty
                            ? showNoFoundWidget()
                            : ListView.builder(
                                controller:
                                    controller.scrollControllerBusinessProfile,
                                itemCount: controller.businessList.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: TattooArtistCard(
                                          businessUserListModel:
                                              controller.businessList[index]));
                                },
                              ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  showNoFoundWidget() =>
      Center(child: Text("לא נמצא עסק", style: bigBoldWhiteStyle));
}

class TattooArtist {
  final List<String> images;
  final String name;
  final String location;
  final List<String> styles;

  TattooArtist({
    required this.images,
    required this.name,
    required this.location,
    required this.styles,
  });
}

class Category {
  final String label;
  final String imageUrl;

  Category({required this.label, required this.imageUrl});
}
