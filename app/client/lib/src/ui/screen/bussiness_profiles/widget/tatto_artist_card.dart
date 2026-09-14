import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/userController.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/ui/screen/bussiness_profiles/model_business_user.dart';
import 'package:ink/src/ui/screen/profile/businessUserProfile.dart';
import 'package:ink/src/ui/widgets/build_custom_catched_image.dart';
import 'package:ink/src/ui/widgets/button/animation_loader_button_widget.dart';
import 'package:ink/src/ui/widgets/promoted_badge.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/open_inspiration_style.dart';
import 'package:ink/src/utils/webService.dart';

class TattooArtistCard extends StatefulWidget {
  final BusinessUserListModel businessUserListModel;

  const TattooArtistCard({super.key, required this.businessUserListModel});

  @override
  State<TattooArtistCard> createState() => _TattooArtistCardState();
}

class _TattooArtistCardState extends State<TattooArtistCard> {
  late String _liked;
  bool _followLoading = false;

  BusinessUserListModel get businessUserListModel =>
      widget.businessUserListModel;

  @override
  void initState() {
    super.initState();
    _liked = businessUserListModel.liked == "1" ? "1" : "0";
  }

  @override
  void didUpdateWidget(TattooArtistCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextLiked =
        widget.businessUserListModel.liked == "1" ? "1" : "0";
    if (_liked != nextLiked && !_followLoading) {
      _liked = nextLiked;
    }
  }

  bool get _isOwnProfile {
    if (!Get.isRegistered<UserController>()) return false;
    final myId = Get.find<UserController>().id.value;
    return myId.isNotEmpty && myId == businessUserListModel.id?.toString();
  }

  void _openProfile() {
    final id = businessUserListModel.id?.toString() ?? "";
    if (id.isEmpty || id == "null") return;
    Get.to(() => BusinessProfileScreen(bId: id, fromPost: false));
  }

  Future<void> _toggleFollow() async {
    if (_followLoading) return;
    final id = businessUserListModel.id?.toString() ?? "";
    if (id.isEmpty || id == "null") return;
    final next = _liked == "1" ? "0" : "1";
    setState(() => _followLoading = true);
    try {
      final result = await Network.followUser(fid: id, likeStatus: next);
      if (!mounted) return;
      if (result != false) {
        setState(() {
          _liked = next;
          businessUserListModel.liked = next;
        });
      }
    } finally {
      if (mounted) setState(() => _followLoading = false);
    }
  }

  Widget _followButton() {
    final isLiked = _liked == "1";
    return GestureDetector(
      onTap: _toggleFollow,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: signInButtonColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: _followLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: InkSpinningLoader(size: 18),
              )
            : isLiked
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        AppAssets.checkedIcon,
                        width: 14,
                        height: 14,
                        color: titleTextWhiteColor,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'במעקב',
                        style: TextStyle(
                          color: titleTextWhiteColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : const Text(
                    'הוסף למעקב',
                    style: TextStyle(
                      color: titleTextWhiteColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final promoted = isPromotedFlag(businessUserListModel.isPromoted);
    return Card(
      color: cardBgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: promoted
            ? const BorderSide(color: promotedBorderColor, width: 1.5)
            : BorderSide.none,
      ),
      child: Stack(
        children: [
          Padding(
          padding: EdgeInsets.fromLTRB(8, promoted ? 36 : 8, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.01),
              GestureDetector(
                onTap: _openProfile,
                child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child:  businessUserListModel.businessImg.toString()=="[]"? Image.asset(
                    height: 120.0,
                    width: 120.0,
                    AppAssets.galleryPlaceholder,
                    fit: BoxFit.cover):Row(
                  children:businessUserListModel.businessImg!.map((image) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 3.0, right: 3),
                      child: Stack(
                        children: [
                          BuildCachedNetworkImage(
                              height: 120.0,
                              width: 120.0,
                              url: image.imageUrl ?? WebService.tempImageUrl,
                              radius: 8),

                         if(image.isMultipleImages=="1")Positioned(
                            top: 10,
                            right: 10,
                            child: SvgPicture.asset(
                              AppAssets.multiImageicon,
                              width: 20,
                              height:20
                            ),)
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _openProfile,
                      child: Row(
                    children: [
                      // const CircleAvatar(radius: 26),
                      businessUserListModel.profileImage==""?ClipRRect(
                        borderRadius: BorderRadius.circular(26),

                        child: Image.asset(
                            height: size.width * 0.13,
                            width: size.width * 0.13,
                            AppAssets.userPlaceHolder,
                            fit: BoxFit.cover),
                      ): buildCachedNetworkImage(
                          height: size.width * 0.13,
                          width: size.width * 0.13,
                          errorWidget: Image.asset(AppAssets.userPlaceHolder,
                              fit: BoxFit.cover),
                          url: WebService.resolveProfileImage(
                              businessUserListModel.profileImage),
                          radius: 26),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                businessUserListModel.name!.length > 27
                                    ? '${businessUserListModel.name!.substring(0, 27)}...'
                                    : businessUserListModel.name!,
                                maxLines: 1,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18)
                            ),
                            const SizedBox(height: 5),
                            Row(children: [
                              SvgPicture.asset(
                                AppAssets.homeIcon,
                                // size: 16
                              ),
                              const SizedBox(width: 4),
                              Text(
                                  businessUserListModel.businessType == "1"
                                      ? 'סטודיו'
                                      : "אמן",
                                  style: const TextStyle(
                                      color: titleTextWhiteColor)),
                              const Text('  |  ',
                                  style: TextStyle(color: titleTextWhiteColor)),
                              SvgPicture.asset(
                                  width: 12,
                                  height: 16,
                                  AppAssets.locationIcon,
                                  color: titleTextWhiteColor),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  businessUserListModel.address!.length > 20
                                      ? '${businessUserListModel.address!.substring(0, 20)}...'
                                      : businessUserListModel.address!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: titleTextWhiteColor)),
                              ),
                            ])
                          ]),
                      ),
                    ],
                  ),
                    ),
                  ),
                  if (!_isOwnProfile) ...[
                    const SizedBox(width: 8),
                    _followButton(),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              //styles
              if (businessUserListModel.stylesHe != null)
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    // Aligns items to the center horizontally
                    child: Row(
                        children: businessUserListModel.stylesHe!.map((style) {
                          // children: UserController().style_list!.map((style) {
                          return Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: SizedBox(
                                height: 24,
                                child: ElevatedButton(
                                    onPressed: () {
                                      final slugs = (businessUserListModel.styles ?? '')
                                          .split(',')
                                          .map((s) => s.trim())
                                          .where((s) => s.isNotEmpty)
                                          .toList();
                                      final names = businessUserListModel.stylesHe!
                                          .where((s) => s.isNotEmpty)
                                          .toList();
                                      final index = names.indexOf(style);
                                      openInspirationForStyle(
                                        slug: index >= 0 && index < slugs.length
                                            ? slugs[index]
                                            : null,
                                        label: style,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: styleBgColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(4.0))),
                                    child: Text(style.toString(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: titleTextWhiteColor)))),
                          );
                        }).toList())),
              SizedBox(height: size.height * 0.01),
            ],
          ),
            ),
            if (promoted)
              const PositionedDirectional(
                top: 10,
                end: 10,
                child: PromotedBadge(),
              ),
          ],
        ),
    );
  }
}

