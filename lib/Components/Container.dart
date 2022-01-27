import 'package:flutter/material.dart';
import '../Style/Colors.dart';

Widget container(
    {bool shadow = true,
    required Widget widget,
    bool border = false,
    Color bgColor = const Color(white),
    Color borderColor = const Color(materialBlack),
    double radius = 10.0,
    double spreadRadius = 5.0,
    double blurRadius = 7.0,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    AlignmentGeometry? alignment}) {
  return Container(
      child: widget,
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      alignment: alignment,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          color: bgColor,
          boxShadow: (shadow)
              ? [
                  BoxShadow(
                    color: Color(materialBlack).withOpacity(0.2),
                    spreadRadius: spreadRadius,
                    blurRadius: blurRadius,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
          border: (border == false) ? null : Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(radius)));
}
