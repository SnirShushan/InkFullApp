import 'package:ink/src/utils/webService.dart';

class FirebaseDynamicLinkHelper {
  static String get shareOrigin {
    final base = WebService.baseUrl;
    return base.replaceFirst(RegExp(r'/api/?$'), '');
  }

  String createShareLink({required String linkType, required String userId}) {
    final action = linkType.trim().isEmpty ? 'POST' : linkType.trim();
    return Uri.parse('$shareOrigin/share').replace(queryParameters: {
      'action': action,
      'pid': userId,
    }).toString();
  }

  Future<String> createShortDynamicLink(
      {required String linkType, required String userId}) async {
    return createShareLink(linkType: linkType, userId: userId);
  }
}
