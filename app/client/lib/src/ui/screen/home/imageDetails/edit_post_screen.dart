import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ink/src/controller/artistsListController.dart';
import 'package:ink/src/controller/userController.dart';
import 'package:ink/src/data/model/MultiPost.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/data/model/image_model.dart';
import 'package:ink/src/data/model/postDetails.dart';
import 'package:ink/src/data/source/network/firebase_api.dart';
import 'package:ink/src/ui/screen/home/controller/post_details_controller.dart';
import 'package:ink/src/ui/screen/sendTattoRquest/widget/dashed_border_widget.dart';
import 'package:ink/src/ui/widgets/multiple_post_image_widget.dart';
import 'package:ink/src/ui/widgets/unfocus_widget.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/permissions.dart';
import 'package:ink/src/utils/utils.dart';
import 'package:ink/src/utils/webService.dart';

class EditPostScreen extends StatefulWidget {
  final MPostDetails postModel;

  const EditPostScreen({super.key, required this.postModel});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen>
    with SingleTickerProviderStateMixin {
  bool secondScreenVisible = true;
  bool thirdScreenVisible = false;
  UploadTask? uploadTask;

  List<StylesList> listStyles = [];
  List<StylesList> filteredListStyles = [];
  List<StylesList> selectedList = [];
  List<String> selectedMemberList = [];
  late AppUser user;

  final artistController = Get.put(ArtistListController());

  TextEditingController aboutTextController = TextEditingController();
  TextEditingController searchTxtController = TextEditingController();
  TextEditingController searchUserTxtController = TextEditingController();

  Future getArtists() async => await artistController.getArtists();
  bool isSearched = false;
  late AnimationController animationController;
  late Animation<double> base;
  final postDetailController = Get.put(PostDetailsController());

  //images
  bool isImageSelected1 = false;
  bool isImageSelected2 = false;
  bool isImageSelected3 = false;
  File imageFile1 = File("");
  File imageFile2 = File("");
  File imageFile3 = File("");

  String imageUrl1 = "";
  String imageUrl2 = "";
  String imageUrl3 = "";

  String imageId1 = "";
  String imageId2 = "";
  String imageId3 = "";

  String tempImageUrl1 = "";
  String tempImageUrl2 = "";
  String tempImageUrl3 = "";

  List<File> imageFilesList = [];
  List<RequestImages> uploadedImages = [];
  final List<String> existingUrls = [];
  final List<String> existingIds = [];
  String finalImageUrls = '';
  String finalImageIds = '';

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    base = CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    if (widget.postModel.artistUid != "") {
      selectedMemberList.add(widget.postModel.artistUid!);
    }

    if (widget.postModel.isMultipleImages == "1") {
      final raw = widget.postModel.imageName;

      if (raw is String && raw.isNotEmpty) {
        // Remove [ and ]
        final cleaned = raw.replaceAll('[', '').replaceAll(']', '');

        final imageList = cleaned
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        if (imageList.length > 0) imageUrl1 = imageList[0];
        if (imageList.length > 1) imageUrl2 = imageList[1];
        if (imageList.length > 2) imageUrl3 = imageList[2];

        if (imageList.length > 0) tempImageUrl1 = imageList[0];
        if (imageList.length > 1) tempImageUrl2 = imageList[1];
        if (imageList.length > 2) tempImageUrl3 = imageList[2];
      }
    } else {
      final raw = widget.postModel.imageName;

      if (raw is String && raw.isNotEmpty) {
        // Remove [ and ]
        final cleaned = raw.replaceAll('[', '').replaceAll(']', '');

        // Otherwise, assign safely
        imageUrl1 = cleaned;
        tempImageUrl1 = cleaned;
      }
    }

    if (widget.postModel.isMultipleImages == "1") {
      final raw = widget.postModel.imageId;

      if (raw is String && raw.isNotEmpty) {
        // Remove [ and ]
        final cleaned = raw.replaceAll('[', '').replaceAll(']', '');

        // Split into list and trim each item
        final imageIdList = cleaned
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        if (imageIdList.length > 0) imageId1 = imageIdList[0];
        if (imageIdList.length > 1) imageId2 = imageIdList[1];
        if (imageIdList.length > 2) imageId3 = imageIdList[2];
      }
    } else {
      final raw = widget.postModel.imageId;

      if (raw is String && raw.isNotEmpty) {
        // Remove [ and ]
        final cleaned = raw.replaceAll('[', '').replaceAll(']', '');

        // Otherwise, assign safely
        imageId1 = cleaned;
        tempImageUrl1 = cleaned;
      }
    }

    aboutTextController.text = widget.postModel.description!;
    getUserStyles();
    getArtists();
    // getAllData();
  }

