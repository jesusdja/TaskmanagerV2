import 'package:flutter/material.dart';

Widget containerLoading({double sizeH = 0,double sizeW = 0, }){
  return Container(
    width: sizeW,
    height: double.infinity,
    child: Center(
      child: CircularProgressIndicator(),
    ),
  );
}