import '../Style/Colors.dart';
import '../Style/Text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

SnackBar snackbar({required String content, SnackBarBehavior snackBarBehaviour = SnackBarBehavior.floating, Duration duration = const Duration(seconds: 5)}) {
  return SnackBar(
    duration: duration,
    content: Text(
      (content.isNotEmpty && content.trim() != "") ? content : "Something went wrong!",
      style: GoogleFonts.montserratAlternates(textStyle: textStyle(color: Color(white))),
    ),
    shape: RoundedRectangleBorder(side: BorderSide(color: Color(materialBlack)), borderRadius: BorderRadius.circular(5)),
    behavior: snackBarBehaviour,
    backgroundColor: Color(materialBlack),
  );
}
