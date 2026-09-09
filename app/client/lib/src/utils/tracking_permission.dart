import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:ink/src/utils/facebook_events/facebook_events.dart';

/// Ask for App Tracking Transparency once on iOS, then enable/disable
/// Facebook advertiser tracking to match the answer. Does not block the UI.
Future<void> requestAppTrackingIfNeeded() async {
  if (!Platform.isIOS) return;
  try {
    final status = await Permission.appTrackingTransparency.request();
    final enabled = status.isGranted;
    await FacebookEvents.facebookAppEvents
        .setAdvertiserTracking(enabled: enabled);
  } catch (_) {
    try {
      await FacebookEvents.facebookAppEvents
          .setAdvertiserTracking(enabled: false);
    } catch (_) {}
  }
}
