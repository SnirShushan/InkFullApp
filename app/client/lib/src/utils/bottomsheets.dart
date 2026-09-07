//save dailog
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/userController.dart';
import 'package:ink/src/data/model/postDetails.dart';
import 'package:ink/src/data/source/network/firebase_api.dart';
import 'package:ink/src/ui/widgets/button/app_button.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/styles.dart';
import 'package:ink/src/utils/utils.dart';
import 'package:ink/src/utils/webService.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ui/screen/collections/new_collection.dart';
import 'colors.dart';
import 'common.dart';

//bookmark post
showBookmarkBottomSheet({size, context, fNameController, pid, imageId, url}) =>
    () {
      final userController = Get.put(UserController());
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter state) {
                return FractionallySizedBox(
                  heightFactor: 0.7,
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          width: size.width,
                          padding: EdgeInsets.all(size.height * 0.02),
                          decoration: BoxDecoration(
                              color: defaultWhite,
                              borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            'צור תיקייה',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: size.height * 0.02),
                          ),
                        ),
                        const Divider(),
                        Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('folders')
                                    .where('uid',
                                        isEqualTo:
                                            userController.firebaseId.value)
                                    .snapshots(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<QuerySnapshot<Object?>>
                                        snapshot) {
                                  if (snapshot.hasError) {
                                    return Center(
                                        child: const Text(
                                                'alerts.something_went_wrong')
                                            .tr());
                                  }

                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }

                                  final foldersList = snapshot.data!.docs;

                                  return foldersList.isEmpty
                                      ? Center(
                                          child: const Text("alerts.no_folder")
                                              .tr())
                                      : ListView.builder(
                                          itemCount: foldersList.length,
                                          shrinkWrap: true,
                                          itemBuilder: (_, index) {
                                            WebService.printMsg("foldersList");
                                            WebService.printMsg(
                                                foldersList[index]["uid"]);
                                            WebService.printMsg(userController
                                                .firebaseId.value);

                                            return Padding(
                                              padding: EdgeInsets.all(
                                                  size.width * 0.02),
                                              child: ListTile(
                                                  onTap: () async {
                                                    Get.back();
                                                    await FireBaseApi
                                                        .addFolderImage(
                                                            fid: foldersList[
                                                                index]["fid"],
                                                            pid: pid,
                                                            imageId: imageId,
                                                            fimageUrl: url,
                                                            folderName:
                                                                foldersList[
                                                                        index]
                                                                    ["fname"]);
                                                  },
                                                  title: Text(foldersList[index]
                                                      ["fname"]),
                                                  leading: foldersList[index]
                                                              ["image_url"] ==
                                                          ""
                                                      ? ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child: Image.asset(
                                                            "assets/images/placeholder.png",
                                                            height: size.width *
                                                                0.2,
                                                            width: size.width *
                                                                0.2,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        )
                                                      : ClipRRect(
                                                          child: buildCachedNetworkImage(
                                                              height:
                                                                  size.width *
                                                                      0.2,
                                                              width:
                                                                  size.width *
                                                                      0.2,
                                                              url: foldersList[
                                                                      index]
                                                                  ["image_url"],
                                                              radius: 10),
                                                        )),
                                            );
                                          });
                                })),
                        const Divider(),
                        buildContainer(
                            isAdd: true,
                            onClick: showAddNewFolder(
                                context: context,
                                controller: fNameController,
                                pid: pid,
                                imageId: imageId,
                                size: size,
                                fimageUrl: url),
                            size: size,
                            text: "צור תיקייה",
                            imgUrl: "assets/icons/ic_multi_add.png",
                            color: Colors.white),
                      ],
                    ),
                  ),
                );
              },
            );
          });
    };

buildContainer(
        {required isAdd,
        required size,
        required text,
        required imgUrl,
        required color,
        required onClick}) =>
    InkWell(
      onTap: onClick,
      child: Container(
        width: size.width,
        padding: EdgeInsets.symmetric(
            horizontal: size.height * 0.05, vertical: size.height * 0.01),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment:
              isAdd ? MainAxisAlignment.center : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: size.width * 0.15,
              height: size.width * 0.15,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: isAdd
                  ? Image.asset(imgUrl)
                  : CachedNetworkImage(
                      imageUrl: imgUrl ?? WebService.tempImageUrl,
                      imageBuilder: (context, imageProvider) => Container(
                        height: size.width * 0.25,
                        width: size.width * 0.25,
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
            ),
            SizedBox(width: size.width * 0.05),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: size.height * 0.02),
            ),
          ],
        ),
      ),
    );

