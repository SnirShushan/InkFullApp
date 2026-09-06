import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/userController.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/business_dashboard.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/bussinessdashboard_binding.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard_binding.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/webService.dart';

class HomeStylesWidget extends StatefulWidget {
  const HomeStylesWidget({super.key});

  @override
  State<HomeStylesWidget> createState() => _HomeStylesWidgetState();
}

class _HomeStylesWidgetState extends State<HomeStylesWidget> {
  final UserController _userController = Get.find<UserController>();

  bool _retryDone = false;

  @override
  void initState() {
    super.initState();

    if (_userController.style_list.isEmpty) {
      _userController.initUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.height * 0.19,
      child: Obx(() {
        // EMPTY → retry once, no UI message
        if (_userController.style_list.isEmpty) {
          if (!_retryDone) {
            _retryDone = true;
            // delay avoids setState / build conflict
            Future.microtask(() {
              _userController.initUser();
            });
          }

          // Just keep space, no text
          return const SizedBox.shrink();
        }

        // DATA AVAILABLE
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _userController.style_list.length,
          itemBuilder: (_, index) {
            final data = _userController.style_list[index];

            return Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 8,
                  child: buildCachedNetworkImage(
                    height: size.width * 0.27,
                    width: size.width * 0.27,
                    url: WebService.resolveImageUrl(data.imageName,
                        base: WebService.styleImgUrl),
                    radius: 10,
                  ),
                ),
                const SizedBox(height: 8),
                Text(data.name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: titleTextWhiteColor,
                          fontWeight: FontWeight.w400,
                        )),
              ],
            );
          },
        );
      }),
    );
  }
}
