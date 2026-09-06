import 'package:flutter/material.dart';
import 'package:ink/src/utils/colors.dart';

class UpgradeDialog extends StatelessWidget {
  final String title;
  final String description;
  final String upgradeButtonTxt;
  final String mayBelaterButtonTxt;
  final bool isTitleVisible;
  final VoidCallback onUpgradeNow;
  final VoidCallback onMaybeLater;

  const UpgradeDialog({
    super.key,
    required this.onUpgradeNow,
    required this.onMaybeLater,
    required this.title,
     this.isTitleVisible=true,
    required this.description,
    required this.upgradeButtonTxt,
    required this.mayBelaterButtonTxt,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return AlertDialog(
      backgroundColor: dialogBgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      insetPadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(20.0),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: size.width * 0.72),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: size.height * 0.01),
             if(isTitleVisible) Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Arimo',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: titleTextWhiteColor,
              ),
            ),
            if(isTitleVisible) SizedBox(height: size.height * 0.02),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.005),
              child:  Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Arimo',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: titleTextWhiteColor,
                ),
              ),
            ),
            SizedBox(height: size.height * 0.03),
            InkWell(
              onTap: onUpgradeNow,
              child: Container(
                width: size.width,
                height: size.height * 0.06,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  gradient: LinearGradient(
                    begin: Alignment.centerRight, // RTL
                    end: Alignment.centerLeft, // RTL
                    colors: [
                      linearGradieantColor1,
                      linearGradieantColor2,
                      linearGradieantColor3,
                    ],
                    stops: [0.0, 0.001, 0.8937],
                  ),
                ),
                child:  Text(
                 upgradeButtonTxt,
                  style: const TextStyle(
                    fontFamily: 'Arimo',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: titleTextWhiteColor,
                  ),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.01),
            InkWell(
              onTap: onMaybeLater,
              child: Container(
                width: size.width,
                height: size.height * 0.07,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  color: styleBgColor,
                ),
                child:  Text(
                mayBelaterButtonTxt,
                  style: const TextStyle(
                    fontFamily: 'Arimo',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: titleTextWhiteColor,
                  ),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.01),
          ],
        ),
      ),
    );
  }
}
