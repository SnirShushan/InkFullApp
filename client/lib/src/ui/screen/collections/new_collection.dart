import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ink/src/ui/widgets/appbar_back_widget.dart';

import '../../../data/model/postDetails.dart';
import '../../../data/source/network/firebase_api.dart';
import '../../../utils/assets.dart';
import '../../../utils/colors.dart';
import '../../../utils/utils.dart';
import '../../../utils/utils_styles.dart';
import '../../widgets/button/app_button.dart';

class CreateNewCollection extends StatefulWidget {
  final MPostDetails? postModel;
  final String? name;
  final String? fid;
  final String imagePath;
  final bool? isRenameEnabled;

  const CreateNewCollection(
      {super.key,
      required this.postModel,
      this.imagePath = "",
      this.isRenameEnabled = false,
      this.name,
      this.fid});

  @override
  State<CreateNewCollection> createState() => _CreateNewCollectionState();
}

class _CreateNewCollectionState extends State<CreateNewCollection>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> base;
  bool isBtnEnabled = false;

  final TextEditingController collectionNameController =
      TextEditingController();

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    base = CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    if (widget.isRenameEnabled == true) {
      collectionNameController.text = widget.name ?? "";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
        backgroundColor: const Color(0xFF16121A),
        appBar: AppBarBackButtonWidget(
            title: widget.isRenameEnabled == true ? 'עריכת אוסף' : 'אוסף חדש',
            titleColor: titleTextWhiteColor,
            iconColor: titleTextWhiteColor),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.05),
                    ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: widget.imagePath != null
                            ? widget.imagePath ?? ""
                            : "",
                        // Provide a fallback URL or handle empty URL as needed
                        height: size.width * 0.5,
                        width: size.width * 0.5,
                        // Adjust size as needed
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Image.asset(
                          AppAssets.collectionPlaceholder,
                          // Replace with your placeholder image path
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.05),
                    const Align(
                        alignment: Alignment.centerRight,
                        child: Text("שם האוסף",
                            style: TextStyle(
                                color: titleTextWhiteColor, fontSize: 16),
                            textAlign: TextAlign.right)),
                    SizedBox(height: size.height * 0.02),
                    SizedBox(
                      height: 48,
                      child: TextField(
                          controller: collectionNameController,
                          textAlignVertical: TextAlignVertical.center,
                          style: const TextStyle(color: titleTextWhiteColor),
                          onChanged: (txt) => setState(
                              () => collectionNameController.text = txt),
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: signInButtonColor,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0)),
                              hintText: 'בחר שם לאוסף החדש',
                              hintStyle: const TextStyle(
                                color: placeholdertxtColor,
                              ),
                              contentPadding:
                                  const EdgeInsets.only(left: 0, right: 16))),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: size.height * 0.25,
              ),
              GradientButton(
                child: animationController.isAnimating
                    ? Center(
                        child: RotationTransition(
                            turns: base,
                            child: Image.asset(
                              AppAssets.loadingIcon,
                              color: Colors.white,
                            )))
                    : Text(
                        widget.isRenameEnabled == true ? "שמור" : "יצירת אוסף",
                        style: textStyle14s400w.copyWith(
                            color: collectionNameController.text.trim().isEmpty
                                ? defaultGrey
                                : kWhite)),
                onPressed: () async {
                  String trimmedName = collectionNameController.text.trim();

                  if (trimmedName.isEmpty) {
                    // Display an error message or perform any action when the name is empty or only spaces
                    // displayMessageIcon(
                    //     message: "נא להזין הודעה חוקית",
                    //     color: Colors.red,
                    //     imageData: AppAssets.errorIcon);
                    return;
                  }

                  try {
                    animationController.repeat();
                    animationController.forward();
                    setState(() {});

                    if (widget.isRenameEnabled == true) {
                      await FireBaseApi.renameCollection(
                              fid: widget.fid ?? "", name: trimmedName)
                          .then((value) {
                        Navigator.of(context).pop();
                      });
                    } else {
                      if (widget.postModel == null) {
                        await FireBaseApi.createFolder(
                                name: trimmedName, fImageUrl: "")
                            .then((value) {
                          if (!Utils.isDataEmpty(value) && value != false) {
                            collectionNameController.text = "";
                            Navigator.of(context).pop();
                          }
                        });
                      } else {
                        await FireBaseApi.createFolder(
                                name: trimmedName,
                                fImageUrl: widget.postModel!.imageName)
                            .then((value) async {
                          if (!Utils.isDataEmpty(value) && value != false) {
                            await FireBaseApi.addFolderImage(
                                    fid: value,
                                    pid: widget.postModel!.id,
                                    imageId: widget.postModel!.imageId,
                                    fimageUrl: widget.postModel!.imageName,
                                    folderName: trimmedName)
                                .then((value) {
                              collectionNameController.text = "";
                              Navigator.of(context).pop();
                            });
                          }
                        });
                      }
                    }
                    animationController.stop();
                    setState(() {});
                    if (widget.isRenameEnabled == true) {
                      Navigator.of(context).pop();
                    }
                  } catch (e) {
                    animationController.stop();
                  }
                },
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
            ],
          ),
        ));
  }
}
