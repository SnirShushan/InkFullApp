import 'package:flutter/material.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/utils/common.dart';

import '../../../../utils/colors.dart';
import '../../../widgets/unfocus_widget.dart';

class EnterDetails extends StatefulWidget {
  const EnterDetails({Key? key}) : super(key: key);

  @override
  State<EnterDetails> createState() => _EnterDetailsState();
}

class _EnterDetailsState extends State<EnterDetails> {
  bool? isValidMsg = false;
  final TextEditingController commentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return UnFocusWidget(
        child: Scaffold(
      appBar: buildappBarwithback(size: size, title: "צור קשר"),
      body: Padding(
        padding: EdgeInsets.all(size.width * 0.1),
        child: Column(
          children: [
            TextFormField(
              controller: commentController,
              onChanged: (str) {
                if (str.length > 5) {
                  setState(() {
                    isValidMsg = true;
                  });
                } else {
                  setState(() {
                    isValidMsg = false;
                  });
                }
              },
              validator: (str) {
                if (str!.length < 5) {
                  return "הזן הודעה חוקית";
                }
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                label: Text("שליחת פנייה"),
                suffix: isValidMsg!
                    ? Image.asset("assets/icons/ic_check.png",
                        width: size.width * 0.07, height: size.width * 0.07)
                    : SizedBox(),
              ),
            ),
            SizedBox(height: size.height * 0.1),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: defaultAppColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.1)),
                onPressed: () async {
                  if (commentController.text == "" ||
                      commentController.text == null) {
                    displayMessage("נא להזין הודעה חוקית", Colors.red);
                    return;
                  }
                  await Network.contactUs(comment: commentController.text);
                },
                child: Text("שלח"))
          ],
        ),
      ),
    ));
  }
}
