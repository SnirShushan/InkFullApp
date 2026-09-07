import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/StartupController.dart';
import 'package:ink/src/controller/myPostController.dart';
import 'package:ink/src/controller/userController.dart';
import 'package:ink/src/data/model/check_subscription_model.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/ui/screen/profile/drawer/business_profile_menu_screen.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/share_data.dart';
import 'package:ink/src/utils/webService.dart';
import 'package:url_launcher/url_launcher.dart';

import 'businessUserProfile.dart';
import 'editProfile/edit_profile.dart';
import 'widgets/no_image_widget.dart';
import 'widgets/no_sketch_widget.dart';
import 'widgets/own_image_grid.dart';
import 'widgets/upgrade_plan_widget.dart';

class Profilescreen extends StatefulWidget {
  final bool isDrawerOpened;

  const Profilescreen({super.key, required this.isDrawerOpened});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen>
    with SingleTickerProviderStateMixin,RouteAware,  WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  TabController? tabController;
  MyPostsController myPostsController = Get.put(MyPostsController());
  final userController = Get.put(UserController());

  final startupController = Get.put(StartupController());

  @override
  void initState() {

    tabController = TabController(
        length: 3,
        vsync: this,
        initialIndex: 0,
        animationDuration: Duration.zero);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scaffoldKey.currentState?.openEndDrawer();
    });
    WidgetsBinding.instance.addObserver(this);
    myPostsController.getMyPosts();

    super.initState();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   if (state == AppLifecycleState.resumed && WebService.shouldRefresh==true) {
  //     WebService.shouldRefresh= false;
  //     myPostsController.getMyPosts();
  //   }
  // }









  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    scaffoldKey.currentState?.closeDrawer();
    myPostsController.selectedIndex.value = 0;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;

    return Obx(() => Scaffold(
          key: scaffoldKey,
          backgroundColor: bgBlack,
          // drawer: const BusinessProfileMenuScreen(
          //   iscurrentUserProfile: true,
          // ),
          body: Padding(
            padding: EdgeInsets.only(
              // Match artist/studio: status-bar inset + modern breathing room
              top: MediaQuery.viewPaddingOf(context).top + 16,
              left: size.width * 0.035,
              right: size.width * 0.035,
              bottom: 0,
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: size.height * 0.042,
                        child: WebService.isMissingProfileImage(
                                userController.profileimage.value)
                            ? Container(
                                height: size.width * 0.25,
                                width: size.width * 0.25,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(50)),
                                    image: DecorationImage(
                                      image: AssetImage(
                                          AppAssets.userPlaceHolder),
                                      fit: BoxFit.cover,
                                    )),
                              )
                            : CachedNetworkImage(
                            imageUrl: WebService.resolveProfileImage(
                                userController.profileimage.value),
                            imageBuilder: (context, imageProvider) => Container(
                                  height: size.width * 0.25,
                                  width: size.width * 0.25,
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
                                  height: size.width * 0.25,
                                  width: size.width * 0.25,
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(50)),
                                      image: DecorationImage(
                                          image: AssetImage(
                                              AppAssets.userPlaceHolder),
                                          fit: BoxFit.cover)),
                                )),
                      ),
                    SizedBox(
                      width: size.width * 0.03,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userController.name.value,
                            maxLines: 2,
                            style: textTheme.titleMedium!.copyWith(
                                color: titleTextWhiteColor, fontSize: 16),
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
                                userController.businessType.value == "1"
                                    ? 'סטודיו'
                                    : "אמן",
                                style: textTheme.bodySmall!.copyWith(
                                    color: dividerGray,
                                    fontWeight: FontWeight.w400),
                              ),
                              const Text(
                                '  |  ',
                                style: TextStyle(color: titleTextWhiteColor),
                              ),
                              Row(
                                children: [
                                  Text(WebService.followUsers,
                                      style: textTheme.bodyMedium!.copyWith(
                                          color: dividerGray,
                                          fontWeight: FontWeight.w700)),
                                  Text(' עוקבים ',
                                      style: textTheme.bodyMedium!.copyWith(
                                          color: dividerGray,
                                          fontWeight: FontWeight.w400)),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      splashColor: Colors.white70,
                      onTap: () async {
                        await Network.getCheckSubscription().then((value) {
                          CheckSubscriptionModel subscriptionModel =
                              CheckSubscriptionModel(subscriptionStatus: 0);
                          subscriptionModel =
                              CheckSubscriptionModel.fromJson(value["data"]);

                          if ((subscriptionModel != null &&
                                  subscriptionModel.isPremium.toString() ==
                                      "1") ||
                              (value['data'] != null &&
                                  value['data']['is_premium'].toString() ==
                                      "1")) {
                            Get.to(() => const BusinessProfileMenuScreen(
                                iscurrentUserProfile: true,
                                isPremiumPlanBuy: true));
                          } else {
                            Get.to(() => const BusinessProfileMenuScreen(
                                iscurrentUserProfile: true));
                          }
                        });

                        // scaffoldKey.currentState?.openDrawer();
                      },
                      child: Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: signInButtonColor,
                          borderRadius: BorderRadius.circular(
                              8.0), // Adjust the radius as needed
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.menu,
                            color: titleTextWhiteColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: size.height * 0.03,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () => checksubscriptionData(),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: signInButtonColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                AppAssets.editIcon,
                                height: 20,
                                color: titleTextWhiteColor,
                              ),
                              const SizedBox(width: 8),
                              Text('עריכת פרופיל',
                                  style: textTheme.titleSmall!.copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: titleTextWhiteColor)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            ShareData.shareProfile(
                                userid: userController.id,
                                sharetype: 'mainprofile',
                                context: context);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: signInButtonColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                AppAssets.shareIcon,
                                //height: 20,
                                //color: titleTextWhiteColor,
                              ),
                              const SizedBox(width: 8),
                              Text('שיתוף פרופיל',
                                  style: textTheme.titleSmall!.copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: titleTextWhiteColor)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: size.height * 0.03,
                ),
                Stack(
                  fit: StackFit.passthrough,
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: textEditingColor, width: 2.0),
                        ),
                      ),
                    ),
                    TabBar(
                      padding: EdgeInsets.zero,

                      controller: tabController,
                      labelPadding: EdgeInsets.zero,
                      // individual tab internal padding

                      onTap: (index) async {
                        myPostsController.isDataLoading.value = true;

                        try {
                          // Handle only index 0 and 1 with subscription checks
                          if (index == 0 || index == 1) {
                            bool isConnected =
                                await WebService.checkConnectionNoMsg();
                            if (!isConnected) return;

                            final value = await Network.getCheckSubscription();

                            if (value == null || value == false) return;

                            final isStatusZero =
                                value['status'].toString() == "0";
                            final isSubscriptionInactive = value['data']
                                        ['subscription_status']
                                    .toString() ==
                                "0";
                            final isPremiumUser =
                                value['data']['is_premium'].toString() != "0";

                            final needsSubscriptionCheck =
                                isStatusZero && isSubscriptionInactive ||
                                    (index == 1 && !isPremiumUser);

                            myPostsController.selectedIndex.value = index;

                            if (needsSubscriptionCheck) {
                              // Free user access allowed
                              if (index == 0) {
                                myPostsController.isDrawingsubscription.value =
                                    true;
                              } else {
                                myPostsController.isSketchsubscription.value =
                                    true;
                              }
                            } else {
                              // Premium check for user
                              await startupController.checkSubscription();
                              if (index == 0) {
                                myPostsController.isDrawingsubscription.value =
                                    false;
                              } else {
                                myPostsController.isSketchsubscription.value =
                                    false;
                              }
                            }
                          } else {
                            // For other indices, no subscription checks needed
                            myPostsController.selectedIndex.value = index;
                            if (index == 0) {
                              myPostsController.isDrawingsubscription.value =
                                  false;
                            } else {
                              myPostsController.isSketchsubscription.value =
                                  false;
                            }
                          }
                        } finally {
                          myPostsController.isDataLoading.value = false;
                        }
                      },

                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(AppAssets.photoIcon),
                              const SizedBox(width: 2),
                              const Text(
                                ' תמונות',
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(AppAssets.flashIcon),
                              const SizedBox(width: 2),
                              const Text(
                                ' סקיצות',
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(AppAssets.infoIcon),
                              const SizedBox(width: 2),
                              const Text(' מידע נוסף'),
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
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Obx(() => myPostsController.isDataLoading.value
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : myPostsController.tattoo.isEmpty
                            ? const NoImageDataContent()
                            : OwnImageGrid(
                                controller: myPostsController,
                                isArtist: false,
                                myPostList: myPostsController.tattoo)),
                    Obx(() => myPostsController.isDataLoading.value
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : startupController.subscriptiondata.value ==
                                    "User_Not_Found" ||
                                myPostsController.isSketchsubscription.value
                            ? UpgradePlanContent()
                            : myPostsController.sketch.isEmpty
                                ? NoSketchDataContent()
                                : OwnImageGrid(
                                    controller: myPostsController,
                                    isArtist: true,
                                    myPostList: myPostsController.sketch)),
                    Obx(() => myPostsController.isDataLoading.value
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : MoreInfoScreen(
                            myPostsController: myPostsController,
                            userController: userController,
                          ))
                  ],
                )),
              ],
            ),
          ),
        ));
  }

  Future<void> checksubscriptionData() async {
    // var checksubscription;
    // if (WebService.isSubscriptionEnable) {
    //   await Network.getCheckSubscription().then((value) async {
    //     checksubscription = value;
    //   });
    //
    //   if (checksubscription['status'].toString() == "1" &&
    //       checksubscription['data']['subscription_status'].toString() == "1") {
    //     Get.to(() => const EditProfile());
    //   } else {
    //     needSubscriptionDialog(context);
    //   }
    // } else {
    bool isConnected = await WebService.checkConnectionNoMsg();

    if (!isConnected) {
      return;
    } else {
      Get.to(const EditProfile());
    }
    // }
  }
}

