import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart' as localization;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart'
    as fg;
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart'
    as gmwp;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:googlemaps_flutter_webservices/places.dart' as gm;
import 'package:image_picker/image_picker.dart';
import 'package:ink/src/controller/StartupController.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/data/source/network/api.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/ui/screen/profile/changeUserType/controller/businessList_controller.dart';
import 'package:ink/src/ui/screen/profile/drawer/controller/business_profile_menu_controller.dart';
import 'package:ink/src/ui/screen/profile/select_category.dart';
import 'package:ink/src/ui/screen/profile/subscription/iosubscription/purchase_ios_screen.dart';
import 'package:ink/src/ui/screen/profile/subscription/purchase_screen.dart';
import 'package:ink/src/ui/widgets/button/animation_loader_button_widget.dart';
import 'package:ink/src/ui/widgets/button/custom_gradient_btn_child_widget.dart';
import 'package:ink/src/ui/widgets/unfocus_widget.dart';
import 'package:ink/src/ui/widgets/upgrade_dialog.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/utils.dart';
import 'package:ink/src/utils/webService.dart';

import '../../../../data/model/check_subscription_model.dart';
import 'widget/edit_members_widget.dart';

//import 'tagmembers.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfile();
}

class _EditProfile extends State<EditProfile>
    with SingleTickerProviderStateMixin {
  late final AppUser user;
  bool isAddressEmpty = true;

  final BusinessListController artistListController =
      Get.put(BusinessListController());

  // final ChangeUserTypeController changeUserTypeController =
  //     Get.put(ChangeUserTypeController());
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final ScrollController scrollController = ScrollController();

  final hintStyle = const TextStyle(color: hintTextColor);

  final BusinessProfileMenuController _controller =
      Get.put(BusinessProfileMenuController());

  late AnimationController animationController;
  late Animation<double> base;

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));
    base = CurvedAnimation(parent: animationController, curve: Curves.easeOut);
    _controller.isLoading.value = true;
    _controller.isLoadingCheckSubscription.value = false;

    _controller.nameController.value.text = "";
    _controller.addressController.value.text = "";
    _controller.aboutController.value.text = "";
    artistListController.selectedList.clear();
    _controller.initPackageInfo();
    WebService.tempArtistIdList = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return UnFocusWidget(
      child: Obx(() => Scaffold(
          key: scaffoldKey,
          backgroundColor: bgBlack,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Column(
              children: [
                SizedBox(height: size.height * 0.02),
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(AppAssets.backarrowIcon,
                                width: 22, height: 22),
                            SizedBox(width: size.width * 0.02),
                            Text(
                              "עריכת פרטים",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontSize: 20,
                                    color: titleTextWhiteColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                            )
                          ]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: _controller.isLoading.value
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SafeArea(
           
                child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                      vertical: size.height * 0.03,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: size.height * 0.015),
                        Obx(() => Center(
                            child: _controller.pickedFilePath.value == ""
                                ? _controller.profileimage.value == ""
                                    ? Container(
                                        margin: EdgeInsets.only(
                                            left: size.width * 0.01),
                                        height: size.width * 0.25,
                                        width: size.width * 0.25,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    AppAssets.galleryPlaceholder),
                                                fit: BoxFit.cover)),
                                      )
                                    : buildCachedNetworkImage(
                                        height: size.width * 0.25,
                                        width: size.width * 0.25,
                                        url: WebService.resolveProfileImage(
                                            _controller.profileimage.value),
                                        radius: size.width * 0.3)
                                : Container(
                                    height: size.width * 0.3,
                                    width: size.width * 0.3,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(size.width * 0.3)),
                                        image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: FileImage(_controller
                                                .pikedFileData.value!)))))),
                        SizedBox(height: size.height * 0.01),
                        Center(
                          child: TextButton.icon(
                            icon: SvgPicture.asset(
                              AppAssets.editIcon,
                              color: titleTextColor,
                            ),
                            onPressed: () => _imageUploadDialogue(context),
                            label: const Text("העלאת תמונה",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: dividerGray)),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        buildArtistOrStudioImage(size: size),
                        // buildArtistOrStudioSelection(size: size),
                        SizedBox(height: size.height * 0.01),
                        buildName(size, context),
                        buildAddress(size, context),
                        buildStylesSelection(size, context),
                        buildDescription(size, context),
                        if (_controller.businessType.value == "1")
                          buildArtistSelection(size, context),
                        SizedBox(height: size.height * 0.04),
                        buildBtnSubmit(context: context, size: size),
                        SizedBox(height: size.height * 0.02),
                        Align(
                          alignment: Alignment.center,
                          child: InkWell(
                            onTap: () => saveDataBtn(context, size),
                            child: IntrinsicWidth(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'ביטול',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: titleTextWhiteColor,
                                            fontSize: 16),
                                  ).tr(),
                                  const SizedBox(height: 2),
                                  Container(
                                      height: 1,
                                      width: 37,
                                      color: titleTextColor),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                      ],
                    ),
                  ),
              ))),
    );
  }

  buildArtistOrStudioImage({required Size size}) =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        buildTabBtn(
            title: "user_to_business.txt_artist",
            onTap: () {
              if (_controller.businessType.value == "1") {
                _controller.businessType.value = "2";
                _controller.isStudioSelected.value = false;
              }
            },
            // onTap: () => changeUserTypeController.setTypeStudio(false),
            icon: AppAssets.artistIconSvg,
            size: size,
            isSelected: _controller.businessType.value != "1"),
        buildTabBtn(
            title: "user_to_business.txt_studio",
            onTap: () async {
              if (_controller.businessType.value != "1") {
                _controller.isLoadingCheckSubscription.value = true;
                await Network.getCheckSubscription().then((value) async {
                  _controller.isLoadingCheckSubscription.value = false;
                  CheckSubscriptionModel subscriptionModel =
                      CheckSubscriptionModel(subscriptionStatus: 0);
                  subscriptionModel =
                      CheckSubscriptionModel.fromJson(value['data']);

                  if ((subscriptionModel != null &&
                          subscriptionModel.isPremium.toString() == "1") ||
                      (value['data'] != null &&
                          value['data']['is_premium'].toString() == "1")) {
                    _controller.businessType.value = "1";
                    _controller.isStudioSelected.value = true;
                  } else {
                    final StartupController startupController =
                        Get.put(StartupController());
                    await startupController
                        .checkSubscription(); // ✅ wait for refresh

                    // ✅ Force UI update
                    startupController.update();
                    artistToStudioAlertDialog(context, value);
                  }
                });
              }
            },
            isStudio: true,
            icon: AppAssets.studioIconSvg,
            size: size,
            isSelected: _controller.businessType.value == "1"),
      ]);

  void studioToArtistAlertDialog(BuildContext mcontext) {
    var size = MediaQuery.of(mcontext).size;

    showDialog(
      context: mcontext,
      builder: (BuildContext context) {
        return UpgradeDialog(
          title: "האם אתה בטוח שתרצה לשנות את סוג הפרופיל?",
          description:
              "שינוי סוג החשבון ישפיע על המקעקעים שרשומים תחת בית העסק שלך.",
          upgradeButtonTxt: "כן, ארצה לשנות",
          mayBelaterButtonTxt: "לא, חזרה לעריכה",
          onUpgradeNow: () async {
            _controller.businessConvertController(context);
            animationController.forward();
            animationController.repeat();

            Navigator.pop(context);

            // Do something after upgrade
          },
          onMaybeLater: () {
            Navigator.pop(context); // Close ChangeUserTypeDialog
          },
        );
      },
    );
  }

  void submitAlertDialog(BuildContext mcontext) {
    showDialog(
      context: mcontext,
      builder: (BuildContext context) {
        return UpgradeDialog(
          isTitleVisible: false,
          title: "",
          description:
              "בהפיכת הפרופיל שלך לסטודיו, אתה תוסר כמקעקע תחת סטודיואים אחרים",
          upgradeButtonTxt: "בסדר, המשך",
          mayBelaterButtonTxt: "בטל",
          onUpgradeNow: () async {
            _controller.businessConvertController(context);

            animationController.forward();
            animationController.repeat();

            Navigator.pop(context);
            // Do something after upgrade
          },
          onMaybeLater: () {
            Navigator.pop(context); // Close ChangeUserTypeDialog
          },
        );
      },
    );
  }

  void artistToStudioAlertDialog(BuildContext context, value) {
    var size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return UpgradeDialog(
          title: "רוצה לשדרג את הפרופיל שלך?",
          description:
              "שינוי הפרופיל יאפשר לך לנהל את העסק שלך כמו סטודיו מקצועי עם כמה מקעקעים.",
          upgradeButtonTxt: "שדרגו עכשיו לפרופיל מתקדם",
          mayBelaterButtonTxt: "אולי אחר כך",
          onUpgradeNow: () async {
            Get.back(closeOverlays: true);
            if (Platform.isAndroid) {
              Future.delayed(Duration(milliseconds: 200), () {
                Get.to(() => PurchaseScreen(
                      fromRegistration: false,
                      checkstatus: value['status'].toString(),
                      isEditProfile: true,
                    ));
              });
            } else {
              if (value['status'].toString() == "0" ||
                  value['data']['subscription_status'].toString() == "0") {
                Get.to(IOSPurchaseScreen(
                    checkstatus: value['status'].toString(),
                    purchasename: 'ללא תוכנית קנייה',
                    fromRegistration: false,
                    isEditProfile: true));
              } else if (value['status'].toString() == "2") {
                ApiResponse.sessionExpired(msg: "alerts.session_expire");
              } else {
                Get.to(IOSPurchaseScreen(
                    checkstatus: value['status'].toString(),
                    fromRegistration: false,
                    purchasename: value['data']['product_id'].toString(),
                    isEditProfile: true));
              }
            }
          },
          onMaybeLater: () {
            Navigator.pop(context); // Close UpgradeProfileDialog
          },
        );
      },
    );
  }

  // buildArtistOrStudioImage({required Size size}) => IntrinsicWidth(
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           if (_controller.businessType.value != "")
  //             TextButton.icon(
  //               icon: SvgPicture.asset(_controller.businessType.value == "1"
  //                   ? AppAssets.studioIconSvg
  //                   : AppAssets.artistIconSvg),
  //               onPressed: () {},
  //               label: Text(
  //                 _controller.businessType.value == "1"
  //                     ? localization.tr("user_to_business.txt_studio")
  //                     : localization.tr("user_to_business.txt_artist"),
  //                 style: const TextStyle(
  //                     color: titleTextWhiteColor,
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.w500),
  //               ),
  //             ),
  //           const SizedBox(height: 4),
  //           if (_controller.businessType.value != "")
  //             Container(
  //                 height: 2, width: size.width * 0.45, color: titleTextColor),
  //         ],
  //       ),
  //     );

  buildTabBtn(
          {required String title,
          required VoidCallback onTap,
          required String icon,
          required Size size,
          bool isStudio = false,
          required bool isSelected}) =>
      Expanded(
        child: _controller.isLoadingCheckSubscription.value && isStudio
            ? RotationTransition(
                turns: animationController,
                child: Image.asset(
                  width: size.width * 0.13,
                  height: size.width * 0.13,
                  AppAssets.loadingIcon, // Replace with your asset
                  color: Colors.white,
                ),
              )
            : Stack(
                children: [
                  TextButton.icon(
                    icon: SvgPicture.asset(icon),
                    onPressed: onTap,
                    label: Text(
                      title,
                      style: TextStyle(
                          color: isSelected
                              ? titleTextWhiteColor
                              : textEditingColor2,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    ).tr(),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: isSelected ? titleTextColor : socialoginbtn,
                      ),
                    ),
                  ),
                ],
              ),
      );

  // Business Name Or Studio Name
  Column buildName(Size size, BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.03),
          Text(
            _controller.isStudioSelected.value
                ? "user_to_business.studio_name"
                : "user_to_business.business_name",
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: titleTextWhiteColor, fontWeight: FontWeight.w400),
          ).tr(),
          SizedBox(height: size.height * 0.02),
          TextFormField(
              autofocus: false,
              controller: _controller.nameController.value,
              keyboardType: TextInputType.name,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: titleTextWhiteColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w400),
              decoration: InputDecoration(
                hintStyle: hintStyle,
                hintText: _controller.isStudioSelected.value
                    ? localization.tr("user_to_business.name_hint_studio")
                    : localization.tr("user_to_business.name_hint_artist"),
                contentPadding: const EdgeInsets.all(8),
                filled: true,
                fillColor: socialoginbtn,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              )),
        ],
      );

  // Address
  Column buildAddress(Size size, BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.03),
          Text(
            localization.tr("user_to_business.address"),
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: titleTextWhiteColor, fontWeight: FontWeight.w400),
          ),
          SizedBox(height: size.height * 0.01),
          TextFormField(
              onTap: () async {
                var place = await fg.PlacesAutocomplete.show(
                    context: context,
                    apiKey: WebService.googleApiKey,
                    mode: fg.Mode.overlay,
                    language: 'He',
                    types: [],
                    components: [
                      const gmwp.Component(gmwp.Component.country, 'IL')
                    ],
                    onError: (err) {
                      WebService.printMsg(err.errorMessage.toString());
                    });

                if (place != null) {
                  final plist = gm.GoogleMapsPlaces(
                    apiKey: WebService.googleApiKey,
                    apiHeaders: await const GoogleApiHeaders().getHeaders(),
                  );
                  String placeId = place.placeId ?? "0";
                  final detail = await plist.getDetailsByPlaceId(placeId);
                  final geometry = detail.result.geometry!;
                  String cityName = '';
                  final addressComponents =
                      await detail.result.addressComponents;
                  for (var component in addressComponents) {
                    if (component.types.contains('locality')) {
                      cityName = component.longName;
                      if (cityName == "") {
                        cityName = component.shortName;
                      }
                      break;
                    }
                  }
                  WebService.placeId = placeId;
                  WebService.lat = geometry.location.lat;
                  WebService.lang = geometry.location.lng;
                  WebService.address = place.description!;
                  WebService.cityName = cityName;

                  print("cityName $cityName");
                  _controller.addressController.value.text = place.description!;
                }
              },
              autofocus: false,
              readOnly: true,
              controller: _controller.addressController.value,
              keyboardType: TextInputType.streetAddress,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: titleTextWhiteColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w400),
              decoration: InputDecoration(
                hintStyle: hintStyle,
                hintText: localization.tr("user_to_business.address_hint"),
                contentPadding: const EdgeInsets.all(12),
                filled: true,
                fillColor: socialoginbtn,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _controller.addressController.value.text.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsetsDirectional.all(16.0),
                        child:
                            SvgPicture.asset(AppAssets.correct_transparentIcon),
                      ) //Image.asset(AppAssets.correct_transparentIcon)
                    : null,
              )),
        ],
      );

  //select styles
  buildStylesSelection(Size size, BuildContext context) => //Obx(() =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.03),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                localization.tr("user_to_business.style_title"),
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: titleTextWhiteColor, fontWeight: FontWeight.w400),
              ),
              InkWell(
                onTap: () {
                  try {
                    Utils.goToScreen(
                        screen: SelectCategory(
                          editprofile: true,
                          businessProfileMenuController: _controller,
                        ),
                        isOffAll: false);
                  } finally {
                    FocusManager.instance.primaryFocus?.unfocus();
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(AppAssets.editIcon, color: titleTextColor),
                    const SizedBox(width: 4),
                    Text(
                      localization.tr("user_to_business.editing"),
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: titleTextWhiteColor,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.02),
          _controller.matchingItems.isEmpty
              ? UserBusinessGradientButtonWidget(
              width: size.width * 0.4,
              onTap: () {
                try {
                  Utils.goToScreen(
                      screen: SelectCategory(
                        editprofile: true,
                        businessProfileMenuController: _controller,
                      ),
                      isOffAll: false);
                } finally {
                  FocusManager.instance.primaryFocus?.unfocus();
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "user_to_business.choice_of_styles",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(
                        color: whiteTxtColor, fontWeight: FontWeight.w400),
                  ).tr(),
                  SizedBox(width: size.width * 0.02),
                  // Image.asset(AppAssets.btnarrowIcon),
                  SvgPicture.asset(AppAssets.btnarrowIcon, color: whiteTxtColor),
                ],
              ))
              :Wrap(
              spacing: 8.0,
              children: _controller.matchingItems
                  .map((style) => InkWell(
                        onTap: () => _controller.matchingItems.remove(style),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: ShapeDecoration(
                            gradient: appLinearGradient,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min, // Restrict the size
                            children: [
                              Text(
                                style.name!,
                                style: const TextStyle(color: whiteTxtColor),
                              ),
                              const SizedBox(width: 5),
                              const Icon(Icons.close, color: whiteTxtColor, size: 20),
                            ],
                          ),
                        ),
                      ))
                  .toList()),
        ],
        // )
      );

  //Description
  Column buildDescription(Size size, BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.03),
          Text(
            localization.tr("user_to_business.tell_us_studio"),
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: titleTextWhiteColor, fontWeight: FontWeight.w400),
          ),
          SizedBox(height: size.height * 0.02),
          TextFormField(
              autofocus: false,
              controller: _controller.aboutController.value,
              maxLines: null,
              minLines: 5,
              keyboardType: TextInputType.multiline,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: titleTextWhiteColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w400),
              autovalidateMode: AutovalidateMode.always,
              inputFormatters: [
                LengthLimitingTextInputFormatter(400),
              ],
              validator: (String? value) {
                if (value!.length >= 400) {
                  return ' התיאור ארוך מדי'; //description is to long
                }
                return null;
              },
              decoration: InputDecoration(
                hintStyle: hintStyle,
                hintText: localization.tr("user_to_business.description_hint"),
                contentPadding: const EdgeInsets.all(8),
                filled: true,
                fillColor: socialoginbtn,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              )),
          SizedBox(height: size.height * 0.01),
          Text(
            localization.tr("user_to_business.information_business_profile"),
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: const Color(0xFF807C84),
                fontSize: 14,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w400),
          ),
        ],
      );

  //artist selection
  buildArtistSelection(Size size, context) => Column(
        children: [
          SizedBox(height: size.height * 0.03),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                //old - מי חברי הסטודיו? / new -
                //old - "Who are the members of the studio?" / new - Select Studio Members
                localization.tr("user_to_business.member_of_studio"), //"מי חברי הסטודיו?"
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: titleTextWhiteColor, fontWeight: FontWeight.w400),
              ),
              InkWell(
                onTap: () {
                  try {
                    if (_controller.businessTypeOriginal.value.isNotEmpty &&
                        _controller.businessType.value.isNotEmpty &&
                        _controller.businessTypeOriginal.value ==
                            "2" && // originally Artist
                        _controller.businessType.value == "1") {
                      WebService.tempArtistIdList = "";
                      Get.to(EditMemberWidget(
                          businessType: _controller.businessType.value,
                          isConvertUser: true,
                          userIdStr: _controller.id.value));
                    } else {
                      WebService.tempArtistIdList = "";
                      Get.to(EditMemberWidget(
                          businessType: _controller.businessType.value));
                    }
                  } finally {
                    FocusManager.instance.primaryFocus?.unfocus();
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      AppAssets.editIcon,
                      color: titleTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      localization.tr("user_to_business.editing"),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: kWhite, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.02),
          SizedBox(
            height: size.height * 0.1,
            child: Stack(
                children: List.generate(_controller.artistList.length, (index) {
              return Positioned(
                  right: index * 45, //25,
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                        border: Border.all(color: btnWhite, width: 2),
                        borderRadius: BorderRadius.circular(50)),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: bgBlack,
                      child: ClipOval(
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: Image.network(
                            WebService.resolveProfileImage(
                                _controller.artistList[index].profileImage),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.photo); //do something
                            },
                            frameBuilder: (_, image, loadingBuilder, __) {
                              if (loadingBuilder == null) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return image;
                            },
                            loadingBuilder: (BuildContext context, Widget image,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return image;
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ));
            })),
          ),
          // SizedBox(
        ],
      );

  bool isEnableBtn() {
    if (_controller.nameController.value.text.isNotEmpty &&
        _controller.addressController.value.text.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  //button
  AnimationLoaderButtonWidget buildBtnSubmit(
          {required BuildContext context, required Size size}) =>
      AnimationLoaderButtonWidget(
        onTap: _controller.nameController.value.text.isEmpty ||
                _controller.addressController.value.text.isEmpty
            ? () {
                if (_controller.nameController.value.text.isEmpty) {
                  displayMessageIcon(
                      snackposition: SnackPosition.BOTTOM,
                      message: "אנא הקצה שם לעסק",
                      color: errorColor,
                      imageData: AppAssets.errorIcon);

                  // please assign name to business
                  return;
                }
                if (_controller.addressController.value.text.isEmpty) {
                  displayMessageIcon(
                      snackposition: SnackPosition.BOTTOM,
                      message: "נא להזין כתובת",
                      color: errorColor,
                      imageData: AppAssets.errorIcon);
                  //please enter address
                  return;
                }
              }
            : () async {
                if (_controller.nameController.value.text.isEmpty) {
                  displayMessageIcon(
                      snackposition: SnackPosition.BOTTOM,
                      message: "אנא הקצה שם לעסק",
                      color: errorColor,
                      imageData: AppAssets.errorIcon);
                  // please assign name to business
                  return;
                }
                if (_controller.addressController.value.text.isEmpty) {
                  displayMessageIcon(
                      snackposition: SnackPosition.BOTTOM,
                      message: "נא להזין כתובת",
                      color: errorColor,
                      imageData: AppAssets.errorIcon); //please enter address
                  return;
                }
                if (_controller.issubmitting.value == false) {
                  if (_controller.businessTypeOriginal.value.isNotEmpty &&
                      _controller.businessType.value.isNotEmpty &&
                      _controller.businessTypeOriginal.value ==
                          "2" && // originally Artist
                      _controller.businessType.value == "1") {
                    print(
                        " WebService.tempArtistIdList ${WebService.tempArtistIdList}");
                    // changed to Studio
                    submitAlertDialog(context);
                  } else if (_controller
                          .businessTypeOriginal.value.isNotEmpty &&
                      _controller.businessType.value.isNotEmpty &&
                      _controller.businessTypeOriginal.value ==
                          "1" && // originally Artist
                      _controller.businessType.value == "2") {
                    studioToArtistAlertDialog(context);
                  } else {
                    _controller.businessEditProfileController(context);
                    animationController.forward();
                    animationController.repeat();
                  }
                }
                // animationController.forward();
                // animationController.repeat();
              },
        title: localization.tr("שמירת שינויים"),
        colors: _controller.nameController.value.text.isNotEmpty &&
                _controller.addressController.value.text.isNotEmpty
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
        isLoading: _controller.issubmitting.value,
      );

  //button Dialog
  Future<void> saveDataBtn(BuildContext context, Size size) async {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) =>
          StatefulBuilder(builder: (builder, setstate) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(1.0),
          backgroundColor: socialoginbtn,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actionsAlignment: MainAxisAlignment.center,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: Column(
              children: [
                const Text("בטוחים שתרצו לבטל את\n השינויים שבוצעו?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        color: titleTextWhiteColor,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: size.height * 0.03),
                Text("לשמירה חזרו למצב עריכה ולחצו  על כפתור ‘שמירת שינויים’",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        fontSize: 16,
                        color: titleTextWhiteColor,
                        fontWeight: FontWeight.w400)),
                SizedBox(height: size.height * 0.03),
                SizedBox(
                  width: size.width,
                  height: size.height * 0.06,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: bgBlack,
                        backgroundColor: titleTextColor,
                      ),
                      onPressed: () async {
                        animationController.stop();
                        animationController.dispose();
                        Get.back();
                        Get.back();
                      },
                      child: const Text('כן, בטל שינויים',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ))),
                ),
                SizedBox(height: size.height * 0.015),
                SizedBox(
                  width: size.width,
                  height: size.height * 0.06,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: titleTextWhiteColor,
                        backgroundColor: const Color(0xFF403D44),
                      ),
                      onPressed: () async {
                        Get.back();
                      },
                      child: const Text(
                        "לא, חזרה לעריכה",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      )),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  //Image Upload Dialog
  _imageUploadDialogue(BuildContext context) {
    _controller.selectImage(context, ImageSource.gallery);
    // return showModalBottomSheet<dynamic>(
    //     useRootNavigator: true,
    //     isScrollControlled: true,
    //     context: context,
    //     builder: (BuildContext context) {
    //       return Container(
    //         decoration: const BoxDecoration(
    //             color: signInButtonColor,
    //             borderRadius: BorderRadius.only(
    //                 topLeft: Radius.circular(16),
    //                 topRight: Radius.circular(16))),
    //         child: Column(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             //close
    //             InkWell(
    //                 onTap: () => Get.back(),
    //                 child: Padding(
    //                     padding: EdgeInsets.symmetric(
    //                         vertical: MediaQuery.of(context).size.height * 0.03,
    //                         horizontal:
    //                             MediaQuery.of(context).size.width * 0.4),
    //                     child: ClipRRect(
    //                       borderRadius: BorderRadius.circular(20.0),
    //                       child: Container(
    //                         margin: const EdgeInsetsDirectional.only(
    //                             start: 1.0, end: 1.0),
    //                         height: MediaQuery.of(context).size.height * 0.005,
    //                         width: MediaQuery.of(context).size.width * 0.2,
    //                         decoration: BoxDecoration(
    //                           color: kDivider,
    //                           borderRadius: BorderRadius.circular(
    //                               10.0), // Adjust the radius as needed
    //                         ),
    //                       ),
    //                     ))),
    //
    //             //sketch
    //             InkWell(
    //               onTap: () async {
    //                 Get.back();
    //                 _controller.selectImage(context, ImageSource.gallery);
    //               },
    //               child: Container(
    //                 padding: const EdgeInsets.all(16),
    //                 width: double.infinity,
    //                 color: signInButtonColor,
    //                 height: MediaQuery.of(context).size.height * 0.08,
    //                 child: Row(
    //                   mainAxisAlignment: MainAxisAlignment.start,
    //                   crossAxisAlignment: CrossAxisAlignment.center,
    //                   children: [
    //                     SvgPicture.asset(AppAssets.photoIcon),
    //                     const SizedBox(width: 8),
    //                     // const Text("העלאת תמונה",
    //                     const Text("העלאת תמונה",
    //                         style: TextStyle(
    //                             color: titleTextWhiteColor, fontSize: 18)),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //
    //             //sketch
    //             InkWell(
    //               onTap: () async {
    //                 Get.back();
    //                 _controller.selectImage(context, ImageSource.camera);
    //               },
    //               child: Container(
    //                 padding: const EdgeInsets.all(16),
    //                 width: double.infinity,
    //                 color: signInButtonColor,
    //                 height: MediaQuery.of(context).size.height * 0.09,
    //                 child: Row(
    //                   mainAxisAlignment: MainAxisAlignment.start,
    //                   crossAxisAlignment: CrossAxisAlignment.center,
    //                   children: [
    //                     SvgPicture.asset(AppAssets.cameraIcon),
    //                     const SizedBox(width: 8),
    //                     // const Text("צילום תמונה",
    //                     const Text("צילום תמונה",
    //                         style: TextStyle(
    //                             color: titleTextWhiteColor, fontSize: 18)),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //             SizedBox(
    //               height: MediaQuery.of(context).size.height * 0.03,
    //             )
    //           ],
    //         ),
    //       );
    //     });
  }

  //select image

  @override
  void dispose() {
    animationController.stop();
    super.dispose();
  }
}

class Style {
  final String name;

  Style({required this.name});
}
