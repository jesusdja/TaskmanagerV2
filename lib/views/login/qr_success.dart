import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tra_s4c/config/s4c_colors.dart';
import 'package:tra_s4c/config/s4c_style.dart';
import 'package:tra_s4c/main.dart';
import 'package:tra_s4c/services/shared_preferences.dart';
import 'package:tra_s4c/views/home/home_page.dart';
import 'package:tra_s4c/widgets_utils/button_general.dart';
import 'package:tra_s4c/widgets_utils/circular_progress_colors.dart';

class QRSuccess extends StatefulWidget {
  @override
  _QRSuccessState createState() => _QRSuccessState();
}

class _QRSuccessState extends State<QRSuccess> {

  Map<String,dynamic> dataUser = {};
  bool loadData = true;

  @override
  void initState() {
    super.initState();
    initialData();
  }

  Future initialData() async{
    String data = await SharedPreferencesClass().getValue('s4cUserLogin');
    dataUser = jsonDecode(data);
    loadData = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: S4CColors().colorLoginPageBack,
      body: loadData ?
      Container(
        width: sizeW,
        height: sizeH,
        child: Center(
          child: circularProgressColors(widthContainer1: sizeW,widthContainer2: sizeH * 0.04,colorCircular: S4CColors().primary),
        ),
      )
          :
      Column(
        children: [
          appBarWidget(),
          Expanded(
            child: imageButtonLogin(),
          )
        ],
      ),
    );
  }

  Widget imageButtonLogin(){

    String name = '';
    if(dataUser['stNombre'] != null){
      name = dataUser['stNombre'];
    }

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: sizeH * 0.01),
            child: Container(
              height: sizeH * 0.4,
              width: sizeH * 0.4,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Image.asset("assets/image/qr_image_success.png").image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SizedBox(height: sizeH * 0.02,),
          Container(
            child: Text('QR reconocido con éxito',style: S4CStyles().stylePrimary(size: sizeH * 0.03,color: S4CColors().colorLoginPageText),),
          ),
          SizedBox(height: sizeH * 0.05,),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Text('Bienvenido',style: S4CStyles().stylePrimary(size: sizeH * 0.03,color: S4CColors().colorLoginPageText),),
                ),
                Container(
                  child: Text(' $name',style: S4CStyles().stylePrimary(size: sizeH * 0.03,color: S4CColors().colorLoginPageText,fontWeight: FontWeight.bold),),
                ),
              ],
            ),
          ),
          SizedBox(height: sizeH * 0.02,),
          ButtonGeneral(
            title: 'Acceder',
            textStyle: S4CStyles().stylePrimary(size: sizeH * 0.028,color: S4CColors().colorLoginPageButtonText,fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
            icon: Container(
              margin: EdgeInsets.only(right: sizeW * 0.015),
              height: sizeH * 0.03,
              width: sizeH * 0.03,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Image.asset("assets/image/icon_access${(idTemplate == 1) ? '_black' : ''}.png").image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            titlePadding: EdgeInsets.only(left: sizeW * 0.015),
            height: sizeH * 0.07,
            width: sizeW * 0.25,
            backgroundColor: S4CColors().primary,
            onPressed: () async {
              Navigator.pushReplacement(context, new MaterialPageRoute(builder: (BuildContext context) => new HomePage()));
            },
          ),
          SizedBox(height: sizeH * 0.1,),
        ],
      ),
    );
  }

  Widget appBarWidget(){
    return Container(
      color: Colors.white,
      width: sizeW,
      padding: EdgeInsets.only(top: sizeH * 0.04),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: sizeH * 0.01),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.only(left: sizeW * 0.05),
                  height: sizeH * 0.06,
                  width: sizeH * 0.25,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: Image.asset("assets/image/logo_lock.png").image,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: (){
              Navigator.of(context).pop();
            },
            child: Container(
              height: sizeH * 0.05,
              width: sizeH * 0.05,
              margin: EdgeInsets.only(right: sizeW * 0.03),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Image.asset("assets/image/icons_door_out${idTemplate == 0 ? '' : '_black'}.png").image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
