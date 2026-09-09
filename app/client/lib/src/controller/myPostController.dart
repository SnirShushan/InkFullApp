import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/data/model/post_inspiration_model.dart';
import 'package:ink/src/data/model/user_artist_model.dart';
import 'package:ink/src/data/source/network/firebase_api.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/webService.dart';

class MyPostsController extends GetxController {
  //set post model
  RxList<PostInspirationModel> tattoo = <PostInspirationModel>[].obs;
  RxList<PostInspirationModel> sketch = <PostInspirationModel>[].obs;
  RxList<UserArtistModel> userArtistList = <UserArtistModel>[].obs;
  RxList<UserArtistModel> userStudioList = <UserArtistModel>[].obs;
  RxBool shouldRefresh = false.obs;
  bool isLoading = false;
  RxString followersUser = "0".obs;
  RxList<String> stylesHe = <String>[].obs;
  RxInt selectedIndex = 0.obs;
  RxBool isDataLoading = false.obs;
  RxBool isSketchsubscription = false.obs;
  RxBool isDrawingsubscription = false.obs;

  //For Pagination

  RxInt startPost = 0.obs;
  int _limitPost = 15;
  final scrollControllerMyPosts = ScrollController();
  RxBool hasMorePosts = true.obs;
  RxBool hasMorePostsLoading = false.obs;

  @override
  void onInit() {
    startPost = 0.obs;
    super.onInit();
    scrollControllerMyPosts.addListener(requestListener);
  }

  void requestListener() {
    if (scrollControllerMyPosts.position.maxScrollExtent ==
        scrollControllerMyPosts.offset) {
      if (hasMorePosts.value && !hasMorePostsLoading.value) {
        getMyPostsScroll();
      }
    }
  }

  Future<void> getMyPostsScroll() async {
    if (startPost.value == 0) {
      return getMyPosts();
    }

    if (!hasMorePosts.value) return;

    hasMorePostsLoading.value = true;

    try {
      final value = await Network.getMyPostsApi(startPost.value, _limitPost);

      if (value == null || value == false) {
        hasMorePosts.value = false;
        return;
      }

      final newTattoList = List.from(value["tatto"] ?? []);
      final newSketchList = List.from(value["sketch"] ?? []);

      tattoo.addAll(
          newTattoList.map((doc) => PostInspirationModel.fromJson(doc)));
      sketch.addAll(
          newSketchList.map((doc) => PostInspirationModel.fromJson(doc)));

      if (newTattoList.length < _limitPost &&
          newSketchList.length < _limitPost) {
        hasMorePosts.value = false;
      } else {
        startPost += _limitPost;
      }
    } catch (e) {
      hasMorePosts.value = false;
    } finally {
      tattoo.refresh();
      sketch.refresh();
      hasMorePostsLoading.value = false;
    }
  }

  Future getMyPosts() async {
    if (isLoading) return;
    isLoading = true;
    isDataLoading.value = true;
    hasMorePosts.value = true;

    startPost.value = 0;
    tattoo.clear();
    sketch.clear();
    stylesHe.clear();
    userArtistList.clear();
    userStudioList.clear();
    followersUser.value = "";

    try {
      await Network.getMyPostsApi(startPost.value, _limitPost)
          .then((value) async {
        if (value == null || value == false || value is! Map) {
          return;
        }
        final rawTatto = value['tatto'];
        final rawSketch = value['sketch'];
        final newTattooList = rawTatto is List
            ? rawTatto
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
            : <Map<String, dynamic>>[];
        final newSketchList = rawSketch is List
            ? rawSketch
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
            : <Map<String, dynamic>>[];
        tattoo.addAll(newTattooList.map(PostInspirationModel.fromJson));
        sketch.addAll(newSketchList.map(PostInspirationModel.fromJson));

        if (tattoo.length < _limitPost && sketch.length < _limitPost) {
          hasMorePosts.value = false;
        } else {
          startPost.value += _limitPost;
        }

        await Network.getUserApi().then((valueUser) async {
          if (valueUser == false) return;
          if (valueUser['followers'] != null) {
            final followers = valueUser['followers'].toString();
            WebService.followUsers = followers;
            followersUser.value = followers;
          }
          final styles = valueUser['profile']?['styles_he'];
          if (styles is List && styles.isNotEmpty) {
            stylesHe.addAll(styles.map((e) => e.toString()));
          }

          final artistList = valueUser['artist'];
          if (artistList is List && artistList.isNotEmpty) {
            userArtistList.addAll(artistList.whereType<Map>().map(
                (doc) => UserArtistModel.fromJson(
                    Map<String, dynamic>.from(doc))));
          }

          final studioList = valueUser['studio'];
          if (studioList is List && studioList.isNotEmpty) {
            userStudioList.addAll(studioList.whereType<Map>().map(
                (doc) => UserArtistModel.fromJson(
                    Map<String, dynamic>.from(doc))));
          }
        });
      });
    } catch (e) {
      isLoading = false;
      isDataLoading.value = false;

      displayMessageIcon(
          message: e.toString(),
          snackposition: SnackPosition.BOTTOM,
          color: errorColor,
          imageData: AppAssets.errorIcon);
    } finally {
      tattoo.refresh();
      sketch.refresh();
      userArtistList.refresh();
      userStudioList.refresh();
      stylesHe.refresh();
      isLoading = false;
      isDataLoading.value = false;
    }
  }

  //remove post
  Future removePostController({pid, imageId, baseUrl}) async {
    try {
      await Network.removePostApi(postId: pid).then((value) async {
        await FireBaseApi.deletestorageImage(imageUrl: baseUrl);

        try {
          await FirebaseFirestore.instance
              .collection("images")
              .doc(imageId)
              .delete();
        } on FirebaseException catch (e) {
          print('Error deleting image record from database: $e');
        }
        await FireBaseApi.removeImageFromFolderImages(pid: pid);
        await FireBaseApi().removeImageFromFolders(imageUrl: baseUrl);
      });
      return;
    } catch (e) {
      displayMessageIcon(
          message: e.toString(),
          snackposition: SnackPosition.BOTTOM,
          color: errorColor,
          imageData: AppAssets.errorIcon);
    }
  }
}
