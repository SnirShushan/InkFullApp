import 'package:easy_localization/easy_localization.dart';

class BSASModel {
  final String title;
  final dynamic basicvalue; // Can hold either String or bool
  final dynamic advancevalue; // Can hold either String or bool

  BSASModel(
      {required this.title,
      required this.basicvalue,
      required this.advancevalue});
}

final purchaseListModel = [
  BSASModel(
      title: "purchases.bsvsps_description_1".tr(),
      basicvalue: false,
      advancevalue: true),
  BSASModel(
      title: "purchases.bsvsps_description_2".tr(),
      basicvalue: false,
      advancevalue: true),
  BSASModel(
      title: "purchases.bsvsps_description_3".tr(),
      basicvalue: false,
      advancevalue: true),
  BSASModel(
      title: "purchases.bsvsps_description_4".tr(),
      basicvalue: false,
      advancevalue: true),
  BSASModel(
      title: "purchases.bsvsps_description_5".tr(),
      basicvalue: true,
      advancevalue: true),
  BSASModel(
      title: "purchases.bsvsps_description_6".tr(),
      basicvalue: true,
      advancevalue: true),
  BSASModel(
      title: "purchases.bsvsps_description_7".tr(),
      basicvalue: true,
      advancevalue: true),
  BSASModel(
      title: "purchases.bsvsps_description_8".tr(),
      basicvalue: true,
      advancevalue: true),
];
