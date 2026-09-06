// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/data/model/currentUser.dart';
// import 'package:ink/src/data/model/home_model.dart';
// import 'package:ink/src/data/model/post_inspiration_model.dart';
// import 'package:ink/src/data/source/network/user_api.dart';
// import 'package:ink/src/utils/webService.dart';
//
// class HomeScreenController extends GetxController {
//   RxList<TattosInStyle> tattosInStyle = <TattosInStyle>[].obs;
//   RxList<NewUserList> newUserLists = <NewUserList>[].obs;
//   RxList<Business> businessList = <Business>[].obs;
//   RxList<PostInspirationModel> posts = <PostInspirationModel>[].obs;
//   RxString isNewNotification = "".obs;
//   final ScrollController scrollController = ScrollController();
//   final ScrollController userscrollControllerRequest = ScrollController();
//   int startUsers = 0;
//   int limitUsers = 6;
//
//   RxBool hasMoreUsers = true.obs;
//   bool isPostApiLoading = false;
//   String getPostsIds = "";
//
//   // RxBool hasMoreHomePostLimit = true.obs;
//   bool isApiLoading = false;
//   RxString stylename = "".obs;
//   RxString stylenameheb = "".obs;
//   RxString totalpostcount = "0".obs;
//   List<StylesList> selectHomestylelist = [];
//   RxBool isTattoStyleEmpty = false.obs;
//   RxBool isHasMoreEmpty = false.obs;
//
//   //3 style Used:
//   RxList<String> styleNames = <String>[].obs; // For style slugs
//   RxList<String> styleNamesHeb = <String>[].obs; // For Hebrew or display names
//   List<StylesList> selectedHomeStyleList = [];
//
//   @override
//   Future<void> onInit() async {
//     super.onInit();
//     startUsers = 0;
//     hasMoreUsers.value = true;
//     getPostsIds = "";
//     isTattoStyleEmpty.value = false;
//     isHasMoreEmpty.value = false;
//     userscrollControllerRequest.addListener(requestNewUserListener);
//
//     if (WebService.isSplashHomeScreen) {
//       getHomeController();
//     }
//   }
//
//   Future<void> getHomeController() async {
//     if (isApiLoading) return;
//     isApiLoading = true;
//
//     try {
//       // Reset state efficiently
//       startUsers = 0;
//       isTattoStyleEmpty.value = false;
//       hasMoreUsers.value = true;
//       isHasMoreEmpty.value = true;
//       // Clear all lists efficiently
//       tattosInStyle.clear();
//       newUserLists.clear();
//       businessList.clear();
//
//       final response = await Network.getHomeApi(startUsers, limitUsers);
//       if (response == null || response == false) return;
//
//       // Update notification state
//       isNewNotification.value = response['is_new_notification'] ?? "";
//
//       // Process tattoos in style
//       tattosInStyle.addAll(
//         (response['tattos_in_style'] as List<dynamic>?)
//                 ?.map((doc) => TattosInStyle.fromJson(doc)) ??
//             [],
//       );
//
//       // Process new user list
//       newUserLists.addAll(
//         (response['new_user_list'] as List<dynamic>?)
//                 ?.map((doc) => NewUserList.fromJson(doc)) ??
//             [],
//       );
//
//       // Process business list
//       businessList.addAll(
//         (response['business'] as List<dynamic>?)
//                 ?.map((doc) => Business.fromJson(doc)) ??
//             [],
//       );
//
//       // Update UI once for all lists
//       tattosInStyle.refresh();
//       newUserLists.refresh();
//       businessList.refresh();
//
//       // Fetch user and select style
//       final user = await WebService.getCurrentUser();
//       final stylesList = user.stylesList ?? [];
//       if (stylesList.isEmpty) return;
//
//       final selectedList = user.profile?.styles?.isNotEmpty == true
//           ? stylesList
//               .where((style) => user.profile!.styles!.contains(style.slug!))
//               .toList()
//           : stylesList;
//       if (selectedList.isEmpty) return;
//       final randomIndex = await getRandomIndex(selectedList);
//       final selectedStyle = selectedList[randomIndex];
//
//       stylename.value = selectedStyle.slug ?? "";
//       stylenameheb.value = selectedStyle.name ?? "";
//       selectHomestylelist = [selectedStyle];
//
//       // Load posts
//       posts.clear();
//       await getPostsList();
//     } catch (e) {
//       print("Error in getHomeController: $e");
//     } finally {
//       tattosInStyle.isEmpty
//           ? isTattoStyleEmpty.value = true
//           : isTattoStyleEmpty.value = false;
//       hasMoreUsers.value = newUserLists.length >= limitUsers;
//       if (hasMoreUsers.value) startUsers += limitUsers;
//       isApiLoading = false;
//     }
//   }
//
//
//   Future<void> getNewUserLimit() async {
//     if (isApiLoading) return;
//     isApiLoading = true;
//     try {
//       await Network.getHomeApi(startUsers, limitUsers).then((response) async {
//         if (response != false && response != null) {
//           await response['new_user_list']
//               .map((doc) => newUserLists.add(NewUserList.fromJson(doc)))
//               .toList();
//           final List newList = List.from(response['new_user_list']);
//
//           if (response['new_user_list'].toString() == "[]" ||
//               response['new_user_list'] == []) {
//             hasMoreUsers.value = false;
//           } else if (newList.length < limitUsers) {
//             hasMoreUsers.value = false;
//           } else {
//             startUsers += 6;
//           }
//           newUserLists.refresh();
//         } else {
//           hasMoreUsers.value = false;
//           isApiLoading = false;
//         }
//       });
//     } catch (e) {
//       isApiLoading = false;
//     } finally {
//       isApiLoading = false;
//     }
//   }
//
//   Future<void> getPostsList() async {
//     if (isPostApiLoading || stylename.value.isEmpty) return;
//     isPostApiLoading = true;
//     try {
//       final values = await Network.getHomePostsApi(
//         start: 0,
//         limit: 6,
//         isRandom: 1,
//         styles: stylename.value,
//         postIds: "",
//       );
//
//       if (values == null || values == false) return;
//
//       totalpostcount.value = values["total_post_count"]?.toString() ?? "0";
//       posts.addAll(
//         (values["posts"] as List<dynamic>?)
//                 ?.map((doc) => PostInspirationModel.fromJson(doc)) ??
//             [],
//       );
//       getPostsIds = posts.map((doc) => doc.id).join(",");
//
//       posts.refresh();
//     } catch (e) {
//       isApiLoading = false;
//       isPostApiLoading = false;
//       print("Error in getPostsList: $e");
//     } finally {
//       // if (posts.length >= num.parse(totalpostcount.value)) {
//       //   hasMoreHomePostLimit.value = false;
//       // }
//       posts.isEmpty
//           ? isHasMoreEmpty.value = true
//           : isHasMoreEmpty.value = false;
//       isApiLoading = false;
//       isPostApiLoading = false;
//     }
//   }
//
//   getRandomIndex(List<StylesList> stylesList) {
//     final random = Random();
//     return random.nextInt(stylesList.length);
//   }
//
//   @override
//   void dispose() {
//     userscrollControllerRequest.dispose();
//     super.dispose();
//   }
//
//   void requestNewUserListener() {
//     if (userscrollControllerRequest.position.maxScrollExtent ==
//         userscrollControllerRequest.offset) {
//       if (hasMoreUsers.value == true) {
//         getNewUserLimit();
//       }
//     }
//   }
// }
