import 'package:flutter/material.dart';
import 'package:tra_s4c/config/s4c_colors.dart';

Widget avatarCircular(Color borde, String rutaImage,double radiu){
  return Container(
      child: CircleAvatar(
        radius: radiu,
        backgroundColor: Colors.white,
        backgroundImage: Image.asset('assets/image/$rutaImage')
            .image,
      ),
      padding: const EdgeInsets.all(2.0), // borde width
      decoration: new BoxDecoration(
        color: borde, // border color
        shape: BoxShape.circle,
      ));
}

Widget avatarCircularNet({Color borde: Colors.black, required String rutaImage,double radiu: 20}){
  Widget res = Container();
  try{
    res = Container(
        child: CircleAvatar(
          radius: radiu,
          backgroundColor: S4CColors().colorLoginPageBack,
          backgroundImage: Image.network(rutaImage).image,
        ),
        padding: const EdgeInsets.all(2.0), // borde width
        decoration: new BoxDecoration(
          color: borde, // border color
          shape: BoxShape.circle,
        ));
  }catch(e){
    print(e.toString());
  }


  return res;
}

Widget avatarCircularImage(Color borde, Image imagen,double radiu){
  return Container(
      child: CircleAvatar(
        radius: radiu,
        backgroundImage: imagen.image,
        backgroundColor: Colors.white,
      ),
      padding: const EdgeInsets.all(2.0), // borde width
      decoration: new BoxDecoration(
        color: borde, // border color
        shape: BoxShape.circle,
      ));
}