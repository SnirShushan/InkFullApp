import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:ink/src/utils/webService.dart';

class AppAnalytics {
  AppAnalytics._();

  static final AppAnalytics instance = AppAnalytics._();

  static const _flushEvery = Duration(seconds: 20);
  static const _maxQueue = 20;
  static const _sessionGap = Duration(minutes: 30);

  final List<Map<String, dynamic>> _queue = [];
  final Dio _dio = Dio();
  Timer? _flushTimer;
  String? _sessionId;
  DateTime? _sessionStartedAt;
  DateTime? _lastResumeAt;
  String? _currentScreen;
  DateTime? _screenEnteredAt;
  bool _flushing = false;

  void startSession() {
    _sessionId ??= _newSessionId();
    _sessionStartedAt = DateTime.now();
    _lastResumeAt = _sessionStartedAt;
    _track(
      type: 'session',
      name: 'session_start',
    );
    _armFlush();
  }

  void resume() {
    final now = DateTime.now();
    final away = _lastResumeAt == null
        ? Duration.zero
        : now.difference(_lastResumeAt!);
    if (_sessionId == null || away >= _sessionGap) {
      _sessionId = _newSessionId();
      _sessionStartedAt = now;
      _track(type: 'session', name: 'session_start');
    }
    _lastResumeAt = now;
    if (_currentScreen != null) {
      _screenEnteredAt = now;
    }
    _armFlush();
  }

  void pause() {
    _closeCurrentScreen();
    unawaited(flush());
  }

  void endSession() {
    _closeCurrentScreen();
    final started = _sessionStartedAt;
    if (started != null) {
      _track(
        type: 'session',
        name: 'session_end',
        durationMs: DateTime.now().difference(started).inMilliseconds,
      );
    }
    unawaited(flush());
  }

  void screen(String rawName) {
    final name = _normalizeScreen(rawName);
    if (name.isEmpty || name == _currentScreen) return;
    _closeCurrentScreen();
    _currentScreen = name;
    _screenEnteredAt = DateTime.now();
    _track(
      type: 'screen',
      name: 'screen_view',
      screen: name,
    );
  }

  void action(String name, {Map<String, dynamic>? extra}) {
    if (name.trim().isEmpty) return;
    _track(
      type: 'action',
      name: name.trim(),
      screen: _currentScreen,
      extra: extra,
    );
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
          'action': 'LogAppEvents',
          'app_token': WebService.appToken,
          'app_version': WebService.appVersion,
          'device_type': WebService.deviceType,
          'uid': user.profile?.id ?? '',
          'login_token': user.profile?.loginToken ?? '',
          'session_id': _sessionId ?? '',
          'events': jsonEncode(batch),
        }),
        options: Options(
          sendTimeout: 8000,
          receiveTimeout: 8000,
        ),
      );
    } catch (_) {
      if (_queue.length < 80) {
        _queue.insertAll(0, batch);
      }
    } finally {
      _flushing = false;
    }
  }

  void _closeCurrentScreen() {
    final screen = _currentScreen;
    final entered = _screenEnteredAt;
    if (screen == null || entered == null) return;
    _track(
      type: 'screen',
      name: 'screen_leave',
      screen: screen,
      durationMs: DateTime.now().difference(entered).inMilliseconds,
    );
    _screenEnteredAt = null;
  }

  void _track({
    required String type,
    required String name,
    String? screen,
    int? durationMs,
    Map<String, dynamic>? extra,
  }) {
    _sessionId ??= _newSessionId();
    _queue.add({
      'event_type': type,
      'event_name': name,
      'screen_name': screen,
      'duration_ms': durationMs,
      'session_id': _sessionId,
      'device_type': WebService.deviceType,
      'app_version': WebService.appVersion,
      if (extra != null) 'extra': extra,
    });
    if (_queue.length >= _maxQueue) {
      unawaited(flush());
    } else {
      _armFlush();
    }
  }

  void _armFlush() {
    _flushTimer?.cancel();
    _flushTimer = Timer(_flushEvery, () => unawaited(flush()));
  }

  String _newSessionId() {
    final rand = Random();
    return '${DateTime.now().millisecondsSinceEpoch}-${rand.nextInt(1 << 32)}';
  }

  String _normalizeScreen(String raw) {
    var name = raw.trim();
    if (name.startsWith('/')) name = name.substring(1);
    if (name.contains('?')) name = name.split('?').first;
    return name;
  }
}

class AppAnalyticsObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _onRoute(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _onRoute(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) _onRoute(previousRoute);
  }

  void _onRoute(Route<dynamic> route) {
    final settingsName = route.settings.name;
    if (settingsName != null &&
        settingsName.isNotEmpty &&
        settingsName != '/') {
      AppAnalytics.instance.screen(settingsName);
      return;
    }
    if (route is GetPageRoute) {
      final name = route.routeName ?? '';
      if (name.isNotEmpty && name != '/') {
        AppAnalytics.instance.screen(name);
      }
    }
  }
}
