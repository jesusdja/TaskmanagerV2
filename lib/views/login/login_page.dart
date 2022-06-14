import 'package:flutter/material.dart';
import 'package:tra_s4c/config/s4c_colors.dart';
import 'package:tra_s4c/config/s4c_style.dart';
import 'package:tra_s4c/main.dart';
import 'package:tra_s4c/views/login/qr_active.dart';
import 'package:tra_s4c/views/login/sensor_search.dart';
import 'package:tra_s4c/widgets_utils/button_general.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: S4CColors().colorLoginPageBack,
      body: Column(
        children: [
          appBarWidget(),
          SizedBox(height: sizeH * 0.05,),
          Container(
            child: Text('Acceder con:',style: S4CStyles().stylePrimary(size: sizeH * 0.03,color: S4CColors().colorLoginPageText),),
          ),
          Container(
            width: sizeW,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                imageButtonLogin(type: 1),
                SizedBox(width: sizeW * 0.1,),
                imageButtonLogin(type: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget imageButtonLogin({required int type}){

    String path = idTemplate == 0 ? 'icons_sensor_login' :  'icons_sensor_login_black';
    String titleButton = 'Sensor de Proximidad';
    if(type == 2){
      path = idTemplate == 0 ? 'icon_qr_login' :  'icon_qr_login_black';
      titleButton = 'Código QR';
    }

    return Container(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: sizeH * 0.01),
            child: Container(
              height: sizeH * 0.2,
              width: sizeH * 0.2,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Image.asset("assets/image/$path.png").image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          ButtonGeneral(
            title: titleButton,
            textStyle: S4CStyles().stylePrimary(size: sizeH * 0.028,color: S4CColors().colorLoginPageButtonText,fontWeight: FontWeight.bold),
            height: sizeH * 0.07,
            width: sizeW * 0.2,
            backgroundColor: S4CColors().primary,
            icon: Container(),
            onPressed: () async {
              // Navigator.pushReplacement(context, new MaterialPageRoute(builder: (BuildContext context) => new HomePage()));
              if(type == 1){
                Navigator.pushReplacement(context, new MaterialPageRoute(builder: (BuildContext context) => new SensorSearch()));
              }else{
                Navigator.pushReplacement(context, new MaterialPageRoute(builder: (BuildContext context) => new QRActive()));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget appBarWidget(){
    return Container(
      color: Colors.white,
      width: sizeW,
      padding: EdgeInsets.only(top: sizeH * 0.05),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: sizeH * 0.05),
              child: Container(
                height: sizeH * 0.2,
                width: sizeH * 0.2,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: Image.asset("assets/image/logo_lock.png").image,
                    fit: BoxFit.contain,
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
