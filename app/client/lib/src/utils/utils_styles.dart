import 'package:flutter/material.dart';

//custom
TextStyle customTextStyle(
        {Color? color, double? fontSize, FontWeight? fontWeight}) =>
    TextStyle(
        color: color ?? Color(0xFFDFDCE3),
        fontSize: fontSize ?? 14,
        fontFamily: 'Arimo',
        fontWeight: fontWeight ?? FontWeight.w400);

TextStyle bigBoldWhiteStyle = const TextStyle(
    color: Color(0xFFDFDCE3),
    fontSize: 18,
    fontFamily: 'Arimo',
    fontWeight: FontWeight.w700);

TextStyle textStyle14s400w = const TextStyle(
    color: Color(0xFFDFDCE3),
    fontSize: 14,
    fontFamily: 'Arimo',
    fontWeight: FontWeight.w400);

TextStyle normalBoldWhiteStyle = const TextStyle(
  color: Color(0xFFDFDCE3),
  fontSize: 14,
  fontFamily: 'Arimo',
  fontWeight: FontWeight.w700,
);

TextStyle normalWhiteStyle = const TextStyle(
    color: Color(0xFFDFDCE3),
    fontSize: 16,
    fontFamily: 'Arimo',
    fontWeight: FontWeight.w400);

TextStyle normalWhiteStyle16width700 = const TextStyle(
    color: Color(0xFFDFDCE3),
    fontSize: 16,
    fontFamily: 'Arimo',
    fontWeight: FontWeight.w700);
