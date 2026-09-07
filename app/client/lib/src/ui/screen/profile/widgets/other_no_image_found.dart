import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';

class OtherNoImageFoundWidget extends StatelessWidget {
  const OtherNoImageFoundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: signInButtonColor,
            child: SvgPicture.asset(
              AppAssets.cameraPlusIcon,
              height: 35,
              width: 35,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          const Text(
            'לא הועלו תמונות עדיין',
            style: TextStyle(
                color: titleTextWhiteColor,
                fontSize: 18,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
