import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/data/model/ArtistModel.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/ui/screen/notification/NotificationModel.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/webService.dart';

class EditMemberController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  RxBool isLoading = false.obs;
  RxBool isChecked = false.obs;
  RxList<Artist> artistList = <Artist>[].obs;
  RxList<ArtistModel> selectedList = <ArtistModel>[].obs;

  // RxString artistIdStr = "".obs;
  RxList<String> artistIdList = <String>[].obs;

  @override
  void onInit() {
    isChecked.value = false;
    getArtists();
    super.onInit();
  }

  Future getArtists() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      await Network.getBusinessListApi(
              btype: WebService.isArtist == "1" ? "2" : "1",
              search_txt: searchController.text)
          .then((list) {
        if (list != null) {
          artistList.clear();
          List<Artist> newList = (list as List<dynamic>)
              .map((value) => Artist.fromJson(value))
              .toList();
          newList.map((e) {
            artistList.add(e);
          }).toList();
        }
      });
    } catch (e) {
      isLoading.value = false;
    } finally {
      getMyArtists();
      artistList.refresh();
    }
  }

  Future<void> getMyArtists() async {
    isLoading.value = true;

    try {
      artistList.refresh();
      selectedList.clear();
      await Network.getMyArtist().then((res) async {
        if (res != null && res != "" && res !=false) {
          await res.map((doc) {
            // if (doc["req_status"].toString() == "1" || doc["req_status"] == 1) {
            selectedList.add(ArtistModel.fromJson(doc));
            // }
          }).toList();
        }
      });
      selectedList.refresh();
    } catch (e) {
      isLoading.value = false;
      displayMessageIcon(
          message: e.toString(),
          snackposition: SnackPosition.BOTTOM,
          color: errorColor,
          imageData: AppAssets.errorIcon);
    } finally {
      isLoading.value = false;
    }
  }

  Future updateArtists({artistId, actionStatus}) async {
    await Network.updateArtistList(
            artistId: artistId, actionStatus: actionStatus)
        .then((value) => getArtists());
  }

  Future updateMultipleArtists({artistId, actionStatus}) async {
    await Network.updateArtistList(
            artistId: artistId, actionStatus: actionStatus)
        .then((value) => getArtists());
  }

  //update studios
  Future updateStudios({studioId, actionStatus}) async {
    await Network.updateStudioList(
            studioId: studioId, actionStatus: actionStatus)
        .then((value) => getArtists());
  }

  // void artistUpdate(ids) {
  //   if (artistIdStr.value == ids) {
  //     artistIdStr.value = "";
  //   } else {
  //     artistIdStr.value = ids;
  //   }
  //
  //   print("artistIdStr.value ${artistIdStr.value}");
  // }
  void artistUpdate(String id) {
    if (artistIdList.contains(id)) {
      // If it is, remove it
      artistIdList.remove(id);
    } else {
      // If not, add it
      artistIdList.add(id);
    }
  }
}
