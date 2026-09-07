// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart';
// import 'package:ink/src/utils/colors.dart';
// import 'package:ink/src/utils/webService.dart';
// import 'package:path_provider/path_provider.dart';
//
// import '../../new_post.dart';
//
// class InstaPage extends StatelessWidget {
//   final resdata;
//   final imageType;
//   const InstaPage({super.key, required this.resdata, required this.imageType});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         leading: IconButton(
//             onPressed: () => Get.back(),
//             icon: const Icon(Icons.arrow_back_ios)),
//         title: Column(
//           children: [
//             Text("העלאת תמונה מאינסטגרם",
//                 style: Theme.of(context)
//                     .textTheme
//                     .titleLarge!
//                     .copyWith(color: kWhite)),
//             Text("בחר תמונה להעלאה",
//                 style: Theme.of(context)
//                     .textTheme
//                     .titleSmall!
//                     .copyWith(color: kWhite)),
//           ],
//         ),
//         centerTitle: true,
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           resdata == null
//               ? const SizedBox()
//               : GridView.builder(
//                   shrinkWrap: true,
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     crossAxisSpacing: 4,
//                     mainAxisSpacing: 4,
//                   ),
//                   itemBuilder: (BuildContext context, int index) {
//                     return InkWell(
//                         onTap: () =>
//                             selectImage(imgUrl: resdata[index]['media_url']),
//                         child: Image.network(resdata[index]['media_url']));
//                   },
//                   itemCount: resdata.length,
//                 ),
//         ],
//       ),
//     );
//   }
//
//   selectImage({imgUrl}) async {
//     var response = await get(Uri.parse(imgUrl));
//
//     final directory = await getTemporaryDirectory();
//     final path = directory.path;
//     final fileName = WebService.generateRandomString(20);
//     var file = File('$path/$fileName.png');
//
//     await file.writeAsBytes(response.bodyBytes).then((value) => Get.off(
//         () => SketchImageScreen(pickedFile: file, imageType: imageType)));
//   }
// }