  // Future<void> getAllData() async {
  //   await getAllImagesByUid("2");
  // }
  //
  // Future<void> getAllImagesByUid(String uid) async {
  //   final firestore = FirebaseFirestore.instance;
  //
  //   // Query Firestore for all docs with this UID
  //   final querySnapshot =
  //       await firestore.collection('images').where('uid', isEqualTo: uid).get();
  //
  //   if (querySnapshot.docs.isEmpty) {
  //     print('No images found for uid: $uid');
  //     return;
  //   }
  //
  //   print('Found ${querySnapshot.docs.length} images for uid: $uid');
  //
  //   for (var doc in querySnapshot.docs) {
  //     print('ImageId (docId): ${doc.id}');
  //     print('Image URL: ${doc['imageUrl']}');
  //   }
  //
  //   // Optional: delete them all if you need
  //   // for (var doc in querySnapshot.docs) {
  //   //   await firestore.collection('images').doc(doc.id).delete();
  //   //   print('Deleted image: ${doc.id}');
  //   // }
  // }

  //get userStyles
  Future getUserStyles() async {
    user = await WebService.getCurrentUser();
    final selectedSlugs =
    widget.postModel.styles!.split(',').map((e) => e.trim()).toList();

    user.stylesList?.forEach((doc) {
      if (selectedSlugs.contains(doc.slug)) {
        selectedList.add(doc);
      }
      listStyles.add(doc);
    });
    user.stylesList?.map((doc) {
      filteredListStyles.add(doc);
    }).toList();

    setState(() {});
  }

  @override
  void dispose() {
    if (animationController.isAnimating) {
      animationController.stop();
    }
    animationController.dispose();
    aboutTextController.dispose();
    searchTxtController.dispose();
    searchUserTxtController.dispose();
    super.dispose();
  }

