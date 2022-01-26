import '../Style/Colors.dart';
import 'package:flutter/material.dart';

Widget textFormField(
    {bool obscureText = false,
    required TextStyle textStyle,
    TextStyle? hintStyle,
    String? hintText,
    String? labelText,
    TextStyle? labelStyle,
    TextStyle? labelDisabledStyle,
    TextStyle? errorStyle,
    Color borderColor = const Color(red),
    Color cursorColor = const Color(red),
    double borderWidth = 2.0,
    double borderRadius = 10.0,
    Color fillColor = const Color(white),
    int minLines = 1,
    int maxLines = 1,
    int errorMaxLines = 3,
    int maxLength = 500,
    bool counter = false,
    FocusNode? focusNode,
    bool enabled = true,
    bool autofocus = false,
    void Function()? onTap,
    TextInputAction? textInputAction,
    void Function(String)? onFieldSubmitted,
    TextInputType keyboardType = TextInputType.text,
    required TextEditingController textEditingController,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
    Widget? suffixIcon}) {
  return TextFormField(
    controller: textEditingController,
    obscureText: obscureText,
    style: textStyle,
    minLines: minLines,
    maxLines: maxLines,
    maxLength: maxLength,
    onChanged: onChanged,
    focusNode: focusNode,
    enabled: enabled,
    autofocus: autofocus,
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    onFieldSubmitted: onFieldSubmitted,
    cursorColor: cursorColor,
    validator: validator,
    onTap: onTap,
    decoration: InputDecoration(
        errorMaxLines: errorMaxLines,
        alignLabelWithHint: true,
        suffixIcon: suffixIcon,
        label: (labelText != null && labelStyle != null && focusNode != null)
            ? Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Text(labelText, style: focusNode.hasFocus ? labelStyle : labelDisabledStyle),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor, width: borderWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor, width: borderWidth),
        ),
        filled: true,
        counter: (counter) ? null : SizedBox.shrink(),
        counterStyle: TextStyle(
          height: double.minPositive,
        ),
        errorStyle: errorStyle,
        hintStyle: hintStyle,
        hintText: hintText,
        fillColor: Color(white)),
  );
}
