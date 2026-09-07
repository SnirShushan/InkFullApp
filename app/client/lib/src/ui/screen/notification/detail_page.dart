import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/notificationController.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/ui/screen/notification/models/tattooRequest.dart';
import 'package:ink/src/ui/screen/notification/screen_images.dart';
import 'package:ink/src/ui/widgets/button/app_button.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/utils.dart';
import 'package:ink/src/utils/webService.dart';

class RequestDetailPage extends StatefulWidget {
  final TattooRequest tattooRequest;
  final NotificationController controller;
  final bool readRequest;

  const RequestDetailPage(
      {Key? key,
      required this.tattooRequest,
      required this.controller,
      required this.readRequest})
      : super(key: key);

  @override
  State<RequestDetailPage> createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  bool isFront = true;
  List<String> imageList = [];

  var isBusiness;

  // var selectedArtist;
  AppUser? currentUser;

  @override
  void initState() {
    super.initState();
    imageList.clear();

    getData();
  }

  Future<void> getData() async {
    currentUser = await WebService.getCurrentUser();
    isBusiness = await WebService.getIsBusiness();

    if (widget.tattooRequest.image1Name != null) {
      if (widget.tattooRequest.image1Name!.isNotEmpty) {
        imageList.add(widget.tattooRequest.image1Name!);
      }
    }
    if (widget.tattooRequest.image2Name != null) {
      if (widget.tattooRequest.image2Name!.isNotEmpty) {
        imageList.add(widget.tattooRequest.image2Name!);
      }
    }
    if (widget.tattooRequest.image3Name != null) {
      if (widget.tattooRequest.image3Name!.isNotEmpty) {
        imageList.add(widget.tattooRequest.image3Name!);
      }
    }

    // selectedArtist = currentUser?.profile?.userType.toString() == "2"
    //     ? widget.tattooRequest.senderRow
    //     : widget.tattooRequest.businessRow;
    setState(() {});
  }

