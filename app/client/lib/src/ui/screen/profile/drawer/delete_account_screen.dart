import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/userController.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';

import '../../../widgets/appbar_back_widget.dart';
import 'widget/custom_btn_widget.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: bgBlack,
      appBar: AppBarBackButtonWidget(
          title: tr('sideDrawer.delete_account_title'),
          titleColor: titleTextWhiteColor,
          iconColor: titleTextWhiteColor),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //SizedBox(height: size.height * 0.06),
              // InkWell(
              //   onTap: () => Navigator.of(context).pop(),
              //   child: Row(
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     children: [
              //       SizedBox(width: size.width * 0.02),
              //       SvgPicture.asset(AppAssets.backarrowIcon,
              //           width: 22, height: 22),
              //       SizedBox(width: size.width * 0.03),
              //       Text(tr('sideDrawer.delete_account_title'),
              //           style: textTheme.titleLarge?.copyWith(
              //             color: titleTextWhiteColor,
              //             fontWeight: FontWeight.w700,
              //           ))
              //     ],
              //   ),
              // ),
              SizedBox(height: size.height * 0.02),
              Text(tr("sideDrawer.delete_account_subtitle1"),
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    color: titleTextWhiteColor,
                    fontWeight: FontWeight.w700,
                  )),
              SizedBox(height: size.height * 0.01),
              Text(tr("sideDrawer.delete_account_subtitle2"),
                  style: textTheme.titleMedium?.copyWith(
                    color: titleTextWhiteColor,
                    fontWeight: FontWeight.w400,
                  )),
              const Spacer(),
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/delete_account.png',
                ),
              ),
              const Spacer(),
              CustomButtonWidget(

                  btnColor: errorColor,
                  txtColor: titleTextWhiteColor,
                  title: 'sideDrawer.delete_account_delete_btn',
                  onTap: () {
                    final userController = Get.put(UserController());
                    buildDeleteDialog(
                        context,
                        () async => await userController
                            .deleteAccount()
                            .then((value) => Get.back()));
                  }),
              SizedBox(height: size.height * 0.03),
              CustomButtonWidget(

                  btnColor: socialoginbtn,
                  txtColor: titleTextWhiteColor,
                  title: 'sideDrawer.delete_account_cancel_btn',
                  onTap: () => Navigator.of(context).pop()),
              if(Platform.isAndroid) SizedBox(height: size.height * 0.045),
            ],
          ),
        ),
      ),
    );
  }
}
