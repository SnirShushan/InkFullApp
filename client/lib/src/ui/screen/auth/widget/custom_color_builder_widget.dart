import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';

class CustomColorBuilder extends ColorBuilder {
  final Color enteredColor;
  final Color notEnteredColor;
  final Color currentFieldColor;
  int maxIndex = 0;
  int currentIndex = 0; // Track the current index

  CustomColorBuilder(this.enteredColor, this.notEnteredColor,
      this.currentFieldColor, this.currentIndex, this.maxIndex);

  @override
  Color indexProperty(int index) {
    if (index == currentIndex) {
      return currentFieldColor; // Color for the current focused pin field
    }
    return index < maxIndex ? enteredColor : notEnteredColor;
  }

  @override
  void notifyChange(String enteredPin) {
    maxIndex = enteredPin.length;
  }

  void updateCurrentIndex(int index) {
    currentIndex = index; // Update the current focused field's index
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomColorBuilder &&
          runtimeType == other.runtimeType &&
          enteredColor == other.enteredColor &&
          notEnteredColor == other.notEnteredColor &&
          currentFieldColor == other.currentFieldColor &&
          maxIndex == other.maxIndex &&
          currentIndex == other.currentIndex;

  @override
  int get hashCode =>
      enteredColor.hashCode ^
      notEnteredColor.hashCode ^
      currentFieldColor.hashCode ^
      maxIndex.hashCode ^
      currentIndex.hashCode;
}
