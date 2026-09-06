// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/controller/userController.dart';
// import 'package:ink/src/data/model/currentUser.dart';
// import 'package:ink/src/utils/common.dart';
// import 'package:ink/src/utils/webService.dart';
//
// import '../../../../utils/colors.dart';
// import '../../../widgets/side_drawer.dart';
// import '../../../widgets/unfocus_widget.dart';
// import '../../business_user/dashboard/business_dashboard_backup.dart';
// import '../../business_user/dashboard/bussinessdashboard_binding.dart';
// import '../../dashboard/dashboard.dart';
// import '../../dashboard/dashboard_binding.dart';
//
// class SelectCategoryBackup extends StatefulWidget {
//   final bool fromProfile;
//   const SelectCategoryBackup({Key? key, required this.fromProfile})
//       : super(key: key);
//
//   @override
//   State<SelectCategoryBackup> createState() => _SelectCategoryBackupState();
// }
//
// class _SelectCategoryBackupState extends State<SelectCategoryBackup> {
//   List<StylesList> selectedList = [];
//   final userController = Get.put(UserController());
//   @override
//   void initState() {
//     super.initState();
//     getUserData();
//   }
//
//   void getData() {
//     List<String> stringList = userController.styles.value.split(",");
//     for (int i = 0; i < stringList.length; i++) {
//       for (int j = 0; j < userController.style_list.length; j++) {
//         if (stringList[i] == userController.style_list.value[j].slug!) {
//           selectedList.add(userController.style_list.value[j]);
//         }
//       }
//     }
//     setState(() {});
//   }
//
//   Future<void> getUserData() async {
//     await userController.initUser();
//     getData();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return UnFocusWidget(
//         child: Scaffold(
//       appBar: AppBar(
//           elevation: 0,
//           backgroundColor: appbarBg,
//           automaticallyImplyLeading: false,
//           actions: [
//             !widget.fromProfile
//                 ? Padding(
//                     padding: EdgeInsets.all(size.width * 0.02),
//                     child: Center(
//                         child: InkWell(
//                             onTap: () {
//                               if (userController.userType.value == "2") {
//                                 Get.offAll(BusinessDashBoard(initialIndex: 0,),
//                                     binding: BusinessDashBoardBinding());
//                               } else {
//                                 Get.offAll(const DashBoard(initialIndex: 3),
//                                     binding: DashBoardBinding());
//                               }
//                             },
//                             child: Text("דלג",
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .titleMedium!
//                                     .copyWith(fontWeight: FontWeight.bold)))))
//                 : SizedBox()
//           ],
//           centerTitle: true,
//           toolbarHeight: size.height * 0.1,
//           title: Text("בחירת סגנון אישי",
//               style: TextStyle(
//                   color: Colors.black,
//                   fontWeight: FontWeight.bold,
//                   fontSize: size.height * 0.02))),
//       drawer: const SideDrawer(),
//       bottomSheet: selectedList.isNotEmpty
//           ? SizedBox(
//               height: size.height * 0.1,
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
//                 child: Center(
//                     child: buildButton(
//                         align: Alignment.centerRight,
//                         size: size,
//                         width: size.width,
//                         // text: "business",
//                         text: "שמור",
//                         onClick: () async {
//                           String newString = "";
//                           if (selectedList != null) {
//                             selectedList.forEach((v) {
//                               if (v == selectedList.last) {
//                                 newString += v.slug!;
//                               } else {
//                                 newString += "${v.slug},";
//                               }
//                             });
//                             WebService.printMsg(newString);
//                           }
//                           await userController
//                               .updateStyles(styles: newString)
//                               .then((value) => displayMessage(
//                                   "השינויים נשמרו", appPrimaryColor));
//                         })),
//               ))
//           : SizedBox(),
//       body: Column(
//         children: [
//           Container(
//             width: double.infinity,
//             alignment: Alignment.center,
//             height: size.height * 0.07,
//             decoration: const BoxDecoration(boxShadow: [
//               BoxShadow(
//                   color: Colors.black,
//                   blurRadius: 5.0,
//                   offset: Offset(0.0, 0.45))
//             ], color: Colors.white),
//             child: const Text("*בחר סגנון אהוב"),
//           ),
//           SizedBox(height: size.height * 0.01),
//           //category list
//           Expanded(
//             child: GridView.builder(
//                 shrinkWrap: true,
//                 scrollDirection: Axis.vertical,
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     mainAxisExtent: size.height * 0.25,
//                     crossAxisSpacing: 3),
//                 itemCount: userController.style_list.value.length,
//                 itemBuilder: (BuildContext context, int index) {
//                   return GestureDetector(
//                     onTap: () => setState(() {
//                       if (!selectedList
//                           .contains(userController.style_list.value[index])) {
//                         if (selectedList.length <= 4) {
//                           selectedList
//                               .add(userController.style_list.value[index]);
//                         }
//                       } else {
//                         selectedList
//                             .remove(userController.style_list.value[index]);
//                       }
//                     }),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         Card(
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(30)),
//                           color: selectedList.contains(
//                                   userController.style_list.value[index])
//                               ? Colors.purple
//                               : Colors.white,
//                           elevation: 8,
//                           child: Container(
//                             foregroundDecoration: BoxDecoration(
//                                 color: !selectedList.contains(
//                                         userController.style_list.value[index])
//                                     ? Colors.white.withOpacity(0.4)
//                                     : null),
//                             margin: selectedList.contains(
//                                     userController.style_list.value[index])
//                                 ? EdgeInsets.all(size.width * 0.01)
//                                 : null,
//                             child: buildCachedNetworkImage(
//                                 height: size.width * 0.27,
//                                 width: size.width * 0.27,
//                                 url: WebService.styleImgUrl +
//                                     userController.style_list[index].imageName!,
//                                 radius: 30),
//                           ),
//                         ),
//                         Text(userController.style_list[index].name!),
//                         Text(userController.style_list[index].nameEn!)
//                       ],
//                     ),
//                   );
//                 }),
//           ),
//           SizedBox(height: size.height * 0.07),
//           // InkWell(
//           //   onTap: () async {
//           //     String newString = "";
//           //     if (selectedList != null) {
//           //       selectedList.forEach((v) {
//           //         if (v == selectedList.last) {
//           //           newString += v.slug!;
//           //         } else {
//           //           newString += "${v.slug},";
//           //         }
//           //       });
//           //       WebService.printMsg(newString);
//           //     }
//           //
//           //     await userController.updateStyles(styles: newString);
//           //   },
//           //   child: Container(
//           //     color: defaultBlack,
//           //     height: size.width * 0.15,
//           //     width: size.width,
//           //     child: Center(
//           //         child: Text("שמור",
//           //             style: TextStyle(
//           //                 color: Colors.white, fontSize: size.width * 0.03))),
//           //   ),
//           // )
//         ],
//       ),
//     ));
//   }
// }
