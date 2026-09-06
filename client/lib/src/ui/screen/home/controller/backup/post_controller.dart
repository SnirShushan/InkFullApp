// import 'package:get/get.dart';
// import 'package:ink/src/data/model/post_model_backup.dart';
// import 'package:ink/src/data/source/network/user_api.dart';
// import 'package:ink/src/utils/webService.dart';
//
// class PostController extends GetxController {
//   //staggered
//   RxBool staggeredEnabled = true.obs;
//   //set post model
//   var posts = <PostModel>[].obs;
//   var followingPosts = <PostModel>[].obs;
//   RxBool isLoading = true.obs;
//   RxBool isAllSelected = true.obs;
//   RxList<PostModel> searchedList = <PostModel>[].obs;
//   final searchController = TextEditingController();
//   bool isSearchEnabled = false;
//   bool isLikeLoading = false;
//   //load more post
//   final ScrollController scrollController = ScrollController();
//   final ScrollController followingScrollController = ScrollController();
//   //start limit
//   int start = 0;
//   int limit = 10;
//   //following posts
//   RxBool isFollowingLoading = false.obs;
//   int followingStart = 0;
//   int followingLimit = 10;
//   //style
//   String selectStyle = "";
//
//   @override
//   void onInit() {
//     posts.clear();
//     followingPosts.clear();
//     super.onInit();
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     searchController.dispose();
//   }
//
//    void toggleView({required bool isEnable}){
//     staggeredEnabled.value = isEnable;
//     update();
//   }
//
//   //scroll
//   void scrollDown() {
//     if (staggeredEnabled.value) {
//       scrollController.animateTo(
//         scrollController.position.minScrollExtent,
//         duration: const Duration(seconds: 2),
//         curve: Curves.fastOutSlowIn,
//       );
//     } else {
//       followingScrollController.animateTo(
//         followingScrollController.position.minScrollExtent,
//         duration: const Duration(seconds: 2),
//         curve: Curves.fastOutSlowIn,
//       );
//     }
//   }
//
//   //get posts
//   Future getPosts() async {
//     posts.clear();
//     isLoading.value = true;
//     if (selectStyle != "") {
//       isAllSelected.value = false;
//     }
//     await Network.getPosts(
//             style: selectStyle, start: "", limit: "", following: "0")
//         .then((value) async {
//       if (value != false) {
//         await value.map((doc) => posts.add(PostModel.fromJson(doc))).toList();
//       }
//       isLoading.value = false;
//     });
//     isSearchEnabled = false;
//     // start += 10;
//   }
//
//   //get following  posts
//   Future getFollowingPosts() async {
//     // if (isFollowingLoading) return;
//     isFollowingLoading.value = true;
//     if (selectStyle != "") {
//       isAllSelected.value = false;
//     }
//     await Network.getPosts(
//             style: selectStyle, start: "", limit: "", following: "1")
//         .then((value) async {
//       if (value != false) {
//         await value
//             .map((doc) => followingPosts.add(PostModel.fromJson(doc)))
//             .toList();
//         followingStart += 10;
//       }
//     });
//     isFollowingLoading.value = false;
//     isSearchEnabled = false;
//   }
//
//   //follow user
//   Future followPostUser({fid, likeStatus}) async {
//     isLikeLoading = true;
//     isFollowingLoading.value = true;
//     await Network.followUser(fid: fid, likeStatus: likeStatus);
//     await refreshPosts();
//     isLikeLoading = false;
//     isFollowingLoading.value = false;
//   }
//
//   //search text
//   void searchPost() {
//     if (searchController.text.isNotEmpty) {
//       if (staggeredEnabled.value) {
//         posts.clear();
//         isLoading.value = true;
//       } else {
//         followingPosts.clear();
//         isFollowingLoading.value = true;
//       }
//
//       Network.searchPosts(
//               searchText: searchController.text,
//               following: staggeredEnabled.value ? "0" : "1")
//           .then((value) async {
//         if (value != null) {
//           if (staggeredEnabled.value) {
//             await value
//                 .map((doc) => posts.add(PostModel.fromJson(doc)))
//                 .toList();
//             isLoading.value = false;
//           } else {
//             await value
//                 .map((doc) => followingPosts.add(PostModel.fromJson(doc)))
//                 .toList();
//             isFollowingLoading.value = false;
//           }
//
//           isSearchEnabled = true;
//         }
//       });
//     } else {
//       getPosts();
//       isSearchEnabled = false;
//     }
//     FocusScope.of(WebService.homeScaffoldKey.currentContext!).unfocus();
//   }
//
//   //refresh post after like
//   Future refreshPosts() async {
//     followingPosts.removeRange(0, followingPosts.length);
//     await Network.getPosts(
//             style: selectStyle, start: "", limit: "", following: "1")
//         .then((value) async {
//       if (value != false) {
//         await value
//             .map((doc) => followingPosts.add(PostModel.fromJson(doc)))
//             .toList();
//       }
//     });
//     followingPosts.refresh();
//   }
// }
