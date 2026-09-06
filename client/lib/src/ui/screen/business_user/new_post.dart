import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ink/src/controller/artistsListController.dart';
import 'package:ink/src/controller/myPostController.dart';
import 'package:ink/src/data/model/MultiPost.dart';
import 'package:ink/src/data/model/check_subscription_model.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/business_dashboard.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/bussinessdashboard_binding.dart';
import 'package:ink/src/ui/screen/sendTattoRquest/widget/dashed_border_widget.dart';
import 'package:ink/src/ui/widgets/multiple_post_image_widget.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/permissions.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../controller/post_controller.dart';
import '../../../controller/userController.dart';
import '../../../data/model/image_model.dart';
import '../../../data/source/network/firebase_api.dart';
import '../../../data/source/network/user_api.dart';
import '../../../utils/common.dart';
import '../../../utils/webService.dart';
import '../../widgets/unfocus_widget.dart';

class SketchImageScreen extends StatefulWidget {
  final List<File> pickedFiles;
  final bool isProfileUpload;
  final String imageType;
  final CheckSubscriptionModel subscriptionModel;

  const SketchImageScreen(
      {super.key,
      required this.pickedFiles,
      required this.imageType,
      required this.subscriptionModel,
      this.isProfileUpload = false});

  @override
  State<SketchImageScreen> createState() => _SketchImageScreenState();
}

