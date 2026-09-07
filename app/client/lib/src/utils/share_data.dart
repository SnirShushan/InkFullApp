import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' as getx;
import 'package:ink/src/ui/screen/home/controller/post_details_controller.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/firebase_dynamic_link_helper.dart';
import 'package:ink/src/utils/webService.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'colors.dart';
import 'common.dart';

class ShareData {
  static Future<void> sharePost({
    required BuildContext context,
    required String imageUrl,
    required String userid,
  }) async {
    final postDetailsController = getx.Get.put(PostDetailsController());
    postDetailsController.isShareLoading.value = true;

    try {
      final cleaned = imageUrl.replaceAll('[', '').replaceAll(']', '');

      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png';

      final dio = Dio(
        BaseOptions(
          responseType: ResponseType.bytes,
          connectTimeout: 15 * 1000,
          receiveTimeout: 20 * 1000,
        ),
      );

      final response = await dio.get<List<int>>(cleaned);

      if (response.data == null) {
        debugPrint("הורדת התמונה נכשלה");
        return;
      }

      final file = File(filePath);
      await file.writeAsBytes(response.data!);

      // 🔥 REQUIRED for Android stability
      await Future.delayed(const Duration(milliseconds: 300));

      if (!file.existsSync() || file.lengthSync() == 0) {
        debugPrint("קובץ תמונה לא חוקי");
        return;
      }

      final files = [
        XFile(
          file.path,
          mimeType: 'image/png',
        )
      ];

      String shareLink;
      try {
        shareLink = await FirebaseDynamicLinkHelper()
            .createShortDynamicLink(linkType: "", userId: userid);
      } catch (_) {
        shareLink = "https://inkapp.page.link/";
      }
      postDetailsController.isShareLoading.value = false;
      if (Platform.isIOS) {
        // iOS requires position origin (especially iPad)
        final box = context.findRenderObject() as RenderBox?;

        final Rect? origin =
            box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;
        Clipboard.setData(ClipboardData(text: shareLink));
        displayMessageShareIcon(
            snackposition: getx.SnackPosition.TOP,
            message: " הלינק לתוכן הועתק, אפשר להדביק אותו בהודעה",
            color: successGreen,
            imageData: AppAssets.correct_transparentIcon);

        await Share.shareXFiles(
          files,
          text: "\n $shareLink",
          sharePositionOrigin: origin,
        );
      } else {
        // Android
        try {
          await Share.shareXFiles(
            files,
            text: "\n $shareLink",
          );
        } catch (e, s) {
          debugPrint("ShareWhatsApp error: $e\n$s");
        }
      }
    } catch (e, s) {
      debugPrint("Share error: $e\n$s");
    } finally {
      postDetailsController.isShareLoading.value = false;
    }
  }

  //share profile
  static Future shareProfile(
      {context, userid, sharetype, String username = ""}) async {
    try {
      final PostDetailsController postDetailsController =
          getx.Get.put(PostDetailsController());

      String shareProfileLink = await FirebaseDynamicLinkHelper()
          .createShortDynamicLink(
              linkType: sharetype, userId: userid.toString());
      postDetailsController.isShareLoading.value = true;

      String shareText;
      if (sharetype == 'mainprofile') {
        shareText =
            "זה הפרופיל העסקי שלי באפליקציית Ink, לחצו כדי לראות עבודות וסקיצות!"
            "\n$shareProfileLink";
      } else {
        shareText =
            "היי, תראה את הפרופיל של $username באפליקציית אינק לחצו כאן כדי לראות עבודות וסקיצות!"
            "\n$shareProfileLink";
      }
      postDetailsController.isShareLoading.value = false;
      await _shareWithPlatformCheck(context, shareText);
    } catch (e) {
      // Handle error
      debugPrint('Error sharing profile: $e');
      // Consider showing a snackbar or toast
    } finally {
      final PostDetailsController postDetailsController =
          getx.Get.find<PostDetailsController>();
      postDetailsController.isShareLoading.value = false;
    }
  }

  static Future<void> _shareWithPlatformCheck(
      BuildContext context, String text) async {
    try {
      // iOS 26+ REQUIRES a non-zero sharePositionOrigin
      if (Platform.isIOS) {
        final box = context.findRenderObject() as RenderBox?;

        // Create a fallback rectangle if box is null
        final Rect originRect = box != null
            ? (box.localToGlobal(Offset.zero) & box.size)
            : const Rect.fromLTWH(0, 0, 1, 1);

        await Share.share(
          text,
          sharePositionOrigin: originRect,
        );
      }
      // Android behavior (optional position)
      else if (Platform.isAndroid && context.mounted) {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          await Share.share(
            text,
            sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
          );
        } else {
          await Share.share(text);
        }
      }
      // Fallback for other platforms
      else {
        await Share.share(text);
      }
    } catch (e) {
      debugPrint('Error in _shareWithPlatformCheck: $e');
      rethrow;
    }
  }
}
