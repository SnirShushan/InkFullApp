import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ink/src/ui/screen/splash/splashscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/common.dart';

class NetworkController extends GetxController with WidgetsBindingObserver {
  final String _lastActiveKey = 'lastActiveTimestamp';
  final Duration _timeoutDuration = const Duration(hours: 1);
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isOnline = true;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    WidgetsBinding.instance.addObserver(this);
  }
  Future<void> _initConnectivity() async {
    // Check initial connectivity state
    final initialResult = await _connectivity.checkConnectivity();
    _handleConnectivityChange(initialResult);

    // Listen for ongoing changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _isOnline = results.any((result) => result != ConnectivityResult.none);

    if (!_isOnline) {
      noIntenetConnectionPopup();
    } else if (wasOnline != _isOnline && Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (state == AppLifecycleState.paused) {
        // App went to background
        await prefs.setInt(_lastActiveKey, DateTime.now().millisecondsSinceEpoch);
      }
      else if (state == AppLifecycleState.resumed) {
        // App came back to foreground
        final lastActiveTime = prefs.getInt(_lastActiveKey);

        if (lastActiveTime != null) {
          final lastActive = DateTime.fromMillisecondsSinceEpoch(lastActiveTime);
          if (DateTime.now().difference(lastActive) > _timeoutDuration) {
            await _restartApp();
          }
        }
      }
      else if (state == AppLifecycleState.detached) {
        // App is being terminated
        await prefs.remove(_lastActiveKey);
      }
    } catch (e) {
      debugPrint('Lifecycle state error: $e');
    }
  }

  Future<void> _restartApp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastActiveKey);
      Get.offAll(() => const SplashScreen());
    } catch (e) {
      debugPrint('Restart app error: $e');
      // Fallback - just navigate to splash screen
      Get.offAll(() => const SplashScreen());
    }
  }
}
