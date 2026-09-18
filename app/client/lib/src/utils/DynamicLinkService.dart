import 'dart:async';

import 'package:app_links/app_links.dart';
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
  static final AppLinks _appLinks = AppLinks();
  static StreamSubscription<Uri>? _sub;

  Future<Uri?> getInitialShareLink() async {
    try {
      return await _appLinks.getInitialLink();
    } catch (_) {
      return null;
    }
  }

  Future<void> retrieveDynamicLink(BuildContext context) async {
    _sub ??= _appLinks.uriLinkStream.listen(_openShareUri);
  }

  static Future<void> _openShareUri(Uri? uri) async {
    if (uri == null) return;
    String action = uri.queryParameters['action'] ?? '';
    String userDynamicId = uri.queryParameters['pid'] ?? '';
    if (action.isEmpty && userDynamicId.isEmpty) {
      Get.offAll(() => HomeScreen());
      return;
    }
    switch (action) {
      case 'mainprofile':
        AppUser user = await WebService.getCurrentUser();
        final bool isBusiness = await WebService.getIsBusiness();
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
        if (userDynamicId.isNotEmpty) {
          Get.to(() => PostDetails(
              dynamictxt: "DYNAMICTEXT",
              postId: userDynamicId,
              isArtist: false));
        }
        break;
    }
  }
}
