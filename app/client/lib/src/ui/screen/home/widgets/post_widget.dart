import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/ui/screen/home/imageDetails/post_details.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/webService.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/model/post_model.dart';

class PostWidget extends StatelessWidget {
  final PostModel postModel;
  final TextEditingController fNameController;
  final List<String> folderIdList;
  final ScrollController scrollController;
  const PostWidget(
      {super.key,
      required this.postModel,
      required this.fNameController,
      required this.folderIdList,
      required this.scrollController});
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final postImage = postModel.imageName!;
    return GestureDetector(
        onTap: () async {
          try {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            print("offset " + scrollController.offset.toString());
            await prefs
                .setDouble("scroll_offset", scrollController.offset)
                .then((value) => Get.to(
                    () => PostDetails(postId: postModel.id!, isArtist: false)));
          } catch (e) {
            displayMessage(e.toString(), Colors.red);
          }
        },
        child: CachedNetworkImage(
            imageUrl: WebService.resolveImageUrl(postImage),
            fit: BoxFit.fitHeight,
            width: size.width,
            placeholder: (context, url) => const SizedBox(height: 250),
            errorWidget: (context, url, error) => const SizedBox(height: 250)
            // Image.asset("assets/images/placeholder.jpg"),
            ));
  }
}
