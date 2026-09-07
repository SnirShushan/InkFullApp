// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/controller/userController.dart';
// import 'package:ink/src/ui/screen/notification/models/tattooRequest.dart';
// import 'package:ink/src/ui/screen/notification/screen_images.dart';
// import 'package:ink/src/ui/screen/profile/businessUserProfile.dart';
// import 'package:ink/src/utils/assets.dart';
// import 'package:ink/src/utils/colors.dart';
// import 'package:ink/src/utils/common.dart';
// import 'package:ink/src/utils/webService.dart';
//
// class RequestDetailPageV1 extends StatefulWidget {
//   final TattooRequest tattooRequest;
//
//   const RequestDetailPageV1({Key? key, required this.tattooRequest})
//       : super(key: key);
//
//   @override
//   State<RequestDetailPageV1> createState() => _RequestDetailPageV1State();
// }
//
// class _RequestDetailPageV1State extends State<RequestDetailPageV1> {
//   bool _customTileFirstExpanded = false;
//   bool _customTileSecondExpanded = false;
//   bool _customTileThirdExpanded = false;
//   bool _customTileFourthExpanded = false;
//   bool isFront = true;
//   List<String> imageList = [];
//   var isBusiness;
//   final userController = Get.put(UserController());
//
//   @override
//   void initState() {
//     super.initState();
//     imageList.clear();
//     if (widget.tattooRequest.image1Name != null) {
//       if (widget.tattooRequest.image1Name!.isNotEmpty) {
//         imageList.add(widget.tattooRequest.image1Name!);
//       }
//     }
//     if (widget.tattooRequest.image2Name != null) {
//       if (widget.tattooRequest.image2Name!.isNotEmpty) {
//         imageList.add(widget.tattooRequest.image2Name!);
//       }
//     }
//     if (widget.tattooRequest.image3Name != null) {
//       if (widget.tattooRequest.image3Name!.isNotEmpty) {
//         imageList.add(widget.tattooRequest.image3Name!);
//       }
//     }
//     getData();
//   }
//
//   buildWhatsappMsg(String type) {
//     if (type == "1") {
//       return const Text("לשיחת ווטסאפ עם סטודיו");
//     } else if (type == "2") {
//       return const Text("לשיחת ווטסאפ עם המקעקע");
//     } else {
//       return const Text("לשיחת ווטסאפ עם הלקוח");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     final selectedArtist = userController.userType.toString() == "2"
//         ? widget.tattooRequest.senderRow
//         : widget.tattooRequest.businessRow;
//
//     return Scaffold(
//         appBar: buildappBarwithback(size: size, title: "פרטי הפנייה"),
//         body: ListView(
//             // padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
//             children: [
//               //contact header
//               buildContactDetails(
//                   size: size,
//                   isNotBusiness: userController.userType.value != "1"),
//               isBusiness == false
//                   ? const SizedBox()
//                   : const Divider(thickness: 2),
//
//               //open whatsapp
//               isBusiness == false
//                   ? const SizedBox()
//                   : SizedBox(
//                       width: size.width,
//                       height: size.height * 0.05,
//                       child: InkWell(
//                           onTap: () {
//                             bool isNotBusiness =
//                                 userController.userType.value != "1";
//                             String phone = isNotBusiness
//                                 ? widget.tattooRequest.phone!
//                                 : widget.tattooRequest.businessRow!.phone!;
//
//                             if (phone != null) {
//                               var whatsapp = "";
//                               whatsapp =
//                                   "+${widget.tattooRequest.cntCode}$phone";
//                               var whatsappAndroid =
//                                   "whatsapp://send?phone=$whatsapp";
//                               WebService.openUrl(whatsappAndroid);
//                             } else {
//                               displayMessageIcon(
//                                   message: "מספר טלפון לא מסופק",
//                                   snackposition: SnackPosition.BOTTOM,
//                                   color: errorColor,
//                                   imageData: AppAssets.errorIcon);
//                               // displayMessage("מספר טלפון לא מסופק",
//                               //     Colors.red); //phone number not provided
//                             }
//                           },
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Image.asset("assets/icons/ic_wp.png",
//                                   width: Get.width * 0.1,
//                                   height: Get.height * 0.1),
//                               const SizedBox(width: 10),
//                               buildWhatsappMsg(
//                                   userController.userType.value == "1"
//                                       ? widget.tattooRequest.businessRow!
//                                           .businessType!
//                                       : ""),
//                             ],
//                           )),
//                     ),
//
//               const Divider(thickness: 2),
//
//               //tattoo size
//               ExpansionTile(
//                 title: const Text('גודל הקעקוע'),
//                 trailing: Icon(
//                   _customTileFirstExpanded
//                       ? Icons.arrow_drop_down_circle
//                       : Icons.arrow_drop_down,
//                 ),
//                 children: <Widget>[
//                   ListTile(
//                       title: Text(WebService.setTattooSize(
//                           widget.tattooRequest.tattooSize!)))
//                 ],
//                 onExpansionChanged: (bool expanded) {
//                   setState(() => _customTileFirstExpanded = expanded);
//                 },
//               ),
//
//               //tattoo style
//               ExpansionTile(
//                 // title: Text(
//                 //     '${(widget.tattooRequest.businessRow!.name! ?? "")} | ${(widget.tattooRequest.artistRow != null ? widget.tattooRequest.artistRow!.name! : "")}'),
//                 title: const Text("סגנון הקעקוע"),
//                 trailing: Icon(
//                   _customTileSecondExpanded
//                       ? Icons.arrow_drop_down_circle
//                       : Icons.arrow_drop_down,
//                 ),
//                 children: <Widget>[
//                   ListTile(
//                       title: Text(widget.tattooRequest.styles!.toString())),
//                 ],
//                 onExpansionChanged: (bool expanded) {
//                   setState(() => _customTileSecondExpanded = expanded);
//                 },
//               ),
//
//               //remarks
//               ExpansionTile(
//                 // title: Text(
//                 //     '${(widget.tattooRequest.businessRow!.name! ?? "")} | ${(widget.tattooRequest.artistRow != null ? widget.tattooRequest.artistRow!.name! : "")}'),
//                 title: const Text("הערות"),
//                 trailing: Icon(
//                   _customTileSecondExpanded
//                       ? Icons.arrow_drop_down_circle
//                       : Icons.arrow_drop_down,
//                 ),
//                 children: <Widget>[
//                   ListTile(
//                       title:
//                           Text(widget.tattooRequest.description!.toString())),
//                 ],
//                 onExpansionChanged: (bool expanded) {
//                   setState(() => _customTileSecondExpanded = expanded);
//                 },
//               ),
//
//               //selected business details
//               if (!WebService.checkBlankData(selectedArtist))
//                 ExpansionTile(
//                     title: const Text("אמן"),
//                     trailing: Icon(_customTileSecondExpanded
//                         ? Icons.arrow_drop_down_circle
//                         : Icons.arrow_drop_down),
//                     children: <Widget>[
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: InkWell(
//                           onTap: () => Get.to(() => BusinessProfileScreen(
//                               bId: selectedArtist.id!, fromPost: false)),
//                           child: Padding(
//                             padding: const EdgeInsets.all(10.0),
//                             child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Container(
//                                       decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(
//                                               size.width * 0.15)),
//                                       child: buildCachedNetworkImage(
//                                           height: size.width * 0.15,
//                                           width: size.width * 0.15,
//                                           url: WebService.profileImageUrl +
//                                               selectedArtist!.profileImage!,
//                                           radius: 50)),
//                                   SizedBox(height: size.height * 0.01),
//                                   Text(selectedArtist!.name!,
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .bodyLarge!
//                                           .copyWith(color: appPrimaryColor))
//                                 ]),
//                           ),
//                         ),
//                       )
//                     ],
//                     onExpansionChanged: (bool expanded) {
//                       setState(() => _customTileSecondExpanded = expanded);
//                     }),
//
//               //location as image
//               ExpansionTile(
//                 title: const Text('מיקום הקעקוע'),
//                 trailing: Icon(_customTileFourthExpanded
//                     ? Icons.arrow_drop_down_circle
//                     : Icons.arrow_drop_down),
//                 children: <Widget>[
//                   SizedBox(
//                       height: size.height * 0.4,
//                       child: Container(
//                           height: size.height * 0.4,
//                           width: size.width,
//                           decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(0.0)),
//                           child: ClipRRect(
//                               borderRadius: BorderRadius.circular(0.0),
//                               child: CachedNetworkImage(
//                                   alignment: Alignment.center,
//                                   imageUrl: WebService.bodyImgUrl +
//                                       widget.tattooRequest.frontDataImage!
//                                           .toString(),
//                                   fit: BoxFit.contain,
//                                   progressIndicatorBuilder: (context, url,
//                                           downloadProgress) =>
//                                       SizedBox(
//                                           height: size.height * 0.4,
//                                           width: size.width,
//                                           child: Center(
//                                               child: CircularProgressIndicator(
//                                                   value: downloadProgress
//                                                       .progress))),
//                                   errorWidget: (context, url, error) =>
//                                       const Icon(Icons.photo, size: 200)))))
//                 ],
//                 onExpansionChanged: (bool expanded) {
//                   setState(() => _customTileFourthExpanded = expanded);
//                 },
//               ),
//
//               //Pictures for inspiration
//               if (widget.tattooRequest.requestImages != null)
//                 const ListTile(
//                     // onTap: () => Get.to(() => ScreenImages(imgList: imageList)),
//                     title: Text('תמונות')),
//
//               //image view
//               widget.tattooRequest.requestImages != null
//                   ? Center(
//                       child: SizedBox(
//                         height: size.height * 0.2,
//                         width: size.width * 0.3,
//                         child: InkWell(
//                           onTap: () => Get.to(() => ScreenImages(
//                               imgList: widget.tattooRequest.requestImages!)),
//                           child: Hero(
//                             tag: "requestImage",
//                             child: Stack(
//                               children: <Widget>[
//                                 Positioned(
//                                   top: 10,
//                                   right: 30,
//                                   height: size.width * 0.15,
//                                   width: size.width * 0.15,
//                                   child: Container(
//                                       decoration: BoxDecoration(
//                                           color: Colors.grey.shade300,
//                                           border:
//                                               Border.all(color: Colors.white),
//                                           borderRadius:
//                                               BorderRadius.circular(10)),
//                                       width: size.width * 0.1,
//                                       height: size.width * 0.1,
//                                       child: const SizedBox()),
//                                 ),
//                                 Positioned(
//                                     top: 20,
//                                     right: 40,
//                                     height: size.width * 0.15,
//                                     width: size.width * 0.15,
//                                     child: Container(
//                                         decoration: BoxDecoration(
//                                             color: Colors.grey.shade300,
//                                             border:
//                                                 Border.all(color: Colors.white),
//                                             borderRadius:
//                                                 BorderRadius.circular(10)),
//                                         width: size.width * 0.1,
//                                         height: size.width * 0.1,
//                                         child: const SizedBox())),
//                                 Positioned(
//                                   top: 30,
//                                   right: 50,
//                                   height: size.width * 0.15,
//                                   width: size.width * 0.15,
//                                   child: Container(
//                                     padding: EdgeInsets.all(size.width * 0.008),
//                                     decoration: BoxDecoration(
//                                         color: Colors.grey.shade300,
//                                         border: Border.all(color: Colors.white),
//                                         borderRadius: BorderRadius.circular(10),
//                                         image: DecorationImage(
//                                             image: NetworkImage(widget
//                                                 .tattooRequest
//                                                 .requestImages![0]
//                                                 .imageUrl
//                                                 .toString()),
//                                             fit: BoxFit.cover)),
//                                     width: size.width * 0.1,
//                                     height: size.width * 0.1,
//                                   ),
//                                 ),
//                                 Positioned(
//                                     top: 0,
//                                     left: 40,
//                                     child: CircleAvatar(
//                                         radius: 18,
//                                         child: Text(
//                                             "${widget.tattooRequest.requestImages!.length} +"))),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     )
//                   : const SizedBox()
//             ]));
//   }
//
//   buildContactDetails({required Size size, required bool isNotBusiness}) =>
//       Padding(
//         padding: EdgeInsets.all(size.height * 0.01),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//                 isNotBusiness
//                     ? widget.tattooRequest.name!
//                     : widget.tattooRequest.businessRow!.name!,
//                 style: Theme.of(context).textTheme.titleLarge),
//             SizedBox(height: size.height * 0.01),
//             isBusiness == false
//                 ? const SizedBox()
//                 : Text(
//                     isNotBusiness
//                         ? widget.tattooRequest.phone!
//                         : widget.tattooRequest.businessRow!.phone!,
//                     style: Theme.of(context).textTheme.titleMedium),
//           ],
//         ),
//       );
//
//   void setSelectedPartData() async {
//     WebService.printMsg(widget.tattooRequest.frontData!);
//
//     // final Map<String, dynamic> responseData = json.decode(
//     //     json.encode(widget.tattooRequest.frontData! as Map<String, dynamic>));
//     // WebService.printMsg("responseData$responseData ");
//     // if (widget.tattooRequest.frontData!.isNotEmpty) {
//     //   _bodyParts = BodyParts.fromJson(await jsonDecode(
//     //       jsonEncode(widget.tattooRequest.frontData! as Map<String, dynamic>)));
//     // } else {
//     //   _bodyParts = BodyParts.fromJson(
//     //       await jsonDecode(jsonEncode(widget.tattooRequest.backData!)));
//     // }
//     setState(() {});
//   }
//
//   Future<void> getData() async {
//     isBusiness = await WebService.getIsBusiness();
//     setState(() {});
//   }
// }
