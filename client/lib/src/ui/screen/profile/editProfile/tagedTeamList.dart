import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/utils/common.dart';

import '../../../../utils/colors.dart';
import '../../../widgets/unfocus_widget.dart';

class TaggedTeam extends StatefulWidget {
  const TaggedTeam({Key? key}) : super(key: key);

  @override
  State<TaggedTeam> createState() => _TaggedTeamState();
}

class _TaggedTeamState extends State<TaggedTeam> {
  String searchedText = "";

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;

    // final Artist artist = postDetailsController.postModel.value.artist!;

    return UnFocusWidget(
        child: Scaffold(
      appBar: buildappBarwithClose(size: size, title: "פתיחת פרופיל עסקי"),
      body: Column(
        children: [
          Padding(
              padding: EdgeInsets.all(size.width * 0.1),
              child: Text("תייג את הצוות שלך בפרופיל העסקי",
                  style: textTheme.titleLarge)),
          buildSearch(context, size),
          buildMemberList(context, size),
        ],
      ),
      bottomSheet: InkWell(
          onTap: () => Get.back(),
          child: Container(
              color: defaultAppColor,
              width: size.width,
              height: size.height * 0.1,
              alignment: Alignment.bottomCenter,
              child: const Center(
                  child: Text("שמור", style: TextStyle(color: defaultWhite))))),
    ));
  }

  buildSearch(BuildContext context, Size size) => Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
        child: TextFormField(
          autofocus: false,
          // textAlign: TextAlign.center,
          onChanged: (str) {
            setState(() {
              searchedText = str;
            });
          },
          onTapOutside: (event) =>
              FocusManager.instance.primaryFocus?.unfocus(),
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(0.0),
              filled: true,
              focusColor: defaultWhite,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  gapPadding: 0.0,
                  borderSide: const BorderSide(color: Colors.black)),
              prefixIcon: const Icon(Icons.search)),
        ),
      );

  buildMemberList(BuildContext context, Size size) => Expanded(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: 4,
          itemBuilder: (context, index) {
            return ListTile(
              minVerticalPadding: size.height * 0.04,
              leading: buildCachedNetworkImage(
                  height: size.width * 0.15,
                  width: size.width * 0.15,
                  url: imgUrl3,
                  radius: 50),
              title: const Text("ךלמילא דעלא",
                  style: TextStyle(overflow: TextOverflow.ellipsis)),
              subtitle: const Text("א״ת"),
              trailing: SizedBox(
                  width: size.width * 0.4,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const VerticalDivider(thickness: 2),
                        SizedBox(
                          width: size.width * 0.25,
                          child: const Text("אלעד אלימלך",
                              style:
                                  TextStyle(overflow: TextOverflow.ellipsis)),
                        ),
                        buildIconWidget(
                            isFill: false,
                            size: size.width * 0.05,
                            iconPath: "ic_delete.png",
                            afterTapIcon: "ic_delete.png",
                            onClick: () {})
                      ])),
            );
          },
        ),
      );
}
