// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/data/model/currentUser.dart';
// import 'package:ink/src/data/model/post_inspiration_model.dart';
// import 'package:ink/src/data/source/network/user_api.dart';
// import 'package:ink/src/utils/webService.dart';
//
// import 'backup_random_pagination.dart';
//
// class InspirationController extends GetxController {
//   RxList<PostInspirationModel> postsInspiration = <PostInspirationModel>[].obs;
//   RxBool isLoading = false.obs;
//   RxBool isPostApiLoading = false.obs;
//   final searchController = TextEditingController();
//   final scrollControllerPosts = ScrollController();
//   RxList<StylesList> styleList = <StylesList>[].obs;
//   RxList<StylesList>? selectedStyles = <StylesList>[].obs;
//   RxString isselected = "מומלצים עבורכם".obs;
//   RxBool isStyleEnabled = false.obs;
//   RxInt startInspiration = 0.obs;
//   int limitInspiration = 10;
//   RxBool isRecommanded = true.obs;
//   RxBool isNew = false.obs;
//   RxBool isMostViewed = false.obs;
//   RxBool hasMoreInspirationn = true.obs;
//   RandomPagination? pagination;
//
//   //Random Pagination
//   RxBool isRandomPagination = true.obs;
//   RxBool isRandomAutoLoad = true.obs;
//
//   final List<String> options = [
//     "מומלצים עבורכם",
//     "החדשים ביותר",
//     "הנצפים ביותר"
//   ];
//
//   @override
//   Future<void> onInit() async {
//     startInspiration = 0.obs;
//     selectedStyles?.clear();
//     isRecommanded = true.obs;
//     isNew = false.obs;
//     isMostViewed = false.obs;
//     searchController.text = "";
//     postsInspiration.clear();
//     AppUser user = await WebService.getCurrentUser();
//     styleList.clear();
//     user.stylesList!.map((e) => styleList.add(e)).toList();
//     _initialized();
//
//     searchController.addListener(_searchListener);
//     scrollControllerPosts.addListener(requestListener);
//   }
//
//   void _initialized() async {
//     try {
//       pagination = RandomPagination(
//           totalPosts: int.parse(WebService.randomPagination ?? "0"),
//           limit: limitInspiration);
//     } catch (e) {
//       debugPrint("error ins ${e.toString()}");
//     } finally {
//       getInspirationController();
//     }
//   }
//
//   _searchListener() {
//     if (searchController.text.length > 3) {
//       postsInspiration.clear();
//       getInspirationController();
//     }
//
//     if (searchController.text.isEmpty) {
//       postsInspiration.clear();
//       getInspirationController();
//     }
//   }
//
//   //scroll Pagination
//   requestListener() {
//     if (scrollControllerPosts.position.maxScrollExtent ==
//         scrollControllerPosts.offset) {
//       if (!isRandomPagination.value || selectedStyles!.isNotEmpty) {
//         if (hasMoreInspirationn.value && !isPostApiLoading.value) {
//
//           getInspirationController(isMoreLoad: true);
//         }
//       } else {
//         if (isRandomPagination.value) {
//           isRandomAutoLoad.value = true;
//           getInspirationController(isMoreLoad: true,);
//         }
//       }
//     }
//   }
//
//   resetData() {
//     selectedStyles!.clear();
//     startInspiration = 0.obs;
//     postsInspiration!.clear();
//
//     isStyleEnabled.value = false;
//     print("WebService.randomPagination ${WebService.randomPagination}");
//     pagination = RandomPagination(
//         totalPosts: int.parse(WebService.randomPagination ?? "0"), limit: 10);
//     pagination!.reset();
//     getInspirationController();
//   }
//
//   Future<void> getInspirationController(
//       {bool isMoreLoad = false, bool isRefresh = false}) async {
//     if (isPostApiLoading.value || isLoading.value) return;
//     isLoading.value = true;
//     if (isMoreLoad) isPostApiLoading.value = true;
//     try {
//       if (isRefresh) {
//         startInspiration.value = 0;
//         postsInspiration.clear();
//         selectedStyles?.clear();
//         hasMoreInspirationn.value = true;
//       }
//       String styles = "";
//
//
//       if (WebService.selectstylelist.isNotEmpty) {
//         selectedStyles!.clear();
//         await Future.wait(styleList.map((element) {
//           if (WebService.selectstylelist.any((e) => e.slug == element.slug)) {
//             selectStyle(element);
//           }
//           return Future.value();
//         }));
//       }
//
//       styles += selectedStyles?.map((e) => e.slug).join(',') ?? '';
//
//       final searchText = searchController.text.trim();
//       final isNewFlag = isNew.value ? "1" : "";
//       final isRecommendedFlag = isRecommanded.value ? "1" : "";
//       final isMostViewedFlag = isMostViewed.value ? "1" : "";
//
//       int? randomStart;
//       try{
//         if (isRandomPagination.value && styles == "") {
//           randomStart = pagination!.getUniqueRandomStart();
//           if (randomStart == null) {
//             return;
//           }
//         }
//       }catch(e){
//         pagination = RandomPagination(
//             totalPosts: int.parse(WebService.randomPagination ?? "0"),
//             limit: limitInspiration);
//         if(WebService.randomPagination !=null){
//           if (isRandomPagination.value && styles == "") {
//             randomStart = pagination!.getUniqueRandomStart();
//             if (randomStart == null) {
//               return;
//             }
//           }
//         }else{
//           randomStart=0;
//         }
//       }
//
//       final response = await Network.getInspirationPostsApi(
//         style: styles,
//         start: isRandomPagination.value
//             ? styles != ""
//             ? startInspiration.value
//             : randomStart.toString() ?? "10"
//             : startInspiration.value,
//         limit: limitInspiration,
//         searchTxt: searchText,
//         isNew: isNewFlag,
//         isRecommended: isRecommendedFlag,
//         mostView: isMostViewedFlag,
//         following: "0",
//       );
//
//       if (response != false && response is List) {
//         final newPosts = response
//             .cast<Map<String, dynamic>>()
//             .map(PostInspirationModel.fromJson)
//             .where((post) => !postsInspiration.any((p) => p.id == post.id))
//             .toList();
//
//         postsInspiration.addAll(newPosts);
//
//         WebService.selectstylelist.clear();
//         postsInspiration.refresh();
//         selectedStyles?.refresh();
//
//         if (!isRandomPagination.value || selectedStyles!.isNotEmpty) {
//           hasMoreInspirationn.value = newPosts.length >= limitInspiration;
//           if (hasMoreInspirationn.value) {
//             startInspiration.value += limitInspiration;
//           }
//         } else {
//           if (isRandomPagination.value) {
//             final isNewPostsLessThanLimit = newPosts.length < 10;
//             final isSameRandomStart =
//                 WebService.lastRandomPagination == randomStart.toString();
//             final isInspirationListShort = postsInspiration.length < 10;
//
//             if (isNewPostsLessThanLimit &&
//                 isSameRandomStart &&
//                 isInspirationListShort) {
//               isLoading.value = false;
//               isPostApiLoading.value = false;
//               getInspirationController();
//             }
//           }
//         }
//       }
//     } catch (e) {
//       isLoading.value = false;
//       isPostApiLoading.value = false;
//
//       debugPrint('Error fetching inspiration posts: $e');
//     } finally {
//       isLoading.value = false;
//       isPostApiLoading.value = false;
//
//
//
//       if (isRandomPagination.value && isRandomAutoLoad.value) {
//         if (postsInspiration.length < num.parse(WebService.randomPagination)) {
//           isRandomAutoLoad.value = false;
//
//           getInspirationController();
//         } else {
//           isRandomAutoLoad.value = false;
//         }
//       }
//     }
//   }
//
//   selectStyle(StylesList style) {
//     if (selectedStyles!.isEmpty) {
//       selectedStyles?.add(style);
//     } else {
//       if (selectedStyles!.contains(style)) {
//         selectedStyles?.remove(style);
//       } else {
//         selectedStyles?.add(style);
//       }
//     }
//     if (selectedStyles!.isNotEmpty) {
//       isStyleEnabled.value = true;
//     } else {
//       isStyleEnabled.value = false;
//     }
//     selectedStyles?.refresh();
//   }
//
//   void sortingsData({required BuildContext context, required String option}) {
//     postsInspiration.clear();
//     startInspiration = 0.obs;
//     if (option == "החדשים ביותר") {
//       if (isNew.value == false) {
//         isRandomAutoLoad.value = false;
//         pagination!.reset();
//         isRandomPagination.value = false;
//         isRecommanded.value = false;
//         isNew.value = true;
//         isMostViewed.value = false;
//         isselected.value = option;
//         getInspirationController();
//         Navigator.of(context).pop();
//       }
//     } else if (option == "הנצפים ביותר") {
//       if (isMostViewed.value == false) {
//         isRandomAutoLoad.value = false;
//         pagination!.reset();
//         isRandomPagination.value = false;
//         isRecommanded.value = false;
//         isNew.value = false;
//         isMostViewed.value = true;
//         isselected.value = option;
//         getInspirationController();
//         Navigator.of(context).pop();
//       }
//     } else {
//       if (isRecommanded.value == false) {
//         pagination!.reset();
//         isRandomPagination.value = true;
//         isRecommanded.value = true;
//         isNew.value = false;
//         isMostViewed.value = false;
//         isselected.value = option;
//         getInspirationController();
//         Navigator.of(context).pop();
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     isRandomAutoLoad.value = false;
//     searchController.clear();
//     isRecommanded.value = false;
//     isNew.value = false;
//     isMostViewed.value = false;
//     searchController.text = "";
//     styleList.clear();
//     super.dispose();
//   }
// }
//
// enum sortings { isRecommanded, newUsers, mostviewed }
//
// class SortOption {
//   final int id;
//   final String name;
//   final sortings type;
//   bool? isSelected;
//
//   SortOption(
//       {required this.id,
//         required this.name,
//         required this.type,
//         this.isSelected = false});
// }
