// import 'dart:async';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:in_app_purchase_android/billing_client_wrappers.dart';
// import 'package:in_app_purchase_android/in_app_purchase_android.dart';
// import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
// import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
// import 'package:ink/src/controller/StartupController.dart';
// import 'package:ink/src/ui/screen/profile/subscription/consumable_store.dart';
// import 'package:ink/src/utils/assets.dart';
// import 'package:ink/src/utils/colors.dart';
// import 'package:ink/src/utils/common.dart';
// import 'package:ink/src/utils/webService.dart';
//
// import 'subscription_db_service.dart';
//
// final bool _kAutoConsume = Platform.isIOS || true;
// const String _kSilverSubscriptionId = 'subscription_basic_5day';
// const String _kGoldSubscriptionId = 'subscription_premium_5day';
//
// const List<String> _kProductIds = <String>[
//   _kSilverSubscriptionId,
//   _kGoldSubscriptionId,
// ];
//
// class PurchaseScreen extends StatefulWidget {
//   final String sub1Id;
//   final String sub2Id;
//   final bool fromRegistration;
//
//   const PurchaseScreen(
//       {Key? key,
//       required this.sub1Id,
//       required this.sub2Id,
//       required this.fromRegistration})
//       : super(key: key);
//
//   @override
//   _PurchaseScreenState createState() => _PurchaseScreenState();
// }
//
// var userid;
// //Subscription 01
// String sub1Id = '';
//
// //Subscription 02
// String sub2Id = '';
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
//
//   late PageController _pageController;
//
//   List<String> description1 = [
//     "בניית פרופיל עסקי לכל סטודיו ומקעקע",
//     "חשיפת הסטודיו לאלפי משתמשים בישראל המחפשים מקעקעים",
//     "קבלת טופס פניה מסודר עם פרטי הליד בתיבת הפניות שבאפליקציה",
//     "תמיכה טכנית ושירות לקוחות",
//     // "אפשרות העלאת 50 תמונות"
//   ];
//   List<String> description2 = [
//     "בניית פרופיל עסקי לכל סטודיו ומקעקע",
//     "חשיפת הסטודיו לאלפי משתמשים בישראל המחפשים מקעקעים",
//     "קבלת טופס פניה מסודר עם פרטי הליד בתיבת הפניות שבאפליקציה",
//     "תמיכה טכנית ושירות לקוחות",
//     // "אפשרות העלאת 200 תמונות",
//     "חשיפה מוגברת של הסטודיו ברשימת העסקים",
//     "פינת סקיצות ייחודית לסטודיו שלך"
//   ];
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
//       _listenToPurchaseUpdated(purchaseDetailsList);
//     }, onDone: () {
//       _subscription.cancel();
//     }, onError: (Object error) {
//       // handle error here.
//     });
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
//           _inAppPurchase
//               .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
//       await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
//     }
//
//     final ProductDetailsResponse productDetailResponse =
//         await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
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
//     await startupController.checkSubscription().then((value) => setState(() {
//           if (startupController.subscriptionModel != null) {
//             selectedItem = startupController
//                         .subscriptionModel.subscriptionStatus
//                         .toString() ==
//                     "0"
//                 ? 0
//                 : startupController.subscriptionModel.isPremium.toString() ==
//                         "1"
//                     ? 1
//                     : 0;
//             productid = startupController.subscriptionModel.subscriptionStatus
//                         .toString() ==
//                     "0"
//                 ? ""
//                 : startupController.subscriptionModel.isPremium.toString() ==
//                         "1"
//                     ? _kProductIds[1]
//                     : _kProductIds[0];
//             _purchasePending = false;
//             isLoading = false;
//           }
//         }));
//   }
//
//   @override
//   void dispose() {
//     if (Platform.isIOS) {
//       final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
//           _inAppPurchase
//               .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
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
//           children: const <Widget>[
//             Opacity(
//               opacity: 0.3,
//               child: ModalBarrier(dismissible: false, color: Colors.grey),
//             ),
//             Center(
//               child: CircularProgressIndicator(),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return Scaffold(
//       backgroundColor: isLoading ? Colors.black : Colors.white,
//       body: isLoading
//           ? Center(
//               child: Stack(
//               children: [
//                 Image.asset(AppAssets.loadingProfile,
//                     width: MediaQuery.of(context).size.width,
//                     height: MediaQuery.of(context).size.height * 0.7,
//                     fit: BoxFit.cover),
//                 Align(
//                   alignment: Alignment.bottomCenter,
//                   child: Container(
//                     height: MediaQuery.of(context).size.height * 0.35,
//                     decoration: const BoxDecoration(
//                         color: bgBlack,
//                         borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(20),
//                             topRight: Radius.circular(20))),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         SizedBox(
//                             height: MediaQuery.of(context).size.height * 0.02),
//                         Text(
//                           "איזה כיף שהצטרפתם!",
//                           textAlign: TextAlign.center,
//                           style: Theme.of(context)
//                               .textTheme
//                               .titleLarge!
//                               .copyWith(
//                                   fontSize: 24,
//                                   color: titleTextColor,
//                                   fontWeight: FontWeight.w700),
//                         ),
//                         SizedBox(
//                             height: MediaQuery.of(context).size.height * 0.01),
//                         Text(
//                           "בעוד מספר שניות הפרופיל\n העסקי יהיה מוכן...",
//                           textAlign: TextAlign.center,
//                           style: Theme.of(context)
//                               .textTheme
//                               .titleMedium!
//                               .copyWith(
//                                   color: titleTextWhiteColor,
//                                   fontWeight: FontWeight.w400),
//                         ),
//                         SizedBox(
//                             height: MediaQuery.of(context).size.height * 0.03),
//                         Padding(
//                           padding: EdgeInsets.all(
//                               MediaQuery.of(context).size.width * 0.1),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(10),
//                             child: ColoredBox(
//                               color: Colors.grey,
//                               child: Padding(
//                                   padding: const EdgeInsets.all(1.0),
//                                   child: LinearProgressIndicator(
//                                     backgroundColor: kWhite,
//                                     borderRadius: BorderRadius.circular(10),
//                                   )),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 )
//               ],
//             ))
//           : Stack(
//               children: stack,
//             ),
//     );
//   }
//
//   Card _buildConnectionCheckTile() {
//     if (_loading) {
//       return const Card(
//           elevation: 0, child: ListTile(title: Text('Trying to connect...')));
//     }
//
//     final Widget storeHeader = _loading
//         ? Container()
//         : Padding(
//             padding: const EdgeInsets.all(4.0),
//             child: widget.fromRegistration
//                 ? Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: <Widget>[
//                       Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: InkWell(
//                               onTap: () => Get.back(),
//                               child: const Icon(Icons.arrow_back_ios,
//                                   color: Colors.black))),
//                       Column(
//                         children: [
//                           const Text("תוכנית נוכחית"),
//                           Text(
//                             productid == _kSilverSubscriptionId
//                                 ? "בסיסי"
//                                 : productid == _kGoldSubscriptionId
//                                     ? "מתקדם"
//                                     : "ללא תוכנית קנייה",
//                             style: Get.textTheme.titleMedium!
//                                 .copyWith(fontWeight: FontWeight.w600),
//                           ),
//                         ],
//                       ),
//                       Visibility(
//                         visible: false,
//                         child: TextButton(
//                           style: TextButton.styleFrom(
//                             backgroundColor: Theme.of(context).primaryColor,
//                             foregroundColor: Colors.white,
//                           ),
//
//                           onPressed: () => _inAppPurchase.restorePurchases(),
//                           // child: const Text('Restore purchases'),
//                           child: const Text("שחזר רכישה"),
//                         ),
//                       ),
//                     ],
//                   )
//                 : Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: <Widget>[
//                       Visibility(
//                         visible: false,
//                         child: TextButton(
//                           style: TextButton.styleFrom(
//                             backgroundColor: Theme.of(context).primaryColor,
//                             foregroundColor: Colors.white,
//                           ),
//
//                           onPressed: () => _inAppPurchase.restorePurchases(),
//                           // child: const Text('Restore purchases'),
//                           child: const Text("שחזר רכישה"),
//                         ),
//                       ),
//                       Column(
//                         children: [
//                           const Text("תוכנית נוכחית"),
//                           Text(
//                             productid == _kSilverSubscriptionId
//                                 ? "בסיסי"
//                                 : productid == _kGoldSubscriptionId
//                                     ? "מתקדם"
//                                     : "ללא תוכנית קנייה",
//                             style: Get.textTheme.titleMedium!
//                                 .copyWith(fontWeight: FontWeight.w600),
//                           ),
//                         ],
//                       ),
//                       CloseButton(
//                           color: Colors.black, onPressed: () => Get.back()),
//                     ],
//                   ),
//           );
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
//     Column productHeader = Column(
//       children: [
//         SizedBox(
//             height: Get.size.height * 0.55,
//             child: PageView.builder(
//                 itemCount: _products.length,
//                 pageSnapping: true,
//                 controller: _pageController,
//                 onPageChanged: (page) {
//                   setState(() {
//                     selectedItem = page;
//                   });
//                 },
//                 itemBuilder: (context, pagePosition) {
//                   return Card(
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(
//                           vertical: Get.size.height * 0.01),
//                       child: Column(
//                         children: [
//                           Text(selectedItem == 0 ? "בסיסי" : "מתקדם",
//                               style: Get.textTheme.titleLarge!
//                                   .copyWith(color: const Color(0xff000000))),
//                           SizedBox(
//                             width: Get.size.width,
//                             child: ListView.builder(
//                                 shrinkWrap: true,
//                                 padding: const EdgeInsets.all(12),
//                                 itemCount: pagePosition == 0
//                                     ? description1.length
//                                     : description2.length,
//                                 itemBuilder: (context, index) {
//                                   return Padding(
//                                     padding: EdgeInsets.symmetric(
//                                         vertical: Get.size.height * 0.01),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       children: [
//                                         Image.asset(
//                                             "assets/icons/check_circle.png"),
//                                         SizedBox(width: Get.size.width * 0.02),
//                                         SizedBox(
//                                           width: Get.size.width * 0.67,
//                                           child: Text(
//                                               pagePosition == 0
//                                                   ? description1[index]
//                                                   : description2[index],
//                                               style: Get.textTheme.titleSmall!
//                                                   .copyWith(
//                                                       color: defaultGrey)),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                   return Text(description2[index]);
//                                 }),
//                           )
//                         ],
//                       ),
//                     ),
//                   );
//                 })),
//         Container(
//           margin: EdgeInsets.symmetric(vertical: Get.size.height * 0.01),
//           height: Get.size.height * 0.02,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: List<Widget>.generate(
//                 _products.length,
//                 (index) => Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 10),
//                       child: InkWell(
//                         onTap: () {
//                           _pageController.animateToPage(index,
//                               duration: const Duration(milliseconds: 300),
//                               curve: Curves.easeIn);
//                         },
//                         child: CircleAvatar(
//                             radius: 8,
//                             backgroundColor: selectedItem == index
//                                 ? Colors.purple
//                                 : Colors.grey),
//                       ),
//                     )),
//           ),
//         ),
//       ],
//     );
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
//         child: Column(children: [
//           productHeader,
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: SizedBox(
//               height: Get.height * 0.13,
//               child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: _products.length,
//                   itemBuilder: (context, index) {
//                     final PurchaseDetails? previousPurchase =
//                         purchases[_products[index].id];
//                     return InkWell(
//                       onTap: () {
//                         setState(() {
//                           selectedItem = index;
//                           _pageController.animateToPage(index,
//                               duration: const Duration(milliseconds: 300),
//                               curve: Curves.linear);
//                         });
//                       },
//                       child: Padding(
//                         padding: const EdgeInsets.only(right: 8),
//                         child: SizedBox(
//                           width: Get.width * 0.44,
//                           child: Card(
//                               color: selectedItem == index
//                                   ? Colors.purple
//                                   : Colors.white,
//                               elevation: 10,
//                               child: previousPurchase != null && Platform.isIOS
//                                   ? IconButton(
//                                       onPressed: () =>
//                                           confirmPriceChange(context),
//                                       icon: const Icon(Icons.upgrade))
//                                   : Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceEvenly,
//                                       children: [
//                                         Text(
//                                             _products[index].id ==
//                                                     _kSilverSubscriptionId
//                                                 ? "בסיסי"
//                                                 : "מתקדם",
//                                             style: Get.textTheme.titleMedium!
//                                                 .copyWith(
//                                                     color: selectedItem == index
//                                                         ? Colors.white
//                                                         : Colors.black)),
//                                         Text(_products[index].price.toString(),
//                                             style: Get.textTheme.titleMedium!
//                                                 .copyWith(
//                                                     fontWeight: FontWeight.bold,
//                                                     color: selectedItem == index
//                                                         ? Colors.white
//                                                         : Colors.black)),
//                                         Text("לא כולל מע'מ",
//                                             style: Get.textTheme.bodySmall!
//                                                 .copyWith(
//                                                     color: selectedItem == index
//                                                         ? Colors.white
//                                                         : Colors.black))
//                                       ],
//                                     )),
//                         ),
//                       ),
//                     );
//                   }),
//             ),
//           ),
//           SizedBox(height: Get.size.height * 0.01),
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8.0),
//             child: SizedBox(
//               width: Get.width * 0.9,
//               height: Get.size.height * 0.06,
//               child: productid == _kSilverSubscriptionId && selectedItem == 0 ||
//                       productid == _kGoldSubscriptionId && selectedItem == 1
//                   ? Align(
//                       alignment: Alignment.center,
//                       child: Text("אתה מנוי במסלול זה",
//                           style: Get.textTheme.titleMedium!
//                               .copyWith(color: appPrimaryColor)),
//                     )
//                   : ElevatedButton(
//                       onPressed: () {
//                         final PurchaseDetails? previousPurchase =
//                             purchases[_products[selectedItem].id];
//                         if (previousPurchase != null && Platform.isIOS) {
//                           confirmPriceChange(context);
//                         } else {
//                           late PurchaseParam purchaseParam;
//
//                           if (Platform.isAndroid) {
//                             // NOTE: If you are making a subscription purchase/upgrade/downgrade, we recommend you to
//                             // verify the latest status of you your subscription by using server side receipt validation
//                             // and update the UI accordingly. The subscription purchase status shown
//                             // inside the app may not be accurate.
//                             final GooglePlayPurchaseDetails? oldSubscription =
//                                 _getOldSubscription(
//                                     _products[selectedItem], purchases);
//
//                             purchaseParam = GooglePlayPurchaseParam(
//                                 productDetails: _products[selectedItem],
//                                 changeSubscriptionParam:
//                                     (oldSubscription != null)
//                                         ? ChangeSubscriptionParam(
//                                             oldPurchaseDetails: oldSubscription,
//                                             prorationMode: ProrationMode
//                                                 .immediateWithTimeProration,
//                                           )
//                                         : null);
//                           } else {
//                             purchaseParam = PurchaseParam(
//                               productDetails: _products[selectedItem],
//                             );
//                           }
//                           _inAppPurchase.buyNonConsumable(
//                               purchaseParam: purchaseParam);
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: appPrimaryColor,
//                           // : defaultGrey,
//                           shape: const RoundedRectangleBorder(
//                               borderRadius:
//                                   BorderRadius.all(Radius.circular(16)))),
//                       child: Text(
//                           productid == _kSilverSubscriptionId &&
//                                       selectedItem == 0 ||
//                                   productid == _kGoldSubscriptionId &&
//                                       selectedItem == 1
//                               ? "אתה מנוי במסלול זה"
//                               : productid == _kSilverSubscriptionId &&
//                                       selectedItem == 1
//                                   ? "שדרג למסלול זה"
//                                   : productid == _kGoldSubscriptionId &&
//                                           selectedItem == 0
//                                       ? "שנמוך למסלול זה"
//                                       : "המשך",
//                           style: Get.textTheme.titleMedium!
//                               .copyWith(color: Colors.white))),
//             ),
//           ),
//         ]));
//   }
//
//   Card _buildConsumableBox() {
//     if (_loading) {
//       return const Card(
//           child: ListTile(
//               leading: CircularProgressIndicator(),
//               title: Text('Fetching consumables...')));
//     }
//     if (!_isAvailable) {
//       return const Card();
//     }
//     const ListTile consumableHeader =
//         ListTile(title: Text('Purchased consumables'));
//     final List<Widget> tokens = _consumables.map((String id) {
//       return GridTile(
//         child: IconButton(
//           icon: const Icon(
//             Icons.stars,
//             size: 42.0,
//             color: Colors.orange,
//           ),
//           splashColor: Colors.yellowAccent,
//           onPressed: () => consume(id),
//         ),
//       );
//     }).toList();
//     return Card(
//         child: Column(children: <Widget>[
//       consumableHeader,
//       const Divider(),
//       GridView.count(
//         crossAxisCount: 5,
//         shrinkWrap: true,
//         padding: const EdgeInsets.all(16.0),
//         children: tokens,
//       )
//     ]));
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
//   Future<void> deliverProduct(PurchaseDetails purchaseDetails) async {
//     try {
//       if (Platform.isAndroid) {
//         await SubscriptionDbService()
//             .saveSubcriptionsDetails(purchaseDetails)
//             .then((value) => startupController.checkSubscription());
//       } else {
//         await SubscriptionDbService()
//             .saveSubcriptionsDetailsIOS(purchaseDetails);
//       }
//     } catch (e) {
//       print(e);
//     }
//     // try {
//     //   if (Platform.isAndroid) {
//     //       await SubscriptionDbService()
//     //           .saveSubcriptionsDetails(purchaseDetails);
//     //   } else {
//     //     await SubscriptionDbService()
//     //         .saveSubcriptionsDetailsIOS(purchaseDetails);
//     //   }
//     //   await startupController.checkSubscription();
//     // } catch (e) {
//     //   print(e);
//     // }
//
//     setState(() {
//       if (Platform.isAndroid) {
//         selectedItem = startupController.subscriptionModel.subscriptionStatus
//                     .toString() ==
//                 "0"
//             ? 0
//             : startupController.subscriptionModel.isPremium.toString() == "1"
//                 ? 1
//                 : 0;
//         productid = startupController.subscriptionModel.subscriptionStatus
//                     .toString() ==
//                 "0"
//             ? ""
//             : startupController.subscriptionModel.isPremium.toString() == "1"
//                 ? _kProductIds[1]
//                 : _kProductIds[0];
//       } else {
//         productid = purchaseDetails.productID.toString();
//       }
//
//       _purchases.add(purchaseDetails);
//       _purchasePending = false;
//       isLoading = false;
//     });
//   }
//
//   void handleError(IAPError error) {
//     setState(() {
//       _purchasePending = false;
//     });
//   }
//
//   Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
//     // IMPORTANT!! Always verify a purchase before delivering the product.
//     // For the purpose of an example, we directly return true.
//
//     // bool isSubscribed = false;
//     // if (Platform.isAndroid) {
//     //   setState(() => isLoading = true);
//     //
//     //   await startupController.checkSubscription().then((value) {
//     //     isSubscribed =
//     //         startupController.subscriptionModel.subscriptionStatus.toString() ==
//     //                 "0"
//     //             ? false
//     //             : true;
//     //   });
//     //
//     //   setState(() => isLoading = false);
//     // }
//     return Future<bool>.value(true);
//     // return isSubscribed;
//   }
//
//   void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
//     displayMessage(
//         "Something went wrong \n Purchase status : ${purchaseDetails.status}",
//         Colors.red);
//     // handle invalid purchase here if  _verifyPurchase` failed.
//   }
//
//   Future<void> _listenToPurchaseUpdated(
//       List<PurchaseDetails> purchaseDetailsList) async {
//     for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
//       WebService.printMsg("Purchase status : ${purchaseDetails.status}");
//       if (purchaseDetails.status == PurchaseStatus.pending) {
//         showPendingUI();
//       } else {
//         if (purchaseDetails.status == PurchaseStatus.error) {
//           handleError(purchaseDetails.error!);
//         } else if (purchaseDetails.status == PurchaseStatus.purchased) {
//           // || purchaseDetails.status == PurchaseStatus.restored) {
//           final bool valid = await _verifyPurchase(purchaseDetails);
//           if (valid) {
//             unawaited(deliverProduct(purchaseDetails));
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
//     if (productDetails.id == _kSilverSubscriptionId &&
//         purchases[_kGoldSubscriptionId] != null) {
//       oldSubscription =
//           purchases[_kGoldSubscriptionId]! as GooglePlayPurchaseDetails;
//     } else if (productDetails.id == _kGoldSubscriptionId &&
//         purchases[_kSilverSubscriptionId] != null) {
//       oldSubscription =
//           purchases[_kSilverSubscriptionId]! as GooglePlayPurchaseDetails;
//     }
//     return oldSubscription;
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
