import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/userController.dart';
import 'package:ink/src/data/model/collection_model.dart';
import 'package:ink/src/data/source/network/firebase_api.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/business_dashboard.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/bussinessdashboard_binding.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard_binding.dart';
import 'package:ink/src/ui/screen/home/imageDetails/post_image.dart';
import 'package:ink/src/ui/screen/sendTattoRquest/request_for_tattoo.dart';
import 'package:ink/src/ui/widgets/bottomenu/business_dashboard_bottomenu.dart';
import 'package:ink/src/ui/widgets/bottomenu/dashboard_bottomenu.dart';
import 'package:ink/src/ui/widgets/button/custom_gradient_btn_widget.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/share_data.dart';
import 'package:ink/src/utils/utils.dart';
import 'package:ink/src/utils/webService.dart';

import '../../../../utils/bottomsheets.dart';
import '../../../../utils/colors.dart';
import '../../profile/businessUserProfile.dart';
import '../controller/post_details_controller.dart';
import 'edit_post_screen.dart';

class PostDetails extends StatefulWidget {
  final String dynamictxt;
  final String postId;
  final String foldersid;
  final bool isArtist;
  final bool isNotification;
  final bool isNotificationscreen;
  final bool isCollectionMultipleImages;
  final bool isInspirationScreen;
  final String fidCollection;
  final currentUserTypeCollection;
  final String fNameCollection;
  final String imageUrlsCollection;

  const PostDetails({Key? key,
    required this.postId,
    required this.isArtist,
    this.isNotificationscreen = false,
    this.isNotification = false,
    this.isInspirationScreen = false,
    this.isCollectionMultipleImages = false,
    this.fidCollection = "",
    this.currentUserTypeCollection = "",
    this.fNameCollection = "",
    this.imageUrlsCollection = "",
    this.foldersid = "",
    this.dynamictxt = "dynamicNot"})
      : super(key: key);

