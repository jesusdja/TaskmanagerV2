import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showAlert({required String text,isSuccess = true,int sec = 3,}){

  Color color = isSuccess ? Colors.green.shade300 : Colors.red.shade300;

  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: sec,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 16.0
  );
}