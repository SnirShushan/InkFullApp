// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../../../../data/source/network/user_api.dart';
// import '../../../../../utils/colors.dart';
// import '../../../../../utils/common.dart';
// import '../../../../../utils/webService.dart';
// import '../../../../widgets/unfocus_widget.dart';
// import '../signinterms.dart';
//
// class TagMembersBackup extends StatefulWidget {
//   const TagMembersBackup({Key? key}) : super(key: key);
//
//   @override
//   State<TagMembersBackup> createState() => _TagMembersBackupState();
// }
//
// class _TagMembersBackupState extends State<TagMembersBackup> {
//   final scrollController = ScrollController();
//   final searchController = TextEditingController();
//
//   Future getList() async => await Network.getBusinessList(
//       btype: WebService.isArtist == "1" ? "2" : "1",
//       search_txt: searchController.text);
//
//   @override
//   void initState() {
//     WebService.memberList.clear();
//     super.initState();
//   }
//
//   List<int> selectedList = [];
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return UnFocusWidget(
//         child: WillPopScope(
//             onWillPop: () => exitRegistrationDialog(size, context),
//             child: Scaffold(
//               appBar: buildRegistrationAppbar(
//                   isback: true,
//                   size: size,
//                   title: WebService.isArtist == "2"
//                       // ? "הסטודיואים שלי"
//                       ? "txt.ttl_add_member_artist"
//                       : "txt.sub_ttl_add_member",
//                   context: context),
//               bottomSheet: buildContinueBtn(size: size),
//               body: Stack(
//                 children: [
//                   SingleChildScrollView(
//                       child: Column(
//                     children: [
//                       Container(
//                           color: Colors.white, height: size.height * 0.01),
//                       Container(
//                           color: Colors.white,
//                           height: size.height * 0.02,
//                           child: Center(
//                               child: Text(WebService.isArtist == "2"
//                                       ? "txt.sub_ttl_add_member_artist"
//                                       : "txt.sub_ttl_add_member")
//                                   .tr())),
//                       buildSearchbar(size: size),
//                       buildUserList(size: size),
//                     ],
//                   )),
//                 ],
//               ),
//             )));
//   }
//
//   buildSearchbar({required Size size}) => Container(
//         color: Colors.white,
//         height: size.height * 0.1,
//         child: Padding(
//           padding: EdgeInsets.symmetric(
//               horizontal: size.width * 0.1, vertical: size.height * 0.02),
//           child: TextFormField(
//             controller: searchController,
//             autofocus: false,
//             textInputAction: TextInputAction.search,
//             onFieldSubmitted: (str) => {getList()},
//             decoration: InputDecoration(
//               contentPadding: const EdgeInsets.all(0.0),
//               filled: true,
//               focusColor: defaultAppColor,
//               border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(15),
//                   gapPadding: 0.0,
//                   borderSide: const BorderSide(color: Colors.black)),
//               prefixIcon: IconButton(
//                   icon: const Icon(Icons.search), onPressed: () => getList),
//             ),
//           ),
//         ),
//       );
//
//   buildUserList({required Size size}) => SizedBox(
//         height: size.height * 0.62,
//         child: FutureBuilder(
//             future: getList(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               if (snapshot.hasError ||
//                   snapshot.data == null ||
//                   snapshot.data == false) {
//                 return Center(
//                     child: WebService.isArtist == "1"
//                         ? const Text("alerts.no_artist_found").tr()
//                         : const Text("alerts.no_studio_found").tr());
//               } else if (snapshot.hasData) {
//                 var memberList = snapshot.data;
//                 return ListView.builder(
//                     shrinkWrap: true,
//                     controller: scrollController,
//                     itemCount: memberList.length + 1,
//                     itemBuilder: (BuildContext context, int index) {
//                       if (index < memberList.length) {
//                         return Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             ListTile(
//                                 onTap: () => setState(() {
//                                       if (selectedList.contains(index) &&
//                                           WebService.memberList.contains(
//                                               memberList[index]["id"])) {
//                                         selectedList.remove(index);
//                                         WebService.memberList
//                                             .remove(memberList[index]["id"]);
//                                       } else {
//                                         selectedList.add(index);
//                                         WebService.memberList
//                                             .add(memberList[index]["id"]);
//                                       }
//                                     }),
//                                 selected:
//                                     selectedList.contains(index) ? true : false,
//                                 selectedTileColor: defaultWhite,
//                                 leading: CachedNetworkImage(
//                                     imageUrl: WebService.profileImageUrl +
//                                         memberList[index]["profile_image"],
//                                     imageBuilder: (context, imageProvider) =>
//                                         Container(
//                                           height: size.width * 0.12,
//                                           width: size.width * 0.12,
//                                           decoration: BoxDecoration(
//                                             borderRadius:
//                                                 const BorderRadius.all(
//                                                     Radius.circular(50)),
//                                             image: DecorationImage(
//                                               image: imageProvider,
//                                               fit: BoxFit.cover,
//                                             ),
//                                           ),
//                                         ),
//                                     placeholder: (context, url) =>
//                                         const CircularProgressIndicator(),
//                                     errorWidget: (context, url, error) =>
//                                         Container(
//                                           height: size.width * 0.12,
//                                           width: size.width * 0.12,
//                                           decoration: const BoxDecoration(
//                                               borderRadius: BorderRadius.all(
//                                                   Radius.circular(50)),
//                                               image: DecorationImage(
//                                                 image: AssetImage(
//                                                     AppAssets.galleryPlaceholder),
//                                                 fit: BoxFit.cover,
//                                               )),
//                                         )),
//                                 title: SizedBox(
//                                   height: size.width * 0.12,
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     children: [
//                                       SizedBox(
//                                           width: size.width * 0.4,
//                                           child: Text(memberList[index]["name"],
//                                               overflow: TextOverflow.ellipsis,
//                                               maxLines: 1,
//                                               textAlign: TextAlign.start,
//                                               style: Get.textTheme.bodyMedium!
//                                                   .copyWith(
//                                                       fontWeight:
//                                                           FontWeight.bold))),
//                                       const VerticalDivider(thickness: 2),
//                                     ],
//                                   ),
//                                 ),
//                                 trailing: SizedBox(
//                                     width: size.width * 0.25,
//                                     child: Text(memberList[index]["address"],
//                                         textAlign: TextAlign.end,
//                                         maxLines: 3,
//                                         style: Get.textTheme.bodySmall))),
//                             const Divider(),
//                           ],
//                         );
//                       } else {
//                         return memberList.length < 10
//                             ? const SizedBox()
//                             : const Center(child: CircularProgressIndicator());
//                       }
//                     });
//               }
//               return Container();
//             }),
//       );
//
//   buildContinueBtn({required Size size}) => SizedBox(
//         height: size.height * 0.1,
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
//           child: Center(
//               child: buildButton(
//                   align: Alignment.centerRight,
//                   size: size,
//                   width: size.width,
//                   // text: "business",
//                   text: "שמור",
//                   onClick: () {
//                     Get.to(() => const SignInTerms());
//                   })),
//         ),
//       );
// }
