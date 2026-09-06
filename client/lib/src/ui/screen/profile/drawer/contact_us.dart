import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/ui/widgets/button/app_button.dart';
import 'package:ink/src/utils/utils_styles.dart';

import '../../../../utils/assets.dart';
import '../../../../utils/colors.dart';
import '../../../widgets/appbar_back_widget.dart';

class Contactus extends StatefulWidget {
  const Contactus({Key? key}) : super(key: key);

  @override
  State<Contactus> createState() => _ContactusState();
}

class _ContactusState extends State<Contactus>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> base;
  final TextEditingController commentController = TextEditingController();
  bool isBtnEnabled = false;

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    base = CurvedAnimation(parent: animationController, curve: Curves.easeOut);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bgBlack,
      bottomSheet: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GradientButton(
              gradient: LinearGradient(
                colors: commentController.text.isNotEmpty
                    ? [
                        linearGradieantColor1,
                        linearGradieantColor2,
                        linearGradieantColor3,
                      ]
                    : [
                        lineargrayGradieantColor1,
                        lineargrayGradieantColor2,
                        lineargrayGradieantColor3,
                      ],
                stops: const [0.0, 0.001, 0.8937],
                begin: Alignment.centerRight, // For RTL, start from right
                end: Alignment.centerLeft,
              ),
              child: animationController.isAnimating
                  ? Center(
                      child: RotationTransition(
                          turns: base,
                          child: Image.asset(
                            AppAssets.loadingIcon,
                            color: Colors.white,
                          )))
                  : Text("שליחה",
                      style: textStyle14s400w.copyWith(
                          color: commentController.text.isEmpty
                              ? defaultGrey
                              : kWhite)),
              onPressed: () async {
                if (commentController.text.toString() == "" ||
                    commentController.text.trim().isEmpty ||
                    commentController.text.toString() == null) {
                  return;
                } else {
                  try {
                    setState(() {
                      animationController.repeat();
                    });
                    await Network.contactUs(
                            comment: commentController.text.toString().trim())
                        .then((value) {

                      setState(() {
                        animationController.stop();
                        if (value != false) Navigator.pop(context);
                      });

                    });
                  } catch (e) {
                    animationController.stop();
                    setState(() {});
                  }
                }
              }),
          if(Platform.isAndroid)  SizedBox(height: size.height*0.045,)
        ],
      ),
      appBar: const AppBarBackButtonWidget(
          title: 'יצירת קשר',
          titleColor: titleTextWhiteColor,
          iconColor: titleTextWhiteColor),
      body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'מוזמנים לפנות אלינו עם כל בקשה, שאלה או הצעה \nלשיפור, נשמח לשמוע ממכם :)',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: Color(0xFFDFDCE3),
                      fontSize: 16,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w400,
                      height: 1.5),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize
                      .min, // Make the Column shrink-wrap its children
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.03,
                        vertical: size.height * 0.007,
                      ),
                      decoration: BoxDecoration(
                          color: signInButtonColor,
                          borderRadius: BorderRadius.circular(8)),
                      child: TextField(
                        controller: commentController,
                        onChanged: (txt) =>
                            setState(() => commentController.text = txt),
                        style: const TextStyle(
                            color: titleTextWhiteColor, fontSize: 16),
                        minLines: 6, // Set the minimum number of lines
                        maxLines:
                            null, // Allows the text field to grow as the user types
                        decoration: const InputDecoration(
                          hintText: 'הקלידו כאן את תוכן הפניה',
                          hintStyle: TextStyle(
                              color: placeholdertxtColor,
                              fontWeight: FontWeight.w400),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
