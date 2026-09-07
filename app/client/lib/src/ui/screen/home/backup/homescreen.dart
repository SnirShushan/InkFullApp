// import 'dart:async';
//
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/ui/screen/home/widgets/following_post_widget.dart';
// import 'package:ink/src/ui/screen/home/widgets/post_widget.dart';
// import 'package:ink/src/utils/webService.dart';
//
// import '../../../controller/post_controller.dart';
// import '../../../utils/colors.dart';
// import '../../../utils/common.dart';
// import '../../widgets/unfocus_widget.dart';
// import 'widgets/CustomMasonry.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen>
//     with TickerProviderStateMixin, WidgetsBindingObserver {
//   String currentStyleIndex = "0";
//   late Timer _timer;
//   int getFollowingPostsCount = 0;
//   List<String> folderIdList = [];
//   bool isAllSelected = true;
//
//   //controllers
//   late final TextEditingController fNameController = TextEditingController();
//   late final PostController postController;
//   final DynamicLinkService _dynamicLinkService = DynamicLinkService();
//
//   @override
//   void initState() {
//     super.initState();
//     postController = Get.put(PostController());
//     folderIdList = WebService.folderList.map((e) => e.imageId).toList();
//     WidgetsBinding.instance.addObserver(this);
//     init();
//   }
//
//   init() async => await postController.retry();
//   selectedTextStyle() => const TextStyle(
//       decoration: TextDecoration.underline, color: Colors.blueAccent);
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _timer = Timer(
//         const Duration(milliseconds: 1000),
//         () {
//           _dynamicLinkService.retrieveDynamicLink(context);
//         },
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     if (_timer.isActive) {
//       _timer.cancel();
//     }
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final double tabBarPadding = size.height * 0.01;
//     return UnFocusWidget(
//         child: Scaffold(
//             key: WebService.homeScaffoldKey,
//             appBar: buildHomeAppbar(size, tabBarPadding),
//             bottomSheet: buildHomeBottomSheet(size),
//             body: Obx(() => !postController.isInternetAvailable.value
//                 ? widgetNoInternet(postController.retry)
//                 : IndexedStack(
//                     index: postController.staggeredEnabled.value ? 0 : 1,
//                     children: [
//                         //home screen post
//                         postController.isLoading.value
//                             ? const Center(child: CircularProgressIndicator())
//                             : postController.posts.isEmpty //if no data
//                                 ? (postController.isSearchEnabled
//                                     ? showSearchNotFound()
//                                     : const Center(
//                                         child: Text("אין כרגע תוכן להציג כאן")))
//                                 : SingleChildScrollView(
//                                     controller: postController.scrollController,
//                                     child: CustomMasonry(
//                                       numberOfColumn: 2,
//                                       listOfItem: postController.posts,
//                                       key: UniqueKey(),
//                                       itemBuilder: (index) {
//                                         return PostWidget(
//                                             key: ValueKey(index),
//                                             postModel: index);
//                                       },
//                                     )),
//                         //following users posts
//                         postController.isFollowingLoading.value
//                             ? showProgressWidget()
//                             : postController.followingPosts.isEmpty
//                                 ? const Center(
//                                     child: Text("אין כרגע תוכן להציג כאן"))
//                                 : ListView.builder(
//                                     controller: postController
//                                         .followingScrollController,
//                                     shrinkWrap: true,
//                                     itemCount:
//                                         postController.followingPosts.length,
//                                     itemBuilder: (context, index) {
//                                       return FollowingPostWidget(
//                                           key: PageStorageKey(index),
//                                           postModel: postController
//                                               .followingPosts[index],
//                                           fNameController: fNameController,
//                                           folderIdList: folderIdList);
//                                     })
//                       ]))));
//   }
//
//   //appbar
//   buildHomeAppbar(Size size, double tabBarPadding) => AppBar(
//       toolbarHeight: (size.height * 0.12) + tabBarPadding,
//       backgroundColor: Colors.white,
//       title: SizedBox(
//           height: size.height * 0.05,
//           width: size.width * 0.7,
//           //search
//           child: TextFormField(
//               textAlignVertical: TextAlignVertical.center,
//               controller: postController.searchController,
//               onEditingComplete: postController.searchPost,
//               autofocus: false,
//               textInputAction: TextInputAction.search,
//               decoration: InputDecoration(
//                   contentPadding: const EdgeInsets.all(10.0),
//                   filled: true,
//                   focusColor: defaultWhite,
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(15),
//                       borderSide: const BorderSide(color: Colors.black)),
//                   suffixIcon: InkWell(
//                       child: const Icon(Icons.clear),
//                       onTap: () => postController.searchController.clear()),
//                   prefixIcon: InkWell(
//                       onTap: postController.searchPost,
//                       child: const Icon(Icons.search))
//                   // hintText: 'Search artist, genre, playlist',
//                   ))),
//       actions: [
//         InkWell(
//           onTap: () => postController.scrollDown(),
//           child: SizedBox(
//               child: Image.asset("assets/images/logo_black_ink_alef.png",
//                   fit: BoxFit.fitHeight)),
//         )
//       ],
//       bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(30.0),
//           child: Obx(() => SizedBox(
//               width: Get.size.width,
//               height: Get.size.height * 0.04,
//               child: ListView.builder(
//                   shrinkWrap: true,
//                   scrollDirection: Axis.horizontal,
//                   itemCount:
//                       postController.userController.style_list.value.length + 1,
//                   itemBuilder: (context, index) {
//                     if (index == 0) {
//                       return SizedBox(
//                           width: size.width * 0.12,
//                           child: GestureDetector(
//                               onTap: () async {
//                                 setState(() {
//                                   isAllSelected = true;
//                                 });
//                                 postController.selectStyle = "";
//                                 if (postController.staggeredEnabled.value) {
//                                   await postController.getPosts();
//                                 } else {
//                                   postController.followingPosts.clear();
//                                   await postController.getFollowingPosts();
//                                 }
//                               },
//                               child: Text("   הכל   ",
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .titleSmall!
//                                       .copyWith(
//                                           color: !isAllSelected
//                                               ? Colors.grey
//                                               : Colors.black))));
//                     } else {
//                       var data =
//                           postController.userController.style_list[index - 1];
//                       return GestureDetector(
//                           onTap: () async {
//                             isAllSelected = false;
//                             setState(() {
//                               currentStyleIndex = data.id!.toString();
//                             });
//                             postController.selectStyle = data.slug!;
//                             if (postController.staggeredEnabled.value) {
//                               await postController.getPosts();
//                             } else {
//                               postController.followingPosts.clear();
//                               await postController.getFollowingPosts();
//                             }
//                           },
//                           child: Text(" |  ${data.name.toString()}  ",
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .titleSmall!
//                                   .copyWith(
//                                       color: (currentStyleIndex == data.id &&
//                                               isAllSelected == false)
//                                           ? Colors.black
//                                           : Colors.grey)));
//                     }
//                   })))));
//
//   //bottomSheet for two tabs
//   buildHomeBottomSheet(Size size) => Container(
//       color: Colors.transparent,
//       alignment: Alignment.center,
//       width: size.width,
//       height: size.height * 0.07,
//       child: Container(
//           decoration: BoxDecoration(
//               color: Colors.white, borderRadius: BorderRadius.circular(30)),
//           alignment: Alignment.center,
//           width: size.width * 0.6,
//           height: size.height * 0.05,
//           child: IntrinsicHeight(
//               child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                 GestureDetector(
//                     onTap: () => setState(() {
//                           postController.staggeredEnabled.value = true;
//                         }),
//                     child: SizedBox(
//                         child: Text(
//                             // userController.userType.value == "2"? "סגנון אישי":
//                             "כולם",
//                             textAlign: TextAlign.center,
//                             style: postController.staggeredEnabled.value
//                                 ? selectedTextStyle()
//                                 : const TextStyle()))),
//                 const VerticalDivider(thickness: 3, width: 3),
//                 GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         postController.staggeredEnabled.value = false;
//                         getFollowingPostsCount = 1;
//                       });
//                     },
//                     child: SizedBox(
//                       child: Text(
//                           // userController.userType.value == "2"? "סטודיו/מקעקעים":
//                           "במעקב",
//                           textAlign: TextAlign.center,
//                           style: !postController.staggeredEnabled.value
//                               ? selectedTextStyle()
//                               : const TextStyle()),
//                     ))
//               ]))));
//
//   //progressbar
//   showProgressWidget() => const Center(child: CircularProgressIndicator());
//
//   //search not found text
//   showSearchNotFound() => Center(
//       child: Text("home.noSearchFound",
//               style: Theme.of(context)
//                   .textTheme
//                   .titleMedium
//                   ?.copyWith(fontWeight: FontWeight.bold, color: Colors.red))
//           .tr());
//
//   //old search not found
//   /*showSearchNotFound() => SizedBox(
//       width: Get.width,
//       child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
//         Padding(
//           padding: const EdgeInsets.only(top: 20.0),
//           child: Text("home.noSearchFound",
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold, color: Colors.red))
//               .tr(),
//         ),
//         Text(
//             " כדאי לנסות: ${userController.style_list.value[0]..name} ${userController.style_list.value[1].name}")
//       ]));*/
// }
