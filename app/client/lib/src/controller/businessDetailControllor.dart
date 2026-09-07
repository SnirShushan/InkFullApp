import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/data/model/post_inspiration_model.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/webService.dart';

import '../data/model/ArtistModel.dart';
import '../data/source/network/user_api.dart';
import '../utils/common.dart';

class BusinessDetailController extends GetxController {
  //set post model
  var tattoo = <PostInspirationModel>[].obs;
  var sketch = <PostInspirationModel>[].obs;

  RxString id = "".obs;
  RxString name = "".obs;
  RxString email = "".obs;
  RxString phone = "".obs;
  RxString cnt_code = "".obs;
  RxString lang = "".obs;
  RxString profile_image = "".obs;
  RxString login_token = "".obs;

  RxString business_type = "".obs;
  RxString user_type = "".obs;
  RxString login_type = "".obs;
  RxString address = "".obs;
  RxString address_lat = "".obs;
  RxString address_lng = "".obs;
  RxString address_place_id = "".obs;
  RxString about_text = "".obs;
  RxString liked = "".obs;
  RxString followers = "".obs;
  RxList<Artist> artistsList = <Artist>[].obs;
  RxList<Artist> studiosList = <Artist>[].obs;
  RxBool isLoading = false.obs;
  RxBool animationLoading = false.obs;

  RxList<String> stylesHe = <String>[].obs;
  RxString idProfile = "".obs;
  RxString userTypeProfile = "".obs;
  Rx<AppUser>? appUser;
  RxString _businessId = "".obs;

  //For Pagination
  final scrollControllerSketches = ScrollController();
  final scrollControllerTattos = ScrollController();
  RxInt startSketches = 0.obs;
  int _limitSketches = 15;
  RxInt startTattos = 0.obs;
  int _limitTattos = 15;
  RxBool hasMoreSketches = true.obs;
  RxBool hasMoreSketchesLoading = false.obs;
  RxBool hasMoreTattos = true.obs;
  RxBool hasMoreTattosLoading = false.obs;

  @override
  void onInit() {
    startSketches = 0.obs;

    startTattos = 0.obs;
    super.onInit();
    scrollControllerSketches.addListener(requestListenerSketches);
    scrollControllerTattos.addListener(requestListenerTattoo);
  }

  requestListenerSketches() {
    final atBottom = scrollControllerSketches.position.maxScrollExtent ==
        scrollControllerSketches.offset;

    if (!atBottom || !hasMoreSketches.value || hasMoreSketchesLoading.value) {
      hasMoreSketchesLoading.value = false;
      return;
    }
    if (_businessId.isNotEmpty) {
      hasMoreSketchesLoading.value = true;
      getSketchListController();
    } else {
      hasMoreSketchesLoading.value = false;
    }
  }

  requestListenerTattoo() {
    final atBottom = scrollControllerTattos.position.maxScrollExtent ==
        scrollControllerTattos.offset;

    if (!atBottom || !hasMoreTattos.value || hasMoreTattosLoading.value) {
      hasMoreTattosLoading.value = false;
      return;
    }
    if (_businessId.isNotEmpty) {
      print("businesss_id_true");
      hasMoreTattosLoading.value = true;
      getTattooListController();
    } else {
      print("businesss_id_fasle");
      hasMoreTattosLoading.value = false;
    }
    print("businesss_id_true");
  }

