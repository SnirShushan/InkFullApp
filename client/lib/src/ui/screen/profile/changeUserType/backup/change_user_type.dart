// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
// import 'package:get/get.dart';
// import 'package:google_api_headers/google_api_headers.dart';
// import 'package:google_maps_webservice/places.dart';
// import 'package:ink/src/data/model/currentUser.dart';
// import 'package:ink/src/utils/colors.dart';
// import 'package:ink/src/utils/common.dart';
// import 'package:ink/src/utils/webService.dart';
//
// import '../../../../widgets/unfocus_widget.dart';
// import '../tagmembers.dart';
//
// class ScreenChangeUserTypeBackup extends StatefulWidget {
//   const ScreenChangeUserTypeBackup({Key? key}) : super(key: key);
//
//   @override
//   State<ScreenChangeUserTypeBackup> createState() =>
//       _ScreenChangeUserTypeBackupState();
// }
//
// class _ScreenChangeUserTypeBackupState
//     extends State<ScreenChangeUserTypeBackup> {
//   bool isStudio = false;
//   bool isArtist = false;
//
//   final _formKey = GlobalKey<FormState>();
//   final studioNameController = TextEditingController();
//   final studioAddressController = TextEditingController();
//   final aboutController = TextEditingController();
//
//   final GlobalKey<ScaffoldState> homeScaffoldKey = GlobalKey<ScaffoldState>();
//   final searchScaffoldKey = GlobalKey<ScaffoldState>();
//
//   late final AppUser user;
//   List<StylesList> listStyles = [];
//   @override
//   void initState() {
//     super.initState();
//     WebService.changeUserStyleList.clear();
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
//   bool isAddressEmpty = true;
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return UnFocusWidget(
//         child: WillPopScope(
//             onWillPop: () => exitRegistrationDialog(size, context),
//             child: Scaffold(
//                 key: homeScaffoldKey,
//                 appBar: buildRegistrationAppbar(
//                     size: size, title: "פתיחת פרופיל עסקי", context: context),
//                 body: SingleChildScrollView(
//                     child: Column(children: [
//                   SizedBox(height: size.height * 0.01),
//                   const Text("הרשמה"),
//                   Center(
//                       child: SizedBox(
//                           width: size.width * 0.5,
//                           child: const Divider(thickness: 2))),
//                   buildArtistOrStudioSelection(size: size),
//                   const Divider(thickness: 2),
//
//                   //name and address
//                   buildTextFields(size: size),
//                   Divider(thickness: 2, height: size.height * 0.02),
//                   const Center(
//                       child:
//                           Text("בחר מספר סגנונות שמתארים בהם הסטודיו מתמחה")),
//                   SizedBox(height: size.height * 0.02),
//
//                   //horizontal styles view
//                   buildStyleList(size: size),
//                   const Text("כמה מילים על הסטודיו"),
//
//                   //description
//                   buildAboutTextField(size: size),
//                   SizedBox(height: size.height * 0.01),
//
//                   //next button
//                   SizedBox(
//                       height: size.height * 0.1,
//                       child: Padding(
//                           padding: EdgeInsets.symmetric(
//                               horizontal: size.width * 0.02),
//                           child: Center(
//                               child: buildButton(
//                                   align: Alignment.centerRight,
//                                   size: size,
//                                   width: size.width,
//                                   // text: "business",
//                                   text: "שמור",
//                                   onClick: () {
//                                     FocusScope.of(context).unfocus();
//
//                                     if (isStudio == false &&
//                                         isArtist == false) {
//                                       displayMessage(
//                                           "alerts.select_business", Colors.red);
//                                     } else if (studioNameController
//                                         .text.isEmpty) {
//                                       displayMessage(
//                                           "alerts.enter_name", Colors.red);
//                                     } else if (studioAddressController
//                                         .text.isEmpty) {
//                                       displayMessage(
//                                           "alerts.enter_address", Colors.red);
//                                     } else if (WebService
//                                         .changeUserStyleList.isEmpty) {
//                                       displayMessage(
//                                           "alerts.select_style", Colors.red);
//                                     } else if (aboutController.text.isEmpty) {
//                                       displayMessage("alerts.enter_description",
//                                           Colors.red);
//                                     } else {
//                                       setState(() {
//                                         WebService.name =
//                                             studioNameController.text;
//                                         WebService.address =
//                                             studioAddressController.text;
//                                         WebService.aboutText =
//                                             aboutController.text;
//                                         WebService.memberList.clear();
//                                         Get.to(() => TagMembers());
//                                       });
//                                     }
//                                   }))))
//                 ])))));
//   }
//
//   //toggle studio or artist
//   buildArtistOrStudioSelection({required Size size}) => SizedBox(
//       height: size.height * 0.15,
//       width: size.width,
//       child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//         Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//           buildIconWidget(
//               isFill: isArtist,
//               size: size.width * 0.2,
//               iconPath: "ic_one_user.png",
//               afterTapIcon: "ic_one_user_fill.png",
//               onClick: () {
//                 isStudio = false;
//                 isArtist = true;
//                 WebService.isArtist = "2";
//                 setState(() {});
//               }),
//           const Text("מקעקע פרטי"),
//         ]),
//         SizedBox(width: size.width * 0.1),
//         Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//           buildIconWidget(
//               isFill: isStudio,
//               size: size.width * 0.2,
//               iconPath: "ic_multi_user.png",
//               afterTapIcon: "ic_multi_user_fill.png",
//               onClick: () {
//                 isArtist = false;
//                 isStudio = true;
//                 WebService.isArtist = "1";
//                 setState(() {});
//               }),
//           const Text("סטודיו")
//         ])
//       ]));
//
//   //name,email,address
//   buildTextFields({required Size size}) => Container(
//       padding: EdgeInsets.only(left: size.width * 0.1, right: size.width * 0.1),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           children: [
//             //name
//             SizedBox(
//               height: size.height * 0.1,
//               width: size.width,
//               child: Column(
//                 children: [
//                   TextFormField(
//                     controller: studioNameController,
//                     inputFormatters: [
//                       LengthLimitingTextInputFormatter(50),
//                     ],
//                     autovalidateMode: AutovalidateMode.onUserInteraction,
//                     validator: (String? str) {
//                       if (str == null || str.isEmpty) {
//                         return "נא להזין שם"; //Please enter name
//                       } else if (str.length >= 50) {
//                         return "השם ארוך מדי"; //name is to long
//                       }
//                     },
//                     decoration: InputDecoration(
//                       label: Text(isArtist ? "שם המקעקע" : "שם הסטודיו"),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//             //address
//             SizedBox(
//               height: size.height * 0.1,
//               width: size.width,
//               child: TextFormField(
//                 controller: studioAddressController,
//                 autovalidateMode: AutovalidateMode.onUserInteraction,
//                 validator: (str) {
//                   if (str == null || str.isEmpty) {
//                     return "נא להזין כתובת חוקית"; //Please enter valid address
//                   }
//                 },
//                 onTap: studioAddressController.text.length > 1
//                     ? () {}
//                     : () async {
//                         var place = await PlacesAutocomplete.show(
//                             context: context,
//                             apiKey: "AIzaSyDdTeFwDMiycVp1HyLduCxPxFKSpK0RaK0",
//                             mode: Mode.overlay,
//                             language: 'He',
//                             types: [],
//                             components: [Component(Component.country, 'IL')],
//                             onError: (err) {
//                               WebService.printMsg(err.errorMessage.toString());
//                             });
//
//                         if (place != null) {
//                           final plist = GoogleMapsPlaces(
//                             apiKey: "AIzaSyDdTeFwDMiycVp1HyLduCxPxFKSpK0RaK0",
//                             apiHeaders:
//                                 await const GoogleApiHeaders().getHeaders(),
//                           );
//                           String placeId = place.placeId ?? "0";
//                           final detail =
//                               await plist.getDetailsByPlaceId(placeId);
//                           final geometry = detail.result.geometry!;
//                           WebService.placeId = placeId;
//                           WebService.lat = geometry.location.lat;
//                           WebService.lang = geometry.location.lng;
//                           WebService.address = place.description!;
//
//                           setState(() {
//                             studioAddressController.text = WebService.address;
//                           });
//                         }
//                       },
//                 // onTap: _handlePressButton,
//                 decoration: const InputDecoration(
//                   label: Text("כתובת"),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ));
//
//   //styles list
//   buildStyleList({required Size size}) => SizedBox(
//         height: size.height * 0.05,
//         child: ListView.builder(
//             shrinkWrap: true,
//             itemCount: listStyles.length,
//             scrollDirection: Axis.horizontal,
//             semanticChildCount: 5,
//             itemBuilder: (context, index) {
//               if (index < listStyles.length) {
//                 return GestureDetector(
//                     onTap: () => setState(() {
//                           if (!WebService.changeUserStyleList
//                               .contains(listStyles[index])) {
//                             // if (selectedList.length <= 4) {
//                             WebService.changeUserStyleList
//                                 .add(listStyles[index]);
//                             // }
//                           } else {
//                             WebService.changeUserStyleList
//                                 .remove(listStyles[index]);
//                           }
//                         }),
//                     child: Padding(
//                       padding:
//                           EdgeInsets.symmetric(horizontal: size.width * 0.05),
//                       // child: Text("Item $index"),
//                       child: Text(listStyles[index].name!,
//                           style: TextStyle(
//                               color: WebService.changeUserStyleList
//                                       .contains(listStyles[index])
//                                   ? Theme.of(context).primaryColor
//                                   : Colors.black)),
//                     ));
//               } else {
//                 return const Center(child: CircularProgressIndicator());
//               }
//             }),
//       );
//
//   //about text
//   buildAboutTextField({required Size size}) => Padding(
//         padding: EdgeInsets.all(size.width * 0.02),
//         child: TextFormField(
//           controller: aboutController,
//           maxLines: null,
//           minLines: 4,
//           keyboardType: TextInputType.multiline,
//           autovalidateMode: AutovalidateMode.always,
//           inputFormatters: [
//             LengthLimitingTextInputFormatter(400),
//           ],
//           validator: (String? value) {
//             if (value!.length >= 400) {
//               return ' התיאור ארוך מדי'; //description is to long
//             }
//           },
//           decoration: const InputDecoration(
//               border: OutlineInputBorder(),
//               fillColor: defaultWhite,
//               filled: true),
//         ),
//       );
// }
