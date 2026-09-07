// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:ink/src/utils/common.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdfx/pdfx.dart';
//
// class CustomPdfViewver extends StatefulWidget {
//   final String url;
//   final String title;
//   const CustomPdfViewver({Key? key, required this.url, required this.title})
//       : super(key: key);
//
//   @override
//   State<CustomPdfViewver> createState() => _CustomPdfViewverState();
// }
//
// enum DocShown { sample, tutorial, hello, password }
//
// class _CustomPdfViewverState extends State<CustomPdfViewver> {
//   static const int _initialPage = 1;
//   DocShown _showing = DocShown.sample;
//   late PdfControllerPinch _pdfControllerPinch;
//   String? localPdfPath;
//   @override
//   void initState() {
//     downloadAndDisplayPdf();
//
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _pdfControllerPinch.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: buildappBarwithback(
//           size: MediaQuery.of(context).size, title: widget.title),
//       body: localPdfPath != null
//           ? PdfViewPinch(
//               builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
//                 options: const DefaultBuilderOptions(),
//                 documentLoaderBuilder: (_) =>
//                     const Center(child: CircularProgressIndicator()),
//                 pageLoaderBuilder: (_) =>
//                     const Center(child: CircularProgressIndicator()),
//                 errorBuilder: (_, error) =>
//                     Center(child: Text(error.toString())),
//               ),
//               controller: _pdfControllerPinch,
//             )
//           : const Center(
//               child: CircularProgressIndicator(),
//             ),
//     );
//   }
//
//   Future<void> downloadAndDisplayPdf() async {
//     final response = await http.get(Uri.parse(widget.url));
//
//     if (response.statusCode == 200) {
//       final Uint8List pdfData = response.bodyBytes;
//
//       // Get the app's cache directory
//       final appDocDir = await getTemporaryDirectory();
//
//       // Create a local file to save the PDF
//       final pdfFile = File("${appDocDir.path}/my_pdf.pdf");
//
//       await pdfFile.writeAsBytes(pdfData);
//
//       if (mounted) {
//         setState(() {
//           _pdfControllerPinch = PdfControllerPinch(
//             // document: PdfDocument.openAsset('assets/hello.pdf'),
//             document: PdfDocument.openFile(pdfFile.path),
//             initialPage: _initialPage,
//           );
//           localPdfPath = pdfFile.path;
//         });
//       }
//     } else {
//       print("Failed to download PDF: ${response.statusCode}");
//     }
//   }
// }
