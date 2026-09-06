import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class FirebaseDynamicLinkHelper {
  Future<String> createShortDynamicLink(
      {required String linkType, required String userId}) async {
    final Uri deepLink;
    // if (linkType == "") {
    //   deepLink =
    //       Uri.parse('https://itapp2u.com/apps/Inkapp/api/profile/$userId');
    // } else {
    //   deepLink = Uri.parse(
    //       'https://itapp2u.com/apps/Inkapp/api/profile/$linkType/$userId');
    // }

    if (linkType == "") {
      deepLink =
          Uri.parse("https://inkisrael.co.il/api/?action=POST&pid=$userId");
    } else {
      deepLink = Uri.parse(
          'https://inkisrael.co.il/api/?action=$linkType&pid=$userId');
    }
// Dynamic URL

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix:
          'https://inkapp.page.link', // Your Firebase dynamic link domain
      link: deepLink, // Use dynamic values in the link
      androidParameters: AndroidParameters(
        packageName: 'com.itapp2u.ink', // Your Android package name
        minimumVersion: 1,
        fallbackUrl: Uri.parse(
            'https://play.google.com/store/apps/details?id=com.itapp2u.ink'),
      ),
      iosParameters: const IOSParameters(
        bundleId: 'com.itapp2u.inkapp.ios', // Your iOS bundle ID
        appStoreId: '6447420384', // Your App Store ID (if applicable)
      ),
    );

    final ShortDynamicLink shortLink =
    await FirebaseDynamicLinks.instance.buildShortLink(parameters);

    return shortLink.shortUrl
        .toString(); // Returns short link like https://ins.page.link/KPo2
  }
}