  // buildWhatsappMsg(String type) {
  //   if (type == "1") {
  //     return const Text("לשיחת ווטסאפ עם סטודיו");
  //   } else if (type == "2") {
  //     return const Text("לשיחת ווטסאפ עם המקעקע");
  //   } else {
  //     return const Text("לשיחת ווטסאפ עם הלקוח");
  //   }
  // }

  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: true,
      onPopInvoked: (bool didPop) async {
        if (widget.readRequest == true) {
          await widget.controller.clearRequestData();
          await widget.controller.fetchRequests();
        }
      },
      child: Scaffold(
          backgroundColor: scaffoldBg,
          // appBar: buildappBarwithback(size: size, title: "פרטי הפנייה"),
          appBar: AppBar(
            elevation: 0,
            // backgroundColor: Colors.black,
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                    padding: EdgeInsets.fromLTRB(
                        MediaQuery.sizeOf(context).width * 0.05,
                        MediaQuery.sizeOf(context).width * 0.1,
                        MediaQuery.sizeOf(context).width * 0.05,
                        MediaQuery.sizeOf(context).width * 0.05),
                    child: InkWell(
                      onTap: () async {
                        if (widget.readRequest == true) {
                          await widget.controller.clearRequestData();
                          await widget.controller.fetchRequests();
                        }
                        Get.back();
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            AppAssets.backarrowIcon,
                            color: titleTextColor,
                            height: 20,
                            width: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "פנייה חדשה",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                    color: titleTextColor,
                                    fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ))
              ],
            ),
          ),
          bottomSheet: isBusiness && widget.tattooRequest.isContactRequest!
              ? buildWhatsappButton(context)
              : const SizedBox.shrink(),
          body: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.04,
                ),
                // //appbar
                // Utils.buildAppBar(title: "פרטי הפנייה"),
                //request details
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: ColoredBox(
                      color: bodyBg,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          //contact header
                          buildContactDetails(
                              size: size,
                              isNotBusiness:
                                  currentUser?.profile?.userType != "1"),

                          // Align(
                          //   alignment: Alignment.centerRight,
                          //   child: Padding(
                          //     padding: EdgeInsets.symmetric(
                          //         horizontal: size.width * 0.07),
                          //     child: Column(
                          //       crossAxisAlignment: CrossAxisAlignment.start,
                          //       mainAxisSize: MainAxisSize.min,
                          //       children: [
                          //         Utils.verticalSpaceContext(
                          //             space: 0.03, context: context),
                          //         buildLabel(title: "purchases.phone"),
                          //         Utils.verticalSpaceContext(
                          //             space: 0.01, context: context),
                          //         IntrinsicWidth(
                          //           child: Column(
                          //             children: [
                          //               Text(
                          //                 currentUser?.profile?.userType != "1"
                          //                     ? formatPhoneNumber(
                          //                         widget.tattooRequest.phone!)
                          //                     : formatPhoneNumber(widget
                          //                         .tattooRequest
                          //                         .businessRow!
                          //                         .phone!),
                          //                 style: Theme.of(context)
                          //                     .textTheme
                          //                     .titleMedium!
                          //                     .copyWith(
                          //                       color: dividerGray,
                          //                       fontSize: 16,
                          //                       fontWeight: FontWeight.w400,
                          //                     ),
                          //               ).tr(),
                          //               const SizedBox(height: 4),
                          //               Container(
                          //                   height: 1, color: titleTextColor),
                          //             ],
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),

                          //details
                          ListView(
                              controller: scrollController,
                              padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.07),
                              shrinkWrap: true,
                              // padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
                              children: [
                                if (widget.tattooRequest.isContactRequest!)
                                  Utils.verticalSpaceContext(
                                      space: 0.03, context: context),
                                if (widget.tattooRequest.isContactRequest!)
                                  buildContactBody(),
                                if (!widget.tattooRequest.isContactRequest!)
                                  ...buildDetailsBody(size, context)
                              ]),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isBusiness && !widget.tattooRequest.isContactRequest!)
                  Utils.verticalSpaceContext(space: 0.012, context: context),

                if (isBusiness && !widget.tattooRequest.isContactRequest!)
                  buildWhatsappButton(context),

                Utils.verticalSpaceContext(space: 0.015, context: context),
              ],
            ),
          )),
    );
  }

  Widget buildWhatsappButton(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      GradientButton(
          gradient: appLinearGradient,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(AppAssets.icWhatsapp),
              Text(
                  widget.tattooRequest.isContactRequest!
                      ? " שליחת הודעה בווטסאפ"
                      : " שליחת הצעה בווטסאפ",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: const Color(0xFFEAE7EE),
                      fontWeight: FontWeight.w500)),
            ],
          ),
          onPressed: () {
            bool isNotBusiness = currentUser!.profile?.userType != "1";
            String phone = isNotBusiness
                ? widget.tattooRequest.phone!
                : widget.tattooRequest.businessRow!.phone!;
            String cntCode = isNotBusiness
                ? widget.tattooRequest.cntCode!
                : widget.tattooRequest.businessRow!.cntCode!;

            if (phone != null) {
              var whatsapp = "";
              whatsapp = "+$cntCode$phone";

              String textmsg1 =
                  "\nהיי, ${isNotBusiness ? widget.tattooRequest.name! : widget.tattooRequest.businessRow!.name!} \n";
              String textmsg2 =
                  "קיבלתי את הפניה שהשארת דרך אפליקציית ״אינק״.\n";

              String textmsg3 = "השלב הבא הוא תיאום פגישה, מתי תרצה להגיע?";

              String textMessage = "$textmsg1$textmsg2$textmsg3";
              if (Platform.isAndroid) {
                var whatsappAndroid =
                    "whatsapp://send?phone=$whatsapp&text=$textMessage";
                WebService.openUrl(whatsappAndroid);
              } else {
                var whatsappIOS =
                    "https://wa.me/$whatsapp/?text=${Uri.encodeFull(textMessage)}";
                WebService.openUrl(whatsappIOS);
              }
            } else {
              displayMessageIcon(
                  message: "מספר טלפון לא מסופק",
                  snackposition: SnackPosition.BOTTOM,
                  color: errorColor,
                  imageData: AppAssets.errorIcon);
              // displayMessage(
              //     "מספר טלפון לא מסופק", Colors.red); //phone number not provided
            }
          }),
      if(Platform.isAndroid) SizedBox(
        height: MediaQuery.of(context).size.height * 0.05,
      ),
    ]);
  }

  //contact details
  buildContactDetails({required Size size, required bool isNotBusiness}) =>
      Padding(
        padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.07, vertical: size.height * 0.02),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                isNotBusiness
                    ? widget.tattooRequest.name!
                    : widget.tattooRequest.businessRow!.name!,
                textAlign: TextAlign.end,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: kWhite, overflow: TextOverflow.ellipsis)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(AppAssets.calenderIcon, color: lightGrayColor),
                const SizedBox(width: 6),
                Text(
                    DateFormat('dd.MM.y').format(
                        DateTime.parse(widget.tattooRequest.dateAdded!)),
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: lightGrayColor,
                          fontWeight: FontWeight.w400,
                        )),
              ],
            )
          ],
        ),
      );

  buildContactBody() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.15,
            child: Text("request_detail.txt_request_consultation",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: dividerGray, fontWeight: FontWeight.w400))
                .tr()),
      );

  List<Widget> buildDetailsBody(size, BuildContext context) => [
        Utils.verticalSpaceContext(space: 0.03, context: context),
        buildLabel(title: "request_detail.txt_size"),
        Utils.verticalSpaceContext(space: 0.01, context: context),
        buildText(
            text: WebService.setTattooSize(widget.tattooRequest.tattooSize!)),

        Utils.verticalSpaceContext(space: 0.03, context: context),

        //style
        buildLabel(title: "request_detail.txt_style"),
        Utils.verticalSpaceContext(space: 0.01, context: context),
        buildText(
            text: Utils.isDataEmpty(widget.tattooRequest.styles)
                ? "request_detail.txt_no_style_selected"
                : widget.tattooRequest.styles!.toString()),

        Utils.verticalSpaceContext(space: 0.03, context: context),

        //sample photos
        if (widget.tattooRequest.requestImages != null)
          buildLabel(title: "request_detail.txt_sample_photos"),

        if (widget.tattooRequest.requestImages != null)
          Utils.verticalSpaceContext(space: 0.01, context: context),
        if (widget.tattooRequest.requestImages != null)
          buildSampleImages(size: size),

        Utils.verticalSpaceContext(space: 0.03, context: context),

        //location
        buildLabel(title: "request_detail.txt_location"),

        buildLocationView(size: size),

        Utils.verticalSpaceContext(space: 0.03, context: context),
        if (widget.tattooRequest.artistRow != null)
          buildLabel(title: "request_detail.txt_tatto_artist"),

        if (widget.tattooRequest.artistRow != null)
          Utils.verticalSpaceContext(space: 0.01, context: context),
        if (widget.tattooRequest.artistRow != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Utils.verticalSpaceContext(space: 0.01, context: context),
              widget.tattooRequest.artistRow!.profileImage!.toString() == ""
                  ? Container(
                      height: size.width * 0.15,
                      width: size.width * 0.15,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image:
                                      AssetImage(AppAssets.galleryPlaceholder),
                                  fit: BoxFit.cover)),
                        ),
                      ),
                    )
                  : Container(
                      height: size.width * 0.15,
                      width: size.width * 0.15,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: CachedNetworkImage(
                          alignment: Alignment.center,
                          imageUrl: WebService.resolveProfileImage(widget
                              .tattooRequest.artistRow?.profileImage),
                          fit: BoxFit.cover,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => SizedBox(
                            height: size.width * 0.15,
                            width: size.width * 0.15,
                            child: Center(
                                child: CircularProgressIndicator(
                                    value: downloadProgress.progress)),
                          ),
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: AssetImage(
                                        AppAssets.galleryPlaceholder),
                                    fit: BoxFit.cover)),
                          ),
                        ),
                      ),
                    ),
              Utils.verticalSpaceContext(space: 0.01, context: context),
              buildText(text: widget.tattooRequest.artistRow!.name!),
            ],
          ),

        Utils.verticalSpaceContext(space: 0.03, context: context),

        //notes and additional details
        if (!Utils.isDataEmpty(widget.tattooRequest.description))
          buildLabel(title: "request_detail.txt_notes"),
        if (!Utils.isDataEmpty(widget.tattooRequest.description))
          Utils.verticalSpaceContext(space: 0.01, context: context),
        if (!Utils.isDataEmpty(widget.tattooRequest.description))
          buildText(text: widget.tattooRequest.description.toString()),

        Utils.verticalSpaceContext(space: 0.03, context: context),
      ];

  //label
  buildLabel({title}) => Text(title,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: kWhite, fontWeight: FontWeight.bold))
      .tr();

  //label value
  buildText({text}) => Text(text,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: dividerGray, fontWeight: FontWeight.w400))
      .tr();

  //sample images
  buildSampleImages({required Size size}) => Row(
      children: widget.tattooRequest.requestImages!
          .map((image) => Padding(
              padding: EdgeInsets.all(size.width * 0.015),
              child: Stack(children: [
                //image
                Utils.buildCachedImageRounded(
                    imgUrl: image.imageUrl!,
                    height: size.width * 0.22,
                    width: size.width * 0.22),
                //btn view full screen image
                Positioned(
                    bottom: 8,
                    right: 4,
                    child: InkWell(
                      onTap: () => Get.to(() => ScreenImages(
                          imgList: widget.tattooRequest.requestImages!)),
                      child: SvgPicture.asset(AppAssets.icViewFullImage),
                    )),
              ])))
          .toList());

  buildLocationView({required Size size}) => SizedBox(
      height: size.height * 0.4,
      child: Container(
          height: size.height * 0.4,
          width: size.width,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(0.0)),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(0.0),
              child: CachedNetworkImage(
                  alignment: Alignment.center,
                  imageUrl: WebService.resolveImageUrl(
                      widget.tattooRequest.frontDataImage?.toString(),
                      base: WebService.bodyImgUrl),
                  fit: BoxFit.contain,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      SizedBox(
                        height: size.width * 0.15,
                        width: size.width * 0.15,
                        child: Center(
                            child: CircularProgressIndicator(
                                value: downloadProgress.progress)),
                      ),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.photo, size: 200)))));

  String formatPhoneNumber(String phoneNumber) {
    if (!phoneNumber.isNotEmpty || phoneNumber.length != 10) {
      return '';
    }

    return '${phoneNumber.substring(0, 3)}-${phoneNumber.substring(3, 6)}-${phoneNumber.substring(6)}';
  }
}
