// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/controller/post_controller.dart';
// import 'package:ink/src/utils/webService.dart';
//
// import 'widgets/CustomMasonry.dart';
// import 'widgets/following_post_widget.dart';
// import 'widgets/post_widget.dart';
//
// class PostListWidget extends StatelessWidget {
//   final PostController postController;
//   final bool isStaggeredEnabled;
//   PostListWidget(
//       {super.key,
//       required this.isStaggeredEnabled,
//       required this.postController});
//
//   final TextEditingController fNameController = TextEditingController();
//   List<String> folderIdList =
//       WebService.folderList.map((e) => e.imageId).toList();
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(() => IndexedStack(index: isStaggeredEnabled ? 0 : 1, children: [
//           //home screen post
//           postController.isLoading.value
//               ? const Center(child: CircularProgressIndicator())
//               : postController.posts.value.isEmpty //if no data
//                   ? (postController.isSearchEnabled
//                       ? showSearchNotFound(context)
//                       : const Center(child: Text("אין כרגע תוכן להציג כאן")))
//                   : SingleChildScrollView(
//                       controller: postController.scrollController,
//                       child: CustomMasonry(
//                         numberOfColumn: 2,
//                         listOfItem: postController.posts.value,
//                         itemBuilder: (index) {
//                           return PostWidget(postModel: index);
//                         },
//                       )),
//           //following users posts
//           postController.isFollowingLoading.value
//               ? showProgressWidget()
//               : postController.followingPosts.isEmpty
//                   ? const Center(child: Text("אין כרגע תוכן להציג כאן"))
//                   : ListView.builder(
//                       controller: postController.followingScrollController,
//                       shrinkWrap: true,
//                       itemCount: postController.followingPosts.length,
//                       itemBuilder: (context, index) {
//                         return FollowingPostWidget(
//                             key: PageStorageKey(index),
//                             postModel: postController.followingPosts[index],
//                             fNameController: fNameController,
//                             folderIdList: folderIdList);
//                       })
//         ]));
//   }
//
//   //progressbar
//   showProgressWidget() => const Center(child: CircularProgressIndicator());
//
//   //search not found text
//   showSearchNotFound(BuildContext context) => Center(
//       child: Text("home.noSearchFound",
//               style: Theme.of(context)
//                   .textTheme
//                   .titleMedium
//                   ?.copyWith(fontWeight: FontWeight.bold, color: Colors.red))
//           .tr());
// }
