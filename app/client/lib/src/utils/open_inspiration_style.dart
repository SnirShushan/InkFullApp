import 'package:get/get.dart';
import 'package:ink/src/controller/userController.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/business_dashboard.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/bussinessdashboard_binding.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard_binding.dart';
import 'package:ink/src/ui/screen/inspiration/controller/inspiration_controller.dart';
import 'package:ink/src/utils/webService.dart';

String normalizeStyleKey(String? raw) => (raw ?? '')
    .trim()
    .replaceFirst(RegExp(r'^#+'), '')
    .replaceAll('_', ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .toLowerCase();

Future<void> openInspirationForStyle({
  String? slug,
  String? label,
}) async {
  List<StylesList> catalog = [];
  if (Get.isRegistered<UserController>()) {
    catalog = List<StylesList>.from(Get.find<UserController>().style_list);
  }
  if (catalog.isEmpty) {
    final user = await WebService.getCurrentUser();
    catalog = user.stylesList ?? [];
  }

  final slugKey = normalizeStyleKey(slug);
  final labelKey = normalizeStyleKey(label);
  StylesList? found;
  for (final style in catalog) {
    final styleSlug = normalizeStyleKey(style.slug);
    final styleName = normalizeStyleKey(style.name);
    final styleEn = normalizeStyleKey(style.nameEn);
    if (slugKey.isNotEmpty && styleSlug == slugKey) {
      found = style;
      break;
    }
    if (labelKey.isNotEmpty &&
        (styleName == labelKey ||
            styleEn == labelKey ||
            styleSlug == labelKey)) {
      found = style;
      break;
    }
  }

  found ??= slugKey.isEmpty
      ? null
      : StylesList(
          slug: (slug ?? '').trim().isNotEmpty ? slug!.trim() : slugKey,
          name: label,
        );

  if (found?.slug == null || found!.slug!.trim().isEmpty) return;

  WebService.selectstylelist = [found];
  WebService.tempHomeselectstylelist = true;

  if (Get.isRegistered<InspirationController>()) {
    try {
      Get.delete<InspirationController>(force: true);
    } catch (_) {}
  }

  final isBusiness = await WebService.getIsBusiness() == true;
  if (isBusiness) {
    Get.offAll(() => BusinessDashBoard(initialIndex: 1),
        binding: BusinessDashBoardBinding());
  } else {
    Get.offAll(() => const DashBoard(initialIndex: 1),
        binding: DashBoardBinding());
  }
}
