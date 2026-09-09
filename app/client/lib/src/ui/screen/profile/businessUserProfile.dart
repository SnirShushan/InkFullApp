import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/notificationController.dart';
import 'package:ink/src/controller/userController.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/business_dashboard.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/bussinessdashboard_binding.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard_binding.dart';
import 'package:ink/src/ui/widgets/bottomenu/business_dashboard_bottomenu.dart';
import 'package:ink/src/ui/widgets/bottomenu/dashboard_bottomenu.dart';
import 'package:ink/src/ui/widgets/button/custom_gradient_btn_widget.dart';
import 'package:ink/src/ui/widgets/button/gradient_tab_Indicator_widget.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/share_data.dart';
import 'package:ink/src/utils/utils.dart';
import 'package:ink/src/utils/webService.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../controller/businessDetailControllor.dart';
import '../sendTattoRquest/request_for_tattoo.dart';
import 'businessStudioProfile.dart';
import 'currentUserProfile.dart';
import 'widgets/image_grid_widget.dart';
import 'widgets/other_no_image_found.dart';
import 'widgets/other_no_sketch_widget.dart';

class BusinessProfileScreen extends StatefulWidget {
  final String bId;
  final bool fromPost;
  final String dynamictxt;
  final bool isNotificationscreen;

  const BusinessProfileScreen(
      {super.key,
      required this.bId,
      this.isNotificationscreen = false,
      required this.fromPost,
      this.dynamictxt = "dynamicNot"});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen>
    with TickerProviderStateMixin {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  late final BusinessDetailController businessDetailsController;
  final TextEditingController commentTxtController = TextEditingController();
  late final UserController userController;

  late AnimationController animationController;
  late Animation<double> base;
  TabController? tabController;

  String userTypes = "";

  @override
  void initState() {
    super.initState();
    try {
      if (Get.isRegistered<BusinessDetailController>()) {
        Get.delete<BusinessDetailController>(force: true);
      }
    } catch (_) {}
    businessDetailsController = Get.put(BusinessDetailController());
    userController = Get.isRegistered<UserController>()
        ? Get.find<UserController>()
        : Get.put(UserController());
    businessDetailsController.startSketches = 0.obs;

    businessDetailsController.startTattos = 0.obs;
    userTypes = userController.userType.value;

    tabController = TabController(length: 3, vsync: this);
    animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    base = CurvedAnimation(parent: animationController, curve: Curves.easeOut);
    // Trigger async data fetch without blocking UI
    Future.microtask(() => _loadBusinessInfo());
  }

  Future<void> _loadBusinessInfo() async {
    try {
      await businessDetailsController.getBusinessInfo(bid: widget.bId);
    } catch (e) {
      debugPrint("Error loading business info: $e");
    }
  }

  Future<bool> redirectTo() async {
    if (widget.dynamictxt == "DYNAMICTEXT") {
      try {
        final isBusiness = await WebService.getIsBusiness();
        if (businessDetailsController.userTypeProfile.value == "1" ||
            isBusiness == false) {
          Get.offAll(const DashBoard(initialIndex: 0),
              binding: DashBoardBinding());
        } else {
          Get.offAll(BusinessDashBoard(initialIndex: 0),
              binding: BusinessDashBoardBinding());
        }
      } catch (e) {
        displayMessageIcon(
            snackposition: SnackPosition.BOTTOM,
            message: e.toString(),
            color: errorColor,
            imageData: AppAssets.errorIcon);

        WebService.printMsg(e.toString());
      }
    } else {
      if (widget.isNotificationscreen == true) {
        final NotificationController notificationController =
            Get.find<NotificationController>();
        await notificationController.clearNotificationData();
        notificationController.fetchNotifications();
      }
      Navigator.of(context).pop();
    }

    return true;
  }

  @override
  void dispose() {
    animationController.stop();
    animationController.dispose();
    tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;

    final topInset = MediaQuery.viewPaddingOf(context).top;

    return PopScope(
      canPop: true,
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        redirectTo();
      },
      child: Scaffold(
              backgroundColor: bgBlack,
              key: scaffoldKey,
              bottomNavigationBar: userTypes == "2"
                  ? BusinessDashboardBottomBar(
                      currentIndex: 3,
                    )
                  : DashboardBottomBar(currentIndex: 2),
              body: Column(
                children: [
                  // Modern edge-to-edge header: status-bar inset + comfortable toolbar
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      size.width * 0.02,
                      topInset + 16,
                      size.width * 0.02,
                      12,
                    ),
                    child: SizedBox(
                      height: 48,
                      child: buildTopRow(),
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      if (businessDetailsController.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (businessDetailsController.loadError.value.isNotEmpty &&
                          businessDetailsController.id.value.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  businessDetailsController.loadError.value,
                                  textAlign: TextAlign.center,
                                  style: textTheme.titleMedium?.copyWith(
                                    color: titleTextWhiteColor,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: () => _loadBusinessInfo(),
                                  child: const Text('נסה שוב'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.035),
                            child: Column(
                              children: [
                                buildtitleRow(size, textTheme),
                                SizedBox(height: size.height * 0.03),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    /// ✅ Follow Button
                                    if (businessDetailsController.id.value !=
                                        businessDetailsController
                                            .idProfile.value)
                                      Obx(() {
                                        final isLiked =
                                            businessDetailsController
                                                    .liked.value ==
                                                "1";

                                        return GestureDetector(
                                          onTap: () async {
                                            await businessDetailsController
                                                .followUser(
                                              bid: businessDetailsController
                                                  .id.value,
                                              likeStatus: isLiked ? "0" : "1",
                                            );
                                          },
                                          child: Container(
                                            width: size.width * 0.36,
                                            height: size.height * 0.05,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: signInButtonColor,
                                            ),
                                            child: Center(
                                              child: isLiked
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        SvgPicture.asset(
                                                          AppAssets.checkedIcon,
                                                          color:
                                                              titleTextWhiteColor,
                                                        ),
                                                        SizedBox(
                                                            width: size.width *
                                                                0.02),
                                                        Text(
                                                          'במעקב',
                                                          style: textTheme
                                                              .titleMedium!
                                                              .copyWith(
                                                            fontSize: 14,
                                                            color:
                                                                titleTextWhiteColor,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : Text(
                                                "הוסף למעקב",
                                                style: textTheme.titleMedium!
                                                    .copyWith(
                                                  color: titleTextWhiteColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                      ),
                                    ),
                                  );
                                }),

                              /// ✅ Contact Business Button
                              if (businessDetailsController.idProfile.value !=
                                  businessDetailsController.id.value)
                                CustomGradientButtonWidget(
                                  width: size.width * 0.37,
                                  height: size.height * 0.05,
                                  radius: 8,
                                  textSize: 14,
                                  title: "פנייה לעסק",
                                  onTap: () => Get.to(() =>
                                      ScreenTattooRequest(bId: widget.bId)),
                                ),

                              /// ✅ Share Button
                              InkWell(
                                onTap: () {
                                  if (businessDetailsController
                                      .id.value.isNotEmpty) {
                                    ShareData.shareProfile(
                                      username:
                                          businessDetailsController.name.value,
                                      userid:
                                          businessDetailsController.id.value,
                                      sharetype: 'businessUserProfile',
                                      context: context,
                                    );
                                  }
                                },

                                child: Container(
                                  height: size.height * 0.05,
                                  width: size.width * 0.1,
                                  decoration: BoxDecoration(
                                    color: signInButtonColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child:
                                        SvgPicture.asset(AppAssets.shareIcon),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.02),
                          Stack(
                            fit: StackFit.passthrough,
                            alignment: Alignment.bottomCenter,
                            children: <Widget>[
                              Container(
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: textEditingColor, width: 2.0),
                                  ),
                                ),
                              ),
                              TabBar(
                                controller: tabController,
                                padding: EdgeInsets.zero,
                                labelPadding: EdgeInsets.zero,

                                tabs: [
                                  Tab(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(AppAssets.photoIcon),
                                        const SizedBox(width: 2),
                                        Text(
                                          ' תמונות',
                                          style: textTheme.titleSmall!.copyWith(
                                            color: titleTextWhiteColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Tab(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(AppAssets.flashIcon),
                                        const SizedBox(width: 2),
                                        Text(
                                          ' סקיצות',
                                          style: textTheme.titleSmall!.copyWith(
                                            color: titleTextWhiteColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Tab(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(AppAssets.infoIcon),
                                        const SizedBox(width: 1),
                                        FittedBox(
                                          child: Text(
                                            ' מידע נוסף',
                                            style:
                                                textTheme.titleSmall!.copyWith(
                                              color: titleTextWhiteColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.01),
                          Expanded(
                              child: TabBarView(
                            controller: tabController,
                            children: [
                              businessDetailsController.tattoo.isEmpty
                                  ? const OtherNoImageFoundWidget()
                                  : ImageGrid(
                                      controller: businessDetailsController,
                                      scrollController:
                                          businessDetailsController
                                              .scrollControllerTattos,
                                      isArtist: false,
                                      myPostList:
                                          businessDetailsController.tattoo),
                              businessDetailsController.sketch.isEmpty
                                  ? const OtherNoSketchDataContent()
                                  : ImageGrid(
                                      controller: businessDetailsController,
                                      scrollController:
                                          businessDetailsController
                                              .scrollControllerSketches,
                                      isArtist: true,
                                      myPostList:
                                          businessDetailsController.sketch),
                              UserInfo(
                                  businessDetailsController:
                                      businessDetailsController),
                            ],
                          ))
                        ],
                      ),
                    );
                    }),
                  ),
                ],
              ),
            ),
    );
  }

  Row buildtitleRow(Size size, TextTheme textTheme) {
    return Row(
      children: [
        CircleAvatar(
            backgroundColor: Colors.white,
            radius: size.height * 0.042,
            child: WebService.isMissingProfileImage(
                    businessDetailsController.profile_image.value)
                ? Container(
                    height: size.width * 0.25,
                    width: size.width * 0.25,
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(50)),
                        image: DecorationImage(
                            image: AssetImage(AppAssets.userPlaceHolder),
                            fit: BoxFit.cover)),
                  )
                : CachedNetworkImage(
                    imageUrl: WebService.resolveProfileImage(
                        businessDetailsController.profile_image.value),
                    imageBuilder: (context, imageProvider) => Container(
                          height: size.width * 0.25,
                          width: size.width * 0.25,
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50)),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Container(
                          height: size.width * 0.25,
                          width: size.width * 0.25,
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(50)),
                              image: DecorationImage(
                                  image: AssetImage(AppAssets.userPlaceHolder),
                                  fit: BoxFit.cover)),
                        ))),
        SizedBox(
          width: size.width * 0.03,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: size.width * 0.68,
              child: Text(businessDetailsController.name.value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Get.textTheme.titleMedium!.copyWith(
                      color: titleTextWhiteColor, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset(
                  AppAssets.homeIcon,

                  // size: 16,
                ),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  businessDetailsController.business_type.value == "1"
                      ? 'סטודיו'
                      : "אמן",
                  style: textTheme.titleSmall!.copyWith(
                      color: dividerGray, fontWeight: FontWeight.w400),
                ),
                const Text(
                  '  |  ',
                  style: TextStyle(color: titleTextWhiteColor),
                ),
                Row(
                  children: [
                    Text(
                        Utils.isDataEmpty(businessDetailsController.liked.value)
                            ? "0"
                            : businessDetailsController.followers.value,
                        style: textTheme.titleSmall!.copyWith(
                            color: dividerGray, fontWeight: FontWeight.w700)),
                    Text(' עוקבים ',
                        style: textTheme.titleSmall!.copyWith(
                            color: dividerGray, fontWeight: FontWeight.w400)),
                  ],
                )
              ],
            ),
          ],
        )
      ],
    );
  }

  Row buildTopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            icon: SvgPicture.asset(
              AppAssets.backarrowIcon,
              height: 22,
              width: 22,
            ),
            onPressed: () => redirectTo()),
        if (businessDetailsController.id.value.toString() !=
            businessDetailsController.idProfile.value)
          IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              icon: SvgPicture.asset(
                AppAssets.dots3Icon,
                height: 22,
                width: 22,
              ),
              onPressed: () => _showReportDialog(context)),
      ],
    );
  }

  // _openContactDialog(size) {
  //   showModalBottomSheet<dynamic>(
  //       useRootNavigator: true,
  //       isScrollControlled: true,
  //       context: context,
  //       builder: (BuildContext context) {
  //         return FractionallySizedBox(
  //           heightFactor: 0.5,
  //           child: ClipRRect(
  //             borderRadius: BorderRadius.circular(30),
  //             child: Container(
  //               height: size.height * 0.85,
  //               decoration: const BoxDecoration(color: Colors.white),
  //               child: Column(
  //                   mainAxisAlignment: MainAxisAlignment.start,
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: <Widget>[
  //                     Container(
  //                       width: size.width,
  //                       height: size.height * 0.1,
  //                       color: defaultWhite,
  //                       child: Center(
  //                         child: SizedBox(
  //                             width: size.width * 0.05,
  //                             child: Divider(
  //                                 thickness: 4, height: size.height * 0.01)),
  //                       ),
  //                     ),
  //                     buildContainer(
  //                         size: size,
  //                         text: "םייק אל קסע לע חוויד",
  //                         color: Colors.white,
  //                         onClick: () => Get.to(
  //                             () => ScreenTattooRequest(bId: widget.bId))),
  //                     const Divider(thickness: 4),
  //                     buildContainer(
  //                         size: size,
  //                         text: "םילהנב תדמוע אלש תונומת",
  //                         color: Colors.white,
  //                         onClick: () => Get.to(
  //                             () => ScreenTattooRequest(bId: widget.bId))),
  //                     const Divider(thickness: 4),
  //                   ]),
  //             ),
  //           ),
  //         );
  //       });
  // }

  buildContainer(
          {required size, required text, required color, required onClick}) =>
      InkWell(
        onTap: onClick,
        child: Container(
          width: size.width,
          padding: EdgeInsets.symmetric(
              horizontal: size.height * 0.05, vertical: size.height * 0.03),
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: size.height * 0.02))
            ],
          ),
        ),
      );

  //report dialog
  _showReportDialog(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return showModalBottomSheet<dynamic>(
        useRootNavigator: true,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext bc) {
          return FractionallySizedBox(
            heightFactor: 0.22,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              decoration: const BoxDecoration(
                  color: signInButtonColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                      onTap: () => Get.back(),
                      child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.03,
                              horizontal: size.width * 0.4),
                          child: Container(
                              margin: const EdgeInsetsDirectional.only(
                                  start: 1.0, end: 1.0),
                              height: size.height * 0.005,
                              width: size.width * 0.2,
                              color: kDivider))),
                  SizedBox(height: size.height * 0.03),
                  InkWell(
                      onTap: () {
                        Get.back();
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) =>
                              StatefulBuilder(builder: (builder, setstate) {
                            return AlertDialog(
                              titlePadding: const EdgeInsets.all(1.0),
                              backgroundColor: socialoginbtn,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              actionsAlignment: MainAxisAlignment.center,
                              title: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 28),
                                child: Column(
                                  children: [
                                    const Text("דיווח על עסק לא קיים",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: titleTextWhiteColor,
                                            fontWeight: FontWeight.w700)),
                                    SizedBox(height: size.height * 0.015),
                                    Text("נשמח לפרטים נוספים על הדיווח",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .copyWith(
                                                color: titleTextWhiteColor,
                                                fontWeight: FontWeight.w400)),
                                    SizedBox(height: size.height * 0.02),
                                    TextFormField(
                                        autofocus: false,
                                        controller: commentTxtController,
                                        minLines: 5,
                                        maxLines: 7,
                                        keyboardType: TextInputType.multiline,
                                        cursorColor: kWhite,
                                        style: const TextStyle(color: kWhite),
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 4, horizontal: 8),
                                          filled: true,
                                          fillColor: const Color(0xFF403D44),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          hintText: 'פרטו כאן את סיבת הדיווח',
                                          hintStyle: const TextStyle(
                                            color: Color(0xFF6B676F),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.transparent),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.white),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          errorMaxLines: 1,
                                          errorText: null,
                                          errorStyle: const TextStyle(
                                            height: 0,
                                            color: Colors.transparent,
                                            fontSize: 0,
                                          ),
                                        )),

                                    SizedBox(height: Get.size.height * 0.02),
                                    // const SizedBox(height: 24),

                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: size.width * 0.3,
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor:
                                                    titleTextWhiteColor,
                                                backgroundColor:
                                                    const Color(0xFF403D44),
                                              ),
                                              onPressed: () async {
                                                Get.back();
                                              },
                                              child: Text("ביטול",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall!
                                                      .copyWith(
                                                          color:
                                                              titleTextWhiteColor,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14))),
                                        ),
                                        const SizedBox(width: 8),
                                        SizedBox(
                                          width: size.width * 0.3,
                                          child: Obx(() => ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: bgBlack,
                                                backgroundColor: titleTextColor,
                                              ),
                                              onPressed: () async {
                                                if (commentTxtController.text
                                                        .toString() !=
                                                    "") {
                                                  if (businessDetailsController
                                                      .animationLoading
                                                      .value) return;
                                                  businessDetailsController
                                                      .animationLoading
                                                      .value = true;

                                                  animationController.forward();
                                                  animationController.repeat();
                                                  await businessDetailsController
                                                      .reportBusiness(
                                                          bid:
                                                              businessDetailsController
                                                                  .id,
                                                          comment:
                                                              commentTxtController
                                                                  .text)
                                                      .then((value) {
                                                    commentTxtController.text =
                                                        "";
                                                    // Get.back();
                                                    businessDetailsController
                                                        .animationLoading
                                                        .value = false;
                                                    animationController.stop();
                                                  });
                                                } else {
                                                  displayMessageIcon(
                                                      message: "יש להזין הערה",
                                                      color: errorColor,
                                                      imageData:
                                                          AppAssets.errorIcon);
                                                }
                                              },
                                              child: businessDetailsController
                                                      .animationLoading.value
                                                  ? RotationTransition(
                                                      turns: base,
                                                      child: Image.asset(
                                                          AppAssets
                                                              .loadingIcon))
                                                  : Text(
                                                      "שליחת דיווח",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleSmall!
                                                          .copyWith(
                                                              color: bgBlack,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 14),
                                                    ))),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          }),
                        );
                      },
                      child: SizedBox(
                          width: double.infinity,
                          height: size.height * 0.07,
                          child: Text("דיווח על עסק לא קיים",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                      color: titleTextWhiteColor)))),

                  SizedBox(height: size.height * 0.06),
                ],
              ),
            ),
          );
        });
  }
}

