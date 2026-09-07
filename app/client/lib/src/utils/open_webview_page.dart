// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ink/src/utils/webService.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'common.dart';
//
// class OpenWebViewPage extends StatefulWidget {
//   final String url;
//   final String title;
//   const OpenWebViewPage({Key? key, required this.url, required this.title})
//       : super(key: key);
//
//   @override
//   State<OpenWebViewPage> createState() => _OpenWebViewStatePage();
// }
//
// class _OpenWebViewStatePage extends State<OpenWebViewPage> {
//   GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//
//   String? customweburl;
//   late final WebViewController _controller;
//   bool isLoading = true;
//   int webProgress = 0;
//
//   @override
//   void initState() {
//     print(widget.url);
//     super.initState();
//
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setBackgroundColor(const Color(0x00000000))
//       ..enableZoom(true)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onProgress: (int progress) {
//             setState(() {
//               webProgress = progress;
//             });
//           },
//           onPageStarted: (String url) {
//             WebService.printMsg(url);
//             setState(() {
//               webProgress = 0;
//             });
//           },
//           onWebResourceError: (WebResourceError error) {
//             print(error.toString());
//           },
//           onPageFinished: (String url) {
//             WebService.printMsg(url);
//             setState(() {
//               webProgress = 100;
//             });
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse(widget.url));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         if (await _controller.canGoBack()) {
//           Get.back();
//           return false;
//         }
//         return true;
//       },
//       child: Scaffold(
//         appBar: buildappBarwithback(
//             size: MediaQuery.of(context).size, title: widget.title),
//         body: SafeArea(
//             child: Stack(
//           children: [
//             WebViewWidget(controller: _controller),
//             if (webProgress < 100)
//               LinearProgressIndicator(value: webProgress / 100.0)
//           ],
//         )),
//       ),
//     );
//   }
// }