//add new folder
showAddNewFolder({context, size, controller, pid, imageId, fimageUrl}) => () {
      showModalBottomSheet<dynamic>(
          useRootNavigator: true,
          isScrollControlled: true,
          context: context,
          builder: (BuildContext ctx) {
            return SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(ctx).viewInsets.bottom),
                  child: Container(
                    decoration: const BoxDecoration(
                        color: appbarBg,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16))),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: size.height * 0.1),
                          fimageUrl == ""
                              ? const SizedBox()
                              : buildCachedNetworkImage(
                                  height: size.height * 0.2,
                                  width: size.height * 0.2,
                                  url: fimageUrl,
                                  radius: 20),
                          SizedBox(height: size.height * 0.05),
                          Padding(
                            padding: EdgeInsets.all(Get.size.width * 0.1),
                            child: TextFormField(
                                autofocus: false,
                                controller: controller,
                                validator: (str) {
                                  if (str == null || str.isEmpty) {
                                    return "השם לא יכול להיות ריק"; //name cannot be empty
                                  }
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.all(0.0),
                                    filled: true,
                                    focusColor: defaultWhite,
                                    hintText: "שם לתיקייה")),
                          ),
                          SizedBox(height: size.height * 0.05),
                          ElevatedButton(
                            onPressed: () async {
                              if (controller.text == "") {
                                displayMessageIcon(
                                    message: "השם לא יכול להיות ריק",
                                    color: errorColor,
                                    snackposition: SnackPosition.BOTTOM,
                                    imageData: AppAssets.errorIcon);

                                return;
                              }

                              if (fimageUrl == "") {
                                await FireBaseApi.createFolder(
                                        name: controller.text.toString().trim(),
                                        fImageUrl: fimageUrl.toString())
                                    .then((value) {
                                  if (!Utils.isDataEmpty(value) &&
                                      value != false) {
                                    controller.text = "";
                                    Get.back();
                                  }
                                });
                              } else {
                                await FireBaseApi.createFolder(
                                        name: controller.text.toString().trim(),
                                        fImageUrl: fimageUrl.toString())
                                    .then((value) async {
                                  if (!Utils.isDataEmpty(value) &&
                                      value != false) {
                                    await FireBaseApi.addFolderImage(
                                            fid: value,
                                            pid: pid,
                                            imageId: imageId,
                                            fimageUrl: fimageUrl,
                                            folderName: controller.text
                                                .toString()
                                                .trim())
                                        .then((value) {
                                      controller.text = "";
                                      Navigator.of(context).pop();
                                    });
                                  }
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: defaultAppColor,
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.1)),
                            child: const Text("btn.save").tr(),
                          )
                        ]),
                  )),
            );
          });
    };

///new design
//custom bottom sheet
buildCommonBottomShit(
        {required BuildContext context,
        required Widget child,
        double? height,
        required bool isBtnView,
        required String btnTitle}) =>
    showModalBottomSheet<dynamic>(
        useRootNavigator: true,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext bc) {
          final size = MediaQuery.sizeOf(context);

          return FractionallySizedBox(
            heightFactor: height ?? 0.7,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              child: Scaffold(
                  appBar: AppBar(
                      automaticallyImplyLeading: false,
                      title: buildDrawerBtn(),
                      centerTitle: true,
                      toolbarHeight: size.height * 0.05),
                  backgroundColor: signInButtonColor,
                  bottomSheet: isBtnView
                      ? GradientButton(
                          onPressed: () {},
                          borderRadius: 20,
                          child: Text(
                            btnTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFEAE7EE),
                              fontSize: 16,
                              fontFamily: 'Arimo',
                              fontWeight: FontWeight.w500,
                              height: 0.08,
                            ),
                          ))
                      : null,
                  body: child),
            ),
          );
        });

buildDrawerBtn() => InkWell(
    onTap: () => Get.back(),
    child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: const SizedBox(
          height: 8,
          width: 48,
          child: ColoredBox(color: Color(0xFF56525A)),
        )));

//show image and collection crete option
showAddCollectionDialog(
    {required BuildContext context, required MPostDetails postModel}) {
  var size = MediaQuery.of(context).size;
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
                            borderRadius: BorderRadius.circular(
                                10.0), // Adjust the radius as needed
                          ),
                        ),
                      ))),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  //  SizedBox(width: 10),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Text(
                      'שמירת התמונה באוסף',
                      // 'שמרת התמונה באוסף',
                      style:
                          TextStyle(color: titleTextWhiteColor, fontSize: 18),
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(postModel.imageName!),
                        // 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQHUuFkQRfJ9ZF3zW2C6wJT3nfHBvIGswq0iw&s'), // replace with your image URL
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              buildDetailBtnSubmit(
                  onPressed: () async {
                    Get.back();
                    Get.to(() => CreateNewCollection(
                        postModel: postModel,
                        isRenameEnabled: false,
                        imagePath: postModel.imageName!,
                        name: null,
                        fid: null));
                    // showBottomSheetNewBoard(
                    //     context: context, postModel: postModel);
                  },
                  context: context,
                  size: size,
                  text: "+ אוסף חדש"),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.08,
              )
            ],
          ),
        );
      });
}

//new collection
// showBottomSheetNewBoard(
//     {required BuildContext context,
//     required MPostDetails? postModel,
//     String? name,
//     String? fid,
//     bool? isRenameEnabled}) {
//   return showModalBottomSheet<dynamic>(
//       useRootNavigator: true,
//       isScrollControlled: true,
//       context: context,
//       builder: (BuildContext context) {
//         return CreateNewCollection(
//             postModel: postModel,
//             isRenameEnabled: isRenameEnabled,
//             name: name,
//             fid: fid);
//       });
// }

buildDetailBtnSubmit(
        {required BuildContext context,
        required VoidCallback onPressed,
        required Size size,
        required text}) =>
    InkWell(
      onTap: onPressed,
      child: Container(
        width: (size.width) - 20,
        height: 52,
        //size.height * 0.07,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          gradient: LinearGradient(
            begin: Alignment.centerRight, // For RTL, start from right
            end: Alignment.centerLeft, // For RTL, end at left
            colors:
                // aboutTextController.text.isNotEmpty
                //     ?
                [
              linearGradieantColor1,
              linearGradieantColor2,
              linearGradieantColor3,
            ],
            //     :
            // colors: [
            //   lineargrayGradieantColor1,
            //   lineargrayGradieantColor2,
            //   lineargrayGradieantColor3,
            // ],
            stops: [0.0, 0.001, 0.8937],
          ),
        ),
        child: Text(
          text,
          // "+ אוסף חדש",
          // style: Theme.of(context).textTheme.titleMedium?.copyWith(
          //     color: aboutTextController.text.isEmpty ? defaultGrey : kWhite,
          //     fontWeight: FontWeight.w700),
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: kWhite, fontWeight: FontWeight.w500),
        ),
      ),
    );
