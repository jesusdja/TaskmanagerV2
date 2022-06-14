import 'package:flutter/material.dart';
import 'package:tra_s4c/main.dart';

class S4CColors {

  Color get primary => colorPrimary[idTemplate];
  List<Color> colorPrimary = [Color(0xF03B5C84),Color(0xF0A0AE57),Color(0xF0000000)];

  Color get colorLoginPageBack => colorLoginPageListBack[idTemplate];
  List<Color> colorLoginPageListBack = [Color(0xF0C9D5EB),Color(0xFFCBD3B3),Color(0xF0C2C2C2)];

  Color get colorLoginPageText => colorLoginPageListText[idTemplate];
  List<Color> colorLoginPageListText = [Color(0xF03B5C84),Color(0xF0000000),Color(0xF0000000)];

  Color get colorLoginPageButtonText => colorLoginPageListButtonText[idTemplate];
  List<Color> colorLoginPageListButtonText = [Colors.white,Color(0xF0000000),Colors.white];

  Color get colorHomeButtonSearch => Color(0xF0D8DEE7);

  Color get colorHomeSplashMenu => colorHomeSplashMenuList[idTemplate];
  List<Color> colorHomeSplashMenuList = [Colors.white,Color(0xF0000000),Colors.white];
}
