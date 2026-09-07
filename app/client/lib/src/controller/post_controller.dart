import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/userController.dart';
import 'package:ink/src/data/model/post_inspiration_model.dart';
import 'package:ink/src/data/model/post_model.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/webService.dart';

import 'StartupController.dart';
import 'myPostController.dart';

class PostController extends GetxController {
  //straggered
  RxBool staggeredEnabled = true.obs;

  //set post model
  var posts = <PostInspirationModel>[].obs;
  var followingPosts = <PostInspirationModel>[].obs;
  RxBool isLoading = true.obs;
  RxList<PostInspirationModel> searchedList = <PostInspirationModel>[].obs;
  final searchController = TextEditingController();
  bool isSearchEnabled = false;
  bool isLikeLoading = false;
  RxBool isInternetAvailable = false.obs;
  RxBool isAllSelected = true.obs;
  RxString currentStyleIndex = "0".obs;
  RxString tempimageType = "".obs;
  bool isApiLoading = false;
  //load more post
  final ScrollController scrollController = ScrollController();
  final ScrollController followingScrollController = ScrollController();

  //start limit
  int start = 0;
  int limit = 10;

  //following posts
  RxBool isFollowingLoading = false.obs;
  int followingStart = 0;
  int followingLimit = 10;

  //style
  String selectStyle = "";

  final UserController userController = Get.find<UserController>();
  late final StartupController startupController =
      Get.find<StartupController>();
  late final MyPostsController myPostsController =
      Get.find<MyPostsController>();

  //getting app data
  Future initUser() async => await userController.initUser();

  Future<bool> checkInternet() async => await WebService.checkConnection();

  retry() async {
    try {
      await checkInternet().then((value) async {
        if (value == true) {
          isInternetAvailable.value = true;
          await initUser().then((value1) async =>
              await StartupController().getStartupImage().then((value2) async {
                // if(WebService.isSessionExpire == false) {
                await getPosts().then((value) async {
                  if (value == true) {
                    await initUser().then((value1) async =>
                        await startupController
                            .checkSubscription()
                            .then((val) async => await getFollowingPosts()));
                  }
                });
                // }
              }));
        } else {
          isInternetAvailable.value = false;
        }
        update();
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  void onInit() {
    posts.clear();
    followingPosts.clear();
    retry();
    super.onInit();
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  void toggleView({required bool isEnable}) {
    staggeredEnabled.value = isEnable;
    update();
  }

  void scrollDown() {
    if (staggeredEnabled.value) {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.fastOutSlowIn,
      );
    } else {
      followingScrollController.animateTo(
        followingScrollController.position.minScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  // int postStart = 0;
  // int postLimit = 10;

  //get posts
  Future getPosts() async {
    if (isApiLoading) return;
    isApiLoading = true;
    try {
      posts.clear();
      posts = <PostInspirationModel>[].obs;
      isLoading.value = true;
      if (selectStyle != "") {
        isAllSelected.value = false;
      }
      List<PostInspirationModel> tempPost = [];
      await Network.getPostsApi(
              style: selectStyle, start: "", limit: "", following: "0")
          .then((value) async {
        if (value != false) {
          try {
            value.map((doc) async {
              // print(doc["id"]);
              // final isValid =
              //     await Network.isImageUrlValid(url: doc["image_name"]);
              // if (isValid == true) {
              posts.value.add(PostInspirationModel.fromJson(doc));
              // } else {
              //   final PostModel postModel = PostModel.fromJson(doc);
              //   postModel.imageName = "";
              //   posts.value.add(postModel);
              // }
            }).toList();
          } catch (ex) {
            print("PostModel.fromJson");
            print(ex.toString());
          }
        }

        // postLimit = posts.length;
        // postStart += 10;
      });
      // posts.value.addAll(tempPost);

      isLoading.value = false;
      isSearchEnabled = false;
      posts.refresh();
    } catch (e) {
      displayMessageIcon(
          message: e.toString(),
          snackposition: SnackPosition.BOTTOM,
          color: errorColor,
          imageData: AppAssets.errorIcon);
      isLoading.value = false;
      throw e;
    } finally {
      isApiLoading = false;
    }
  }

  //get following  posts
  Future getFollowingPosts() async {
    // if (isFollowingLoading) return;
    isFollowingLoading.value = true;
    if (selectStyle != "") {
      isAllSelected.value = false;
    }
    await Network.getPostsApi(
            style: selectStyle, start: "", limit: "", following: "1")
        .then((value) async {
      if (value != false) {
        await value.map((doc) async {
          followingPosts.add(PostInspirationModel.fromJson(doc));
        }).toList();
        followingStart += 10;
      }
    });
    isFollowingLoading.value = false;
    isSearchEnabled = false;
  }

  //follow user
  Future followPostUser({fid, likeStatus}) async {
    isLikeLoading = true;
    isFollowingLoading.value = true;
    await Network.followUser(fid: fid, likeStatus: likeStatus);
    await refreshPosts();
    isLikeLoading = false;
    isFollowingLoading.value = false;
  }

  //search text
  void searchPost() {
    if (searchController.text.isNotEmpty) {
      if (staggeredEnabled.value) {
        posts.clear();
        isLoading.value = true;
      } else {
        followingPosts.clear();
        isFollowingLoading.value = true;
      }

      Network.searchPosts(
              searchText: searchController.text,
              following: staggeredEnabled.value ? "0" : "1")
          .then((value) async {
        if (value != null) {
          if (staggeredEnabled.value) {
            await value
                .map((doc) => posts.add(PostInspirationModel.fromJson(doc)))
                .toList();
            isLoading.value = false;
          } else {
            await value
                .map((doc) => followingPosts.add(PostInspirationModel.fromJson(doc)))
                .toList();
            isFollowingLoading.value = false;
          }

          isSearchEnabled = true;
        }
      });
    } else {
      getPosts();
      isSearchEnabled = false;
    }
    FocusScope.of(WebService.homeScaffoldKey.currentContext!).unfocus();
  }

  //refresh post after like
  Future refreshPosts() async {
    followingPosts.removeRange(0, followingPosts.length);
    await Network.getPostsApi(
            style: selectStyle, start: "", limit: "", following: "1")
        .then((value) async {
      if (value != false) {
        await value
            .map((doc) => followingPosts.add(PostInspirationModel.fromJson(doc)))
            .toList();
      }
    });
    followingPosts.refresh();
  }
}
