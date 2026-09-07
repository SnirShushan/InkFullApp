// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/controller/StartupController.dart';
// import 'package:ink/src/controller/post_controller.dart';
// import 'package:ink/src/controller/userController.dart';
// import 'package:ink/src/data/model/post_model_backup.dart';
// import 'package:ink/src/utils/webService.dart';
//
// class HomeController extends GetxController{
//   RxBool staggeredEnabled = false.obs;
//   var posts = <PostModel>[].obs;
//   var followingPosts = <PostModel>[].obs;
//   RxBool isLoading = true.obs;
//   RxBool isAllSelected = true.obs;
//   RxList<PostModel> searchedList = <PostModel>[].obs;
//   final TextEditingController searchController = TextEditingController();
//   bool isSearchEnabled = false;
//   bool isLikeLoading = false;
//   RxBool isInternetAvailable = false.obs;
//
//   final UserController userController = Get.put(UserController());
//   late final StartupController startupController = Get.put(StartupController());
//
//   //getting app data
//   Future initUser() async => await userController.initUser();
//   Future<bool> checkInternet() async => await WebService.checkConnection();
//
//   //retry or init method
//   retry() async {
//     try {
//       await checkInternet().then((value) async {
//         if (value == true) {
//           isInternetAvailable.value = true;
//           await initUser().then((value1) async =>
//           await StartupController().getStartupImage()
//               .then((value2) async => await PostController().getPosts()));
//         } else {
//           isInternetAvailable.value = false;
//         }
//       });
//           update();
//     }catch(e){
//       print("retry");
//       print(e.toString());
//       throw e;
//     }
//   }
//
// }
