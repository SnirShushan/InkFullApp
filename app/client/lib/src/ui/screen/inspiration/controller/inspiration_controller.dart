import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/data/model/post_inspiration_model.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/utils/webService.dart';

import 'random_pagination.dart';

class InspirationController extends GetxController {
  RxList<PostInspirationModel> postsInspiration = <PostInspirationModel>[].obs;
  RxBool isLoading = false.obs;
  RxBool isPostApiLoading = false.obs;
  final searchController = TextEditingController();
  final scrollControllerPosts = ScrollController();
  RxList<StylesList> styleList = <StylesList>[].obs;
  RxList<StylesList>? selectedStyles = <StylesList>[].obs;
  RxString isselected = "מומלצים עבורכם".obs;
  RxBool isStyleEnabled = false.obs;
  RxInt startInspiration = 0.obs;
  int limitInspiration = 20;
  RxBool isRecommanded = true.obs;
  RxBool isNew = false.obs;
  RxBool isMostViewed = false.obs;
  RxBool hasMoreInspirationn = true.obs;
  RandomPagination? pagination;
  String styles = "";
  //Random Pagination
  RxBool isRandomPagination = true.obs;
  RxBool isRandomAutoLoad = true.obs;

  final List<String> options = [
    "מומלצים עבורכם",
    "החדשים ביותר",
    "הנצפים ביותר"
  ];

  @override
  Future<void> onInit() async {
    styles="";
    startInspiration = 0.obs;
    selectedStyles?.clear();
    isRecommanded = true.obs;
    isNew = false.obs;
    isMostViewed = false.obs;
    searchController.text = "";
    postsInspiration.clear();
    AppUser user = await WebService.getCurrentUser();
    styleList.clear();
    user.stylesList!.map((e) => styleList.add(e)).toList();
    _initialized();

    searchController.addListener(_searchListener);
    scrollControllerPosts.addListener(requestListener);
  }

  void _initialized() async {
    try {
      final total = int.tryParse(WebService.randomPagination.toString()) ?? 0;
      pagination = RandomPagination(
          totalPosts: total <= 0 ? 100 : total, limit: limitInspiration);
    } catch (e) {
      debugPrint("error ins ${e.toString()}");
      pagination = RandomPagination(totalPosts: 100, limit: limitInspiration);
    } finally {
      getInspirationController();
    }
  }

  _searchListener() {
    if (searchController.text.length > 3) {
      postsInspiration.clear();
      getInspirationController();
    }

    if (searchController.text.isEmpty) {
      postsInspiration.clear();
      getInspirationController();
    }
  }

  //scroll Pagination
  requestListener() {

    if (scrollControllerPosts.position.maxScrollExtent ==
        scrollControllerPosts.offset) {
      if (!isRandomPagination.value || selectedStyles!.isNotEmpty ||  searchController.text.toString().trim().isNotEmpty) {
        if (hasMoreInspirationn.value && !isPostApiLoading.value) {
          isRandomAutoLoad.value = false;
          getInspirationController(isMoreLoad: true);
        }
      } else {
        // print("isRandomPagination.value ${isRandomPagination.value}");
        // print(postsInspiration.length);
        // print(WebService.randomPagination);
        // print(pagination!.isCurrentGroupFinished);

        if (isRandomPagination.value) {
          isRandomAutoLoad.value = true;
          if(postsInspiration.length < num.parse(WebService.randomPagination)-5){
            if (pagination!.isCurrentGroupFinished==true) {
              getInspirationController(isMoreLoad: true,);
            }
          }
        }
      }
    }
  }

  resetData() {
    selectedStyles!.clear();
    startInspiration = 0.obs;
    postsInspiration!.clear();
    styles="";
    isStyleEnabled.value = false;
    isRandomAutoLoad.value=false;
    searchController.text="";
    pagination = RandomPagination(
        totalPosts: int.parse(WebService.randomPagination ?? "0"), limit: limitInspiration);
    pagination!.reset();
    getInspirationController();
  }

