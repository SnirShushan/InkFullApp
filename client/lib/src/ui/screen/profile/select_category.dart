import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/change_user_type.dart';
import 'package:ink/src/controller/myPostController.dart';
import 'package:ink/src/controller/userController.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/ui/screen/profile/drawer/controller/business_profile_menu_controller.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/utils.dart';
import 'package:ink/src/utils/webService.dart';

import '../../../utils/colors.dart';
import '../../widgets/unfocus_widget.dart';
import '../business_user/dashboard/business_dashboard.dart';
import '../business_user/dashboard/bussinessdashboard_binding.dart';
import '../dashboard/dashboard.dart';
import '../dashboard/dashboard_binding.dart';

class SelectCategory extends StatefulWidget {
  final bool fromProfile;
  final bool fromLogin;
  final bool editprofile;
  final bool isChangeUserType;
  final BusinessProfileMenuController? businessProfileMenuController;
  final ChangeUserTypeController? changeUserTypeController;

  const SelectCategory(
      {Key? key,
        this.businessProfileMenuController,
        this.changeUserTypeController,
        this.isChangeUserType=false,
        this.fromProfile = false,
        this.editprofile = false,
        this.fromLogin = false})
      : super(key: key);

  @override
  State<SelectCategory> createState() => _SelectCategoryState();
}