  //get business details
  Future getBusinessInfo({required String bid}) async {
    _businessId.value = bid;
    startSketches.value = 0;
    startTattos.value = 0;
    isLoading.value = true;
    try {
      if (stylesHe.isNotEmpty) stylesHe.clear();
      if (artistsList.isNotEmpty) artistsList.clear();
      if (studiosList.isNotEmpty) studiosList.clear();
      if (tattoo.isNotEmpty) tattoo.clear();
      if (sketch.isNotEmpty) sketch.clear();

      await Network.getBusinessDetails(bid).then((responseData) async {
        if (responseData != false && responseData != null) {
          isLoading.value = false;
          var data = responseData["detail"];
          if (data == null) {
            isLoading.value = false;
            return;
          }

          String s(dynamic v) => v == null ? "" : v.toString();

          id.value = s(data["id"]);
          name.value = s(data["name"]);
          email.value = s(data["email"]);
          phone.value = s(data["phone"]);
          address.value = s(data["address"]);
          about_text.value = s(data["about_text"]);
          address_lat.value = s(data["address_lat"]);
          address_lng.value = s(data["address_lng"]);
          user_type.value = s(data["user_type"]);
          business_type.value = s(data["business_type"]);
          profile_image.value =
              WebService.resolveImageUrl(s(data["profile_image"]));
          liked.value = s(data["liked"]);
          followers.value = s(data["followers"]);

          final stylesRaw = data['styles_he'];
          if (stylesRaw is List) {
            stylesHe.addAll(stylesRaw.map((e) => e.toString()));
          }

          if (data['artist'] is List) {
            artistsList.addAll(
                (data['artist'] as List).map((v) => Artist.fromJson(v)));
          }
          if (data['studio'] is List) {
            studiosList.addAll(
                (data['studio'] as List).map((v) => Artist.fromJson(v)));
          }

          final posts = data["posts"];
          final sketchList =
              posts is Map ? List.from(posts["sketch"] ?? []) : <dynamic>[];
          final tattoList =
              posts is Map ? List.from(posts["tatto"] ?? []) : <dynamic>[];

          sketch.addAll(
              sketchList.map((v) => PostInspirationModel.fromJson(v)));
          tattoo
              .addAll(tattoList.map((v) => PostInspirationModel.fromJson(v)));

          if (sketchList.isEmpty || sketchList.length < _limitSketches) {
            hasMoreSketches.value = false;
          } else {
            startSketches += _limitSketches;
          }

          if (tattoList.isEmpty || tattoList.length < _limitTattos) {
            hasMoreTattos.value = false;
          } else {
            startTattos += _limitTattos;
          }

          AppUser user = await WebService.getCurrentUser();
          userTypeProfile.value = user.profile!.userType!.toString();
          idProfile.value = user.profile!.id.toString();
          isLoading.value = false;
          tattoo.refresh();
          sketch.refresh();
          stylesHe.refresh();
          artistsList.refresh();
          studiosList.refresh();
        } else {
          isLoading.value = false;
        }
      });
    } catch (e) {
      print("errorerrorerrorerrorerrorerrorerror $e");
      isLoading.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future getSketchListController() async {
    hasMoreSketchesLoading.value = true;
    try {
      await Network.getSketchListApi(
              _businessId.value, startSketches, _limitSketches)
          .then((responseData) async {
        if (responseData != false && responseData != null) {
          final List _newListSketches = List.from(responseData["sketch"]);
          if (_newListSketches.isEmpty ||
              _newListSketches.length < _limitSketches) {
            hasMoreSketches.value = false;
          } else {
            startSketches += _limitSketches;
          }

          for (var doc in _newListSketches) {
            final post = PostInspirationModel.fromJson(doc);
            if (!sketch.any((p) => p.id == post.id)) sketch.add(post);
          }
          sketch.refresh();
        } else {
          hasMoreSketchesLoading.value = false;
        }
      });
    } catch (e) {
      hasMoreSketchesLoading.value = false;
    } finally {
      hasMoreSketchesLoading.value = false;
    }
  }

  Future getTattooListController() async {
    try {
      await Network.getTattooListApi(
              _businessId.value, startTattos, _limitTattos)
          .then((responseData) async {
        if (responseData != false && responseData != null) {
          var data = responseData;

          final List _newListTattos = List.from(data["tatto"]);
          if (_newListTattos.isEmpty || _newListTattos.length < _limitTattos) {
            hasMoreTattos.value = false;
          } else {
            startTattos += _limitTattos;
          }

          for (var doc in _newListTattos) {
            final post = PostInspirationModel.fromJson(doc);
            if (!tattoo.any((p) => p.id == post.id)) {
              print("post ${post.id}");
              tattoo.add(post);
            }
          }

          hasMoreTattosLoading.value = false;
        } else {
          hasMoreTattosLoading.value = false;
        }
      });
    } catch (e) {
      hasMoreTattosLoading.value = false;
    } finally {
      tattoo.refresh();
      hasMoreTattosLoading.value = false;
    }
  }

  //follow user
  Future followUser({bid, likeStatus}) async {
    // final postDetailsController = Get.put(PostDetailsController());
    await Network.followUser(fid: bid, likeStatus: likeStatus).then((value) {
      if (value != false) {
        followers.value = value["followers"];
      }
    });
    liked.value = likeStatus;
    // await getBusinessInfo(bid: bid).then((value) async =>
    //     await postDetailsController.getPostDetails(
    //         pid: postDetailsController.postModel.value.id!));
  }

  //report Business
  Future reportBusiness({bid, required String comment}) async {
    await Network.reportBusiness(bid: bid, comment: comment).then((value) {
      final msg = value["msg"].toString();

      Get.back();
      animationLoading.value = false;
      displayMessageIcon(
          snackposition: SnackPosition.BOTTOM,
          message: msg,
          color: successGreen,
          imageData: AppAssets.correct_transparentIcon);
    });
  }
}
