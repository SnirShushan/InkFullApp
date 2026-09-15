import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/data/model/folderImage.dart';
import 'package:ink/src/data/model/postDetails.dart';
import 'package:ink/src/data/model/post_inspiration_model.dart';
import 'package:ink/src/data/source/network/firebase_api.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/ui/screen/home/imageDetails/post_details.dart';
import 'package:ink/src/ui/widgets/appbar_action_widget.dart';
import 'package:ink/src/ui/widgets/bottomenu/business_dashboard_bottomenu.dart';
import 'package:ink/src/ui/widgets/bottomenu/dashboard_bottomenu.dart';
import 'package:ink/src/utils/webService.dart';

import '../../../utils/assets.dart';
import '../../../utils/colors.dart';
import 'edit_collection.dart';
import 'new_collection.dart';

class CollectionView extends StatelessWidget {
  final currentUserType;
  final String fName;
  final String imageUrls;
  final String fid;
  final bool isback2time;

  const CollectionView(
      {Key? key,
      required this.fName,
      required this.fid,
      required this.imageUrls,
      required this.currentUserType,
      this.isback2time = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bgBlack,
      appBar: AppBarActionButtonWidget(
          onBackPressed: () {
            if (isback2time == true) {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pop();
            }
          },
          title: fName.toString(),
          onPressed: () =>
              _showBottomSheet(context, fid, fName, currentUserType, imageUrls),
          iconName: AppAssets.dots3Icon),
      bottomNavigationBar: currentUserType == "2"
          ? BusinessDashboardBottomBar(
              currentIndex: 4,
            )
          : DashboardBottomBar(currentIndex: 3),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ImageGridScreen(
            fid: fid,
            currentUserType: currentUserType,
            fName: fName,
            imageUrls: imageUrls),
      ),
    );
  }
}

_showBottomSheet(BuildContext context, String fid, String fName,
    currentUserType, imageUrls) {
  return showModalBottomSheet<dynamic>(
      useRootNavigator: true,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
              color: signInButtonColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //back
              InkWell(
                  onTap: () => Get.back(),
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.03,
                          horizontal: MediaQuery.of(context).size.width * 0.4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Container(
                            margin: const EdgeInsetsDirectional.only(
                                start: 1.0, end: 1.0),
                            height: MediaQuery.of(context).size.height * 0.005,
                            width: MediaQuery.of(context).size.width * 0.2,
                            decoration: BoxDecoration(
                                color: kDivider,
                                borderRadius: BorderRadius.circular(10.0))),
                      ))),
              //rename collection
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => CreateNewCollection(
                      imagePath: imageUrls!,
                      postModel: MPostDetails(),
                      isRenameEnabled: true,
                      name: fName,
                      fid: fid));

                  // showBottomSheetNewBoard(
                  //     context: context,
                  //     postModel: MPostDetails(),
                  //     name: fName,
                  //     fid: fid,
                  //     isRenameEnabled: true);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  color: signInButtonColor,
                  height: MediaQuery.of(context).size.height * 0.07,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon(Icons.photo_outlined,
                      //     size: 24, color: titleTextWhiteColor),
                      SizedBox(width: 8),
                      Text("שינוי שם",
                          style: TextStyle(
                              color: titleTextWhiteColor, fontSize: 18)),
                    ],
                  ),
                ),
              ),
              //select & delete
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Get.to(EditCollection(
                      fid: fid, currentUserType: currentUserType));
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  color: signInButtonColor,
                  height: MediaQuery.of(context).size.height * 0.07,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon(Icons.photo_outlined,
                      //     size: 24, color: titleTextWhiteColor),
                      SizedBox(width: 8),
                      Text("סימון ועריכה",
                          style: TextStyle(
                              color: titleTextWhiteColor, fontSize: 18)),
                    ],
                  ),
                ),
              ),
              //delete collection
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  deleteCollectionAlertDialog(context, fid);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  color: signInButtonColor,
                  height: MediaQuery.of(context).size.height * 0.07,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(AppAssets.trashIcon, color: redtxtColor),
                      const SizedBox(width: 8),
                      const Text("מחיקת אוסף",
                          style: TextStyle(color: redtxtColor, fontSize: 18)),
                    ],
                  ),
                ),
              ),
              if (Platform.isAndroid)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.07,
                )
            ],
          ),
        );
      });
}

