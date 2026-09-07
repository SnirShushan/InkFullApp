import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/data/model/folderImage.dart';
import 'package:ink/src/data/model/postDetails.dart';
import 'package:ink/src/data/source/network/firebase_api.dart';
import 'package:ink/src/ui/screen/home/imageDetails/post_details.dart';
import 'package:ink/src/ui/widgets/appbar_action_widget.dart';
import 'package:ink/src/ui/widgets/bottomenu/business_dashboard_bottomenu.dart';
import 'package:ink/src/ui/widgets/bottomenu/dashboard_bottomenu.dart';
import 'package:ink/src/utils/webService.dart';

import '../../../utils/assets.dart';
import '../../../utils/colors.dart';
import 'edit_collection.dart';
import 'new_collection.dart';

class CollectionView extends StatelessWidget {
  final currentUserType;
  final String fName;
  final String imageUrls;
  final String fid;
  final bool isback2time;

  const CollectionView(
      {Key? key,
      required this.fName,
      required this.fid,
      required this.imageUrls,
      required this.currentUserType,
      this.isback2time = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bgBlack,
      appBar: AppBarActionButtonWidget(
          onBackPressed: () {
            if (isback2time == true) {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pop();
            }
          },
          title: fName.toString(),
          onPressed: () =>
              _showBottomSheet(context, fid, fName, currentUserType, imageUrls),
          iconName: AppAssets.dots3Icon),
      bottomNavigationBar: currentUserType == "2"
          ? BusinessDashboardBottomBar(
              currentIndex: 4,
            )
          : DashboardBottomBar(currentIndex: 3),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ImageGridScreen(
            fid: fid,
            currentUserType: currentUserType,
            fName: fName,
            imageUrls: imageUrls),
      ),
    );
  }
}

_showBottomSheet(BuildContext context, String fid, String fName,
    currentUserType, imageUrls) {
  return showModalBottomSheet<dynamic>(
      useRootNavigator: true,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
              color: signInButtonColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //back
              InkWell(
                  onTap: () => Get.back(),
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.03,
                          horizontal: MediaQuery.of(context).size.width * 0.4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Container(
                            margin: const EdgeInsetsDirectional.only(
                                start: 1.0, end: 1.0),
                            height: MediaQuery.of(context).size.height * 0.005,
                            width: MediaQuery.of(context).size.width * 0.2,
                            decoration: BoxDecoration(
                                color: kDivider,
                                borderRadius: BorderRadius.circular(10.0))),
                      ))),
              //rename collection
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => CreateNewCollection(
                      imagePath: imageUrls!,
                      postModel: MPostDetails(),
                      isRenameEnabled: true,
                      name: fName,
                      fid: fid));

                  // showBottomSheetNewBoard(
                  //     context: context,
                  //     postModel: MPostDetails(),
                  //     name: fName,
                  //     fid: fid,
                  //     isRenameEnabled: true);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  color: signInButtonColor,
                  height: MediaQuery.of(context).size.height * 0.07,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon(Icons.photo_outlined,
                      //     size: 24, color: titleTextWhiteColor),
                      SizedBox(width: 8),
                      Text("שינוי שם",
                          style: TextStyle(
                              color: titleTextWhiteColor, fontSize: 18)),
                    ],
                  ),
                ),
              ),
              //select & delete
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Get.to(EditCollection(
                      fid: fid, currentUserType: currentUserType));
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  color: signInButtonColor,
                  height: MediaQuery.of(context).size.height * 0.07,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon(Icons.photo_outlined,
                      //     size: 24, color: titleTextWhiteColor),
                      SizedBox(width: 8),
                      Text("סימון ועריכה",
                          style: TextStyle(
                              color: titleTextWhiteColor, fontSize: 18)),
                    ],
                  ),
                ),
              ),
              //delete collection
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  deleteCollectionAlertDialog(context, fid);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  color: signInButtonColor,
                  height: MediaQuery.of(context).size.height * 0.07,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(AppAssets.trashIcon, color: redtxtColor),
                      const SizedBox(width: 8),
                      const Text("מחיקת אוסף",
                          style: TextStyle(color: redtxtColor, fontSize: 18)),
                    ],
                  ),
                ),
              ),
              if (Platform.isAndroid)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.07,
                )
            ],
          ),
        );
      });
}

