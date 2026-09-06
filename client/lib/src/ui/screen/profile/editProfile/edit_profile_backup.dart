// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/controller/userController.dart';
// import 'package:ink/src/utils/colors.dart';
//
// import '../../../../utils/common.dart';
// import 'edit_screen.dart';
//
// class EditProfileBackup extends StatefulWidget {
//   const EditProfileBackup({Key? key}) : super(key: key);
//
//   @override
//   State<EditProfileBackup> createState() => _EditProfileBackupState();
// }
//
// class _EditProfileBackupState extends State<EditProfileBackup> {
//   final UserController userController = Get.put(UserController());
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       appBar: AppBar(
//         toolbarHeight: size.height * 0.1,
//         backgroundColor: appbar2Bg,
//         centerTitle: true,
//         title: const Text("ניהול פרופיל"),
//         leading: IconButton(
//             onPressed: () => Get.back(),
//             icon: const Icon(Icons.arrow_back_ios)),
//       ),
//       body: ListView(
//         children: [
//           SizedBox(height: size.height * 0.02),
//           //studio title
//           // Row(
//           //   mainAxisAlignment: MainAxisAlignment.center,
//           //   children: [
//           //     Image.asset("assets/icons/ic_multi_user.png",
//           //         height: size.width * 0.2,
//           //         width: size.width * 0.2,
//           //         color: defaultAppColor),
//           //     const Text(" סטודיו>>מנהל"),
//           //   ],
//           // ),
//           // //name
//           // const Divider(thickness: 2),
//           buildListTile(
//               size: size,
//               title: "שם",
//               onClick: () =>
//                   Get.to(const EditScreen(editTitle: "שם", editIndex: 0))),
//
//           //address
//           const Divider(thickness: 2),
//           buildListTile(
//               size: size,
//               title: "כתובת",
//               onClick: () => Get.to(const EditScreen(
//                   editTitle: "עריכת כתובת", editIndex: 1))), //address
//
//           //about
//           const Divider(thickness: 2),
//           buildListTile(
//               size: size,
//               title: "אודות",
//               onClick: () =>
//                   Get.to(const EditScreen(editTitle: "אודות", editIndex: 2))),
//
//           //update members
//           const Divider(thickness: 2),
//           buildListTile(
//               size: size,
//               title: userController.businessType.value == "2"
//                   ? "txt.ttl_add_member_artist"
//                   : "צוות",
//               onClick: () => Get.to(EditScreen(
//                   editTitle: userController.businessType.value == "2"
//                       ? "txt.ttl_add_member_artist"
//                       : "צוות הסטודיו",
//                   editIndex: 3))),
//
//           //profileImage
//           const Divider(thickness: 2),
//           buildListTile(
//               size: size,
//               title: "תמונת פרופיל",
//               onClick: () => Get.to(const EditScreen(
//                   editTitle: "עריכת תמונת פרופיל",
//                   editIndex: 4))), //profileImage
//
//           const Divider(thickness: 2),
//           SizedBox(height: size.height * 0.1),
//
//           //delete account btn
//           Center(
//             child: OutlinedButton.icon(
//                 style: OutlinedButton.styleFrom(
//                     side: const BorderSide(color: Colors.grey),
//                     foregroundColor: Colors.black,
//                     padding: EdgeInsets.symmetric(
//                         horizontal: size.width * 0.1,
//                         vertical: size.height * 0.02)),
//                 icon: Image.asset("assets/icons/ic_delete.png",
//                     width: size.width * 0.03),
//                 onPressed: () => buildDeleteDialog(
//                     context,
//                     () async => await userController
//                         .deleteAccount()
//                         .then((value) => Get.back())),
//                 label: const Text("מחיקת פרופיל")),
//           ),
//         ],
//       ),
//     );
//   }
//
//   buildListTile({required size, required title, required onClick}) => ListTile(
//       leading:
//           Text(title, style: const TextStyle(fontWeight: FontWeight.bold)).tr(),
//       trailing: const Icon(Icons.arrow_right),
//       onTap: onClick);
// }
