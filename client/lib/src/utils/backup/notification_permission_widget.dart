import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../colors.dart';

class NotificationPermissionDialog extends StatelessWidget {
  const NotificationPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return AlertDialog(
        backgroundColor: signInButtonColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
        contentPadding: const EdgeInsets.all(20.0),
        alignment: Alignment.center,
        content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: size.height * 0.01,
              ),
              const Text(
                "הודעות מושבתות",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: titleTextWhiteColor),
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              const Text(
                "אפשר התראות בהגדרות האפליקציה כדי לקבל עדכונים.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: titleTextWhiteColor,
                ),
              ),
            ]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: styleBgColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: const Text('פתח את ההגדרות'),
                  onPressed: () {
                    openAppSettings();
                    Navigator.of(context).pop();
                  },
                ),
                SizedBox(width: size.width * 0.02),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: errorColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('לְבַטֵל'),
                ),
              ],
            ),
          ),
        ]);
  }
}
