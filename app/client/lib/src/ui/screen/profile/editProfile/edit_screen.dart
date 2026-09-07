import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart'
    as gmwp;
import 'package:get/get.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:googlemaps_flutter_webservices/places.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ink/src/controller/artistsListController.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/webService.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../controller/userController.dart';
import '../../../../data/model/currentUser.dart';
import '../../../../data/source/network/user_api.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/permissions.dart';
import '../../../widgets/unfocus_widget.dart';
import 'addArtist.dart';

class EditScreen extends StatefulWidget {
  final String editTitle;
  final int editIndex;
  const EditScreen({Key? key, required this.editTitle, required this.editIndex})
      : super(key: key);

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  bool? isValidMsg = false;
  bool isEditing = true;
  bool isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  //address
  late double lat = WebService.lat;
  late double lang = WebService.lang;
  late String address = WebService.address;
  late String newPlaceId = WebService.placeId;

  //image
  File? pikedFileData;
  String? pickedFilePath;
  final picker = ImagePicker();

  final userController = Get.put(UserController());
  final artistController = Get.put(ArtistListController());

  @override
  void initState() {
    super.initState();
    setState(() {
      _nameController.text = userController.name.value;
      _addressController.text = userController.address.value;
      _aboutController.text = userController.about_text.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return UnFocusWidget(
        child: Scaffold(
      appBar: buildEditAppBar(size: size, title: widget.editTitle),
      body: editWidget(size: size),
    ));
  }

  editWidget({required Size size}) {
    if (widget.editIndex == 0) {
      return buildUpdateName(size: size);
    } else if (widget.editIndex == 1) {
      return buildUpdateAddress(size: size);
    } else if (widget.editIndex == 2) {
      return buildUpdateAbout(size: size);
    } else if (widget.editIndex == 3) {
      return buildArtistUpdate(size: size);
    } else if (widget.editIndex == 4) {
      _checkPermission();
      return buildUpdateImage(size: size);
    } else {}
  }

  /* edit name */
  buildUpdateName({required Size size}) => Padding(
        padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.1, vertical: size.height * 0.05),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              SizedBox(
                width: size.width * 0.6,
                // width: size.width * (isEditing ? 0.6 : 0.8),
                child: TextFormField(
                  controller: _nameController,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                  ],
                  autovalidateMode: AutovalidateMode.always,
                  validator: (String? str) {
                    if (str == null || str.isEmpty) {
                      return "נא להזין שם"; //Please enter name
                    } else if (str.length >= 50) {
                      return "השם ארוך מדי"; //name is to long
                    }
                  },
                  onChanged: (str) {
                    if (str == "" || str.length >= 50) {
                      setState(() {
                        isValidMsg = false;
                      });
                    }
                    if (str.length > 5) {
                      setState(() {
                        isValidMsg = true;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(!isEditing ? 20 : 10)),
                    // label: isEditing ? Text("שם העסק") : Text(""),
                    suffix: isEditing
                        ? (isValidMsg!
                            ? Image.asset("assets/icons/ic_check.png",
                                width: size.width * 0.07,
                                height: size.width * 0.07)
                            : const SizedBox())
                        : const SizedBox(),
                  ),
                ),
              ),
              if (!isEditing && isValidMsg == true)
                buildIconWidget(
                    isFill: false,
                    size: size.width * 0.07,
                    iconPath: "ic_check_green.png",
                    afterTapIcon: "ic_check_green.png",
                    onClick: () {})
            ]),
            SizedBox(height: size.height * 0.1),
            isLoading
                ? showLoadingProgress()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: defaultAppColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.1)),
                    onPressed: () async {
                      if (_nameController.text == userController.name.value ||
                          _nameController.text == "" &&
                              _nameController.text.length >= 50) return;
                      FocusScope.of(context).unfocus();
                      setState(() {
                        isLoading = true;
                      });
                      final AppUser user = await WebService.getCurrentUser();

                      await userController
                          .updateUser(
                              name: _nameController.text,
                              address: user.profile!.address,
                              addressPlaceId: user.profile!.addressPlaceId,
                              lat: user.profile!.addressLat,
                              lng: user.profile!.addressLng,
                              about: user.profile!.aboutText,
                              styles: user.profile!.styles,
                              firebaseId: "")
                          .then((value) => setState(() {
                                isEditing = false;
                                isLoading = false;
                              }));
                    },
                    child: const Text("שמור"))
          ],
        ),
      );

  /* edit address */
  buildUpdateAddress({required Size size}) => Padding(
        padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.1, vertical: size.height * 0.05),
        child: Column(
          children: [
            SizedBox(height: size.height * 0.05),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              SizedBox(
                width: size.width * 0.6,
                // width: size.width * (isEditing ? 0.6 : 0.8),
                child: TextFormField(
                  onTap: () async {
                    var place = await PlacesAutocomplete.show(
                        context: context,
                        apiKey: WebService.googleApiKey,
                        mode: Mode.overlay,
                        language: 'He',
                        types: [],
                        components: [
                          const gmwp.Component(gmwp.Component.country, 'IL')
                        ],
                        onError: (err) {
                          WebService.printMsg(err.errorMessage.toString());
                        });

                    if (place != null) {
                      final plist = GoogleMapsPlaces(
                        apiKey: WebService.googleApiKey,
                        apiHeaders: await const GoogleApiHeaders().getHeaders(),
                      );
                      String placeId = place.placeId ?? "0";
                      final detail = await plist.getDetailsByPlaceId(placeId);
                      final geometry = detail.result.geometry!;
                      newPlaceId = placeId;
                      lat = geometry.location.lat;
                      lang = geometry.location.lng;
                      address = place.description!;

                      setState(() {
                        _addressController.text = address;
                      });
                    }
                  },
                  readOnly: true,
                  controller: _addressController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(!isEditing ? 20 : 10)),
                    suffix: isEditing
                        ? (isValidMsg!
                            ? Image.asset("assets/icons/ic_check.png",
                                width: size.width * 0.07,
                                height: size.width * 0.07)
                            : const SizedBox())
                        : const SizedBox(),
                  ),
                ),
              ),
              if (!isEditing)
                buildIconWidget(
                    isFill: false,
                    size: size.width * 0.07,
                    iconPath: "ic_check_green.png",
                    afterTapIcon: "ic_check_green.png",
                    onClick: () {})
            ]),
            SizedBox(height: size.height * 0.05),
            isLoading
                ? showLoadingProgress()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: defaultAppColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.1)),
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      if (_addressController.text ==
                              userController.address.value ||
                          _addressController.text == "") return;
                      FocusScope.of(context).unfocus();
                      await userController
                          .updateUser(
                              name: userController.name.value,
                              address: address,
                              addressPlaceId: newPlaceId,
                              lat: lat,
                              lng: lang,
                              about: userController.about_text.value,
                              styles: userController.styles.value,
                              firebaseId: "")
                          .then((value) => setState(() {
                                isEditing = false;
                                isLoading = false;
                              }));
                    },
                    child: const Text("שמור"))
          ],
        ),
      );

  /* edit about studio or artist */
  buildUpdateAbout({required Size size}) => Padding(
        padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05, vertical: size.height * 0.05),
        child: Obx(() => SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: size.width * 0.8,
                          // width: size.width * (isEditing ? 0.6 : 0.8),
                          child: TextFormField(
                            controller: _aboutController,
                            autovalidateMode: AutovalidateMode.always,
                            keyboardType: TextInputType.multiline,
                            minLines: 5,
                            maxLines: null,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(400),
                            ],
                            validator: (String? str) {
                              if (str == "" || str == null) {
                                return "";
                              } else if (str.length >= 400) {
                                return ' התיאור ארוך מדי';
                              }
                            },
                            onChanged: (str) {
                              if (str == "" || str == null) {
                                setState(() {
                                  isValidMsg = false;
                                });
                              } else if (str.length >= 200) {
                                setState(() {
                                  isValidMsg = true;
                                });
                              }
                            },
                            decoration: InputDecoration(
                              counterText: "",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      !isEditing ? 20 : 10)),
                              label: userController.about_text.value == ""
                                  ? const Text("על העסק")
                                  : const Text(""),
                              // suffix: isValidMsg!
                              //     ? Image.asset("assets/icons/ic_check.png",
                              //         width: size.width * 0.07, height: size.width * 0.07)
                              //     : SizedBox(),
                            ),
                          ),
                        ),
                        if (!isEditing)
                          buildIconWidget(
                              isFill: false,
                              size: size.width * 0.07,
                              iconPath: "ic_check_green.png",
                              afterTapIcon: "ic_check_green.png",
                              onClick: () {})
                      ]),
                  SizedBox(height: size.height * 0.1),
                  isLoading
                      ? showLoadingProgress()
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: defaultAppColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.1)),
                          onPressed: () async {
                            if (_aboutController.text ==
                                    userController.about_text.value ||
                                _aboutController.text == "") return;
                            FocusScope.of(context).unfocus();
                            setState(() {
                              isLoading = true;
                            });
                            await userController
                                .updateUser(
                                    name: userController.name.value,
                                    address: userController.address.value,
                                    addressPlaceId:
                                        userController.address_place_id.value,
                                    lat: userController.address_lat.value,
                                    lng: userController.address_lng.value,
                                    about: _aboutController.text,
                                    styles:
                                        userController.styles.value.toString(),
                                    firebaseId: "")
                                .then((value) => setState(() {
                                      isEditing = false;
                                      isLoading = false;
                                    }));
                          },
                          child: const Text("שמור"))
                ],
              ),
            )),
      );

  /* update image */
  buildUpdateImage({required Size size}) => Padding(
      padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.1, vertical: size.height * 0.05),
      child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
                child: pickedFilePath == null
                    ? buildCachedNetworkImage(
                        height: size.width * 0.3,
                        width: size.width * 0.3,
                        url: WebService.resolveProfileImage(
                            userController.profileimage.value),
                        radius: size.width * 0.3)
                    : Container(
                        height: size.width * 0.3,
                        width: size.width * 0.3,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                                Radius.circular(size.width * 0.3)),
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: FileImage(pikedFileData!))))),
            SizedBox(height: size.height * 0.1),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              //save
              isLoading
                  ? showLoadingProgress()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: defaultAppColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.1)),
                      onPressed: () async {
                        if (pikedFileData != null) {
                          setState(() {
                            isLoading = true;
                          });
                          await Network.updateProfileImage(
                                  profileImage: pikedFileData!)
                              .then((value) => setState(() {
                                    isLoading = false;
                                  }));
                        }
                      },
                      child: const Text("btn.save").tr()),
              SizedBox(width: size.width * 0.1),
              //change image
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: defaultAppColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.1)),
                  onPressed: () => _showAddPostDialogue(context),
                  child: const Text("שינוי"))
            ]),
          ]));

  /*  add or remove artist */
  buildArtistUpdate({required Size size}) {
    return Padding(
        padding: EdgeInsets.all(size.height * 0.01),
        child: Obx(() => artistController.artistList.isEmpty
            ? Center(
                child: Text(
                        userController.businessType.value == "1"
                            ? "txt.txt_add_studio"
                            : "txt.txt_add_artist",
                        textAlign: TextAlign.center)
                    .tr(),
              )
            : ListView.builder(
                itemCount: artistController.artistList.length,
                reverse: true,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int index) {
                  final image = WebService.resolveProfileImage(artistController
                      .artistList[index].profile?.profileImage);

                  return Padding(
                    padding: EdgeInsets.all(size.height * 0.01),
                    child: ListTile(
                      leading: ClipOval(
                        child: image == null
                            ? Container(
                                height: size.width * 0.12,
                                width: size.width * 0.12,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(50)),
                                    image: DecorationImage(
                                        image: AssetImage(
                                            AppAssets.galleryPlaceholder),
                                        fit: BoxFit.cover)),
                              )
                            : CachedNetworkImage(
                                imageUrl: image,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                      height: size.width * 0.12,
                                      width: size.width * 0.12,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(50)),
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => Container(
                                      height: size.width * 0.12,
                                      width: size.width * 0.12,
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(50)),
                                          image: DecorationImage(
                                            image: AssetImage(
                                                AppAssets.galleryPlaceholder),
                                            fit: BoxFit.cover,
                                          )),
                                    )),
                      ),
                      title: Text(
                          artistController.artistList[index].profile!.name!),
                      subtitle: Text(
                          artistController.artistList[index].profile!.address!),
                      trailing: IconButton(
                          onPressed: () async => await buildDeleteDialog(
                              context, () async => await onDelete(index)),
                          icon: const Icon(Icons.delete_forever)),
                    ),
                  );
                })));
  }

  //delete method
  onDelete(index) async {
    if (userController.businessType.value == "1") {
      await artistController
          .updateArtists(
              artistId: artistController.artistList[index].profile!.id,
              actionStatus: "2")
          .then((value) async => await artistController.getArtists());
    } else {
      await artistController
          .updateStudios(
              studioId: artistController.artistList[index].profile!.id,
              actionStatus: "2")
          .then((value) async => await artistController.getArtists());
    }
  }

  //choose image dialog
  _showAddPostDialogue(BuildContext context) {
    return showModalBottomSheet<dynamic>(
        useRootNavigator: true,
        enableDrag: true,
        context: context,
        clipBehavior: Clip.antiAlias,
        builder: (BuildContext ctx) {
          return Container(
            decoration: const BoxDecoration(
                color: appbarBg,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //close
                InkWell(
                  onTap: () => Get.back(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(ctx).size.height * 0.03,
                        horizontal: MediaQuery.of(ctx).size.width * 0.4),
                    child: Container(
                        margin: const EdgeInsetsDirectional.only(
                            start: 1.0, end: 1.0),
                        height: MediaQuery.of(ctx).size.height * 0.005,
                        width: MediaQuery.of(ctx).size.width * 0.2,
                        color: kDivider),
                  ),
                ),
                //gallery
                InkWell(
                  onTap: () async =>
                      await _selectImage(ctx, ImageSource.gallery),
                  child: Container(
                    width: double.infinity,
                    color: Colors.white,
                    height: MediaQuery.of(ctx).size.height * 0.1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset('assets/icons/ic_gallary.png',
                            width: Get.width * 0.1),
                        const SizedBox(width: 8),
                        Text("העלה תמונה",
                            style: Theme.of(ctx).textTheme.titleMedium) //קעקוע
                      ],
                    ),
                  ),
                ),
                //camera
                InkWell(
                  onTap: () async {
                    PermissionStatus status = await Permission.camera.status;
                    if (status.isGranted || status.isLimited) {
                      _selectImage(context, ImageSource.camera);
                    } else if (status.isDenied) {
                      await openAppSettings();
                    } else {
                      await Permission.camera.request();
                    }
                  },
                  child: SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(ctx).size.height * 0.1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Image.asset('assets/icons/ic_edit.png'),
                        Icon(Icons.camera_alt_outlined, size: Get.width * 0.1),
                        const SizedBox(width: 8),
                        Text("צלם תמונה",
                            style: Theme.of(ctx).textTheme.titleMedium) //סקיצה
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  //select image
  _selectImage(context, source) async {
    if (source == ImageSource.gallery) {
      if (!(await checkPermission())) await requestPermission();
    }

    Navigator.of(context).pop();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
    // if (pickedFile == null) displayMessage("message", Colors.red);
    if (pickedFile == null) return;
    final picked = File(pickedFile.path);
    setState(() {
      pickedFilePath = pickedFile.path;
      pikedFileData = picked;
    });
  }

  //permission
  Future _checkPermission() async {
    if (!(await checkPermission())) await requestPermission();
  }

  //loading
  Widget showLoadingProgress() {
    return const Center(child: CircularProgressIndicator());
  }

  //appbar
  buildEditAppBar({required Size size, required String title}) => AppBar(
      elevation: 0,
      backgroundColor: appbarBg,
      automaticallyImplyLeading: false,
      leading: widget.editIndex == 3
          ? IconButton(
              icon: const Icon(Icons.person_add_alt_sharp, color: Colors.black),
              onPressed: () => Get.to(
                  AddMembers(memberType: userController.businessType.value)))
          : null,
      actions: [CloseButton(color: Colors.black, onPressed: () => Get.back())],
      centerTitle: true,
      toolbarHeight: size.height * 0.1,
      title: Text(title,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: size.height * 0.02))
          .tr());
}