class _SketchImageScreenState extends State<SketchImageScreen>
    with SingleTickerProviderStateMixin {
  String imageTypes = "0";
  bool secondScreenVisible = true;
  bool thirdScreenVisible = false;
  bool isLoading = false;
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

  //images
  bool isImageSelected1 = false;
  bool isImageSelected2 = false;
  bool isImageSelected3 = false;
  File imageFile1 = File("");
  File imageFile2 = File("");
  File imageFile3 = File("");

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));
    base = CurvedAnimation(parent: animationController, curve: Curves.easeOut);
    imageTypes = widget.imageType;
    getUserStyles();
    getArtists();
    // if (widget.pickedFiles != null) {
    //   isImageSelected1 = true;
    //   imageFile1 = File(widget.pickedFile!.path);
    // }
    _assignImages();
  }

  void _assignImages() {
    final files = widget.pickedFiles;

    if (files.isNotEmpty) {
      imageFile1 = files[0];
      isImageSelected1 = true;
    }
    if (files.length > 1) {
      imageFile2 = files[1];
      isImageSelected2 = true;
    }
    if (files.length > 2) {
      imageFile3 = files[2];
      isImageSelected3 = true;
    }
  }

  //get userStyles
  Future getUserStyles() async {
    user = await WebService.getCurrentUser();
    user.stylesList?.map((doc) {
      listStyles.add(doc);
    }).toList();
    user.stylesList?.map((doc) {
      filteredListStyles.add(doc);
    }).toList();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    animationController.stop();
    aboutTextController.dispose();
    searchTxtController.dispose();
    searchUserTxtController.dispose();
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: size.height * 0.03,
                      ),
                      buildTopBackRow(
                          textTheme: textTheme,
                          title: 'העלאת פוסט',
                          onPressed: () => Get.back()),
                      SizedBox(
                        height: size.height * 0.03,
                      ),
                      buildTabBar(context, size, textTheme),
                      SizedBox(
                        height: size.height * 0.03,
                      ),
                      buildTitleOnlyText(
                          size,
                          textTheme,
                          imageTypes.toString() == "1"
                              ? 'ספר לנו על הסקיצה שלך'
                              : 'ספר לנו על העבודה שלך'),
                      buildImageUpload(context, size, textTheme),
                      SizedBox(
                        height: size.height * 0.03,
                      ),
                      buildTitleText(
                          size,
                          textTheme,
                          // imageTypes.toString() == "1"
                          //     ? 'באיזה סגנון הקעקוע?'
                          //     : 'איזה סטייל מתאים לעבודה הזו?'),
                          imageTypes.toString() == "1"
                              ? "באיזה סגנון הסקיצה?"
                              : 'באיזה סגנון הקעקוע?'),
                      Wrap(
                        spacing: 10.0,
                        runSpacing: 2.0,
                        verticalDirection: VerticalDirection.up,
                        children: listStyles.map((option) {
                          return ElevatedButton(
                            onPressed: () => setState(() {
                              if (selectedList.contains(option)) {
                                // If the option is already selected, deselect it
                                selectedList.remove(option);
                              } else {
                                if (selectedList.length < 3) {
                                  selectedList.add(option);
                                } else {
                                  displayMessageIcon(
                                      message: 'ניתן לבחור עד 3 סגנונות.',
                                      color: errorColor,
                                      snackposition: SnackPosition.BOTTOM,
                                      imageData: AppAssets.errorIcon);
                                }
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
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      buildTitleText(size, textTheme, 'תיאור'),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
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
                          style: textTheme.titleMedium!.copyWith(
                              color: titleTextWhiteColor,
                              fontWeight: FontWeight.w400),
                          // Allows the text field to grow as the user types
                          decoration: InputDecoration(
                            hintStyle: const TextStyle(
                                color: placeholdertxtColor,
                                fontSize: 15,
                                fontFamily: 'Arimo',
                                fontWeight: FontWeight.w400),
                            hintMaxLines: 2,
                            hintText: imageTypes.toString() == "1"
                                ? 'ספר בקצרה על סקיצה / המשמעות / השראה'
                                : 'ספר בקצרה על העבודה / המשמעות / השראה',
                            border: InputBorder.none,
                          ),
                          onChanged: (txt) {
                            aboutTextController.text = txt;
                            setState(() {});
                          },
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      isLoading
                          ? Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: buildIsLoading(size),
                            )
                          : buildDetailBtnSubmit(context: context, size: size),
                    ],
                  ),
                ))
            :
            //tag crew member
            Column(
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
                              secondScreenVisible = true;
                              thirdScreenVisible = false;
                            });
                          }),
                      Text(
                        'תיוג המקעקע',
                        style: Theme.of(context)
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
                                        onTap: () => setState(() {
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
                                                selectedMemberList.remove(id);
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
                                                        maxLines: 2,
                                                        overflow:
                                                            TextOverflow.clip,
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
                  isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: buildIsLoading(size),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: InkWell(
                            onTap: () async {
                              FocusScope.of(context).unfocus();
                              await uploadImage();
                            },
                            child: Container(
                              width: size.width,
                              height: size.height * 0.07,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                gradient: appLinearGradient,
                              ),
                              child: Text(
                                "הבא",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        color: kWhite,
                                        fontWeight: FontWeight.w700),
                              ),
                            ),
                          ))
                ],
              ),
      ),
    ));
  }

  InkWell buildTopBackRow(
      {required TextTheme textTheme,
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
          SizedBox(width: 8),
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
  customAppBar(
          String title, BuildContext context, Size size, TextTheme textTheme) =>
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
  buildProgress() => StreamBuilder<TaskSnapshot>(
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
                        'Please Wait..  ${(100 * progress).roundToDouble()} %',
                        style: const TextStyle(color: Colors.white)))
              ],
            ));
      });

  //upload image to firebase
  uploadImage() async {
    bool isConnected = await WebService.checkConnection2();

    if (!isConnected) {
      return;
    } else {
      setState(() {
        isLoading = true;
        animationController.forward();
        animationController.repeat();
      });
      try {
        String styleList = "";
        if (selectedList != null) {
          selectedList.forEach((v) {
            styleList += v == selectedList.last ? v.slug! : "${v.slug},";
          });
        }
        List<File> imageFiles = [imageFile1, imageFile2, imageFile3];
        List<RequestImages> uploadedImages = [];

        // Filter out empty or non-existing files
        List<File> validImages = imageFiles.where((file) {
          return file.path.isNotEmpty && file.existsSync();
        }).toList();
        AppUser user = await WebService.getCurrentUser();
        // Now process only the valid ones
        for (var file in validImages) {
          final fileName = file.path.split('/').last;
          final path = "creatorImages/${user.profile!.id}/$fileName";
          final ref = FirebaseStorage.instance.ref().child(path);

          // Upload to Firebase Storage
          final uploadTask = ref.putFile(file);
          final snapshots = await uploadTask.whenComplete(() {});
          final imageUrl = await snapshots.ref.getDownloadURL();

          print("imageUrl $imageUrl");
          // Create your RequestImages object
          final image = RequestImages(
            name: fileName,
            imageUrl: imageUrl,
            uid: user.profile!.id!,
          );

          print("imageimageimageimage:-> $image");
          // Save image info to Firestore (or your backend)
          await FireBaseApi.uploadBusinessImage(image: image);
          uploadedImages.add(image);
          // Your upload or handling logic here
        }

        //Old Data

        // String fileName = widget.pickedFile.existsSync()
        //     ? widget.pickedFile.path.split('/').last
        //     : null;
        //
        // AppUser user = await WebService.getCurrentUser();
        // final path = "creatorImages/${user.profile!.id}/$fileName";
        //
        // final ref = FirebaseStorage.instance.ref().child(path);
        //
        // setState(() {
        //   uploadTask = ref.putFile(
        //       widget.pickedFile.existsSync() ? widget.pickedFile : null);
        // });
        //
        // final snapshots = await uploadTask!.whenComplete(() {});
        //
        // final imageUrl = await snapshots.ref.getDownloadURL();
        //
        // RequestImages image = RequestImages(
        //     name: fileName, imageUrl: imageUrl, uid: user.profile!.id!);
        //
        // await FireBaseApi.uploadBusinessImage(image: image);
// Old Data End

        print("uploadedImages ${uploadedImages.length}");
        print("uploadedImages ${uploadedImages}");
        String tempImageUrl = "";
        String tempImageId = "";

        if (uploadedImages.isNotEmpty) {
          for (var image in uploadedImages) {
            // Assuming RequestImages has fields: name, imageUrl, uid
            tempImageUrl += "${image.imageUrl},";
            tempImageId += "${image.imageId},";
          }

          // Remove the last comma if needed
          if (tempImageUrl.endsWith(',')) {
            tempImageUrl = tempImageUrl.substring(0, tempImageUrl.length - 1);
          }
          if (tempImageId.endsWith(',')) {
            tempImageId = tempImageId.substring(0, tempImageId.length - 1);
          }
        }
        await Network.addPost(
          imageType: imageTypes,
          description: aboutTextController.text,
          imageName: tempImageUrl,
          imageId: tempImageId,
          styles: styleList,
          creatorId: selectedMemberList.isNotEmpty ? selectedMemberList[0] : "",
        ).then((value) async {
          final postController = await Get.put(PostController());
          final myPostsController = await Get.put(MyPostsController());
          await postController.getPosts().then((value) async {
            await myPostsController.getMyPosts();
            setState(() {
              displayMessageIcon(
                  message: 'התמונה הועלתה בהצלחה!',
                  color: const Color(0xFF2E602E),
                  snackposition: SnackPosition.BOTTOM,
                  imageData: AppAssets.correct_transparentIcon);
              animationController.stop();
              uploadTask = null;
            });
          });
        });

        Get.deleteAll(force: true);

        if (widget.isProfileUpload == true) {
          Get.offAll(
              BusinessDashBoard(
                initialIndex: 4,
              ),
              binding: BusinessDashBoardBinding());
        } else {
          Get.offAll(
              BusinessDashBoard(
                initialIndex: 0,
              ),
              binding: BusinessDashBoardBinding());
        }
      } catch (e) {
        isLoading = false;
      } finally {
        isLoading = false;
      }
    }
  }

  _buildSearchbar({required Size size}) => Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
        child: SizedBox(
          height: size.height * 0.1,
          child: TextFormField(
              autofocus: false,
              controller: searchUserTxtController,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.search,
              style: const TextStyle(color: titleTextWhiteColor),
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

  buildDetailBtnSubmit({required BuildContext context, required Size size}) =>
      InkWell(
        onTap: () async {
          if (imageFile1.path.isEmpty &&
              imageFile2.path.isEmpty &&
              imageFile3.path.isEmpty) {
            FocusScope.of(context).unfocus();
            return;
          } else if (selectedList.length == 0) {
            FocusScope.of(context).unfocus();
            return;
          } else if (aboutTextController.text.isEmpty &&
              aboutTextController.text.trim().isEmpty) {
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
              await uploadImage();
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
              colors: imageFile1.path.isEmpty &&
                      imageFile2.path.isEmpty &&
                      imageFile3.path.isEmpty
                  ? [
                      lineargrayGradieantColor1,
                      lineargrayGradieantColor2,
                      lineargrayGradieantColor3
                    ]
                  : aboutTextController.text.isNotEmpty &&
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
            "העלאת פוסט",
            // imageTypes.toString() == "1" ? "העלאת פוסט" : "פרסם עכשיו",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: aboutTextController.text.trim().isEmpty ||
                        selectedList.length == 0 ||
                        imageFile1.path.isEmpty &&
                            imageFile2.path.isEmpty &&
                            imageFile3.path.isEmpty
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
          SizedBox(height: size.height * 0.03),
          buildTitleText(size, textTheme, 'בחר את התמונות שתרצה להציג'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              isImageSelected1
                  ? buildimgrounded(size, 1)
                  : InkWell(
                      onTap: () => _showBottomSheet(context, 1),
                      // onTap: () => _pickImagefromGallery(type: 1),
                      child: builddotted(size)),
              isImageSelected2
                  ? buildimgrounded(size, 2)
                  : InkWell(
                      onTap: () => _showBottomSheet(context, 2),
                      // onTap: () => _pickImagefromGallery(type: 2),
                      child: builddotted(size)),
              isImageSelected3
                  ? buildimgrounded(size, 3)
                  : InkWell(
                      onTap: () => _showBottomSheet(context, 3),
                      // onTap: () => _pickImagefromGallery(type: 3),
                      child: builddotted(size)),
            ],
          )
        ],
      );

  Column buildTitleText(Size size, TextTheme textTheme, title) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(title,
              style: textTheme.titleMedium!.copyWith(
                  color: kWhite, fontSize: 16, fontWeight: FontWeight.w700)),
        ),
        SizedBox(height: size.height * 0.02),
      ],
    );
  }

  Align buildTitleOnlyText(Size size, TextTheme textTheme, title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(title,
          style: textTheme.titleMedium!.copyWith(
              fontFamily: 'Arimo',
              color: kWhite,
              fontSize: 20,
              fontWeight: FontWeight.w700)),
    );
  }

  _showBottomSheet(BuildContext context, int i) async {
    final hasPermission = await ensurePhotoPermission();

    if (!hasPermission) {
      return; // ⛔ STOP if denied
    }

    _pickImagefromGalleryOrCamara(type: i, source: ImageSource.gallery);

    /*return showModalBottomSheet<dynamic>(
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
                        Text(imageTypes == "1" ? "העלאת סקיצה" : "העלאת תמונה",
                            style: const TextStyle(
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
                        Text(imageTypes == "1" ? "צילום סקיצה" : "צילום תמונה",
                            style: TextStyle(
                                color: titleTextWhiteColor, fontSize: 18)),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                )
              ],
            ),
          );
        });*/
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

  Stack buildimgrounded(Size size, type) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: size.width * 0.29,
          width: size.width * 0.28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            //set border radius to 50% of square height and width
            image: DecorationImage(
              image: FileImage(type == 3
                  ? imageFile3
                  : type == 2
                      ? imageFile2
                      : imageFile1),
              fit: BoxFit.cover, //change image fill type
            ),
          ),
        ),
        Positioned(
          left: 0,
          bottom: 0,
          child: InkWell(
            onTap: () {
              setState(() {
                if (type == 3) {
                  isImageSelected3 = false;
                  imageFile3 = File("");
                } else if (type == 2) {
                  isImageSelected2 = false;
                  imageFile2 = File("");
                } else {
                  isImageSelected1 = false;
                  imageFile1 = File("");
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
              List<File?> files = [imageFile1, imageFile2, imageFile3];

              List<MultiPostSlider> tempList = files
                  .where((file) => file != null && file.path.isNotEmpty)
                  .map((file) => MultiPostSlider(
                        imageName: file!.path,
                        imageType: ImageSourceType.file,
                      ))
                  .toList();

              Get.to(
                MultiplePostImageWidget(
                    multiPostSlider: tempList, isNewPost: true),
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

  buildTabBar(BuildContext context, Size size, TextTheme textTheme) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabItem(
            icon: AppAssets.photoIcon,
            text: ' תמונות',
            type: "0",
          ),
          const SizedBox(width: 20),
          _buildTabItem(
            icon: AppAssets.flashIcon,
            text: ' סקיצות',
            type: "1",
          ),
        ],
      );

  Widget _buildTabItem({
    required String icon,
    required String text,
    required String type,
  }) {
    bool isSelected = imageTypes == type;
    return GestureDetector(
      onTap: () async {
        if (type.toString() == "1") {
          if (widget.subscriptionModel.subscriptionStatus.toString() == "1" &&
              widget.subscriptionModel.isPremium.toString() == "1") {
            setState(() {
              imageTypes = type;
            });
          } else {
            needSubscriptionUploadDialog(
                context: context, backCurrentScreen: true);
          }
        } else {
          setState(() {
            imageTypes = type;
          });
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(icon,
                  color: isSelected ? whiteTxtColor : titleTextWhiteColor),
              const SizedBox(width: 2),
              Text(text,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w400,
                    color: isSelected ? whiteTxtColor : titleTextWhiteColor,
                  )),
            ],
          ),
          const SizedBox(height: 4),
          isSelected
              ? Container(
                  width: 80,
                  height: 2,
                  color: titleTextColor,
                )
              : Container(
                  width: 80,
                  height: 2,
                  color: Colors.transparent,
                ),
        ],
      ),
    );
  }
}
