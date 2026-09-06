// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/data/model/currentUser.dart';
// import 'package:ink/src/ui/screen/business_user/dashboard/business_dashboard.dart';
// import 'package:ink/src/ui/screen/business_user/dashboard/bussinessdashboard_binding.dart';
// import 'package:ink/src/ui/screen/home/imageDetails/post_details.dart';
// import 'package:ink/src/ui/screen/profile/businessStudioProfile.dart';
// import 'package:ink/src/ui/screen/profile/businessUserProfile.dart';
// import 'package:ink/src/utils/webService.dart';
//
// class DynamicLinkService {
//   static const String businessUserProfileLink =
//       "https://itapp2u.com/apps/Inkapp/api/profile/businessUserProfile";
//   static const String businessStudioProfileLink =
//       "https://itapp2u.com/apps/Inkapp/api/profile/businessStudioProfile";
//   static const String mainprofileLink =
//       "https://itapp2u.com/apps/Inkapp/api/profile/mainprofile";
//
//   static const String businessUserProfileLink2 =
//       "https://inkisrael.co.il/api/profile/businessUserProfile";
//   static const String businessStudioProfileLink2 =
//       "https://inkisrael.co.il/api/profile/businessStudioProfile";
//   static const String mainprofileLink2 =
//       "https://inkisrael.co.il/api/profile/mainprofile";
//
//   Future<void> retrieveDynamicLink(BuildContext context) async {
//     FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
//     dynamicLinks.onLink.listen((dynamicLinkData) async {
//       final Uri uri = dynamicLinkData.link;
//       if (uri != null) {
//         try {
//           String link = uri.toString();
//           print("linklinklink $link");
//           String checklink = await extractBaseUrl(link);
//           String user_dynamic_id =
//               await extractLastSlashValue(dynamicLinkData!.link.toString());
//           print("checklink $checklink");
//           if (checklink == mainprofileLink || checklink == mainprofileLink2) {
//             AppUser user = await WebService.getCurrentUser();
//             print(user.profile!.id.toString());
//             if (user.profile!.id.toString() == user_dynamic_id) {
//               final isBusiness = await WebService.getIsBusiness();
//               if (isBusiness == false) {
//                 Get.to(() => BusinessProfileScreen(
//                     bId: user_dynamic_id, fromPost: true));
//               } else {
//                 Get.offAll(
//                     () => BusinessDashBoard(
//                           initialIndex: 4,
//                         ),
//                     binding: BusinessDashBoardBinding());
//               }
//             } else {
//               Get.to(() =>
//                   BusinessProfileScreen(bId: user_dynamic_id, fromPost: true));
//             }
//           } else if (checklink == businessUserProfileLink ||
//               checklink == businessUserProfileLink2) {
//             Get.to(() =>
//                 BusinessProfileScreen(bId: user_dynamic_id, fromPost: true));
//           } else if (checklink == businessStudioProfileLink ||
//               checklink == businessStudioProfileLink2) {
//             Get.to(() =>
//                 StudioProfileScreen(bId: user_dynamic_id, fromPost: true));
//           } else {
//             Get.to(() => PostDetails(
//                 dynamictxt: "DYNAMICTEXT",
//                 postId: user_dynamic_id,
//                 isArtist: false));
//           }
//         } catch (e) {
//           String user_dynamic_id =
//               await extractLastSlashValue(dynamicLinkData!.link.toString());
//           Get.to(() => PostDetails(
//               dynamictxt: "DYNAMICTEXT",
//               postId: user_dynamic_id,
//               isArtist: false));
//         }
//       }
//     });
//   }
//
//   String extractBaseUrl(String url) {
//     Uri uri = Uri.parse(url);
//     return '${uri.scheme}://${uri.host}${uri.path.split('/').take(6).join('/')}';
//   }
//
//   String extractLastSlashValue(String url) {
//     final parts = url.split('/');
//     return parts.last;
//   }
// }
//
// // class DynamicLinkService {
// //   Future<void> retrieveDynamicLink(BuildContext context) async {
// //     FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
// //     dynamicLinks.onLink.listen((dynamicLinkData) {
// //       final Uri uri = dynamicLinkData.link;
// //       if (uri != null) {
// //         String str = uri
// //             .toString()
// //             .replaceAll("https://itapp2u.com/apps/Inkapp/api/", "");
// //         print("DeepLink Data" + uri.toString());
// //         Get.to(() => PostDetails(
// //             dynamictxt: "DYNAMICTEXT", postId: str, isArtist: false));
// //       }
// //     });
// //   }
// // }
