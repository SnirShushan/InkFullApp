import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/business_dashboard.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/bussinessdashboard_binding.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard_binding.dart';
import 'package:ink/src/ui/widgets/bottomenu/business_dashboard_bottomenu.dart';
import 'package:ink/src/ui/widgets/bottomenu/dashboard_bottomenu.dart';
import 'package:ink/src/ui/widgets/button/custom_gradient_btn_child_widget.dart';
import 'package:ink/src/ui/widgets/button/custom_gradient_btn_widget.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/share_data.dart';
import 'package:ink/src/utils/utils.dart';
import 'package:ink/src/utils/webService.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../controller/userController.dart';
import '../sendTattoRquest/request_for_tattoo.dart';
import 'businessUserProfile.dart';
import 'controller/studioDetailControllor.dart';
import 'widgets/image_grid_widget.dart';
import 'widgets/other_no_image_found.dart';
import 'widgets/other_no_sketch_widget.dart';

class StudioProfileScreen extends StatefulWidget {
  final String bId;
  final bool fromPost;
  final String dynamictxt;

  const StudioProfileScreen(
      {super.key,
      required this.bId,
      required this.fromPost,
      this.dynamictxt = "dynamicNot"});

  @override
  State<StudioProfileScreen> createState() => _StudioProfileScreenState();
}

