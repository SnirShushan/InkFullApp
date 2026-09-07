import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/myPostController.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/ui/screen/profile/drawer/controller/business_profile_menu_controller.dart';
import 'package:ink/src/ui/widgets/button/animation_loader_button_widget.dart';
import 'package:ink/src/ui/widgets/unfocus_widget.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/webService.dart';

import '../controller/edit_member_controller.dart';

class EditMemberWidget extends StatefulWidget {
  final String businessType;
  final String userIdStr;
  final bool isConvertUser;

  const EditMemberWidget(
      {super.key,
      required this.businessType,
      this.isConvertUser = false,
      this.userIdStr = ""});

  @override
  State<EditMemberWidget> createState() => _EditMemberWidgetState();
}

class _EditMemberWidgetState extends State<EditMemberWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  final EditMemberController editMemberController =
      Get.put(EditMemberController());
  final BusinessProfileMenuController _businessProfileMenuController =
      Get.put(BusinessProfileMenuController());
  String selectedCreatorId = "";

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return UnFocusWidget(
      child: Scaffold(
        backgroundColor: bgBlack,
        appBar: buildAppBar(size),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "המקעקעים בסטודיו",
                  style: TextStyle(
                    color: titleTextColor,
                    fontSize: 24,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                const Text(
                  "תייגו את צוות המוכשרים שלכם",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: titleTextWhiteColor,
                    fontSize: 18,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                buildSearchbar(size: size),
                SizedBox(height: size.height * 0.01),
                Align(
                  alignment: Alignment.centerRight,
                  child: Obx(
                    () => Text(
                      " תייגתם ${(editMemberController.selectedList?.length ?? 0) + editMemberController.artistIdList.length} חברי צוות: ",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: titleTextWhiteColor,
                        fontSize: 18,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Obx(() => editMemberController.artistList.isEmpty &&
                        editMemberController.searchController.text != ""
                    ? buildNoSearchMsg(
                        size, editMemberController.searchController.text)
                    : editMemberController.artistList.isEmpty
                        ? Center(
                            child: const Text("txt.txt_add_studio",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: lightGrayColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400))
                                .tr(),
                          )
                        : ListView.builder(
                            itemCount: editMemberController.artistList.length,
                            // reverse: true,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            itemBuilder: (BuildContext context, int index) {
                              final artist =
                                  editMemberController.artistList[index];

                              final isSelected = editMemberController
                                  .selectedList
                                  .any((selectedArtist) =>
                                      selectedArtist.profile!.id == artist.id);

                              return Obx(
                                () => widget.userIdStr ==
                                        editMemberController
                                            .artistList[index].id!
                                            .toString()
                                    ? const SizedBox.shrink()
                                    : ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                        onTap: () {
                                          if (isSelected == true ||
                                              editMemberController
                                                      .artistList[index]
                                                      .isRequestSent ==
                                                  "1") {
                                            editMemberController
                                                .isChecked.value = true;
                                            buildDeleteDialog(
                                                context,
                                                () async =>
                                                    await onDelete(index));
                                          } else {
                                            editMemberController.artistUpdate(
                                                editMemberController
                                                    .artistList[index].id!);
                                          }
                                        },
                                        selected: editMemberController
                                                .artistIdList
                                                .contains(artist.id)
                                            ? editMemberController
                                                        .artistList[index]
                                                        .isRequestSent ==
                                                    "1"
                                                ? false
                                                : true
                                            : isSelected ||
                                                    editMemberController
                                                            .artistList[index]
                                                            .isRequestSent ==
                                                        "1"
                                                ? true
                                                : false,
                                        selectedTileColor: cardBgColor,
                                        leading: ClipOval(
                                          child: editMemberController
                                                      .artistList[index]
                                                      .profileImage! ==
                                                  ""
                                              ? Container(
                                                  height: size.width * 0.12,
                                                  width: size.width * 0.12,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  50)),
                                                      image: DecorationImage(
                                                          image: AssetImage(
                                                              AppAssets
                                                                  .galleryPlaceholder),
                                                          fit: BoxFit.cover)),
                                                )
                                              : CachedNetworkImage(
                                                  imageUrl: WebService
                                                      .resolveProfileImage(
                                                          editMemberController
                                                              .artistList[index]
                                                              .profileImage),
                                                  imageBuilder:
                                                      (context,
                                                              imageProvider) =>
                                                          Container(
                                                            height: size.width *
                                                                0.12,
                                                            width: size.width *
                                                                0.12,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .all(
                                                                      Radius.circular(
                                                                          50)),
                                                              image:
                                                                  DecorationImage(
                                                                image:
                                                                    imageProvider,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                  placeholder: (context, url) =>
                                                      const CircularProgressIndicator(),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      Container(
                                                        height:
                                                            size.width * 0.12,
                                                        width:
                                                            size.width * 0.12,
                                                        decoration:
                                                            BoxDecoration(
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .all(
                                                                        Radius.circular(
                                                                            50)),
                                                                image:
                                                                    DecorationImage(
                                                                  image: AssetImage(
                                                                      AppAssets
                                                                          .galleryPlaceholder),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                )),
                                                      )),
                                        ),
                                        title: Text(
                                          // editMemberController.artistIdStr.value,
                                          editMemberController
                                              .artistList[index].name!,
                                          style: const TextStyle(
                                              color: titleTextWhiteColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        subtitle: Text(
                                          editMemberController
                                              .artistList[index].address!,
                                          style: const TextStyle(
                                              color: lightGrayColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        trailing: editMemberController
                                                    .artistIdList
                                                    .contains(artist.id) ||
                                                isSelected ||
                                                editMemberController
                                                        .artistList[index]
                                                        .isRequestSent ==
                                                    "1"
                                            ? CloseButton(
                                                color: kWhite,
                                                onPressed: () async {
                                                  if (isSelected == true) {
                                                    editMemberController
                                                        .isChecked.value = true;
                                                    buildDeleteDialog(
                                                        context,
                                                        () async =>
                                                            await onDelete(
                                                                index));
                                                  } else if (editMemberController
                                                          .artistList[index]
                                                          .isRequestSent ==
                                                      "1") {
                                                    editMemberController
                                                        .isChecked.value = true;
                                                    buildDeleteDialog(
                                                        context,
                                                        () async =>
                                                            await onDelete(
                                                                index));
                                                  } else {
                                                    editMemberController
                                                        .artistUpdate(
                                                            editMemberController
                                                                .artistList[
                                                                    index]
                                                                .id!);
                                                  }
                                                },
                                              )
                                            : const SizedBox(),
                                      ),
                              );
                            })),
                SizedBox(height: size.height * 0.02),
                Container(
                    padding: EdgeInsets.only(
                        left: size.width * 0.03,
                        right: size.width * 0.03,
                        bottom: size.height * 0.02),
                    decoration: const BoxDecoration(
                        color: bgBlack,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16))),
                    child: Obx(
                      () => AnimationLoaderButtonWidget(
                          isLoading: _businessProfileMenuController
                                  .isLoadingTeam.value ==
                              true,
                          title: "שמירת שינויים",
                          onTap: () async {
                            _businessProfileMenuController.isLoadingTeam.value =
                                true;
                            if (editMemberController
                                .artistIdList.value.isNotEmpty) {
                              // if (widget.businessType == "1") {

                              if (widget.isConvertUser) {
                                WebService.tempArtistIdList =
                                    editMemberController.artistIdList.join(',');
                                _businessProfileMenuController
                                    .isLoadingTeam.value = false;
                                Get.back();
                              } else {
                                await editMemberController
                                    .updateMultipleArtists(
                                        artistId: editMemberController
                                            .artistIdList
                                            .join(','),
                                        actionStatus: "1")
                                    .then((value) {
                                  _businessProfileMenuController
                                      .isLoadingTeam.value = false;
                                });
                              }
                            } else {
                              // displayMessage(
                              //     "אנא בחר אמן לסטודיו שלך", Colors.red);

                              if (editMemberController.isChecked.value) {
                                editMemberController.isChecked.value = false;

                                displayMessageIcon(
                                    snackposition: SnackPosition.BOTTOM,
                                    message: "השינויים נשמרו בהצלחה",
                                    color: successGreen,
                                    imageData:
                                        AppAssets.correct_transparentIcon);

                                Navigator.of(context).pop();
                              } else {
                                displayMessageIcon(
                                    snackposition: SnackPosition.BOTTOM,
                                    message: "לא בוצעו שינויים",
                                    color: successGreen,
                                    imageData:
                                        AppAssets.correct_transparentIcon);

                                Navigator.of(context).pop();
                              }

                              _businessProfileMenuController
                                  .isLoadingTeam.value = false;
                            }
                          }),
                    )),
                SizedBox(height: size.height * 0.06),
              ],
            ),
          ),
        ),
      ),
    );
  }

  buildAppBar(Size size) => AppBar(
      elevation: 0,
      backgroundColor: bgBlack,
      leading: Padding(
          padding: EdgeInsets.all(size.width * 0.01),
          child: Center(
              child: InkWell(
                  onTap: () => Get.back(),
                  child: const CloseButton(color: kWhite)))),
      centerTitle: true,
      toolbarHeight: size.height * 0.1,
      title: const Text(""));

  buildSearchbar({required Size size}) => SizedBox(
        height: size.height * 0.1,
        child: TextFormField(
            autofocus: false,
            controller: editMemberController.searchController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.search,
            onTapOutside: (event) =>
                FocusManager.instance.primaryFocus?.unfocus(),
            style: const TextStyle(color: titleTextWhiteColor),
            onEditingComplete: () => editMemberController.getArtists(),
            onFieldSubmitted: (txt) {
              FocusManager.instance.primaryFocus?.unfocus();
              editMemberController.getArtists();
            },
            onChanged: (txt) => editMemberController.getArtists(),
            decoration: InputDecoration(
                hintStyle: const TextStyle(color: Color(0xFF6B676F)),
                hintText: "חפשו את חברי הצוות שלכם",
                contentPadding: const EdgeInsets.all(8),
                filled: true,
                fillColor: socialoginbtn,
                suffixIcon: InkWell(
                    child: const Icon(Icons.clear, color: titleTextWhiteColor),
                    onTap: () => editMemberController.searchController.clear()),
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
                      FocusManager.instance.primaryFocus?.unfocus();
                      editMemberController.getArtists();
                    }),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)))),
      );

  onDelete(int index) async {

      await Network.updateArtistList(
          artistId: editMemberController.artistList[index].id!,
          actionStatus: "2")
          .then((value) {
        editMemberController.getArtists().then((value) async {
          final MyPostsController myPostsController =
          Get.put(MyPostsController());

          await myPostsController.getMyPosts();
          _businessProfileMenuController.initPackageInfo();
        });
      });


  }

  buildNoSearchMsg(Size size, String search_txt) => SizedBox(
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
}
