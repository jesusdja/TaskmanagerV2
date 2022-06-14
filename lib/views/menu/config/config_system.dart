import 'dart:async';
import 'package:flutter/material.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:tra_s4c/config/s4c_colors.dart';
import 'package:tra_s4c/config/s4c_style.dart';
import 'package:tra_s4c/main.dart';
import 'package:tra_s4c/services/shared_preferences.dart';
import 'package:tra_s4c/utils/deviced_lampara_ip.dart';
import 'package:tra_s4c/utils/get_data.dart';
import 'package:tra_s4c/widgets_utils/button_general.dart';
import 'package:tra_s4c/widgets_utils/circular_progress_colors.dart';
import 'package:tra_s4c/widgets_utils/textfield_general.dart';
import 'package:tra_s4c/widgets_utils/toast_widget.dart';

class ConfigSystem extends StatefulWidget {
  @override
  _ConfigTabletState createState() => _ConfigTabletState();
}

class _ConfigTabletState extends State<ConfigSystem> {

  bool obscure = false;
  bool loadData = true;
  bool loadButton = false;
  TextEditingController controllerTimeInactivity = TextEditingController();
  TextEditingController controllerIpLampara = TextEditingController();
  TextEditingController controllerPass = TextEditingController();
  Map<String,String> getDataIdAzure = {};
  ButtonState stateOnOff = ButtonState.loading;
  int idOnOff = 0;
  String ipDevice = '';

  @override
  void initState() {
    super.initState();
    checkOnOff();
    initData();
  }

  Future initData()async{
    loadData = true;
    setState(() {});

    int timeInact = await SharedPreferencesClass().getValue('S4CTimeInact') ?? 120;
    double segTime = (timeInact / 60);
    controllerTimeInactivity.text = segTime.toStringAsFixed(0);

    try{
      ipDevice = await SharedPreferencesClass().getValue('S4CIpDeviceLampara') ?? '';
      String ip =  ipDevice.split('|')[0];
      controllerIpLampara.text = ip;
    }catch(_){}

    loadData = false;
    setState(() {});
  }