class _StudioProfileScreenState extends State<StudioProfileScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController animationController;
  late Animation<double> base;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final studioDetailsController = Get.put(StudioDetailController());
  final userController = Get.put(UserController());
  final TextEditingController commentTxtController = TextEditingController();

  // final startupController = Get.put(StartupController());
  TabController? tabController;
  String userTypes = "";

  @override
  void initState() {
    userTypes = userController.userType.value;
    studioDetailsController.startTattos = 0.obs;
    studioDetailsController.startSketches = 0.obs;

    super.initState();
    tabController = TabController(length: 3, vsync: this);
    animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    base = CurvedAnimation(parent: animationController, curve: Curves.easeOut);
    Future.microtask(() {
      studioDetailsController.getBusinessInfo(bid: widget.bId);
    });
  }

  Future<bool> redirectTo() async {
    if (widget.dynamictxt == "DYNAMICTEXT") {
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
            Get.to(
                BusinessDashBoard(
                  initialIndex: 0,
                ),
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
      });
    } else {
      Navigator.of(context).pop();
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;

    final topInset = MediaQuery.viewPaddingOf(context).top;

    return PopScope(
      canPop: true,
      onPopInvoked: (bool didPop) => redirectTo,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
            key: scaffoldKey,
            backgroundColor: bgBlack,
            bottomNavigationBar: userTypes == "2"
                ? BusinessDashboardBottomBar(
                    currentIndex: 3,
                  )
                : DashboardBottomBar(currentIndex: 2),
            body: Column(
              children: [
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
                  child: Obx(() => studioDetailsController.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.035),
                          child: Column(
                            children: [
                              buildtitleRow(
                                  size, textTheme, studioDetailsController),
                              SizedBox(height: size.height * 0.02),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Obx(() {
                                    final isLiked =
                                        studioDetailsController.liked.value ==
                                            "1";

                                    return GestureDetector(
                                        onTap: () async {
                                          await studioDetailsController
                                              .followUser(
                                            bid: studioDetailsController
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
                                              gradient: isLiked
                                                  ? appLinearGradient
                                                  : null,
                                              color: isLiked
                                                  ? null
                                                  : signInButtonColor,
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
                                      )));
                            }),

                            if ((userController.id.value !=
                                studioDetailsController.id.value))
                              CustomGradientButtonWidget(
                                width: size.width * 0.38,
                                title: "פנייה לעסק",
                                onTap: () => Get.to(
                                    () => ScreenTattooRequest(bId: widget.bId)),
                              ),
                            InkWell(
                              splashColor: Colors.white70,
                              onTap: () {
                                ShareData.shareProfile(
                                    username:
                                        studioDetailsController.name.toString(),
                                    userid: studioDetailsController.id,
                                    sharetype: 'businessStudioProfile',
                                    context: context);
                                scaffoldKey.currentState?.openDrawer();
                              },
                              child: Container(
                                height: size.height * 0.05,
                                width: size.width * 0.1,
                                decoration: BoxDecoration(
                                  color: signInButtonColor,
                                  borderRadius: BorderRadius.circular(
                                      8.0), // Adjust the radius as needed
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    AppAssets.shareIcon,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.03),
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
                              padding: EdgeInsets.zero,
                              labelPadding: EdgeInsets.zero,
                              tabs: [
                                Tab(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(AppAssets.photoIcon),
                                      const SizedBox(width: 8),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(AppAssets.flashIcon),
                                      const SizedBox(width: 8),
                                      const Text(
                                        ' סקיצות',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                Tab(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(AppAssets.infoIcon),
                                      const SizedBox(width: 8),
                                      const Text(
                                        ' מידע נוסף',
                                        style: TextStyle(fontSize: 14),
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
                          children: [
                            studioDetailsController.tattoo.isEmpty
                                ? const OtherNoImageFoundWidget()
                                : ImageGrid(
                                    controller: studioDetailsController,
                                    scrollController: studioDetailsController
                                        .scrollControllerSketches,
                                    isArtist: false,
                                    myPostList: studioDetailsController.tattoo),
                            studioDetailsController.sketch.isEmpty
                                ? const OtherNoSketchDataContent()
                                : ImageGrid(
                                    controller: studioDetailsController,
                                    scrollController: studioDetailsController
                                        .scrollControllerTattos,
                                    isArtist: true,
                                    myPostList: studioDetailsController.sketch),
                            businessStudioProfileInfo(
                                studioDetailsController:
                                    studioDetailsController),
                          ],
                        ))
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // buildCachedNetworkImageGrid({required size, required String url}) =>
  //     CachedNetworkImage(
  //         imageUrl: url,
  //         imageBuilder: (context, imageProvider) => Container(
  //               margin: EdgeInsets.all(size.width * 0.002),
  //               height: size.width * 0.1,
  //               width: size.width * 0.1,
  //               decoration: BoxDecoration(
  //                   image: DecorationImage(
  //                       image: imageProvider, fit: BoxFit.cover)),
  //             ),
  //         progressIndicatorBuilder: (context, url, downloadProgress) =>
  //             SizedBox(
  //               height: size.height * 0.1,
  //               width: size.width * 0.1,
  //               child: Center(
  //                   child: CircularProgressIndicator(
  //                       value: downloadProgress.progress)),
  //             ),
  //         errorWidget: (context, url, error) => const Icon(Icons.error));

  // Future<void> _launchUrl() async {
  //   final Uri mapUrl = Uri.parse(
  //       'https://www.google.com/maps/search/?api=1&query=${studioDetailsController.address_lat.value},${studioDetailsController.address_lng.value}');
  //   if (!await launchUrl(mapUrl)) {
  //     throw 'Could not launch $mapUrl';
  //   }
  // }

  // _openContactDialog(size) => () {
  //   showModalBottomSheet(
  //       context: context,
  //       isScrollControlled: true,
  //       builder: (context) {
  //         return StatefulBuilder(
  //             builder: (BuildContext context, StateSetter state) {
  //               return FractionallySizedBox(
  //                 heightFactor: 0.5,
  //                 child: ClipRRect(
  //                   borderRadius: BorderRadius.circular(30),
  //                   child: Container(
  //                     height: size.height * 0.85,
  //                     decoration: const BoxDecoration(color: Colors.white),
  //                     child: Column(
  //                         mainAxisAlignment: MainAxisAlignment.start,
  //                         mainAxisSize: MainAxisSize.min,
  //                         children: <Widget>[
  //                           Container(
  //                             width: size.width,
  //                             height: size.height * 0.1,
  //                             color: defaultWhite,
  //                             child: Center(
  //                               child: SizedBox(
  //                                   width: size.width * 0.05,
  //                                   child: Divider(
  //                                       thickness: 4,
  //                                       height: size.height * 0.01)),
  //                             ),
  //                           ),
  //                           buildContainer(
  //                               size: size,
  //                               text: "םייק אל קסע לע חוויד",
  //                               color: Colors.white,
  //                               onClick: () => Get.to(() =>
  //                                   ScreenTattooRequest(bId: widget.bId))),
  //                           const Divider(thickness: 4),
  //                           buildContainer(
  //                               size: size,
  //                               text: "םילהנב תדמוע אלש תונומת",
  //                               color: Colors.white,
  //                               onClick: () => Get.to(() =>
  //                                   ScreenTattooRequest(bId: widget.bId))),
  //                           const Divider(thickness: 4),
  //                         ]),
  //                   ),
  //                 ),
  //               );
  //             });
  //       });
  // };

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
  // _showReportDialog(BuildContext context) {
  //   var size = MediaQuery.of(context).size;
  //   return showModalBottomSheet<dynamic>(
  //       useRootNavigator: true,
  //       isScrollControlled: true,
  //       context: context,
  //       builder: (BuildContext bc) {
  //         return FractionallySizedBox(
  //           heightFactor: 0.18,
  //           child: Container(
  //             padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
  //             decoration: const BoxDecoration(
  //                 color: Color(0xFF2B272F),
  //                 borderRadius: BorderRadius.only(
  //                     topLeft: Radius.circular(16),
  //                     topRight: Radius.circular(16))),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 InkWell(
  //                     onTap: () => Get.back(),
  //                     child: Padding(
  //                         padding: EdgeInsets.symmetric(
  //                             vertical: size.height * 0.03,
  //                             horizontal: size.width * 0.4),
  //                         child: Container(
  //                             margin: const EdgeInsetsDirectional.only(
  //                                 start: 1.0, end: 1.0),
  //                             height:
  //                                 MediaQuery.of(context).size.height * 0.005,
  //                             width: MediaQuery.of(context).size.width * 0.2,
  //                             color: kDivider))),
  //                 InkWell(
  //                     onTap: () {
  //                       Get.back();
  //                       showDialog<String>(
  //                         context: context,
  //                         builder: (BuildContext context) =>
  //                             StatefulBuilder(builder: (builder, setstate) {
  //                           return AlertDialog(
  //                             titlePadding: const EdgeInsets.all(1.0),
  //                             shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(20)),
  //                             title: Padding(
  //                               padding: EdgeInsets.all(Get.size.width * 0.05),
  //                               child: Stack(
  //                                 clipBehavior: Clip.none,
  //                                 children: [
  //                                   Column(
  //                                     children: [
  //                                       const Text("דיווח על עסק לא קיים"),
  //                                       SizedBox(
  //                                           height: Get.size.height * 0.02),
  //                                       TextFormFieldWidget(
  //                                           controller: commentTxtController,
  //                                           minlines: 5,
  //                                           maxlines: 7,
  //                                           titleText: 'הערות',
  //                                           //comments
  //                                           hintText: 'ניתן להוסיף הערה כאן',
  //                                           //You can add a comment here
  //                                           keyboardType:
  //                                               TextInputType.multiline),
  //                                       SizedBox(
  //                                           height: Get.size.height * 0.02),
  //                                       CustomButton(
  //                                           customtitle: 'שלח', //Send
  //                                           txtColor: Colors.white,
  //                                           customcolor:
  //                                               Theme.of(context).primaryColor,
  //                                           onPressed: () async {
  //                                             Get.back();
  //                                             // if (commentTxtController.text.isNotEmpty) {
  //                                             await studioDetailsController
  //                                                 .reportBusiness(
  //                                                     bid:
  //                                                         studioDetailsController
  //                                                             .id,
  //                                                     comment:
  //                                                         commentTxtController
  //                                                             .text)
  //                                                 .then((value) {
  //                                               commentTxtController.text = "";
  //                                             });
  //                                             // }
  //                                           }),
  //                                     ],
  //                                   ),
  //                                   Positioned(
  //                                     right: -Get.size.width * 0.08,
  //                                     top: -Get.size.width * 0.08,
  //                                     child: InkWell(
  //                                       onTap: () => Get.back(),
  //                                       child: CircleAvatar(
  //                                           backgroundColor: defaultGrey,
  //                                           child: Icon(Icons.close,
  //                                               color: defaultWhite)),
  //                                     ),
  //                                   )
  //                                 ],
  //                               ),
  //                             ),
  //                           );
  //                         }),
  //                       );
  //                     },
  //                     child: SizedBox(
  //                         width: double.infinity,
  //                         height: size.height * 0.07,
  //                         child: Text("דיווח על עסק",
  //                             style: Theme.of(context)
  //                                 .textTheme
  //                                 .titleLarge!
  //                                 .copyWith(
  //                                     fontSize: 18,
  //                                     fontWeight: FontWeight.w400,
  //                                     color: titleTextWhiteColor)))),
  //               ],
  //             ),
  //           ),
  //         );
  //       });
  // }

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
                  color: Color(0xFF2B272F),
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
                                          fillColor: Color(0xFF403D44),
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

                                    // TextFormFieldWidget(
                                    //     controller: commentTxtController,
                                    //     minlines: 5,
                                    //     maxlines: 7,
                                    //     titleText: 'הערות',
                                    //     //comments
                                    //     hintText: 'ניתן להוסיף הערה כאן',
                                    //     //You can add a comment here
                                    //     keyboardType:
                                    //     TextInputType.multiline),
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
                                                if (commentTxtController.text
                                                        .toString() !=
                                                    "") {
                                                  if (studioDetailsController
                                                      .animationLoading
                                                      .value) return;
                                                  studioDetailsController
                                                      .animationLoading
                                                      .value = true;

                                                  await studioDetailsController
                                                      .reportBusiness(
                                                          bid:
                                                              studioDetailsController
                                                                  .id,
                                                          comment:
                                                              commentTxtController
                                                                  .text)
                                                      .then((value) {
                                                    commentTxtController.text =
                                                        "";
                                                    animationController.stop();
                                                    // Get.back();
                                                  });
                                                } else {
                                                  displayMessageIcon(
                                                      message: "יש להזין הערה",
                                                      color: errorColor,
                                                      imageData:
                                                          AppAssets.errorIcon);
                                                }
                                              },
                                              child: studioDetailsController
                                                      .animationLoading.value
                                                  ? RotationTransition(
                                                      turns: base,
                                                      child: Image.asset(
                                                          AppAssets
                                                              .loadingIcon))
                                                  : Text("שליחת דיווח",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleSmall!
                                                          .copyWith(
                                                              color:
                                                                  titleTextWhiteColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 14))),
                                        ),
                                        const SizedBox(width: 4),
                                        SizedBox(
                                          width: size.width * 0.3,
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: bgBlack,
                                                backgroundColor: titleTextColor,
                                              ),
                                              onPressed: () async {
                                                Get.back();
                                              },
                                              child: Text(
                                                "ביטול",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall!
                                                    .copyWith(
                                                        color: bgBlack,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 14),
                                              )),
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
                ],
              ),
            ),
          );
        });
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

  Row buildtitleRow(Size size, TextTheme textTheme,
      StudioDetailController studioDetailsController) {
    return Row(
      children: [
        CircleAvatar(
            backgroundColor: Colors.white,
            radius: size.height * 0.042,
            child: studioDetailsController.profile_image.value == ""
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
                    imageUrl: studioDetailsController.profile_image.value,
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
              child: Text(studioDetailsController.name.value,
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
                  studioDetailsController.business_type.value == "1"
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
                        Utils.isDataEmpty(studioDetailsController.liked.value)
                            ? "0"
                            : studioDetailsController.followers.value,
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
}

class businessStudioProfileInfo extends StatelessWidget {
  final StudioDetailController studioDetailsController;

  businessStudioProfileInfo({super.key, required this.studioDetailsController});

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
                      title: studioDetailsController.address.value),
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
              title: studioDetailsController.about_text.value),
          SizedBox(
            height: size.height * 0.03,
          ),
          if (studioDetailsController.stylesHe.isNotEmpty)
            buildtitleMedium700Text(
                textTheme: textTheme, title: 'התמחות בסגנונות'),
          if (studioDetailsController.stylesHe.isNotEmpty)
            SizedBox(height: size.height * 0.02),
          if (studioDetailsController.stylesHe.isNotEmpty)
            Wrap(
              spacing: 8,
              children: studioDetailsController.stylesHe.map((style) {
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
          if (studioDetailsController.business_type.value == "1" &&
                  studioDetailsController.artistsList.isNotEmpty ||
              studioDetailsController.business_type.value == "2" &&
                  studioDetailsController.studiosList.isNotEmpty)
            SizedBox(
              height: size.height * 0.03,
            ),
          if (studioDetailsController.business_type.value == "1" &&
                  studioDetailsController.artistsList.isNotEmpty ||
              studioDetailsController.business_type.value == "2" &&
                  studioDetailsController.studiosList.isNotEmpty)
            buildtitleMedium700Text(
                textTheme: textTheme,
                title: studioDetailsController.business_type.value == "1"
                    ? 'המקעקעים בסטודיו'
                    : 'מקעקע בסטודיו'),
          if (studioDetailsController.business_type.value == "1" &&
                  studioDetailsController.artistsList.isNotEmpty ||
              studioDetailsController.business_type.value == "2" &&
                  studioDetailsController.studiosList.isNotEmpty)
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
                itemCount: studioDetailsController.business_type.value == "1"
                    ? studioDetailsController.artistsList.length
                    : studioDetailsController.studiosList.length,
                itemBuilder: (context, index) {
                  final artists =
                      studioDetailsController.business_type.value == "1"
                          ? studioDetailsController.artistsList[index]
                          : studioDetailsController.studiosList[index];

                  return InkWell(
                    onTap: () async {
                      AppUser user = await WebService.getCurrentUser();
                      if ((user.profile!.id == artists.id!)) {
                        Get.offAll(
                            () => BusinessDashBoard(
                                  initialIndex: 4,
                                ),
                            binding: BusinessDashBoardBinding());
                      } else {
                        Get.off(() => BusinessProfileScreen(
                            bId: artists.id!, fromPost: true));
                      }
                    },
                    child: Column(
                      children: [
                        artists.profileImage!.toString() == ""
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
        'https://www.google.com/maps/search/?api=1&query=${studioDetailsController.address_lat.value},${studioDetailsController.address_lng.value}');
    if (!await launchUrl(mapUrl)) {
      throw 'Could not launch $mapUrl';
    }
  }
}
