// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/ui/screen/home/post_list_widget.dart';
// import 'package:ink/src/utils/DynamicLinkService.dart';
//
// import '../../../controller/post_controller.dart';
// import '../../../utils/colors.dart';
// import '../../../utils/common.dart';
// import '../../widgets/unfocus_widget.dart';
//
// class HomeScreen extends StatefulWidget {
//   HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
//   final DynamicLinkService _dynamicLinkService = DynamicLinkService();
//   final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
//   Timer? _timer;
//
//   @override
//   void initState() {
//     WidgetsBinding.instance.addObserver(this);
//     super.initState();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _timer = Timer(
//         const Duration(milliseconds: 100),
//         () {
//           _dynamicLinkService.retrieveDynamicLink(context);
//         },
//       );
//     }
//     if (state == AppLifecycleState.paused) {
//       if (_timer != null) {
//         if (_timer!.isActive) {
//           _timer!.cancel();
//         }
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//
//     if (_timer != null) {
//       if (_timer!.isActive) {
//         _timer!.cancel();
//       }
//     }
//     super.dispose();
//   }
//
//   final PostController postController = Get.put(PostController());
//
//   selectedTextStyle() => const TextStyle(
//       decoration: TextDecoration.underline, color: Colors.blueAccent);
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final double tabBarPadding = size.height * 0.01;
//     return UnFocusWidget(
//         child: Obx(() => Scaffold(
//             key: _key,
//             appBar: buildHomeAppbar(size, tabBarPadding),
//             bottomSheet: buildHomeBottomSheet(size),
//             body: !postController.isInternetAvailable.value
//                 ? widgetNoInternet(postController.retry)
//                 : PostListWidget(
//                     postController: postController,
//                     isStaggeredEnabled:
//                         postController.staggeredEnabled.value))));
//   }
//
//   //progressbar
//   showProgressWidget() => const Center(child: CircularProgressIndicator());
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
//         ),
//       ],
//       bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(30.0),
//           child: SizedBox(
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
//                           child: Obx(() => GestureDetector(
//                               onTap: () async {
//                                 postController.isAllSelected.value = true;
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
//                                           color: !postController
//                                                   .isAllSelected.value
//                                               // color: false
//                                               ? Colors.grey
//                                               : Colors.black)))));
//                     } else {
//                       var data =
//                           postController.userController.style_list[index - 1];
//                       return Obx(() => GestureDetector(
//                           onTap: () async {
//                             postController.currentStyleIndex.value =
//                                 data.id!.toString();
//
//                             print(
//                                 "postController.currentStyleIndex.value ${postController.currentStyleIndex.value}");
//                             print(data.id!.toString());
//
//                             postController.isAllSelected.value = false;
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
//                                       color: (postController.currentStyleIndex
//                                                       .value ==
//                                                   data.id!.toString() &&
//                                               postController
//                                                       .isAllSelected.value ==
//                                                   false)
//                                           // color:false
//                                           ? Colors.black
//                                           : Colors.grey))));
//                     }
//                   }))));
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
//                     onTap: () => postController.toggleView(isEnable: true),
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
//                     onTap: () => postController.toggleView(isEnable: false),
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
// }
