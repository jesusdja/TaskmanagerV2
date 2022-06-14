import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tra_s4c/config/s4c_colors.dart';
import 'package:tra_s4c/config/s4c_style.dart';
import 'package:tra_s4c/main.dart';
import 'package:tra_s4c/services/auth.dart';
import 'package:tra_s4c/services/shared_preferences.dart';
import 'package:tra_s4c/widgets_utils/button_general.dart';
import 'package:tra_s4c/widgets_utils/textfield_general.dart';
import 'package:tra_s4c/widgets_utils/toast_widget.dart';

class SelectTypeLogin extends StatefulWidget {
  SelectTypeLogin({required this.contextHome, required this.isConfig});
  final BuildContext? contextHome;
  final bool isConfig;
  @override
  _SelectTypeLoginState createState() => _SelectTypeLoginState();
}

class _SelectTypeLoginState extends State<SelectTypeLogin> {

  int? typeLogin;
  bool viewPass = true;
  bool obscure = true;
  TextEditingController controllerPass = TextEditingController();

  @override
  void initState() {
    super.initState();
    viewPass = widget.isConfig;
    if(widget.isConfig){
      initData();
    }
  }

  Future initData() async{
    typeLogin = await SharedPreferencesClass().getValue('s4cTypeLogin');
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: S4CColors().colorLoginPageBack,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            appBarWidget(),
            SizedBox(height: sizeH * 0.1,),
            pageSelect(),
          ],
        ),
      ),
    );
  }

  Widget pagePass(){
    return Container(
      width: sizeW,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: sizeH * 0.2,),
          Container(
            width: sizeW * 0.2,
            child: Text('Contraseña de validación',style: S4CStyles().stylePrimary(size: sizeH * 0.02,color: S4CColors().colorLoginPageText),),
          ),
          SizedBox(height: sizeH * 0.01,),
          Container(
            margin: EdgeInsets.symmetric(horizontal: sizeW * 0.4),
            child: TextFieldGeneral(
              sizeH: sizeH,sizeW: sizeW,
              prefixIcon: Icon(Icons.lock_outline),
              suffixIcon: InkWell(
                child: Icon(!obscure ? Icons.remove_red_eye_outlined : Icons.remove_red_eye_rounded),
                onTap: (){
                  setState(() {
                    obscure = !obscure;
                  });
                },
              ),
              colorBack: Colors.transparent,
              borderColor: Colors.transparent,
              activeInputBorder: false,
              obscure: !obscure,
              textInputType: TextInputType.number,
              textEditingController: controllerPass,
              initialValue: null,
            ),
          ),
          SizedBox(height: sizeH * 0.08,),
          ButtonGeneral(
            title: 'Confirmar',
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
              String error = '';
              if(error.isEmpty && controllerPass.text != '130818'){
                error = 'Contraseña de validación incorrecta';
              }
              if(error.isEmpty){
                setState(() {
                  viewPass = false;
                });
              }else{
                showAlert(text: error,isSuccess: false);
              }
            },
          ),
          SizedBox(height: sizeH * 0.1,),
        ],
      ),
    );
  }

  Widget pageSelect(){
    return Container(
      width: sizeW,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: sizeW,
            child: Text('Configure su método de acceso \npredeterminado',
              style: S4CStyles().stylePrimary(
                  size: sizeH * 0.035,
                  color: S4CColors().colorLoginPageText,
                  fontWeight: FontWeight.bold
              ),textAlign: TextAlign.center,),
          ),
          SizedBox(height: sizeH * 0.08,),
          Container(
            width: sizeW,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                selectTemplateImage(type: 0),
                SizedBox(width: sizeW * 0.05,),
                selectTemplateImage(type: 1),
                SizedBox(width: sizeW * 0.05,),
                selectTemplateImage(type: 2),
              ],
            ),
          ),
          SizedBox(height: sizeH * 0.08,),
          Container(
            width: sizeW,
            child: Text('Seleccionando el método de acceso predeterminado para poder ingresar.\nSerá más rápido y fácil, con menos clics.',
              style: S4CStyles().stylePrimary(
                size: sizeH * 0.025,
                color: S4CColors().colorLoginPageText,
              ),textAlign: TextAlign.center,),
          ),
        ],
      ),
    );
  }

  Widget selectTemplateImage({required int type}){

    String pathImage = '';
    String textName = '';
    bool selected = typeLogin != null && typeLogin == type;
    if(type == 0){
      pathImage = idTemplate == 0 ? 'icons_sensor_login' : 'icons_sensor_login_black';
      textName = 'Sensor';
    }
    if(type == 1){
      pathImage = idTemplate == 0 ? 'icon_qr_login' : 'icon_qr_login_black';
      textName = 'QR';
    }
    if(type == 2){
      pathImage = idTemplate == 0 ? 'icons_login' : 'icons_login_black';
      textName = 'Sensor / QR';
    }

    return InkWell(
      onTap: () async {
        await SharedPreferencesClass().setIntValue('s4cTypeLogin', type);
        if(widget.isConfig){
          blocData.inList.add({'refreshApp' : true});
          Navigator.of(context).pop(true);
        }else{
          await SharedPreferencesClass().setIntValue('S4CInit',4);
          AuthService auth = Provider.of<AuthService>(widget.contextHome!,listen: false);
          auth.init();
        }

      },
      child: Container(
        decoration: BoxDecoration(
          color: selected ? Colors.white54 : Colors.transparent,
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
        ),
        padding: EdgeInsets.all(sizeH * 0.03),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: sizeH * 0.25,
              width: sizeH * 0.25,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Image.asset("assets/image/$pathImage.png").image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: sizeH * 0.01,),
            Text(textName,style: S4CStyles().stylePrimary(size: sizeH * 0.03,fontWeight: FontWeight.bold,color: S4CColors().primary),)
          ],
        ),
      ),
    );
  }

  Widget logo(){
    return Container(
      width: sizeW,
      child: Container(
        height: sizeH * 0.15,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Image.asset("assets/image/logo_lock.png").image,
            fit: BoxFit.contain,
          ),
        ),
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
          widget.isConfig ?
          InkWell(
            splashColor: S4CColors().primary,
            focusColor: S4CColors().primary,
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
          ) : Container()
        ],
      ),
    );
  }
}
