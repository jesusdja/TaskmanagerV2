import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tra_s4c/config/s4c_colors.dart';
import 'package:tra_s4c/config/s4c_style.dart';
import 'package:tra_s4c/main.dart';
import 'package:tra_s4c/services/auth.dart';
import 'package:tra_s4c/services/http_connection.dart';
import 'package:tra_s4c/services/shared_preferences.dart';
import 'package:tra_s4c/services/updateDataHttpToSqlflite.dart';
import 'package:tra_s4c/widgets_utils/button_general.dart';
import 'package:tra_s4c/widgets_utils/circular_progress_colors.dart';
import 'package:tra_s4c/widgets_utils/textfield_general.dart';
import 'package:tra_s4c/widgets_utils/toast_widget.dart';

class SelectDB extends StatefulWidget {
  SelectDB({required this.contextHome, required this.isConfig});
  final BuildContext? contextHome;
  final bool isConfig;
  @override
  _SelectDBState createState() => _SelectDBState();
}

class _SelectDBState extends State<SelectDB> {

  bool obscure = false;
  TextEditingController controllerDB = TextEditingController();
  TextEditingController controllerPass = TextEditingController();
  bool loadData = false;

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future initData()async{
    controllerDB.text = await SharedPreferencesClass().getValue('S4CNameDB') ?? '';
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Scaffold(
        backgroundColor: S4CColors().colorLoginPageBack,
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            appBarWidget(),
            Expanded(
              child: imageButtonLogin(),
            ),
          ],
        ),
      ),
    );
  }

  Widget imageButtonLogin(){
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: sizeH * 0.15,),
          Container(
            child: Text('Seleccionar BB.DD.',style: S4CStyles().stylePrimary(size: sizeH * 0.03,color: S4CColors().colorLoginPageText,fontWeight: FontWeight.bold),),
          ),
          SizedBox(height: sizeH * 0.1,),
          Container(
            width: sizeW * 0.2,
            child: Text('Nombre de la BB.DD.',style: S4CStyles().stylePrimary(size: sizeH * 0.02,color: S4CColors().colorLoginPageText),),
          ),
          SizedBox(height: sizeH * 0.01,),
          Container(
            margin: EdgeInsets.symmetric(horizontal: sizeW * 0.4),
            child: TextFieldGeneral(
              sizeH: sizeH,sizeW: sizeW,
              prefixIcon: Icon(Icons.web),
              colorBack: Colors.transparent,
              borderColor: Colors.transparent,
              activeInputBorder: false,
              textInputType: TextInputType.name,
              textEditingController: controllerDB,
              initialValue: null,
            ),
          ),
          SizedBox(height: sizeH * 0.05,),
          widget.isConfig ? Container() : Container(
            width: sizeW * 0.2,
            child: Text('Contraseña de validación',style: S4CStyles().stylePrimary(size: sizeH * 0.02,color: S4CColors().colorLoginPageText),),
          ),
          widget.isConfig ? Container() : SizedBox(height: sizeH * 0.01,),
          widget.isConfig ? Container() :
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
          widget.isConfig ? Container() : SizedBox(height: sizeH * 0.04,),
          loadData ?
          Container(
            height: sizeH * 0.05,
            width: sizeH * 0.05,
            child: Center(
              child: circularProgressColors(widthContainer1: sizeW,widthContainer2: sizeH * 0.1,colorCircular: S4CColors().primary),
            ),
          ) :
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
              loadData = true;
              setState(() {});

              String error = '';
              if(controllerDB.text.isEmpty){
                error = 'Nombre de la base de datos no puede estar vacio';
              }

              bool passSuccess = false;

              if(error.isEmpty && controllerPass.text.isEmpty && !widget.isConfig){
                error = 'Contraseña de validación incorrecta';
              }else{
                if(!widget.isConfig){
                  passSuccess = await PasswordAdmin().checkPassword(nameDb: controllerDB.text, pass: controllerPass.text);
                }else{
                  passSuccess = true;
                }
                if(!passSuccess){
                  error = 'Contraseña de validación incorrecta o la contraseña no se encuentra configurada';
                }
              }

              if(error.isEmpty){
                try{
                  var response = await ConnectionHttp().httpGetValidateCentro(controllerDB.text);
                  if(response.statusCode == 200){
                    var value = jsonDecode(response.body);
                    if(value){
                      UpdateDataHttpToSqlLite().getUsersHttp();
                      UpdateDataHttpToSqlLite().getPatientsHttp();
                      UpdateDataHttpToSqlLite().getDataCentro();
                      UpdateDataHttpToSqlLite().getMotivosAlarma();
                      await SharedPreferencesClass().setStringValue('S4CNameDB',controllerDB.text.toLowerCase());
                      if(widget.isConfig){
                        Navigator.of(context).pop(true);
                      }else{
                        await SharedPreferencesClass().setStringValue('S4CPasswordDB',controllerPass.text.toLowerCase());
                        await SharedPreferencesClass().setIntValue('S4CInit',2);
                        AuthService auth = Provider.of<AuthService>(widget.contextHome!,listen: false);
                        auth.init();
                      }
                    }else{
                      String errorHttp = 'EL nombre de la base de datos es incorrecto';
                      showAlert(text: errorHttp,isSuccess: false);
                    }
                  }else{
                    String errorHttp = 'Error de conexión con el servidor, Posiblemente nombre de Base de Datos incorrecta.';
                    showAlert(text: errorHttp,isSuccess: false);
                  }
                }catch(e){
                  showAlert(text: 'Error: ${e.toString()}',isSuccess: false);
                }
                if(mounted){
                  loadData = false;
                  setState(() {});
                }
              }else{
                showAlert(text: error,isSuccess: false);
              }
              loadData = false;
              setState(() {});
            },
          ),
          widget.isConfig ? Container() : SizedBox(height: sizeH * 0.1,),
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
          widget.isConfig ?
          InkWell(
            splashColor: S4CColors().primary,
            focusColor: S4CColors().primary,
            onTap: (){
              Navigator.of(context).pop(false);
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