void deleteCollectionAlertDialog(BuildContext context, String fid) {
  var size = MediaQuery.of(context).size;
  bool isdeleteloading = false;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: signInButtonColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
        contentPadding: const EdgeInsets.all(20.0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: size.height * 0.01,
            ),
            const Text(
              "למחוק את האוסף?",
              // "למחוק את התמונות מהאוסף?",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: titleTextWhiteColor),
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
            const Text(
              "האוסף וכל התמונות שבו ימחקו ללא אפשרות שחזור.",
              // "התמונות שסומנו ימחקו\nמהאוסף ללא אפשרות שחזור.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: titleTextWhiteColor,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: styleBgColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: const Text("ביטול"),
                  onPressed: () {
                    // Add your delete action here
                    if (isdeleteloading == false) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                SizedBox(width: size.width * 0.02),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: errorColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: const Text("מחיקה"),
                  onPressed: () async {
                    if (isdeleteloading == false) {
                      isdeleteloading = true;
                      await FireBaseApi.deleteCollection(fid: fid)
                          .then((value) {
                        Future.delayed(const Duration(seconds: 1))
                            .then((value) {
                          isdeleteloading == false;
                          Navigator.pop(context);
                          Navigator.pop(context);
                        });
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

class ImageGridScreen extends StatefulWidget {
  final currentUserType;
  final String fName;
  final String imageUrls;
  final String fid;

  const ImageGridScreen(
      {Key? key,
      required this.fName,
      required this.fid,
      required this.imageUrls,
      required this.currentUserType})
      : super(key: key);

  @override
  State<ImageGridScreen> createState() => _ImageGridScreenState();
}

class _ImageGridScreenState extends State<ImageGridScreen> {
  static const int _suggestBelowCount = 6;
  List<PostInspirationModel> _suggestions = [];
  int _lastSavedCount = -1;
  bool _loadingSuggestions = false;

  Stream<List<FolderImage>> _readPosts() => FirebaseFirestore.instance
      .collection('foldersImages')
      .where('fid', isEqualTo: widget.fid)
      .snapshots()
      .map((snapshots) => snapshots.docs
          .map((doc) {
            try {
              return FolderImage.fromJson(doc.data());
            } catch (_) {
              return null;
            }
          })
          .whereType<FolderImage>()
          .toList());

  Future<void> _loadSuggestions(List<FolderImage> saved) async {
    if (saved.length >= _suggestBelowCount) {
      if (_suggestions.isNotEmpty && mounted) {
        setState(() => _suggestions = []);
      }
      return;
    }
    if (_loadingSuggestions) return;
    _loadingSuggestions = true;
    try {
      final AppUser user = await WebService.getCurrentUser();
      final styles = user.profile?.styles ?? "";
      final data = await Network.getHomePostsApi(
        isRandom: "1",
        start: 0,
        limit: 12,
        postIds: "",
        styles: styles,
      );
      if (data == false || data == null) return;
      final raw = data["posts"];
      if (raw is! List) return;
      final savedIds = saved.map((e) => e.pId).toSet();
      final list = <PostInspirationModel>[];
      for (final item in raw) {
        if (item is! Map) continue;
        final post = PostInspirationModel.fromJson(
            Map<String, dynamic>.from(item));
        if ((post.id ?? "").isEmpty || savedIds.contains(post.id)) continue;
        list.add(post);
        if (list.length >= 6) break;
      }
      if (mounted) setState(() => _suggestions = list);
    } finally {
      _loadingSuggestions = false;
    }
  }

  void _maybeLoadSuggestions(List<FolderImage> saved) {
    if (saved.length == _lastSavedCount) return;
    _lastSavedCount = saved.length;
    _loadSuggestions(saved);
  }

  Widget _roundedTile({
    required Size size,
    required String imageUrl,
    required bool isMultiple,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: WebService.resolveImageUrl(imageUrl),
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Image.asset(
                "assets/images/placeholder.png",
                fit: BoxFit.cover,
              ),
            ),
            if (isMultiple)
              Positioned(
                top: 10,
                right: 10,
                child: SvgPicture.asset(AppAssets.multiImageicon,
                    width: 20, height: 20),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return StreamBuilder<List<FolderImage>>(
        stream: _readPosts(),
        builder:
            (BuildContext context, AsyncSnapshot<List<FolderImage>> snapshot) {
          if (snapshot.hasError) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.04),
                Container(
                  padding: const EdgeInsets.all(16),
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    color: Color(0xFF211D25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cloud_off_outlined,
                      color: titleTextWhiteColor),
                ),
                SizedBox(height: size.height * 0.03),
                const Text(
                  "לא ניתן לטעון את האוסף",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: titleTextWhiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data ?? [];
          WebService.folderList.clear();
          WebService.folderList = users;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _maybeLoadSuggestions(users);
          });

          if (users.isEmpty) {
            // Do not wipe the folder cover when the query is empty.
          }

          return ListView(
            children: [
              if (users.isEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: size.height * 0.03),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: size.height * 0.02),
                      Container(
                        padding: const EdgeInsets.all(16),
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          color: Color(0xFF211D25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.folder_off_outlined,
                            color: titleTextWhiteColor),
                      ),
                      SizedBox(height: size.height * 0.02),
                      const Text(
                        'אין פוסטים להצגה כאן',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: titleTextWhiteColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final folder = users[index];
                    final imageData = folder.imageUrl;
                    final isMultiple = imageData.contains(',') &&
                        imageData.startsWith('[') &&
                        imageData.endsWith(']');
                    return _roundedTile(
                      size: size,
                      imageUrl: FireBaseApi().getFirstImageUrl(imageData) ??
                          WebService.tempImageUrl,
                      isMultiple: isMultiple,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => PostDetails(
                                  postId: folder.pId,
                                  foldersid: folder.fid,
                                  fidCollection: widget.fid,
                                  currentUserTypeCollection:
                                      widget.currentUserType,
                                  fNameCollection: widget.fName,
                                  isCollectionMultipleImages: isMultiple,
                                  imageUrlsCollection: widget.imageUrls,
                                  isArtist: false))),
                    );
                  },
                ),
              if (users.length < _suggestBelowCount &&
                  _suggestions.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'הצעות לאוסף',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Color(0xFFDFDCE3),
                      fontSize: 16,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final post = _suggestions[index];
                    return _roundedTile(
                      size: size,
                      imageUrl: post.imageName ?? "",
                      isMultiple: post.isMultipleImages == "1",
                      onTap: () => Get.to(() => PostDetails(
                          postId: post.id ?? "", isArtist: false)),
                    );
                  },
                ),
              ],
            ],
          );
        });
  }
}
