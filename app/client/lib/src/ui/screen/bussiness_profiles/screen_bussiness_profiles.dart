import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/businessProfilecontroller.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/utils.dart';
import 'package:ink/src/utils/utils_styles.dart';

import 'widget/search_business_user_widget.dart';
import 'widget/tatto_artist_card.dart';

class BusinessProfiles extends StatelessWidget {
  BusinessProfiles({Key? key}) : super(key: key);

  final BusinessProfileController controller =
      Get.put(BusinessProfileController());

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bgBlack,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            SizedBox(
              height: size.height * 0.01,
            ),
            SearchBusinessUserWidget(businessProfileController: controller),
            Expanded(
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
                              shrinkWrap: true,
                              itemCount: controller.businessList.length + 1,
                              itemBuilder: (context, index) {
                                if (index < controller.businessList.length) {
                                  return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: TattooArtistCard(
                                          businessUserListModel:
                                              controller.businessList[index]));
                                } else {
                                  return Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Obx(() => Center(
                                        child: controller
                                                .hasMoreBusinessProfileLoading
                                                .value
                                            ? const CircularProgressIndicator()
                                            : const SizedBox())),
                                  );
                                }
                              },
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
