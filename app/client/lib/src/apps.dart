import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ink/src/ui/screen/splash/splashscreen.dart';

import 'utils/colors.dart';
import 'utils/utils.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ink',
      key: Utils.navigationKey,
      debugShowCheckedModeBanner: false,
      color: Colors.black,
      defaultTransition: Transition.noTransition,
      theme: ThemeData(
          useMaterial3: false,
          primarySwatch: appPrimaryColor,
          scaffoldBackgroundColor: scaffoldBg,
          fontFamily: 'Arimo',
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
