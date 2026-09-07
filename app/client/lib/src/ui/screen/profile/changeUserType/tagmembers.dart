import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/data/model/ArtistModel.dart';
import 'package:ink/src/ui/screen/profile/changeUserType/controller/businessList_controller.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/utils.dart';

import '../../../../utils/colors.dart';
import '../../../../utils/webService.dart';
import '../../../widgets/unfocus_widget.dart';

class TagMembers extends StatefulWidget {
  TagMembers({Key? key}) : super(key: key);

  @override
  State<TagMembers> createState() => _TagMembersState();
}

class _TagMembersState extends State<TagMembers> {
  final scrollController = ScrollController();
  final BusinessListController artistListController = Get.find();

  getArtist() async => await artistListController.getArtists();

  bool isManageEnabled = false;

  @override
  void initState() {
    WebService.memberList.clear();
    // widget.changeUserTypeController ??= Get.put(ChangeUserTypeController());
    getArtist();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return UnFocusWidget(
        // child: WillPopScope(
        //     onWillPop: () => exitRegistrationDialog(size, context),
        child: Scaffold(
            backgroundColor: bgBlack,
            appBar: buildAppBar(size),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
              child: SingleChildScrollView(
                child: Obx(() => Column(
                      children: [
                        const Text(
                          "user_to_business.artist_selection_title",
                          style: TextStyle(
                            color: titleTextColor,
                            fontSize: 24,
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.w700,
                          ),
                        ).tr(),
                        SizedBox(height: size.height * 0.01),
                        const Text(
                          "user_to_business.artist_selection_subtitle",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: titleTextWhiteColor,
                            fontSize: 18,
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.w400,
                          ),
                        ).tr(),
                        SizedBox(height: size.height * 0.03),
                        buildSearchbar(
                            size: size, isManageEnable: isManageEnabled),
                        isManageEnabled == false
                            ? buildArtistSelection(size, context)
                            : Align(
                                alignment: Alignment.centerRight,
                                child: Utils.buildSubTitle(
                                    title:
                                        "תייגתם ${artistListController.selectedList.length} חברי צוות:",
                                    color: defaultWhite)),
                        SizedBox(
                          height: size.height * 0.02,
                        ),
                        isManageEnabled == false
                            ? buildArtistList(size, context)
                            : buildManageArtist(size, context),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.03,
                              vertical: size.height * 0.03),
                          child: Utils.buildBtnSubmit(
                              context: context,
                              size: size,
                              title: isManageEnabled
                                  ? "סיימתי לערוך"
                                  : "סיימתי לתייג",
                              onTap: () {
                                if (isManageEnabled) {
                                  if (artistListController
                                          .searchController.text !=
                                      "") {
                                    artistListController
                                        .isselectedClickable.value = false;
                                    artistListController
                                            .searchController.text ==
                                        "";
                                    artistListController.searchArtists();
                                  }
                                  if (artistListController
                                      .isselectedClickable.value) {
                                    displayMessageIcon(
                                        snackposition: SnackPosition.BOTTOM,
                                        message: "השינויים נשמרו בהצלחה",
                                        color: successGreen,
                                        imageData:
                                            AppAssets.correct_transparentIcon);
                                  } else {
                                    displayMessageIcon(
                                        snackposition: SnackPosition.BOTTOM,
                                        message: "לא בוצעו שינויים",
                                        color: successGreen,
                                        imageData:
                                            AppAssets.correct_transparentIcon);
                                  }
                                  setState(() => isManageEnabled = false);
                                } else {
                                  artistListController
                                      .isselectedClickable.value = false;
                                  artistListController.searchController.text ==
                                      "";
                                  Navigator.of(context).pop();
                                  artistListController.getArtists();
                                  if (artistListController
                                      .isselectedClickable.value) {
                                    displayMessageIcon(
                                        snackposition: SnackPosition.BOTTOM,
                                        message: "השינויים נשמרו בהצלחה",
                                        color: successGreen,
                                        imageData:
                                            AppAssets.correct_transparentIcon);
                                  } else {
                                    displayMessageIcon(
                                        snackposition: SnackPosition.BOTTOM,
                                        message: "לא בוצעו שינויים",
                                        color: successGreen,
                                        imageData:
                                            AppAssets.correct_transparentIcon);
                                  }
                                }
                              }),
                        ),
                        SizedBox(height: size.height * 0.02),
                      ],
                    )),
              ),
            )));
  }

  buildSearchbar({required Size size, required bool isManageEnable}) =>
      SizedBox(
        height: size.height * 0.1,
        child: TextFormField(
            autofocus: false,
            controller: artistListController.searchController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.search,
            style: const TextStyle(color: titleTextWhiteColor),
            onTapOutside: (event) =>
                FocusManager.instance.primaryFocus?.unfocus(),
            onEditingComplete: () {
              if (isManageEnabled) {
                artistListController.searchArtists();
              } else {
                artistListController.getArtists();
              }
            },
            onFieldSubmitted: (txt) {
              FocusScope.of(context).unfocus();
              if (isManageEnabled) {
                artistListController.searchArtists();
              } else {
                artistListController.getArtists();
              }
            },
            onChanged: (txt) {
              if (isManageEnabled) {
                artistListController.searchArtists();
              } else {
                artistListController.getArtists();
              }
            },
            decoration: InputDecoration(
                hintStyle: const TextStyle(color: Color(0xFF6B676F)),
                hintText: isManageEnabled
                    ? "חפשו את חברי הצוות שלכם"
                    : 'חפשו את חברי הצוות שלכם',
                contentPadding: const EdgeInsets.all(8),
                filled: true,
                fillColor: socialoginbtn,
                suffixIcon: InkWell(
                    child: const Icon(Icons.clear, color: titleTextWhiteColor),
                    onTap: () {
                      artistListController.searchController.clear();
                      if (isManageEnabled) {
                        artistListController.searchArtists();
                      } else {
                        artistListController.getArtists();
                      }
                    }),
                focusedBorder: OutlineInputBorder(
                    // width: 0.0 produces a thin "hairline" border
                    borderSide:
                        const BorderSide(color: textEditingColor, width: 1.0),
                    borderRadius: BorderRadius.circular(8)),
                enabledBorder: OutlineInputBorder(
                    // width: 0.0 produces a thin "hairline" border
                    borderSide:
                        const BorderSide(color: textEditingColor, width: 1.0),
                    borderRadius: BorderRadius.circular(8)),
                prefixIcon: IconButton(
                    icon: const Icon(Icons.search, color: titleTextWhiteColor),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      // artistListController.getArtists();

                      if (isManageEnabled) {
                        artistListController.searchArtists();
                      } else {
                        artistListController.getArtists();
                      }
                    }),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)))),
      );

  //artist no found
  buildNoFoundMsg(size) => SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: size.height * 0.02),
            Utils.buildTitle(
                title: "user_to_business.something_is_missing",
                color: titleTextWhiteColor),
            SizedBox(height: size.height * 0.01),
            Utils.buildSubTitle(
                title: "user_to_business.something_is_missing_subtitle",
                color: titleTextWhiteColor),
            SizedBox(height: size.height * 0.04),
            Image.asset(AppAssets.notFound, width: size.width * 0.6)
          ],
        ),
      );

  buildNoSearchMsg(size, String search_txt) => SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: size.height * 0.02),
            Text(
              ' לא מצאנו מקעקע בשם "$search_txt"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF807C84),
                fontSize: 20,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: size.height * 0.01),
            const Text(
              'כדאי לוודא שהקלדתם נכון את השם ושהמקעקע רשום לאינק ובעל חשבון משתמש.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFE0DAE8),
                fontSize: 16,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: size.height * 0.04),
            Image.asset(AppAssets.nosearchFound, width: size.width * 0.6)
          ],
        ),
      );

  buildAppBar(Size size) => AppBar(
      elevation: 0,
      backgroundColor: bgBlack,
      automaticallyImplyLeading: false,
      leading: Padding(
          padding: EdgeInsets.all(size.width * 0.01),
          child: Center(
              child: isManageEnabled == false
                  ? InkWell(
                      onTap: () {
                        artistListController.isselectedClickable.value = false;
                        Navigator.of(context).pop();
                      },
                      child: const CloseButton(color: kWhite))
                  : InkWell(
                      onTap: () {
                        if (artistListController.searchController != "") {
                          artistListController.searchController.clear();

                          artistListController.searchArtists();
                        }
                        if (artistListController.isselectedClickable.value) {
                          displayMessageIcon(
                              snackposition: SnackPosition.BOTTOM,
                              message: "השינויים נשמרו בהצלחה",
                              color: successGreen,
                              imageData: AppAssets.correct_transparentIcon);
                        } else {
                          displayMessageIcon(
                              snackposition: SnackPosition.BOTTOM,
                              message: "לא בוצעו שינויים",
                              color: successGreen,
                              imageData: AppAssets.correct_transparentIcon);
                        }
                        setState(() {
                          isManageEnabled = false;
                        });
                      },
                      child: SvgPicture.asset(
                        AppAssets.backarrowIcon,
                        color: titleTextColor,
                      )))),
      centerTitle: true,
      toolbarHeight: size.height * 0.1,
      title: const Text(""));

  //manage artist
  buildArtistSelection(Size size, context) => artistListController
          .selectedList.isEmpty
      ? const SizedBox()
      : Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      "הצוות שלכם:",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: titleTextWhiteColor,
                          fontWeight: FontWeight.w400),
                    ),
                    SizedBox(width: size.width * 0.02),
                    SizedBox(
                      width: size.width * 0.48,
                      height: size.height * 0.05,
                      child: Stack(
                          children: List.generate(
                              artistListController.selectedList.length > 5
                                  ? 5
                                  : artistListController.selectedList.length,
                              (index) {
                        return Positioned(
                            right: index * 20,
                            child: Container(
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50)),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                        backgroundImage: AssetImage(
                                            AppAssets.userPlaceHolder),
                                        foregroundImage: NetworkImage(
                                            WebService.resolveProfileImage(
                                                artistListController
                                                    .selectedList[index]
                                                    .profileImage)),
                                        radius: 15),
                                    if (index == 4)
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: ShapeDecoration(
                                          color: const Color(0xFF2B272F),
                                          shape: RoundedRectangleBorder(
                                            side: const BorderSide(
                                                width: 1,
                                                color: Color(0xFFDFDCE3)),
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          shadows: const [
                                            BoxShadow(
                                              color: Color(0x4C16121A),
                                              blurRadius: 8,
                                              offset: Offset(2, 2),
                                              spreadRadius: 2,
                                            )
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              '+${artistListController.selectedList.length > 5 ? (artistListController.selectedList.length - 5) : artistListController.selectedList.length}',
                                              style: const TextStyle(
                                                color: Color(0xFFDFDCE3),
                                                fontSize: 14,
                                                fontFamily: 'Arimo',
                                                fontWeight: FontWeight.w500,
                                                height: 0.10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                  ],
                                )));
                      })),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    setState(() => isManageEnabled = !isManageEnabled);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AppAssets.editIcon,
                        color: titleTextColor,
                      ),
                      const SizedBox(width: 8),
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
          ],
        );

  //build artist list
  buildArtistList(Size size, BuildContext context) => SizedBox(
      height: size.height * 0.45,
      child: artistListController.isLoading.value
          ? Utils.showProgress()
          : artistListController.artistList.isEmpty &&
                  artistListController.searchController.text.length > 1
              ? buildNoSearchMsg(
                  size, artistListController.searchController.text)
              : artistListController.artistList.isEmpty
                  ? buildNoFoundMsg(size)
                  : ListView(
        children: [
          ListView.builder(
              shrinkWrap: true,
              controller: scrollController,
              itemCount: artistListController.selectedList.length,
              itemBuilder: (BuildContext context, int index) {
                var data =
                artistListController.selectedList[index];
                // if (index < artistListController.artistList.length) {

                // final Artist artist =
                //     artistListController.artistList[index];
                //
                // final bool hasMatch = artistListController
                //     .selectedList
                //     .any((element) => element.id == artist.id);

                return ListTile(
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.02,
                      vertical: size.height * 0.001),
                  // contentPadding: EdgeInsets.zero,
                  // onTap: () {
                  //   if (artistListController.selectedList
                  //       .contains(artist)) {
                  //     displayMessage(
                  //         "already added", errorColor);
                  //     // artistListController.selectArtist(artist);
                  //   }
                  //   // print(artistListController
                  //   //     .selectedList.isEmpty);
                  //   // print(artist);
                  //
                  //   if (!artistListController.selectedList
                  //       .contains(artist)) {
                  //     artistListController.selectArtist(artist);
                  //   }
                  //   setState(() {});
                  // },
                  onTap: () {
                    artistListController
                        .isselectedClickable.value = true;
                    artistListController.selectArtist(data);
                  },
                  selected: true,
                  selectedTileColor: cardBgColor,

                  trailing: CloseButton(
                      color: kWhite,
                      onPressed: () => artistListController
                          .selectArtist(data)),
                  leading: CircleAvatar(
                      radius: 25,
                      backgroundImage:
                      AssetImage(AppAssets.userPlaceHolder),
                      foregroundImage: NetworkImage(
                          WebService.resolveProfileImage(data.profileImage))),
                  title: Text(data.name!,
                      style: const TextStyle(
                        color: Color(0xFFDFDCE3),
                        fontSize: 16,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w700,
                      )),
                  subtitle: Text(data.address!,
                      style: const TextStyle(
                        color: Color(0xFF807C84),
                        fontSize: 16,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w400,
                      )),
                );

                //No List Show.

                // return hasMatch
                //     ? SizedBox()
                //     : Padding(
                //         padding: EdgeInsets.symmetric(
                //             vertical: size.height * 0.01),
                //         child: ListTile(
                //           contentPadding: EdgeInsets.zero,
                //           // shape: artistListController.selectedList.contains(artist)? OutlineInputBorder(borderRadius:BorderRadius.circular(10.0)): null,
                //           // tileColor: artistListController.selectedList.contains(artist)? appPrimaryColor: bgBlack,
                //           onTap: () {
                //             if (artistListController.selectedList
                //                 .contains(artist)) {
                //               displayMessage(
                //                   "already added", errorColor);
                //               // artistListController.selectArtist(artist);
                //             }
                //             // print(artistListController
                //             //     .selectedList.isEmpty);
                //             // print(artist);
                //
                //             if (!artistListController.selectedList
                //                 .contains(artist)) {
                //               artistListController.selectArtist(artist);
                //             }
                //             setState(() {});
                //           },
                //           leading: CircleAvatar(
                //               radius: 25,
                //               backgroundImage:
                //                   AssetImage(AppAssets.userPlaceHolder),
                //               foregroundImage: NetworkImage(
                //                   WebService.profileImageUrl +
                //                       artistListController
                //                           .artistList[index]
                //                           .profileImage!)),
                //           title: Text(
                //               artistListController
                //                   .artistList[index].name!,
                //               style: const TextStyle(
                //                 color: Color(0xFFDFDCE3),
                //                 fontSize: 16,
                //                 fontFamily: 'Arimo',
                //                 fontWeight: FontWeight.w700,
                //               )),
                //           subtitle: Text(
                //               artistListController
                //                   .artistList[index].address!,
                //               style: const TextStyle(
                //                 color: Color(0xFF807C84),
                //                 fontSize: 16,
                //                 fontFamily: 'Arimo',
                //                 fontWeight: FontWeight.w400,
                //               )),
                //         ));
              }),
          ListView.builder(
              shrinkWrap: true,
              controller: scrollController,
              itemCount: artistListController.artistList.length,
              itemBuilder: (BuildContext context, int index) {
                // if (index < artistListController.artistList.length) {

                final Artist artist =
                artistListController.artistList[index];

                final bool hasMatch = artistListController
                    .selectedList
                    .any((element) => element.id == artist.id);

                return hasMatch
                    ? const SizedBox.shrink()
                    : ListTile(
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.02,
                      vertical: size.height * 0.001),
                  // contentPadding: EdgeInsets.zero,
                  // onTap: () {
                  //   if (artistListController.selectedList
                  //       .contains(artist)) {
                  //     displayMessage(
                  //         "already added", errorColor);
                  //     // artistListController.selectArtist(artist);
                  //   }
                  //   // print(artistListController
                  //   //     .selectedList.isEmpty);
                  //   // print(artist);
                  //
                  //   if (!artistListController.selectedList
                  //       .contains(artist)) {
                  //     artistListController.selectArtist(artist);
                  //   }
                  //   setState(() {});
                  // },
                  onTap: () {
                    artistListController
                        .isselectedClickable.value = true;
                    artistListController
                        .selectArtist(artist);
                  },
                  selected: false,
                  selectedTileColor: cardBgColor,
                  leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage(
                          AppAssets.userPlaceHolder),
                      foregroundImage: NetworkImage(
                          WebService.resolveProfileImage(artistListController
                              .artistList[index].profileImage))),
                  title: Text(
                      artistListController
                          .artistList[index].name!,
                      style: const TextStyle(
                        color: Color(0xFFDFDCE3),
                        fontSize: 16,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w700,
                      )),
                  subtitle: Text(
                      artistListController
                          .artistList[index].address!,
                      style: const TextStyle(
                        color: Color(0xFF807C84),
                        fontSize: 16,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w400,
                      )),
                );

                //No List Show.

                // return hasMatch
                //     ? SizedBox()
                //     : Padding(
                //         padding: EdgeInsets.symmetric(
                //             vertical: size.height * 0.01),
                //         child: ListTile(
                //           contentPadding: EdgeInsets.zero,
                //           // shape: artistListController.selectedList.contains(artist)? OutlineInputBorder(borderRadius:BorderRadius.circular(10.0)): null,
                //           // tileColor: artistListController.selectedList.contains(artist)? appPrimaryColor: bgBlack,
                //           onTap: () {
                //             if (artistListController.selectedList
                //                 .contains(artist)) {
                //               displayMessage(
                //                   "already added", errorColor);
                //               // artistListController.selectArtist(artist);
                //             }
                //             // print(artistListController
                //             //     .selectedList.isEmpty);
                //             // print(artist);
                //
                //             if (!artistListController.selectedList
                //                 .contains(artist)) {
                //               artistListController.selectArtist(artist);
                //             }
                //             setState(() {});
                //           },
                //           leading: CircleAvatar(
                //               radius: 25,
                //               backgroundImage:
                //                   AssetImage(AppAssets.userPlaceHolder),
                //               foregroundImage: NetworkImage(
                //                   WebService.profileImageUrl +
                //                       artistListController
                //                           .artistList[index]
                //                           .profileImage!)),
                //           title: Text(
                //               artistListController
                //                   .artistList[index].name!,
                //               style: const TextStyle(
                //                 color: Color(0xFFDFDCE3),
                //                 fontSize: 16,
                //                 fontFamily: 'Arimo',
                //                 fontWeight: FontWeight.w700,
                //               )),
                //           subtitle: Text(
                //               artistListController
                //                   .artistList[index].address!,
                //               style: const TextStyle(
                //                 color: Color(0xFF807C84),
                //                 fontSize: 16,
                //                 fontFamily: 'Arimo',
                //                 fontWeight: FontWeight.w400,
                //               )),
                //         ));
              }),
        ],
      ));

  //build artist list
  buildManageArtist(Size size, BuildContext context) => SizedBox(
      height: size.height * 0.45,
      child: artistListController.isLoading.value
          ? Utils.showProgress()
          : artistListController.selectedList.isEmpty &&
                  artistListController.searchController.text.length > 1
              ? buildNoSearchMsg(
                  size, artistListController.searchController.text)
              : artistListController.selectedList.isEmpty
                  ? buildNoFoundMsg(size)
                  : ListView.builder(
                      shrinkWrap: true,
                      controller: scrollController,
                      itemCount: artistListController.selectedList.value.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Artist artist =
                            artistListController.selectedList.value[index];

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          tileColor: cardBgColor,
                          trailing: CloseButton(
                              color: kWhite,
                              onPressed: () async {
                                artistListController.isselectedClickable.value =
                                    true;
                                artistListController.selectedList.value
                                    .remove(artist);

                                artistListController.filterselectedList.value
                                    .remove(artist);
                                artistListController.filterselectedList
                                    .refresh();
                                artistListController.selectedList.refresh();
                                await artistListController.getArtists();
                                setState(() {});
                              }),
                          leading: CircleAvatar(
                              backgroundImage:
                                  AssetImage(AppAssets.userPlaceHolder),
                              foregroundImage: NetworkImage(
                                  WebService.resolveProfileImage(
                                      artistListController.selectedList[index]
                                          .profileImage))),
                          title: Text(
                            artistListController.selectedList[index].name!,
                            style: const TextStyle(
                              color: titleTextWhiteColor,
                              fontSize: 16,
                              fontFamily: 'Arimo',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                              artistListController.selectedList[index].address!,
                              style: const TextStyle(
                                color: Color(0xFF807C84),
                                fontSize: 16,
                                fontFamily: 'Arimo',
                                fontWeight: FontWeight.w400,
                              )),
                        );
                      }));
}
