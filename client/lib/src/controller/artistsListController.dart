import 'package:get/get.dart';
import 'package:ink/src/controller/userController.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';

import '../ui/screen/notification/NotificationModel.dart';

class ArtistListController extends GetxController {
  RxList<ArtistModel> artistList = <ArtistModel>[].obs;
  RxBool isLoading = false.obs;
  final userController = Get.put(UserController());

  Future<void> getArtists() async {
    isLoading.value = true;

    try {
      userController.businessType.value.toString() == "2" ||
              userController.businessType.value == 2
          ? await Network.getMyStudio().then((res) async {
              isLoading.value = false;

              if (res != null && res != "" && res != false) {
                artistList.clear();
                await res.map((doc) {
                  if (doc["req_status"].toString() == "1" ||
                      doc["req_status"] == 1) {
                    artistList.add(ArtistModel.fromJson(doc));
                  }
                }).toList();
              }
              artistList.refresh();
            })
          : await Network.getMyArtist().then((res) async {
              isLoading.value = false;
              if (res != null && res != "" && res != false) {
                artistList.clear();
                await res.map((doc) {
                  if (doc["req_status"].toString() == "1" ||
                      doc["req_status"] == 1) {
                    artistList.add(ArtistModel.fromJson(doc));
                  }
                }).toList();
                artistList.refresh();
              }
            });
    } catch (e) {
      displayMessageIcon(
          message: e.toString(),
          snackposition: SnackPosition.BOTTOM,
          color: errorColor,
          imageData: AppAssets.errorIcon);
    }
  }

  //update artists
  Future updateArtists({artistId, actionStatus}) async {
    await Network.updateArtistList(
        artistId: artistId, actionStatus: actionStatus);
  }

  //update studios
  Future updateStudios({studioId, actionStatus}) async {
    await Network.updateStudioList(
        studioId: studioId, actionStatus: actionStatus);
    update();
  }
}
