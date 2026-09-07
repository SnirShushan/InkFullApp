import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart'
    as gmwp;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:googlemaps_flutter_webservices/places.dart';
import 'package:ink/src/controller/businessProfilecontroller.dart';
import 'package:ink/src/ui/screen/sendTattoRquest/widget/custom_checkbox_widget.dart';
import 'package:ink/src/ui/widgets/button/custom_gradient_btn_widget.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/webService.dart';

class SearchBusinessUserWidget extends StatelessWidget {
  final BusinessProfileController businessProfileController;

  const SearchBusinessUserWidget(
      {super.key, required this.businessProfileController});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
        top: size.height * 0.02,
        bottom: size.height * 0.02,
      ), //symmetric(horizontal: 10.0, vertical: 10.0),
      color: bgBlack,
      child: Row(
        children: [
          Expanded(
              child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  controller: businessProfileController.searchController,
                  style: const TextStyle(color: Colors.white),
                  onTapOutside: (event) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  onChanged: (value){
                    if(value == ""){
                      businessProfileController.clearFilters();
                    }else{
                      businessProfileController.startBusinessProfile.value = 0;
                    }
                  },
                  onSubmitted: (value) async {

                    if(value == ""){
                      businessProfileController.clearFilters();
                      FocusManager.instance.primaryFocus?.unfocus();
                    }else{
                      if(businessProfileController.searchController.text ==""){
                        businessProfileController.startBusinessProfile.value = 0;
                        businessProfileController.clearFilters();
                        FocusManager.instance.primaryFocus?.unfocus();

                      }else{
                        FocusManager.instance.primaryFocus?.unfocus();
                        businessProfileController.businessList.clear();
                        businessProfileController.getBusinessList();

                      }
                    }
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    filled: true,
                    fillColor: socialoginbtn,
                    hintText: 'חפשו מקעקעים',
                    prefixIcon: InkWell(
                      onTap: () async {

                        FocusManager.instance.primaryFocus?.unfocus();
                        businessProfileController.startBusinessProfile.value =
                            0;
                        businessProfileController.businessList.clear();
                        await businessProfileController.getBusinessList();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SvgPicture.asset(
                          AppAssets.searchdashboard,
                          color: titleTextWhiteColor,
                        ),
                      ),
                    ),
                    hintStyle: const TextStyle(
                      color: placeholdertxtColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                    ),
                  ))),
          const SizedBox(
            width: 8,
          ),
          InkWell(
              onTap: () =>
                  _showFilterBottomSheet(context, businessProfileController),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ColoredBox(
                    color: socialoginbtn,
                    child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Obx(() => SizedBox(
                          height: 27.0,
                          width: 27.0,
                          child: SvgPicture.asset(
                              businessProfileController
                                          .isAsPerLocationClickable.value ||
                                      businessProfileController
                                          .isStyleEnabled.value ||
                                      businessProfileController
                                          .selectedStyles!.isNotEmpty
                                  ? AppAssets.filterAppliedIcon
                                  : AppAssets.filterIcon),
                        ))),
                  ))),
          const SizedBox(
            width: 8,
          ),
          InkWell(
              onTap: () =>
                  _showSortBottomSheet(context, businessProfileController),
              // onTap: () => SortBusinessUserWidget(
              //     businessProfileController: businessProfileController),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ColoredBox(
                    color: const Color(0xCC2B272F),
                    child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SizedBox(
                            height: 27.0,
                            width: 27.0,
                            child: SvgPicture.asset(AppAssets.sortIcon))),
                  ))),
        ],
      ),
    );
  }

  _showSortBottomSheet(
      BuildContext context, BusinessProfileController controller) {
    return showModalBottomSheet<dynamic>(
        useRootNavigator: true,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          // return StatefulBuilder(
          //     builder: (BuildContext context, StateSetter setState) {

          return Container(
            decoration: const BoxDecoration(
                color: signInButtonColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16))),
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //close
                  InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.03,
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Container(
                              margin: const EdgeInsetsDirectional.only(
                                  start: 1.0, end: 1.0),
                              height:
                                  MediaQuery.of(context).size.height * 0.005,
                              width: MediaQuery.of(context).size.width * 0.2,
                              decoration: BoxDecoration(
                                  color: kDivider,
                                  borderRadius: BorderRadius.circular(10.0)),
                            ),
                          ))),
                  Row(
                    children: [
                      SvgPicture.asset(AppAssets.sortIcon),
                      const SizedBox(width: 10),
                      const Text('מיון לפי',
                          style: TextStyle(
                              color: titleTextWhiteColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                      const Spacer(),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  Flexible(
                    child: Obx(() => Wrap(
                          spacing: 16.0,
                          runSpacing: 2.0,
                          children:
                              businessProfileController.options.map((option) {
                            return ElevatedButton(
                              onPressed: () {


                               if(option != "הכי קרובים אליכם"){
                                 businessProfileController
                                     .startBusinessProfile.value = 0;
                                 businessProfileController.hasMoreBusinessProfile.value=true;
                                 businessProfileController.businessList.clear();
                               }


                                businessProfileController.sortingsData(
                                    context: context, option: option);
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, // Adjust padding as needed
                                  vertical: 12.0, // Adjust padding as needed
                                ),
                                backgroundColor: option ==
                                        businessProfileController
                                            .isselected.value
                                    ? titleTextWhiteColor
                                    : signInButtonColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  side: const BorderSide(
                                      color:
                                          titleTextWhiteColor), // Border color
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (option ==
                                      businessProfileController
                                          .isselected.value)
                                    const Icon(
                                      Icons.check,
                                      color: bgBlack,
                                      size: 15,
                                    ),
                                  if (option ==
                                      businessProfileController
                                          .isselected.value)
                                    const SizedBox(width: 8),
                                  Text(
                                    option,
                                    style: TextStyle(
                                        color: option ==
                                                businessProfileController
                                                    .isselected.value
                                            ? signInButtonColor
                                            : titleTextWhiteColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        )),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  // Obx(
                  //   () => Visibility(
                  //     visible: businessProfileController.isClosest.value,
                  //     child: Column(
                  //       children: [
                  //         SizedBox(
                  //           height: 48,
                  //           child: TextField(
                  //             controller:
                  //                 businessProfileController.addressController,
                  //             onTap: () async {
                  //               controller.isLocationPopupOpen.value = true;
                  //
                  //               Future.delayed(const Duration(seconds: 1), () {
                  //                 print(
                  //                     "controller.isLocationPopupOpen ${controller.isLocationPopupOpen.value}");
                  //                 Navigator.of(context).pop();
                  //
                  //                 changeAddressSorting(
                  //                     context, businessProfileController);
                  //               });
                  //             },
                  //             canRequestFocus: false,
                  //             decoration: InputDecoration(
                  //                 hintText: 'חפשו עיר',
                  //                 hintStyle: const TextStyle(
                  //                     color: placeholdertxtColor),
                  //                 filled: true,
                  //                 fillColor: styleBgColor,
                  //                 contentPadding: const EdgeInsets.symmetric(
                  //                     horizontal: 12.0),
                  //                 border: OutlineInputBorder(
                  //                     borderRadius: BorderRadius.circular(8),
                  //                     borderSide: BorderSide.none)),
                  //             style:
                  //                 const TextStyle(color: titleTextWhiteColor),
                  //           ),
                  //         ),
                  //         SizedBox(
                  //             height:
                  //                 MediaQuery.of(context).size.height * 0.02),
                  //         Row(
                  //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //           children: [
                  //             Obx(
                  //               () => CustomCheckboxWidget(
                  //                   title: 'השתמשו במיקום הנוכחי שלי',
                  //                   onChanged: (value) =>
                  //                       businessProfileController
                  //                           .setCurrentLocation(
                  //                               isEnabled: value!),
                  //                   ischecked: businessProfileController
                  //                       .isCurrentLocationSelected.value),
                  //             ),
                  //             SizedBox(
                  //               height: 48,
                  //               width: MediaQuery.of(context).size.width * 0.2,
                  //               child: ElevatedButton(
                  //                 onPressed: () {
                  //                   controller.isOkButton = true.obs;
                  //                   if (businessProfileController.lat.value !=
                  //                       "") {
                  //                     businessProfileController.getBusinessList(
                  //                         isCloseSorting: true);
                  //                     Navigator.of(context).pop();
                  //                   } else {
                  //                     Get.rawSnackbar(
                  //                       messageText: const Text("אנא בחר מיקום",
                  //                           style: TextStyle(
                  //                             fontFamily: 'Arimo',
                  //                             // Assuming you have the Arimo font included
                  //                             fontSize: 14.0,
                  //                             // Logical pixels, may need adjustment
                  //                             fontWeight: FontWeight.normal,
                  //                             color: titleTextWhiteColor,
                  //                           )),
                  //                       snackPosition: SnackPosition.TOP,
                  //                       backgroundColor: errorColor,
                  //                       borderRadius: 8,
                  //                       margin: const EdgeInsets.all(30.0),
                  //                       padding: const EdgeInsets.symmetric(
                  //                           vertical: 20.0, horizontal: 0),
                  //                       duration: const Duration(seconds: 3),
                  //                       icon: SvgPicture.asset(
                  //                         AppAssets.errorIcon,
                  //                       ),
                  //                       // forwardAnimationCurve: Curves.easeOutBack,
                  //                     );
                  //                   }
                  //                 },
                  //                 style: ElevatedButton.styleFrom(
                  //                   backgroundColor: titleTextColor,
                  //                   shape: RoundedRectangleBorder(
                  //                     borderRadius: BorderRadius.circular(8),
                  //                   ),
                  //                 ),
                  //                 child: const Text('סינון',
                  //                     style: TextStyle(
                  //                         color: bgBlack,
                  //                         fontWeight: FontWeight.w500)),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),

                  SizedBox(height: Platform.isIOS?MediaQuery.of(context).size.height * 0.02:MediaQuery.of(context).size.height * 0.05),
                ],
              ),
            ),
          );
        }).whenComplete(() {
      // if (controller.isLocationPopupOpen.value == false &&
      //     controller.lat.value == "" &&
      //     controller.isClosest.value == true) {
      //   //Location not select and closet selected
      //   if (controller.previousId == "2") {
      //     businessProfileController.sortingsData(
      //         iscloseTime: false, context: context, option: "הפופולרים ביותר");
      //   } else {
      //     controller.isRecommended.value = false;
      //     businessProfileController.sortingsData(
      //         iscloseTime: false, context: context, option: "מומלצים עבורכם");
      //   }
      // } else if (controller.isLocationPopupOpen.value == false &&
      //     controller.isOkButton.value == false &&
      //     controller.lat.value != "" &&
      //     controller.isClosest.value == true) {
      //   //Location select and ok button not select.
      //   if (controller.previousId == "2") {
      //     businessProfileController.sortingsData(
      //         iscloseTime: false, context: context, option: "הפופולרים ביותר");
      //   } else {
      //     controller.isRecommended.value = false;
      //     businessProfileController.sortingsData(
      //         iscloseTime: false, context: context, option: "מומלצים עבורכם");
      //   }
      // } else {
      //   //is location popup close time
      //   controller.isLocationPopupOpen = false.obs;
      // }
    });
  }

  _showFilterBottomSheet(
    BuildContext context,
    BusinessProfileController controller,
  ) {
    return showModalBottomSheet<dynamic>(
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: false,
        context: context,
        builder: (BuildContext context) {
          return Container(
            decoration: const BoxDecoration(
                color: signInButtonColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16))),
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Obx(() => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //back
                      InkWell(
                          onTap: () {
                            controller.isFilterApplied();
                            Get.back();
                          },
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.height * 0.03,
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: Container(
                                  margin: const EdgeInsetsDirectional.only(
                                      start: 1.0, end: 1.0),
                                  height: MediaQuery.of(context).size.height *
                                      0.005,
                                  width:
                                      MediaQuery.of(context).size.width * 0.2,
                                  decoration: BoxDecoration(
                                    color: kDivider,
                                    borderRadius: BorderRadius.circular(
                                        10.0), // Adjust the radius as needed
                                  ),
                                ),
                              ))),

                      Row(
                        children: [
                          SvgPicture.asset(AppAssets.filterIcon),
                          const SizedBox(width: 10),
                          const Text('סינון',
                              style: TextStyle(
                                  color: titleTextWhiteColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700)),
                          const Spacer(),
                          TextButton(
                            child: const Text('איפוס',
                                style: TextStyle(
                                    color: titleTextColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400)),
                            onPressed: () {
                              controller.clearFilters();
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      ),

                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03),

                      const Text("מיקום",
                          style: TextStyle(
                              color: titleTextWhiteColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w400)),

                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03),

                      //address
                      SizedBox(
                        height: 48,
                        child: TextField(
                          controller:
                              businessProfileController.addressController,
                          onTap: () async {
                            Navigator.of(context).pop();
                            changeAddress(context, controller);
                          },
                          canRequestFocus: false,
                          decoration: InputDecoration(
                              hintText: 'חפשו עיר',
                              hintStyle:
                                  const TextStyle(color: placeholdertxtColor),
                              filled: true,
                              fillColor: styleBgColor,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none)),
                          style: const TextStyle(color: titleTextWhiteColor),
                        ),
                      ),

                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      Obx(
                        () => CustomCheckboxWidget(
                            title: 'השתמשו במיקום הנוכחי שלי',
                            onChanged: (value) => controller.setCurrentLocation(
                                isEnabled: value!),
                            ischecked:
                                controller.isCurrentLocationSelected.value),
                        // Checkbox(
                        //     value: controller.isCurrentLocationSelected.value,
                        //     onChanged: (value) => controller
                        //         .setCurrentLocation(isEnabled: value!),
                        //     activeColor: titleTextColor,
                        //     checkColor: const Color(0xFF28272f),
                        //     shape: RoundedRectangleBorder(
                        //         // Making around shape
                        //         borderRadius: BorderRadius.circular(4)),
                        //     side: BorderSide(
                        //         color:
                        //             controller.isCurrentLocationSelected.value
                        //                 ? titleTextColor
                        //                 : lightGrayColor,
                        //         width: 2.0),
                        //     fillColor:
                        //         MaterialStateProperty.resolveWith((states) {
                        //       if (!states.contains(MaterialState.selected)) {
                        //         return socialoginbtn;
                        //       }
                        //       return null;
                        //     })),
                      ),

                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),

                      //styles
                      const Text("סגנון",
                          style: TextStyle(
                              color: titleTextWhiteColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w400)),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          // children: categories.map((category) {
                          children: controller.userController.style_list
                              .map((category) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () =>
                                        controller.selectStyle(category),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Stack(
                                          children: [
                                            ColoredBox(
                                                color: kWhite,
                                                child: buildCachedNetworkImage(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                    url: WebService
                                                        .resolveImageUrl(
                                                            category.imageName,
                                                            base: WebService
                                                                .styleImgUrl),
                                                    radius: 10)),
                                            if (controller.selectedStyles!.value
                                                .contains(category))
                                              ColoredBox(
                                                  color: Colors.black45,
                                                  child: SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                  )),
                                            if (controller.selectedStyles!
                                                .contains(category))
                                              Positioned(
                                                  top: 8,
                                                  right: 3,
                                                  child: SizedBox(
                                                      height: 20.0,
                                                      width: 20.0,
                                                      child: SvgPicture.asset(
                                                          AppAssets
                                                              .icSelected))),
                                          ],
                                        )),
                                  ),
                                  // CachedNetworkImage(
                                  //       imageUrl: WebService.styleImgUrl +category.imageName!,
                                  //       height: MediaQuery.of(context).size.width * 0.2,
                                  //       width: MediaQuery.of(context).size.width * 0.2,
                                  //       fit: BoxFit.cover)),
                                  const SizedBox(height: 5),
                                  Text(
                                    category.name!,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03),

                      CustomGradientButtonWidget(
                        height: 52,
                        title: 'סינון',
                        onTap: () {
                          controller.isAsPerLocation == true
                              ? controller.isAsPerLocationClickable.value =
                          true
                              : controller.isAsPerLocationClickable.value =
                          false;
                          controller.isFilterApplied();
                          controller.startBusinessProfile.value = 0;
                          businessProfileController.hasMoreBusinessProfile.value=true;
                          controller.businessList.clear();

                          controller.getBusinessList();
                          Get.back();
                        },
                      ),


                     SizedBox(
                          height:Platform.isAndroid? MediaQuery.of(context).size.height * 0.08:MediaQuery.of(context).size.height * 0.03)
                    ],
                  )),
            ),
          );
        });
  }

  changeAddress(
      BuildContext context, BusinessProfileController controller) async {
    var place = await PlacesAutocomplete.show(
        context: context,
        apiKey: WebService.googleApiKey,
        mode: Mode.overlay,
        language: 'He',
        types: [],
        components: [const gmwp.Component(gmwp.Component.country, 'IL')],
        onError: (err) {
          // displayMessageIcon(
          //     message: err.errorMessage.toString(),
          //     color: errorColor,
          //     imageData: AppAssets.errorIcon);
        });

    if (place != null) {
      final plist = GoogleMapsPlaces(
          apiKey: WebService.googleApiKey,
          apiHeaders: await const GoogleApiHeaders().getHeaders());
      String placeId = place.placeId ?? "0";
      final detail = await plist.getDetailsByPlaceId(placeId);
      if (detail.result != null) {
        print(detail.result);
        final geometry = detail.result.geometry!;
        print("geometry $geometry");

        controller.lat.value = geometry.location.lat.toString();
        controller.lng.value = geometry.location.lng.toString();
        controller.addressController.text = place.description!;
        controller.isAsPerLocation.value = true;
        // controller.setCurrentLocation(isEnabled: false);

        controller.isCurrentLocationSelected.value = false;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showFilterBottomSheet(Get.context!, controller);
        });
      }
    }
  }

  void changeAddressSorting(
      BuildContext context, BusinessProfileController controller) async {
    var place = await PlacesAutocomplete.show(
        context: context,
        apiKey: WebService.googleApiKey,
        mode: Mode.overlay,
        language: 'He',
        types: [],
        components: [const gmwp.Component(gmwp.Component.country, 'IL')],
        onError: (err) {
          // displayMessageIcon(
          //     message: err.errorMessage.toString(),
          //     color: errorColor,
          //     imageData: AppAssets.errorIcon);
        });

    if (place != null) {
      final plist = GoogleMapsPlaces(
          apiKey: WebService.googleApiKey,
          apiHeaders: await const GoogleApiHeaders().getHeaders());
      String placeId = place.placeId ?? "0";
      final detail = await plist.getDetailsByPlaceId(placeId);
      if (detail.result != null) {
        print(detail.result);
        final geometry = detail.result.geometry!;
        print("geometry $geometry");

        controller.lat.value = geometry.location.lat.toString();
        controller.lng.value = geometry.location.lng.toString();
        controller.addressController.text = place.description!;
        controller.isAsPerLocation.value = true;
        // controller.setCurrentLocation(isEnabled: false);

        controller.isCurrentLocationSelected.value = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showSortBottomSheet(
            Get.context!,
            controller,
          );
        });
      }
    }
  }
}
