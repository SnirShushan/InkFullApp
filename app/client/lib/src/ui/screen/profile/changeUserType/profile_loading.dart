import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:ink/src/ui/screen/profile/subscription/subscription_db_service.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';

class ScreenProfileLoading extends StatefulWidget {
  final PurchaseDetails? purchaseDetails;

  const ScreenProfileLoading({Key? key, required this.purchaseDetails})
      : super(key: key);

  @override
  State<ScreenProfileLoading> createState() => _ScreenProfileLoadingState();
}

class _ScreenProfileLoadingState extends State<ScreenProfileLoading> {
  @override
  void initState() {
    // SubscriptionDbService.fromRegistration = true;
    // SubscriptionDbService().saveSubcriptionsDetails(widget.purchaseDetails!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
        body: Stack(
      children: [buildBg(size), buildProgress(size)],
    ));
  }

  buildBg(size) => Image.asset(AppAssets.loadingProfile,
      width: size.width,
      height: size.height * 0.7,
      fit: BoxFit.cover,
      opacity: const AlwaysStoppedAnimation(.9));

  buildProgress(size) => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: size.height * 0.35,
          decoration: const BoxDecoration(
              color: bgBlack,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.02),
              Text(
                "איזה כיף שהצטרפתם!",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontSize: 24,
                    color: titleTextColor,
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                "בעוד מספר שניות הפרופיל\n העסקי יהיה מוכן...",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: titleTextWhiteColor, fontWeight: FontWeight.w400),
              ),
              SizedBox(height: size.height * 0.03),
              Padding(
                padding: EdgeInsets.all(size.width * 0.1),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ColoredBox(
                    color: Colors.grey,
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: LinearProgressIndicator(
                        backgroundColor: kWhite,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
}
