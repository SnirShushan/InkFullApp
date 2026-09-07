import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/artistsListController.dart';
import 'package:ink/src/controller/myPostController.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/business_dashboard.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/bussinessdashboard_binding.dart';
import 'package:ink/src/utils/colors.dart';

import '../../../controller/post_controller.dart';
import '../../../controller/userController.dart';
import '../../../data/model/image_model.dart';
import '../../../data/source/network/firebase_api.dart';
import '../../../data/source/network/user_api.dart';
import '../../../utils/common.dart';
import '../../../utils/webService.dart';
import '../../widgets/unfocus_widget.dart';

class SketchImageScreenBackup extends StatefulWidget {
  final pickedFile;
  final String imageType;
  const SketchImageScreenBackup(
      {super.key, required this.pickedFile, required this.imageType});
  @override
  State<SketchImageScreenBackup> createState() =>
      _SketchImageScreenBackupState();
}

class _SketchImageScreenBackupState extends State<SketchImageScreenBackup> {
  bool firstScreenVisible = true;
  bool secondScreenVisible = false;
  bool thirdScreenVisible = false;

  UploadTask? uploadTask;

  List<StylesList> listStyles = [];
  List<StylesList> filteredListStyles = [];
  List<StylesList> selectedList = [];
  List<String> selectedMemberList = [];
  late AppUser user;
  final userController = Get.put(UserController());
  final postController = Get.put(PostController());
  final artistController = Get.put(ArtistListController());
  final myPostsController = Get.put(MyPostsController());
  TextEditingController aboutTextController = TextEditingController();
  TextEditingController searchTxtController = TextEditingController();
  TextEditingController searchUserTxtController = TextEditingController();
  Future getArtists() async => await artistController.getArtists();
  bool isSearched = false;

  @override
  void initState() {
    super.initState();
    getUserStyles();
    getArtists();
  }

  //get userStyles
  Future getUserStyles() async {
    user = await WebService.getCurrentUser();
    user.stylesList?.map((doc) {
      listStyles.add(doc);
    }).toList();
    user.stylesList?.map((doc) {
      filteredListStyles.add(doc);
    }).toList();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    aboutTextController.dispose();
  }

