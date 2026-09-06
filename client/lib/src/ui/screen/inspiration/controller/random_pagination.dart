import 'dart:math';

import 'package:ink/src/utils/webService.dart';

class RandomPagination {
  final int totalPosts;
  final int limit;
  final int groupSize; // how many items per group
  late final List<List<int>> _groups;
  int _currentGroupIndex = 0;
  bool _isExhausted = false;

  RandomPagination({
    required this.totalPosts,
    required this.limit,
    this.groupSize = 5,
  }) {
    final safeTotal = totalPosts < 0 ? 0 : totalPosts;
    final totalStarts = safeTotal == 0
        ? <int>[0]
        : List.generate(
            (safeTotal / limit).ceil(),
            (index) => index * limit,
          );

    // Split into groups
    _groups = [];
    for (var i = 0; i < totalStarts.length; i += groupSize) {
      _groups.add(totalStarts.sublist(
        i,
        i + groupSize > totalStarts.length ? totalStarts.length : i + groupSize,
      ));
    }

    WebService.lastRandomPagination = totalStarts.isEmpty ? 0 : totalStarts.last;
  }

  int? getUniqueRandomStart() {
    if (_isExhausted) return null;
    while (_currentGroupIndex < _groups.length) {
      final currentGroup = _groups[_currentGroupIndex];
      if (currentGroup.isEmpty) {
        _currentGroupIndex++;
        continue;
      }

      final random = Random();
      final randomIndex = random.nextInt(currentGroup.length);
      final selectedStart = currentGroup[randomIndex];
      currentGroup.removeAt(randomIndex);
      return selectedStart;
    }

    _isExhausted = true;
    return null;
  }

  void reset() {
    _currentGroupIndex = 0;
    _isExhausted = false;
    final totalStarts = List.generate(
      (totalPosts / limit).ceil(),
          (index) => index * limit,
    );

    _groups.clear();
    for (var i = 0; i < totalStarts.length; i += groupSize) {
      _groups.add(totalStarts.sublist(
        i,
        i + groupSize > totalStarts.length ? totalStarts.length : i + groupSize,
      ));
    }
  }
  bool get isCurrentGroupFinished {
    if (_isExhausted) return true;
    return _currentGroupIndex >= _groups.length || _groups[_currentGroupIndex].isEmpty;
  }


  bool get isExhausted => _isExhausted;
}