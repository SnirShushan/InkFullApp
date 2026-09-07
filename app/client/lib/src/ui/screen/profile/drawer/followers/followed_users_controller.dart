import 'package:get/get.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/ui/screen/profile/drawer/followers/follower_model.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';

class FollowedUsersController extends GetxController {
  RxList<FollowerModel> followersList = <FollowerModel>[].obs;
  RxBool isLoading = false.obs;
  RxInt start = 0.obs;
  RxInt limit = 10.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    Future.microtask(() {
      getFollowers();
    });
  }
  Future getFollowers({bool? isLoadingEnabled}) async {
    if (isLoadingEnabled == null) {
      isLoading.value = true;
    }
    try {
      await Network.getFollowers(
              start: start.value.toString(), limit: limit.value.toString())
          .then((res) async {
        isLoading.value = false;
        if (res != null && res != "" && res != false) {
          followersList.clear();
          await res.map((doc) {
            followersList.add(FollowerModel.fromJson(doc));
          }).toList();

          followersList.refresh();

          start.value = followersList.length;
          limit.value = followersList.length + 10;

          // print("followersList.length : ${followersList.length}");
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

  //follow user
  Future unFollowArtists({bid, likeStatus}) async {
    await Network.followUser(fid: bid, likeStatus: "0")
        .then((value) => getFollowers(isLoadingEnabled: false));
  }
}