void deleteCollectionAlertDialog(BuildContext context, String fid) {
  var size = MediaQuery.of(context).size;
  bool isdeleteloading = false;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: signInButtonColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
        contentPadding: const EdgeInsets.all(20.0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: size.height * 0.01,
            ),
            const Text(
              "למחוק את האוסף?",
              // "למחוק את התמונות מהאוסף?",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: titleTextWhiteColor),
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
            const Text(
              "האוסף וכל התמונות שבו ימחקו ללא אפשרות שחזור.",
              // "התמונות שסומנו ימחקו\nמהאוסף ללא אפשרות שחזור.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: titleTextWhiteColor,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: styleBgColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: const Text("ביטול"),
                  onPressed: () {
                    // Add your delete action here
                    if (isdeleteloading == false) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                SizedBox(width: size.width * 0.02),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: errorColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: const Text("מחיקה"),
                  onPressed: () async {
                    if (isdeleteloading == false) {
                      isdeleteloading = true;
                      await FireBaseApi.deleteCollection(fid: fid)
                          .then((value) {
                        Future.delayed(const Duration(seconds: 1))
                            .then((value) {
                          isdeleteloading == false;
                          Navigator.pop(context);
                          Navigator.pop(context);
                        });
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

class ImageGridScreen extends StatelessWidget {
  final currentUserType;
  final String fName;
  final String imageUrls;
  final String fid;

  const ImageGridScreen(
      {Key? key,
      required this.fName,
      required this.fid,
      required this.imageUrls,
      required this.currentUserType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    Stream<List<FolderImage>> readPosts() => FirebaseFirestore.instance
        .collection('foldersImages')
        .snapshots()
        .map((snapshots) => snapshots.docs
            .map((doc) => FolderImage.fromJson(doc.data()))
            .where((doc) => doc.fid == fid)
            .toList());

    return StreamBuilder<List<FolderImage>>(
        stream: readPosts(),
        builder:
            (BuildContext context, AsyncSnapshot<List<FolderImage>> snapshot) {
          if (snapshot.hasError) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.04),
                Container(
                  padding: const EdgeInsets.all(16),
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    color: Color(0xFF211D25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cloud_off_outlined,
                      color: titleTextWhiteColor),
                ),
                SizedBox(height: size.height * 0.03),
                const Text(
                  "התיקייה ריקה",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: titleTextWhiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data!;
          WebService.folderList.clear();
          WebService.folderList = users;

          if (snapshot.data!.isEmpty) {
            FireBaseApi.removeImageFromSpecificFolders(fid: fid);
          }
          return snapshot.data!.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: size.height * 0.04),
                      Container(
                        padding: const EdgeInsets.all(16),
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          color: Color(0xFF211D25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.folder_off_outlined,
                            color: titleTextWhiteColor),
                      ),
                      SizedBox(height: size.height * 0.02),
                      const Text(
                        'אין פוסטים להצגה כאן',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: titleTextWhiteColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Number of columns
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemCount: WebService.folderList.length,
                  itemBuilder: (context, index) {
                    final imageData = WebService.folderList[index].imageUrl;
                    bool isMultipleImages = imageData is String &&
                        imageData.contains(',') &&
                        imageData.startsWith('[') &&
                        imageData.endsWith(']');
                    return InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => PostDetails(
                                  postId: WebService.folderList[index].pId,
                                  foldersid: WebService.folderList[index].fid,
                                  fidCollection: fid,
                                  currentUserTypeCollection: currentUserType,
                                  fNameCollection: fName,
                                  isCollectionMultipleImages: isMultipleImages,
                                  imageUrlsCollection: imageUrls,
                                  isArtist: false))),
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                              width: size.width * 0.28,
                              imageUrl: FireBaseApi().getFirstImageUrl(
                                      WebService.folderList[index].imageUrl) ??
                                  WebService.tempImageUrl,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(
                                  width: Get.width * 0.9,
                                  height: Get.height * 0.5,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage(
                                              "assets/images/placeholder.png"),
                                          fit: BoxFit.cover)))
                              //   height: size.width * 0.1,
                              // width: size.width * 0.1,
                              ),
                          if (isMultipleImages)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: SvgPicture.asset(AppAssets.multiImageicon,
                                  width: 20, height: 20),
                            )
                        ],
                      ),
                    );
                  },
                );
        });
  }
}
