// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/data/model/postDetails.dart';
// import 'package:ink/src/ui/screen/home/controller/post_details_controller.dart';
// import 'package:ink/src/utils/common.dart';
//
// import '../../../widgets/unfocus_widget.dart';
// import 'changeArtist.dart';
// import 'edit_styles.dart';
//
// class EditImage extends StatefulWidget {
//   final MPostDetails postModel;
//   final String businesstype;
//   const EditImage(
//       {Key? key, required this.postModel, required this.businesstype})
//       : super(key: key);
//
//   @override
//   State<EditImage> createState() => _EditImageState();
// }
//
// class _EditImageState extends State<EditImage> {
//   final postDetailController = Get.put(PostDetailsController());
//   final TextEditingController descriptionController = TextEditingController();
//   bool isLoading = false;
//   @override
//   void initState() {
//     super.initState();
//     if (postDetailController.postModel.value.description != "") {
//       descriptionController.text =
//           postDetailController.postModel.value.description!;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return UnFocusWidget(
//         child: Scaffold(
//       appBar: buildappBarwithClose(size: size, title: "עריכת תמונה"),
//       bottomSheet: isLoading
//           ? const Align(
//               alignment: Alignment.bottomCenter,
//               child: CircularProgressIndicator())
//           : SizedBox(
//               height: Get.height * 0.1,
//               child: Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: buildButton(
//                       align: Alignment.bottomCenter,
//                       size: Get.size,
//                       width: double.infinity,
//                       text: "btn.save",
//                       onClick: () async {
//                         if (descriptionController.text == "" ||
//                             descriptionController.text == null) {
//                           displayMessage("נא להזין תיאור", Colors.red);
//                         } else {
//                           setState(() {
//                             isLoading = true;
//                           });
//                           FocusScope.of(context).unfocus();
//                           await postDetailController
//                               .updatePost(
//                                   description: descriptionController.text,
//                                   postId:
//                                       postDetailController.postModel.value.id)
//                               .then((value) => setState(() {
//                                     isLoading = false;
//                                   }));
//                         }
//                       }))),
//       body: Obx(() => ListView(
//             shrinkWrap: true,
//             padding: EdgeInsets.all(size.width * 0.03),
//             children: [
//               SizedBox(height: size.height * 0.02),
//               const Text("תאור התמונה"),
//               SizedBox(height: size.height * 0.02),
//               //description
//               SizedBox(
//                   height: size.height * 0.1,
//                   child: TextFormField(
//                       controller: descriptionController,
//                       decoration:
//                           const InputDecoration(border: InputBorder.none),
//                       minLines: 3,
//                       maxLines: null,
//                       keyboardType: TextInputType.multiline,
//                       textDirection: TextDirection.rtl,
//                       inputFormatters: [
//                         LengthLimitingTextInputFormatter(400),
//                       ],
//                       validator: (String? value) {
//                         if (value!.length < 400) {
//                           return ' התיאור ארוך מדי'; //description is to long
//                         }
//                       })),
//               //styles
//               ListTile(
//                   trailing: const Icon(Icons.arrow_right),
//                   onTap: () {
//                     FocusScope.of(context).unfocus();
//                     Get.to(() => EditStyles());
//                   },
//                   title: const Text('סגנון')),
//               //change artist
//               postDetailController.postModel.value.owner!.businessType == "1"
//                   ? (postDetailController.postModel.value.artist != null
//                       ? ListTile(
//                           trailing: SizedBox(
//                               width: Get.width * 0.25,
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.end,
//                                 children: const [
//                                   Text("בחר מקעקע"),
//                                   Icon(Icons.arrow_right),
//                                 ],
//                               )), //Add : Change
//                           onTap: () {
//                             FocusScope.of(context).unfocus();
//                             Get.to(() => ChangeArtist(
//                                 pid: postDetailController.postModel.value.id
//                                     .toString()));
//                           },
//                           leading: buildOwnerProfileImage(
//                               size: size,
//                               ownerImage: postDetailController
//                                   .postModel.value.artist!.profileImage!
//                                   .toString()),
//                           title: Text(postDetailController
//                               .postModel.value.artist!.name!))
//                       : ListTile(
//                           trailing:
//                               const Icon(Icons.arrow_right), //Add : Change
//                           onTap: () {
//                             FocusScope.of(context).unfocus();
//                             Get.to(() => ChangeArtist(
//                                 pid: postDetailController.postModel.value.id
//                                     .toString()));
//                           },
//                           title: const Text("בחר מקעקע")))
//                   : const SizedBox()
//             ],
//           )),
//     ));
//   }
// }
