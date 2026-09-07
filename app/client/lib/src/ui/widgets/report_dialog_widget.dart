import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/utils/colors.dart';

class ReportDialogWidget extends StatefulWidget {
  final controller;
  final bid;
  final bool isPostDetails;

  const ReportDialogWidget(
      {super.key, this.isPostDetails = false, this.controller, this.bid});

  @override
  State<ReportDialogWidget> createState() => _ReportDialogWidgetState();
}

class _ReportDialogWidgetState extends State<ReportDialogWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> base;

  @override
  void initState() {
    animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    base = CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return FractionallySizedBox(
      heightFactor: 0.18,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
        decoration: const BoxDecoration(
            color: signInButtonColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
                onTap: () => Get.back(),
                child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: size.height * 0.03,
                        horizontal: size.width * 0.4),
                    child: Container(
                        margin: const EdgeInsetsDirectional.only(
                            start: 1.0, end: 1.0),
                        height: size.height * 0.005,
                        width: size.width * 0.2,
                        color: kDivider))),
            SizedBox(height: size.height * 0.03),
            InkWell(
                onTap: () {
                  Get.back();
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) =>
                        StatefulBuilder(builder: (builder, setstate) {
                      return _AlertDialogReports(
                          onTap: () async {
                            // Get.back();
                            // await controller
                            //     .reportBusiness(
                            //     bid: businessDetailsController.id,
                            //     comment: commentTxtController.text)
                            //     .then((value) {
                            //   commentTxtController.text = "";
                            //   // Get.back();
                            // });
                          },
                          title: "דיווח על עסק לא קיים",
                          subtitle: "נשמח לפרטים נוספים על הדיווח",
                          hintText: "פרטו כאן את סיבת הדיווח");
                    }),
                  );
                },
                child: SizedBox(
                    width: double.infinity,
                    height: size.height * 0.07,
                    child: Text("דיווח על עסק לא קיים",
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: titleTextWhiteColor)))),
            SizedBox(height: size.height * 0.02),
            if (widget.isPostDetails)
              InkWell(
                  onTap: () {
                    Get.back();
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) =>
                          StatefulBuilder(builder: (builder, setstate) {
                        return _AlertDialogReports(
                            onTap: () {},
                            title: "דיווח על תמונות בניגוד לנהלים",
                            subtitle: "נשמח לפרטים נוספים על הדיווח",
                            hintText: "פרטו כאן את סיבת הדיווח");
                      }),
                    );
                  },
                  child: SizedBox(
                      width: double.infinity,
                      height: size.height * 0.07,
                      child: Text("דיווח על עסק לא קיים",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: titleTextWhiteColor)))),
            if (widget.isPostDetails) SizedBox(height: size.height * 0.02),
          ],
        ),
      ),
    );
  }
}

class _AlertDialogReports extends StatefulWidget {
  final String title;
  final String subtitle;
  final String hintText;

  final VoidCallback onTap;

  const _AlertDialogReports({
    super.key,
    required this.onTap,
    required this.title,
    required this.subtitle,
    required this.hintText,
  });

  @override
  State<_AlertDialogReports> createState() => _AlertDialogReportsState();
}

class _AlertDialogReportsState extends State<_AlertDialogReports> {
  final TextEditingController commentTxtController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return AlertDialog(
      titlePadding: const EdgeInsets.all(1.0),
      backgroundColor: socialoginbtn,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      actionsAlignment: MainAxisAlignment.center,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Column(
          children: [
            Text(widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 18,
                    color: titleTextWhiteColor,
                    fontWeight: FontWeight.w700)),
            SizedBox(height: size.height * 0.015),
            Text(widget.subtitle,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: titleTextWhiteColor, fontWeight: FontWeight.w400)),
            SizedBox(height: size.height * 0.02),
            TextFormField(
                autofocus: false,
                controller: commentTxtController,
                minLines: 5,
                maxLines: 7,
                keyboardType: TextInputType.multiline,
                cursorColor: kWhite,
                style: const TextStyle(color: kWhite),
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  filled: true,
                  fillColor: Color(0xFF403D44),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: widget.hintText,
                  hintStyle: const TextStyle(
                    color: Color(0xFF6B676F),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8)),
                  errorMaxLines: 1,
                  errorText: null,
                  errorStyle: const TextStyle(
                    height: 0,
                    color: Colors.transparent,
                    fontSize: 0,
                  ),
                )),
            SizedBox(height: Get.size.height * 0.02),
            // const SizedBox(height: 24),

            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: size.width * 0.3,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: titleTextWhiteColor,
                        backgroundColor: const Color(0xFF403D44),
                      ),
                      onPressed: widget.onTap,
                      child: Text("שליחת דיווח",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                  color: titleTextWhiteColor,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14))),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: size.width * 0.3,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: bgBlack,
                        backgroundColor: titleTextColor,
                      ),
                      onPressed: () async {
                        Get.back();
                      },
                      child: Text(
                        "ביטול",
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: bgBlack,
                            fontWeight: FontWeight.w400,
                            fontSize: 14),
                      )),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
