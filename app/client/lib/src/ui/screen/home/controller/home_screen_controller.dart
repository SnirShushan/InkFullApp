import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/data/model/home_model.dart';
import 'package:ink/src/data/model/post_inspiration_model.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/utils/webService.dart';

class HomeScreenController extends GetxController {
  RxList<TattosInStyle> tattosInStyle = <TattosInStyle>[].obs;
  RxList<NewUserList> newUserLists = <NewUserList>[].obs;
  RxList<Business> businessList = <Business>[].obs;

  RxString isNewNotification = "".obs;
  final ScrollController scrollController = ScrollController();
  final ScrollController userscrollControllerRequest = ScrollController();
  int startUsers = 0;
  int limitUsers = 6;

  RxBool hasMoreUsers = true.obs;
  bool isPostApiLoading = false;
  String getPostsIds = "";

  // RxBool hasMoreHomePostLimit = true.obs;
  bool isApiLoading = false;
  RxString stylename = "".obs;
  RxString stylenameheb = "".obs;
  RxString totalpostcount = "0".obs;

  RxBool isTattoStyleEmpty = false.obs;
  RxBool isHasMoreEmpty = false.obs;

  // RxList<String> styleNames = <String>[].obs;
  // RxList<String> styleNamesHeb = <String>[].obs;
  RxMap<String, List<PostInspirationModel>> stylePosts =
      <String, List<PostInspirationModel>>{}.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    startUsers = 0;
    hasMoreUsers.value = true;
    getPostsIds = "";
    isTattoStyleEmpty.value = false;
    isHasMoreEmpty.value = false;
    userscrollControllerRequest.addListener(requestNewUserListener);

