import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/userController.dart';
import 'package:ink/src/data/source/network/firebase_api.dart';
import 'package:ink/src/ui/screen/collections/widget/no_collection_widget.dart';
import 'package:ink/src/ui/widgets/appbar_action_widget.dart';
import 'package:ink/src/ui/widgets/bottomenu/business_dashboard_bottomenu.dart';
import 'package:ink/src/ui/widgets/bottomenu/dashboard_bottomenu.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';

import '../../../utils/common.dart';
import 'collection_view.dart';
import 'new_collection.dart';

class SavedCollection extends StatelessWidget {
  final String currentUserType;

  const SavedCollection({Key? key, required this.currentUserType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bgBlack,
      appBar: AppBarActionButtonWidget(
        title: "שמורים",
        onPressed: () => Get.to(const CreateNewCollection(
            postModel: null, isRenameEnabled: null, name: null, fid: null)),
        iconName: AppAssets.icPlusWhite,
      ),
      bottomNavigationBar: currentUserType == "2"
          ? BusinessDashboardBottomBar(
              currentIndex: 4,
            )
          : DashboardBottomBar(currentIndex: 3),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Expanded(child: TattooGridScreen(currentUserType: currentUserType)),
        ]),
      ),
    );
  }
}

class TattooGridScreen extends StatelessWidget {
  final String currentUserType;

  TattooGridScreen({super.key, required this.currentUserType});

  final UserController userController = Get.find<UserController>();

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
            return Center(
                child: const Text('alerts.something_went_wrong').tr());
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return NoCollectionWidget(
                size: size,
                onPressed: () => Get.to(const CreateNewCollection(
                    postModel: null,
                    isRenameEnabled: null,
                    name: null,
                    fid: null)));
          }

          return GridView(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 0.88, //0.75,
                mainAxisSpacing: 10, //10.0,
                crossAxisSpacing: 10.0,
                crossAxisCount: 2,
                // mainAxisExtent: size.height * 0.22,
                // crossAxisSpacing: 3
              ),
              children: snapshot.data!.docs.map(
                (DocumentSnapshot document) {
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

                  return InkWell(
                    // onTap: () => Get.to(() => FolderImages(
                    //     fname: document["fname"], fid: document["fid"])),

                    onTap: () => Get.to(CollectionView(
                      imageUrls: document["image_url"] ?? "",
                      currentUserType: currentUserType,
                      fid: document["fid"],
                      fName: document["fname"],
                    )),

                    child: ImageCard(
                        imagePath: document["image_url"] ?? "",
                        title: document["fname"] ?? ""),
                  );
                },
              ).toList());
        });
  }
}

class ImageCard extends StatelessWidget {
  final String imagePath;
  final String title;

  ImageCard({required this.imagePath, required this.title});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    bool isMultipleImages = imagePath is String &&
        imagePath.contains(',') &&
        imagePath.startsWith('[') &&
        imagePath.endsWith(']');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: SizedBox(
        //  width: 160,
        height: 192,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Container(
            //   width: 60,
            //   height: 60,
            //   decoration: BoxDecoration(
            //     image: DecorationImage(
            //       image: NetworkImage(
            //           'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQHUuFkQRfJ9ZF3zW2C6wJT3nfHBvIGswq0iw&s'), // replace with your image URL
            //       fit: BoxFit.cover,
            //     ),
            //     borderRadius: BorderRadius.circular(8.0),
            //   ),
            // ),
            imagePath == "" || imagePath.isEmpty
                ? Image.asset(AppAssets.galleryPlaceholder,
                width: size.width * 0.4, fit: BoxFit.cover):Stack(
              children: [

                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: buildCachedNetworkImage2(
                      height: size.width * 0.4,
                      width: size.width * 0.4,
                      url: FireBaseApi().getFirstImageUrl(imagePath),
                      radius: size.width * 0.0),

                ),
                if (isMultipleImages)   Positioned(
                  top: 10,
                  right: 10,
                  child: SvgPicture.asset(
                      AppAssets.multiImageicon,
                      width: 20,
                      height:20
                  ),)
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                  color: titleTextWhiteColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
