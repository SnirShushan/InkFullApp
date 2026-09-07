// import 'dart:async';
// import 'dart:io';
//
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:in_app_purchase_android/billing_client_wrappers.dart';
// import 'package:in_app_purchase_android/in_app_purchase_android.dart';
// import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
// import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
// import 'package:ink/src/data/source/network/user_api.dart';
// import 'package:ink/src/ui/screen/profile/subscription/consumable_store.dart';
// import 'package:ink/src/ui/screen/profile/subscription/widget/purchase_footer_widget.dart';
// import 'package:ink/src/ui/screen/profile/subscription/widget/purchase_loading_widget.dart';
// import 'package:ink/src/ui/screen/profile/subscription/widget/purchase_plan_header_widget.dart';
// import 'package:ink/src/utils/assets.dart';
// import 'package:ink/src/utils/colors.dart';
// import 'package:ink/src/utils/common.dart';
// import 'package:ink/src/utils/webService.dart';
//
// import '../subscription_db_service.dart';
// import '../widget/purchase_elevated_button.dart';
// import '../widget/purchase_header_widget.dart';
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
// class IOSPurchaseScreen extends StatefulWidget {
//   final String purchasename;
//   final String checkstatus;
//   final bool fromRegistration;
//
//   const IOSPurchaseScreen(
//       {Key? key,
//       required this.purchasename,
//       required this.fromRegistration,
//       required this.checkstatus})
//       : super(key: key);
//
//   @override
//   _IOSPurchaseScreenState createState() => _IOSPurchaseScreenState();
// }
//
// var userid;
//
// class _IOSPurchaseScreenState extends State<IOSPurchaseScreen> {
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
//   late PageController _pageController;
//   bool isProductcustom = false;
//   bool islimitUrlCount = false;
//   bool isApiLoading = false;
//   bool isrestoremessageLoading = false;
//   final ScrollController _scrollController = ScrollController();
//
//   @override
//   void initState() {
//     SubscriptionDbService.fromRegistration = widget.fromRegistration;
//     productid = widget.purchasename;
//     final Stream<List<PurchaseDetails>> purchaseUpdated =
//         _inAppPurchase.purchaseStream;
//     _subscription =
//         purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
//       _listenToPurchaseUpdated(purchaseDetailsList);
//     }, onDone: () {
//       _subscription.cancel();
//     }, onError: (Object error) {
//       // handle error here.
//     });
//     initStoreInfo();
//     _pageController = PageController(viewportFraction: 0.95);
//     super.initState();
//   }
//
//   Future<void> initStoreInfo() async {
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
//           _inAppPurchase
//               .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
//       await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
//     }
//
//     final ProductDetailsResponse productDetailResponse =
//         await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
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
//     userid = await WebService.getUserIds();
//   }
//
//   @override
//   void dispose() {
//     final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
//         _inAppPurchase
//             .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
//     iosPlatformAddition.setDelegate(null);
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
//           clipBehavior: Clip.none,
//           children: const <Widget>[SizedBox()],
//         ),
//       );
//       // stack.add(
//       //     // TODO(goderbauer): Make this const when that's available on stable.
//       //     // ignore: prefer_const_constructors
//       //     PurchaseLoadingWidget());
//     }
//     var size = MediaQuery.of(context).size;
//     return Scaffold(
//       backgroundColor: bgBlack,
//       body: _loading
//           ? const Center(
//               child: CircularProgressIndicator(),
//             )
//           : widget.fromRegistration && _purchasePending
//               ? const PurchaseLoadingWidget()
//               : _purchasePending
//                   ? const Stack(
//                       clipBehavior: Clip.none,
//                       children: <Widget>[
//                         Opacity(
//                           opacity: 0.9,
//                           child:
//                               ModalBarrier(dismissible: false, color: bgBlack),
//                         ),
//                         Center(
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                           ),
//                         )
//                       ],
//                     )
//                   : Stack(
//                       children: [
//                         Stack(
//                           clipBehavior: Clip.none,
//                           children: [
//                             Image.asset(AppAssets.purchasebg,
//                                 width: size.width,
//                                 height: size.height * 0.5,
//                                 fit: BoxFit.fitWidth),
//                             Positioned(
//                               top: size.height * 0.07,
//                               right: 20,
//                               child: InkWell(
//                                 onTap: () => Get.back(),
//                                 child: Row(
//                                   children: [
//                                     SvgPicture.asset(AppAssets.backarrowIcon,
//                                         width: 24,
//                                         height: 24,
//                                         color: titleTextColor),
//                                     SizedBox(width: size.width * 0.02),
//                                     const Text(
//                                       "חזרה",
//                                       style: TextStyle(
//                                         color: Color(0xFFC0BCC4),
//                                         fontSize: 14,
//                                         fontFamily: 'Arimo',
//                                         fontWeight: FontWeight.w400,
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             // Positioned(
//                             //   top: size.height * 0.08,
//                             //   left: 20,
//                             //   child: InkWell(
//                             //       splashColor: Colors.grey,
//                             //       onTap: () {
//                             //         islimitUrlCount = true;
//                             //         _inAppPurchase.restorePurchases();
//                             //         setState(() {});
//                             //       },
//                             //       child: const Text(
//                             //         "שחזר רכישה",
//                             //         style: TextStyle(
//                             //           color: Color(0xFFC0BCC4),
//                             //           fontSize: 16,
//                             //           fontFamily: 'Arimo',
//                             //           fontWeight: FontWeight.w400,
//                             //         ),
//                             //       )),
//                             // ),
//                           ],
//                         ),
//                         SizedBox.expand(
//                           child: DraggableScrollableSheet(
//                               initialChildSize: 0.7,
//                               maxChildSize: 1.0,
//                               minChildSize: 0.8,
//                               builder: (BuildContext context,
//                                   ScrollController scrollController) {
//                                 return Container(
//                                   padding: const EdgeInsets.only(
//                                       left: 12.0,
//                                       right: 12,
//                                       bottom: 12,
//                                       top: 4),
//                                   decoration: const BoxDecoration(
//                                       color: bgBlack,
//                                       borderRadius: BorderRadius.only(
//                                           topLeft: Radius.circular(25),
//                                           topRight: Radius.circular(25))),
//                                   height: size.height,
//                                   child: Stack(
//                                     children: stack,
//                                   ),
//                                 );
//                               }),
//                         ),
//                       ],
//                     ),
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
//         Map<String, PurchaseDetails>.fromEntries(
//             _purchases.map((PurchaseDetails purchase) {
//       if (purchase.pendingCompletePurchase) {
//         _inAppPurchase.completePurchase(purchase);
//       }
//       return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
//     }));
//
//     return Card(
//         elevation: 0,
//         color: bgBlack,
//         margin: EdgeInsets.zero,
//         child: Column(children: [
//           const PurchaseHeaderWidget(),
//           buildBasicPlanContainer(purchases),
//           SizedBox(height: MediaQuery.of(context).size.height * 0.02),
//           buildPremiumPlanContainer(purchases),
//           SizedBox(height: MediaQuery.of(context).size.height * 0.04),
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
//                   });
//                 }
//               } catch (e) {
//                 setState(() {
//                   WebService.isrestoremessageLoading = false;
//                 });
//               }
//             },
//             isLoading: isrestoremessageLoading,
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
//   Future<void> deliverProduct(
//       PurchaseDetails purchaseDetails, String purchaseStatus) async {
//     if (isApiLoading) return;
//     isApiLoading = true;
//     try {
//       await SubscriptionDbService()
//           .saveSubcriptionsDetailsIOS(purchaseDetails, purchaseStatus)
//           .then((value) {
//         setState(() {
//           if (isProductcustom == true) {
//             productid = purchaseDetails.productID;
//             purchaseSuccessDialog(
//                 MediaQuery.of(context).size, context, "זה ייקח כמה שניות");
//           }
//           isProductcustom = false;
//           islimitUrlCount = false;
//           _purchases.add(purchaseDetails);
//           _purchasePending = false;
//         });
//       });
//     } catch (e) {
//       isApiLoading = false;
//     } finally {
//       isApiLoading = false;
//     }
//
//     // }
//   }
//
//   void handleError(IAPError error) {
//     setState(() {
//       _purchasePending = false;
//       isProductcustom = false;
//       islimitUrlCount = false;
//       _loading = false;
//     });
//   }
//
//   Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
//     // IMPORTANT!! Always verify a purchase before delivering the product.
//     // For the purpose of an example, we directly return true.
//     return Future<bool>.value(true);
//   }
//
//   void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
//     // handle invalid purchase here if  _verifyPurchase` failed.
//
//     setState(() {
//       _purchasePending = false;
//       isProductcustom = false;
//       islimitUrlCount = false;
//       _loading = false;
//     });
//   }
//
//   Future<void> _listenToPurchaseUpdated(
//       List<PurchaseDetails> purchaseDetailsList) async {
//     for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
//       if (purchaseDetails.status == PurchaseStatus.pending) {
//         showPendingUI();
//       } else {
//         if (purchaseDetails.status == PurchaseStatus.error ||
//             purchaseDetails.status == PurchaseStatus.canceled) {
//           handleError(purchaseDetails.error!);
//         } else if (purchaseDetails.status == PurchaseStatus.purchased) {
//           final bool valid = await _verifyPurchase(purchaseDetails);
//           if (valid) {
//             print("Delivery DATA Purchased");
//             unawaited(deliverProduct(purchaseDetails, "Purchased"));
//           } else {
//             _handleInvalidPurchase(purchaseDetails);
//             return;
//           }
//         } else if (purchaseDetails.status == PurchaseStatus.restored) {
//           final bool valid = await _verifyPurchase(purchaseDetails);
//           if (valid) {
//             print("Delivery DATA Restored");
//             unawaited(deliverProduct(purchaseDetails, "Restored"));
//           } else {
//             _handleInvalidPurchase(purchaseDetails);
//             return;
//           }
//         }
//         if (Platform.isAndroid) {
//           if (!_kAutoConsume) {
//             final InAppPurchaseAndroidPlatformAddition androidAddition =
//                 _inAppPurchase.getPlatformAddition<
//                     InAppPurchaseAndroidPlatformAddition>();
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
//           _inAppPurchase
//               .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
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
//           purchases[_kPremiumMonthlyId] as GooglePlayPurchaseDetails?;
//     } else if (purchases[_kPremiumYearlyId] != null &&
//         productDetails.id != _kPremiumYearlyId) {
//       oldSubscription =
//           purchases[_kPremiumYearlyId] as GooglePlayPurchaseDetails?;
//     } else if (purchases[_kBasicMonthlyId] != null &&
//         productDetails.id != _kBasicMonthlyId) {
//       oldSubscription =
//           purchases[_kBasicMonthlyId] as GooglePlayPurchaseDetails?;
//     } else if (purchases[_kBasicYearlyId] != null &&
//         productDetails.id != _kBasicYearlyId) {
//       oldSubscription =
//           purchases[_kBasicYearlyId] as GooglePlayPurchaseDetails?;
//     }
//     return oldSubscription;
//   }
//
//   buildBasicPlanContainer(Map<String, PurchaseDetails> purchases) {
//     List<ProductDetails> isBasicYearly =
//         _products.where((element) => element.id == _kBasicYearlyId).toList();
//
//     List<ProductDetails> isBasicMonthly =
//         _products.where((element) => element.id == _kBasicMonthlyId).toList();
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//           color: purchasebgcolor, borderRadius: BorderRadius.circular(16)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           PurchasePlanHeaderWidget(isBasicPlan: true),
//           // productid == _kBasicYearlyId
//           //     ? buildProductBuyText(
//           //     isbasic: true,
//           //     title:
//           //     " אתה מנוי במסלול זה\nתשלום שנתי של ${isBasicYearly[0].price} יגבה אוטומטית ")
//           //     : PurchaseElevatedBtnWidget(
//           //     isbasicplan: true,
//           //     onTaps: () {
//           //       if (isBasicYearly.isNotEmpty) {
//           //         PurchaseBtnClick(isBasicYearly[0], purchases);
//           //       } else {
//           //         displayMessage(
//           //             'No matching item found for ID:${_kBasicYearlyId}',
//           //             Colors.red);
//           //       }
//           //     },
//           //     title: "${isBasicYearly[0].price} לשנה ",
//           //     // title: "₪420 לשנה",
//           //     subtitle: tr("purchases.basic_yearly_subtitle")),
//           // SizedBox(height: MediaQuery.of(context).size.height * 0.02),
//
//           productid == _kBasicYearlyId
//               ? buildProductBuyText(
//                   isbasic: true,
//                   title:
//                       " אתה מנוי במסלול זה\nתשלום שנתי של ${addSuffixIfEndsWithDotNine(isBasicYearly[0].price)} יגבה אוטומטית ")
//               : productid == _kBasicMonthlyId
//                   ? buildProductBuyText(
//                       isbasic: true,
//                       title: "התחילו ללא עלות",
//                       // title:
//                       //     " אתה מנוי במסלול זה\nתשלום חודשי של ${addSuffixIfEndsWithDotNine(isBasicMonthly[0].price)} יגבה אוטומטית ",
//                     )
//                   : productid == _kBasicYearlyId
//                       ? const SizedBox.shrink()
//                       // : PurchaseOutlineWidget(
//                       : PurchaseElevatedBtnWidget(
//                           isbasicplan: true,
//                           ismainscreen: true,
//                           onTaps: () async {
//                             bool isConnected =
//                                 await WebService.checkConnectionNoMsg();
//                             if (!isConnected) return;
//                             Network.testServerApi().then((value) async {
//                               if (value != false) {
//                                 if (isBasicMonthly.isNotEmpty) {
//                                   WebService.setPrice(
//                                       plan: 0,
//                                       products: _products,
//                                       pID: _kBasicMonthlyId);
//                                   PurchaseBtnClick(
//                                       isBasicMonthly[0], purchases);
//                                 } else {
//                                   displayMessageIcon(
//                                       snackposition: SnackPosition.BOTTOM,
//                                       message:
//                                           'No matching item found for ID:${_kBasicMonthlyId}',
//                                       color: errorColor,
//                                       imageData: AppAssets.errorIcon);
//                                 }
//                               }
//                             });
//                           },
//                           title: "התחילו ללא עלות",
//                           // title: widget.checkstatus == "0"
//                           //     ? "${addSuffixIfEndsWithDotNine(isBasicMonthly[0].price)} לחודש \n3 חודשים ראשונים חינם "
//                           //     : addSuffixIfEndsWithDotNine(
//                           //         isBasicMonthly[0].price),
//                           // subtitle: tr("purchases.basic_monthly_subtitle")
//                           subtitle: ""),
//
//           SizedBox(height: MediaQuery.of(context).size.height * 0.01),
//         ],
//       ),
//     );
//   }
//
//   Container buildPremiumPlanContainer(Map<String, PurchaseDetails> purchases) {
//     List<ProductDetails> isPremiumYearly =
//         _products.where((element) => element.id == _kPremiumYearlyId).toList();
//
//     List<ProductDetails> isPremiumMonthly =
//         _products.where((element) => element.id == _kPremiumMonthlyId).toList();
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//           color: purchasebgcolor, borderRadius: BorderRadius.circular(16)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           PurchasePlanHeaderWidget(isBasicPlan: false),
//           // productid == _kPremiumYearlyId
//           //     ? buildProductBuyText(
//           //     isbasic: false,
//           //     title:
//           //     " אתה מנוי במסלול זה\nתשלום שנתי של ${isPremiumYearly[0].price} יגבה אוטומטית ")
//           //     : PurchaseElevatedBtnWidget(
//           //     isbasicplan: false,
//           //     onTaps: () {
//           //       if (isPremiumYearly.isNotEmpty) {
//           //         PurchaseBtnClick(isPremiumYearly[0], purchases);
//           //       } else {
//           //         displayMessage(
//           //             'No matching item found for ID:${_kPremiumYearlyId}',
//           //             Colors.red);
//           //       }
//           //     },
//           //     title: "${isPremiumYearly[0].price} לשנה ",
//           //     subtitle: tr("purchases.premium_yearly_subtitle")),
//           // SizedBox(height: MediaQuery.of(context).size.height * 0.02),
//           productid == isPremiumYearly
//               ? buildProductBuyText(
//                   isbasic: false,
//                   title:
//                       " אתה מנוי במסלול זה\nתשלום שנתי של ${addSuffixIfEndsWithDotNine(isPremiumYearly[0].price)} יגבה אוטומטית ")
//               : productid == _kPremiumMonthlyId
//                   ? buildProductBuyText(
//                       isbasic: false,
//                       title:
//                           " אתה מנוי במסלול זה\nתשלום חודשי של ${addSuffixIfEndsWithDotNine(isPremiumMonthly[0].price)} יגבה אוטומטית ")
//                   : productid == _kPremiumYearlyId
//                       ? const SizedBox.shrink()
//                       // : PurchaseOutlineWidget(
//                       : PurchaseElevatedBtnWidget(
//                           isbasicplan: false,
//                           onTaps: () async {
//                             bool isConnected =
//                                 await WebService.checkConnectionNoMsg();
//                             if (!isConnected) return;
//                             Network.testServerApi().then((value) async {
//                               if (value != false) {
//                                 if (isPremiumMonthly.isNotEmpty) {
//                                   WebService.setPrice(
//                                       plan: 1,
//                                       products: _products,
//                                       pID: _kPremiumMonthlyId);
//                                   PurchaseBtnClick(
//                                       isPremiumMonthly[0], purchases);
//                                 } else {
//                                   displayMessageIcon(
//                                       snackposition: SnackPosition.BOTTOM,
//                                       message:
//                                           'No matching item found for ID:${_kPremiumMonthlyId}',
//                                       color: errorColor,
//                                       imageData: AppAssets.errorIcon);
//                                 }
//                               }
//                             });
//                           },
//                           // title: "${isPremiumMonthly[0].price} לחודש ",
//                           title: widget.checkstatus == "0"
//                               ? "${addSuffixIfEndsWithDotNine(isPremiumMonthly[0].price)} לחודש \n3 חודשים ראשונים חינם "
//                               : addSuffixIfEndsWithDotNine(
//                                   isPremiumMonthly[0].price),
//                           subtitle: tr("purchases.premium_monthly_subtitle")),
//           SizedBox(height: MediaQuery.of(context).size.height * 0.01),
//         ],
//       ),
//     );
//   }
//
//   Future<void> PurchaseBtnClick(
//       ProductDetails? isfind, Map<String, PurchaseDetails> purchases) async {
//     final PurchaseDetails? previousPurchase = purchases[isfind?.id];
//     if (previousPurchase != null && Platform.isIOS) {
//       confirmPriceChange(context);
//     } else {
//       late PurchaseParam purchaseParam;
//       if (Platform.isAndroid) {
//         final GooglePlayPurchaseDetails? oldSubscription =
//             await _getOldSubscription(isfind!, purchases);
//
//         purchaseParam = GooglePlayPurchaseParam(
//             productDetails: isfind,
//             changeSubscriptionParam: (oldSubscription != null)
//                 ? ChangeSubscriptionParam(
//                     oldPurchaseDetails: oldSubscription,
//                     prorationMode: ProrationMode.immediateAndChargeFullPrice,
//                   )
//                 : null);
//       } else {
//         purchaseParam = PurchaseParam(
//           productDetails: isfind!,
//         );
//       }
//       _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
//
//       setState(() {
//         isProductcustom = true;
//         islimitUrlCount = true;
//       });
//     }
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
//   Future<bool> hasPurchasedIntroductoryOffer(String productId) async {
//     final Stream<List<PurchaseDetails>> purchaseStream =
//         await InAppPurchase.instance.purchaseStream;
//     bool hasIntroductoryOffer = false;
//
//     await for (var purchases in purchaseStream) {
//       for (var purchase in purchases) {
//         if (purchase.productID == productId) {
//           // Since there's no direct introductory offer type in `in_app_purchase`,
//           // you might need to implement server-side receipt validation to check for
//           // introductory offers.
//           hasIntroductoryOffer = true;
//           break;
//         }
//       }
//       if (hasIntroductoryOffer) break;
//     }
//
//     return hasIntroductoryOffer;
//   }
//
//   String addSuffixIfEndsWithDotNine(String number) {
//     final regex = RegExp(r"\.\d$"); // Match numbers ending with ".1" to ".9"
//     if (regex.hasMatch(number)) {
//       final parts = number.split('.');
//       final suffix =
//           (int.parse(parts[1]) * 10).toString(); // Convert fractional part
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
