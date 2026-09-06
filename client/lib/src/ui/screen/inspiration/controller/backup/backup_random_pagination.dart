// import 'dart:math';
//
// import 'package:ink/src/utils/webService.dart';
//
// class RandomPaginations {
//   final int totalPosts;
//   final int limit;
//   late final List<int> _allStartPoints;
//   late List<int> _availableStartPoints;
//   bool _isExhausted = false;
//
//   RandomPaginations({
//     required this.totalPosts,
//     required this.limit,
//   }) {
//     _allStartPoints = List.generate(
//       (totalPosts / limit).ceil(),
//           (index) => index * limit,
//     );
//     _availableStartPoints = List.from(_allStartPoints);
//     WebService.lastRandomPagination=_allStartPoints.last;
//
//   }
//
//   int? getUniqueRandomStart() {
//     if (_isExhausted) return null;
//     if (_availableStartPoints.isEmpty) {
//       _isExhausted = true;
//       return null;
//     }
//
//     final random = Random();
//     final randomIndex = random.nextInt(_availableStartPoints.length);
//     final selectedStart = _availableStartPoints[randomIndex];
//     _availableStartPoints.removeAt(randomIndex);
//     WebService.allStartPointsList.addAll(_allStartPoints);
//     return selectedStart;
//   }
//
//   void reset() {
//     _availableStartPoints = List.from(_allStartPoints);
//     _isExhausted = false;
//   }
//
//   bool get isExhausted => _isExhausted;
//   List<int> get allStartPoints => List.from(_allStartPoints);
//   List<int> get remainingStartPoints => List.from(_availableStartPoints);
// }