  //search styles
  searchQuery(query) {
    if (query.toString().length > 1) {
      var filterData = listStyles
          .where((e) => e.name.toString().toLowerCase().contains(query))
          .toList();
      setState(() {
        isSearched = true;
        listStyles = filterData;
      });
    } else if (query.toString().isEmpty) {
      setState(() {
        isSearched = false;
        listStyles = filteredListStyles;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;

    return UnFocusWidget(
        child: SafeArea(
      child: Scaffold(
        body: firstScreenVisible
            ?
            //styles screen
            Column(
                children: [
                  customAppBar("בחירת סגנונות", context, size, textTheme),
                  SizedBox(height: size.height * 0.02),
                  Text('תייג סגנון התמונה',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.bold)),
                  Visibility(
                    visible: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.1,
                          vertical: size.height * 0.02),
                      child: TextFormField(
                        maxLines: 1,
                        onChanged: (text) => searchQuery(text),
                        controller: searchTxtController,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          prefixIcon: Icon(Icons.search),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: kDivider),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: kDivider),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: kRed),
                          ),
                        ),
                      ),
                    ),
                  ),

                  //styles
                  Expanded(
                    flex: 1,
                    child: listStyles.isEmpty
                        ? const Center(
                            child: Text("אין סגנון להראות")) //No style to show
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            itemCount: listStyles.length,
                            semanticChildCount: 5,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                  onTap: () => setState(() {
                                        if (!selectedList
                                            .contains(listStyles[index])) {
                                          selectedList.add(listStyles[index]);
                                        } else {
                                          selectedList
                                              .remove(listStyles[index]);
                                        }
                                      }),
                                  child: Container(
                                    width: size.width,
                                    color:
                                        selectedList.contains(listStyles[index])
                                            ? Theme.of(context).primaryColor
                                            : Colors.transparent,
                                    child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: size.width * 0.05,
                                            horizontal: size.width * 0.05),
                                        // child: Text("Item $index"),
                                        child: Text(
                                            "#${listStyles[index].name!}",
                                            style: TextStyle(
                                                color: selectedList.contains(
                                                        listStyles[index])
                                                    ? Colors.white
                                                    : Colors.black)),
                                      ),
                                    ),
                                  ));
                            }),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: buildButton(
                          align: Alignment.center,
                          size: Get.size,
                          width: double.infinity,
                          text: "btn.continue",
                          onClick: () {
                            setState(() {
                              firstScreenVisible = false;
                              secondScreenVisible = true;
                              thirdScreenVisible = false;
                            });
                          })),
                ],
              )
            : secondScreenVisible
                ?
                //image description screen
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      customAppBar("תיאור", context, size, textTheme),
                      SizedBox(height: size.height * 0.05),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.1,
                            vertical: size.height * 0.01),
                        child: Text(
                          'כמה מילים',
                          style: textTheme.titleMedium!.copyWith(color: kBlack),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.1,
                              vertical: size.height * 0.01),
                          child: TextFormField(
                              controller: aboutTextController,
                              minLines: 5,
                              maxLines: 10,
                              keyboardType: TextInputType.multiline,
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(4),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: kDivider)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: kDivider)),
                                  errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: kRed))))),
                      const Spacer(),
                      uploadTask != null
                          ? const Center(child: CircularProgressIndicator())
                          : Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: buildButton(
                                  align: Alignment.center,
                                  size: Get.size,
                                  width: double.infinity,
                                  text: "btn.continue",
                                  onClick: () async {
                                    FocusScope.of(context).unfocus();
                                    if (userController.businessType.value ==
                                            "1" &&
                                        artistController
                                            .artistList.isNotEmpty) {
                                      setState(() {
                                        firstScreenVisible = false;
                                        secondScreenVisible = false;
                                        thirdScreenVisible = true;
                                      });
                                    } else {
                                      await uploadImage();
                                    }
                                  }))
                    ],
                  )
                :
                //tag crew member
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      customAppBar("בחירת המקעקע", context, size,
                          textTheme), //choose member
                      SizedBox(
                        height: size.height * 0.05,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.1,
                            vertical: size.height * 0.01),
                        child: Text(
                          "תייג את המקעקע",
                          style: textTheme.titleMedium!.copyWith(color: kBlack),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.1,
                            vertical: size.height * 0.02),
                        child: TextFormField(
                          controller: searchUserTxtController,
                          maxLines: 1,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            prefixIcon: Icon(Icons.search),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: kDivider),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: kDivider),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: kRed),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                          flex: 1,
                          child: artistController.artistList.isEmpty
                              ? Center(
                                  child: user.profile!.businessType == "1"
                                      ? const Text("alerts.no_artist_found")
                                          .tr()
                                      : const Text("alerts.no_studio_found")
                                          .tr())
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: artistController.artistList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final id = artistController
                                        .artistList[index].profile!.id;
                                    // WebService.printMsg(selectedMemberList.toString());
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ListTile(
                                            onTap: () => setState(() {
                                                  if (!selectedMemberList
                                                      .contains(id)) {
                                                    if (selectedMemberList
                                                        .isEmpty) {
                                                      selectedMemberList
                                                          .add(id!);
                                                    } else {
                                                      selectedMemberList
                                                          .clear();
                                                      selectedMemberList
                                                          .add(id!);
                                                    }
                                                  } else {
                                                    selectedMemberList
                                                        .remove(id);
                                                  }
                                                  WebService.printMsg(
                                                      selectedMemberList
                                                          .toString());
                                                }),
                                            selected:
                                                selectedMemberList.contains(id)
                                                    ? true
                                                    : false,
                                            selectedTileColor: defaultWhite,
                                            leading: buildCachedNetworkImage(
                                                height: size.width * 0.12,
                                                width: size.width * 0.12,
                                                url: WebService
                                                    .resolveProfileImage(
                                                        artistController
                                                            .artistList[index]
                                                            .profile
                                                            ?.profileImage),
                                                radius: 50),
                                            title: SizedBox(
                                                height: size.width * 0.12,
                                                width: size.width * 0.4,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Text(
                                                        artistController
                                                            .artistList[index]
                                                            .profile!
                                                            .name!,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                size.height *
                                                                    0.02)),
                                                    const VerticalDivider(
                                                        thickness: 2),
                                                    Text(artistController
                                                        .artistList[index]
                                                        .profile!
                                                        .address!)
                                                  ],
                                                ))),
                                        const Divider(),
                                      ],
                                    );
                                  })),
                      const Divider(),
                      uploadTask != null
                          ? const Center(child: CircularProgressIndicator())
                          : Padding(
                              padding: EdgeInsets.all(10.0),
                              child: buildButton(
                                  align: Alignment.center,
                                  size: Get.size,
                                  width: double.infinity,
                                  text: "btn.continue",
                                  onClick: () async {
                                    FocusScope.of(context).unfocus();
                                    await uploadImage();
                                  }))
                    ],
                  ),
      ),
    ));
  }

  //appbar
  customAppBar(
          String title, BuildContext context, Size size, TextTheme textTheme) =>
      Container(
        color: defaultBlack,
        width: size.width,
        height: size.height * 0.1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Visibility(
              visible: false,
              child: InkWell(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.arrow_circle_right_sharp)),
            ),
            Text(
              title,
              style: textTheme.titleMedium!.copyWith(color: defaultWhite),
            ),
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.02),
              child: InkWell(
                onTap: () => Get.back(),
                child: const Icon(Icons.close_rounded, color: defaultWhite),
              ),
            ),
          ],
        ),
      );

  //image uploading progress
  buildProgress() => StreamBuilder<TaskSnapshot>(
      stream: uploadTask?.snapshotEvents,
      builder: (context, snapshots) {
        final data = snapshots.data!;
        double progress = data.bytesTransferred / data.totalBytes;

        return SizedBox(
            height: 50,
            child: Stack(
              fit: StackFit.expand,
              children: [
                LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey,
                    color: Colors.green),
                Center(
                    child: Text(
                        'Please Wait..  ${(100 * progress).roundToDouble()} %',
                        style: const TextStyle(color: Colors.white)))
              ],
            ));
      });

  //upload image to firebase
  uploadImage() async {
    String styleList = "";
    if (selectedList != null) {
      selectedList.forEach((v) {
        styleList += v == selectedList.last ? v.slug! : "${v.slug},";
      });
    }

    String fileName = widget.pickedFile.existsSync()
        ? widget.pickedFile.path.split('/').last
        : null;

    AppUser user = await WebService.getCurrentUser();
    final path = "creatorImages/${user.profile!.id}/$fileName";

    final ref = FirebaseStorage.instance.ref().child(path);

    setState(() {
      uploadTask = ref
          .putFile(widget.pickedFile.existsSync() ? widget.pickedFile : null);
    });

    final snapshots = await uploadTask!.whenComplete(() {
      setState(() {
        uploadTask = null;
      });
    });

    final imageUrl = await snapshots.ref.getDownloadURL();

    RequestImages image = RequestImages(
        name: fileName, imageUrl: imageUrl, uid: user.profile!.id!);

    await FireBaseApi.uploadBusinessImage(image: image);

    await Network.addPost(
      imageType: widget.imageType,
      description: aboutTextController.text,
      imageName: image.imageUrl!,
      imageId: image.imageId!,
      styles: styleList,
      creatorId: selectedMemberList.isNotEmpty ? selectedMemberList[0] : "",
    ).then((value) async {
      await postController.getPosts().then((value) async {
        await myPostsController.getMyPosts();
      });
    });

    Get.offAll(
        BusinessDashBoard(
          initialIndex: 0,
        ),
        binding: BusinessDashBoardBinding());
  }
}
