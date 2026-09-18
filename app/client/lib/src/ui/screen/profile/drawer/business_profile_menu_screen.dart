import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/google_signin_controller.dart';
import 'package:ink/src/data/source/network/api.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/ui/screen/auth/login.dart';
import 'package:ink/src/ui/screen/collections/saved_screen.dart';
import 'package:ink/src/ui/screen/profile/drawer/about_us.dart';
import 'package:ink/src/ui/screen/profile/drawer/controller/business_profile_menu_controller.dart';
import 'package:ink/src/ui/screen/profile/drawer/widget/collection_list_widget.dart';
import 'package:ink/src/ui/screen/profile/drawer/widget/image_rounded_title_widget.dart';
import 'package:ink/src/ui/screen/profile/select_category.dart';
import 'package:ink/src/ui/screen/profile/subscription/iosubscription/purchase_ios_screen.dart';
import 'package:ink/src/ui/screen/profile/subscription/purchase_screen.dart';
import 'package:ink/src/ui/widgets/bottomenu/business_dashboard_bottomenu.dart';
import 'package:ink/src/ui/widgets/button/custom_gradient_btn_widget.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/webService.dart';

import '../../splash/welcome_screen.dart';
import 'FAQ/FAQ.dart';
import 'TAC/terme_of_use.dart';
import 'accessibility_statement.dart';
import 'contact_us.dart';
import 'delete_account_screen.dart';
import 'editing_details.dart';
import 'followed_artist_list.dart';
import 'sent_requests_screen.dart';
import 'widget/custom_btn_widget.dart';

class BusinessProfileMenuScreen extends StatefulWidget {
  final bool iscurrentUserProfile;
  final bool isPremiumPlanBuy;

  const BusinessProfileMenuScreen(
      {super.key,
      this.iscurrentUserProfile = false,
      this.isPremiumPlanBuy = false});

  @override
  State<BusinessProfileMenuScreen> createState() =>
      _BusinessProfileMenuScreenState();
}

class _BusinessProfileMenuScreenState extends State<BusinessProfileMenuScreen> {
  final _controller = Get.put(BusinessProfileMenuController());
  bool isApiLoading = false;

  @override
  void initState() {
    // _initialization();
    super.initState();
  }

  void _openEditingDetails() {
    Get.to(() => EditingDetails(
          businessProfileMenuController: _controller,
        ));
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    return widget.iscurrentUserProfile
        ? Scaffold(
            backgroundColor: bgBlack,
            bottomNavigationBar: BusinessDashboardBottomBar(
              currentIndex: 4,
            ),
            body: buildBodyDrawer(size, textTheme, context),
          )
        : Scaffold(
            backgroundColor: bgBlack,
            body: buildBodyDrawer(size, textTheme, context),
          );
  }

