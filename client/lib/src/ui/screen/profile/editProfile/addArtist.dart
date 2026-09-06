import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/userController.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/webService.dart';
import 'package:signature/signature.dart';

import '../../../../controller/artistsListController.dart';
import '../../../../data/source/network/user_api.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/common.dart';

class AddMembers extends StatefulWidget {
  final String memberType;
  const AddMembers({Key? key, required this.memberType}) : super(key: key);

  @override
  State<AddMembers> createState() => _AddMembers();
}

class _AddMembers extends State<AddMembers> {
  final TextEditingController searchController = TextEditingController();

  final SignatureController _controller = SignatureController(
      penStrokeWidth: 5,
      penColor: Colors.red,
      exportBackgroundColor: Colors.blue);

  final UserController userController = Get.put(UserController());
  final ArtistListController artistController = Get.put(ArtistListController());

  Future getList() async => await Network.getBusinessListApi(
      btype: userController.businessType.value == "1" ? "2" : "1");

  late Future _getList;

  List<String> artistIds = [];

  @override
  void initState() {
    super.initState();
    _getList = getList();
    userController.artistList.forEach((element) {
      artistIds.add(element.id!);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<dynamic> memberList = [];
  List<dynamic> searchList = [];

  String artistId = "";

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final isArtist = userController.businessType.value == "2" ? true : false;

    return WillPopScope(
      onWillPop: () async {
        Get.back();

        return true;
      },
      child: Scaffold(
        appBar: buildappBarwithClose(
            size: size,
            title:
                isArtist ? "txt.ttl_add_member_artist" : "txt.ttl_add_member"),
        bottomSheet: buildContinueBtn(size: size),
        body: Stack(
          children: [
            SingleChildScrollView(
                child: Column(
              children: [
                Container(color: Colors.white, height: size.height * 0.01),
                Container(
                    color: Colors.white,
                    height: size.height * 0.02,
                    child: Center(
                        child: Text(isArtist
                                ? "txt.sub_ttl_add_member_artist"
                                : "txt.sub_ttl_add_member")
                            .tr())),
                buildSearchbar(size: size),
                buildUserList(size: size),
              ],
            )),
          ],
        ),
      ),
    );
  }

  //search
  buildSearchbar({required Size size}) => Container(
        color: Colors.white,
        height: size.height * 0.1,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.1, vertical: size.height * 0.02),
          child: TextFormField(
            controller: searchController,
            autofocus: false,
            // textAlign: TextAlign.center,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(0.0),
              filled: true,
              focusColor: defaultAppColor,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  gapPadding: 0.0,
                  borderSide: const BorderSide(color: Colors.black)),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
      );

  //artist list
  buildUserList({required Size size}) => SizedBox(
        height: size.height * 0.62,
        child: FutureBuilder(
            future: _getList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError ||
                  snapshot.data == null ||
                  snapshot.data == false) {
                return Center(
                    child: userController.businessType.value == "2"
                        ? const Text("alerts.no_artist_found").tr()
                        : const Text("alerts.no_studio_found").tr());
              } else if (snapshot.hasData) {
                // if(searchController.text != null) {
                memberList = snapshot.data;
                return memberList.isEmpty
                    ? Center(
                        child: userController.businessType.value == "2"
                            ? const Text("alerts.no_artist_found").tr()
                            : const Text("alerts.no_studio_found").tr())
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: memberList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return artistIds.contains(memberList[index]["id"])
                              ? const SizedBox()
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ListTile(
                                        onTap: () => setState(() {
                                              if (artistId ==
                                                  memberList[index]["id"]) {
                                                artistId = "";
                                              } else {
                                                artistId =
                                                    memberList[index]["id"];
                                              }
                                            }),
                                        selected:
                                            artistId == memberList[index]["id"]
                                                ? true
                                                : false,
                                        selectedTileColor: defaultWhite,
                                        leading: CachedNetworkImage(
                                            imageUrl:
                                                WebService.resolveProfileImage(
                                                    memberList[index]
                                                        ["profile_image"]),
                                            imageBuilder: (context,
                                                    imageProvider) =>
                                                Container(
                                                  height: size.width * 0.12,
                                                  width: size.width * 0.12,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                50)),
                                                    image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                            placeholder: (context, url) =>
                                                const CircularProgressIndicator(),
                                            errorWidget: (context, url,
                                                    error) =>
                                                Container(
                                                  height: size.width * 0.12,
                                                  width: size.width * 0.12,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  50)),
                                                      image: DecorationImage(
                                                        image: AssetImage(AppAssets
                                                            .galleryPlaceholder),
                                                        fit: BoxFit.cover,
                                                      )),
                                                )),
                                        title: SizedBox(
                                          height: size.width * 0.12,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                  width: size.width * 0.4,
                                                  child: Text(
                                                      memberList[index]["name"],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: Get
                                                          .textTheme.bodyMedium!
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold))),
                                              const VerticalDivider(
                                                  thickness: 2),
                                            ],
                                          ),
                                        ),
                                        trailing: SizedBox(
                                            width: size.width * 0.25,
                                            child: Text(
                                                memberList[index]["address"],
                                                textAlign: TextAlign.end,
                                                maxLines: 3,
                                                style:
                                                    Get.textTheme.bodySmall))),
                                    const Divider(),
                                  ],
                                );
                        });
              }
              return Container();
            }),
      );

  //continue btn
  buildContinueBtn({required Size size}) => SizedBox(
        height: size.height * 0.1,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: buildButton(
            align: Alignment.bottomCenter,
            size: Get.size,
            width: double.infinity,
            text: "btn.continue",
            onClick: () async {
              if (artistId.isNotEmpty) {
                if (userController.businessType.value == "1") {
                  await artistController
                      .updateArtists(artistId: artistId, actionStatus: "1")
                      .then((value) async =>
                          await artistController.getArtists().then((value) {}));
                } else {
                  await artistController
                      .updateStudios(studioId: artistId, actionStatus: "1")
                      .then((value) async =>
                          await artistController.getArtists().then((value) {}));
                }
              } else {
                displayMessageIcon(
                    message: "אנא בחר אמן לסטודיו שלך",
                    snackposition: SnackPosition.BOTTOM,
                    color: errorColor,
                    imageData: AppAssets.errorIcon);
              }
            },
          ),
        ),
      );
}