    // Load when splash requests it, or when we have a session but empty home
    // (common after OTP login while an old empty controller is still registered).
    if (WebService.isSplashHomeScreen) {
      getHomeController();
    } else {
      final token = await WebService.getUserToken();
      if (token != null &&
          token.isNotEmpty &&
          tattosInStyle.isEmpty &&
          businessList.isEmpty) {
        getHomeController();
      }
    }
  }

  /// Firebase Storage URLs are unreachable on offline/local emulator runs.
  String _localizeImageUrl(String? url) => WebService.resolveImageUrl(url);

  Future<void> getHomeController() async {
    if (isApiLoading) return;
    isApiLoading = true;

    try {
      // Reset state
      startUsers = 0;
      isTattoStyleEmpty.value = false;
      hasMoreUsers.value = true;
      isHasMoreEmpty.value = true;

      // Clear old lists
      tattosInStyle.clear();
      newUserLists.clear();
      businessList.clear();

      // Fetch home sections + post grids in parallel (biggest home latency win)
      final homeFuture = Network.getHomeApi(startUsers, limitUsers);
      final postsFuture = Network.getHomePostsNewApi(
        start: 0,
        limit: 6,
        isRandom: 1,
        postIds: "",
      );

      final response = await homeFuture;
      if (response == null || response == false) {
        await postsFuture; // still settle
        return;
      }

      // Update notification state
      isNewNotification.value = response['is_new_notification'] ?? "";

      // Parse lists
      tattosInStyle.addAll(
        (response['tattos_in_style'] as List<dynamic>?)
                ?.map((doc) {
                  final item = TattosInStyle.fromJson(doc);
                  item.imageName = _localizeImageUrl(item.imageName);
                  return item;
                })
                .toList() ??
            [],
      );
      newUserLists.addAll(
        (response['new_user_list'] as List<dynamic>?)
                ?.map((doc) => NewUserList.fromJson(doc))
                .toList() ??
            [],
      );
      businessList.addAll(
        (response['business'] as List<dynamic>?)
                ?.map((doc) {
                  final item = Business.fromJson(doc);
                  if (item.businessimg != null) {
                    for (final img in item.businessimg!) {
                      img.imageUrl = _localizeImageUrl(img.imageUrl);
                    }
                  }
                  return item;
                })
                .toList() ??
            [],
      );

      // Refresh lists so UI can paint while posts finish
      tattosInStyle.refresh();
      newUserLists.refresh();
      businessList.refresh();

      final values = await postsFuture;
      await _applyHomePosts(values);
    } catch (e, s) {
      print("❌ Error in getHomeController: $e");
      print(s);
    } finally {
      isTattoStyleEmpty.value = tattosInStyle.isEmpty;
      hasMoreUsers.value = newUserLists.length >= limitUsers;
      if (hasMoreUsers.value) startUsers += limitUsers;
      isApiLoading = false;
    }
  }

  Future<void> _applyHomePosts(dynamic values) async {
    if (values == false || values == null) {
      stylePosts.isEmpty
          ? isHasMoreEmpty.value = true
          : isHasMoreEmpty.value = false;
      return;
    }
    try {
      stylePosts.clear();
      totalpostcount.value = values["total_post_count"]?.toString() ?? "0";
      final data = values["posts"] as Map<String, dynamic>? ?? {};
      data.forEach((styleKey, listData) {
        final list = (listData as List<dynamic>?)
                ?.map((doc) {
                  final post = PostInspirationModel.fromJson(doc);
                  post.imageName = _localizeImageUrl(post.imageName);
                  return post;
                })
                .toList() ??
            [];
        stylePosts[styleKey] = list;
      });
      stylePosts.refresh();
    } finally {
      stylePosts.isEmpty
          ? isHasMoreEmpty.value = true
          : isHasMoreEmpty.value = false;
    }
  }

  Future<void> getNewUserLimit() async {
    if (isApiLoading) return;
    isApiLoading = true;
    try {
      await Network.getHomeApi(startUsers, limitUsers).then((response) async {
        if (response != false && response != null) {
          await response['new_user_list']
              .map((doc) => newUserLists.add(NewUserList.fromJson(doc)))
              .toList();
          final List newList = List.from(response['new_user_list']);

          if (response['new_user_list'].toString() == "[]" ||
              response['new_user_list'] == []) {
            hasMoreUsers.value = false;
          } else if (newList.length < limitUsers) {
            hasMoreUsers.value = false;
          } else {
            startUsers += 6;
          }
          newUserLists.refresh();
        } else {
          hasMoreUsers.value = false;
          isApiLoading = false;
        }
      });
    } catch (e) {
      isApiLoading = false;
    } finally {
      isApiLoading = false;
    }
  }

  Future<void> getPostsList() async {
    if (isPostApiLoading) return;
    isPostApiLoading = true;

    try {
      stylePosts.clear();
      final values = await Network.getHomePostsNewApi(
        start: 0,
        limit: 6,
        isRandom: 1,
        // styles: styleNames.join(","),
        postIds: "",
      );
      if (values != false) {
        totalpostcount.value = values["total_post_count"]?.toString() ?? "0";

        // ---- new parsing for multi-style structure ----
        final data = values["posts"] as Map<String, dynamic>? ?? {};

        // iterate over each style key ("re", "ab", "cc")
        data.forEach((styleKey, listData) {
          final list = (listData as List<dynamic>?)
                  ?.map((doc) {
                    final post = PostInspirationModel.fromJson(doc);
                    post.imageName = _localizeImageUrl(post.imageName);
                    return post;
                  })
                  .toList() ??
              [];
          stylePosts[styleKey] = list;
        });

        // ---- refresh observable map ----
        stylePosts.refresh();
      }
    } catch (e) {
      isApiLoading = false;
      isPostApiLoading = false;
    } finally {
      // if (posts.length >= num.parse(totalpostcount.value)) {
      //   hasMoreHomePostLimit.value = false;
      // }
      stylePosts.isEmpty
          ? isHasMoreEmpty.value = true
          : isHasMoreEmpty.value = false;
      isApiLoading = false;
      isPostApiLoading = false;
    }
  }

  getRandomIndex(List<StylesList> stylesList) {
    final random = Random();
    return random.nextInt(stylesList.length);
  }

  @override
  void dispose() {
    userscrollControllerRequest.dispose();
    super.dispose();
  }

  void requestNewUserListener() {
    if (userscrollControllerRequest.position.maxScrollExtent ==
        userscrollControllerRequest.offset) {
      if (hasMoreUsers.value == true) {
        getNewUserLimit();
      }
    }
  }
}