class _SelectCategoryState extends State<SelectCategory>
    with SingleTickerProviderStateMixin {
  List<StylesList> selectedList = [];
  final userController = Get.put(UserController());
  late AnimationController animationController;
  late Animation<double> base;
  bool isbtnLoading = false;
  bool isBusiness=false;
  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    base = CurvedAnimation(parent: animationController, curve: Curves.easeOut);
    getStyles();
    super.initState();
  }

  @override
  void dispose() {
    animationController.stop();
    animationController.dispose();
    super.dispose();
  }

  //set selected styles if from profile
  Future getStyles() async {
    isBusiness = await WebService.getIsBusiness();
    if (WebService.tmpStyleList) {
      userController.style_list.value = List.generate(
          10,
              (i) => StylesList(
              id: "$i",
              imageName: "Style $i",
              name: "Style $i",
              nameEn: "Style $i",
              slug: "Style $i")).obs;
    }

    if (widget.businessProfileMenuController != null) {
      print("ABB");

      selectedList.clear();
      selectedList = userController.style_list
          .where((style) => widget.businessProfileMenuController!.matchingItems
          .any((item) => item.slug == style.slug))
          .toList();
      // selectedList = [...widget.businessProfileMenuController!.matchingItems];
    } else if (widget.changeUserTypeController != null) {
      print("ABB 23");

      selectedList = widget.changeUserTypeController!.selectedStyles.value;
    } else {
      print("ABB 32");

      await userController.initUser();
      List<String> stringList = userController.styles.value.split(",");
      for (int i = 0; i < stringList.length; i++) {
        for (int j = 0; j < userController.style_list.length; j++) {
          if (stringList[i] == userController.style_list.value[j].slug!) {
            selectedList.add(userController.style_list.value[j]);
            selectedList.map((e) => e.slug).toList();
          }
        }
      }
    }
    setState(() {});
  }

  /*@override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.changeUserTypeController != null) {
      selectedList = widget.changeUserTypeController!.selectedStyles.value;
    } else {
      userController.initUser();
      List<String> stringList = userController.styles.value.split(",");
      for (int i = 0; i < stringList.length; i++) {
        for (int j = 0; j < userController.style_list.length; j++) {
          if (stringList[i] == userController.style_list.value[j].slug!) {
            selectedList.add(userController.style_list.value[j]);
            selectedList.map((e) => e.slug).toList();
          }
        }
      }
    }
    setState(() {});
  }*/

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return UnFocusWidget(
        child: Scaffold(
          backgroundColor: bgBlack,
          //drawer: const SideDrawer(),
          bottomSheet: Container(
            color: bgBlack,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              isbtnLoading!
                  ? Align(
                alignment: Alignment.center,
                child: Container(
                    width: size.width,
                    height: size.height * 0.07,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      gradient: LinearGradient(
                        begin: Alignment
                            .centerRight, // For RTL, start from right
                        end: Alignment.centerLeft, // For RTL, end at left
                        colors: [
                          linearGradieantColor1,
                          linearGradieantColor2,
                          linearGradieantColor3,
                        ],
                        stops: [0.0, 0.001, 0.8937],
                      ),
                    ),
                    child: Center(
                      child: RotationTransition(
                          turns: base,
                          child: Image.asset(AppAssets.loadingIcon)),
                    )),
              )
                  : Utils.buildBtnSubmit(
                  context: context,
                  size: size,
                  title: widget.fromLogin
                      ? "אפשר להמשיך"
                      : widget.fromProfile
                      ? "שמירת שינויים"
                      : widget.editprofile
                      ? "אפשר להמשיך"
                      : "שמירת שינויים",
                  onTap: () async {
                    if (selectedList != null) {
                      if (widget.businessProfileMenuController != null) {
                        if (widget.fromProfile == true) {
                          setState(() {
                            isbtnLoading = true;
                            // Repeat the fade animation indefinitely
                            animationController.forward().whenComplete(() {
                              animationController.repeat();
                            });
                          });
                          String newStyles = "";
                          selectedList.forEach((v) {
                            if (v == selectedList.last) {
                              newStyles += v.slug!;
                            } else {
                              newStyles += "${v.slug},";
                            }
                          });
                            Network.businessEditStylesApi(
                              styles: newStyles,
                            ).then((value) async {
                              final MyPostsController myPostsController =
                              Get.put(MyPostsController());
                              await myPostsController.getMyPosts();
                              Navigator.of(context).pop();
                            });
                            widget.businessProfileMenuController!
                                .matchingItems(selectedList);

                        } else {
                          widget.businessProfileMenuController!
                              .matchingItems(selectedList);
                          if (!Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          } else {
                            setState(() {
                              isbtnLoading = true;
                              animationController.repeat();

                              // Play the slide animation once
                              animationController.forward();
                            });
                            Future.delayed(const Duration(seconds: 1), () {
                              if (Navigator.of(context).canPop()) {
                                setState(() {
                                  isbtnLoading = false;
                                });
                                Navigator.of(context).pop();
                              } else {
                                setState(() {
                                  isbtnLoading = false;
                                });
                                Navigator.of(context).pop();
                              }
                            });
                          }
                        }
                      } else if (widget.changeUserTypeController != null) {
                        widget.changeUserTypeController!
                            .selectStyle(selectedList);
                        //
                        // if (!Navigator.of(context).canPop()) {
                        //   Navigator.of(context).pop();
                        // } else {
                        //   Future.delayed(const Duration(milliseconds: 300), () {
                        //     if (Navigator.of(context).canPop()) {
                        //       Navigator.of(context).pop();
                        //     } else {
                        //       Get.back();
                        //     }
                        //   });
                        // }

                        setState(() {
                          isbtnLoading = true;
                          animationController.repeat();

                          // Play the slide animation once
                          animationController.forward();
                        });
                        Future.delayed(const Duration(seconds: 1), () {
                          if (Navigator.of(context).canPop()) {
                            setState(() {
                              isbtnLoading = false;
                            });
                            Navigator.of(context).pop();
                          } else {
                            setState(() {
                              isbtnLoading = false;
                            });
                            Navigator.of(context).pop();
                          }
                        });
                      } else {
                        setState(() {
                          isbtnLoading = true;
                          // Repeat the fade animation indefinitely
                          animationController.repeat();

                          // Play the slide animation once
                          animationController.forward();
                        });
                        String newString = "";
                        selectedList.forEach((v) {
                          if (v == selectedList.last) {
                            newString += v.slug!;
                          } else {
                            newString += "${v.slug},";
                          }
                        });

                        await userController
                            .updateStyles(styles: newString)
                            .then((value) {
                          if (widget.fromProfile) {

                            // Get.off(const BusinessProfileMenuScreen());
                          } else {
                            if (userController.userType.value == "2") {
                              isbtnLoading = false;

                              Get.offAll(
                                  BusinessDashBoard(
                                    initialIndex: 0,
                                  ),
                                  binding: BusinessDashBoardBinding());
                            } else {
                              Get.offAll(
                                  const DashBoard(
                                    initialIndex: 0,
                                  ),
                                  binding: DashBoardBinding());
                            }
                          }

                          if (widget.fromLogin == false) {
                            displayMessageIcon(
                                snackposition: SnackPosition.BOTTOM,
                                message: "השינויים נשמרו",
                                color: const Color(0xFF2E602E),
                                imageData: AppAssets.correct_transparentIcon);
                          }
                        });
                      }
                    }
                  }),
              if (widget.changeUserTypeController == null &&
                  widget.businessProfileMenuController == null ||
                  widget.fromProfile)
                TextButton(
                    onPressed: () {
                      if (widget.fromProfile) {
                        Navigator.of(context).pop();
                        // Get.off(const BusinessProfileMenuScreen());
                      } else {
                        if (userController.userType.value == "2") {
                          Get.offAll(
                              BusinessDashBoard(
                                initialIndex: 0,
                              ),
                              binding: BusinessDashBoardBinding());
                        } else {
                          Get.offAll(
                              const DashBoard(
                                initialIndex: 3,
                              ),
                              binding: DashBoardBinding());
                        }
                      }
                    },
                    child: IntrinsicWidth(
                      child: Column(
                        children: [
                          Text(
                            widget.fromLogin
                                ? "אין לי העדפה מיוחדת"
                                : !widget.fromProfile
                                ? "אין לי העדפה…"
                                : "ביטול",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: titleTextWhiteColor, fontSize: 16),
                          ),
                          SizedBox(height: size.width * 0.01),
                          Container(height: 1, color: titleTextColor),
                          SizedBox(height: size.width * 0.02),
                        ],
                      ),
                    )),
              SizedBox(height: size.height * 0.055),
            ]),
          ),
          body: Column(
            children: [
              if (widget.editprofile) SizedBox(height: size.height * 0.04),
              if (widget.editprofile)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                        icon: SvgPicture.asset(
                          AppAssets.closeIcon,
                          color: titleTextWhiteColor,
                          height: 20,
                          width: 20,
                        ),
                        onPressed: () => Navigator.pop(context)),
                  ),
                ),
              if (widget.editprofile == false) SizedBox(height: size.height * 0.06),
              Utils.buildHeaderTitle(
                  title: widget.fromProfile
                      ? "מה הסגנון שלך?"
                      : widget.fromLogin
                      ? "מה הסגנון שלך?"
                      : widget.businessProfileMenuController != null
                      ? "במה אתם מתמחים?"
                      : "עריכת סגנונות"),
              SizedBox(height: size.height * 0.01),
              Utils.buildHeaderSubtitle(
                  title:
                  widget.isChangeUserType || isBusiness==true
                      ? "בחרו 5 סגנונות שאתם אוהבים"
                      : widget.fromProfile
                      ? "בחרו סגנונות שאתם אוהבים"
                  // ? "בחרו 5 סגנונות שאתם אוהבים"
                      : widget.businessProfileMenuController != null
                      ? "בחרו בסגנונות שהסטודיו חזק בהם"
                      : "בחרו סגנונות שאתם אוהבים"),
              // : "בחרו 5 סגנונות שאתם אוהבים"),

              SizedBox(height: size.height * 0.025),
              //category list
              Expanded(
                child: GridView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    padding: EdgeInsets.only(bottom: size.height * 0.17,top: 0,left: 0,right: 0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisExtent: size.height * 0.22, //5
                        crossAxisSpacing: 3),
                    itemCount: userController.style_list.value.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: ()  => setState(() {
                          if (!selectedList
                              .contains(userController.style_list.value[index])) {
                            if (isBusiness == true || widget.isChangeUserType==true) {
                              if (selectedList.length <= 4) {
                                selectedList
                                    .add(userController.style_list.value[index]);
                              }
                            } else {
                              selectedList
                                  .add(userController.style_list.value[index]);
                            }
                          } else {

                            selectedList
                                .remove(userController.style_list.value[index]);
                          }
                        }),
                        child: Center(
                          child: Stack(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                    color: !selectedList.contains(
                                        userController.style_list.value[index])
                                        ? null
                                        : Colors.white,
                                    elevation: 8,
                                    child: Container(
                                      foregroundDecoration: BoxDecoration(
                                          border: Border.all(
                                              width: 4,
                                              color: !selectedList.contains(
                                                  userController
                                                      .style_list.value[index])
                                                  ? appTransparent
                                                  : appPrimaryColor),
                                          borderRadius: BorderRadius.circular(10),
                                          color: ((isBusiness == true|| widget.isChangeUserType==true) &&selectedList.length >= 5) &&
                                              !selectedList.contains(
                                                  userController
                                                      .style_list.value[index])
                                              ? Colors.black.withOpacity(0.5) //null
                                              : Colors.black.withOpacity(0.2)),
                                      // margin: selectedList.contains(
                                      //         userController.style_list.value[index])
                                      //     ? EdgeInsets.all(size.width * 0.01)
                                      //     : null,
                                      child: buildCachedNetworkImage(
                                          height: size.width * 0.27,
                                          width: size.width * 0.27,
                                          url: WebService.resolveImageUrl(
                                              userController.style_list[index]
                                                  .imageName,
                                              base: WebService.styleImgUrl),
                                          radius: 10),
                                    ),
                                  ),
                                  Text(userController.style_list[index].name!,
                                      style: const TextStyle(color: defaultWhite)),
                                  // Text(userController.style_list[index].nameEn!,style: TextStyle(color: defaultWhite))
                                ],
                              ),
                              if (selectedList
                                  .contains(userController.style_list.value[index]))
                                Positioned(
                                    top: 10,
                                    right: 0,
                                    child:
                                    Image.asset(AppAssets.correctVioletIcon)),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
            ],
          ),
        ));
  }
}