  Future checkOnOff() async{
    idOnOff = await SharedPreferencesClass().getValue('S4COnOffLed') ?? 0;
    if(idOnOff == 1){
      stateOnOff = ButtonState.fail;
    }else{
      stateOnOff = ButtonState.success;
    }

    if(mounted){
      setState(() {});
    }
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
        body:
        loadData ?
        Container(
          width: sizeW,
          height: sizeH,
          child: Center(
            child: circularProgressColors(widthContainer1: sizeW,widthContainer2: sizeH * 0.1,colorCircular: S4CColors().primary),
          ),
        ) :
        SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              appBarWidget(),
              imageButtonLogin(),
            ],
          ),
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
          Container(
            margin: EdgeInsets.only(left: sizeW * 0.8,top: sizeH * 0.02),
            child: Container(
              width: sizeW * 0.15,
              child: ProgressButton.icon(
                radius: 5.0,
                height: sizeH * 0.07,
                minWidth: sizeW * 0.1,
                maxWidth: sizeW * 0.1,
                iconedButtons: {
                  ButtonState.idle:
                  IconedButton(
                      text: "Enviar",
                      icon: Icon(Icons.send,color: Colors.white),
                      color: S4CColors().primary),
                  ButtonState.loading:
                  IconedButton(
                      text: "Enviando. . . .",
                      color: S4CColors().primary),
                  ButtonState.fail:
                  IconedButton(
                      text: "Lampara apagada",
                      icon: Icon(Icons.flash_off,color: S4CColors().primary,size: sizeH * 0.02),
                      color: Colors.red.shade300),
                  ButtonState.success:
                  IconedButton(
                      text: "Lampara encendida",
                      icon: Icon(Icons.flash_on,color: S4CColors().primary,size: sizeH * 0.02,),
                      color: Colors.yellow)
                },
                onPressed: () async {
                  int type = stateOnOff == ButtonState.fail ? 0 : 1;
                  print('Type = $type ($stateOnOff)');
                  stateOnOff = ButtonState.loading;
                  setState(() {});
                  await ledOnAndOff(type);
                  checkOnOff();
                },
                state: stateOnOff,
                textStyle: S4CStyles().stylePrimary(size: sizeH * 0.018,color: stateOnOff == ButtonState.success ? S4CColors().primary : S4CColors().colorLoginPageButtonText,fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: sizeH * 0.05,),
          Container(
            child: Text('Configuración del Sistema',style: S4CStyles().stylePrimary(size: sizeH * 0.03,color: S4CColors().colorLoginPageText,fontWeight: FontWeight.bold),),
          ),
          SizedBox(height: sizeH * 0.08,),
          Container(
            width: sizeW * 0.2,
            child: Text('Tiempo inactivo',style: S4CStyles().stylePrimary(size: sizeH * 0.02,color: S4CColors().colorLoginPageText),),
          ),
          SizedBox(height: sizeH * 0.01,),
          Container(
            margin: EdgeInsets.symmetric(horizontal: sizeW * 0.39),
            child: TextFieldGeneral(
              sizeH: sizeH,sizeW: sizeW,
              prefixIcon: Icon(Icons.access_alarm),
              colorBack: Colors.transparent,
              borderColor: Colors.transparent,
              activeInputBorder: false,
              textInputType: TextInputType.numberWithOptions(signed: false,decimal: false),
              textEditingController: controllerTimeInactivity,
              initialValue: null,
            ),
          ),
          SizedBox(height: sizeH * 0.03,),
          Container(
            width: sizeW * 0.2,
            child: Text('Ip lampara',style: S4CStyles().stylePrimary(size: sizeH * 0.02,color: S4CColors().colorLoginPageText),),
          ),
          SizedBox(height: sizeH * 0.01,),
          Container(
            margin: EdgeInsets.symmetric(horizontal: sizeW * 0.39),
            child: TextFieldGeneral(
              sizeH: sizeH,sizeW: sizeW,
              prefixIcon: Icon(Icons.network_wifi),
              colorBack: Colors.transparent,
              borderColor: Colors.transparent,
              activeInputBorder: false,
              textInputType: TextInputType.number,
              textEditingController: controllerIpLampara,
              initialValue: null,
            ),
          ),
          SizedBox(height: sizeH * 0.03,),
          Container(
            width: sizeW * 0.2,
            child: Text('Contraseña de validación',style: S4CStyles().stylePrimary(size: sizeH * 0.02,color: S4CColors().colorLoginPageText),),
          ),
          SizedBox(height: sizeH * 0.01,),
          Container(
            margin: EdgeInsets.symmetric(horizontal: sizeW * 0.39),
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
          SizedBox(height: sizeH * 0.04,),
          loadButton ?
          Container(
            width: sizeW,
            height: sizeH * 0.08,
            child: Center(
              child: circularProgressColors(widthContainer1: sizeW,widthContainer2: sizeH * 0.05,colorCircular: S4CColors().primary),
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
            onPressed: () => saveButton(),
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
          ),
        ],
      ),
    );
  }

  Future saveButton() async{

    loadButton = true;
    setState(() {});

    String error = '';
    int minText = 0;
    if(controllerTimeInactivity.text.isEmpty){
      error = 'Tiempo de inactividad no puede estar vacio';
    }

    try{
      minText = int.parse(controllerTimeInactivity.text);
    }catch(_){
      error = 'Tiempo de inactividad debe ser un valor entero';
    }

    if(controllerIpLampara.text.isEmpty){
      error = 'Ip de la Lampara no puede estar vacio';
    }

    if(error.isEmpty && controllerPass.text != '130818'){
      error = 'Contraseña de validación incorrecta';
    }

    if(error.isEmpty){
      int segText = minText * 60;
      await SharedPreferencesClass().setIntValue('S4CTimeInact',segText);
      await DeviceIp().updateDeviceIp(ip: controllerIpLampara.text, id: ipDevice.split('|')[2]);
      Navigator.of(context).pop();
    }else{
      showAlert(text: error,isSuccess: false);
    }

    loadButton = false;
    setState(() {});
  }
}