class UserInfo extends StatelessWidget {
  final BusinessDetailController businessDetailsController;

  UserInfo({super.key, required this.businessDetailsController});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildtitleMedium700Text(textTheme: textTheme, title: 'מיקום'),
          SizedBox(
            height: size.height * 0.01,
          ),
          InkWell(
            onTap: _launchUrl,
            child: Row(
              children: [
                SvgPicture.asset(
                  AppAssets.locationIcon,
                ),
                const SizedBox(width: 5),
                SizedBox(
                  width: size.width * 0.82,
                  child: buildtitleMedium400Text(
                      textTheme: textTheme,
                      title: businessDetailsController.address.value),
                ),
              ],
            ),
          ),
          SizedBox(
            height: size.height * 0.03,
          ),
          buildtitleMedium700Text(textTheme: textTheme, title: 'תיאור'),
          SizedBox(height: size.height * 0.01),
          buildtitleMedium400Text(
              textTheme: textTheme,
              title: businessDetailsController.about_text.value),
          SizedBox(
            height: size.height * 0.03,
          ),
          if (businessDetailsController.stylesHe.isNotEmpty)
            buildtitleMedium700Text(
                textTheme: textTheme, title: 'התמחות בסגנונות'),
          if (businessDetailsController.stylesHe.isNotEmpty)
            SizedBox(height: size.height * 0.02),
          if (businessDetailsController.stylesHe.isNotEmpty)
            Wrap(
              spacing: 8,
              children: businessDetailsController.stylesHe.map((style) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: signInButtonColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(style,
                      style: textTheme.titleSmall!.copyWith(
                          fontSize: 14,
                          color: dividerGray,
                          fontWeight: FontWeight.w400)),
                );
              }).toList(),
            ),
          SizedBox(
            height: size.height * 0.03,
          ),
          if (businessDetailsController.business_type.value == "1" &&
                  businessDetailsController.artistsList.isNotEmpty ||
              businessDetailsController.business_type.value == "2" &&
                  businessDetailsController.studiosList.isNotEmpty)
            buildtitleMedium700Text(
                textTheme: textTheme,
                title: businessDetailsController.business_type.value == "1"
                    ? 'המקעקעים בסטודיו'
                    : 'מקעקע בסטודיו'),
          if (businessDetailsController.business_type.value == "1" &&
                  businessDetailsController.artistsList.isNotEmpty ||
              businessDetailsController.business_type.value == "2" &&
                  businessDetailsController.studiosList.isNotEmpty)
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: size.height * 0.6, // Adjust this value as needed
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // Number of columns
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 16.0,
                    childAspectRatio:
                        1 //1 / 1.2, // Adjust this to change item height
                    ),
                itemCount: businessDetailsController.business_type.value == "1"
                    ? businessDetailsController.artistsList.length
                    : businessDetailsController.studiosList.length,
                itemBuilder: (context, index) {
                  final artists =
                      businessDetailsController.business_type.value == "1"
                          ? businessDetailsController.artistsList[index]
                          : businessDetailsController.studiosList[index];

                  return InkWell(
                    onTap: () async {
                      final artistId = artists.id?.toString() ?? "";
                      if (artistId.isEmpty || artistId == "null") return;
                      AppUser user = await WebService.getCurrentUser();
                      final myId = user.profile?.id?.toString() ?? "";
                      if (myId.isNotEmpty && myId == artistId) {
                        Get.to(() =>
                            const Profilescreen(isDrawerOpened: false));
                      } else {
                        Get.to(() => StudioProfileScreen(
                            bId: artistId, fromPost: true));
                      }
                    },
                    child: Column(
                      children: [
                        (artists.profileImage.toString().isEmpty ||
                                artists.profileImage == null ||
                                artists.profileImage.toString() == "")
                            ? Container(
                                height: size.width * 0.15,
                                width: size.width * 0.15,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(50)),
                                    image: DecorationImage(
                                      image: AssetImage(
                                          AppAssets.galleryPlaceholder),
                                      fit: BoxFit.cover,
                                    )),
                              )
                            : CachedNetworkImage(
                                imageUrl: WebService.resolveProfileImage(
                                    artists.profileImage),
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                      height: size.width * 0.15,
                                      width: size.width * 0.15,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(50)),
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => Container(
                                      height: size.width * 0.15,
                                      width: size.width * 0.15,
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(50)),
                                          image: DecorationImage(
                                            image: AssetImage(
                                                AppAssets.galleryPlaceholder),
                                            fit: BoxFit.cover,
                                          )),
                                    )),
                        SizedBox(height: size.height * 0.01),
                        SizedBox(
                            width: size.width * 0.4,
                            child: Text(
                              artists.name!,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: textTheme.titleMedium!.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: dividerGray),
                            ))
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Text buildtitleMedium700Text(
          {required TextTheme textTheme, required String title}) =>
      Text(
        title,
        style: textTheme.titleMedium!.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: titleTextWhiteColor),
      );

  Text buildtitleMedium400Text(
          {required TextTheme textTheme, required String title}) =>
      Text(
        title,
        style: textTheme.titleMedium!.copyWith(
            fontSize: 16, fontWeight: FontWeight.w400, color: dividerGray),
      );

  Future<void> _launchUrl() async {
    final Uri mapUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${businessDetailsController.address_lat.value},${businessDetailsController.address_lng.value}');
    if (!await launchUrl(mapUrl)) {
      throw 'Could not launch $mapUrl';
    }
  }
}
