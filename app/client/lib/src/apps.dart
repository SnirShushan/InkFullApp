import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ink/src/data/source/analytics/app_analytics.dart';
import 'package:ink/src/data/source/analytics/app_error_log.dart';
import 'package:ink/src/ui/screen/splash/splashscreen.dart';
import 'package:ink/src/ui/widgets/ink_page_transition.dart';

import 'utils/colors.dart';
import 'utils/utils.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppAnalytics.instance.startSession();
    AppAnalytics.instance.screen('SplashScreen');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AppAnalytics.instance.endSession();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AppAnalytics.instance.resume();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      AppAnalytics.instance.pause();
      AppErrorLog.instance.flush();
    } else if (state == AppLifecycleState.detached) {
      AppAnalytics.instance.endSession();
      AppErrorLog.instance.flush();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ink',
      key: Utils.navigationKey,
      navigatorObservers: [AppAnalyticsObserver()],
      debugShowCheckedModeBanner: false,
      color: Colors.black,
      defaultTransition: Transition.cupertino,
      customTransition: InkPageTransition(),
      transitionDuration: const Duration(milliseconds: 280),
      theme: ThemeData(
          useMaterial3: false,
          primarySwatch: appPrimaryColor,
          scaffoldBackgroundColor: scaffoldBg,
          fontFamily: 'Arimo',
          pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            backgroundColor: Colors.transparent,
          ),

          bottomSheetTheme:
              const BottomSheetThemeData(backgroundColor: Colors.transparent),
          canvasColor: scaffoldBg, // Prevents unexpected backgrounds

          switchTheme:
              SwitchThemeData(thumbColor: MaterialStateProperty.all(null))),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const SplashScreen(),
    );
  }
}
