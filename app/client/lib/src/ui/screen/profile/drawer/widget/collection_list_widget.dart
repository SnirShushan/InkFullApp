import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/data/source/network/firebase_api.dart';
import 'package:ink/src/ui/screen/collections/collection_view.dart';
import 'package:ink/src/ui/screen/profile/drawer/controller/business_profile_menu_controller.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/webService.dart';

import '../../../../../controller/userController.dart';

class CollectionListWidget extends StatefulWidget {
  final BusinessProfileMenuController businessProfileMenuController;
  final String currentUserType;

  const CollectionListWidget(
      {super.key,
      required this.businessProfileMenuController,
      required this.currentUserType});

  @override
  State<CollectionListWidget> createState() => _CollectionListWidgetState();
}

class _CollectionListWidgetState extends State<CollectionListWidget> {
  final UserController userController = Get.put(UserController());

  @override
  void initState() {
    super.initState();
    if (_folderUid().isEmpty) {
      userController.initUser();
    }
  }

  String _folderUid() {
    final fromUser = userController.firebaseId.value.trim();
    if (fromUser.isNotEmpty && fromUser != "null") return fromUser;
    return FirebaseAuth.instance.currentUser?.uid ?? "";
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Obx(() {
      final uid = _folderUid();
      if (uid.isEmpty) {
        return const SizedBox.shrink();
      }

      return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('folders')
              .where('uid', isEqualTo: uid)
              .snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
            if (snapshot.hasError ||
                snapshot.connectionState == ConnectionState.waiting ||
                !snapshot.hasData ||
                snapshot.data!.docs.isEmpty) {
              return const SizedBox.shrink();
            }

            return SizedBox(
              height: size.height * 0.22,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  final data = document.data() as Map<String, dynamic>? ?? {};
                  final imageData = data["image_url"]?.toString() ?? "";
                  final fid = data["fid"]?.toString() ?? document.id;
                  final fname = data["fname"]?.toString() ?? "";

                  bool isMultiImage = imageData.contains(',') &&
                      imageData.startsWith('[') &&
                      imageData.endsWith(']');

                  if (imageData.isEmpty && fid.isNotEmpty) {
                    FireBaseApi.getRandomImageUrlFromFoldersImages(fid)
                        .then((value) async {
                      if (value != null) {
                        final updateFolder = FirebaseFirestore.instance
                            .collection("folders")
                            .doc(fid);
                        await updateFolder.update({"image_url": value});
                      }
                    });
                  }
                  return GestureDetector(
                    onTap: () => Get.to(CollectionView(
                      currentUserType: widget.currentUserType,
                      fid: fid,
                      fName: fname,
                      imageUrls: imageData,
                    )),
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
                                            imageData) ??
                                        WebService.tempImageUrl,
                                    fit: BoxFit.cover,
                                    progressIndicatorBuilder:
                                        (context, url, downloadProgress) =>
                                            SizedBox(
                                      height: size.height * 0.1,
                                      width: size.height * 0.1,
                                      child: Center(
                                          child: CircularProgressIndicator(
                                              value:
                                                  downloadProgress.progress)),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16),
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
                          Text(fname,
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
    });
  }
}
