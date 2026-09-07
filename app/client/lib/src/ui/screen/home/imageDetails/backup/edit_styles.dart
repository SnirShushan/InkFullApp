// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/ui/screen/home/controller/post_details_controller.dart';
//
// import '../../../../data/model/currentUser.dart';
// import '../../../../utils/common.dart';
// import '../../../../utils/webService.dart';
// import '../../../widgets/unfocus_widget.dart';
//
// class EditStyles extends StatefulWidget {
//   const EditStyles({Key? key}) : super(key: key);
//
//   @override
//   State<EditStyles> createState() => _EditStylesState();
// }
//
// class _EditStylesState extends State<EditStyles> {
//   final TextEditingController searchController = TextEditingController();
//   late AppUser user;
//   List<StylesList> listStyles = [];
//   List<StylesList> filteredListStyles = [];
//   List<StylesList> selectedList = [];
//   final postDetailController = Get.put(PostDetailsController());
//   bool isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     getUserStyleList();
//   }
//
//   //get styles
//   Future getUserStyleList() async {
//     user = await WebService.getCurrentUser();
//
//     user.stylesList?.map((doc) {
//       WebService.printMsg("user styles");
//       WebService.printMsg(postDetailController.postModel.value.styles!);
//       if (postDetailController.postModel.value.styles!.contains(doc.slug!)) {
//         selectedList.add(doc);
//       }
//
//       listStyles.add(doc);
//     }).toList();
//     user.stylesList?.map((doc) {
//       filteredListStyles.add(doc);
//     }).toList();
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return UnFocusWidget(
//         child: Scaffold(
//       appBar: buildappBarwithClose(size: Get.size, title: "בחירת סגנונות"),
//       bottomSheet:
//       isLoading
//           ?
//       //progress
//       const Align(
//               alignment: Alignment.bottomCenter,
//               child: CircularProgressIndicator())
//           :
//       //save button
//       SizedBox(
//               height: Get.height * 0.1,
//               child: Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: buildButton(
//                       align: Alignment.bottomCenter,
//                       size: Get.size,
//                       width: double.infinity,
//                       text: "btn.continue",
//                       onClick: () async {
//                         String styleList = "";
//                         if (selectedList.isEmpty) {
//                           displayMessage("אנא בחר סגנון",
//                               Colors.red); //Please select style
//                           return;
//                         }
//                         selectedList.forEach((v) {
//                           if (v == selectedList.last) {
//                             styleList += "${v.slug}";
//                           } else {
//                             styleList += "${v.slug},";
//                           }
//                         });
//                         setState(() {
//                           isLoading = true;
//                         });
//                         await postDetailController
//                             .updatePost(
//                                 styles: styleList,
//                                 postId: postDetailController.postModel.value.id)
//                             .then((value) => setState(() {
//                                   isLoading = false;
//                                   Get.back();
//                                 }));
//                       })),
//             ),
//       body: SizedBox(
//         height: Get.size.height,
//         child: Column(
//           children: [
//             SizedBox(height: Get.size.height * 0.05),
//             const Text('תייג סגנון התמונה'),
//             Expanded(
//               flex: 1,
//               child: ListView.builder( //styles list
//                   physics: const BouncingScrollPhysics(),
//                   scrollDirection: Axis.vertical,
//                   itemCount: listStyles.length,
//                   itemBuilder: (context, index) {
//                     return Card(
//                       key: ValueKey(listStyles[index].name),
//                       margin: const EdgeInsets.all(0),
//                       shape: const RoundedRectangleBorder(
//                           borderRadius: BorderRadius.all(Radius.zero)),
//                       elevation: 0,
//                       color: selectedList.contains(listStyles[index])
//                           ? Theme.of(context).primaryColor
//                           : Colors.transparent,
//                       child: ListTile(
//                           onTap: () => setState(() {
//                                 if (!selectedList.contains(listStyles[index])) {
//                                   selectedList.add(listStyles[index]);
//                                 } else {
//                                   selectedList.remove(listStyles[index]);
//                                 }
//                               }),
//                           title: Text("#" + listStyles[index].name!,
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                   color:
//                                       selectedList.contains(listStyles[index])
//                                           ? Colors.white
//                                           : Colors.black))),
//                     );
//                   })),
//             SizedBox(height: Get.size.height * 0.1)]))));
//   }
// }
//
// // Container(
// // width: Get.size.width,
// // padding: EdgeInsets.symmetric(
// // vertical: Get.size.width * 0.05,
// // horizontal: Get.size.width * 0.05),
// // color: selectedList.contains(listStyles[index])
// // ? defaultAppColor
// //     : Colors.white,
// // child: Center(
// // child: Text("#" + listStyles[index].name!),
// // ),
// // )