  Future<void> getInspirationController(
      {bool isMoreLoad = false, bool isRefresh = false}) async {
    styles="";
    if (isPostApiLoading.value || isLoading.value) return;
    isLoading.value = true;
    if (isMoreLoad) isPostApiLoading.value = true;
    try {
      if (isRefresh) {
        startInspiration.value = 0;
        postsInspiration.clear();
        selectedStyles?.clear();
        hasMoreInspirationn.value = true;
      }

      if (WebService.selectstylelist.isNotEmpty) {
        selectedStyles!.clear();
        await Future.wait(styleList.map((element) {
          if (WebService.selectstylelist.any((e) => e.slug == element.slug)) {
            selectStyle(element);
          }
          return Future.value();
        }));
      }

      styles += selectedStyles?.map((e) => e.slug).join(',') ?? '';

      final searchText = searchController.text.trim();
      final isNewFlag = isNew.value ? "1" : "";
      final isRecommendedFlag = isRecommanded.value ? "1" : "";
      final isMostViewedFlag = isMostViewed.value ? "1" : "";

      int? randomStart;
      try{
        if (isRandomPagination.value && styles == "") {
          isRandomAutoLoad.value = true;
          randomStart = pagination!.getUniqueRandomStart();
          if (randomStart == null) {
            return;
          }
        }else{
          isRandomAutoLoad.value = false;
        }
      }catch(e){
        pagination = RandomPagination(
            totalPosts: int.parse(WebService.randomPagination ?? "0"),
            limit: limitInspiration);
        if(WebService.randomPagination !=null){
          if (isRandomPagination.value && styles == "") {
            isRandomAutoLoad.value = true;
            randomStart = pagination!.getUniqueRandomStart();
            if (randomStart == null) {
              return;
            }
          }else{
            isRandomAutoLoad.value = false;
          }
        }else{
          randomStart=0;
        }
      }

     String tempStyleName= removeRepeatedPattern(styles);
      final response = await Network.getInspirationPostsApi(
        style: tempStyleName,
        start: isRandomPagination.value && styles.isEmpty && searchController.text.toString().trim().isEmpty
            ? randomStart.toString() ?? "0"
            : startInspiration.value,
        limit: limitInspiration,
        searchTxt: searchText,
        isNew: isNewFlag,
        isRecommended: isRecommendedFlag,
        mostView: isMostViewedFlag,
        following: "0",
      );
      WebService.selectstylelist.clear();
      if (response != false && response is List) {
        final newPosts = response
            .cast<Map<String, dynamic>>()
            .map(PostInspirationModel.fromJson)
            .where((post) => !postsInspiration.any((p) => p.id == post.id))
            .toList();

        postsInspiration.addAll(newPosts);


        postsInspiration.refresh();
        selectedStyles?.refresh();

        if (!isRandomPagination.value || selectedStyles!.isNotEmpty) {
          hasMoreInspirationn.value = newPosts.length >= limitInspiration;
          if (hasMoreInspirationn.value) {
            startInspiration.value += limitInspiration;
          }
        } else {
          if (isRandomPagination.value) {
            final isNewPostsLessThanLimit = newPosts.length < 10;
            final isSameRandomStart =
                WebService.lastRandomPagination == randomStart.toString();
            final isInspirationListShort = postsInspiration.length < 10;

            if (isNewPostsLessThanLimit &&
                isSameRandomStart &&
                isInspirationListShort) {
              isLoading.value = false;
              isPostApiLoading.value = false;
              getInspirationController();
            }
          }
        }
      }
    } catch (e) {
      isLoading.value = false;
      isPostApiLoading.value = false;

      debugPrint('Error fetching inspiration posts: $e');
    } finally {
      isLoading.value = false;
      isPostApiLoading.value = false;

      if (isRandomAutoLoad.value &&
          styles == "" &&
          searchController.text.toString().trim().isEmpty) {
        if (pagination != null && !pagination!.isCurrentGroupFinished) {
          isRandomAutoLoad.value = true;
          getInspirationController(isMoreLoad: true);
        }
      } else {
        isRandomAutoLoad.value = false;
      }

    }
  }

  selectStyle(StylesList style) {
    if (selectedStyles!.isEmpty) {
      selectedStyles?.add(style);
    } else {
      if (selectedStyles!.contains(style)) {
        selectedStyles?.remove(style);
      } else {
        selectedStyles?.add(style);
      }
    }
    if (selectedStyles!.isNotEmpty) {
      isStyleEnabled.value = true;
    } else {
      isStyleEnabled.value = false;
    }
    selectedStyles?.refresh();

    print("selectedStyles ${selectedStyles}");
    print(jsonEncode(selectedStyles));
  }

  void sortingsData({required BuildContext context, required String option}) {
    postsInspiration.clear();
    startInspiration = 0.obs;
    if (option == "החדשים ביותר") {
      if (isNew.value == false) {
        isRandomAutoLoad.value = false;
        pagination!.reset();
        isRandomPagination.value = false;
        isRecommanded.value = false;
        isNew.value = true;
        isMostViewed.value = false;
        isselected.value = option;
        getInspirationController();
        Navigator.of(context).pop();
      }
    } else if (option == "הנצפים ביותר") {
      if (isMostViewed.value == false) {
        isRandomAutoLoad.value = false;
        pagination!.reset();
        isRandomPagination.value = false;
        isRecommanded.value = false;
        isNew.value = false;
        isMostViewed.value = true;
        isselected.value = option;
        getInspirationController();
        Navigator.of(context).pop();
      }
    } else {
      if (isRecommanded.value == false) {
        pagination!.reset();
        isRandomPagination.value = true;
        isRecommanded.value = true;
        isNew.value = false;
        isMostViewed.value = false;
        isselected.value = option;
        getInspirationController();
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    isRandomAutoLoad.value = false;
    searchController.clear();
    isRecommanded.value = false;
    isNew.value = false;
    isMostViewed.value = false;
    searchController.text = "";
    styleList.clear();
    super.dispose();
  }

  String removeRepeatedPattern(String input) {
    // Regex: ^(.+?)\1+$ means
    //  - (.+?) capture the smallest repeating group
    //  - \1+ means the same group repeats one or more times
    final regExp = RegExp(r'^(.+?)\1+$');
    final match = regExp.firstMatch(input);

    // If match found, return only the first group (the true name)
    return match != null ? match.group(1)! : input;
  }
}

enum sortings { isRecommanded, newUsers, mostviewed }

class SortOption {
  final int id;
  final String name;
  final sortings type;
  bool? isSelected;

  SortOption(
      {required this.id,
        required this.name,
        required this.type,
        this.isSelected = false});
}
