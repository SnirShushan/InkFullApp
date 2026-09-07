import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/business_dashboard.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/bussinessdashboard_binding.dart';
import 'package:ink/src/ui/screen/home/homescreen.dart';
import 'package:ink/src/ui/screen/home/imageDetails/post_details.dart';
import 'package:ink/src/ui/screen/profile/businessStudioProfile.dart';
import 'package:ink/src/ui/screen/profile/businessUserProfile.dart';
import 'package:ink/src/utils/webService.dart';

class DynamicLinkService {
  // static const String businessUserProfileLink =
  //     "https://itapp2u.com/apps/Inkapp/api/profile/businessUserProfile";
  // static const String businessStudioProfileLink =
  //     "https://itapp2u.com/apps/Inkapp/api/profile/businessStudioProfile";
  // static const String mainprofileLink =
  //     "https://itapp2u.com/apps/Inkapp/api/profile/mainprofile";
  //
  // static const String businessUserProfileLink2 =
  //     "https://inkisrael.co.il/api/profile/businessUserProfile";
  // static const String businessStudioProfileLink2 =
  //     "https://inkisrael.co.il/api/profile/businessStudioProfile";
  // static const String mainprofileLink2 =
  //     "https://inkisrael.co.il/api/profile/mainprofile";

  Future<void> retrieveDynamicLink(BuildContext context) async {
    FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
    dynamicLinks.onLink.listen((dynamicLinkData) async {
      final Uri uri = dynamicLinkData.link;
      String action = "";
      String userDynamicId = "";
      if (uri != null) {
        try {
          String link = uri.toString();
          final Uri parsedUri = Uri.parse(link);

          action = parsedUri.queryParameters['action'] ?? "";
          userDynamicId = parsedUri.queryParameters['pid'] ?? "";

          if (action == null && userDynamicId == null) {
            // Safety fallback
            Get.offAll(() => HomeScreen());
            return;
          }
          print("action $action");
          switch (action) {

            case 'mainprofile':

              AppUser user = await WebService.getCurrentUser();

              final bool isBusiness = await WebService.getIsBusiness();
              print(user.profile!.id.toString());
              if (user.profile!.id.toString() == userDynamicId) {
                if (!isBusiness) {
                  Get.to(() => BusinessProfileScreen(
                        bId: userDynamicId,
                        fromPost: true,
                      ));
                } else {
                  Get.offAll(
                    () => BusinessDashBoard(initialIndex: 4),
                    binding: BusinessDashBoardBinding(),
                  );
                }
              } else {
                Get.to(() => BusinessProfileScreen(
                      bId: userDynamicId,
                      fromPost: true,
                    ));
              }
              break;

            case 'businessUserProfile':
              Get.to(() => BusinessProfileScreen(
                    bId: userDynamicId,
                    fromPost: true,
                  ));
              break;

            case 'businessStudioProfile':
              Get.to(() => StudioProfileScreen(
                    bId: userDynamicId,
                    fromPost: true,
                  ));
              break;

            case 'POST':
              Get.to(() => PostDetails(
                    dynamictxt: "DYNAMICTEXT",
                    postId: userDynamicId,
                    isArtist: false,
                  ));
              break;

            default:
              Get.to(() => PostDetails(
                  dynamictxt: "DYNAMICTEXT",
                  postId: userDynamicId,
                  isArtist: false));
              break;
          }
        } catch (e) {
          if (userDynamicId != "" && userDynamicId != null) {
            Get.to(() => PostDetails(
                dynamictxt: "DYNAMICTEXT",
                postId: userDynamicId,
                isArtist: false));
          }
        }
      }
    });
  }
}

// class DynamicLinkService {
//   Future<void> retrieveDynamicLink(BuildContext context) async {
//     FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
//     dynamicLinks.onLink.listen((dynamicLinkData) {
//       final Uri uri = dynamicLinkData.link;
//       if (uri != null) {
//         String str = uri
//             .toString()
//             .replaceAll("https://itapp2u.com/apps/Inkapp/api/", "");
//         print("DeepLink Data" + uri.toString());
//         Get.to(() => PostDetails(
//             dynamictxt: "DYNAMICTEXT", postId: str, isArtist: false));
//       }
//     });
//   }
// }
