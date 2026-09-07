import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/data/model/ArtistModel.dart';
import 'package:ink/src/ui/screen/profile/changeUserType/controller/businessList_controller.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:signature/signature.dart';

import '../data/model/currentUser.dart';

class ChangeUserTypeController extends GetxController {
  RxBool isStudioSelected = false.obs;
  RxBool isLoading = false.obs;
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final aboutController = TextEditingController();
  final SignatureController signController = SignatureController(
    penStrokeWidth: 5,
    penColor: kWhite,
    exportPenColor: kWhite,
  );
  RxList<Artist> selectedArtists = <Artist>[].obs;
  RxList<String> selectedNewArtists=<String>[].obs;
  RxList<StylesList> selectedStyles = <StylesList>[].obs;
  // RxList<StylesList> selectedStyles = List.generate(
  //     10,
  //     (i) => StylesList(
  //         id: "$i",
  //         imageName: "Style $i",
  //         name: "Style $i",
  //         nameEn: "Style $i",
  //         slug: "Style $i")).obs;


  // RxList<Artist> selectedArtists = List.generate(
  //     10,
  //     (i) => Artist(
  //           id: "$i",
  //           name: "Artist $i",
  //           aboutText: "About $i",
  //           address: "Address $i",
  //           profileImage: "",
  //         )).obs;

  //set business type
  setTypeStudio(bool value) {
    isStudioSelected.value = value;
    clearFields();
    update();
  }

  //set styles
  selectStyle(List<StylesList> styles) {
    selectedStyles.value = styles;
    selectedStyles.refresh();
    update();
  }

  clearFields() {
    final BusinessListController artistListController =
        Get.put(BusinessListController());
    nameController.clear();
    addressController.clear();
    aboutController.clear();
    signController.clear();
    selectedArtists.clear();
    selectedStyles.clear();
    artistListController.artistList.clear();
    artistListController.selectedList.clear();
    update();
  }

  //remove style
  toggleStyles(StylesList style) {
    if (selectedStyles.value.contains(style)) {
      selectedStyles.value.remove(style);
    } else {
      selectedStyles.value.add(style);
    }
    selectedStyles.refresh();
    update();
  }

  //remove style
  toggleArtist(Artist artist) {
    if (selectedArtists.value.contains(artist)) {
      selectedArtists.value.remove(artist);
    } else {
      selectedArtists.value.add(artist);
    }
    selectedArtists.refresh();
    update();
  }

  //artist
  getArtist() async {}
}
