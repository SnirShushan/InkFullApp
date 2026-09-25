import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:ink/src/utils/webService.dart';

class AppErrorLog {
  AppErrorLog._();

  static final AppErrorLog instance = AppErrorLog._();

  static const _flushEvery = Duration(seconds: 6);
  static const _maxQueue = 20;
  static const _dedupeWindow = Duration(seconds: 15);

  final List<Map<String, dynamic>> _queue = [];
  final Dio _dio = Dio();
  Timer? _flushTimer;
  bool _flushing = false;
  String? _lastKey;
  DateTime? _lastAt;

  void capture({
    required String type,
    required String message,
    String? stack,
    String? screen,
    String? action,
    Map<String, dynamic>? extra,
  }) {
    final text = message.trim();
    if (text.isEmpty) return;
    if (action == 'LogAppError' || action == 'LogAppEvents') return;
    if (text.contains('Action stubbed') || text.contains('Action not migrated')) {
      return;
    }

    final key = '$type|$text|$action';
    final now = DateTime.now();
    if (_lastKey == key &&
        _lastAt != null &&
        now.difference(_lastAt!) < _dedupeWindow) {
      return;
    }
    _lastKey = key;
    _lastAt = now;

    String? currentScreen = screen;
    if (currentScreen == null || currentScreen.isEmpty) {
      try {
        currentScreen = Get.currentRoute;
      } catch (_) {}
    }

    _queue.add({
      'log_type': type,
      'message': text.length > 2000 ? text.substring(0, 2000) : text,
      if (stack != null && stack.isNotEmpty)
        'stack': stack.length > 8000 ? stack.substring(0, 8000) : stack,
      'screen_name': currentScreen,
      if (action != null && action.isNotEmpty) 'action_name': action,
      'device_type': WebService.deviceType,
      'app_version': WebService.appVersion,
      'source': 'app',
      if (extra != null && extra.isNotEmpty) 'extra': extra,
    });

    debugPrint('AppErrorLog [$type] $text');
    if (_queue.length >= _maxQueue) {
      unawaited(flush());
    } else {
      _armFlush();
    }
  }

  Future<void> flush() async {
    if (_flushing || _queue.isEmpty) return;
    _flushing = true;
    final batch = List<Map<String, dynamic>>.from(_queue);
    _queue.clear();
    try {
      final user = await WebService.getCurrentUser();
      await _dio.post(
        WebService.baseUrl,
        data: FormData.fromMap({
          'action': 'LogAppError',
          'app_token': WebService.appToken,
          'app_version': WebService.appVersion,
          'device_type': WebService.deviceType,
          'uid': user.profile?.id ?? '',
          'login_token': user.profile?.loginToken ?? '',
          'logs': jsonEncode(batch),
        }),
        options: Options(
          sendTimeout: 8000,
          receiveTimeout: 8000,
        ),
      );
    } catch (_) {
      if (_queue.length < 60) {
        _queue.insertAll(0, batch);
      }
    } finally {
      _flushing = false;
    }
  }

  void _armFlush() {
    _flushTimer?.cancel();
    _flushTimer = Timer(_flushEvery, () => unawaited(flush()));
  }
}
