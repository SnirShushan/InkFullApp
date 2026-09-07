import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/utils_styles.dart';

class FAQContainer extends StatefulWidget {
  final String questions;
  final List<String> responses;
  final responseData;
  final bool isRichText;
  const FAQContainer(
      {super.key,
      required this.questions,
      required this.responses,
      this.responseData,
      this.isRichText = false});

  @override
  State<FAQContainer> createState() => _FAQContainerState();
}

class _FAQContainerState extends State<FAQContainer> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        setState(() {
          expanded = !expanded;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: ShapeDecoration(
              color: socialoginbtn,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              )),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: size.width * 0.7,
                    child: Text(
                      widget.questions,
                      style: normalWhiteStyle16width700,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SvgPicture.asset(expanded
                        ? AppAssets.upArrowIcon
                        : AppAssets.downArrowIcon),
                  )
                ],
              ),
              // const SizedBox(height: 10),
              if (expanded)
                //description

                widget.isRichText
                    //   ? widget.responseData
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: widget.responseData)
                    : Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.responses.length,
                          itemBuilder: (context, i) {
                            return Text(widget.responses[i].toString(),
                                style: normalWhiteStyle.copyWith(
                                    fontSize: 14,
                                    color: dividerGray,
                                    wordSpacing: 0.5),
                                textAlign: TextAlign.right,
                                softWrap: true);
                          },
                        ),
                      ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:ink/src/utils/assets.dart';
// import 'package:ink/src/utils/colors.dart';
// import 'package:ink/src/utils/utils_styles.dart';
//
// class FAQContainer extends StatefulWidget {
//   final String questions;
//   final List<String> responses;
//
//   const FAQContainer(
//       {super.key, required this.questions, required this.responses});
//
//   @override
//   State<FAQContainer> createState() => _FAQContainerState();
// }
//
// class _FAQContainerState extends State<FAQContainer> {
//   bool expanded = false;
//
//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           expanded = !expanded;
//         });
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//           decoration: ShapeDecoration(
//               color: socialoginbtn,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               )),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   SizedBox(
//                     width: size.width * 0.7,
//                     child: Text(
//                       widget.questions,
//                       style: normalWhiteStyle16width700,
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 10),
//                     child: SvgPicture.asset(expanded
//                         ? AppAssets.upArrowIcon
//                         : AppAssets.downArrowIcon),
//                   )
//                 ],
//               ),
//               // const SizedBox(height: 10),
//               if (expanded)
//                 //description
//
//                 Padding(
//                   padding: const EdgeInsets.only(top: 8.0),
//                   child: ListView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: widget.responses.length,
//                     itemBuilder: (context, i) {
//                       return Text(widget.responses[i].toString(),
//                           style: normalWhiteStyle.copyWith(
//                               fontSize: 14,
//                               color: dividerGray,
//                               wordSpacing: 0.5),
//                           textAlign: TextAlign.right,
//                           softWrap: true);
//                     },
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
