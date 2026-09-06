// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/controller/artistsListController.dart';
// import 'package:ink/src/ui/screen/home/controller/post_details_controller.dart';
// import 'package:ink/src/utils/common.dart';
//
// import '../../../../../utils/colors.dart';
// import '../../../../../utils/webService.dart';
//
// class ChangeArtistBackup extends StatefulWidget {
//   final String pid;
//
//   const ChangeArtistBackup({Key? key, required this.pid}) : super(key: key);
//
//   @override
//   State<ChangeArtistBackup> createState() => _ChangeArtistBackupState();
// }
//
// class _ChangeArtistBackupState extends State<ChangeArtistBackup> {
//   String selectedId = "";
//   final PostDetailsController postDetailController =
//       Get.put(PostDetailsController());
//   final ArtistListController artistListController =
//       Get.put(ArtistListController());
//   Future getArtists() async => await artistListController.getArtists();
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     getArtists();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isArtistNull =
//         postDetailController.postModel.value.artist == null ? true : false;
//
//     return Scaffold(
//       appBar: buildappBarwithClose(
//           size: Get.size,
//           title: isArtistNull
//               ? "החלף איש צוות"
//               : "הוסף איש צוות"), //Change staff member
//       bottomSheet: SizedBox(
//           width: Get.width,
//           height: Get.height * 0.1,
//           child: Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: buildButton(
//                   align: Alignment.bottomCenter,
//                   size: Get.size,
//                   width: double.infinity,
//                   text: "btn.continue",
//                   onClick: () async {
//                     if (selectedId == "" || selectedId.isEmpty) {
//                       displayMessage(
//                           "אנא בחר צוות", Colors.red); //Please select crew
//                     } else if (!isArtistNull &&
//                         postDetailController.postModel.value.artist!.id! ==
//                             selectedId) {
//                       Get.back();
//                       // displayMessage("member is already tagged", Colors.red);
//                     } else {
//                       await postDetailController.updatePostMember(
//                           postId: widget.pid, memberId: selectedId);
//                     }
//                   }))), //save
//       body: Obx(() => buildUserList(size: Get.size)),
//     );
//   }
//
//   //build list of artist
//   buildUserList({required Size size}) => ListView.builder(
//       shrinkWrap: true,
//       itemCount: artistListController.artistList.length,
//       itemBuilder: (BuildContext context, int index) {
//         return Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ListTile(
//                 onTap: () => setState(() {
//                       if (selectedId ==
//                           artistListController.artistList[index].profile!.id!) {
//                         selectedId = "";
//                       } else {
//                         selectedId =
//                             artistListController.artistList[index].profile!.id!;
//                       }
//                     }),
//                 selected: selectedId ==
//                     artistListController.artistList[index].profile!.id!,
//                 selectedTileColor: defaultWhite,
//                 leading: CachedNetworkImage(
//                     imageUrl: WebService.profileImageUrl +
//                         artistListController
//                             .artistList[index].profile!.profileImage!,
//                     imageBuilder: (context, imageProvider) => Container(
//                           height: size.width * 0.12,
//                           width: size.width * 0.12,
//                           decoration: BoxDecoration(
//                             borderRadius:
//                                 const BorderRadius.all(Radius.circular(50)),
//                             image: DecorationImage(
//                               image: imageProvider,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//                     placeholder: (context, url) =>
//                         const CircularProgressIndicator(),
//                     errorWidget: (context, url, error) => Container(
//                           height: size.width * 0.12,
//                           width: size.width * 0.12,
//                           decoration: const BoxDecoration(
//                               borderRadius:
//                                   BorderRadius.all(Radius.circular(50)),
//                               image: DecorationImage(
//                                 image: AssetImage(
//                                     AppAssets.galleryPlaceholder),
//                                 fit: BoxFit.cover,
//                               )),
//                         )),
//                 title: SizedBox(
//                   height: size.width * 0.12,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       SizedBox(
//                           width: size.width * 0.4,
//                           child: Text(
//                               artistListController
//                                   .artistList[index].profile!.name!,
//                               overflow: TextOverflow.ellipsis,
//                               maxLines: 1,
//                               textAlign: TextAlign.start,
//                               style: Get.textTheme.bodyMedium!
//                                   .copyWith(fontWeight: FontWeight.bold))),
//                       const VerticalDivider(thickness: 2),
//                     ],
//                   ),
//                 ),
//                 trailing: SizedBox(
//                     width: size.width * 0.25,
//                     child: Text(
//                         artistListController
//                             .artistList[index].profile!.address!,
//                         textAlign: TextAlign.end,
//                         maxLines: 3,
//                         style: Get.textTheme.bodySmall))),
//             const Divider(),
//           ],
//         );
//       });
// }
