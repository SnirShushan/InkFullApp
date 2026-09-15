import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/controller/notificationController.dart';
import 'package:ink/src/ui/screen/notification/widget/notification_list_empty_widget.dart';
import 'package:ink/src/ui/screen/notification/widget/request_list_tile.dart';
import 'package:ink/src/ui/widgets/appbar_back_widget.dart';
import 'package:ink/src/ui/widgets/bottomenu/business_dashboard_bottomenu.dart';
import 'package:ink/src/ui/widgets/bottomenu/dashboard_bottomenu.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/utils.dart';
import 'package:ink/src/utils/webService.dart';

class SentRequestsScreen extends StatefulWidget {
  final String currentUserType;

  const SentRequestsScreen({Key? key, required this.currentUserType})
      : super(key: key);

  @override
  State<SentRequestsScreen> createState() => _SentRequestsScreenState();
}

class _SentRequestsScreenState extends State<SentRequestsScreen> {
  late final NotificationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(NotificationController(), tag: 'sentRequests');
    _controller.startIndexRequest = 0;
    _controller.hasMoreRequest.value = true;
    _controller.tattooRequestsList.clear();
    _controller.fetchRequests(type: 'sent');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBlack,
      appBar: const AppBarBackButtonWidget(
        title: 'פניות למקעקעים',
        titleColor: titleTextWhiteColor,
        iconColor: titleTextWhiteColor,
      ),
      bottomNavigationBar: widget.currentUserType == "2"
          ? BusinessDashboardBottomBar(currentIndex: 4)
          : DashboardBottomBar(currentIndex: 3),
      body: Obx(() {
        if (_controller.isLoadingRequest.value &&
            _controller.tattooRequestsList.isEmpty) {
          return Utils.showProgress();
        }
        if (_controller.tattooRequestsList.isEmpty) {
          return const NotificationListEmptyWidget(isAlertList: false);
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: _controller.tattooRequestsList.length,
          itemBuilder: (context, index) {
            final request = _controller.tattooRequestsList[index];
            final business = request.businessRow;
            return RequestListTile(
              notificationController: _controller,
              title: business?.name ?? request.name ?? '',
              tattooSize: WebService.setTattooSize(request.tattooSize ?? ''),
              imgUrl: business?.profileImage ?? '',
              tattooRequest: request,
              markAsRead: false,
            );
          },
        );
      }),
    );
  }
}
