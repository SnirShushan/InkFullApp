import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ink/src/ui/widgets/appbar_back_widget.dart';
import 'package:ink/src/ui/widgets/bottomenu/dashboard_bottomenu.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/utils_styles.dart';

class AgrementRegulations extends StatelessWidget {
  AgrementRegulations({super.key});

  final List<AgrementRegulationsItems> _agrementRegulationsItems = [
    AgrementRegulationsItems(
        headerValue: tr('agreement_regulations.headerValue1'),
        expandedValue: [tr('agreement_regulations.expandedValue1')]),
    AgrementRegulationsItems(
        headerValue: tr('agreement_regulations.headerValue2'),
        expandedValue: [tr('agreement_regulations.expandedValue2')]),
    AgrementRegulationsItems(
        headerValue: tr('agreement_regulations.follow'), expandedValue: []),
    AgrementRegulationsItems(
        headerValue: tr('agreement_regulations.termstitle1'),
        expandedValue: [
          tr('agreement_regulations.termsdetail1'),
          tr('agreement_regulations.termsdetail1_2'),
          tr('agreement_regulations.termsdetail1_3'),
          tr('agreement_regulations.termsdetail1_4'),
          tr('agreement_regulations.termsdetail1_5'),
          tr('agreement_regulations.termsdetail1_6'),
          tr('agreement_regulations.termsdetail1_7'),
          tr('agreement_regulations.termsdetail1_8'),
        ]),
    AgrementRegulationsItems(
        headerValue: tr('agreement_regulations.termstitle2'),
        expandedValue: [
          tr('agreement_regulations.termsdetail2_1'),
          tr('agreement_regulations.termsdetail2_2'),
          tr('agreement_regulations.termsdetail2_3'),
          tr('agreement_regulations.termsdetail2_4'),
          tr('agreement_regulations.termsdetail2_5'),
          tr('agreement_regulations.termsdetail2_6'),
        ]),
    AgrementRegulationsItems(
        headerValue: tr('agreement_regulations.termstitle3'),
        expandedValue: [
          tr('agreement_regulations.termsdetail3_1'),
          tr('agreement_regulations.termsdetail3_2'),
          tr('agreement_regulations.termsdetail3_3'),
          tr('agreement_regulations.termsdetail3_4'),
          tr('agreement_regulations.termsdetail3_5')
        ]),
    AgrementRegulationsItems(
        headerValue: tr('agreement_regulations.termstitle4'),
        expandedValue: [
          tr('agreement_regulations.termsdetail4_1'),
          tr('agreement_regulations.termsdetail4_2')
        ]),
    AgrementRegulationsItems(
        headerValue: tr('agreement_regulations.termstitle5'),
        expandedValue: [
          tr('agreement_regulations.termsdetail5_1'),
          tr('agreement_regulations.termsdetail5_2'),
          tr('agreement_regulations.termsdetail5_3')
        ]),
    AgrementRegulationsItems(
        headerValue: tr('agreement_regulations.termstitle6'),
        expandedValue: [
          tr('agreement_regulations.termsdetail6_1'),
          tr('agreement_regulations.termsdetail6_2'),
          tr('agreement_regulations.termsdetail6_3')
        ]),
    AgrementRegulationsItems(
        headerValue: tr('agreement_regulations.termstitle7'),
        expandedValue: [tr('agreement_regulations.termsdetail7_1')]),
    AgrementRegulationsItems(
        headerValue: tr('agreement_regulations.termstitle8'),
        expandedValue: [
          tr('agreement_regulations.termsdetail8_1'),
          tr('agreement_regulations.termsdetail8_2'),
          tr('agreement_regulations.termsdetail8_3')
        ]),
    AgrementRegulationsItems(
        headerValue: tr('agreement_regulations.termstitle9'),
        expandedValue: [
          tr('agreement_regulations.termsdetail9_1'),
          tr('agreement_regulations.termsdetail9_2'),
          tr('agreement_regulations.termsdetail9_3'),
          tr('agreement_regulations.termsdetail9_4'),
          tr('agreement_regulations.termsdetail9_5'),
          tr('agreement_regulations.termsdetail9_6'),
          tr('agreement_regulations.termsdetail9_7'),
          tr('agreement_regulations.termsdetail9_8'),
        ]),
  ];
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bgBlack,
      appBar: const AppBarBackButtonWidget(
          title: 'תקנון הסכם ספק',
          titleColor: titleTextWhiteColor,
          iconColor: titleTextWhiteColor),
      bottomNavigationBar: DashboardBottomBar(currentIndex: 3),
      body: Padding(
        padding: const EdgeInsets.only(
            left: 16.0, right: 16.0, bottom: 16.0, top: 32),
        child: ListView.builder(
          shrinkWrap: true,

          // physics: const NeverScrollableScrollPhysics(),
          itemCount: _agrementRegulationsItems.length,

          itemBuilder: (context, index) {
            var data = _agrementRegulationsItems[index];
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //point
                Text(data.headerValue.toString(), style: normalBoldWhiteStyle),
                SizedBox(height: size.height * 0.01),
                //description
                if (data.expandedValue.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.expandedValue!.length,
                    itemBuilder: (context, i) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: size.height * 0.02),
                        child: Text(
                          data.expandedValue[i],
                          softWrap: true,
                          textAlign: TextAlign.right,
                          style: normalBoldWhiteStyle.copyWith(
                            wordSpacing: 0.7,
                          ),
                        ),
                      );
                    },
                  ),

                SizedBox(height: size.height * 0.01),
              ],
            );
          },
        ),
      ),
    );
  }
}

class AgrementRegulationsItems {
  AgrementRegulationsItems({
    required this.expandedValue,
    required this.headerValue,
  });

  List<String> expandedValue;
  String headerValue;
}
