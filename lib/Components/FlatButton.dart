import '../Components/Container.dart';
import '../Style/Colors.dart';
import 'package:flutter/material.dart';

Widget flatButton(
    {double spreadRadius = 2.0,
    bool shadow = true,
    required Function()? onPressed,
    required Widget widget,
    double radius = 5.0,
    Color bgColor = const Color(transparent),
    Color primary = const Color(white),
    Color backgroundColor = const Color(materialBlack),
    TextStyle? textStyle,
    Size size = const Size(125, 45)}) {
  return container(
    widget: TextButton(
      onPressed: onPressed,
      child: widget,
      style: TextButton.styleFrom(
        primary: primary,
        backgroundColor: backgroundColor,
        textStyle: textStyle,
        minimumSize: size,
      ),
    ),
    bgColor: bgColor,
    shadow: shadow,
    spreadRadius: spreadRadius,
    radius: radius,
  );
}
