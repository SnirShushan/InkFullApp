import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/data/source/network/firebase_api.dart';
import 'package:ink/src/ui/screen/collections/collection_view.dart';
import 'package:ink/src/ui/screen/profile/drawer/controller/business_profile_menu_controller.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/utils_styles.dart';
import 'package:ink/src/utils/webService.dart';

import '../../../../../controller/userController.dart';

class CollectionListWidget extends StatelessWidget {
  final BusinessProfileMenuController businessProfileMenuController;
  final String currentUserType;

  CollectionListWidget(
      {super.key,
      required this.businessProfileMenuController,
      required this.currentUserType});

  final UserController userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('folders')
            .where('uid', isEqualTo: userController.firebaseId.value)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
          if (snapshot.hasError) {
            return SizedBox(
              height: size.height * 0.22,
              child: Center(
                  child: Text('alerts.something_went_wrong',
                          style: bigBoldWhiteStyle)
                      .tr()),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            // return SizedBox(
            //   height: size.height * 0.15,
            //   child: Center(
            //       child: const Text(
            //     "alerts.no_folder",
            //     style: TextStyle(
            //         color: titleTextWhiteColor,
            //         fontSize: 18,
            //         fontWeight: FontWeight.w700),
            //   ).tr()),
            // );
            return const SizedBox.shrink();
          }

          return SizedBox(
            height: size.height * 0.22,
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                final imageData = document["image_url"];

                bool isMultiImage = imageData is String &&
                    imageData.contains(',') &&
                    imageData.startsWith('[') &&
                    imageData.endsWith(']');

                if (document["image_url"] == "") {
                  FireBaseApi.getRandomImageUrlFromFoldersImages(
                          document["fid"])
                      .then((value) async {
                    if (value != null) {
                      final updateFolder = FirebaseFirestore.instance
                          .collection("folders")
                          .doc(document["fid"]);
                      await updateFolder.update({"image_url": value});
                    }
                  });
                }
                return GestureDetector(
                  onTap: () => Get.to(CollectionView(
                    currentUserType: currentUserType,
                    fid: document["fid"],
                    fName: document["fname"],
                    imageUrls: document["image_url"] ?? "",
                  )),
                  // onTap: () => Get.to(() => FolderImages(
                  //     fname: document["fname"], fid: document["fid"])),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: size.height * 0.15,
                              width: size.height * 0.15,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: CachedNetworkImage(
                                  alignment: Alignment.center,
                                  imageUrl: FireBaseApi().getFirstImageUrl(
                                          document["image_url"]) ??
                                      WebService.tempImageUrl,
                                  fit: BoxFit.cover,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          SizedBox(
                                    height: size.height * 0.1,
                                    width: size.height * 0.1,
                                    child: Center(
                                        child: CircularProgressIndicator(
                                            value: downloadProgress.progress)),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        image: DecorationImage(
                                            image: AssetImage(
                                                AppAssets.galleryPlaceholder),
                                            fit: BoxFit.cover)),
                                  ),
                                ),
                              ),
                            ),
                            if (isMultiImage)
                              Positioned(
                                top: 10,
                                right: 10,
                                child: SvgPicture.asset(
                                    AppAssets.multiImageicon,
                                    width: 20,
                                    height: 20),
                              )
                          ],
                        ),
                        SizedBox(height: size.height * 0.02),
                        Text(document["fname"],
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                    fontSize: 16,
                                    color: dividerGray,
                                    fontWeight: FontWeight.w400))
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        });
  }
}
