import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/userController.dart';
import 'package:ink/src/data/source/network/firebase_api.dart';
import 'package:ink/src/ui/widgets/bottomenu/business_dashboard_bottomenu.dart';
import 'package:ink/src/ui/widgets/bottomenu/dashboard_bottomenu.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/webService.dart';

import '../../../utils/assets.dart';

class EditCollection extends StatefulWidget {
  final String fid, currentUserType;

  const EditCollection(
      {Key? key, required this.fid, required this.currentUserType})
      : super(key: key);

  @override
  State<EditCollection> createState() => _EditCollectionState();
}

class _EditCollectionState extends State<EditCollection> {
  final List<String> selectedImages = [];
  final UserController userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bgBlack,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: scaffoldBg,
        title: Row(
          children: [
            IconButton(
                icon: SvgPicture.asset(
                  AppAssets.closeIcon,
                  color: titleTextWhiteColor,
                  height: 20,
                  width: 20,
                ),
                onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
      bottomNavigationBar: widget.currentUserType == "2"
          ? BusinessDashboardBottomBar(
              currentIndex: 4,
            )
          : DashboardBottomBar(currentIndex: 3),
      body: Stack(
        children: [
          Padding(
              padding: const EdgeInsets.all(16),
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('folders')
                      .where('uid', isEqualTo: userController.firebaseId.value)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                    return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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

                          final image = WebService.folderList[index];
                          final isSelected =
                              selectedImages.contains(image.imageId);

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedImages.remove(image.imageId);
                                } else {
                                  selectedImages.add(image.imageId);
                                }
                              });
                            },
                            child: Stack(
                              children: [
                                Positioned.fill(
                                    child: ColorFiltered(
                                        colorFilter: isSelected
                                            ? ColorFilter.mode(
                                                Colors.black.withOpacity(0.5),
                                                // Adjust the opacity as needed
                                                BlendMode.srcATop)
                                            : const ColorFilter.mode(
                                                Colors.transparent,
                                                BlendMode.multiply),
                                        child: CachedNetworkImage(
                                            imageUrl: FireBaseApi().getFirstImageUrl(
                                                WebService.folderList[index].imageUrl) ??
                                                WebService.tempImageUrl,
                                            errorWidget: (context, url,
                                                    error) =>
                                                Container(
                                                    width: size.width * 0.9,
                                                    height: size.height * 0.5,
                                                    alignment: Alignment.center,
                                                    decoration: const BoxDecoration(
                                                        image: DecorationImage(
                                                            image: AssetImage(
                                                                "assets/images/placeholder.png"),
                                                            fit:
                                                                BoxFit.cover))),
                                            fit: BoxFit.cover))),
                                if (isSelected)
                                  Positioned(
                                      top: 2,
                                      right: 2,
                                      child: SvgPicture.asset(
                                          AppAssets.checkedCircleFilledIcon,
                                          color: titleTextWhiteColor))
                                else
                                  Positioned(
                                      top: 2,
                                      right: 2,
                                      child: SvgPicture.asset(AppAssets.circle))
                              ],
                            ),
                          );
                        });
                  })),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: size.width,
              padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.02, horizontal: size.width * 0.02),
              color: signInButtonColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${selectedImages.length} תמונות נבחרו ',
                    style: const TextStyle(
                        color: titleTextWhiteColor, fontSize: 16),
                  ),
                  SizedBox(
                      height: 44,
                      width: size.width * 0.3,
                      child: ElevatedButton.icon(
                          onPressed: () {
                            if (selectedImages.isNotEmpty) {
                              showCustomAlertDialog(context, selectedImages);
                            }
                            // setState(() {
                            //   selectedImages.clear();
                            //
                            // });
                          },
                          icon:
                              SvgPicture.asset(AppAssets.trashIcon, height: 20),
                          label: const Text('מחיקה',
                              style: TextStyle(color: titleTextWhiteColor)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: styleBgColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))))),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void showCustomAlertDialog(
      BuildContext context, List<String> selectedImages) {
    var size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          alignment: Alignment.center,
          backgroundColor: signInButtonColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          contentPadding: const EdgeInsets.all(16.0),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: size.height * 0.01,
              ),
              const Text(
                "למחוק את התמונות מהאוסף?",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: titleTextWhiteColor),
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
              const Text(
                "התמונות שסומנו ימחקו\nמהאוסף ללא אפשרות שחזור.",
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
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 44,
                    width: size.width * 0.28,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: styleBgColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child: const FittedBox(child: Text("ביטול")),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  SizedBox(width: size.width * 0.02),
                  SizedBox(
                    height: 44,
                    width: size.width * 0.28,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: errorColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child: const FittedBox(child: Text("מחיקה")),
                      onPressed: () async {
                        for (int i = 0; i < selectedImages.length; i++) {
                          await FireBaseApi.deleteImage(
                              fid: widget.fid, imageId: selectedImages[i]);
                        }

                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),

                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
