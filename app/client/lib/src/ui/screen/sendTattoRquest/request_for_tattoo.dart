import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ink/src/controller/businessDetailControllor.dart';
import 'package:ink/src/controller/userController.dart';
import 'package:ink/src/data/model/bodypart_images.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/data/model/image_model.dart';
import 'package:ink/src/ui/screen/sendTattoRquest/controller/imgListController.dart';
import 'package:ink/src/ui/screen/sendTattoRquest/widget/custom_checkbox_widget.dart';
import 'package:ink/src/ui/screen/sendTattoRquest/widget/stadium_toggle_btn.dart';
import 'package:ink/src/ui/widgets/bodyparts/rotation_stage/src/rotation_stage_labels.dart';
import 'package:ink/src/ui/widgets/bodyparts/src/body_part_selector_turnable.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/webService.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

import '../../widgets/appbar_back_widget.dart';
import 'widget/dashed_border_widget.dart';

class ScreenTattooRequest extends StatefulWidget {
  final String bId;

  const ScreenTattooRequest({super.key, required this.bId});

  @override
  State<ScreenTattooRequest> createState() => _ScreenTattooRequestState();
}

class _ScreenTattooRequestState extends State<ScreenTattooRequest>
    with SingleTickerProviderStateMixin {
  List<StylesList> listStyles = [];
  int selectedindex = 0;
  final picker = ImagePicker();
  bool isNotSureStyle = false;
  bool isNotPreference = false;
  late Animation<double> base;
  final imgListController = Get.put(ImgListController());
  final userController = Get.find<UserController>();
  final businessDetailsController = Get.put(BusinessDetailController());

  // ScreenshotController screenshotController = ScreenshotController();

  late final AppUser user;
  String tattooSize = "L";
  String selectedCreatorId = "";
  late AnimationController animationController;
  bool isImageSelected1 = false;
  bool isImageSelected2 = false;
  bool isImageSelected3 = false;
  File imageFile1 = File("");
  File imageFile2 = File("");
  File imageFile3 = File("");
  late Animation inverted;
  late Animation<Offset> slidAnimation;
  bool isvalidate = false;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));
    base = CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    businessDetailsController.getBusinessInfo(bid: widget.bId);
    inverted = Tween<double>(begin: 0.0, end: -1.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.linear));

    slidAnimation =
        Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(
            CurvedAnimation(
                parent: animationController, curve: Curves.easeInOut));

    WebService.changeUserStyleList.clear();
    imgListController.nameController.text = userController.name.value ?? "";
    imgListController.phoneController.text = userController.phone.value ?? "";
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
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: bgBlack,
      appBar: AppBarBackButtonWidget(
          title: tr('sending_request.sending_request_title'),
          titleColor: titleTextColor,
          iconColor: titleTextColor),
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   title: Column(
      //     children: [
      //       SizedBox(height: size.height * 0.02),
      //       Row(
      //         children: [
      //           InkWell(
      //             onTap: () => Get.back(),
      //             child: Row(
      //                 crossAxisAlignment: CrossAxisAlignment.center,
      //                 mainAxisSize: MainAxisSize.min,
      //                 children: [
      //                   SvgPicture.asset(AppAssets.backarrowIcon,
      //                       width: 22, height: 22, color: titleTextColor),
      //                   SizedBox(width: size.width * 0.02),
      //                   Text(
      //                     "sending_request.sending_request_title",
      //                     style: Theme.of(context)
      //                         .textTheme
      //                         .headlineSmall
      //                         ?.copyWith(
      //                           color: titleTextColor,
      //                           fontWeight: FontWeight.w700,
      //                         ),
      //                   ).tr()
      //                 ]),
      //           ),
      //         ],
      //       ),
      //     ],
      //   ),
      // ),
      body: Padding(
        padding: EdgeInsets.all(size.height * 0.02),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTitle(context, size, textTheme),
              SizedBox(height: size.height * 0.03),
              buildSendingRequestAdvice(size, textTheme),
              SizedBox(height: size.height * 0.03),
              buildNotes(size, textTheme),
              SizedBox(height: size.height * 0.03),
              buildTattoSize(context, size, textTheme),
              buildStyleList(context, size, textTheme),
              buildImageUpload(context, size, textTheme),
              buildLocationChoose(context, size, textTheme),
              // buildLocationChooseSS(context, size, textTheme),
              buildTattoArtist(context, size, textTheme),
              buildAdditionalNotes(context, size, textTheme),
              buildBtnSubmit(context: context, size: size),
              if(Platform.isAndroid) SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              )

            ],
          ),
        ),
      ),
    );
  }

  Container buildBorderContainer(TextTheme textTheme, title) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          border: Border.all(color: titleTextColor),
          borderRadius: BorderRadius.circular(20)),
      child: Text(
        title,
        style: textTheme.titleSmall!.copyWith(color: titleTextColor),
      ),
    );
  }

  //Title
  buildTitle(BuildContext context, size, textTheme) => Obx(() => Row(
        children: [
          ClipOval(
            child: Container(
              height: size.width * 0.12,
              width: size.width * 0.12,
              color: Colors.white,
              child: Obx(() => buildOwnerProfileImage(
                  size: size,
                  width: size.width * 0.11,
                  ownerImage:
                      businessDetailsController.profile_image.value == ""
                          ? ""
                          : businessDetailsController.profile_image.value)),
            ),
          ),
          SizedBox(
            width: size.width * 0.02,
          ),
          Text(businessDetailsController.name.value,
              style: textTheme.titleLarge?.copyWith(
                color: kWhite,
                fontWeight: FontWeight.w700,
              )),
        ],
      ));

  //Sending Request Advice
  Container buildSendingRequestAdvice(Size size, TextTheme textTheme) =>
      Container(
        width: size.width,
        padding: const EdgeInsets.all(16),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: purchasebgcolor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "sending_request.sending_request_advice_title",
              style: textTheme.titleMedium!.copyWith(
                  color: kWhite, fontWeight: FontWeight.w700, fontSize: 16),
            ).tr(),
            SizedBox(height: size.height * 0.01),
            Text(
              "sending_request.sending_request_advice_subtitle",
              style: textTheme.titleMedium!.copyWith(
                  color: kWhite, fontWeight: FontWeight.w400, fontSize: 16),
            ).tr(),
            SizedBox(height: size.height * 0.02),
            Obx(() => InkWell(
                  onTap: () async {
                    bool isConnected =
                        await WebService.checkConnectionShowMsg();
                    if (!isConnected) return;
                    imgListController.isNewRequestLoading.value = true;
                    animationController.forward();
                    animationController.repeat();

                    imgListController
                        .directSendRequest(
                            bid: businessDetailsController.id.value)
                        .then((value) {
                      animationController.stop();
                    });
                  },
                  child: Container(
                    width: size.width * 0.45,
                    height: size.height * 0.06,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      color: titleTextColor,
                      gradient: appLinearGradient
                    ),
                    child: imgListController.isNewRequestLoading.value
                        ? Center(
                            child: RotationTransition(
                                turns: base,
                                child: Image.asset(AppAssets.loadingIcon)),
                          )
                        : Text(
                            "sending_request.sending_request_advice_btn",
                            style: textTheme.titleSmall!.copyWith(
                                color: whiteTxtColor,
                                // color: bgBlack,
                                fontWeight: FontWeight.w400,
                                fontSize: 14),
                          ).tr(),
                  ),
                ))
          ],
        ),
      );

  Padding buildNotes(Size size, TextTheme textTheme) => Padding(
        padding: EdgeInsets.only(left: size.width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                // businessDetailsController.name.value,
                "sending_request.sending_request_notes_title",
                style: textTheme.titleLarge?.copyWith(
                  color: titleTextWhiteColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                )).tr(),
            SizedBox(height: size.height * 0.02),
            Text(
                // businessDetailsController.name.value,
                "sending_request.sending_request_notes_description",
                style: textTheme.titleMedium?.copyWith(
                  color: titleTextWhiteColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                )).tr(),
          ],
        ),
      );

  buildTattoSize(BuildContext context, Size size, TextTheme textTheme) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.02),
          Align(
            alignment: Alignment.centerRight,
            child: Text("sending_request.tatto_size_title",
                    style: textTheme.titleMedium!.copyWith(
                        color: kWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.w700))
                .tr(),
          ),
          SizedBox(height: size.height * 0.015),
          StadiumToggleButton(
            children: const ["קטן", "בינוני", "גדול"],
            selectedIndex: selectedindex,
            onPressed: (index) {
              setState(() {
                index == 1
                    ? tattooSize = "M"
                    : index == 2
                        ? tattooSize = "B"
                        : tattooSize = "L";
                selectedindex = index;
              });
            },
          ),
        ],
      );

  buildStyleList(BuildContext context, Size size, TextTheme textTheme) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.04),
          Text('sending_request.style_list_title',
                  style: textTheme.titleMedium!.copyWith(
                      color: kWhite, fontSize: 16, fontWeight: FontWeight.w700))
              .tr(),
          SizedBox(height: size.height * 0.02),
          SizedBox(
            width: size.width,
            height: size.height * 0.05,
            child: ListView.builder(
                reverse: false,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                itemCount: listStyles.length,
                itemBuilder: (BuildContext context, int index) =>
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (!WebService.changeUserStyleList
                              .contains(listStyles[index])) {
                            if (WebService.changeUserStyleList.length < 3) {
                              setState(() {
                                isNotSureStyle = false;
                                WebService.changeUserStyleList
                                    .add(listStyles[index]);
                              });
                            } else {
                              displayMessageIcon(
                                  message:
                                      "אתה יכול לבחור רק עד 3 סגנונות.\n אנא בטל את הבחירה באחד לפני הוספת סגנון חדש.",
                                  color: errorColor,
                                  imageData: AppAssets.errorIcon);
                            }
                          } else {
                            setState(() {
                              WebService.changeUserStyleList
                                  .remove(listStyles[index]);
                            });
                          }
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: size.width * 0.02),
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.03),
                        decoration: BoxDecoration(
                            // color: WebService.changeUserStyleList
                            //         .contains(listStyles[index])
                            //     ? titleTextColor
                            //     : null,
                            gradient: WebService.changeUserStyleList
                                    .contains(listStyles[index])
                                ? appLinearGradient
                                : null,
                            border: Border.all(
                                color: WebService.changeUserStyleList
                                        .contains(listStyles[index])
                                    ? linearGradieantColor1
                                    : linearGradieantColor1),
                            borderRadius: BorderRadius.circular(50)),
                        alignment: Alignment.center,
                        child: Text(listStyles[index].name!,
                            style: textTheme.titleSmall!.copyWith(
                              color: WebService.changeUserStyleList
                                      .contains(listStyles[index])
                                  // ? bgBlack
                                  ? whiteTxtColor
                                  : titleTextColor,
                              fontWeight: FontWeight.w400,
                            )),
                      ),
                    )),
          ),
          SizedBox(height: size.height * 0.02),
          CustomCheckboxWidget(
              title: "sending_request.not_sure_checkbox",
              ischecked: isNotSureStyle,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    WebService.changeUserStyleList.clear();
                  }
                  isNotSureStyle = value!;
                });
              }),
        ],
      );

  buildImageUpload(BuildContext context, Size size, TextTheme textTheme) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.03),
          Text('sending_request.img_list_title',
                  style: textTheme.titleMedium!.copyWith(
                      color: kWhite, fontSize: 16, fontWeight: FontWeight.w700))
              .tr(),
          SizedBox(height: size.height * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              isImageSelected1
                  ? buildimgrounded(size, 1)
                  : InkWell(
                      onTap: () => _pickImagefromGallery(type: 1),
                      child: builddotted(size)),
              isImageSelected2
                  ? buildimgrounded(size, 2)
                  : InkWell(
                      onTap: () => _pickImagefromGallery(type: 2),
                      child: builddotted(size)),
              isImageSelected3
                  ? buildimgrounded(size, 3)
                  : InkWell(
                      onTap: () => _pickImagefromGallery(type: 3),
                      child: builddotted(size)),
            ],
          )
        ],
      );

  Stack buildimgrounded(Size size, type) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.all(5),
          height: size.width * 0.3,
          width: size.width * 0.25,
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
        InkWell(
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
      ],
    );
  }

  _pickImagefromGallery({type}) async {
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
        final pickedImage = await ImagePicker()
            .pickImage(source: ImageSource.gallery, imageQuality: 50);
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

    // try {
    //   PermissionStatus status = Platform.isAndroid
    //       ? await Permission.photos.status
    //       : await Permission.storage.status;
    //
    //
    //
    //   if (status.isGranted || status.isLimited) {
    //     final pickedImage = await ImagePicker()
    //         .pickImage(source: ImageSource.gallery, imageQuality: 50);
    //     if (pickedImage != null) {
    //       setState(() {
    //         if (type == 3) {
    //           imageFile3 = File(pickedImage.path);
    //           isImageSelected3 = true;
    //         } else if (type == 2) {
    //           imageFile2 = File(pickedImage.path);
    //           isImageSelected2 = true;
    //         } else {
    //           imageFile1 = File(pickedImage.path);
    //           isImageSelected1 = true;
    //         }
    //       });
    //     }
    //   } else if (status.isDenied) {
    //     status == Platform.isAndroid
    //         ? await Permission.photos.status
    //         : await Permission.storage.request();
    //   } else {
    //     await openAppSettings();
    //   }
    // } catch (e) {
    //   debugPrint(e.toString());
    // }
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

  buildLocationChoose(BuildContext context, Size size, TextTheme textTheme) =>
      Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.03),
              Text('מיקום הקעקוע',
                  style: textTheme.titleMedium!.copyWith(
                      color: kWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              SizedBox(height: size.height * 0.01),
              Screenshot(
                controller: imgListController.screenshotController,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (imgListController.isNotLoading.value == false)
                      Positioned(
                        left: 10,
                        top: size.width * 0.4,
                        child: OutlinedButton(onPressed: (){},
                          style: OutlinedButton.styleFrom(
                              shape: const StadiumBorder(),
                              foregroundColor: bgBlack,
                              backgroundColor: titleTextColor),
                          child: Text(imgListController.isbodyFrontPart.value
                              ? 'מקדימה'
                              : "מאחורה"),
                        ),
                      ),
                    SizedBox(
                      height: size.height * 0.51,
                      child: BodyPartSelectorTurnable(
                        mirrored: false,
                        islabelshow:
                            imgListController.isNotLoading.value ? true : false,
                        bodyParts: imgListController.bodyParts.value,
                        onSelectionUpdated: (p) => setState(() {
                          imgListController.bodyParts.value = p;
                        }),
                        labelData: const RotationStageLabelData(
                          front: 'מקדימה', //Front
                          // left: 'Left',
                          // right: 'Right',
                          back: "מאחורה", //'Back',
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ));

  buildTattoArtist(BuildContext context, Size size, TextTheme textTheme) =>
      Obx(() => businessDetailsController.artistsList.isEmpty
          ? const SizedBox()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.02),
                Text('sending_request.prefer_tatto_artist',
                        style: textTheme.titleMedium!.copyWith(
                            color: kWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.w700))
                    .tr(),
                SizedBox(height: size.height * 0.01),
                SizedBox(
                    height: size.height * 0.17,
                    child: ListView.builder(
                        itemCount: businessDetailsController.artistsList.length,
                        reverse: true,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () => setState(() {
                              isNotPreference = false;
                              selectedCreatorId ==
                                      businessDetailsController
                                          .artistsList[index].id!
                                  ? selectedCreatorId = ""
                                  : selectedCreatorId =
                                      businessDetailsController
                                          .artistsList[index].id!;
                            }),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  buildRequestForTattoImage(
                                      isclickable: selectedCreatorId ==
                                          businessDetailsController
                                              .artistsList[index].id!,
                                      height: size.width * 0.2,
                                      width: size.width * 0.2,
                                      url: WebService.resolveProfileImage(
                                          businessDetailsController
                                              .artistsList[index]
                                              .profileImage),
                                      radius: 50),
                                  SizedBox(height: size.height * 0.02),
                                  Text(
                                      businessDetailsController
                                          .artistsList[index].name!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.titleMedium!.copyWith(
                                        color: titleTextWhiteColor,
                                        fontWeight: FontWeight.w400,
                                      )),
                                ],
                              ),
                            ),
                          );
                        })),
                CustomCheckboxWidget(
                    title: "sending_request.no_particular_checkbox",
                    ischecked: isNotPreference,
                    onChanged: (value) {
                      setState(() {
                        selectedCreatorId = "";
                        isNotPreference = value!;
                      });
                    }),
              ],
            ));

  buildAdditionalNotes(BuildContext context, Size size, TextTheme textTheme) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.03),
          Text('sending_request.additional_notes',
                  style: textTheme.titleMedium!.copyWith(
                      color: kWhite, fontSize: 16, fontWeight: FontWeight.w700))
              .tr(),
          SizedBox(height: size.height * 0.02),
          TextFormField(
            autofocus: false,
            cursorColor: kWhite,
            style: const TextStyle(color: kWhite),
            controller: imgListController.aboutController,
            minLines: 5,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            inputFormatters: [
              LengthLimitingTextInputFormatter(400),
            ],
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            decoration: InputDecoration(
              hintText: tr('sending_request.additional_notes_hints'),
              hintMaxLines: 2,
              hintStyle: const TextStyle(
                  color: Color(0xFF6B676F),
                  fontSize: 16,
                  fontWeight: FontWeight.w400),
              contentPadding: const EdgeInsets.all(16),
              filled: true,
              fillColor: socialoginbtn,
              // enabledBorder: const UnderlineInputBorder(
              //     borderSide: BorderSide(color: defaultBlack)),
              // focusedBorder: const UnderlineInputBorder(
              //     borderSide: BorderSide(color: defaultBlack)),
              // errorBorder: const UnderlineInputBorder(
              //     borderSide: BorderSide(color: errorColor)),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(8), // Set corner radius here
                borderSide: const BorderSide(color: defaultBlack),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(8), // Set corner radius here
                borderSide: const BorderSide(color: defaultBlack),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(8), // Set corner radius here
                borderSide: const BorderSide(color: errorColor),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(8), // Set corner radius here
                borderSide: const BorderSide(color: errorColor),
              ),
            ),
          ),
          SizedBox(height: size.height * 0.04),
        ],
      );

  InkWell buildBtnSubmit({required BuildContext context, required Size size}) =>
      InkWell(
        onTap: () async {
          bool isConnected = await WebService.checkConnectionShowMsg();
          if (!isConnected) return;
          if (WebService.changeUserStyleList.isEmpty &&
              isNotSureStyle == false) {
            displayMessageIcon(
                message: "alerts.choose_tattoo_style",
                snackposition: SnackPosition.BOTTOM,
                color: errorColor,
                imageData: AppAssets.errorIcon);
            //choose style
            return;
          } else if (imgListController.bodyParts.value ==
              imgListController.blankBodyParts.value) {
            displayMessageIcon(
                message: "alerts.please_select_part",
                snackposition: SnackPosition.BOTTOM,
                color: errorColor,
                imageData: AppAssets.errorIcon);
            return;
          } else if (businessDetailsController.artistsList.isNotEmpty &&
              selectedCreatorId == "" &&
              isNotPreference == false) {
            displayMessageIcon(
                message: "alerts.no_artist_found",
                snackposition: SnackPosition.BOTTOM,
                color: errorColor,
                imageData: AppAssets.errorIcon);
            return;
          } else {
            setState(() {
              if (!mounted) return;
              imgListController.isNotLoading = false.obs;
              isvalidate = true;
              isLoading = true;

              animationController.forward();
              animationController.repeat();
            });
            await _addImagesList();
            List<RequestImages> imgList = [];
            if (imgListController.imgList.isNotEmpty) {
              // await FireBaseApi.userRequestImagesUpload(
              //     imgList: imgListController.imgList.value,
              //     imgNameList: imgList);
              imgListController.WithcaptureImage(
                      bid: businessDetailsController.id.value,
                      screenshotController:
                          imgListController.screenshotController,
                      selectedCreatorId: selectedCreatorId,
                      tattooSize: tattooSize,
                      imgListDetails: imgList)
                  .then((value) {
                if (!mounted) return;
                setState(() {
                  isvalidate = true;
                  isLoading = false;
                  animationController.stop();
                });
              });
            } else {
              imgListController
                  .captureImage(
                      bid: businessDetailsController.id.value,
                      screenshotController:
                          imgListController.screenshotController,
                      selectedCreatorId: selectedCreatorId,
                      tattooSize: tattooSize,
                      imgListDetails: imgList)
                  .then((value) {
                setState(() {
                  if (!mounted) return;
                  isvalidate = true;
                  isLoading = false;
                  animationController.stop();
                });
              });
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
                colors: ((WebService.changeUserStyleList.isNotEmpty ||
                            isNotSureStyle == true &&
                                imgListController.bodyParts.value !=
                                    imgListController.blankBodyParts.value) ||
                        (businessDetailsController.artistsList.isNotEmpty &&
                                selectedCreatorId != "" ||
                            isNotPreference == true))
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
            child: isLoading!
                ? Center(
                    child: RotationTransition(
                        turns: base, child: Image.asset(AppAssets.loadingIcon)),
                  )
                : Text(
                    "sending_request.sending_request_btn",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: ((WebService.changeUserStyleList.isNotEmpty ||
                                    isNotSureStyle == true &&
                                        imgListController.bodyParts.value !=
                                            imgListController
                                                .blankBodyParts.value) ||
                                (businessDetailsController
                                            .artistsList.isNotEmpty &&
                                        selectedCreatorId != "" ||
                                    isNotPreference == true))
                            ? kWhite
                            : defaultGrey,
                        fontWeight: FontWeight.w700),
                  ).tr()),
      );

  Future<void> _addImagesList() async {
    imgListController.imgList.clear();
    List<File> imageFiles = [imageFile1, imageFile2, imageFile3];

    for (var imageFile in imageFiles) {
      if (await imageFile?.exists() == true) {
        int length = await imageFile.length();
        if (length > 0) {
          imgListController.imgList
              .add(AddBodyPartsImages(source: "file", path: imageFile.path));
        }
      }
    }
    return;
  }

  @override
  void dispose() {
    animationController.stop();
    animationController.dispose();
    isvalidate = false;
    isLoading = false;

    super.dispose();
  }
}