  Padding buildBodyDrawer(
      Size size, TextTheme textTheme, BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        12,
        MediaQuery.viewPaddingOf(context).top + 12,
        12,
        12,
      ),
      child: Obx(() => _controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  //user info — tap avatar / name / pencil to edit details
                  SizedBox(
                    height: size.height * 0.08,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _openEditingDetails,
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              children: [
                                buildCachedNetworkImage(
                                    height: size.width * 0.15,
                                    width: size.width * 0.15,
                                    errorWidget: Image.asset(
                                        height: size.width * 0.15,
                                        width: size.width * 0.15,
                                        AppAssets.userPlaceHolder,
                                        fit: BoxFit.cover),
                                    url: WebService.resolveProfileImage(
                                        _controller.profileimage.value),
                                    radius: 50),
                                SizedBox(width: size.width * 0.04),
                                Flexible(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          _controller.name.value,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: textTheme.titleLarge!.copyWith(
                                            fontSize: 20,
                                            color: titleTextWhiteColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      SvgPicture.asset(
                                        AppAssets.editIcon,
                                        height: 16,
                                        width: 16,
                                        color: titleTextWhiteColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (widget.iscurrentUserProfile == true)
                          IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: SvgPicture.asset(
                                AppAssets.closeIcon,
                                height: 18,
                                width: 18,
                              ))
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.01),

                  //collections
                  buildtitlebackbold(
                      title: "sideDrawer.reserved",
                      context: context,
                      onTap: () => Get.to(() => SavedCollection(
                          currentUserType: _controller.userType.value))),
                  CollectionListWidget(
                      businessProfileMenuController: _controller,
                      currentUserType: _controller.userType.value),

                  //followings list
                  // if (_controller.userType.value != "1")
                  buildtitlebackbold(
                      title: "sideDrawer.follow_up_tatto",
                      context: context,
                      onTap: () => Get.to(() => FollowedArtistList(
                          currentUserType: _controller.userType.value))),
                  // if (_controller.userType.value != "1")

                  ImageRoundedTitleWidget(controller: _controller),

                  if (_controller.userType.value == "1")
                    buildtitlebackbold(
                        title: "sideDrawer.sent_requests",
                        context: context,
                        onTap: () => Get.to(() => SentRequestsScreen(
                            currentUserType: _controller.userType.value))),

                  SizedBox(height: size.height * 0.01),

                  // title account settings
                  buildtitle(
                      context: context, title: "sideDrawer.account_operation"),

                  //edit styles
                  buildtitleback(
                      title: "sideDrawer.change_favourite_style",
                      context: context,
                      onTap: () => Get.to(() => SelectCategory(
                            fromProfile: true,
                            businessProfileMenuController: _controller,
                          ))),

                  buildLanguageRow(context),

                  //delete account
                  buildtitleback(
                      title: "sideDrawer.delete_account",
                      context: context,
                      onTap: () => Get.to(const DeleteAccountScreen())),

                  SizedBox(height: size.height * 0.01),

                  buildtitle(context: context, title: "sideDrawer.alerts"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("sideDrawer.send_notification",
                              style: textTheme.titleMedium!.copyWith(
                                  fontSize: 16,
                                  color: dividerGray,
                                  fontWeight: FontWeight.w400))
                          .tr(),
                      Obx(() => CupertinoSwitch(
                            value: _controller.pushEnable.value,
                            onChanged: (newValue) =>
                                _controller.toggleIsEnabled(context, newValue),
                            activeColor: linearGradieantColor1,
                            // Active track color
                            trackColor: textEditingColor,
                            // Inactive track color
                            thumbColor: const Color(0xFFEAE7EE),
                          ))
                    ],
                  ),
                  SizedBox(height: size.height * 0.02),
                  buildtitle(context: context, title: "sideDrawer.on_us"),

                  //contact us
                  buildtitleback(
                      title: "sideDrawer.contact",
                      context: context,
                      onTap: () => Get.to(() => const Contactus())),
                  // onTap: () => Get.to(() => const EnterDetails())),

                  //FAQ
                  buildtitleback(
                      title: "sideDrawer.qanda",
                      context: context,
                      onTap: () => Get.to(
                          FAQ(currentUserType: _controller.userType.value))),
                  // onTap: () => Get.to(() => CustomPdfViewver(
                  //     url: _controller.userType.value == "1"
                  //         ? WebService.regularQuestionAndAnswers
                  //         : WebService.businessQuestionAndAnswers,
                  //     title: "שאלות תשובות"))),

                  //about
                  buildtitleback(
                      title: "sideDrawer.about",
                      context: context,
                      onTap: () => Get.to(const AboutUs())),

                  //terms & privacy
                  buildtitleback(
                      title: "sideDrawer.terms",
                      context: context,
                      onTap: () => Get.to(() => const TermsOfUse())),

                  buildtitleback(
                      title: "sideDrawer.accessibility_statement",
                      context: context,
                      onTap: () => Get.to(() => const AccessibilityStatementScreen())),

                  SizedBox(height: size.height * 0.02),
                  buildPackageInfo(context, size),
                  SizedBox(height: size.height * 0.03),

                  _controller.userType.value == "2" && (widget.isPremiumPlanBuy || _controller.isStudioSelected.value)
                     ? const SizedBox.shrink()
                     : CustomGradientButtonWidget(
                     title: _controller.userType.value == "2"
                         ? 'sideDrawer.business_plan'
                         : 'sideDrawer.opening_account',
                     onTap: () async {
                       if (isApiLoading) return;
                       isApiLoading = true;
                       try {
                         if (_controller.userType.value == "2") {
                           if (Platform.isAndroid) {
                             await Network.getCheckSubscription()
                                 .then((value) {
                               Get.to(PurchaseScreen(
                                   fromRegistration: false,
                                   checkstatus: value['status'].toString(),
                                   isEditProfile: true));
                             });
                           } else {
                             await Network.getCheckSubscription()
                                 .then((value) {
                               if (value['status'].toString() == "0" ||
                                   value['data']['subscription_status']
                                       .toString() ==
                                       "0") {
                                 Get.to(IOSPurchaseScreen(
                                     checkstatus:
                                     value['status'].toString(),
                                     purchasename: 'ללא תוכנית קנייה',
                                     fromRegistration: false,
                                     isEditProfile: true));
                               } else if (value['status'].toString() ==
                                   "2") {
                                 ApiResponse.sessionExpired(
                                     msg: "alerts.session_expire");
                               } else {
                                 Get.to(IOSPurchaseScreen(
                                     checkstatus:
                                     value['status'].toString(),
                                     fromRegistration: false,
                                     purchasename: value['data']
                                     ['product_id']
                                         .toString(),
                                     isEditProfile: true));
                               }
                             });
                           }
                         } else {
                           Get.to(() => const WelcomeScreen(
                               isFromChangeUserScreen: true));
                         }
                       } catch (e) {
                         isApiLoading = false;
                       } finally {
                         isApiLoading = false;
                       }
                     }),
                  SizedBox(height: size.height * 0.03),
                  CustomButtonWidget(
                      btnColor: socialoginbtn,
                      txtColor: titleTextWhiteColor,
                      title: 'sideDrawer.disconnection',
                      onTap: () => deleteAccountDialog(context)),
                  SizedBox(height: size.height * 0.03),
                ],
              ),
            )),
    );
  }

  Row buildPackageInfo(BuildContext context, Size size) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          tr("sideDrawer.version"),
          textAlign: TextAlign.right,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontSize: 16, color: lightGrayColor, fontWeight: FontWeight.w400),
        ),
        SizedBox(width: size.width * 0.02),
        Text(
          WebService.appVersion,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontSize: 16, color: lightGrayColor, fontWeight: FontWeight.w700),
        )
      ],
    );
  }

  Padding buildLanguageRow(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isEnglish = context.locale.languageCode == 'en';
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.017),
      child: InkWell(
        onTap: () => _openLanguageSheet(context),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              tr('sideDrawer.language'),
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontSize: 16,
                  color: dividerGray,
                  fontWeight: FontWeight.w400),
            ),
            const Spacer(),
            Text(
              isEnglish
                  ? tr('sideDrawer.language_english')
                  : tr('sideDrawer.language_hebrew'),
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontSize: 16,
                  color: titleTextWhiteColor,
                  fontWeight: FontWeight.w400),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.02),
              child: SvgPicture.asset(AppAssets.backside),
            ),
          ],
        ),
      ),
    );
  }

  void _openLanguageSheet(BuildContext context) {
    final current = context.locale;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: signInButtonColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF56525A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Text(
                    tr('sideDrawer.language_title'),
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontSize: 18,
                        color: titleTextWhiteColor,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  _languageOption(
                    pageContext: context,
                    sheetContext: sheetContext,
                    label: tr('sideDrawer.language_hebrew'),
                    locale: const Locale('he', 'HE'),
                    selected: current.languageCode == 'he',
                  ),
                  _languageOption(
                    pageContext: context,
                    sheetContext: sheetContext,
                    label: tr('sideDrawer.language_english'),
                    locale: const Locale('en', 'EN'),
                    selected: current.languageCode == 'en',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _languageOption({
    required BuildContext pageContext,
    required BuildContext sheetContext,
    required String label,
    required Locale locale,
    required bool selected,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: Theme.of(pageContext).textTheme.titleMedium!.copyWith(
            fontSize: 16,
            color: titleTextWhiteColor,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400),
      ),
      trailing: selected
          ? const Icon(Icons.check, color: linearGradieantColor1)
          : null,
      onTap: () async {
        Navigator.of(sheetContext).pop();
        if (selected) return;
        await pageContext.setLocale(locale);
        Get.updateLocale(locale);
      },
    );
  }

  Padding buildtitleback(
      {required BuildContext context,
      required String title,
      required VoidCallback onTap}) {
    var size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.017),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              tr(title),
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontSize: 16,
                  color: dividerGray,
                  fontWeight: FontWeight.w400),
            ),
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.02),
              child: SvgPicture.asset(
                AppAssets.backside,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding buildtitlebackbold(
      {required BuildContext context,
      required String title,
      required VoidCallback onTap}) {
    var size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              tr(title),
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: 18,
                  color: titleTextWhiteColor,
                  fontWeight: FontWeight.w700),
            ),
            SvgPicture.asset(
              AppAssets.backside,
            ),
          ],
        ),
      ),
    );
  }

  Padding buildtitle({required BuildContext context, required String title}) {
    var size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
      child: Text(
        tr(title),
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontSize: 18,
            color: titleTextWhiteColor,
            fontWeight: FontWeight.w700),
      ),
    );
  }

  Future<void> deleteAccountDialog(BuildContext context) async {
    showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          StatefulBuilder(builder: (builder, setstate) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(1.0),
          backgroundColor: socialoginbtn,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("להתנתק מהחשבון?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        color: titleTextWhiteColor,
                        fontWeight: FontWeight.w700)),
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
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                        child: const Text("ביטול")),
                    const SizedBox(width: 8),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: kWhite,
                          backgroundColor: dialogRedColor,
                        ),
                        onPressed: () async {
                          try {
                            final googleSignInController =
                                GoogleSignInController();
                            await googleSignInController.signOut();

                            await FirebaseMessaging.instance.deleteToken();
                            await WebService.clearUserData();

                            Get.offAll(() => const LoginScreen());
                          } catch (e, stackTrace) {
                            debugPrint("Logout Error: $e");
                            debugPrint("StackTrace: $stackTrace");
                          }
                        },
                        child: Text("התנתק",
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    color: kWhite,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14))),
                  ],
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  // Future<void> _initialization() async {
  //   if (!await WebService.checkConnectionNoMsg()) return;
  //
  //   _controller.isLoading.value = true;
  //   try {
  //     await _controller.initPackageInfo();
  //   } finally {
  //     _controller.isLoading.value = false;
  //   }
  // }

  void sendEvents() async {
    final params = {
      "action": "UpdateBusinessProfile",
      'uid': 20,
      'login_token': "loginToken",
      'business_type': "2",
      'name': "Test User",
      'address': "address",
      'device_type': WebService.deviceType,
      'app_version': WebService.appVersion,
      'app_token': WebService.appToken,
    };

    // if (controller.isStudioSelected.value.toString() == "1") {
    // await FacebookEvents.studioProfileCreationEvent(params: params);
    // } else {
    // await FacebookEvents.artistProfileCreationEvent(params: params);
    // }

    /* await FacebookEvents.addSubscription(
        amount: WebService.purchasePrice,
        currency: WebService.purchaseCurrency,
        parameters: params);*/
  }
}
