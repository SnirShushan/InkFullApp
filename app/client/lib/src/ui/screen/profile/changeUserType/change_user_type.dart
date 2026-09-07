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
import 'package:ink/src/controller/change_user_type.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard_binding.dart';
import 'package:ink/src/ui/screen/profile/changeUserType/controller/businessList_controller.dart';
import 'package:ink/src/ui/screen/profile/changeUserType/widget/agreement%20regulations/agrement%20regulations.dart';
import 'package:ink/src/ui/screen/profile/select_category.dart';
import 'package:ink/src/ui/screen/profile/subscription/iosubscription/purchase_ios_screen.dart';
import 'package:ink/src/ui/screen/profile/subscription/purchase_screen.dart';
import 'package:ink/src/ui/widgets/button/custom_gradient_btn_child_widget.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/permissions.dart';
import 'package:ink/src/utils/utils.dart';
import 'package:ink/src/utils/webService.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';

import '../../../widgets/unfocus_widget.dart';
import 'tagmembers.dart';

class ScreenChangeUserType extends StatefulWidget {
  const ScreenChangeUserType({Key? key}) : super(key: key);

  @override
  State<ScreenChangeUserType> createState() => _ScreenChangeUserTypeState();
}

class _ScreenChangeUserTypeState extends State<ScreenChangeUserType>
    with SingleTickerProviderStateMixin {
  bool isStudio = false;
  bool isArtist = false;
  late AnimationController animationController;
  late Animation<double> base;
  final GlobalKey<ScaffoldState> homeScaffoldKey = GlobalKey<ScaffoldState>();
  final searchScaffoldKey = GlobalKey<ScaffoldState>();

  late final AppUser user;
  List<StylesList> listStyles = [];

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController signController = TextEditingController();

  final hintStyle = const TextStyle(color: hintTextColor);
  final textStyle = const TextStyle(color: kWhite);
  bool isAddressEmpty = true;

  final ScrollController scrollController = ScrollController();

  final ChangeUserTypeController changeUserTypeController =
      Get.put(ChangeUserTypeController());
  final BusinessListController artistListController =
      Get.put(BusinessListController());

  @override
  void initState() {
    artistListController.selectedList.clear();
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    base = CurvedAnimation(parent: animationController, curve: Curves.easeOut);
    super.initState();
    getUser();
  }

  Future getUser() async {
    user = await WebService.getCurrentUser();

    user.stylesList?.map((doc) {
      listStyles.add(doc);
    }).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double textScaleFactor = MediaQuery.textScalerOf(context).scale(1);
    return UnFocusWidget(
        child: PopScope(
      canPop: false,
      child: Scaffold(
        body: SizedBox.expand(
          child: Stack(
            fit: StackFit.loose,
            children: <Widget>[
              Stack(
                children: [
                  Image.asset(AppAssets.changeUserTypeBg,
                      width: size.width,
                      height: size.height * 0.5,
                      fit: BoxFit.cover),
                  Positioned(
                    top: size.height * 0.08,
                    right: 20,
                    child: InkWell(
                      splashColor: dividerGray,
                      onTap: () {
                        Get.offAll(
                            () => const DashBoard(
                                  initialIndex: 3,
                                ),
                            binding: DashBoardBinding());
                      },
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            AppAssets.backarrowIcon,
                            color: titleTextColor,
                          ),
                          SizedBox(width: size.width * 0.02),
                          Text(
                            "חזרה",
                            style: TextStyle(
                                fontSize: 16 * textScaleFactor,
                                color: dividerGray),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox.expand(
                child: DraggableScrollableSheet(
                  initialChildSize: 0.8,
                  maxChildSize: 0.8,
                  snapSizes: [0.8],
                  minChildSize: 0.8,
                  expand: false,
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Obx(() => Container(
                        decoration: const BoxDecoration(
                            color: bgBlack,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(36), //25
                                topRight: Radius.circular(36))), //25,
                        height: size.height,
                        child: ListView(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.05,
                                vertical: size.height * 0.03),
                            controller: scrollController,
                            children: [
                              //title
                              Utils.buildTitle(title: "user_to_business.title"),

                              SizedBox(height: size.height * 0.02),
                              buildArtistOrStudioSelection(size: size),
                              SizedBox(height: size.height * 0.01),
                              //name
                              buildName(size, context),

                              //address
                              buildAddress(size, context),

                              //style
                              buildStylesSelection(size, context),

                              //description
                              buildDescription(size, context),

                              //artist selection
                              if (changeUserTypeController
                                  .isStudioSelected.value)
                                buildArtistSelection(size, context),

                              //signature
                              buildSignatureView(size, context),

                              SizedBox(height: size.height * 0.04),

                              //continue
                              buildBtnSubmit(context: context, size: size),
                              SizedBox(height: Platform.isAndroid?size.height * 0.04:size.height * 0.023),
                            ])));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  //toggle studio or artist
  // buildArtistOrStudioSelection({required Size size}) =>
  //     Row(mainAxisAlignment: MainAxisAlignment.center, children: [
  //       buildTabBtn(
  //           title: "user_to_business.txt_studio",
  //           onTap: () => changeUserTypeController.setTypeStudio(true),
  //           icon: AppAssets.studioIconSvg,
  //           size: size,
  //           isSelected:
  //               changeUserTypeController.isStudioSelected.value == true),
  //       buildTabBtn(
  //           title: "user_to_business.txt_artist",
  //           // onTap: () => changeUserTypeController.setTypeStudio(false),
  //           icon: AppAssets.artistIconSvg,
  //           size: size,
  //           isSelected:
  //               changeUserTypeController.isStudioSelected.value == false),
  //     ]);

  buildArtistOrStudioSelection({required Size size}) => IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              icon: SvgPicture.asset(AppAssets.artistIconSvg),
              onPressed: () {},
              label: Text(
                localization.tr("user_to_business.txt_artist"),
                style: const TextStyle(
                    color: titleTextWhiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 4),
            Container(
                height: 2, width: size.width * 0.45, decoration: const BoxDecoration( color: titleTextColor),),
          ],
        ),
      );

  //build tab btn for business selection
  // buildTabBtn(
  //         {required String title,
  //         required VoidCallback onTap,
  //         required String icon,
  //         required Size size,
  //         required bool isSelected}) =>
  //     Expanded(
  //       child: Container(
  //         decoration: BoxDecoration(
  //           border: Border(
  //             bottom: BorderSide(
  //                 width: 2.0,
  //                 color: isSelected ? titleTextColor : socialoginbtn),
  //           ),
  //         ),
  //         child: TextButton.icon(
  //           icon: SvgPicture.asset(icon),
  //           onPressed: onTap,
  //           label: Text(
  //             title,
  //             style: TextStyle(
  //                 color: isSelected ? titleTextWhiteColor : textEditingColor2,
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.w500),
  //           ).tr(),
  //         ),
  //       ),
  //     );

  // Business Name Or Studio Name
  Column buildName(Size size, BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.03),
          Text(
            changeUserTypeController.isStudioSelected.value
                ? "user_to_business.studio_name"
                : "user_to_business.business_name",
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: titleTextWhiteColor, fontWeight: FontWeight.w400),
          ).tr(),
          SizedBox(height: size.height * 0.02),
          Obx(
            () => TextFormField(
                autofocus: false,
                controller: changeUserTypeController.nameController,
                keyboardType: TextInputType.name,
                style: textStyle,
                decoration: InputDecoration(
                  hintStyle: hintStyle,
                  hintText: changeUserTypeController.isStudioSelected.value
                      ? localization.tr("user_to_business.name_hint_studio")
                      : localization.tr("user_to_business.name_hint_artist"),
                  contentPadding: const EdgeInsets.all(8),
                  filled: true,
                  fillColor: socialoginbtn,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                )),
          ),
        ],
      );

  // Address
  Column buildAddress(Size size, BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.03),
          Text(
            "user_to_business.address",
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: titleTextWhiteColor, fontWeight: FontWeight.w400),
          ).tr(),
          SizedBox(height: size.height * 0.02),
          TextFormField(
              onTap: () async {
                var place = await fg.PlacesAutocomplete.show(
                    context: context,
                    apiKey: WebService.googleApiKey,
                    mode: fg.Mode.overlay,
                    language: 'He',
                    types: [],
                    components: [gmwp.Component(gmwp.Component.country, 'IL')],
                    onError: (err) {
                      print(
                          "err.errorMessage.toString() ${err.errorMessage.toString()}");
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
                      break;
                    }
                  }
                  WebService.placeId = placeId;
                  WebService.lat = geometry.location.lat;
                  WebService.lang = geometry.location.lng;
                  WebService.address = place.description!;
                  WebService.cityName = cityName;

                  setState(() {
                    changeUserTypeController.addressController.text =
                        WebService.address;
                  });
                }
              },
              autofocus: false,
              controller: changeUserTypeController.addressController,
              keyboardType: TextInputType.streetAddress,
              style: textStyle,
              decoration: InputDecoration(
                hintStyle: hintStyle,
                hintText: localization.tr("user_to_business.address_hint"),
                contentPadding: const EdgeInsets.all(8),
                filled: true,
                fillColor: socialoginbtn,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon:
                    changeUserTypeController.addressController.text.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(8),
                            child: SvgPicture.asset(
                              AppAssets.correct_transparentIcon,
                            ),
                          ) //Image.asset(AppAssets.correct_transparentIcon)
                        : null,
              )),
        ],
      );

  //select styles
  buildStylesSelection(Size size, BuildContext context) => Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.03),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "user_to_business.style_title",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: titleTextWhiteColor, fontWeight: FontWeight.w400),
              ).tr(),
              if (changeUserTypeController.selectedStyles.value.isNotEmpty)
                InkWell(
                  onTap: () => Utils.goToScreen(
                      screen: SelectCategory(
                        changeUserTypeController: changeUserTypeController,
                        isChangeUserType: true,
                      ),
                      isOffAll: false),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(AppAssets.editIcon,
                          color: titleTextColor),
                      const SizedBox(width: 4),
                      Text(
                        "user_to_business.editing",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                color: titleTextWhiteColor,
                                fontWeight: FontWeight.w400),
                      ).tr(),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: size.height * 0.02),
          changeUserTypeController.selectedStyles.isEmpty
              ? UserBusinessGradientButtonWidget(
                  width: size.width * 0.4,
                  onTap: () => Utils.goToScreen(
                      screen: SelectCategory(
                          changeUserTypeController: changeUserTypeController,
                          isChangeUserType: true),
                      isOffAll: false),
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
              : Wrap(
                  spacing: 8.0,
                  children: changeUserTypeController.selectedStyles.value
                      .map((style) => InkWell(
                            onTap: () =>
                                changeUserTypeController.toggleStyles(style),
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
                                mainAxisSize:
                                    MainAxisSize.min, // Restrict the size
                                children: [
                                  Text(
                                    style.name!,
                                    style: const TextStyle(color: whiteTxtColor),
                                  ),
                                  const SizedBox(width: 5),
                                  const Icon(Icons.close,
                                      color: whiteTxtColor, size: 20),
                                ],
                              ),
                            ),
                          ))
                      .toList()),
        ],
      ));

  //Description
  Column buildDescription(Size size, BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.03),
          Text(
            "user_to_business.tell_us_studio",
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: titleTextWhiteColor, fontWeight: FontWeight.w400),
          ).tr(),
          SizedBox(height: size.height * 0.02),
          TextFormField(
              autofocus: false,
              controller: changeUserTypeController.aboutController,
              maxLines: null,
              minLines: 5,
              keyboardType: TextInputType.multiline,
              style: textStyle,
              autovalidateMode: AutovalidateMode.always,
              inputFormatters: [
                LengthLimitingTextInputFormatter(400),
              ],
              validator: (String? value) {
                if (value!.length >= 400) {
                  return ' התיאור ארוך מדי'; //description is to long
                }
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
            "user_to_business.information_business_profile",
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Color(0xFF807C84),
                fontSize: 14,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w400),
          ).tr(),
        ],
      );

  //artist selection
  buildArtistSelection(Size size, context) => artistListController
          .selectedList.isEmpty
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height * 0.02),
            Text(
              "user_to_business.member_of_studio",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: titleTextWhiteColor, fontWeight: FontWeight.w400),
            ).tr(),
            Padding(
              padding: EdgeInsets.only(top: size.height * 0.01),
              child: ElevatedButton(
                  onPressed: () =>
                      Utils.goToScreen(screen: TagMembers(), isOffAll: false),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        vertical: size.height * 0.02,
                        horizontal: size.width * 0.04),
                    backgroundColor: titleTextColor, // Google Red
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // <-- Radius
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "user_to_business.btn_artist_selection_title",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                color: bgBlack, fontWeight: FontWeight.w400),
                      ).tr(),
                      SizedBox(width: size.width * 0.02),
                      SvgPicture.asset(AppAssets.btnarrowIcon, color: bgBlack)
                    ],
                  )),
            ),
          ],
        )
      : Column(
          children: [
            SizedBox(height: size.height * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "user_to_business.member_of_studio",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: titleTextWhiteColor, fontWeight: FontWeight.w400),
                ).tr(),
                InkWell(
                  onTap: () =>
                      Utils.goToScreen(screen: TagMembers(), isOffAll: false),
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
                        "user_to_business.editing",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                color: titleTextWhiteColor,
                                fontWeight: FontWeight.w400),
                      ).tr(),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
            SizedBox(
              height: size.height * 0.1,
              child: Stack(
                  children: List.generate(
                      artistListController.selectedList.length, (index) {
                return Positioned(
                    right: index * 30,
                    child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                            border: Border.all(color: btnWhite, width: 3),
                            borderRadius: BorderRadius.circular(50)),
                        child: CircleAvatar(
                          backgroundImage:
                              AssetImage(AppAssets.userPlaceHolder),
                          foregroundImage: NetworkImage(
                              WebService.resolveProfileImage(
                                  artistListController
                                      .selectedList[index].profileImage)),
                        )));
              })),
            ),
          ],
        );

  //Signature
  Column buildSignatureView(Size size, BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: size.height * 0.03),
        Text(
          "user_to_business.signature",
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: titleTextWhiteColor, fontWeight: FontWeight.w400),
        ).tr(),
        SizedBox(height: size.height * 0.02),
        ClipRRect(
          borderRadius:
              BorderRadius.circular(8.0), // Set the desired corner radius
          child: Signature(
            controller: changeUserTypeController.signController,
            height: 200,
            backgroundColor: signInButtonColor,
          ),
        ),
        SizedBox(height: size.height * 0.01),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(
            children: [
              Text("user_to_business.signature_subtitle",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: titleTextWhiteColor,
                          fontWeight: FontWeight.w400))
                  .tr(),
              SizedBox(width: size.width * 0.01),
              InkWell(
                  onTap: () => Get.to(() => AgrementRegulations()),
                  child: Text("user_to_business.txt_signature_cut",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                  decoration: TextDecoration.underline,
                                  color: appPrimaryColor,
                                  fontWeight: FontWeight.w400))
                      .tr()),
            ],
          ),
          TextButton.icon(
              icon: Image.asset(AppAssets.clearSign),
              // icon: const Icon(Icons.refresh, color: kWhite),
              onPressed: () => changeUserTypeController.signController.clear(),
              label: Text("נקה", style: textStyle)),
        ]),
      ]);

  bool isEnableBtn() {
    if (changeUserTypeController.nameController.text.isNotEmpty &&
        changeUserTypeController.addressController.text.isNotEmpty &&
        changeUserTypeController.nameController.text.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  //button
  InkWell buildBtnSubmit({required BuildContext context, required Size size}) =>
      InkWell(
        onTap: !isEnableBtn()
            ? () {}
            : () async {
                changeUserTypeController.isLoading.value = true;
                animationController.forward();
                animationController.repeat();
                Future.delayed(const Duration(seconds: 1), () {})
                    .then((value) async {
                  try {
                    if (changeUserTypeController.nameController.text.isEmpty) {
                      displayMessageIcon(
                          message: "אנא הקצה שם לעסק",
                          snackposition: SnackPosition.BOTTOM,
                          color: errorColor,
                          imageData: AppAssets.errorIcon);
                      // please assign name to business
                      return;
                    }
                    if (changeUserTypeController
                        .addressController.text.isEmpty) {
                      displayMessageIcon(
                          message: "נא להזין כתובת",
                          snackposition: SnackPosition.BOTTOM,
                          color: errorColor,
                          imageData: AppAssets.errorIcon);
                      // displayMessage(
                      //     , Colors.red); //please enter address
                      return;
                    }

                    if (changeUserTypeController.signController.isEmpty) {
                      displayMessageIcon(
                          message: "alerts.no_sign",
                          snackposition: SnackPosition.BOTTOM,
                          color: errorColor,
                          imageData: AppAssets.errorIcon);
                      return;
                    }

                    var pngBytes = await changeUserTypeController.signController
                        .toPngBytes();

                    if (!(await checkPermission())) await requestPermission();

                    Directory? directory = await getTemporaryDirectory();
                    String path = directory.path;

                    var directoryName = "signatures";

                    await Directory('$path/$directoryName')
                        .create(recursive: true);

                    File("$path/$directoryName/signature_image.png")
                        .writeAsBytesSync(pngBytes!.buffer.asInt8List());

                    WebService.signFile =
                        File("$path/$directoryName/signature_image.png");

                    if (await WebService.signFile.exists()) {
                      var sub = await Network.getCheckSubscriptionRegistration(
                          nameCheck:
                              changeUserTypeController.nameController.text);
                      if (sub != false && sub != null) {
                        String isNameExists =
                            await sub["data"]["is_name_exist"];
                        if (isNameExists == "") {
                          changeUserTypeController.selectedNewArtists.value =
                              [];
                          for (var artist
                              in artistListController.selectedList) {
                            if (!changeUserTypeController.selectedNewArtists
                                .contains(artist)) {
                              changeUserTypeController.selectedNewArtists
                                  .add(artist.id ?? "");
                            }
                          }

                          if (Platform.isAndroid) {
                            Get.to(PurchaseScreen(
                                fromRegistration: true,
                                checkstatus: sub['status'].toString()));
                          } else {
                            Get.to(IOSPurchaseScreen(
                                checkstatus: sub['status'].toString(),
                                purchasename: 'ללא תוכנית קנייה',
                                fromRegistration: true));
                          }
                        } else {
                          displayMessageIcon(
                              message: isNameExists,
                              color: errorColor,
                              snackposition: SnackPosition.BOTTOM,
                              imageData: AppAssets.errorIcon);
                        }
                      }
                    }
                  } finally {
                    changeUserTypeController.isLoading.value = false;
                    animationController.stop();
                  }
                });
              },
        child: Container(
            width: size.width,
            height: size.height * 0.07,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              gradient: LinearGradient(
                begin: Alignment.centerRight, // For RTL, start from right
                end: Alignment.centerLeft, // For RTL, end at left
                colors: [
                  linearGradieantColor1,
                  linearGradieantColor2,
                  linearGradieantColor3,
                ],
                stops: [0.0, 0.001, 0.8937],
              ),
            ),
            child: Obx(() => changeUserTypeController.isLoading.value
                ? Center(
                    child: RotationTransition(
                        turns: base, child: Image.asset(AppAssets.loadingIcon)),
                  )
                : Text(
                    "user_to_business.opening_a_profile",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: !isEnableBtn() ? defaultGrey : Colors.white,
                        fontWeight: FontWeight.w700),
                  ).tr())),
      );

  @override
  void dispose() {
    animationController.stop();
    animationController.dispose();
    super.dispose();
  }
}
