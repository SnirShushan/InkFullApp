import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';

import '../controller/inspiration_controller.dart';

class SortInspirationWidget extends StatelessWidget {
  final InspirationController inspirationController;

  const SortInspirationWidget({super.key, required this.inspirationController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      decoration: const BoxDecoration(
          color: signInButtonColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //close
          InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.03,
                      horizontal: MediaQuery.of(context).size.width * 0.4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Container(
                      margin: const EdgeInsetsDirectional.only(
                          start: 1.0, end: 1.0),
                      height: MediaQuery.of(context).size.height * 0.005,
                      width: MediaQuery.of(context).size.width * 0.2,
                      decoration: BoxDecoration(
                        color: kDivider,
                        borderRadius: BorderRadius.circular(
                            10.0), // Adjust the radius as needed
                      ),
                    ),
                  ))),
          Row(
            children: [
              SvgPicture.asset(AppAssets.sortIcon),
              const SizedBox(width: 10),
              const Text('מיון לפי',
                  style: TextStyle(
                      color: titleTextWhiteColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),

          Obx(() => Flexible(
                child: Wrap(
                  spacing: 16.0,
                  runSpacing: 2.0,
                  children: inspirationController.options.map((option) {
                    return ElevatedButton(
                      onPressed: () => inspirationController.sortingsData(
                          context: context, option: option)

                      // if (option == "מומלצים עבורכם") {
                      //   inspirationController.toggleRecommanded(option);
                      //   Navigator.of(context).pop();
                      // } else if (option == "החדשים ביותר") {
                      //   inspirationController.toggleNew();
                      //   Navigator.of(context).pop();
                      // } else if (option == "הנצפים ביותר") {
                      //   inspirationController.toggleMostViewed();
                      //   Navigator.of(context).pop();
                      // }
                      ,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, // Adjust padding as needed
                          vertical: 12.0, // Adjust padding as needed
                        ),
                        backgroundColor:
                            option == inspirationController.isselected.value
                                ? titleTextWhiteColor
                                : signInButtonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: const BorderSide(
                              color: titleTextWhiteColor), // Border color
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (option == inspirationController.isselected.value)
                            const Icon(
                              Icons.check,
                              color: bgBlack,
                              size: 15,
                            ),
                          if (option == inspirationController.isselected.value)
                            const SizedBox(width: 8),
                          Text(
                            option,
                            style: TextStyle(
                                color: option ==
                                        inspirationController.isselected.value
                                    ? signInButtonColor
                                    : titleTextWhiteColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              )),
           SizedBox(
            height: Platform.isAndroid?MediaQuery.of(context).size.height * 0.065:MediaQuery.of(context).size.height * 0.03,
          ),
        ],
      ),
    );
  }
}
