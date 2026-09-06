// import 'dart:async';
// import 'dart:convert';
//
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart' as getx;
// import 'package:ink/src/utils/colors.dart';
// import 'package:ink/src/utils/common.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:webview_flutter/webview_flutter.dart';
//
// import 'instaPage.dart';
//
// class InstagramMedia extends StatefulWidget {
//   final String appID;
//   final String appSecret;
//   final int mediaTypes;
//   final String imageType;
//   InstagramMedia(
//       {required this.appID,
//       required this.appSecret,
//       required this.mediaTypes,
//       required this.imageType})
//       : assert(appID != null),
//         assert(mediaTypes != null),
//         assert(appSecret != null);
//
//   /*
//   mediaTypes options:
//   0 - images only (No CAROUSEL_ALBUM)
//   1 - videos only (No CAROUSEL_ALBUM)
//   2 - images and videos (No CAROUSEL_ALBUM)
//   3 - everything - everything (CAROUSEL_ALBUM, VIDEO, IMAGE)
//   */
//
//   @override
//   State<InstagramMedia> createState() => _InstagramMediaState();
// }
//
// class _InstagramMediaState extends State<InstagramMedia> {
//   GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//   late final WebViewController _controller;
//   late Dio dio;
//   int stage = 0;
//   late String accessToken;
//   late String accessCode;
//   late String igUserID;
//   late String redirectUrl = "https://itapp2u.com/apps/Inkapp/get_code.php";
//   int webProgress = 0;
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setBackgroundColor(const Color(0xFF000000))
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onProgress: (int progress) {
//             // Update loading bar.
//             setState(() {
//               webProgress = progress;
//             });
//           },
//           onPageStarted: (String url) {
//             setState(() {
//               webProgress = 0;
//             });
//           },
//           onNavigationRequest: (NavigationRequest request) {
//             if (request.url.startsWith('https://m.facebook.com')) {
//               getx.Get.snackbar(
//                 "Not Working",
//                 "Please Use Instagram Email & Password for login",
//                 snackPosition: getx.SnackPosition.BOTTOM,
//                 colorText: Colors.white,
//                 backgroundColor: Colors.red,
//                 forwardAnimationCurve: Curves.easeOutBack,
//               );
//               return NavigationDecision.prevent;
//             }
//             return NavigationDecision.navigate;
//           },
//           onWebResourceError: (WebResourceError error) {},
//           onPageFinished: (String url) {
//             setState(() {
//               webProgress = 100;
//               getData();
//             });
//             debugPrint('Page finished loading: $url');
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse(
//           "https://instagram.com/oauth/authorize/?client_id=${widget.appID}&redirect_uri=$redirectUrl&scope=user_profile,user_media&response_type=code&hl=en"));
//     // ..loadRequest(Uri.parse(
//     //     "https://instagram.com/oauth/authorize/?client_id=${widget.appID}&redirect_uri=$redirectUrl&scope=user_profile,user_media&response_type=code&hl=en"));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         key: scaffoldKey,
//         body: Stack(
//           children: [
//             WebViewWidget(controller: _controller),
//             if (webProgress < 100)
//               LinearProgressIndicator(value: webProgress / 100.0)
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> getData() async {
//     final response = await _controller
//         .runJavaScriptReturningResult("document.documentElement.innerText");
//
//     try {
//       var data = jsonDecode(response.toString());
//       if (data.substring(0, 1) == "{") {
//         print("datadatadata $data");
//         if (data.substring(2, 6) == "code") {
//           displayMessage("Please Wait....", defaultAppColor);
//         } else {
//           displayMessage(data, Colors.red);
//         }
//       }
//
//       String tempdata = data;
//       FormData formData = FormData.fromMap({
//         "client_id": widget.appID,
//         "client_secret": widget.appSecret,
//         "grant_type": 'authorization_code',
//         'redirect_uri': redirectUrl,
//         'code': tempdata.substring(9, tempdata.length - 2),
//       });
//       _getShortLivedToken(formData);
//     } catch (e) {
//       print(e);
//     }
//   }
//
//   _getShortLivedToken(formData) async {
//     Response response = await Dio()
//         .post('https://api.instagram.com/oauth/access_token', data: formData);
//     var respData = response.data;
//
//     setState(() {
//       accessToken = respData['access_token'];
//       igUserID = (respData['user_id']).toString();
//     });
//     _getMedia(context);
//   }
//
//   _getMedia(context) async {
//     var respData;
//
//     Response response = await Dio().get(
//         'https://graph.instagram.com/$igUserID/media?access_token=$accessToken&fields=timestamp,media_url,media_type,caption');
//
//     var filterData = response.data['data']
//         .where(
//             (e) => e['media_type'].toString().toLowerCase().contains("image"))
//         .toList();
//
//     // respData = response.data['data'];
//     // Navigator.push(
//     //   context,
//     //   MaterialPageRoute(
//     //       builder: (context) =>
//     //           InstaPage(resdata: respData, imageType: widget.imageType)),
//     // );
//
//     getx.Get.off(InstaPage(resdata: filterData, imageType: widget.imageType));
//   }
//
//   Future<void> _launchUrl(url) async {
//     if (!await launchUrl(url)) {
//       throw Exception('Could not launch $url');
//     }
//   }
// }
