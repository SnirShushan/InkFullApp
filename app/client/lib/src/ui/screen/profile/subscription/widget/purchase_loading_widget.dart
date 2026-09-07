import 'package:flutter/material.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';

class PurchaseLoadingWidget extends StatelessWidget {
  const PurchaseLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(AppAssets.loadingProfile,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.7,
            fit: BoxFit.cover),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: const BoxDecoration(
                color: bgBlack,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Text(
                  "איזה כיף שהצטרפתם!",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontSize: 24,
                      color: titleTextColor,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  "בעוד מספר שניות הפרופיל\n העסקי יהיה מוכן...",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: titleTextWhiteColor, fontWeight: FontWeight.w400),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Padding(
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.1),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: ColoredBox(
                      color: Colors.grey,
                      child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: LinearProgressIndicator(
                            backgroundColor: kWhite,
                            borderRadius: BorderRadius.circular(10),
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
