import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/ui/screen/inspiration/controller/inspiration_controller.dart';
import 'package:ink/src/ui/screen/inspiration/widget/filter_inspiration_widget.dart';
import 'package:ink/src/ui/screen/inspiration/widget/sort_inspiration_widget.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';

class SearchInspirationWidget extends StatelessWidget {
  final InspirationController inspirationController;

  const SearchInspirationWidget(
      {super.key, required this.inspirationController});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
        top: size.height * 0.02,
        bottom: size.height * 0.02,
      ), //symmetric(horizontal: 10.0, vertical: 10.0),
      color: bgBlack,
      child: Row(
        children: [
          Expanded(
              child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  controller: inspirationController.searchController,
                  style: const TextStyle(color: Colors.white),
                  onTapOutside: (event) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  onSubmitted: (value) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    inspirationController.postsInspiration.clear();
                    inspirationController.startInspiration = 0.obs;
                    inspirationController.getInspirationController();
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    filled: true,
                    fillColor: socialoginbtn,
                    hintText: 'חפשו קעקועים להשראה',
                    prefixIcon: InkWell(
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        inspirationController.startInspiration = 0.obs;
                        inspirationController.postsInspiration.clear();
                        inspirationController.getInspirationController();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SvgPicture.asset(
                          AppAssets.searchdashboard,
                          color: titleTextWhiteColor,
                        ),
                      ),
                    ),
                    hintStyle: const TextStyle(
                      color: placeholdertxtColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                    ),
                  ))),
          // Expanded(
          //   child: Container(
          //     padding: const EdgeInsets.symmetric(horizontal: 8.0),
          //     decoration: ShapeDecoration(
          //       color: Color(0xFF2B272F),
          //       shape: RoundedRectangleBorder(
          //         side: BorderSide(
          //           width: 2,
          //           strokeAlign: BorderSide.strokeAlignOutside,
          //           color: Color(0xFF16121A),
          //         ),
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //     ),
          //     child: Row(
          //       // Use Row for horizontal alignment
          //       children: [
          //         InkWell(
          //           onTap: () {
          //             inspirationController.getInspirationController();
          //           },
          //           child: SvgPicture.asset(
          //             AppAssets.searchdashboard,
          //             color: titleTextWhiteColor,
          //           ),
          //         ),
          //         Expanded(
          //           // Expanded widget for TextField flexibility
          //           child: TextField(
          //             textAlignVertical: TextAlignVertical.center,
          //             controller: inspirationController.searchController,
          //             style: const TextStyle(color: Colors.white),
          //             decoration: const InputDecoration(
          //               hintText: 'חפשו קעקועים להשראה',
          //               hintStyle: TextStyle(
          //                 color: placeholdertxtColor,
          //                 fontSize: 16,
          //                 fontWeight: FontWeight.w400,
          //               ),
          //               border: InputBorder.none,
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          const SizedBox(
            width: 8,
          ),

          Obx(()=>commonIconButton(
              context: context,
              onTap: () => showModalBottomSheet<dynamic>(
                  useRootNavigator: true,
                  isScrollControlled: true,
                  context: context,
                  builder: (BuildContext context) => FilterInspirationWidget(
                      controller: inspirationController)),
              imageName: inspirationController.isStyleEnabled.value
                  ? AppAssets.filterAppliedIcon
                  : AppAssets.filterIcon)),
          const SizedBox(
            width: 8,
          ),

          commonIconButton(
              context: context,
              onTap: () => showModalBottomSheet<dynamic>(
                  useRootNavigator: true,
                  isScrollControlled: true,
                  context: context,
                  builder: (BuildContext context) => SortInspirationWidget(
                        inspirationController: inspirationController,
                      )),
              imageName: AppAssets.sortIcon),
        ],
      ),
    );
  }

  InkWell commonIconButton(
      {required BuildContext context,
      required VoidCallback onTap,
      required String imageName}) {
    return InkWell(
        onTap: onTap,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ColoredBox(
              color: socialoginbtn,
              child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                      height: 27.0,
                      width: 27.0,
                      child: SvgPicture.asset(imageName))),
            )));
  }
}
