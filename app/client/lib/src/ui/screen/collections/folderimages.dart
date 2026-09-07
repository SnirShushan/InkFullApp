import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/data/source/network/firebase_api.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/share_data.dart';

import '../../../controller/userController.dart';
import '../../../data/model/folderImage.dart';
import '../../../utils/colors.dart';
import '../../../utils/webService.dart';
import '../home/controller/post_details_controller.dart';
import '../home/imageDetails/post_details.dart';

class FolderImages extends StatefulWidget {
  final String fname;
  final String fid;

  const FolderImages({
    Key? key,
    required this.fname,
    required this.fid,
  }) : super(key: key);

  @override
  State<FolderImages> createState() => _FolderImagesState();
}

class _FolderImagesState extends State<FolderImages> {
  final TextEditingController fNameController = TextEditingController();
  final userController = Get.put(UserController());
  final postDetailsController = Get.put(PostDetailsController());

  Stream<List<FolderImage>> readPosts() => FirebaseFirestore.instance
      .collection('foldersImages')
      .snapshots()
      .map((snapshots) => snapshots.docs
          .map((doc) => FolderImage.fromJson(doc.data()))
          .where((doc) => doc.fid == widget.fid)
          .toList());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    //appbar
    appBar() => AppBar(
        elevation: 0,
        backgroundColor: appbarBg,
        leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios)),
        centerTitle: true,
        toolbarHeight: size.height * 0.1,
        foregroundColor: Colors.black,
        title: Text(widget.fname,
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: size.height * 0.02)));

    return Scaffold(
      appBar: appBar(), //sa
      body: StreamBuilder<List<FolderImage>>(
          stream: readPosts(),
          builder: (BuildContext context,
              AsyncSnapshot<List<FolderImage>> snapshot) {
            if (snapshot.hasError) {
              return Center(child: const Text("alerts.no_post_saved").tr());
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final users = snapshot.data!;
            WebService.folderList = users;
            return snapshot.data!.isEmpty
                ? const Center(child: Text(WebService.nothingDisplayMSG))
                : ListView.builder(
                    itemCount: WebService.folderList.length,
                    itemBuilder: (_, index) {
                      return buildPost(index);
                    },
                  );
          }), // ved posts
    );
  }

  Widget buildPost(int index) => Container(
        decoration: const BoxDecoration(color: Colors.transparent),
        child: GestureDetector(
          onTap: () => Get.to(() => PostDetails(
              postId: WebService.folderList[index].pId,
              foldersid: WebService.folderList[index].fid,
              isArtist: false)),
          child: Column(
            children: [
              //post image
              CachedNetworkImage(
                imageUrl: WebService.folderList[index].imageUrl ??
                    WebService.tempImageUrl,
                fit: BoxFit.fitWidth,
                width: Get.size.width,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              buildActions(context, index)
            ],
          ),
        ),
      );

  buildActions(BuildContext context, int index) => SizedBox(
        height: Get.size.height * 0.08,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: Get.size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: Get.size.width * 0.02),
                  //remove from gallery
                  TextButton(
                      onPressed: () async => buildDeleteDialog(
                          context,
                          () async => await FireBaseApi.removeFolderImage(
                                  postIndex: index,
                                  fid: WebService.folderList[index].fid,
                                  imageId: WebService.folderList[index].imageId)
                              .then((value) => Get.back())),
                      child: Row(
                        children: [
                          const Text("txt.remove").tr(),
                          SizedBox(width: Get.size.width * 0.01),
                          buildIconWidget(
                              isFill: false,
                              size: Get.size.width * 0.05,
                              iconPath: "ic_delete.png",
                              afterTapIcon: "ic_delete.png",
                              onClick: () {}),
                        ],
                      )),

                  SizedBox(
                      height: Get.size.height * 0.04,
                      child: const VerticalDivider(thickness: 2)),

                  //share
                  TextButton(
                      onPressed: () async => await ShareData.sharePost(
                          userid: postDetailsController.postModel.value.id??"",
                          context: context,
                          imageUrl: WebService.folderList[index].imageUrl),
                      child: Obx(() =>
                          postDetailsController.isShareLoading.value
                              ? SizedBox(
                                  height: Get.width * 0.08,
                                  width: Get.width * 0.08,
                                  child: const CircularProgressIndicator())
                              : Row(
                                  children: [
                                    const Text("txt.share").tr(),
                                    buildIconWidget(
                                        isFill: false,
                                        size: Get.size.width * 0.05,
                                        iconPath: "ic_share.png",
                                        afterTapIcon: "ic_share_fill.png",
                                        onClick: () {}),
                                  ],
                                ))),
                  SizedBox(width: Get.size.width * 0.02),
                ],
              ),
            ),
            SizedBox(
                width: Get.size.width * 0.9, child: const Divider(thickness: 2))
          ],
        ),
      );
}
