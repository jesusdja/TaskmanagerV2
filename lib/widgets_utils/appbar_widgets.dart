import 'package:flutter/material.dart';
import 'package:tra_s4c/config/s4c_style.dart';

AppBar appBarWidget({
  double sizeH = 10,
  void Function()? onTap,
  String title = '',
  Color colorIcon = Colors.white,
  TextStyle? styleTitle,
  TextAlign alignTitle = TextAlign.center,
  Color backgroundColor = Colors.white,
  double elevation = 5,
  IconData icon = Icons.arrow_back_outlined,
  bool centerTitle = true,
  }){

  styleTitle = styleTitle ?? S4CStyles().stylePrimary(size: sizeH * 0.027,color: Colors.white,fontWeight: FontWeight.bold);

  return AppBar(
    backgroundColor: backgroundColor,
    elevation: elevation,
    leading: InkWell(
      child: Icon(icon,size: sizeH * 0.038,color: colorIcon,),
      onTap: onTap,
    ),
    centerTitle: centerTitle,
    title: Text(title,style: styleTitle,textAlign: alignTitle,),
  );
}