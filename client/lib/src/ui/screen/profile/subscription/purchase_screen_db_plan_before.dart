// import 'dart:async';
// import 'dart:io';
//
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:in_app_purchase_android/billing_client_wrappers.dart';
// import 'package:in_app_purchase_android/in_app_purchase_android.dart';
// import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
// import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
// import 'package:ink/src/controller/StartupController.dart';
// import 'package:ink/src/data/source/network/user_api.dart';
// import 'package:ink/src/ui/screen/profile/subscription/consumable_store.dart';
// import 'package:ink/src/ui/screen/profile/subscription/widget/purchase_elevated_button.dart';
// import 'package:ink/src/ui/screen/profile/subscription/widget/purchase_loading_widget.dart';
// import 'package:ink/src/utils/assets.dart';
// import 'package:ink/src/utils/colors.dart';
// import 'package:ink/src/utils/common.dart';
// import 'package:ink/src/utils/webService.dart';
//
// import 'subscription_db_service.dart';
// import 'widget/purchase_footer_widget.dart';
// import 'widget/purchase_header_widget.dart';
// import 'widget/purchase_plan_header_widget.dart';
//
// final bool _kAutoConsume = Platform.isIOS || true;
//
// const String _kBasicMonthlyId = 'monthly_basic_plan';
// const String _kBasicYearlyId = 'yearly_basic_plan';
// const String _kPremiumMonthlyId = 'monthly_premium_plan';
// const String _kPremiumYearlyId = 'yearly_premium_plan';
//
// const List<String> _kProductIds = <String>[
//   _kBasicMonthlyId,
//   _kBasicYearlyId,
//   _kPremiumMonthlyId,
//   _kPremiumYearlyId
// ];
//
// class PurchaseScreen extends StatefulWidget {
//   final bool fromRegistration;
//   final String checkstatus;
//
//   const PurchaseScreen(
//       {Key? key, required this.fromRegistration, required this.checkstatus})
//       : super(key: key);
//
//   @override
//   _PurchaseScreenState createState() => _PurchaseScreenState();
// }
//
// var userid;
//
// class _PurchaseScreenState extends State<PurchaseScreen> {
//   final InAppPurchase _inAppPurchase = InAppPurchase.instance;
//   late StreamSubscription<List<PurchaseDetails>> _subscription;
//   List<String> _notFoundIds = <String>[];
//   List<ProductDetails> _products = <ProductDetails>[];
//   List<PurchaseDetails> _purchases = <PurchaseDetails>[];
//   List<String> _consumables = <String>[];
//   bool _isAvailable = false;
//   bool _purchasePending = false;
//   bool _loading = true;
//   String? _queryProductError;
//   int selectedItem = 0;
//   String productid = "";
//   bool isLoading = true;
//   bool isrestoremessageLoading =
//   false; // Used For Restore purchase loading show
//   final ScrollController _scrollController = ScrollController();
//   late PageController _pageController;
//
//   final StartupController startupController = Get.put(StartupController());
//
//   @override
//   void initState() {
//     SubscriptionDbService.fromRegistration = widget.fromRegistration;
//     final Stream<List<PurchaseDetails>> purchaseUpdated =
//         _inAppPurchase.purchaseStream;
//     _subscription =
//         purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
//           _listenToPurchaseUpdated(purchaseDetailsList);
//         }, onDone: () {
//           _subscription.cancel();
//         }, onError: (Object error) {
//           // handle error here.
//         });
//     initStoreInfo();
//
//     _pageController = PageController(viewportFraction: 0.95);
//     initData();
//     super.initState();
//   }
//
//   initData() {
//     Future.delayed(const Duration(seconds: 2), () {
//       setState(() {
//         isLoading = false;
//       });
//     });
//   }
//
//   Future<void> initStoreInfo() async {
//     // await
//     final bool isAvailable = await _inAppPurchase.isAvailable();
//     if (!isAvailable) {
//       setState(() {
//         _isAvailable = isAvailable;
//         _products = <ProductDetails>[];
//         _purchases = <PurchaseDetails>[];
//         _notFoundIds = <String>[];
//         _consumables = <String>[];
//         _purchasePending = false;
//         _loading = false;
//       });
//       return;
//     }
//
//     if (Platform.isIOS) {
//       final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
//       _inAppPurchase
//           .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
//       await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
//     }
//
//     final ProductDetailsResponse productDetailResponse =
//     await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
//
//     if (productDetailResponse.error != null) {
//       setState(() {
//         _queryProductError = productDetailResponse.error!.message;
//         _isAvailable = isAvailable;
//         _products = productDetailResponse.productDetails;
//         _purchases = <PurchaseDetails>[];
//         _notFoundIds = productDetailResponse.notFoundIDs;
//         _consumables = <String>[];
//         _purchasePending = false;
//         _loading = false;
//       });
//       return;
//     }
//
//     if (productDetailResponse.productDetails.isEmpty) {
//       setState(() {
//         _queryProductError = null;
//         _isAvailable = isAvailable;
//         _products = productDetailResponse.productDetails;
//         _purchases = <PurchaseDetails>[];
//         _notFoundIds = productDetailResponse.notFoundIDs;
//         _consumables = <String>[];
//         _purchasePending = false;
//         _loading = false;
//       });
//       return;
//     }
//
//     final List<String> consumables = await ConsumableStore.load();
//     setState(() {
//       _isAvailable = isAvailable;
//       _products = productDetailResponse.productDetails;
//       _notFoundIds = productDetailResponse.notFoundIDs;
//       _consumables = consumables;
//       _purchasePending = false;
//       _loading = false;
//     });
//
//     widget.fromRegistration ? "" : _inAppPurchase.restorePurchases();
//     userid = await WebService.getUserIds();
//
//     checkSubscriptionData();
//   }
//
//   @override
//   void dispose() {
//     if (Platform.isIOS) {
//       final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
//       _inAppPurchase
//           .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
//       iosPlatformAddition.setDelegate(null);
//     }
//     _subscription.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final List<Widget> stack = <Widget>[];
//     if (_queryProductError == null) {
//       stack.add(
//         ListView(
//           controller: _scrollController,
//           children: <Widget>[
//             _buildConnectionCheckTile(),
//             _buildProductList(),
//             // _buildConsumableBox(),
//           ],
//         ),
//       );
//     } else {
//       stack.add(Center(
//         child: Text(_queryProductError!),
//       ));
//     }
//     if (_purchasePending) {
//       stack.add(
//         // TODO(goderbauer): Make this const when that's available on stable.
//         // ignore: prefer_const_constructors
//         Stack(
//           children: const <Widget>[SizedBox()],
//         ),
//       );
//     }
//     var size = MediaQuery.of(context).size;
//     return Scaffold(
//       backgroundColor: isLoading ? bgBlack : Colors.white,
//       body: _loading
//           ? const Center(
//         child: CircularProgressIndicator(),
//       )
//           : widget.fromRegistration && _purchasePending
//           ? const PurchaseLoadingWidget()
//           : _purchasePending
//           ? const Stack(
//         clipBehavior: Clip.none,
//         children: <Widget>[
//           Opacity(
//             opacity: 0.9,
//             child: ModalBarrier(
//                 dismissible: false, color: defaultAppColor),
//           ),
//           Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CircularProgressIndicator(
//                   color: Colors.white,
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Text(
//                   'Loading Product Details, Please wait...',
//                   style: TextStyle(color: Colors.white),
//                 )
//               ],
//             ),
//           )
//         ],
//       )
//           : Stack(
//         children: [
//           Stack(
//             clipBehavior: Clip.none,
//             children: [
//               Image.asset(AppAssets.purchasebg,
//                   width: size.width,
//                   height: size.height * 0.5,
//                   fit: BoxFit.fitWidth),
//               Positioned(
//                 top: size.height * 0.08,
//                 right: 20,
//                 child: InkWell(
//                   onTap: () {
//                     if (!Navigator.of(context).canPop()) {
//                       Navigator.of(context).pop();
//                     } else {
//                       Future.delayed(
//                           const Duration(milliseconds: 300), () {
//                         if (Navigator.of(context).canPop()) {
//                           Navigator.of(context).pop();
//                         } else {
//                           Get.back();
//                         }
//                       });
//                     }
//                   },
//                   child: Row(
//                     children: [
//                       SvgPicture.asset(AppAssets.backarrowIcon,
//                           color: titleTextColor,
//                           width: 24,
//                           height: 24),
//                       SizedBox(width: size.width * 0.02),
//                       const Text(
//                         "חזרה",
//                         style: TextStyle(
//                           color: Color(0xFFC0BCC4),
//                           fontSize: 16,
//                           fontFamily: 'Arimo',
//                           fontWeight: FontWeight.w400,
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox.expand(
//             child: DraggableScrollableSheet(
//                 initialChildSize: 0.8,
//                 maxChildSize: 1.0,
//                 minChildSize: 0.8,
//                 builder: (BuildContext context,
//                     ScrollController scrollController) {
//                   return Container(
//                     padding: const EdgeInsets.only(
//                         left: 12.0,
//                         right: 12,
//                         bottom: 12,
//                         top: 4),
//                     decoration: const BoxDecoration(
//                         color: bgBlack,
//                         borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(25),
//                             topRight: Radius.circular(25))),
//                     height: size.height,
//                     child: Stack(
//                       children: stack,
//                     ),
//                   );
//                 }),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Card _buildConnectionCheckTile() {
//     if (_loading) {
//       return const Card(
//           elevation: 0, child: ListTile(title: Text('Trying to connect...')));
//     }
//
//     final Widget storeHeader = _loading ? Container() : const SizedBox();
//     final List<Widget> children = <Widget>[storeHeader];
//
//     if (!_isAvailable) {
//       children.addAll(<Widget>[
//         const Divider(),
//         ListTile(
//           title: Text('Not connected',
//               style: TextStyle(color: ThemeData.light().colorScheme.error)),
//           subtitle: const Text(
//               'Unable to connect to the payments processor. Has this app been configured correctly? See the example README for instructions.'),
//         ),
//       ]);
//     }
//     return Card(elevation: 0, child: Column(children: children));
//   }
//
//   Card _buildProductList() {
//     if (_loading) {
//       return const Card(
//           child: ListTile(
//               leading: CircularProgressIndicator(),
//               title: Text('Fetching products...')));
//     }
//     if (!_isAvailable) {
//       return const Card();
//     }
//
//     // This loading previous purchases code is just a demo. Please do not use this as it is.
//     // In your app you should always verify the purchase data using the `verificationData` inside the [PurchaseDetails] object before trusting it.
//     // We recommend that you use your own server to verify the purchase data.
//     final Map<String, PurchaseDetails> purchases =
//     Map<String, PurchaseDetails>.fromEntries(
//         _purchases.map((PurchaseDetails purchase) {
//           if (purchase.pendingCompletePurchase) {
//             _inAppPurchase.completePurchase(purchase);
//           }
//           return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
//         }));
//
//     return Card(
//         elevation: 0,
//         color: bgBlack,
//         margin: EdgeInsets.zero,
//         child: Column(children: [
//           const PurchaseHeaderWidget(),
//
//           buildBasicPlanContainer(purchases),
//           SizedBox(height: MediaQuery.of(context).size.height * 0.02),
//           buildPremiumPlanContainer(purchases),
//           SizedBox(height: MediaQuery.of(context).size.height * 0.02),
//           // Padding(
//           //   padding: const EdgeInsets.all(8.0),
//           //   child: SizedBox(
//           //     height: Get.height * 0.13,
//           //     child: ListView.builder(
//           //         scrollDirection: Axis.horizontal,
//           //         itemCount: _products.length,
//           //         itemBuilder: (context, index) {
//           //           final PurchaseDetails? previousPurchase =
//           //               purchases[_products[index].id];
//           //           return InkWell(
//           //             onTap: () {
//           //               setState(() {
//           //                 selectedItem = index;
//           //               });
//           //             },
//           //             child: Padding(
//           //               padding: const EdgeInsets.only(right: 8),
//           //               child: SizedBox(
//           //                 width: Get.width * 0.44,
//           //                 child: Card(
//           //                     color: selectedItem == index
//           //                         ? Colors.purple
//           //                         : Colors.white,
//           //                     elevation: 10,
//           //                     child: previousPurchase != null && Platform.isIOS
//           //                         ? IconButton(
//           //                             onPressed: () =>
//           //                                 confirmPriceChange(context),
//           //                             icon: const Icon(Icons.upgrade))
//           //                         : Column(
//           //                             mainAxisAlignment:
//           //                                 MainAxisAlignment.spaceEvenly,
//           //                             children: [
//           //                               Text(
//           //                                   _products[index].id ==
//           //                                           _kBasicMonthlyId
//           //                                       ? "בסיסי"
//           //                                       : "מתקדם",
//           //                                   style: Get.textTheme.titleMedium!
//           //                                       .copyWith(
//           //                                           color: selectedItem == index
//           //                                               ? Colors.white
//           //                                               : Colors.black)),
//           //                               Text(_products[index].price.toString(),
//           //                                   style: Get.textTheme.titleMedium!
//           //                                       .copyWith(
//           //                                           fontWeight: FontWeight.bold,
//           //                                           color: selectedItem == index
//           //                                               ? Colors.white
//           //                                               : Colors.black)),
//           //                               Text(_products[index].id.toString(),
//           //                                   style: Get.textTheme.bodySmall!
//           //                                       .copyWith(
//           //                                           color: selectedItem == index
//           //                                               ? Colors.white
//           //                                               : Colors.black))
//           //                             ],
//           //                           )),
//           //               ),
//           //             ),
//           //           );
//           //         }),
//           //   ),
//           // ),
//           // SizedBox(height: Get.size.height * 0.01),
//           // Padding(
//           //   padding: const EdgeInsets.symmetric(vertical: 8.0),
//           //   child: SizedBox(
//           //     width: Get.width * 0.9,
//           //     height: Get.size.height * 0.06,
//           //     child: productid == _kBasicMonthlyId && selectedItem == 0 ||
//           //             productid == _kBasicYearlyId && selectedItem == 1
//           //         ? Align(
//           //             alignment: Alignment.center,
//           //             child: Text("אתה מנוי במסלול זה",
//           //                 style: Get.textTheme.titleMedium!
//           //                     .copyWith(color: appPrimaryColor)),
//           //           )
//           //         : ElevatedButton(
//           //             onPressed: () async {
//           //               final PurchaseDetails? previousPurchase =
//           //                   purchases[_products[selectedItem].id];
//           //               if (previousPurchase != null && Platform.isIOS) {
//           //                 confirmPriceChange(context);
//           //               } else {
//           //                 late PurchaseParam purchaseParam;
//           //
//           //                 if (Platform.isAndroid) {
//           //                   // NOTE: If you are making a subscription purchase/upgrade/downgrade, we recommend you to
//           //                   // verify the latest status of you your subscription by using server side receipt validation
//           //                   // and update the UI accordingly. The subscription purchase status shown
//           //                   // inside the app may not be accurate.
//           //                   final GooglePlayPurchaseDetails? oldSubscription =
//           //                       await _getOldSubscription(
//           //                           _products[selectedItem], purchases);
//           //
//           //                   print("oldSubscription $oldSubscription");
//           //
//           //                   purchaseParam = GooglePlayPurchaseParam(
//           //                       productDetails: _products[selectedItem],
//           //                       changeSubscriptionParam:
//           //                           (oldSubscription != null)
//           //                               ? ChangeSubscriptionParam(
//           //                                   oldPurchaseDetails: oldSubscription,
//           //                                   prorationMode: ProrationMode
//           //                                       .immediateAndChargeFullPrice,
//           //                                 )
//           //                               : null);
//           //                 } else {
//           //                   purchaseParam = PurchaseParam(
//           //                     productDetails: _products[selectedItem],
//           //                   );
//           //                 }
//           //                 _inAppPurchase.buyNonConsumable(
//           //                     purchaseParam: purchaseParam);
//           //               }
//           //             },
//           //             style: ElevatedButton.styleFrom(
//           //                 backgroundColor: appPrimaryColor,
//           //                 // : defaultGrey,
//           //                 shape: const RoundedRectangleBorder(
//           //                     borderRadius:
//           //                         BorderRadius.all(Radius.circular(16)))),
//           //             child: Text(
//           //                 productid == _kBasicMonthlyId && selectedItem == 0 ||
//           //                         productid == _kBasicYearlyId &&
//           //                             selectedItem == 1
//           //                     ? "אתה מנוי במסלול זה"
//           //                     : productid == _kBasicMonthlyId &&
//           //                             selectedItem == 1
//           //                         ? "שדרג למסלול זה"
//           //                         : productid == _kBasicYearlyId &&
//           //                                 selectedItem == 0
//           //                             ? "שנמוך למסלול זה"
//           //                             : "המשך",
//           //                 style: Get.textTheme.titleMedium!
//           //                     .copyWith(color: Colors.white))),
//           //   ),
//           // ),
//           SizedBox(height: MediaQuery.of(context).size.height * 0.02),
//           PurchaseFooterWidget(
//             onbasicClick: () => _scrollController.animateTo(
//               _scrollController.position.minScrollExtent,
//               duration: const Duration(seconds: 1),
//               curve: Curves.easeInOut,
//             ),
//             onpremiumClick: () => _scrollController.animateTo(
//               _scrollController.position.maxScrollExtent / 3,
//               duration: const Duration(seconds: 1),
//               curve: Curves.easeInOut,
//             ),
//             onRestorePurchase: () async {
//               try {
//                 setState(() {
//                   isrestoremessageLoading = true;
//                   print("isrestoremessageLoading $isrestoremessageLoading");
//                 });
//                 final bool available = await _inAppPurchase.isAvailable();
//
//                 if (available) {
//                   await _inAppPurchase.restorePurchases().then((value) {
//                     setState(() {
//                       isrestoremessageLoading = false;
//                       Navigator.of(context).pop();
//                     });
//                   });
//                 } else {
//                   setState(() {
//                     isrestoremessageLoading = false;
//
//                     Navigator.of(context).pop();
//                     print("isrestoremessageLoading $isrestoremessageLoading");
//                   });
//                 }
//               } catch (e) {
//                 setState(() {
//                   WebService.isrestoremessageLoading = false;
//                 });
//               }
//             },
//             // isLoading: isrestoremessageLoading,
//           ),
//         ]));
//   }
//
//   Future<void> consume(String id) async {
//     await ConsumableStore.consume(id);
//     final List<String> consumables = await ConsumableStore.load();
//     setState(() {
//       _consumables = consumables;
//     });
//   }
//
//   void showPendingUI() {
//     setState(() {
//       _purchasePending = true;
//     });
//   }
//
//   Future<void> deliverProduct(PurchaseDetails purchaseDetails,String purchaseStatus) async {
//     try {
//
//       if (Platform.isAndroid) {
//         print("ABBBC 2");
//         await SubscriptionDbService()
//             .saveSubcriptionsDetails(purchaseDetails,purchaseStatus)
//             .then(
//                 (value) => startupController.checkSubscription().then((value) {
//               setState(() {
//                 if (Platform.isAndroid) {
//                   selectedItem = startupController
//                       .subscriptionModel.subscriptionStatus
//                       .toString() ==
//                       "0"
//                       ? 0
//                       : startupController.subscriptionModel.isPremium
//                       .toString() ==
//                       "1"
//                       ? 1
//                       : 0;
//                   productid = startupController
//                       .subscriptionModel.subscriptionStatus
//                       .toString() ==
//                       "0"
//                       ? ""
//                       : startupController.subscriptionModel.productId
//                       .toString();
//                 } else {
//                   productid = purchaseDetails.productID.toString();
//                 }
//
//                 _purchases.add(purchaseDetails);
//                 _purchasePending = false;
//                 isLoading = false;
//               });
//             }));
//       } else {
//         await SubscriptionDbService()
//             .saveSubcriptionsDetailsIOS(purchaseDetails);
//       }
//     } catch (e) {
//       print("Cache Erorr ${e.toString()}");
//     }
//   }
//
//   void handleError(IAPError error) {
//     setState(() {
//       _purchasePending = false;
//     });
//   }
//
//   Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
//     return Future<bool>.value(true);
//     // return isSubscribed;
//   }
//
//   void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
//     displayMessageIcon(
//         snackposition: SnackPosition.BOTTOM,
//         message:
//         "Something went wrong \n Purchase status : ${purchaseDetails.status}",
//         color: errorColor,
//         imageData: AppAssets.errorIcon);
//     // handle invalid purchase here if  _verifyPurchase` failed.
//   }
//
//   Future<void> _listenToPurchaseUpdated(
//       List<PurchaseDetails> purchaseDetailsList) async {
//     for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
//       if (purchaseDetails.status == PurchaseStatus.pending) {
//         showPendingUI();
//       } else {
//         if (purchaseDetails.status == PurchaseStatus.error) {
//           handleError(purchaseDetails.error!);
//         } else if (purchaseDetails.status == PurchaseStatus.purchased) {
//           final bool valid = await _verifyPurchase(purchaseDetails);
//           print("ABBBBBBBBBB $valid");
//           if (valid) {
//             unawaited(deliverProduct(purchaseDetails,"Purchased"));
//           } else {
//             _handleInvalidPurchase(purchaseDetails);
//             return;
//           }
//         } else if (purchaseDetails.status == PurchaseStatus.restored) {
//           final bool valid = await _verifyPurchase(purchaseDetails);
//
//           if (valid) {
//             unawaited(deliverProduct(purchaseDetails,"Restored"));
//           } else {
//             _handleInvalidPurchase(purchaseDetails);
//             return;
//           }
//         }
//         if (Platform.isAndroid) {
//           if (!_kAutoConsume) {
//             final InAppPurchaseAndroidPlatformAddition androidAddition =
//             _inAppPurchase.getPlatformAddition<
//                 InAppPurchaseAndroidPlatformAddition>();
//             await androidAddition.consumePurchase(purchaseDetails);
//           }
//         }
//         if (purchaseDetails.pendingCompletePurchase) {
//           await _inAppPurchase.completePurchase(purchaseDetails);
//         }
//       }
//     }
//   }
//
//   Future<void> confirmPriceChange(BuildContext context) async {
//     // Price changes for Android are not handled by the application, but are
//     // instead handled by the Play Store. See
//     // https://developer.android.com/google/play/billing/price-changes for more
//     // information on price changes on Android.
//     if (Platform.isIOS) {
//       final InAppPurchaseStoreKitPlatformAddition iapStoreKitPlatformAddition =
//       _inAppPurchase
//           .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
//       await iapStoreKitPlatformAddition.showPriceConsentIfNeeded();
//     }
//   }
//
//   GooglePlayPurchaseDetails? _getOldSubscription(
//       ProductDetails productDetails, Map<String, PurchaseDetails> purchases) {
//     GooglePlayPurchaseDetails? oldSubscription;
//
//     if (purchases[_kPremiumMonthlyId] != null &&
//         productDetails.id != _kPremiumMonthlyId) {
//       oldSubscription =
//       purchases[_kPremiumMonthlyId] as GooglePlayPurchaseDetails?;
//     } else if (purchases[_kPremiumYearlyId] != null &&
//         productDetails.id != _kPremiumYearlyId) {
//       oldSubscription =
//       purchases[_kPremiumYearlyId] as GooglePlayPurchaseDetails?;
//     } else if (purchases[_kBasicMonthlyId] != null &&
//         productDetails.id != _kBasicMonthlyId) {
//       oldSubscription =
//       purchases[_kBasicMonthlyId] as GooglePlayPurchaseDetails?;
//     } else if (purchases[_kBasicYearlyId] != null &&
//         productDetails.id != _kBasicYearlyId) {
//       oldSubscription =
//       purchases[_kBasicYearlyId] as GooglePlayPurchaseDetails?;
//     }
//     return oldSubscription;
//   }
//
//   Container buildBasicPlanContainer(purchases) {
//     String yearlyPrice = "₪1599.90 לשנה";
//     String monthlyPrice = " ₪149.90 לשנה";
//
//     String freePlanMonthlyAvaliable = "";
//
//     try {
//       yearlyPrice = _products
//           .lastWhere((product) => product.id == _kBasicYearlyId)
//           .rawPrice
//           .toString();
//     } catch (e) {
//       yearlyPrice = "₪1599.90 לשנה"; // Default price
//     }
//
//     try {
//       monthlyPrice = _products
//           .lastWhere((product) => product.id == _kBasicMonthlyId)
//           .price;
//
//       freePlanMonthlyAvaliable = _products
//           .firstWhere((product) => product.id == _kBasicMonthlyId)
//           .rawPrice
//           .toString();
//     } catch (e) {
//       monthlyPrice = " ₪149.90 לשנה"; // Default price
//     }
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//           color: purchasebgcolor, borderRadius: BorderRadius.circular(16)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           PurchasePlanHeaderWidget(isBasicPlan: true),
//           // startupController.subscriptionModel.productId == _kBasicYearlyId
//           //     // ? buildProductBuyText(
//           //     //     title: tr("purchases.basic_yearly_plan_buy"))
//           //
//           //     ? buildProductBuyText(
//           //         title:
//           //             " אתה מנוי במסלול זה\nתשלום שנתי של $yearlyPrice גבה אוטומטית ")
//           //     : PurchaseElevatedBtnWidget(
//           //         isbasicplan: true,
//           //         onTaps: () {
//           //           List<ProductDetails> isFind = _products
//           //               .where((element) => element.id == _kBasicYearlyId)
//           //               .toList();
//           //           if (isFind.isNotEmpty) {
//           //             PurchaseBtnClick(isFind[0], purchases);
//           //           } else {
//           //             displayMessage(
//           //                 'No matching item found for ID:$_kBasicYearlyId',
//           //                 Colors.red);
//           //           }
//           //         },
//           //         // title: "₪420 לשנה",
//           //         // title: "₪1599 לשנה"
//           //         title: yearlyPrice,
//           //         subtitle: tr("purchases.basic_yearly_subtitle")),
//           // SizedBox(height: MediaQuery.of(context).size.height * 0.02),
//           startupController.subscriptionModel.productId == _kBasicMonthlyId
//           // ? buildProductBuyText(
//           //     title: tr("purchases.basic_monthly_plan_buy"))
//               ? buildProductBuyText(
//               title:
//               " אתה מנוי במסלול זה\nתשלום חודשי של ${addSuffixIfEndsWithDotNine(monthlyPrice)} יגבה אוטומטית ")
//               : startupController.subscriptionModel.productId == _kBasicYearlyId
//               ? buildProductBuyText(
//               title:
//               " אתה מנוי במסלול זה\nתשלום שנתי של $yearlyPrice גבה אוטומטית ")
//           // : PurchaseOutlineWidget(
//               : PurchaseElevatedBtnWidget(
//               isbasicplan: true,
//               // onTaps: (){
//               //   Get.back();
//               // },
//               onTaps: () async {
//                 bool isConnected =
//                 await WebService.checkConnectionNoMsg();
//                 if (!isConnected) return;
//                 Network.testServerApi().then((value) async {
//                   if (value != false) {
//                     List<ProductDetails> isFind = await _products
//                         .where(
//                             (element) => element.id == _kBasicMonthlyId)
//                         .toList();
//
//                     if (isFind.isNotEmpty) {
//                       WebService.setPrice(
//                           plan: 0,
//                           products: _products,
//                           pID: _kBasicMonthlyId);
//                       PurchaseBtnClick(isFind[0], purchases);
//                     } else {
//                       displayMessageIcon(
//                           snackposition: SnackPosition.BOTTOM,
//                           message:
//                           'No matching item found for ID:$_kBasicMonthlyId',
//                           color: errorColor,
//                           imageData: AppAssets.errorIcon);
//                     }
//                   }
//                 });
//               },
//               // title: "₪35 לחודש",
//               // title: "₪149 לחודש",
//
//               ismainscreen: true,
//               title: "התחילו ללא עלות",
//               // title: freePlanMonthlyAvaliable == "0.0" &&
//               //         widget.checkstatus == "0"
//               //     ? "${addSuffixIfEndsWithDotNine(monthlyPrice)}\n3 חודשים ראשונים חינם"
//               //     : addSuffixIfEndsWithDotNine(monthlyPrice),
//               subtitle: tr("purchases.basic_monthly_subtitle")),
//           SizedBox(height: MediaQuery.of(context).size.height * 0.01),
//         ],
//       ),
//     );
//   }
//
//   Align buildProductBuyText({bool isbasic = true, required String title}) {
//     return Align(
//       alignment: Alignment.center,
//       child: Text(title,
//           textAlign: TextAlign.center,
//           style: Get.textTheme.titleMedium!
//               .copyWith(color: isbasic ? appPrimaryColor : advanceplancolor)),
//     );
//   }
//
//   Container buildPremiumPlanContainer(purchases) {
//     String yearlyPremiumPrice = "₪2699.90 לשנה";
//     String monthlyPremiumPrice = " ₪249.90 לשנה";
//     String freePlanMonthlyAvaliable = "";
//
//     if (_products is AppStoreProductDetails) {
//       SKProductWrapper skProduct =
//           (_products as AppStoreProductDetails).skProduct;
//       print(skProduct.subscriptionGroupIdentifier);
//     }
//     try {
//       yearlyPremiumPrice = _products
//           .lastWhere((product) => product.id == _kPremiumYearlyId)
//           .price;
//     } catch (e) {
//       yearlyPremiumPrice = "₪2699.90 לשנה"; // Default price
//     }
//
//     try {
//       monthlyPremiumPrice = _products
//           .lastWhere((product) => product.id == _kPremiumMonthlyId)
//           .price;
//
//       freePlanMonthlyAvaliable = _products
//           .firstWhere((product) => product.id == _kPremiumMonthlyId)
//           .rawPrice
//           .toString();
//     } catch (e) {
//       monthlyPremiumPrice = " ₪249.90 לשנה"; // Default price
//     }
//
//     // print("yearlyPremiumPrice $yearlyPremiumPrice");
//     // print("monthlyPremiumPrice $monthlyPremiumPrice");
//     // print("freePlanMonthlyAvaliable $freePlanMonthlyAvaliable");
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//           color: purchasebgcolor, borderRadius: BorderRadius.circular(16)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           PurchasePlanHeaderWidget(isBasicPlan: false),
//
//           // startupController.subscriptionModel.productId == _kPremiumYearlyId
//           //     ? buildProductBuyText(
//           //         isbasic: false,
//           //         // title: tr("purchases.premium_yearly_plan_buy"))
//           //         title:
//           //             " אתה מנוי במסלול זה\nתשלום שנתי של $yearlyPremiumPrice יגבה אוטומטית ")
//           //     : PurchaseElevatedBtnWidget(
//           //         isbasicplan: false,
//           //         onTaps: () {
//           //           List<ProductDetails> isFind = _products
//           //               .where((element) => element.id == _kPremiumYearlyId)
//           //               .toList();
//           //
//           //           if (isFind.isNotEmpty) {
//           //             PurchaseBtnClick(isFind[0], purchases);
//           //           } else {
//           //             displayMessage(
//           //                 'No matching item found for ID:$_kPremiumYearlyId',
//           //                 Colors.red);
//           //           }
//           //         },
//           //         title: yearlyPremiumPrice,
//           //         subtitle: tr("purchases.premium_yearly_subtitle")),
//           // SizedBox(height: MediaQuery.of(context).size.height * 0.02),
//
//           startupController.subscriptionModel.productId == _kPremiumMonthlyId
//               ? buildProductBuyText(
//               isbasic: false,
//               title:
//               " אתה מנוי במסלול זה\nתשלום חודשי של ${addSuffixIfEndsWithDotNine(monthlyPremiumPrice)} יגבה אוטומטית ")
//               : startupController.subscriptionModel.productId ==
//               _kPremiumYearlyId
//               ? buildProductBuyText(
//               isbasic: false,
//               // title: tr("purchases.premium_yearly_plan_buy"))
//               title:
//               " אתה מנוי במסלול זה\nתשלום שנתי של $yearlyPremiumPrice יגבה אוטומטית ")
//           // : PurchaseOutlineWidget(
//               : PurchaseElevatedBtnWidget(
//             isbasicplan: false,
//             onTaps: () async {
//               bool isConnected =
//               await WebService.checkConnectionNoMsg();
//               if (!isConnected) return;
//               Network.testServerApi().then((value) async {
//                 if (value != false) {
//                   List<ProductDetails> isFind = _products
//                       .where((element) =>
//                   element.id == _kPremiumMonthlyId)
//                       .toList();
//
//                   if (isFind.isNotEmpty) {
//                     WebService.setPrice(
//                         plan: 1,
//                         products: _products,
//                         pID: _kPremiumMonthlyId);
//                     PurchaseBtnClick(isFind[0], purchases);
//                   } else {
//                     displayMessageIcon(
//                         snackposition: SnackPosition.BOTTOM,
//                         message:
//                         'No matching item found for ID:$_kPremiumMonthlyId',
//                         color: errorColor,
//                         imageData: AppAssets.errorIcon);
//                   }
//                 }
//               });
//             },
//             // title: freePlanMonthlyAvaliable == "0.0" &&
//             //         widget.checkstatus == "0"
//             //     ? "${addSuffixIfEndsWithDotNine(monthlyPremiumPrice)}\n3 חודשים ראשונים חינם"
//             //     : addSuffixIfEndsWithDotNine(monthlyPremiumPrice),
//             // subtitle: tr("purchases.premium_monthly_subtitle")
//
//             title: "₪99 לחודש",
//             subtitle: "חודש ראשון מתנה!",
//           ),
//           SizedBox(height: MediaQuery.of(context).size.height * 0.01),
//         ],
//       ),
//     );
//   }
//
//   Future<void> PurchaseBtnClick(ProductDetails? isfind, purchases) async {
//     final PurchaseDetails? previousPurchase = purchases[isfind?.id];
//
//     if (previousPurchase != null && Platform.isIOS) {
//       confirmPriceChange(context);
//     } else {
//       late PurchaseParam purchaseParam;
//       if (Platform.isAndroid) {
//         final GooglePlayPurchaseDetails? oldSubscription =
//         await _getOldSubscription(isfind!, purchases);
//
//         purchaseParam = GooglePlayPurchaseParam(
//             productDetails: isfind,
//             changeSubscriptionParam: (oldSubscription != null)
//                 ? ChangeSubscriptionParam(
//               oldPurchaseDetails: oldSubscription,
//               prorationMode: ProrationMode.immediateAndChargeFullPrice,
//             )
//                 : null);
//       } else {
//         purchaseParam = PurchaseParam(
//           productDetails: isfind!,
//         );
//       }
//       _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
//     }
//   }
//
//   void checkSubscriptionData() async {
//     await startupController.checkSubscription().then((value) => setState(() {
//       if (startupController.subscriptionModel != null) {
//         selectedItem = startupController
//             .subscriptionModel.subscriptionStatus
//             .toString() ==
//             "0"
//             ? 0
//             : startupController.subscriptionModel.isPremium.toString() ==
//             "1"
//             ? 1
//             : 0;
//         productid = startupController.subscriptionModel.subscriptionStatus
//             .toString() ==
//             "0"
//             ? ""
//             : startupController.subscriptionModel.isPremium.toString() ==
//             "1"
//             ? _kProductIds[1]
//             : _kProductIds[0];
//         _purchasePending = false;
//         isLoading = false;
//       }
//     }));
//   }
//
//   String addSuffixIfEndsWithDotNine(String number) {
//     final regex = RegExp(r"\.\d$"); // Match numbers ending with ".1" to ".9"
//     if (regex.hasMatch(number)) {
//       final parts = number.split('.');
//       final suffix =
//       (int.parse(parts[1]) * 10).toString(); // Convert fractional part
//       return parts[0] + '.' + suffix;
//     } else {
//       return number; // Return unchanged if no match
//     }
//   }
// }
//
// class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
//   @override
//   bool shouldContinueTransaction(
//       SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
//     return true;
//   }
//
//   @override
//   bool shouldShowPriceConsent() {
//     return false;
//   }
// }
