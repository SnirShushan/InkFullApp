import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/ui/screen/inspiration/controller/inspiration_controller.dart';
import 'package:ink/src/ui/screen/inspiration/widget/inspiration_grid_widget.dart';
import 'package:ink/src/ui/screen/inspiration/widget/search_inspiration_widget.dart';
import 'package:ink/src/utils/colors.dart';

class InspirationScreen extends StatelessWidget {
  InspirationScreen({Key? key}) : super(key: key);

  // final InspirationController _inspirationController =
  //     Get.find<InspirationController>();

  final InspirationController _inspirationController =
      Get.put(InspirationController());

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bgBlack,

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            SizedBox(
              height: size.height * 0.01,
            ),
            SearchInspirationWidget(
                inspirationController: _inspirationController),
            // Divider(),

            Expanded(
                child:
                    InspiriationGridWidget(controller: _inspirationController)),
            SizedBox(
              height: size.height * 0.02,
            ),
          ],
        ),
      ),
    );
  }
}
