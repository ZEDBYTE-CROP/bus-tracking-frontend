import '../Style/Colors.dart';
import 'package:flutter/material.dart';

TextStyle textStyle(
    {double fontsize = 18,
    Color color = const Color(materialBlack),
    double letterSpacing = 0,
    TextDecoration textDecoration = TextDecoration.none,
    FontStyle fontStyle = FontStyle.normal,
    FontWeight fontWeight = FontWeight.w400}) {
  return TextStyle(fontSize: fontsize, color: color, letterSpacing: letterSpacing, decoration: textDecoration, fontStyle: fontStyle, fontWeight: fontWeight);
}

TextSpan textSpan({required String text, required TextStyle textStyle}) {
  return TextSpan(text: text, style: textStyle);
}
