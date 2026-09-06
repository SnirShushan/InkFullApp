// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/controller/userController.dart';
// import 'package:ink/src/data/model/currentUser.dart';
// import 'package:ink/src/ui/screen/sendTattoRquest/select_request_images.dart';
// import 'package:ink/src/utils/assets.dart';
// import 'package:ink/src/utils/colors.dart';
// import 'package:ink/src/utils/common.dart';
// import 'package:screenshot/screenshot.dart';
//
// import '../../../controller/businessDetailControllor.dart';
// import '../../../data/model/image_model.dart';
// import '../../../data/source/network/firebase_api.dart';
// import '../../../utils/webService.dart';
// import '../../widgets/bodyparts/bodyparts.dart';
// import '../../widgets/bodyparts/rotation_stage/rotation_stage.dart';
// import '../../widgets/unfocus_widget.dart';
// import 'controller/imgListController.dart';
//
// class ScreenTattooRequestBackupv1 extends StatefulWidget {
//   final String bId;
//
//   const ScreenTattooRequestBackupv1({super.key, required this.bId});
//   @override
//   State<ScreenTattooRequestBackupv1> createState() =>
//       _ScreenTattooRequestBackupv1State();
// }
//
// class _ScreenTattooRequestBackupv1State
//     extends State<ScreenTattooRequestBackupv1> {
//   final globalKey = GlobalKey<ScaffoldState>();
//
//   ScreenshotController screenshotController = ScreenshotController();
//
//   bool isSelected = false;
//   bool isb1Selected = false;
//   bool isb2Selected = false;
//   bool isb3Selected = false;
//   bool isImageExist = false;
//   bool isTermChecked = false;
//
//   //tattoo size
//   bool isLittle = false;
//   bool isMedium = true;
//   bool isBig = false;
//   String tattooSize = "M";
//
//   //select creator
//   String selectedCreatorId = "";
//
//   //selected styles
//   late final AppUser user;
//   List<StylesList> selectedList = [];
//   List<StylesList> listStyles = [];
//   String styles = "";
//
//   final imgListController = Get.put(ImgListController());
//   final userController = Get.put(UserController());
//   final businessDetailsController = Get.put(BusinessDetailController());
//
//   bool isEnabled = true;
//
//   @override
//   void initState() {
//     super.initState();
//     businessDetailsController.getBusinessInfo(bid: widget.bId);
//     WebService.changeUserStyleList.clear();
//     imgListController.nameController.text = userController.name.value ?? "";
//     imgListController.phoneController.text = userController.phone.value ?? "";
//     getUser();
//   }
//
//   Future getUser() async {
//     user = await WebService.getCurrentUser();
//
//     user.stylesList?.map((doc) {
//       listStyles.add(doc);
//     }).toList();
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     var textTheme = Theme.of(context).textTheme;
//
//     return UnFocusWidget(
//         child: Scaffold(
//             key: globalKey,
//             appBar: AppBar(
//                 elevation: 0,
//                 leading: IconButton(
//                     onPressed: () => Get.back(),
//                     icon:
//                         const Icon(Icons.arrow_back_ios, color: Colors.white)),
//                 toolbarHeight: size.height * 0.08,
//                 backgroundColor: Colors.black,
//                 title: const Text("פניה לעסק"), //פניות לעסק
//                 centerTitle: true),
//             body: Obx(
//               () => SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     //title
//                     buildTitle(context, size, textTheme),
//
//                     //name and phone
//                     buildFormField(context, size, textTheme),
//                     const Divider(color: kDivider),
//
//                     //size and image
//                     buildSizeAndImages(context, size, textTheme),
//                     const Divider(color: kDivider),
//
//                     //styles list
//                     buildStyleList(context, size, textTheme),
//
//                     //body part section
//                     SizedBox(
//                         height: size.height * 0.52,
//                         child: Screenshot(
//                           controller: screenshotController,
//                           child: BodyPartSelectorTurnable(
//                             mirrored: false,
//                             bodyParts: imgListController.bodyParts.value,
//                             onSelectionUpdated: (p) => setState(() {
//                               imgListController.bodyParts.value = p;
//                             }),
//                             labelData: const RotationStageLabelData(
//                               front: 'מקדימה', //Front
//                               // left: 'Left',
//                               // right: 'Right',
//                               back: "מאחור", //'Back',
//                             ),
//                           ),
//                         )),
//                     businessDetailsController.artistsList.isEmpty
//                         ? const SizedBox()
//                         : const Divider(),
//
//                     businessDetailsController.artistsList.isEmpty
//                         ? const SizedBox()
//                         : Padding(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: Get.size.width * 0.05,
//                                 vertical: Get.size.height * 0.005),
//                             child: Align(
//                               alignment: Alignment.centerLeft,
//                               child: Text('בחר מקעקע מועדף',
//                                   style: Get.textTheme.titleMedium!.copyWith(
//                                       color: kBlack,
//                                       fontWeight: FontWeight.bold)),
//                             ),
//                           ),
//
//                     //artists selection
//                     SizedBox(
//                         child: businessDetailsController.artistsList.isEmpty
//                             ? const SizedBox()
//                             : SizedBox(
//                                 height: size.height * 0.15,
//                                 child: ListView.builder(
//                                     itemCount: businessDetailsController
//                                         .artistsList.length,
//                                     reverse: true,
//                                     shrinkWrap: false,
//                                     scrollDirection: Axis.horizontal,
//                                     itemBuilder:
//                                         (BuildContext context, int index) {
//                                       return InkWell(
//                                         onTap: () => setState(() {
//                                           selectedCreatorId ==
//                                                   businessDetailsController
//                                                       .artistsList[index].id!
//                                               ? selectedCreatorId = ""
//                                               : selectedCreatorId =
//                                                   businessDetailsController
//                                                       .artistsList[index].id!;
//                                         }),
//                                         child: Container(
//                                           decoration: const BoxDecoration(
//                                               // color: selectedCreatorId ==
//                                               //         businessDetailsController
//                                               //             .artistsList[index].id!
//                                               //     ? Colors.grey.withOpacity(0.5)
//                                               //     : Colors.white,
//                                               border: Border(
//                                                   right: BorderSide(
//                                                       color: Colors.grey))),
//                                           width: size.width * 0.3,
//                                           padding:
//                                               EdgeInsets.all(size.width * 0.01),
//                                           child: Column(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
//                                               Container(
//                                                   decoration: BoxDecoration(
//                                                       border: Border.all(
//                                                           color: selectedCreatorId ==
//                                                                   businessDetailsController
//                                                                       .artistsList[
//                                                                           index]
//                                                                       .id!
//                                                               ? defaultAppColor
//                                                               : Colors
//                                                                   .transparent,
//                                                           width: 3),
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               size.width *
//                                                                   0.15)),
//                                                   child: buildCachedNetworkImage(
//                                                       height: size.width * 0.15,
//                                                       width: size.width * 0.15,
//                                                       url: WebService.profileImageUrl +
//                                                           businessDetailsController
//                                                               .artistsList[index]
//                                                               .profileImage!,
//                                                       radius: 50)),
//                                               SizedBox(
//                                                   height: size.height * 0.01),
//                                               Text(
//                                                   businessDetailsController
//                                                       .artistsList[index].name!,
//                                                   maxLines: 1,
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                   style: textTheme.titleMedium!
//                                                       .copyWith(
//                                                           color: kviolet)),
//                                               // Text(
//                                               //   businessDetailsController
//                                               //       .artistsList[index].address!,
//                                               //   style: textTheme.bodyText2,
//                                               // ),
//                                             ],
//                                           ),
//                                         ),
//                                       );
//                                     }))),
//                     const Divider(),
//
//                     //description
//                     Padding(
//                       padding: EdgeInsets.symmetric(
//                           horizontal: size.width * 0.1,
//                           vertical: size.height * 0.005),
//                       child: TextFormField(
//                         controller: imgListController.aboutController,
//                         decoration: const InputDecoration(
//                           hintText: 'הערות',
//                           enabledBorder: UnderlineInputBorder(
//                               borderSide: BorderSide(color: defaultBlack)),
//                           focusedBorder: UnderlineInputBorder(
//                               borderSide: BorderSide(color: defaultBlack)),
//                           errorBorder: UnderlineInputBorder(
//                               borderSide: BorderSide(color: defaultBlack)),
//                         ),
//                       ),
//                     ),
//
//                     //term & conditions
//                     InkWell(
//                       splashColor: Colors.grey,
//                       onTap: () => Get.to(() => const (
//                             url: WebService.termAndConditionUrl,
//                             title: "תנאי שימוש ופרטיות"
//                           )),
//                       child: SizedBox(
//                           child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Checkbox(
//                               value: isTermChecked,
//                               onChanged: (value) {
//                                 setState(() {
//                                   isTermChecked = value!;
//                                 });
//                               },
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(50))),
//                           const Text("קראתי ואישרתי את תנאי השימוש",
//                               style: TextStyle(
//                                   decoration: TextDecoration.underline,
//                                   color: Colors.blue))
//                         ],
//                       )),
//                     ),
//
//                     //continue btn
//                     SizedBox(
//                       width: size.width,
//                       height: size.height * 0.1,
//                       child: !isEnabled
//                           ? const Center(child: CircularProgressIndicator())
//                           : Padding(
//                               padding: const EdgeInsets.all(5.0),
//                               child: buildButton(
//                                   align: Alignment.centerRight,
//                                   size: size,
//                                   width: size.width,
//                                   // text: "business",
//                                   text: "שלח",
//                                   onClick: () async {
//                                     try {
//                                       if (imgListController
//                                           .nameController.text.isEmpty) {
//                                         displayMessageIcon(
//                                             message: "נא להזין שם",
//                                             snackposition: SnackPosition.BOTTOM,
//                                             color: errorColor,
//                                             imageData: AppAssets.errorIcon);
//                                         //Please enter name
//                                         return;
//                                       }
//
//                                       if (imgListController
//                                           .phoneController.text.isEmpty) {
//                                         displayMessageIcon(
//                                             message: "נא להזין מספר טלפון",
//                                             snackposition: SnackPosition.BOTTOM,
//                                             color: errorColor,
//                                             imageData: AppAssets.errorIcon);
//                                         // displayMessage(
//                                         //     "נא להזין מספר טלפון",
//                                         //     Colors
//                                         //         .red); //Please enter phone number
//                                         return;
//                                       }
//
//                                       if (WebService
//                                           .changeUserStyleList.isEmpty) {
//                                         displayMessageIcon(
//                                             message:
//                                                 "alerts.choose_tattoo_style",
//                                             snackposition: SnackPosition.BOTTOM,
//                                             color: errorColor,
//                                             imageData: AppAssets.errorIcon);
//                                         // displayMessage(
//                                         //     "alerts.choose_tattoo_style",
//                                         //     Colors.red); //choose style
//                                         return;
//                                       }
//
//                                       if (!isTermChecked) {
//                                         displayMessageIcon(
//                                             message:
//                                                 "alerts.term_validation_msg",
//                                             snackposition: SnackPosition.BOTTOM,
//                                             color: errorColor,
//                                             imageData: AppAssets.errorIcon);
//                                         // displayMessage(
//                                         //     "alerts.term_validation_msg",
//                                         //     Colors.red); //choose style
//                                         return;
//                                       }
//                                       // if (imgListController.imgList.length != 3) {
//                                       //   displayMessage("Please enter minimum 3 images",
//                                       //       Colors.red); //
//                                       //   return;
//                                       // }
//                                       if (imgListController.bodyParts.value ==
//                                           imgListController
//                                               .blankBodyParts.value) {
//                                         displayMessageIcon(
//                                             message:
//                                                 "alerts.please_select_part",
//                                             snackposition: SnackPosition.BOTTOM,
//                                             color: errorColor,
//                                             imageData: AppAssets.errorIcon);
//                                         // displayMessage(
//                                         //     "alerts.please_select_part",
//                                         //     Colors.red); //
//                                         return;
//                                       }
//
//                                       setState(() {
//                                         isEnabled = false;
//                                       });
//                                       // ShowCapturedWidget(context, capturedImage!);
//
//                                       // uploading images to firebase
//                                       List<RequestImages> imgList = [];
//                                       if (imgListController
//                                           .imgList.value.isNotEmpty) {
//                                         await FireBaseApi
//                                             .userRequestImagesUpload(
//                                                 imgList: imgListController
//                                                     .imgList.value,
//                                                 imgNameList: imgList);
//                                       }
//
//                                       await imgListController
//                                           .captureImage(
//                                               bid: businessDetailsController
//                                                   .id.value,
//                                               screenshotController:
//                                                   screenshotController,
//                                               selectedCreatorId:
//                                                   selectedCreatorId,
//                                               tattooSize: tattooSize,
//                                               imgListDetails: imgList)
//                                           .then((value) {
//                                         setState(() {
//                                           isEnabled = true;
//                                         });
//                                       });
//                                     } catch (e) {
//                                       displayMessageIcon(
//                                           message: e.toString(),
//                                           snackposition: SnackPosition.BOTTOM,
//                                           color: errorColor,
//                                           imageData: AppAssets.errorIcon);
//                                     }
//                                   })), //*נשמר
//                     ),
//                   ],
//                 ),
//               ),
//             )));
//   }
//
//   //show captured screenshot
//   Future<dynamic> ShowCapturedWidget(
//       BuildContext context, Uint8List capturedImage) {
//     return showDialog(
//       useSafeArea: false,
//       context: context,
//       builder: (context) => Scaffold(
//         appBar: AppBar(),
//         body: Center(
//             child: capturedImage != null
//                 ? Image.memory(capturedImage)
//                 : const SizedBox()),
//       ),
//     );
//   }
//
//   //title
//   buildTitle(BuildContext context, size, textTheme) => Container(
//         width: size.width,
//         color: defaultWhite,
//         height: size.height * 0.08,
//         alignment: Alignment.center,
//         child: Obx(() => Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   businessDetailsController.name.value,
//                   style: textTheme.titleLarge,
//                 ),
//                 SizedBox(
//                   width: size.width * 0.02,
//                 ),
//                 ClipOval(
//                   child: Container(
//                     height: size.width * 0.14,
//                     width: size.width * 0.14,
//                     color: Colors.white,
//                     child: Padding(
//                         padding: EdgeInsets.all(size.width * 0.01),
//                         child: buildCachedNetworkImage(
//                             height: size.width * 0.13,
//                             width: size.width * 0.13,
//                             url: businessDetailsController.profile_image.value,
//                             radius: 50)),
//                   ),
//                 )
//               ],
//             )),
//       );
//
//   //form field
//   buildFormField(BuildContext context, Size size, TextTheme textTheme) =>
//       Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.symmetric(
//                 horizontal: size.width * 0.1, vertical: size.height * 0.005),
//             child: TextFormField(
//               controller: imgListController.nameController,
//               decoration: const InputDecoration(
//                 hintText: 'שם',
//                 enabledBorder: UnderlineInputBorder(
//                   borderSide: BorderSide(color: defaultBlack),
//                 ),
//                 focusedBorder: UnderlineInputBorder(
//                   borderSide: BorderSide(color: defaultBlack),
//                 ),
//                 errorBorder: UnderlineInputBorder(
//                   borderSide: BorderSide(color: defaultBlack),
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.symmetric(
//                 horizontal: size.width * 0.1, vertical: size.height * 0.005),
//             child: TextFormField(
//               controller: imgListController.phoneController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 hintText: 'טלפון',
//                 enabledBorder: UnderlineInputBorder(
//                   borderSide: BorderSide(color: defaultBlack),
//                 ),
//                 focusedBorder: UnderlineInputBorder(
//                   borderSide: BorderSide(color: defaultBlack),
//                 ),
//                 errorBorder: UnderlineInputBorder(
//                   borderSide: BorderSide(color: defaultBlack),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       );
//
//   //tattoo size and select image
//   buildSizeAndImages(BuildContext context, Size size, TextTheme textTheme) =>
//       Padding(
//         padding: EdgeInsets.symmetric(horizontal: size.width * 0.01),
//         child: IntrinsicHeight(
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               //add images
//               Obx(() => SizedBox(
//                     width: size.width * 0.4,
//                     height: size.height * 0.1,
//                     child: imgListController.imgList.isNotEmpty
//                         ? InkWell(
//                             onTap: () =>
//                                 Get.to(() => const BodyPartsImageScreens()),
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
//                                   top: 20,
//                                   right: 40,
//                                   height: size.width * 0.15,
//                                   width: size.width * 0.15,
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                         color: Colors.grey.shade300,
//                                         border: Border.all(color: Colors.white),
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                     width: size.width * 0.1,
//                                     height: size.width * 0.1,
//                                     child: const SizedBox(),
//                                   ),
//                                 ),
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
//                                             image: FileImage(File(
//                                                 imgListController
//                                                     .imgList[0].path)),
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
//                                             "${imgListController.imgList.length} +"))),
//                               ],
//                             ),
//                           )
//                         : ElevatedButton.icon(
//                             onPressed: () =>
//                                 Get.to(() => const BodyPartsImageScreens()),
//                             style: ElevatedButton.styleFrom(
//                                 elevation: 0,
//                                 shadowColor: Colors.transparent,
//                                 backgroundColor: Colors.transparent),
//                             icon: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(Icons.add_photo_alternate_outlined,
//                                     color: Colors.black,
//                                     size: size.width * 0.08),
//                                 const SizedBox(height: 4),
//                                 const Text('3 תמונות להשראה',
//                                     style: TextStyle(color: Colors.black))
//                               ],
//                             ),
//                             label: const Text(''),
//                           ),
//                   )),
//               const VerticalDivider(color: kDivider),
//               //select tattoo size
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Text("גודל הקעקוע"),
//                   SizedBox(height: size.height * 0.02),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       //little
//                       OutlinedButton(
//                         onPressed: () => setState(() {
//                           isLittle = true;
//                           isMedium = false;
//                           isBig = false;
//                           tattooSize = "L";
//                         }),
//                         style: OutlinedButton.styleFrom(
//                           // backgroundColor:
//                           //     isLittle ? defaultAppColor : Colors.white,
//                           side: BorderSide(
//                               color: isLittle ? defaultAppColor : Colors.grey),
//                           shape: const CircleBorder(),
//                           padding: EdgeInsets.all(size.height * 0.022),
//                         ),
//                         child: Text("קטן",
//                             style: TextStyle(
//                                 color:
//                                     !isLittle ? Colors.grey : defaultAppColor)),
//                       ),
//                       //medium
//                       OutlinedButton(
//                         onPressed: () => setState(() {
//                           isLittle = false;
//                           isMedium = true;
//                           isBig = false;
//                           tattooSize = "M";
//                         }),
//                         style: OutlinedButton.styleFrom(
//                           // backgroundColor:
//                           //     isMedium ? defaultAppColor : Colors.white,
//                           textStyle: TextStyle(
//                               color: !isMedium ? Colors.grey : defaultAppColor),
//                           side: BorderSide(
//                               color: !isMedium ? Colors.grey : defaultAppColor),
//                           shape: const CircleBorder(),
//                           padding: EdgeInsets.all(size.height * 0.022),
//                         ),
//                         child: Text("בינוני",
//                             style: TextStyle(
//                                 color:
//                                     !isMedium ? Colors.grey : defaultAppColor)),
//                       ),
//                       //big
//                       OutlinedButton(
//                         onPressed: () => setState(() {
//                           isLittle = false;
//                           isMedium = false;
//                           isBig = true;
//                           tattooSize = "B";
//                         }),
//                         style: OutlinedButton.styleFrom(
//                           // backgroundColor:
//                           //     isBig ? defaultAppColor : Colors.white,
//                           side: BorderSide(
//                               color: !isBig ? Colors.grey : defaultAppColor),
//                           shape: const CircleBorder(),
//                           padding: EdgeInsets.all(size.height * 0.022),
//                         ),
//                         child: Text("גדול",
//                             style: TextStyle(
//                                 color: !isBig ? Colors.grey : defaultAppColor)),
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//             ],
//           ),
//         ),
//       );
//
//   buildStyleList(BuildContext context, Size size, TextTheme textTheme) =>
//       Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             Align(
//               alignment: Alignment.centerRight,
//               child: Text('סגנון הקעקוע',
//                   style: textTheme.titleMedium!
//                       .copyWith(color: kBlack, fontWeight: FontWeight.bold)),
//             ),
//             SizedBox(
//               height: size.height * 0.07,
//               child: ListView.builder(
//                   reverse: false,
//                   shrinkWrap: true,
//                   scrollDirection: Axis.horizontal,
//                   itemCount: listStyles.length,
//                   itemBuilder: (BuildContext context, int index) =>
//                       GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             if (!WebService.changeUserStyleList
//                                 .contains(listStyles[index])) {
//                               setState(() {
//                                 WebService.changeUserStyleList
//                                     .add(listStyles[index]);
//                               });
//                             } else {
//                               setState(() {
//                                 WebService.changeUserStyleList
//                                     .remove(listStyles[index]);
//                               });
//                             }
//                           });
//                         },
//                         child: Container(
//                           margin: EdgeInsets.symmetric(
//                               vertical: size.height * 0.005,
//                               horizontal: size.width * 0.01),
//                           padding: EdgeInsets.symmetric(
//                               vertical: size.height * 0.005,
//                               horizontal: size.width * 0.01),
//                           alignment: Alignment.center,
//                           child: IntrinsicHeight(
//                             child: Row(
//                               children: [
//                                 Text(listStyles[index].name!,
//                                     style: TextStyle(
//                                         color: WebService.changeUserStyleList
//                                                 .contains(listStyles[index])
//                                             ? Theme.of(context).primaryColor
//                                             : Colors.black)),
//                                 SizedBox(width: size.width * 0.02),
//                                 const VerticalDivider(
//                                     width: 2, thickness: 2, color: kBlack),
//                               ],
//                             ),
//                           ),
//                         ),
//                       )),
//             ),
//           ],
//         ),
//       );
// }