  //search styles
  searchQuery(query) {
    if (query.toString().length > 1) {
      var filterData = listStyles
          .where((e) => e.name.toString().toLowerCase().contains(query))
          .toList();
      setState(() {
        isSearched = true;
        listStyles = filterData;
      });
    } else if (query.toString().isEmpty) {
      setState(() {
        isSearched = false;
        listStyles = filteredListStyles;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;

    return UnFocusWidget(
        child: SafeArea(
          child: Scaffold(
            backgroundColor: bgBlack,
            body: secondScreenVisible
                ? Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: size.height * 0.03,
                      ),
                      buildTopBackRow(
                          textTheme: textTheme,
                          title: 'עריכת פוסט',
                          // title: 'סגנון הקעקוע',
                          onPressed: () => Get.back()),
                      SizedBox(
                        height: size.height * 0.03,
                      ),
                      buildTitleText20(
                          size, textTheme, 'ספר לנו על העבודה שלך'),
                      buildImageUpload(context, size, textTheme),
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      buildTitleText(
                          size, textTheme, widget.postModel.imgType == "1"
                          ? "באיזה סגנון הסקיצה?"
                          : "באיזה סגנון הקעקוע?"),
                      // buildTitleText(
                      //     size,
                      //     textTheme,
                      //     widget.postModel.imgType == "1"
                      //         ? 'באיזה סגנון הקעקוע?'
                      //         : 'איזה סטייל מתאים לעבודה הזו?'),
                      // size, textTheme, 'איזה סטייל מתאים לעבודה הזו?'),
                      Wrap(
                        spacing: 12.0,
                        runSpacing: 2.0,
                        verticalDirection: VerticalDirection.up,
                        children: listStyles.map((option) {
                          return ElevatedButton(
                            onPressed: () =>
                                setState(() {
                                  if (!selectedList.contains(option)) {
                                    if (selectedList.length < 3) {
                                      selectedList.add(option);
                                    } else {
                                      displayMessageIcon(
                                          message: 'ניתן לבחור עד 3 סגנונות.',
                                          color: errorColor,
                                          snackposition: SnackPosition.BOTTOM,
                                          imageData: AppAssets.errorIcon);
                                    }
                                  } else {
                                    selectedList.remove(option);
                                  }
                                }),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: selectedList.contains(option)
                                    ? 12.0
                                    : 22.0, // Adjust padding as needed
                                vertical: 12.0, // Adjust padding as needed
                              ),
                              backgroundColor: selectedList.contains(option)
                                  ? titleTextWhiteColor
                                  : bgBlack,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                side: BorderSide(
                                    color: selectedList.contains(option)
                                        ? titleTextWhiteColor
                                        : Colors.white), // Border color
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize
                                  .min, // Ensure the row takes up minimum space
                              children: [
                                if (selectedList
                                    .contains(option)) // Add icon if selected
                                  const Icon(
                                    Icons.check,
                                    color: bgBlack,
                                    size: 15,
                                  ),
                                if (selectedList.contains(option))
                                  const SizedBox(width: 4),
                                Text(
                                  option.name!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: selectedList.contains(option)
                                        ? bgBlack
                                        : titleTextWhiteColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16.0),
                      buildTitleText(size, textTheme, 'כמה מילים על הקעקוע'),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize
                            .min, // Make the Column shrink-wrap its children
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: signInButtonColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextFormField(
                              controller: aboutTextController,
                              minLines: 5,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              onTapOutside: (event) {
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              style: textTheme.titleMedium!.copyWith(
                                  color: titleTextWhiteColor,
                                  fontWeight: FontWeight.w400),
                              // Allows the text field to grow as the user types
                              decoration: const InputDecoration(
                                hintText:
                                'קעקוע מיוחד בצבע שחור בלבד, קווים דקים, עדין מאוד עבודה מדויקת ביותר',
                                hintStyle: TextStyle(
                                    color: placeholdertxtColor,
                                    fontSize: 15,
                                    fontFamily: 'Arimo',
                                    fontWeight: FontWeight.w400),
                                hintMaxLines: 2,
                                border: InputBorder.none,
                              ),
                              onChanged: (txt) {
                                aboutTextController.text = txt;
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Obx(() =>
                      (postDetailController.isEditPostLoading.value ==
                          true)
                          ? buildIsLoading(size)
                          : buildDetailBtnSubmit(context: context, size: size))
                    ],
                  ),
                ))
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: size.height * 0.03,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: size.width * 0.03,
                    ),
                    IconButton(
                        icon: SvgPicture.asset(
                          AppAssets.backarrowIcon,
                          color: titleTextColor,
                          height: 20,
                          width: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            // firstScreenVisible = false;
                            secondScreenVisible = true;
                            thirdScreenVisible = false;
                          });
                        }),
                    Text(
                      'תיוג המקעקע',
                      style: Theme
                          .of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(
                          color: titleTextColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                SizedBox(
                  height: size.height * 0.04,
                ),
                _buildSearchbar(size: size),
                Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: size.width * 0.04),
                  child: Text(
                    'המקעקעים בסטודיו:',
                    textAlign: TextAlign.center,
                    style: textTheme.titleSmall!.copyWith(
                      color: const Color(0xFF807C84),
                      fontWeight: FontWeight.w500,
                      height: 0.10,
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height * 0.04,
                ),
                Expanded(
                    flex: 1,
                    child: artistController.artistList.isEmpty
                        ? Center(
                        child: user.profile!.businessType == "1"
                            ? const Text("alerts.no_artist_found").tr()
                            : const Text("alerts.no_studio_found").tr())
                        : ListView.builder(
                        shrinkWrap: true,
                        itemCount: artistController.artistList.length,
                        itemBuilder: (BuildContext context, int index) {
                          final id = artistController
                              .artistList[index].profile!.id;
                          // WebService.printMsg(selectedMemberList.toString());
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  onTap: () =>
                                      setState(() {
                                        if (!selectedMemberList
                                            .contains(id)) {
                                          if (selectedMemberList
                                              .isEmpty) {
                                            selectedMemberList.add(id!);
                                          } else {
                                            selectedMemberList.clear();
                                            selectedMemberList.add(id!);
                                          }
                                        } else {
                                          selectedMemberList.clear();
                                        }
                                        WebService.printMsg(
                                            selectedMemberList
                                                .toString());
                                      }),
                                  selected:
                                  selectedMemberList.contains(id)
                                      ? true
                                      : false,
                                  selectedTileColor: purchasebgcolor,
                                  title: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                              width: size.width * 0.04),
                                          buildOwnerProfileImage(
                                              size: size,
                                              width: size.width * 0.14,
                                              ownerImage: artistController
                                                  .artistList[
                                              index]
                                                  .profile!
                                                  .profileImage! ==
                                                  ""
                                                  ? ""
                                                  : artistController
                                                  .artistList[index]
                                                  .profile!
                                                  .profileImage!),
                                          SizedBox(
                                              width: size.width * 0.015),
                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  artistController
                                                      .artistList[index]
                                                      .profile!
                                                      .name!,
                                                  style: textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                      color:
                                                      titleTextWhiteColor,
                                                      fontWeight:
                                                      FontWeight
                                                          .w700)),
                                              SizedBox(
                                                  height:
                                                  size.height * 0.01),
                                              SizedBox(
                                                width: size.width * 0.7,
                                                child: Text(
                                                  artistController
                                                      .artistList[index]
                                                      .profile!
                                                      .address!,
                                                  overflow:
                                                  TextOverflow.clip,
                                                  maxLines: 1,
                                                  style: textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                    color: lightGrayColor,
                                                    fontWeight:
                                                    FontWeight.w400,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                      if (selectedMemberList.contains(id))
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SvgPicture.asset(
                                              AppAssets.closeIcon,
                                            ),
                                            SizedBox(
                                                width: size.width * 0.04),
                                          ],
                                        ),
                                    ],
                                  )),
                              const Divider(),
                            ],
                          );
                        })),
                const Divider(),
                Obx(() =>
                    Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: InkWell(
                          onTap: () => updatePostDetail(context),
                          child: Container(
                            width: size.width,
                            height: size.height * 0.07,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(
                                  12)),
                              gradient: appLinearGradient,
                            ),
                            child: postDetailController.isEditPostLoading
                                .value ==
                                true
                                ? Center(
                                child: RotationTransition(
                                    turns: base,
                                    child: Image.asset(
                                      AppAssets.loadingIcon,
                                      color: Colors.white,
                                    )))
                                : Text(
                              "הבא",
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                  color: kWhite,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        )))
              ],
            ),
          ),
        ));
  }

  InkWell buildTopBackRow({required TextTheme textTheme,
    required String title,
    required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 4),
          SvgPicture.asset(
            AppAssets.backarrowIcon,
            color: titleTextColor,
            height: 20,
            width: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: textTheme.headlineSmall!
                .copyWith(color: titleTextColor, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  //appbar
  customAppBar(String title, BuildContext context, Size size,
      TextTheme textTheme) =>
      Container(
        color: defaultBlack,
        width: size.width,
        height: size.height * 0.1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Visibility(
              visible: false,
              child: InkWell(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.arrow_circle_right_sharp)),
            ),
            Text(
              title,
              style: textTheme.titleMedium!.copyWith(color: defaultWhite),
            ),
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.02),
              child: InkWell(
                onTap: () => Get.back(),
                child: const Icon(Icons.close_rounded, color: defaultWhite),
              ),
            ),
          ],
        ),
      );

  //image uploading progress
  buildProgress() =>
      StreamBuilder<TaskSnapshot>(
          stream: uploadTask?.snapshotEvents,
          builder: (context, snapshots) {
            final data = snapshots.data!;
            double progress = data.bytesTransferred / data.totalBytes;

            return SizedBox(
                height: 50,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey,
                        color: Colors.green),
                    Center(
                        child: Text(
                            'Please Wait..  ${(100 * progress)
                                .roundToDouble()} %',
                            style: const TextStyle(color: Colors.white)))
                  ],
                ));
          });

  //upload image to firebase
  // updatePostDetail(BuildContext context) async {
  //   setState(() {
  //     animationController.forward().whenComplete(() {
  //       animationController.repeat();
  //     });
  //   });
  //   postDetailController.isEditPostLoading.value = true;
  //   bool isConnected = await WebService.checkConnection2();
  //   String styleList = "";
  //   if (selectedList != null) {
  //     selectedList.forEach((v) {
  //       styleList += v == selectedList.last ? v.slug! : "${v.slug},";
  //     });
  //   }
  //   if(imageUrl1 =="" || imageUrl2==""||imageUrl3==""){
  //     await removePostFirebaseHandling();
  //
  //     String tempImageUrl = "";
  //     String tempImageId = "";
  //
  //
  //     if (uploadedImages.isNotEmpty) {
  //       if(imageUrl1 !=""){
  //         tempImageUrl+="$imageUrl1,";
  //         tempImageId+="$imageId1,";
  //       }
  //       if(imageUrl2 !=""){
  //         tempImageUrl+="$imageUrl2,";
  //         tempImageId+="$imageId2,";
  //       }
  //       if(imageUrl3 !=""){
  //         tempImageUrl+="$imageUrl3,";
  //         tempImageId+="$imageId3,";
  //       }
  //
  //       for (var image in uploadedImages) {
  //         // Assuming RequestImages has fields: name, imageUrl, uid
  //         tempImageUrl += "${image.imageUrl},";
  //         tempImageId += "${image.imageId},";
  //       }
  //       // Remove the last comma if needed
  //       if (tempImageUrl.endsWith(',')) {
  //         tempImageUrl = tempImageUrl.substring(0, tempImageUrl.length - 1);
  //       }
  //       if (tempImageId.endsWith(',')) {
  //         tempImageId = tempImageId.substring(0, tempImageId.length - 1);
  //       }
  //     }
  //     if (!isConnected) {
  //       return;
  //     } else {
  //       try {
  //         if (artistController.artistList.isNotEmpty) {
  //           postDetailController.updatePostController(
  //               imageNmae: tempImageUrl,
  //               imageId: tempImageId,
  //               context: context,
  //               styles: styleList,
  //               description: aboutTextController.text.toString(),
  //               postId: widget.postModel.id,
  //               artistId:
  //               selectedMemberList.isNotEmpty ? selectedMemberList[0] : "");
  //         } else {
  //           postDetailController.updatePostController(
  //               imageNmae:tempImageUrl,
  //               imageId: tempImageId,
  //               context: context,
  //               styles: styleList,
  //               description: aboutTextController.text.toString(),
  //               postId: widget.postModel.id);
  //         }
  //       } catch (e) {
  //         postDetailController.isEditPostLoading.value = false;
  //       } finally {
  //         if (animationController.isAnimating) {
  //           animationController.stop();
  //         }
  //       }
  //     }
  //   }else{
  //
  //
  //     if (!isConnected) {
  //       return;
  //     } else {
  //       try {
  //
  //
  //         if (artistController.artistList.isNotEmpty) {
  //           postDetailController.updatePostController(
  //               imageNmae: widget.postModel.imageName,
  //               imageId: widget.postModel.imageId,
  //               context: context,
  //               styles: styleList,
  //               description: aboutTextController.text.toString(),
  //               postId: widget.postModel.id,
  //               artistId:
  //               selectedMemberList.isNotEmpty ? selectedMemberList[0] : "");
  //         } else {
  //           postDetailController.updatePostController(
  //               imageNmae: widget.postModel.imageName,
  //               imageId: widget.postModel.imageId,
  //               context: context,
  //               styles: styleList,
  //               description: aboutTextController.text.toString(),
  //               postId: widget.postModel.id);
  //         }
  //       } catch (e) {
  //         postDetailController.isEditPostLoading.value = false;
  //       } finally {
  //         if (animationController.isAnimating) {
  //           animationController.stop();
  //         }
  //       }
  //     }
  //   }
  //
  //
  //
  //
  //
  // }

  Future<void> updatePostDetail(BuildContext context) async {
    setState(() {
      animationController
        ..forward().whenComplete(() => animationController.repeat());
    });

    postDetailController.isEditPostLoading.value = true;

    final bool isConnected = await WebService.checkConnection2();
    if (!isConnected) return;

    // Build style list
    final String styleList = selectedList != null && selectedList!.isNotEmpty
        ? selectedList!.map((v) => v.slug ?? '').join(',')
        : '';

    final bool hasRemovedImage =
        (imageUrl1.isEmpty && tempImageUrl1.isNotEmpty) ||
            (imageUrl2.isEmpty && tempImageUrl2.isNotEmpty) ||
            (imageUrl3.isEmpty && tempImageUrl3.isNotEmpty);

    final bool hasAddPostImage = (imageFile1.path.isNotEmpty ||
        imageFile2.path.isNotEmpty ||
        imageFile3.path.isNotEmpty);

    if (hasRemovedImage || hasAddPostImage) {
      await updatePostFirebaseHandling();
    } else {
      finalImageUrls = widget.postModel.imageName;
      finalImageIds = widget.postModel.imageId ?? "";
    }

    String cleanedImageUrl =
    finalImageUrls.replaceAll('[', '').replaceAll(']', '');
    String cleanedImageId =
    finalImageIds.replaceAll('[', '').replaceAll(']', '');
    try {
      await postDetailController.updatePostController(
        imageNmae: cleanedImageUrl,
        imageId: cleanedImageId,
        context: context,
        styles: styleList,
        description: aboutTextController.text.trim(),
        postId: widget.postModel.id,
        artistId: artistController.artistList.isNotEmpty &&
            selectedMemberList.isNotEmpty
            ? selectedMemberList.first
            : '',
      );
    } catch (e) {
      postDetailController.isEditPostLoading.value = false;
      debugPrint('Error updating post: $e');
    } finally {
      if (animationController.isAnimating) {
        animationController.stop();
      }
    }
  }

  _buildSearchbar({required Size size}) =>
      Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
        child: SizedBox(
          height: size.height * 0.1,
          child: TextFormField(
              autofocus: false,
              controller: searchUserTxtController,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.search,
              style: const TextStyle(color: titleTextWhiteColor),
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              decoration: InputDecoration(
                  hintStyle: const TextStyle(color: Color(0xFF6B676F)),
                  hintText: "חפשו את המקעקע/ת",
                  contentPadding: const EdgeInsets.all(8),
                  filled: true,
                  fillColor: socialoginbtn,
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  prefixIcon:
                  const Icon(Icons.search, color: titleTextWhiteColor),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)))),
        ),
      );

  // buildStyleBtnSubmit({required BuildContext context, required Size size}) =>
  //     InkWell(
  //       onTap: () {
  //         if (selectedList.isNotEmpty) {
  //           if (selectedList.length > 3) {
  //             displayMessageIcon(
  //                 message: 'ניתן לבחור עד 3 סגנונות.',
  //                 color: errorColor,
  //                 snackposition: SnackPosition.BOTTOM,
  //                 imageData: AppAssets.errorIcon);
  //           } else {
  //             setState(() {
  //               // firstScreenVisible = false;
  //               secondScreenVisible = true;
  //               thirdScreenVisible = false;
  //             });
  //           }
  //         }
  //       },
  //       child: Container(
  //         width: size.width,
  //         height: size.height * 0.07,
  //         alignment: Alignment.center,
  //         decoration: BoxDecoration(
  //           borderRadius: const BorderRadius.all(Radius.circular(12)),
  //           gradient: LinearGradient(
  //             begin: Alignment.centerRight, // For RTL, start from right
  //             end: Alignment.centerLeft, // For RTL, end at left
  //             colors: selectedList.isNotEmpty
  //                 ? [
  //                     linearGradieantColor1,
  //                     linearGradieantColor2,
  //                     linearGradieantColor3,
  //                   ]
  //                 : [
  //                     lineargrayGradieantColor1,
  //                     lineargrayGradieantColor2,
  //                     lineargrayGradieantColor3,
  //                   ],
  //             stops: const [0.0, 0.001, 0.8937],
  //           ),
  //         ),
  //         child: Text(
  //           "הבא",
  //           style: Theme.of(context).textTheme.titleMedium?.copyWith(
  //               color: selectedList.isEmpty ? defaultGrey : kWhite,
  //               fontWeight: FontWeight.w700),
  //         ),
  //       ),
  //     );

  buildDetailBtnSubmit({required BuildContext context, required Size size}) =>
      InkWell(
        onTap: () async {
          if (imageUrl1.isEmpty &&
              imageUrl2.isEmpty &&
              imageUrl3.isEmpty &&
              imageFile1.path.isEmpty &&
              imageFile2.path.isEmpty &&
              imageFile3.path.isEmpty) {
            return;
          } else if (selectedList.length == 0) {
            // if (selectedList.length > 3) {
            //   displayMessageIcon(
            //       message: 'ניתן לבחור עד 3 סגנונות.',
            //       color: errorColor,
            //       snackposition: SnackPosition.BOTTOM,
            //       imageData: AppAssets.errorIcon);
            // }
            FocusScope.of(context).unfocus();
            return;
          } else if (aboutTextController.text
              .trim()
              .isEmpty) {
            FocusScope.of(context).unfocus();
            return;
          } else {
            FocusScope.of(context).unfocus();
            final userController = Get.put(UserController());
            if (userController.businessType.value == "1" &&
                artistController.artistList.isNotEmpty) {
              setState(() {
                secondScreenVisible = false;
                thirdScreenVisible = true;
              });
            } else {
              await updatePostDetail(context);
            }
          }
        },
        child: Container(
          width: size.width,
          height: size.height * 0.07,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            gradient: LinearGradient(
              begin: Alignment.centerRight, // For RTL, start from right
              end: Alignment.centerLeft, // For RTL, end at left
              colors: imageUrl1.isEmpty &&
                  imageUrl2.isEmpty &&
                  imageUrl3.isEmpty &&
                  imageFile1.path.isEmpty &&
                  imageFile2.path.isEmpty &&
                  imageFile3.path.isEmpty
                  ? [
                lineargrayGradieantColor1,
                lineargrayGradieantColor2,
                lineargrayGradieantColor3,
              ]
                  : aboutTextController.text
                  .trim()
                  .isNotEmpty &&
                  selectedList.length != 0
                  ? [
                linearGradieantColor1,
                linearGradieantColor2,
                linearGradieantColor3,
              ]
                  : [
                lineargrayGradieantColor1,
                lineargrayGradieantColor2,
                lineargrayGradieantColor3,
              ],
              stops: const [0.0, 0.001, 0.8937],
            ),
          ),
          child: Text(
            // "הבא",
            // "שמירה",
            "שמירה",
            style: Theme
                .of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                color: imageUrl1.isEmpty &&
                    imageUrl2.isEmpty &&
                    imageUrl3.isEmpty &&
                    imageFile1.path.isEmpty &&
                    imageFile2.path.isEmpty &&
                    imageFile3.path.isEmpty
                    ? defaultGrey
                    : aboutTextController.text
                    .trim()
                    .isEmpty ||
                    selectedList.length == 0
                    ? defaultGrey
                    : kWhite,
                fontWeight: FontWeight.w700),
          ),
        ),
      );

  Align buildIsLoading(Size size) {
    return Align(
      alignment: Alignment.center,
      child: Container(
          width: size.width,
          height: size.height * 0.07,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            gradient: appLinearGradient,
          ),
          child: Center(
            child: RotationTransition(
                turns: base, child: Image.asset(AppAssets.loadingIcon)),
          )),
    );
  }

  buildImageUpload(BuildContext context, Size size, TextTheme textTheme) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.02),
          buildTitleText(size, textTheme, 'בחר את התמונות שתרצה להציג'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              isImageSelected1
                  ? buildImgRounded(size: size, type: "1", isUrls: false)
                  : imageUrl1 != ""
                  ? buildImgRounded(size: size, type: "1", isUrls: true)
                  : InkWell(
                  onTap: () => _showBottomSheet(context, 1),
                  // onTap: () => _pickImagefromGallery(type: 1),
                  child: builddotted(size)),
              isImageSelected2
                  ? buildImgRounded(size: size, type: "2", isUrls: false)
                  : imageUrl2 != ""
                  ? buildImgRounded(size: size, type: "2", isUrls: true)
                  : InkWell(
                  onTap: () => _showBottomSheet(context, 2),
                  // onTap: () => _pickImagefromGallery(type: 2),
                  child: builddotted(size)),
              isImageSelected3
                  ? buildImgRounded(size: size, type: "3", isUrls: false)
                  : imageUrl3 != ""
                  ? buildImgRounded(size: size, type: "3", isUrls: true)
                  : InkWell(
                  onTap: () => _showBottomSheet(context, 3),
                  // onTap: () => _pickImagefromGallery(type: 3),
                  child: builddotted(size)),
            ],
          )
        ],
      );

  _showBottomSheet(BuildContext context, int i) async {
    final hasPermission = await ensurePhotoPermission();

    if (!hasPermission) {
      return; // ⛔ STOP if denied
    }

    _pickImagefromGalleryOrCamara(type: i, source: ImageSource.gallery);

    /*
    return showModalBottomSheet<dynamic>(
        useRootNavigator: true,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return Container(
            decoration: const BoxDecoration(
                color: signInButtonColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //close
                InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.height * 0.03,
                            horizontal:
                                MediaQuery.of(context).size.width * 0.4),
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

                //sketch
                InkWell(
                  onTap: () async {
                    try {
                      PermissionStatus status;
                      if (Platform.isAndroid) {
                        if (await Permission.photos.request().isGranted) {
                          status = await Permission.photos.status;
                        } else {
                          status = await Permission.storage.status;
                        }
                      } else {
                        status = await Permission.storage.status;
                      }

                      if (status.isGranted || status.isLimited) {
                        _pickImagefromGalleryOrCamara(
                            type: i, source: ImageSource.gallery);
                      } else if (status.isDenied) {
                        if (Platform.isAndroid) {
                          await Permission.photos.request();
                          if (!await Permission.photos.isGranted) {
                            await Permission.storage.request();
                          }
                        } else {
                          await Permission.storage.request();
                        }
                      } else {
                        await openAppSettings();
                      }
                    } catch (e) {
                      debugPrint('Image picker error: ${e.toString()}');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    color: signInButtonColor,
                    height: MediaQuery.of(context).size.height * 0.08,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(AppAssets.photoIcon),
                        const SizedBox(width: 8),
                        Text(
                            widget.postModel.imgType == "1"
                                ? "העלאת סקיצה"
                                : "העלאת תמונה",
                            style: TextStyle(
                                color: titleTextWhiteColor, fontSize: 18)),
                      ],
                    ),
                  ),
                ),

                //sketch
                InkWell(
                  onTap: () async {
                    PermissionStatus status = await Permission.camera.status;
                    if (status.isGranted || status.isLimited) {
                      _pickImagefromGalleryOrCamara(
                          type: i, source: ImageSource.camera);
                    } else if (status.isDenied) {
                      await openAppSettings();
                    } else if (!status.isGranted) {
                      status = await Permission.camera.request();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    color: signInButtonColor,
                    height: MediaQuery.of(context).size.height * 0.09,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(AppAssets.cameraIcon),
                        const SizedBox(width: 8),
                        Text(
                            widget.postModel.imgType == "1"
                                ? "צילום סקיצה"
                                : "צילום תמונה",
                            style: TextStyle(
                                color: titleTextWhiteColor, fontSize: 18)),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.06,
                )
              ],
            ),
          );
        });
     */
  }

  _pickImagefromGalleryOrCamara({type, source}) async {
    // Get.back();
    try {
      final pickedImage =
      await ImagePicker().pickImage(source: source, imageQuality: 50);
      if (pickedImage != null) {
        setState(() {
          if (type == 3) {
            imageFile3 = File(pickedImage.path);
            isImageSelected3 = true;
          } else if (type == 2) {
            imageFile2 = File(pickedImage.path);
            isImageSelected2 = true;
          } else {
            imageFile1 = File(pickedImage.path);
            isImageSelected1 = true;
          }
        });
      }
    } catch (e) {
      debugPrint('Image picker error: ${e.toString()}');
    }
  }


  Stack buildImgRounded(
      {required Size size, required String type, required bool isUrls}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        isUrls
            ? Utils.buildCachedImageRounded(
            imgUrl: type == "3"
                ? imageUrl3
                : type == "2"
                ? imageUrl2
                : imageUrl1 ?? "",
            height: size.width * 0.29,
            width: size.width * 0.28)
            : Container(
          height: size.width * 0.29,
          width: size.width * 0.28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            //set border radius to 50% of square height and width
            image: DecorationImage(
              image: FileImage(type == "3"
                  ? imageFile3
                  : type == "2"
                  ? imageFile2
                  : imageFile1),
              fit: BoxFit.cover, //change image fill type
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: InkWell(
            onTap: () {
              setState(() {
                if (type == "3") {
                  if (isUrls) {
                    imageUrl3 = "";
                  } else {
                    isImageSelected3 = false;
                    imageFile3 = File("");
                  }
                } else if (type == "2") {
                  if (isUrls) {
                    imageUrl2 = "";
                  } else {
                    isImageSelected2 = false;
                    imageFile2 = File("");
                  }
                } else {
                  if (isUrls) {
                    imageUrl1 = "";
                  } else {
                    isImageSelected1 = false;
                    imageFile1 = File("");
                  }
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: socialoginbtn,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                AppAssets.deleteicon,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: InkWell(
            onTap: () {
              List<String> urls = [imageUrl1, imageUrl2, imageUrl3];

              List<File?> files = [imageFile1, imageFile2, imageFile3];

              List<MultiPostSlider> tempList = buildMultiPostList(
                urls: urls,
                files: files,
              );

              Get.to(
                MultiplePostImageWidget(
                  multiPostSlider: tempList,
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: socialoginbtn,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                AppAssets.inlargeIcon,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Stack builddotted(Size size) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background color inside the dotted border
        Container(
          height: size.width * 0.29,
          width: size.width * 0.28,
          decoration: BoxDecoration(
            color: socialoginbtn, // Background color
            borderRadius:
            BorderRadius.circular(8.0), // Optional: rounded corners
          ),
          child: Center(
            child: Transform.scale(
              scale: 2, //0.5, // Adjust the scale factor to fit your needs
              child: SvgPicture.asset(
                AppAssets.uploadicon,
                color: titleTextWhiteColor,
                height: 18, // Desired height
                width: 18, // Desired width
              ),
            ),
          ),
        ),
        // Dotted border overlay
        Positioned.fill(
          child: DottedBorderWidget(
            color: lightGrayColor, //const Color(0xFF807C84),
            strokeWidth: 1.0,
            gap: 8.0,
          ),
        ),
        // Centered icon
        // Center(
        //   child: SvgPicture.asset(
        //     color: titleTextWhiteColor,
        //     height: 18,
        //     width: 18,
        //     AppAssets.uploadicon,
        //   ),
        // ),
      ],
    );
  }

  Column buildTitleText(Size size, TextTheme textTheme, title) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(title,
              style: textTheme.titleMedium!.copyWith(
                  fontFamily: 'Arimo',
                  color: whiteTxtColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
        ),
        SizedBox(height: size.height * 0.02),
      ],
    );
  }

  Column buildTitleText20(Size size, TextTheme textTheme, title) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(title,
              style: textTheme.titleMedium!.copyWith(
                  fontFamily: 'Arimo',
                  color: whiteTxtColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
        ),
        SizedBox(height: size.height * 0.02),
      ],
    );
  }

  Future<void> updatePostFirebaseHandling() async {
    try {
      // Combine all local image files
      final imageFilesList = [imageFile1, imageFile2, imageFile3];

      // Remove any images the user deleted
      await deleteImageUserDeleted();

      // Filter only valid (existing + non-empty path) files
      final validImages = imageFilesList
          .where((file) => file.path.isNotEmpty && file.existsSync())
          .toList();

      // Fetch current user
      final user = await WebService.getCurrentUser();
      final userId = user.profile?.id;
      if (userId == null) throw Exception("User ID not found.");

      // Upload all valid images sequentially
      for (final file in validImages) {
        final fileName = file.path
            .split('/')
            .last;
        final path = "creatorImages/$userId/$fileName";
        final ref = FirebaseStorage.instance.ref(path);

        // Upload to Firebase Storage
        final uploadTask = await ref.putFile(file);
        final imageUrl = await uploadTask.ref.getDownloadURL();

        // Create RequestImages object
        final image = RequestImages(
          name: fileName,
          imageUrl: imageUrl,
          uid: userId,
        );

        await FireBaseApi.uploadBusinessImage(image: image);
        uploadedImages.add(image);
      }

      // Collect existing (already uploaded) image data
      final existingImages = [
        {'url': imageUrl1, 'id': imageId1},
        {'url': imageUrl2, 'id': imageId2},
        {'url': imageUrl3, 'id': imageId3},
      ];

      for (final img in existingImages) {
        final url = img['url'] ?? '';
        final id = img['id'] ?? '';
        if (url.isNotEmpty) {
          existingUrls.add(url);
          existingIds.add(id);
        }
      }

      // Append newly uploaded images
      for (final img in uploadedImages) {
        existingUrls.add(img.imageUrl ?? '');
        existingIds.add(img.imageId ?? '');
      }

      // Generate final comma-separated strings
      finalImageUrls = existingUrls.join(',');
      finalImageIds = existingIds.join(',');
    } catch (e, stack) {
      debugPrint("Error updating post Firebase handling: $e");
      debugPrint(stack.toString());
    }
  }

  Future<void> deleteImageUserDeleted() async {
    Future<void> deleteImageIfNeeded(String imageUrl, String tempImageUrl,
        String imageId) async {
      if (imageUrl.isEmpty && tempImageUrl.isNotEmpty) {
        try {
          // Delete image from Firebase Storage
          await FireBaseApi.deletestorageImage(imageUrl: tempImageUrl);

          if (imageId.isNotEmpty) {
            await FirebaseFirestore.instance
                .collection("images")
                .doc(imageId)
                .delete();
          }

          await FireBaseApi.removeImageFromFolderImages(
              pid: widget.postModel.id!);

          await FireBaseApi().removeImageFromFolders(imageUrl: tempImageUrl);
        } on FirebaseException catch (e) {
          debugPrint(
              '🔥 Firebase error deleting image ($imageId): ${e.message}');
        } catch (e) {
          debugPrint('⚠️ Unexpected error deleting image ($imageId): $e');
        }
      }
    }

    // Use a loop for scalability and cleaner code
    final imageData = [
      {'url': imageUrl1, 'temp': tempImageUrl1, 'id': imageId1},
      {'url': imageUrl2, 'temp': tempImageUrl2, 'id': imageId2},
      {'url': imageUrl3, 'temp': tempImageUrl3, 'id': imageId3},
    ];

    for (final img in imageData) {
      await deleteImageIfNeeded(img['url']!, img['temp']!, img['id']!);
    }
  }

  Future<bool> isFileEmpty(File file) async {
    if (file.path.isEmpty) return true; // no path provided
    if (!await file.exists()) return true; // file doesn't exist
    int length = await file.length();
    return length == 0;
  }

  List<MultiPostSlider> buildMultiPostList({
    required List<File?> files,
    required List<String> urls,
  }) {
    List<MultiPostSlider> tempList = [];

    // FILES
    tempList.addAll(
      files.where((file) => file != null && file.path.isNotEmpty).map(
            (file) =>
            MultiPostSlider(
              imageName: file!.path,
              imageType: ImageSourceType.file,
            ),
      ),
    );

    // URLS
    tempList.addAll(
      urls.where((url) => url.isNotEmpty).map(
            (url) =>
            MultiPostSlider(
              imageName: url,
              imageType: ImageSourceType.url,
            ),
      ),
    );

    return tempList;
  }
}