  @override
  State<PostDetails> createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails>
    with SingleTickerProviderStateMixin {
  final postDetailsController = Get.put(PostDetailsController());

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController scrollController = ScrollController();
  final TextEditingController fNameController = TextEditingController();
  final TextEditingController commentTxtController = TextEditingController();
  final userController = Get.put(UserController());

  late AnimationController animationController;
  late Animation<double> base;

  //see creator
  bool? isCreatorViewOpened = false;

  // final studioDetailsController = Get.put(StudioDetailController());
  // final myPostController = Get.put(MyPostsController());
  List<String> collectionsList = [];
  bool isShareLoading = false;

  String userTypes = "";

  @override
  void initState() {
    postDetailsController.getPostDetailsController(
      pid: widget.postId,
      foldersid: widget.foldersid,
    );
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    base = CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    userTypes = userController.userType.value;
  }

  @override
  void dispose() {
    // WidgetsBinding.instance.removeObserver(this);
    animationController.stop();
    animationController.dispose();
    // postModel == null;
    super.dispose();
  }

  Future<bool> redirectTo({required BuildContext contexts,
    required String foldersid,
    required String postId}) async {
    if (identical(widget.dynamictxt, "DYNAMICTEXT")) {
      userController.initUser().then((value) async {
        try {
          final isBusiness = await WebService.getIsBusiness();
          if (userController.userType.value == "1" || isBusiness == false) {
            Get.offAll(
                const DashBoard(
                  initialIndex: 3,
                ),
                binding: DashBoardBinding());
          } else {
            Get.offAll(
                BusinessDashBoard(
                  initialIndex: 0,
                ),
                binding: BusinessDashBoardBinding());
          }
        } catch (e) {
          displayMessageIcon(
              message: e.toString(),
              snackposition: SnackPosition.BOTTOM,
              color: errorColor,
              imageData: AppAssets.errorIcon);
          // displayMessage(e.toString(), Colors.deepOrange);
          WebService.printMsg(e.toString());
        }
      });
    } else {
      postDetailsController.navigateBack(
        context: contexts,
        isNotification: widget.isNotification,
        isNotificationscreen: widget.isNotificationscreen,
        foldersid: foldersid,
        imageUrlsCollection: widget.currentUserTypeCollection,
        currentUserTypeCollection: widget.currentUserTypeCollection,
        fidCollection: widget.fidCollection,
        fNameCollection: widget.fNameCollection,
      );
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;
    return PopScope(
      canPop: true,
      onPopInvoked: (bool didPop) =>
          redirectTo(
              foldersid: widget.foldersid,
              postId: widget.postId,
              contexts: context),
      child: SafeArea(
          child: Scaffold(
              backgroundColor: bgColor,
              key: scaffoldKey,
              bottomNavigationBar: userTypes == "2"
                  ? BusinessDashboardBottomBar(
                currentIndex: widget.isInspirationScreen ? 1 : 0,
              )
                  : DashboardBottomBar(
                  currentIndex: widget.isInspirationScreen ? 1 : 0),
              appBar: AppBar(
                automaticallyImplyLeading: false,
                elevation: 0,
                backgroundColor: scaffoldBg,
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () =>
                            redirectTo(
                                foldersid: widget.foldersid,
                                postId: widget.postId,
                                contexts: context),
                        child: SvgPicture.asset(AppAssets.backarrowIcon,
                            width: 22, height: 22, color: titleTextWhiteColor),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: IconButton(
                        icon: SvgPicture.asset(
                          AppAssets.dots3Icon,
                          color: titleTextWhiteColor,
                        ),
                        onPressed: () =>
                            buildCommonBottomShit(
                                context: context,
                                height: (postDetailsController
                                    .appUser.value.profile!.id ==
                                    postDetailsController
                                        .postModel.value.owner!.id)
                                    ? 0.26
                                    : 0.19,
                                child: Padding(
                                  padding: EdgeInsets.all(size.width * 0.03),
                                  child: (postDetailsController
                                      .appUser.value.profile!.id ==
                                      postDetailsController
                                          .postModel.value.owner!.id)
                                      ? Column(
                                    children: [
                                      InkWell(
                                          onTap: () async {
                                            Get.back();
                                            Get.to(() =>
                                                EditPostScreen(
                                                  postModel:
                                                  postDetailsController
                                                      .postModel.value,
                                                ));
                                          },
                                          child: SizedBox(
                                              width: double.infinity,
                                              height: MediaQuery
                                                  .of(context)
                                                  .size
                                                  .height *
                                                  0.07,
                                              child: Row(
                                                children: [
                                                  const SizedBox(width: 4),
                                                  SvgPicture.asset(
                                                    AppAssets.editIcon,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text("עריכת פרטים",
                                                      style: Theme
                                                          .of(context)
                                                          .textTheme
                                                          .titleLarge!
                                                          .copyWith(
                                                          fontSize: 18,
                                                          fontWeight:
                                                          FontWeight
                                                              .w400,
                                                          color:
                                                          titleTextWhiteColor)),
                                                ],
                                              ))),
                                      InkWell(
                                          onTap: () =>
                                              buildDeletePostDialog(
                                                  context, () async {
                                                postDetailsController
                                                    .isDeleteLoading
                                                    .value = true;
                                                animationController.repeat();
                                                await postDetailsController
                                                    .removePostController(
                                                  pid: postDetailsController
                                                      .postModel.value.id,
                                                  imageId:
                                                  postDetailsController
                                                      .postModel
                                                      .value
                                                      .imageId,
                                                  baseUrl:
                                                  postDetailsController
                                                      .postModel
                                                      .value
                                                      .imageName,
                                                  isMultipleImage:
                                                  postDetailsController
                                                      .postModel
                                                      .value
                                                      .isMultipleImages,
                                                )
                                                    .then((value) async {
                                                  postDetailsController
                                                      .isDeleteLoading
                                                      .value = false;
                                                  //
                                                  // final MyPostsController
                                                  //     myPostsController =
                                                  //     Get.put(
                                                  //         MyPostsController());
                                                  // await myPostsController
                                                  //     .getMyPosts();
                                                  animationController.stop();
                                                  Get.offAll(
                                                          () =>
                                                          BusinessDashBoard(
                                                            initialIndex: 4,
                                                          ),
                                                      binding:
                                                      BusinessDashBoardBinding());
                                                });
                                              }),
                                          child: SizedBox(
                                              width: double.infinity,
                                              height: MediaQuery
                                                  .of(context)
                                                  .size
                                                  .height *
                                                  0.07,
                                              child: Row(
                                                children: [
                                                  const SizedBox(width: 4),
                                                  SvgPicture.asset(
                                                    AppAssets.deleteicon,
                                                    color: const Color(
                                                        0xFFEE7B7B),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text("מחיקת תמונה",
                                                      style: Theme
                                                          .of(context)
                                                          .textTheme
                                                          .titleLarge!
                                                          .copyWith(
                                                        color: const Color(
                                                            0xFFEE7B7B),
                                                        fontSize: 18,
                                                        fontWeight:
                                                        FontWeight
                                                            .w400,
                                                      )),
                                                ],
                                              ))),

                                    ],
                                  )
                                      : Column(
                                    children: [
                                      InkWell(
                                          onTap: () async {
                                            Get.back();
                                            await postDetailsController
                                                .reportPost(
                                                pid: postDetailsController
                                                    .postModel.value.id,
                                                reportMsg: 2,
                                                reportMsgDetails: "")
                                                .then((value) async {
                                              commentTxtController.text = "";
                                            });
                                          },
                                          child: SizedBox(
                                              width: double.infinity,
                                              height: MediaQuery
                                                  .of(context)
                                                  .size
                                                  .height *
                                                  0.07,
                                              child: Text(
                                                  "דיווח על תמונה בניגוד לנהלים",
                                                  style: Theme
                                                      .of(context)
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                      color:
                                                      defaultWhite)))),
                                    ],
                                  ),
                                ),
                                btnTitle: tr("collection.new_collection"),
                                isBtnView: false)),
                  ),

                ],
              ),
              body: Obx(
                    () =>
                postDetailsController.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildImage(size: size),

                            if (postDetailsController
                                .postModel.value.owner !=
                                null)
                              buildInfoRow(size),
                            // buildDivider(size),
                            buildDescription(size),
                            // if (postModel!.artist !=
                            //         null &&
                            //     postModel!.artist!.id !=
                            //         postModel!.owner!.id)
                            if (!Utils.isDataEmpty(postDetailsController
                                .postModel.value.artist))
                              const SizedBox(height: 10),
                            if (!Utils.isDataEmpty(postDetailsController
                                .postModel.value.artist))
                              buildCreatorPopUp(size),

                            const SizedBox(height: 10),
                            if (postDetailsController
                                .postModel.value.tagList !=
                                null)
                              SizedBox(
                                  height: 24,
                                  child: ListView(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      children: buildTags(size))),

                            const SizedBox(height: 40),

                            const SizedBox(
                              width: 351,
                              child: Text(
                                'קעקועים בסגנון',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Color(0xFFDFDCE3),
                                  fontSize: 18,
                                  fontFamily: 'Arimo',
                                  fontWeight: FontWeight.w700,
                                  height: 0.09,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            buildRelatedPosts(size: size),
                          ]),
                    )),
              ))),
    );
  }

  //description
  buildDescription(Size size) =>
      Text(postDetailsController.postModel.value.description ?? "",
          textAlign: TextAlign.right,
          style: const TextStyle(
              color: Color(0xFFC0BCC4),
              fontSize: 16,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w400));

  //tags list
  buildTags(Size size) =>
      postDetailsController.postModel.value.tagList!.isEmpty
          ? const SizedBox()
          : postDetailsController.postModel.value.tagList!
          .map((e) =>
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: ShapeDecoration(
                  color: const Color(0xFF2B272F),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4))),
              child: Text(
                e.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFDFDCE3),
                  fontSize: 14,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.56,
                ),
              ),
            ),
          ))
          .toList();

  // buildTags(Size size) => Container(
  //     width: size.width,
  //     padding: const EdgeInsets.all(5.0),
  //     child: Text(postDetailsController.postModel.value.tagStr.toString(),
  //         style: const TextStyle(color: Colors.blueAccent)));

  //creator view
  buildCreatorPopUp(Size size) =>
      Container(
        margin: EdgeInsets.symmetric(vertical: size.height * 0.01),
        width: size.width,
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // SizedBox(
            //     width:
            //         isCreatorViewOpened! ? size.width * 0.3 : size.width * 0.7,
            //     child: const Divider(thickness: 2)),
            const Text(
              'מקעקע:',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Color(0xFFC0BCC4),
                fontSize: 16,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(width: 5),

            InkWell(
              onTap: () async {
                if ((postDetailsController.appUser.value.profile!.id ==
                    postDetailsController.postModel.value.owner!.id)) {
                  Get.offAll(
                          () =>
                          BusinessDashBoard(
                            initialIndex: 4,
                          ),
                      binding: BusinessDashBoardBinding());
                } else {
                  Get.to(() =>
                      BusinessProfileScreen(
                          bId: postDetailsController.postModel.value.artist !=
                              null
                              ? postDetailsController.postModel.value.artist!
                              .id!
                              : postDetailsController.postModel.value.owner!
                              .id!,
                          fromPost: true));
                }
              },
              child: buildOwnerProfileImage(
                  size: size,
                  width: 24,
                  ownerImage:
                  ((postDetailsController.postModel.value.artist != null)
                      ? postDetailsController
                      .postModel.value.artist!.profileImage!
                      : postDetailsController
                      .postModel.value.owner!.profileImage!)),
            ),

            Text(
              postDetailsController.postModel.value.artist != null
                  ? postDetailsController.postModel.value.artist!.name!
                  : postDetailsController.postModel.value.owner!.name!,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFFC0BCC4),
                fontSize: 16,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );

  buildInfoRow(Size size) =>
      SizedBox(
          height: size.height * 0.1,
          child: InkWell(
            splashColor: Colors.grey,
            onTap: () {
              if (postDetailsController.appUser.value.profile!.id ==
                  postDetailsController.postModel.value.owner!.id) {
                Get.offAll(
                        () =>
                        BusinessDashBoard(
                          initialIndex: 4,
                        ),
                    binding: BusinessDashBoardBinding());
              } else {
                Get.to(() =>
                    BusinessProfileScreen(
                        bId: postDetailsController.postModel.value.owner!.id!,
                        fromPost: true));
              }
            },
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //profile picture
                  buildOwnerProfileImage(
                      size: size,
                      width: 40,
                      ownerImage: postDetailsController
                          .postModel.value.owner!.profileImage ??
                          ""),

                  const SizedBox(width: 10),

                  //name
                  Text(
                      postDetailsController.postModel.value.owner!.name == ""
                          ? ""
                          : postDetailsController
                          .postModel.value.owner!.name!.length >
                          15
                          ? '${postDetailsController.postModel.value.owner!
                          .name!.substring(0, 15)}..'
                          : postDetailsController.postModel.value.owner!.name!,

                      style: const TextStyle(
                          color: Color(0xFFDFDCE3),
                          fontSize: 18,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w700)),

                  const Spacer(),

                  //tattoo btn
                  if (postDetailsController.appUser.value.profile!.id !=
                      postDetailsController.postModel.value.owner!.id)
                    CustomGradientButtonWidget(
                      textSize: 14,
                      width: size.width * 0.34,
                      height: size.height * 0.05,
                      title: "פנייה לעסק",
                      onTap: () {
                        Get.to(() =>
                            ScreenTattooRequest(
                                bId: postDetailsController.postModel.value
                                    .uid!));
                      },
                    )
                ]),
          ));

  //image
  buildImage({required Size size}) {
    final CarouselSliderController _carouselSliderController =
    CarouselSliderController();
    var imageList = <String>[];

    final raw = postDetailsController.postModel.value.imageName;

    if (raw is String && raw.isNotEmpty) {
      // Remove [ and ]
      final cleaned = raw.substring(1, raw.length - 1);

      // Split by comma
      imageList = cleaned.split(',').map((e) => e.trim()).toList();
    }
    debugPrint("imageList:-> $imageList");
    final imageName = postDetailsController.postModel.value.imageName;

    return InkWell(
        onTap: () =>
            Get.to(PostImageScreen(
                imgUrl: postDetailsController.postModel.value.imageName!,
                isMultipleImages:
                postDetailsController.postModel.value.isMultipleImages ?? "0",
                posTitle: postDetailsController.postModel.value.artist != null
                    ? postDetailsController.postModel.value.artist!.name!
                    : postDetailsController.postModel.value.owner!.name!)),
        child: Stack(children: [
          postDetailsController.postModel.value.isMultipleImages == "1"
              ? Stack(
            clipBehavior: Clip.none,
            children: [
              CarouselSlider(
                carouselController: _carouselSliderController,
                options: CarouselOptions(
                    height: Get.height * 0.5,
                    autoPlay: false,
                    viewportFraction: 1,
                    animateToClosest: true,
                    enlargeCenterPage: false,
                    onPageChanged: (index, reason) {
                      postDetailsController
                          .currentCarouselSliderPage.value = index;
                    }),
                items: imageList.map((imageUrl) {
                  return CachedNetworkImage(
                    imageUrl: WebService.resolveImageUrl(imageUrl),
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Center(
                          child: CircularProgressIndicator(),
                        ),
                    errorWidget: (context, url, error) =>
                        Icon(Icons.error),
                  );
                }).toList(),
              ),
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: imageList
                      .asMap()
                      .entries
                      .map((entry) {
                    return Container(
                      width: postDetailsController
                          .currentCarouselSliderPage.value ==
                          entry.key
                          ? 32.0
                          : 20.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(20),
                          color: (postDetailsController
                              .currentCarouselSliderPage.value ==
                              entry.key
                              ? titleTextWhiteColor
                              : titleTextWhiteColor.withOpacity(0.4))),
                    );
                  }).toList(),
                ),
              )
            ],
          )
          : CachedNetworkImage(
              imageUrl: WebService.resolveImageUrl(
                  (imageName == null || imageName.isEmpty)
                      ? ''
                      : imageList.first),
              imageBuilder: (context, imageProvider) =>
                  Container(
                      height: Get.height * 0.5,
                      alignment: Alignment.center,
                      decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          // color: Colors.black87,
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover))),
              fit: BoxFit.fitHeight,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  SizedBox(
                      width: Get.width * 0.9,
                      height: Get.height * 0.5,
                      child: Center(
                          child: CircularProgressIndicator(
                              value: downloadProgress.progress))),
              errorWidget: (context, url, error) =>
                  Container(
                      width: Get.width * 0.9,
                      height: Get.height * 0.5,
                      alignment: Alignment.center,
                      decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          // color: Colors.black87,
                          image: const DecorationImage(
                              image:
                              AssetImage("assets/images/placeholder.png"),
                              fit: BoxFit.cover)))),
          //save
          Positioned(
              bottom: 10,
              left: size.width * 0.02,
              child: Obx(() =>
                  buildSvgIcon(
                      isFill: postDetailsController.savedFolderList.isNotEmpty
                          ? true
                          : false,
                      borderRadius: 50.0,
                      size: size.width * 0.12,
                      iconPath: AppAssets.postSaveIcon,
                      afterTapIcon: AppAssets.postSavedIcon,
                      onClick: () =>
                          buildCommonBottomShit(
                              context: context,
                              child: Column(
                                children: [
                                  //photo view and title
                                  Padding(
                                    padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: SizedBox(
                                        height: size.height * 0.15,
                                        child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            children: [
                                              const Text(
                                                'שמירת התמונה באוסף',
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                  color: Color(0xFFDFDCE3),
                                                  fontSize: 18,
                                                  fontFamily: 'Arimo',
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),

                                              Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10.0),
                                                  child: buildCachedNetworkImage(
                                                      height: size.width * 0.15,
                                                      width: size.width * 0.15,
                                                      url:  imageList[0],
                                                      radius: 8))
                                            ])),
                                  ),

                                  buildDivider(size: size, isPadding: false),

                                  //add new collection
                                  Padding(
                                      padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: SizedBox(
                                          height: size.height * 0.1,
                                          child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              children: [
                                                //text collections
                                                const Text('אוספים',
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(
                                                        color: Color(
                                                            0xFFDFDCE3),
                                                        fontSize: 18,
                                                        fontFamily: 'Arimo',
                                                        fontWeight: FontWeight
                                                            .w700)),

                                                // open add collection dialog
                                                InkWell(
                                                  // onTap: (){},
                                                  onTap: () =>
                                                      showAddCollectionDialog(
                                                          context: context,
                                                          postModel: postDetailsController
                                                              .postModel.value),
                                                  child: Row(
                                                    children: [
                                                      //plus icon
                                                      SizedBox(
                                                          width: 18,
                                                          child: buildSvgIcon(
                                                              isFill: false,
                                                              borderRadius: 0.0,
                                                              size: size.width *
                                                                  0.002,
                                                              iconPath:
                                                              AppAssets
                                                                  .icPlusIcon,
                                                              afterTapIcon:
                                                              AppAssets
                                                                  .icPlusIcon,
                                                              onClick: () =>
                                                                  showAddCollectionDialog(
                                                                      context: context,
                                                                      postModel:
                                                                      postDetailsController
                                                                          .postModel
                                                                          .value))),

                                                      const SizedBox(width: 5),

                                                      //text add
                                                      const Text('+ אוסף חדש',
                                                          textAlign: TextAlign
                                                              .center,
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xFF9792E8),
                                                              fontSize: 16,
                                                              fontFamily: 'Arimo',
                                                              fontWeight:
                                                              FontWeight.w400))
                                                    ],
                                                  ),
                                                ),
                                              ]))),

                                  //collections list
                                  Expanded(
                                      child: StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('folders')
                                              .where('uid',
                                              isEqualTo:
                                              userController.firebaseId.value)
                                              .snapshots(),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<
                                                  QuerySnapshot<Object?>>
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

                                            final foldersList = snapshot.data!
                                                .docs;

                                            return foldersList.isEmpty
                                                ? Center(
                                                child: const Text(
                                                    "alerts.no_folder",
                                                    style: TextStyle(
                                                        color:
                                                        titleTextWhiteColor,
                                                        fontSize: 18,
                                                        fontWeight:
                                                        FontWeight.w700))
                                                    .tr())
                                                : ListView.builder(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 5),
                                                itemCount: foldersList.length,
                                                shrinkWrap: true,
                                                itemBuilder: (_, index) {
                                                  final CollectionModel collection =
                                                  CollectionModel.fromJson(
                                                      jsonDecode(jsonEncode(
                                                          foldersList[index]
                                                              .data())));

                                                  if (collection.imageUrl ==
                                                      "") {
                                                    FireBaseApi
                                                        .getRandomImageUrlFromFoldersImages(
                                                        collection.fid!)
                                                        .then((value) async {
                                                      if (value != null) {
                                                        final updateFolder =
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                            "folders")
                                                            .doc(collection
                                                            .fid!);
                                                        await updateFolder
                                                            .update(
                                                            {
                                                              "image_url": value
                                                            });
                                                      }
                                                    });
                                                  }

                                                  return Padding(
                                                    padding: EdgeInsets.all(
                                                        size.width * 0.02),
                                                    child: ListTile(
                                                      /*onTap: () async {
                                                      Get.back();
                                                      await FireBaseApi
                                                          .addFolderImage(
                                                          fid: foldersList[
                                                          index]["fid"],
                                                          pid: postModel!.id,
                                                          imageId: postModel!.imageId,
                                                          fimageUrl: postModel!.imageName!);
                                                    },*/
                                                      // title: Text(foldersList[index]
                                                      // ["fname"]),
                                                        title: Text(
                                                            collection.fname!,
                                                            textAlign:
                                                            TextAlign.right,
                                                            style: const TextStyle(
                                                                color: Color(
                                                                    0xFFDFDCE3),
                                                                fontSize: 18,
                                                                fontFamily: 'Arimo',
                                                                fontWeight:
                                                                FontWeight
                                                                    .w400)),
                                                        trailing: Obx(() =>
                                                            buildSvgIcon(
                                                                isFill: postDetailsController
                                                                    .savedFolderList
                                                                    .contains(
                                                                    collection
                                                                        .fid)
                                                                    ? true
                                                                    : false,
                                                                // isFill: isExist ?? false,
                                                                borderRadius: 50.0,
                                                                size: size
                                                                    .width *
                                                                    0.1,
                                                                iconPath: AppAssets
                                                                    .icAddRounded,
                                                                afterTapIcon:
                                                                AppAssets
                                                                    .icAdded,
                                                                onClick: () async {
                                                                  if (postDetailsController
                                                                      .isFirebaseLoading
                                                                      .value)
                                                                    return;
                                                                  postDetailsController
                                                                      .isFirebaseLoading
                                                                      .value =
                                                                  true;
                                                                  FireBaseApi
                                                                      .addFolderImage(
                                                                      fid: foldersList[index]
                                                                      [
                                                                      "fid"],
                                                                      pid: postDetailsController
                                                                          .postModel
                                                                          .value
                                                                          .id,
                                                                      imageId: postDetailsController
                                                                          .postModel
                                                                          .value
                                                                          .imageId,
                                                                      fimageUrl: postDetailsController
                                                                          .postModel
                                                                          .value
                                                                          .imageName!,
                                                                      folderName:
                                                                      collection
                                                                          .fname)
                                                                      .then((
                                                                      value) =>
                                                                  postDetailsController
                                                                      .isFirebaseLoading
                                                                      .value =
                                                                  false);
                                                                })),
                                                        leading:
                                                        Utils.isDataEmpty(
                                                            collection
                                                                .imageUrl)
                                                            ? ClipRRect(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                              10),
                                                          child:
                                                          Image.asset(
                                                            AppAssets
                                                                .galleryPlaceholder,
                                                            height:
                                                            size.width *
                                                                0.15,
                                                            width:
                                                            size.width *
                                                                0.15,
                                                            fit: BoxFit
                                                                .cover,
                                                          ),
                                                        )
                                                            : ClipRRect(
                                                          child:
                                                          buildCachedNetworkImage(
                                                              height: size
                                                                  .width *
                                                                  0.15,
                                                              width: size
                                                                  .width *
                                                                  0.15,
                                                              url: FireBaseApi()
                                                                  .getFirstImageUrl(
                                                                  foldersList[index]
                                                                  [
                                                                  "image_url"]),
                                                              radius:
                                                              10,
                                                              errorWidget:
                                                              ClipRRect(
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    10),
                                                                child:
                                                                Image.asset(
                                                                  AppAssets
                                                                      .galleryPlaceholder,
                                                                  height:
                                                                  size.width *
                                                                      0.15,
                                                                  width:
                                                                  size.width *
                                                                      0.15,
                                                                  fit:
                                                                  BoxFit.cover,
                                                                ),
                                                              )),
                                                        )),
                                                  );
                                                });
                                          }))
                                ],
                              ),
                              btnTitle: tr("collection.new_collection"),
                              isBtnView: false)))),

          //share
          Positioned(
              bottom: 10,
              left: size.width * 0.17,
              child: postDetailsController.isShareLoading.value
                  ? Center(
                child: SizedBox(
                    height: size.width * 0.1,
                    width: size.width * 0.1,
                    child: const CircularProgressIndicator()),
              )
                  : buildSvgIcon(
                  isFill: false,
                  borderRadius: 50.0,
                  size: size.width * 0.12,
                  iconPath: AppAssets.postShareIcon,
                  afterTapIcon: AppAssets.postShareIcon,
                  onClick: () =>
                      ShareData.sharePost(
                          userid: postDetailsController.postModel.value.id ??
                              "",
                          context: context,
                          imageUrl: postDetailsController
                              .postModel.value.imageName))),
        ]));
  }

  buildRelatedPosts({required Size size}) =>
      postDetailsController
          .postModel.value.relatedPosts !=
          null
          ? GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 4, mainAxisSpacing: 4),
          itemCount: postDetailsController.postModel.value.relatedPosts!.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
                padding: const EdgeInsets.all(2.0),
                child: InkWell(
                  // onTap: () => Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (ctx) => PostDetails(
                  //             postId: postDetailsController
                  //                 .postModel.value.relatedPosts![index].id
                  //                 .toString(),
                  //             isArtist: false))),
                  onTap: () =>
                      postDetailsController.navigateToPost(
                          post: postDetailsController.postModel.value,
                          postid: postDetailsController
                              .postModel.value.relatedPosts![index].id
                              .toString(),
                          foldersid: '',
                          wpostId: ''),
                  child: Container(
                    width: size.width * 0.35,
                    height: size.height * 0.19,
                    decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(16)),
                    child: ClipRRect(

                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            width: size.width * 0.44,
                            height: size.height * 0.22,
                            alignment: Alignment.center,
                            imageUrl: WebService.resolveImageUrl(
                                postDetailsController
                                    .postModel.value.relatedPosts![index].imageName
                                    .toString()),
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.low,
                            memCacheWidth: (size.height *
                                0.19 *
                                MediaQuery
                                    .of(context)
                                    .devicePixelRatio)
                                .round(),
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
                                      image: DecorationImage(
                                          image: AssetImage(
                                              AppAssets.imagePlaceHolder),
                                          fit: BoxFit.cover)),
                                ),
                          ),
                          if(postDetailsController.postModel.value
                              .relatedPosts![index].isMultipleImages ==
                              "1")Positioned(
                            top: 10,
                            right: 10,
                            child: SvgPicture.asset(
                                AppAssets.multiImageicon,
                                width: 20,
                                height: 20
                            ),)
                        ],
                      ),
                    ),
                  ),
                ));
          })
          : const SizedBox.shrink();

  Future<void> buildDeletePostDialog(BuildContext context,
      VoidCallback onDelete) async {
    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          StatefulBuilder(
            builder: (context, setState) =>
                AlertDialog(
                  titlePadding: const EdgeInsets.all(1.0),
                  backgroundColor: socialoginbtn,
                  shape:
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(tr("edit_delete_post.delete_title"),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 18,
                                color: titleTextWhiteColor,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),
                        Text(tr("edit_delete_post.delete_subtitle"),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 16,
                                color: titleTextWhiteColor,
                                fontWeight: FontWeight.w400)),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: titleTextWhiteColor,
                                  backgroundColor: const Color(0xFF403D44),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text("ביטול")),
                            const SizedBox(width: 8),
                            Obx(() =>
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: kWhite,
                                      backgroundColor: errorColor,
                                    ),
                                    onPressed: onDelete,
                                    child: postDetailsController.isDeleteLoading
                                        .value
                                        ? Center(
                                      child: RotationTransition(
                                          turns: base,
                                          child: Image.asset(
                                              AppAssets.loadingIcon)),
                                    )
                                        : const Text("מחיקה")))
                          ],
                        )
                      ],
                    ),
                  ),
                ),
          ),
    );
  }
}
