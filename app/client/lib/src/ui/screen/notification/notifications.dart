import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/business_dashboard.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/bussinessdashboard_binding.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard_binding.dart';
import 'package:ink/src/ui/screen/home/controller/home_screen_controller.dart';
import 'package:ink/src/ui/screen/notification/widget/notification_list_widget.dart';
import 'package:ink/src/ui/widgets/bottomenu/business_dashboard_bottomenu.dart';
import 'package:ink/src/ui/widgets/bottomenu/dashboard_bottomenu.dart';
import 'package:ink/src/ui/widgets/button/gradient_tab_Indicator_widget.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/webService.dart';

import '../../../controller/notificationController.dart';
import '../../../utils/colors.dart';
import 'widget/notification_list_empty_widget.dart';
import 'widget/request_list_tile.dart';

class NotificationScreen extends StatefulWidget {
  final bool openHomeScreen;
  final bool isPushNotification;
  final bool isRequest;

  const NotificationScreen(
      {Key? key,
      this.isRequest = false,
      this.openHomeScreen = false,
      this.isPushNotification = false})
      : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  TabController? tabController;

  final notificationController = Get.put(NotificationController());
  final notificationScrollController = ScrollController();
  bool? isNotBusiness;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
        length: 2,
        vsync: this,
        initialIndex: widget.isRequest ? 1 : 0,
        animationDuration: Duration.zero);
    notificationController.activeIndex.value = widget.isRequest ? 1 : 0;

    _initialization();
  }

  Future<void> _initialization() async {
    AppUser currentUser = await WebService.getCurrentUser();

    isNotBusiness = currentUser.profile!.userType != "1";
    notificationController.startNotification = 0;
    notificationController.notificationList.clear();
    notificationController.isLoadingNotification.value = true;
    notificationController.hasMoreNotification.value = true;
    await notificationController.fetchNotifications();

    notificationController.startIndexRequest = 0;
    notificationController.tattooRequestsList.clear();
    notificationController.isLoadingRequest.value = true;
    notificationController.hasMoreRequest.value = true;
    await notificationController.fetchRequests();

    if (!WebService.isSplashHomeScreen) {
      WebService.isSplashHomeScreen = true;
    }
  }

  Future<bool> redirectTo() async {
    if (widget.isPushNotification == true) {
      AppUser user = await WebService.getCurrentUser();
      final isBusiness = await WebService.getIsBusiness();
      if (user.profile!.userType!.toString() == "1" || isBusiness == false) {
        Get.offAll(
            const DashBoard(
              initialIndex: 0,
            ),
            binding: DashBoardBinding());
      } else {
        Get.offAll(BusinessDashBoard(initialIndex: 0),
            binding: BusinessDashBoardBinding());
      }
    } else {
      getBack(context);
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                InkWell(
                  onTap: () async {
                    if (widget.isPushNotification == true) {
                      AppUser user = await WebService.getCurrentUser();
                      final isBusiness = await WebService.getIsBusiness();
                      if (user.profile!.userType!.toString() == "1" || isBusiness == false) {
                        Get.offAll(
                            const DashBoard(
                              initialIndex: 0,
                            ),
                            binding: DashBoardBinding());
                      } else {
                        Get.offAll(BusinessDashBoard(initialIndex: 0),
                            binding: BusinessDashBoardBinding());
                      }
                    }else{
                      final homeScreenController =
                      Get.put(HomeScreenController());

                      homeScreenController.stylePosts.clear();
                      homeScreenController.getPostsIds = "";
                      homeScreenController.stylename.value = "";
                      homeScreenController.stylenameheb.value = "";
                      homeScreenController.getHomeController();
                      getBack(context);
                    }

                  },
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: size.width * 0.02),
                        SvgPicture.asset(AppAssets.backarrowIcon,
                            width: 22, height: 22, color: titleTextWhiteColor),
                        SizedBox(width: size.width * 0.02),
                        Text(
                          "התראות ופניות",
                          style: textTheme.headlineSmall?.copyWith(
                            fontSize: 20,
                            color: titleTextWhiteColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ).tr()
                      ]),
                ),
              ],
            ),
            bottom: PreferredSize(
                preferredSize: Size.fromHeight(Get.size.height * 0.06),
                child: Stack(
                  fit: StackFit.passthrough,
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom:
                          BorderSide(color: textEditingColor, width: 2.0),
                        ),
                      ),
                    ),
                    TabBar(
                        labelPadding: EdgeInsets.zero,
                        padding: EdgeInsets.zero,
                        splashFactory: NoSplash.splashFactory,
                        overlayColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                          // Use the default focused overlay color
                          return states.contains(MaterialState.focused)
                              ? null
                              : Colors.transparent;
                        }),
                        controller: tabController,
                        labelColor: titleTextWhiteColor,
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: size.width * 0.04),
                        indicatorWeight: 2,


                        indicatorSize: TabBarIndicatorSize.tab,
                        unselectedLabelColor: titleTextWhiteColor,


                        isScrollable: false,
                        onTap: (index) async {
                          notificationController.isLoading.value = true;
                          if (index == 0) {
                            notificationController.startNotification = 0;
                            notificationController.activeIndex.value = index;
                            notificationController.notificationList.clear();
                            notificationController.hasMoreNotification.value =
                                true;
                            await notificationController.fetchNotifications();
                          } else {
                            notificationController.hasMoreRequest.value = true;
                            notificationController.activeIndex.value = index;
                            notificationController.startIndexRequest = 0;
                            notificationController.tattooRequestsList.clear();
                            await notificationController.fetchRequests();
                          }
                        },
                        tabs: [
                          Tab(
                            child: Obx(() => Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(width: size.width * 0.02),
                                    notificationController.activeIndex.value == 0
                                        ? SvgPicture.asset(
                                            AppAssets.bellFilledIcon)
                                        : SvgPicture.asset(
                                            AppAssets.bellInactiveIcon,
                                            color: lightGrayColor),
                                    SizedBox(width: size.width * 0.04),
                                    Text(
                                      'התראות',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: notificationController
                                                    .activeIndex.value ==
                                                0
                                            ? titleTextWhiteColor
                                            : lightGrayColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (notificationController
                                                .notificationUnreadCount.value !=
                                            "0" &&
                                        notificationController
                                                .notificationUnreadCount.value !=
                                            "null")
                                      SizedBox(width: size.width * 0.02),
                                    if (notificationController
                                                .notificationUnreadCount.value !=
                                            "0" &&
                                        notificationController
                                                .notificationUnreadCount.value !=
                                            "null")
                                      Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient:  appLinearGradient// Change color as desired
                                          ),
                                          child: Text(
                                            notificationController
                                                .notificationUnreadCount.value,
                                            style: textTheme.titleSmall!.copyWith(
                                              color: whiteTxtColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ))
                                  ],
                                )),
                          ), // Notifications
                          Tab(
                              child: Obx(() => Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(width: size.width * 0.02),
                                      notificationController.activeIndex.value ==
                                              1
                                          ? SvgPicture.asset(AppAssets.mailFilled)
                                          : SvgPicture.asset(AppAssets.mail,
                                              color: lightGrayColor),
                                      SizedBox(width: size.width * 0.04),
                                      Text(
                                        'פניות',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: notificationController
                                                      .activeIndex.value ==
                                                  1
                                              ? titleTextWhiteColor
                                              : lightGrayColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (notificationController
                                                  .messageUnreadCount.value !=
                                              "0" &&
                                          notificationController
                                                  .messageUnreadCount.value !=
                                              "null")
                                        SizedBox(width: size.width * 0.02),
                                      if (notificationController
                                                  .messageUnreadCount.value !=
                                              "0" &&
                                          notificationController
                                                  .messageUnreadCount.value !=
                                              "null")
                                        Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                                gradient:  appLinearGradient // Change color as desired
                                            ),
                                            child: Text(
                                              notificationController
                                                  .messageUnreadCount.value,
                                              style: const TextStyle(
                                                color: whiteTxtColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ))
                                    ],
                                  ))), //inquiry box
                        ]),
                  ],
                ))),
        bottomNavigationBar:
            Obx(() => notificationController.userTypes.value == "2"
                ? BusinessDashboardBottomBar(
                    currentIndex: 0,
                  )
                : DashboardBottomBar(currentIndex: 0)),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TabBarView(
              controller: tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                //notifications
                Obx(() => notificationController.isLoadingNotification.value
                    ? const Center(child: CircularProgressIndicator())
                    : notificationController.notificationList.isEmpty
                        ? const NotificationListEmptyWidget(isAlertList: true)
                        : ListView.builder(
                            controller: notificationController
                                .scrollControllerNotification,
                            shrinkWrap: true,
                            itemCount:
                                notificationController.notificationList.length +
                                    1,
                            itemBuilder: (BuildContext context, int index) {
                              if (index <
                                  notificationController
                                      .notificationList.length) {
                                return notificationController
                                                .notificationList[index]
                                                .custid ==
                                            null ||
                                        notificationController
                                                .notificationList[index]
                                                .custid ==
                                            ""
                                    ? const SizedBox()
                                    : NotificationListWidget(
                                        notificationController:
                                            notificationController,
                                        notificationModelNew:
                                            notificationController
                                                .notificationList[index],
                                        index: index);
                              } else {
                                return Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Obx(() => Center(
                                      child: notificationController
                                              .hasMoreNotification.value
                                          ? const CircularProgressIndicator()
                                          : const SizedBox())),
                                );
                              }
                            })),
                //tattoo requests
                Obx(() => notificationController.isLoadingRequest.value
                    ? const Center(child: CircularProgressIndicator())
                    : notificationController.tattooRequestsList.isEmpty
                        ? const NotificationListEmptyWidget(isAlertList: false)
                        : ListView.builder(
                            shrinkWrap: true,
                            controller:
                                notificationController.scrollControllerRequest,
                            itemCount: notificationController
                                    .tattooRequestsList.length +
                                1,
                            itemBuilder: (BuildContext context, int index) {
                              if (index <
                                  notificationController
                                      .tattooRequestsList.length) {
                                return RequestListTile(
                                    notificationController:
                                        notificationController,
                                    title: isNotBusiness!
                                        ? notificationController
                                                .tattooRequestsList[index]
                                                .name ??
                                            ""
                                        : notificationController
                                                    .tattooRequestsList[index]
                                                    .businessRow ==
                                                null
                                            ? ""
                                            : notificationController
                                                    .tattooRequestsList[index]
                                                    .businessRow!
                                                    .name ??
                                                "",
                                    tattooSize: WebService.setTattooSize(
                                        notificationController
                                            .tattooRequestsList[index]
                                            .tattooSize!),
                                    imgUrl: (isNotBusiness!
                                        ? notificationController
                                                    .tattooRequestsList[index]
                                                    .senderRow ==
                                                null
                                            ? ""
                                            : notificationController
                                                .tattooRequestsList[index]
                                                .senderRow!
                                                .profileImage!
                                        : notificationController
                                                    .tattooRequestsList[index]
                                                    .businessRow ==
                                                null
                                            ? ""
                                            : notificationController
                                                    .tattooRequestsList[index]
                                                    .businessRow!
                                                    .profileImage ??
                                                ""),
                                    tattooRequest: notificationController
                                        .tattooRequestsList[index]);
                              } else {
                                return Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Obx(() => Center(
                                      child: notificationController
                                              .hasMoreRequest.value
                                          ? const CircularProgressIndicator()
                                          : const SizedBox())),
                                );
                              }
                            })),
              ]),
        ));
  }
}