class MoreInfoScreen extends StatelessWidget {
  final UserController userController;
  final MyPostsController myPostsController;

  const MoreInfoScreen(
      {Key? key, required this.userController, required this.myPostsController})
      : super(key: key);

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
                      title: userController.address.value),
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
              textTheme: textTheme, title: userController.about_text.value),
          SizedBox(
            height: size.height * 0.03,
          ),
          buildtitleMedium700Text(
              textTheme: textTheme, title: 'התמחות בסגנונות'),
          SizedBox(height: size.height * 0.02),
          Obx(() => Wrap(
                spacing: 8.0,
                runSpacing: 2.0,
                alignment: WrapAlignment.start,
                children: myPostsController.stylesHe.map((style) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    decoration: BoxDecoration(
                      color: signInButtonColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(style,
                        style:
                            const TextStyle(fontSize: 14, color: dividerGray)),
                  );
                }).toList(),
              )),
          SizedBox(
            height: size.height * 0.03,
          ),
          buildtitleMedium700Text(
              textTheme: textTheme,
              title: userController.businessType.value == "2"
                  ? 'מקעקע בסטודיו'
                  : "מקעקעים בסטודיו"),
          SizedBox(
            height: size.height * 0.02,
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: size.height * 0.6, // Adjust this value as needed
            ),
            child: Obx(() => GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, // Number of columns
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 16.0,
                      childAspectRatio:
                          1 //1 / 1.2, // Adjust this to change item height
                      ),
                  itemCount: userController.businessType.value == "2"
                      ? myPostsController.userStudioList.length
                      : myPostsController.userArtistList.length,
                  itemBuilder: (context, index) {
                    final artists = userController.businessType.value == "2"
                        ? myPostsController.userStudioList[index]
                        : myPostsController.userArtistList[index];
                    if (userController.businessType.value == "2"
                        ? myPostsController.userStudioList.isEmpty
                        : myPostsController.userArtistList.isEmpty) {
                      return Center(
                          child: userController.businessType.value == "2"
                              ? const Text("alerts.no_artist_found").tr()
                              : const Text("alerts.no_studio_found").tr());
                    }
                    return InkWell(
                      onTap: () => Get.to(() => BusinessProfileScreen(
                          bId: artists!.id!, fromPost: false)),
                      child: Column(
                        children: [
                          CachedNetworkImage(
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
                          Text(
                            artists.name!,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleMedium!.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: dividerGray),
                          )
                        ],
                      ),
                    );
                  },
                )),
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
        'https://www.google.com/maps/search/?api=1&query=${userController.address_lat.value},${userController.address_lng.value}');
    if (!await launchUrl(mapUrl)) {
      throw 'Could not launch $mapUrl';
    }
  }
}
