import 'package:flutter/material.dart';

class S4CStyles {
  TextStyle stylePrimary({
    double size = 10,
    Color color = Colors.black,
    FontWeight fontWeight = FontWeight.normal,
    double? heightText,
    TextDecoration? textDecoration,
    String family = 'NunitoSans'
  }) {
    return TextStyle(
      color: color,
      fontSize: size,
      fontWeight: fontWeight,
      height: heightText,
      decoration: textDecoration,
      fontFamily: family,

    );
  }
}
