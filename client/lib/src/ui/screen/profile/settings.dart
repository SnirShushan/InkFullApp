// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/controller/userController.dart';
// import 'package:location/location.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// import '../../../utils/colors.dart';
// import '../../../utils/common.dart';
// import 'select_category.dart';
//
// class Settings extends StatefulWidget {
//   const Settings({Key? key}) : super(key: key);
//
//   @override
//   State<Settings> createState() => _SettingsState();
// }
//
// class _SettingsState extends State<Settings> {
//   bool? isNotificationChecked = false;
//   bool? isLocationChecked = true;
//
//   final userController = Get.put(UserController());
//
//   PackageInfo _packageInfo = PackageInfo(
//     appName: 'Unknown',
//     packageName: 'Unknown',
//     version: 'Unknown',
//     buildNumber: 'Unknown',
//     buildSignature: 'Unknown',
//     installerStore: 'Unknown',
//   );
//
//   bool _locationPermissionGranted = false;
//
//   void _checkLocationPermissionStatus() async {
//     var status = await Permission.location.status;
//     setState(() {
//       _locationPermissionGranted = status.isGranted;
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _checkLocationPermissionStatus();
//     _initPackageInfo();
//   }
//
//   Future<void> _initPackageInfo() async {
//     final info = await PackageInfo.fromPlatform();
//     setState(() {
//       _packageInfo = info;
//     });
//   }
//
//   void _requestLocationPermission(bool value) async {
//     Location location = Location();
//     if (value) {
//       // Enable location services
//       if (!await location.serviceEnabled()) {
//         bool serviceStatus = await location.requestService();
//         setState(() {
//           print("serviceStatus1 $serviceStatus");
//         });
//       }
//     } else {
//       if (await location.serviceEnabled()) {
//         bool serviceStatus = await location.requestService();
//         setState(() {
//           print("serviceStatus2 $serviceStatus");
//         });
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       appBar: buildappBarwithback(size: size, title: "הגדרות"),
//       body: Obx(() => Column(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 children: [
//                   // buildCheckListTile(
//                   //     size: size,
//                   // title: "מיקום",
//                   //     isEnabled: userController.locationEnable.value == true
//                   //         ? true
//                   //         : false,
//                   //     onChange: (value) async {
//                   //       await userController
//                   //           .updateLocationEnabled(
//                   //               isLocationEnabled:
//                   //                   userController.locationEnable.value == true
//                   //                       ? "2"
//                   //                       : "1")
//                   //           .then(
//                   //               (value1) => _requestLocationPermission(value));
//                   //     }),
//                   // const Divider(thickness: 2),
//                   buildCheckListTile(
//                       size: size,
//                       title: "התראות",
//                       isEnabled:
//                           userController.pushEnabl.value == true ? false : true,
//                       onChange: (value) async {
//                         await userController.updatePushEnabled(
//                             isPushEnabled:
//                                 userController.pushEnabl.value == true
//                                     ? "2"
//                                     : "1");
//                       }),
//                   const Divider(thickness: 2),
//                   buildListTile(
//                       size: size,
//                       title: "עריכת סגנון",
//                       onClick: () =>
//                           Get.to(() => SelectCategory(fromProfile: true))),
//                   const Divider(thickness: 2),
//                   buildListTile(size: size, title: "גרסה", onClick: () {}),
//                   const Divider(thickness: 2),
//                   SizedBox(height: size.height * 0.05),
//                   Center(
//                     child: OutlinedButton.icon(
//                         style: OutlinedButton.styleFrom(
//                             foregroundColor: Colors.black,
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: size.width * 0.1,
//                                 vertical: size.height * 0.02)),
//                         icon: Image.asset("assets/icons/ic_delete.png",
//                             width: size.width * 0.03),
//                         onPressed: () => buildDeleteDialog(
//                             context,
//                             () async => await userController
//                                 .deleteAccount()
//                                 .then((value) => Get.back())),
//                         label: const Text("מחיקת פרופיל")),
//                   ),
//                 ],
//               ),
//             ],
//           )),
//     );
//   }
//
//   buildCheckListTile(
//           {required size,
//           required title,
//           required isEnabled,
//           required onChange}) =>
//       SizedBox(
//           height: size.height * 0.08,
//           width: size.width,
//           child: SwitchListTile.adaptive(
//             contentPadding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
//             title: Text(title),
//             inactiveTrackColor: Colors.grey,
//             // activeTrackColor: Colors.grey,
//             inactiveThumbColor: Colors.grey,
//             activeColor: appPrimaryColor,
//             isThreeLine: false,
//             // activeThumbImage: const AssetImage("assets/icons/switch_red.png"),
//             // inactiveThumbImage: const AssetImage("assets/icons/switch_green.png"),
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//             value: isEnabled!,
//             onChanged: onChange,
//           ));
//
//   buildListTile({required size, required title, required onClick}) => ListTile(
//       onTap: onClick,
//       title: Text(title),
//       trailing: title == "גרסה"
//           ? Text(_packageInfo.version,
//               style: const TextStyle(fontWeight: FontWeight.bold))
//           : Icon(Icons.arrow_right, size: size.width * 0.08));
// }
