import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/data/model/ArtistModel.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/utils/webService.dart';

class BusinessListController extends GetxController {
  final searchController = TextEditingController();
  RxList<Artist> artistList = <Artist>[].obs;
  RxList<Artist> selectedList = <Artist>[].obs;
  RxList<Artist> filterselectedList = <Artist>[].obs;
  RxBool isLoading = false.obs;
  RxBool isselectedClickable = false.obs;


  /*RxList<Artist> artistList = List.generate(
      10,
      (i) => Artist(
            id: "$i",
            name: "Artist $i",
            aboutText: "About $i",
            address: "Address $i",
            profileImage: "",
          )).obs;*/

  //get artist
  Future getArtists() async {
    isLoading.value = true;
    try {
      await Network.getBusinessListApi(
              btype: WebService.isArtist == "1" ? "2" : "1",
              search_txt: searchController.text)
          .then((list) {
        isLoading.value = false;
        if (list != null && list !=false) {
          artistList.clear();
          List<Artist> newList = (list as List<dynamic>)
              .map((value) => Artist.fromJson(value))
              .toList();
          newList.map((e) {
            if (selectedList.contains(e)) {
            } else {
              artistList.add(e);
            }
          }).toList();

          if (selectedList.isNotEmpty) {
            for (int i = 0; i <= artistList.length; i++) {
              for (int j = 0; j <= selectedList.length; j++) {
                if (artistList[i].id == selectedList[j].id) {
                  artistList.remove(artistList[i]);
                }
              }
            }
          }
        }
      });
    } finally {
      filterselectedList.refresh();
      selectedList.refresh();
      artistList.refresh();
    }
  }

//search artist
  Future searchArtists() async {
    isLoading.value = true;
    if (searchController.text != "") {
      try {
        selectedList.clear();
        selectedList.value = filterselectedList
            .where((artist) => artist.name!
                .toLowerCase()
                .contains(searchController.text.toLowerCase()))
            .toList();
      } finally {
        selectedList.refresh();
        isLoading.value = false;
      }
    } else {
      selectedList.clear();
      selectedList.addAll(filterselectedList);
      selectedList.refresh();
      isLoading.value = false;
    }
  }

  setArtistList(List<Artist> list) {
    filterselectedList.clear();
    selectedList.value = list;
    selectedList.refresh();

    filterselectedList.addAll(selectedList);
    filterselectedList.refresh();
    update();
  }

  selectArtist(Artist artist) {
    print("artist ${artist.name}");
    if (selectedList.value.contains(artist)) {
      selectedList.value.remove(artist);
    } else {
      if (isIdExists(artist.id)) {
      } else {
        selectedList.value.add(artist);
      }
    }
    selectedList.refresh();
    filterselectedList.clear();

    filterselectedList.addAll(selectedList);
    filterselectedList.refresh();
    update();
  }

  bool isIdExists(id) {
    return selectedList.any((element) => element.id == id);
  }
}
