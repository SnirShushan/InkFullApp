import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomButton extends StatelessWidget {
  final String customtitle;
  final Color customcolor;
  final Color txtColor;
  final Function() onPressed;
  const CustomButton(
      {Key? key,
      required this.customtitle,
      required this.customcolor,
      required this.onPressed,
      required this.txtColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: Get.size.width * 0.3,
        height: Get.size.height * 0.05,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: customcolor,
            foregroundColor: Colors.black,
          ),
          child: FittedBox(
              child: Text(
            customtitle,
            style: TextStyle(color: txtColor),
            textAlign: TextAlign.center,
          )),
        ));
  }
}

/*InkWell(
        onTap: phoneController.text.isEmpty
            ? () {
                setState(() {
                  loginvalidation = 'login.phone_number_incorrect';
                });
              }
            : () async => await _startLogin(),
        child: Container(
            width: size.width,
            height: size.height * 0.07,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              gradient: LinearGradient(
                begin: Alignment.centerRight, // For RTL, start from right
                end: Alignment.centerLeft, // For RTL, end at left
                colors: [
                  linearGradieantColor1,
                  linearGradieantColor2,
                  linearGradieantColor3,
                ],
                stops: [0.0, 0.001, 0.8937],
              ),
            ),
            child: isLoading!
                ? Center(
                    child: RotationTransition(
                        turns: base, child: Image.asset(AppAssets.loadingIcon)),
                  )
                : Text(
                    "login.continue_to_verify_code",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color:
                            phoneController.text.isEmpty ? defaultGrey : kWhite,
                        fontWeight: FontWeight.w700),
                  ).tr()),
      )*/
