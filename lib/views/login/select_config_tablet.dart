import'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:provider/provider.dart';
import 'package:tra_s4c/config/s4c_colors.dart';
import 'package:tra_s4c/config/s4c_style.dart';
import 'package:tra_s4c/main.dart';
import 'package:tra_s4c/services/auth.dart';
import 'package:tra_s4c/services/http_connection.dart';
import 'package:tra_s4c/services/shared_preferences.dart';
import 'package:tra_s4c/services/updateDataHttpToSqlflite.dart';
import 'package:tra_s4c/utils/deviced_lampara_ip.dart';
import 'package:tra_s4c/utils/get_data.dart';
import 'package:tra_s4c/widgets_utils/button_general.dart';
import 'package:tra_s4c/widgets_utils/circular_progress_colors.dart';
import 'package:tra_s4c/widgets_utils/dropdownButton_generic.dart';
import 'package:tra_s4c/widgets_utils/textfield_general.dart';
import 'package:tra_s4c/widgets_utils/toast_widget.dart';

class ConfigTablet extends StatefulWidget {
  ConfigTablet({required this.contextHome, required this.isConfig});
  final BuildContext? contextHome;
  final bool isConfig;
  @override
  _ConfigTabletState createState() => _ConfigTabletState();
}

class _ConfigTabletState extends State<ConfigTablet> {

  bool obscure = false;
  bool loadData = true;
  bool loadButton = false;
  bool checkIp = false;
  bool checkIdTablet = false;
  bool checkIdRoom = false;
  bool isRoom = true;
  bool switchValue = true;

  List dataRooms = [];
  List dataUF = [];
  List<String> dataIntPul = ['Seg','Min','Hrs'];
  String valuePul = 'Seg';
  String idUfHab = '';

  TextEditingController controllerIdTablet = TextEditingController();
  TextEditingController controllerBusiness = TextEditingController();
  TextEditingController controllerRoom = TextEditingController();
  TextEditingController controllerPass = TextEditingController();
  TextEditingController controllerTimeInactivity = TextEditingController();
  TextEditingController controllerIpLampara = TextEditingController();
  TextEditingController controllerIntPulsador = TextEditingController(text: '30');

  TextEditingController controllerUF = TextEditingController();

  String ipDevice = '';

  Map<String,String> getDataIdAzure = {};
  Map<String,int> getDataIdUFHab = {};
  Map<String,int> mapIdHab = {};
  Map<String,int> mapIdUF = {};

  int idOnOff = 0;
  ButtonState stateOnOff = ButtonState.loading;

  String passwordDb = '';

  @override
  void initState() {
    super.initState();
    if(widget.isConfig){ initDataConfig(); }else{ initData(); }
  }

  Future initData()async{
    loadData = true;
    setState(() {});
    passwordDb = await SharedPreferencesClass().getValue('S4CPasswordDB');
    try{
      var response = await ConnectionHttp().httpGetDataCentro();
      if(response.statusCode == 200){
        dataRooms = jsonDecode(response.body);
      }else{
        String errorHttp = 'Error de conexión con el servidor, Posiblemente nombre de Base de Datos incorrecta.';
        showAlert(text: errorHttp,isSuccess: false);
      }
    }catch(e){
      showAlert(text: 'Error: ${e.toString()}',isSuccess: false);
    }

    try{
      var response = await ConnectionHttp().httpGetDataCentroUnidadFuncional();
      if(response.statusCode == 200){
        dataUF = jsonDecode(response.body);
      }else{
        String errorHttp = 'Error de conexión con el servidor, Posiblemente nombre de Base de Datos incorrecta.';
        showAlert(text: errorHttp,isSuccess: false);
      }
    }catch(e){
      showAlert(text: 'Error: ${e.toString()}',isSuccess: false);
    }
    loadData = false;
    setState(() {});
  }

  Future initDataConfig()async{
    loadData = true;
    isRoom = await SharedPreferencesClass().getValue('S4CisRoom') ?? true;
    switchValue = await SharedPreferencesClass().getValue('S4CSwitchValue') ?? true;

    String data = await SharedPreferencesClass().getValue('S4CIntPulsador') ?? '30|Seg|30';
    controllerIntPulsador.text = data.split('|')[2];
    valuePul = data.split('|')[1];

    setState(() {});

    if(isRoom){ checkOnOff(); }

    controllerIdTablet.text = await SharedPreferencesClass().getValue('S4CIdTablet');
    passwordDb = await SharedPreferencesClass().getValue('S4CPasswordDB');

    if(isRoom){
      controllerBusiness.text = await SharedPreferencesClass().getValue('S4CBusiness');
      controllerRoom.text = await SharedPreferencesClass().getValue('S4CRoom');

      try{
        var response = await ConnectionHttp().httpGetDataCentro();
        if(response.statusCode == 200){
          dataRooms = jsonDecode(response.body);
        }else{
          String errorHttp = 'Error de conexión con el servidor, Posiblemente nombre de Base de Datos incorrecta.';
          showAlert(text: errorHttp,isSuccess: false);
        }
      }catch(e){
        showAlert(text: 'Error: ${e.toString()}',isSuccess: false);
      }
    }else{
      controllerUF.text = await SharedPreferencesClass().getValue('S4CRoom');

      try{
        var response = await ConnectionHttp().httpGetDataCentroUnidadFuncional();
        if(response.statusCode == 200){
          dataUF = jsonDecode(response.body);
        }else{
          String errorHttp = 'Error de conexión con el servidor, Posiblemente nombre de Base de Datos incorrecta.';
          showAlert(text: errorHttp,isSuccess: false);
        }
      }catch(e){
        showAlert(text: 'Error: ${e.toString()}',isSuccess: false);
      }
    }

    //int timeInact = await SharedPreferencesClass().getValue('S4CTimeInact') ?? 1200;
    //double segTime = (timeInact / 60);
    controllerTimeInactivity.text = '2';

    try{
      ipDevice = await SharedPreferencesClass().getValue('S4CIpDeviceLampara') ?? '';
      String ip =  ipDevice.split('|')[0];
      controllerIpLampara.text = ip;
    }catch(_){}

    if((isRoom && dataRooms.isEmpty) || !isRoom && dataUF.isEmpty){
      await UpdateDataHttpToSqlLite().getUsersHttp();
      await UpdateDataHttpToSqlLite().getPatientsHttp();
      await UpdateDataHttpToSqlLite().getDataCentro();
      await UpdateDataHttpToSqlLite().getMotivosAlarma();
      await Future.delayed(Duration(seconds: 3));
      initDataConfig();
    }else{
      loadData = false;
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
          !widget.isConfig ? Container() : !isRoom ? Container() : Container(
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
          !widget.isConfig ? SizedBox(height: sizeH * 0.1,) : isRoom ? SizedBox(height: sizeH * 0.05,) : SizedBox(height: sizeH * 0.1,),
          Container(
            child: Text('Configuración de Tablet',style: S4CStyles().stylePrimary(size: sizeH * 0.03,color: S4CColors().colorLoginPageText,fontWeight: FontWeight.bold),),
          ),
          SizedBox(height: sizeH * 0.025,),
          Container(
            width: sizeW,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.isConfig ? Container() : ButtonGeneral(
                  title: 'Habitación',
                  textStyle: S4CStyles().stylePrimary(size: sizeH * 0.028,color: S4CColors().colorLoginPageButtonText,fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  icon: Container(),
                  titlePadding: EdgeInsets.only(left: sizeW * 0.015),
                  height: sizeH * 0.07,
                  width: sizeW * 0.25,
                  backgroundColor: isRoom ? Colors.green : Colors.grey,
                  onPressed: () async {
                    setState(() { isRoom = true; });
                  },
                ),
                widget.isConfig ? Container() : SizedBox(width: sizeW * 0.04,),
                widget.isConfig ? Container() : ButtonGeneral(
                  title: 'Unidad funcional',
                  textStyle: S4CStyles().stylePrimary(size: sizeH * 0.028,color: S4CColors().colorLoginPageButtonText,fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  icon: Container(),
                  titlePadding: EdgeInsets.only(left: sizeW * 0.015),
                  height: sizeH * 0.07,
                  width: sizeW * 0.25,
                  backgroundColor: !isRoom ? Colors.green : Colors.grey,
                  onPressed: (){
                    setState(() { isRoom = false; });
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: sizeH * 0.05,),
          isRoom ? Container(
            margin: EdgeInsets.only(left: sizeW * 0.1,right: sizeW * 0.1),
            width: sizeW,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: columnDerRoom(),
                ),
                Container(width: sizeW * 0.1,),
                Expanded(
                  child: columnIzqRoom(),
                ),
              ],
            ),
          ) :
          Container(
            margin: EdgeInsets.only(left: sizeW * 0.1,right: sizeW * 0.1),
            width: sizeW,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: columnDerMant(),
                ),
                Container(width: sizeW * 0.1,),
                Expanded(
                  child: columnIzqMant(),
                ),
              ],
            ),
          ),
          SizedBox(height: sizeH * 0.03,),
          Container(
            width: sizeW * 0.2,
            child: Text('Contraseña de validación',style: S4CStyles().stylePrimary(size: sizeH * 0.02,color: S4CColors().colorLoginPageText),),
          ),
          SizedBox(height: sizeH * 0.01,),
          Container(
            margin: EdgeInsets.symmetric(horizontal: sizeW * 0.35),
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
          SizedBox(height: sizeH * 0.06,),
          loadButton ?
          Container(
            width: sizeW,
            height: sizeH * 0.08,
            child: Center(
              child: circularProgressColors(widthContainer1: sizeW,widthContainer2: sizeH * 0.05,colorCircular: S4CColors().primary),
            ),
          ) :
          Container(
            width: sizeW,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.isConfig ? Container() : ButtonGeneral(
                  title: 'Seleccionar BB.DD.',
                  textStyle: S4CStyles().stylePrimary(size: sizeH * 0.028,color: S4CColors().colorLoginPageButtonText,fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                  icon: Container(
                    margin: EdgeInsets.only(right: sizeW * 0.015),
                    child: Icon(Icons.arrow_back,color: (idTemplate == 1) ? Colors.black : Colors.white,),
                  ),
                  titlePadding: EdgeInsets.only(left: sizeW * 0.015),
                  height: sizeH * 0.07,
                  width: sizeW * 0.25,
                  backgroundColor: S4CColors().primary,
                  onPressed: () async {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    await Future.delayed(Duration(seconds: 1));
                    await SharedPreferencesClass().setIntValue('S4CInit',1);
                    AuthService auth = Provider.of<AuthService>(widget.contextHome!,listen: false);
                    auth.init();
                  },
                ),
                widget.isConfig ? Container() : SizedBox(width: sizeW * 0.04,),
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
              ],
            ),
          ),
          SizedBox(height: sizeH * 0.1,),
        ],
      ),
    );
  }

  Widget columnDerRoom(){
    List<String> listBusiness = [];
    dataRooms.forEach((business) {
      if(!listBusiness.contains(business['stAlojamiento'])){
        listBusiness.add(business['stAlojamiento']);
      }
    });
    listBusiness.sort((a, b) => a.compareTo(b));
    listBusiness.insert(0, 'Seleccionar Alojamiento');

    List<String> listRooms = [];
    dataRooms.forEach((room) {
      try{
        if(controllerBusiness.text ==  room['stAlojamiento'] && !listRooms.contains(room['stHabitacion']) && (room['idtablet'] == 0 || controllerRoom.text == room['stHabitacion'])){
          listRooms.add(room['stHabitacion']);
          getDataIdAzure['${room['stHabitacion']}|${room['stAlojamiento']}'] = '0';
          getDataIdUFHab['${room['stHabitacion']}|${room['stAlojamiento']}'] = room['iduf'];
          mapIdHab[room['stHabitacion']] = int.parse(room['idHabitacion'].toString());
        }
      }catch(e){
        print(e.toString());
      }
    });
    listRooms.sort((a, b) => a.compareTo(b));
    listRooms.insert(0, 'Seleccionar Habitación');

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          SizedBox(height: sizeH * 0.03,),
          Container(
            width: sizeW * 0.2,
            child: Text('Alojamiento ',style: S4CStyles().stylePrimary(size: sizeH * 0.02,color: S4CColors().colorLoginPageText),),
          ),
          SizedBox(height: sizeH * 0.01,),
          Container(
            child: DropdownGeneric(
              backColor: Colors.transparent,
              onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
              sizeH: sizeH,
              value: controllerBusiness.text.isEmpty ? 'Seleccionar Alojamiento' : controllerBusiness.text,
              onChanged: (String? value) {
                controllerBusiness.text = value!;
                controllerRoom.text = '';
              },
              items: listBusiness.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: sizeH * 0.03,),
          Container(
            width: sizeW * 0.2,
            child: Text('Habitación / Registro',style: S4CStyles().stylePrimary(size: sizeH * 0.02,color: S4CColors().colorLoginPageText),),
          ),
          SizedBox(height: sizeH * 0.01,),
          Container(
            child: DropdownGeneric(
              backColor: Colors.transparent,
              onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
              sizeH: sizeH,
              value: controllerRoom.text.isEmpty ? 'Seleccionar Habitación' : controllerRoom.text,
              onChanged: (String? value) {
                controllerRoom.text = value!;
                checkIdRoom = true;
              },
              items: listRooms.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget columnIzqRoom(){
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: sizeH * 0.02,),
          Container(
            width: sizeW * 0.2,
            child: Text('Ip lampara',style: S4CStyles().stylePrimary(size: sizeH * 0.02,color: S4CColors().colorLoginPageText),),
          ),
          SizedBox(height: sizeH * 0.01,),
          Container(
            child: TextFieldGeneral(
              sizeH: sizeH,sizeW: sizeW,
              prefixIcon: Icon(Icons.network_wifi),
              colorBack: Colors.transparent,
              borderColor: Colors.transparent,
              activeInputBorder: false,
              textInputType: TextInputType.number,
              onChanged: (value){
                setState(() {
                  checkIp = true;
                });
              },
              textEditingController: controllerIpLampara,
              initialValue: null,
            ),
          ),
          !widget.isConfig ? Container() : SizedBox(height: sizeH * 0.03,),
          !widget.isConfig ? Container() : Container(
            width: sizeW * 0.2,
            child: Text('Id de Tablet',style: S4CStyles().stylePrimary(size: sizeH * 0.02,color: S4CColors().colorLoginPageText),),
          ),
          !widget.isConfig ? Container() : SizedBox(height: sizeH * 0.01,),
          !widget.isConfig ? Container() : Container(
            width: sizeW * 0.2,
            child: Text(controllerIdTablet.text,style: S4CStyles().stylePrimary(size: sizeH * 0.02,color: S4CColors().colorLoginPageText,fontWeight: FontWeight.bold),),
          ),
          !widget.isConfig ? Container() : SizedBox(height: sizeH * 0.03,),
          !widget.isConfig ? Container() : Container(
            width: sizeW * 0.3,
            child: Row(
              children: [
                Expanded(
                  child: Text('Mostrar solo imágenes en las tareas',style: S4CStyles().stylePrimary(size: sizeH * 0.02,color: S4CColors().colorLoginPageText),textAlign: TextAlign.left),
                ),
                CupertinoSwitch(
                  value: switchValue,
                  onChanged: (value){
                    switchValue = value;
                    checkIdRoom = true;
                    setState(() {});
                  },
                )
              ],
            ),
          ),
          !widget.isConfig ? Container() : Container(
            width: sizeW * 0.2,
            child: Text('Intervalo de espera para el pulsador',style: S4CStyles().stylePrimary(size: sizeH * 0.02,color: S4CColors().colorLoginPageText),),
          ),
          !widget.isConfig ? Container() : SizedBox(height: sizeH * 0.01,),
          !widget.isConfig ? Container() : containerSetMinPulsador(),

        ],
      ),
    );
  }

  Widget containerSetMinPulsador(){
    return Container(
      width: sizeW * 0.3,
      child: Row(
        children: [
          Container(
            width: sizeW * 0.15,
            child: TextFieldGeneral(
              textEditingController: controllerIntPulsador,
              initialValue: null,
              sizeH: sizeH,sizeW: sizeW,
              prefixIcon: Icon(Icons.timer),
              colorBack: Colors.transparent,
              borderColor: Colors.transparent,
              activeInputBorder: false,
              textInputType: TextInputType.number,
              onChanged: (value){
                setState(() {
                  checkIp = true;
                });
              },
            ),
          ),
          Expanded(
            child: DropdownGeneric(
              backColor: Colors.transparent,
              onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
              sizeH: sizeH,
              value: valuePul,
              onChanged: (String? value) {
                valuePul = value!;
                checkIp = true;
                setState(() {});
              },
              items: dataIntPul.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          )
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

  Future<String> getIpLampara() async{
    String ipData = '';
    String idTablet = await SharedPreferencesClass().getValue('S4CIdTablet') ?? '';
    await DeviceIp().createDeviceIp(ip: controllerIpLampara.text);
    Map<String,dynamic> dataDevice = await getDataDevicesHttp(idTablet: idTablet);
    if(dataDevice.isNotEmpty){
      ipData = '${dataDevice['ip']}|${dataDevice['deviceid']}|${dataDevice['id']}';
    }
    return ipData;
  }

  Widget columnDerMant(){
    List<String> listAllUF = [];

    dataUF.forEach((uf) {
      if((!listAllUF.contains(uf['stunidadfuncional']) && uf['idtablet'] == 0) || (controllerUF.text == uf['stunidadfuncional'])){
        listAllUF.add(uf['stunidadfuncional']);
        mapIdUF[uf['stunidadfuncional']] = uf['idunidadfuncional'];
      }
    });
    listAllUF.sort((a, b) => a.compareTo(b));
    listAllUF.insert(0, 'Seleccionar Unidad Funcional');

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          SizedBox(height: sizeH * 0.03,),
          Container(
            width: sizeW * 0.2,
            child: Text('Unidad funcional ',style: S4CStyles().stylePrimary(size: sizeH * 0.02,color: S4CColors().colorLoginPageText),),
          ),
          SizedBox(height: sizeH * 0.01,),
          Container(
            child: DropdownGeneric(
              backColor: Colors.transparent,
              onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
              sizeH: sizeH,
              value: controllerUF.text.isEmpty ? 'Seleccionar Unidad Funcional' : controllerUF.text,
              onChanged: (String? value) {
                controllerUF.text = value!.contains('Seleccionar Unidad Funcional') ? '' : value;
                checkIdRoom = true;
              },
              items: listAllUF.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: sizeH * 0.1125,),
        ],
      ),
    );
  }

  Widget columnIzqMant(){
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          !widget.isConfig ? Container() : SizedBox(height: sizeH * 0.03,),
          !widget.isConfig ? Container() : Container(
            width: sizeW * 0.2,
            child: Text('Id de Tablet',style: S4CStyles().stylePrimary(size: sizeH * 0.02,color: S4CColors().colorLoginPageText),),
          ),
          !widget.isConfig ? Container() : SizedBox(height: sizeH * 0.01,),
          !widget.isConfig ? Container() : Container(
            width: sizeW * 0.2,
            child: Text(controllerIdTablet.text,style: S4CStyles().stylePrimary(size: sizeH * 0.02,color: S4CColors().colorLoginPageText,fontWeight: FontWeight.bold)),
          ),
          !widget.isConfig ? Container() : SizedBox(height: sizeH * 0.03,),
          !widget.isConfig ? Container() : Container(
            width: sizeW * 0.3,
            child: Row(
              children: [
                Expanded(
                  child: Text('Mostrar solo imágenes en las tareas',style: S4CStyles().stylePrimary(size: sizeH * 0.02,color: S4CColors().colorLoginPageText),textAlign: TextAlign.center),
                ),
                CupertinoSwitch(
                  value: switchValue,
                  onChanged: (value){
                    switchValue = value;
                    checkIdRoom = true;
                    setState(() {});
                  },
                )
              ],
            ),
          ),
          !widget.isConfig ? Container() : Container(
            width: sizeW * 0.2,
            child: Text('Intervalo de espera para el pulsador',style: S4CStyles().stylePrimary(size: sizeH * 0.02,color: S4CColors().colorLoginPageText),),
          ),
          !widget.isConfig ? Container() : SizedBox(height: sizeH * 0.01,),
          !widget.isConfig ? Container() : containerSetMinPulsador(),
        ],
      ),
    );
  }

  Future saveButton() async {
    loadButton = true;
    setState(() {});
    String error = '';

    if(isRoom){
      if(error.isEmpty && controllerBusiness.text.isEmpty){
        error = 'Organización no puede estar vacio';
      }
      if(error.isEmpty && controllerRoom.text.isEmpty){
        error = 'Habitación / Registro no puede estar vacio';
      }
      if(error.isEmpty && controllerPass.text != passwordDb){
        error = 'Contraseña de validación incorrecta';
      }
      if(controllerIpLampara.text.isEmpty){
        error = 'Ip de la Lampara no puede estar vacio';
      }
      if(controllerIntPulsador.text.isEmpty){
        error = 'Intervalo de espera para el pulsador no puede estar vacio';
      }else{
        try{
          int.parse(controllerIntPulsador.text);
        }catch(_){
          error = 'Intervalo de espera para el pulsador debe ser un numero correcto';
        }
      }
    }else{
      if(error.isEmpty && controllerUF.text.isEmpty){
        error = 'Seleccionar Unidad funcional';
      }
    }

    if(passwordDb != controllerPass.text){
      error = 'Contraseña de validación incorrecta';
    }

    if(error.isEmpty){
      try{
        String idTabletGet = '';
        String fkRoom = '';
        if(!widget.isConfig || checkIdRoom){
          String nameDB = await SharedPreferencesClass().getValue('S4CNameDB') ?? '';
          Map<String,dynamic> body = {
            "centro": nameDB,
            "fkhabitacion": isRoom ? mapIdHab[controllerRoom.text] : mapIdUF[controllerUF.text],
            "stip_sonoff": isRoom ? controllerIpLampara.text : '',
            "oldid": 0,
            "bluf" : isRoom ? 0 : 1,
          };

          String fkRoomOld = await SharedPreferencesClass().getValue('S4CIdTablet') ?? '';
          if(fkRoomOld.isNotEmpty){
            body['oldid'] = int.parse(fkRoomOld);
          }

          var response = await ConnectionHttp().httpPostSetConfigTK(body: body);
          var value = jsonDecode(response.body);
          if(response.statusCode == 200){
            idTabletGet = '$value';
            fkRoom = isRoom ? mapIdHab[controllerRoom.text].toString() : mapIdUF[controllerUF.text].toString();
          }else{
            showAlert(text: 'Problemas para enviar la información',isSuccess: false);
          }
        }else{
          idTabletGet = await SharedPreferencesClass().getValue('S4CIdTablet');
          fkRoom = await SharedPreferencesClass().getValue('S4CfkRoom');
        }

        if(idTabletGet.isNotEmpty && fkRoom.isNotEmpty){
          await SharedPreferencesClass().setBoolValue('S4CSwitchValue',switchValue);

          await SharedPreferencesClass().setStringValue('S4CIdTablet',idTabletGet);
          await SharedPreferencesClass().setStringValue('S4CfkRoom',fkRoom);
          await SharedPreferencesClass().setStringValue('S4CRoom', isRoom ? controllerRoom.text : controllerUF.text);
          if(isRoom){
            await SharedPreferencesClass().setStringValue('S4CBusiness',controllerBusiness.text);
            if(getDataIdUFHab.containsKey('${controllerRoom.text}|${controllerBusiness.text}')){
              await SharedPreferencesClass().setStringValue('S4CIdUFHab',getDataIdUFHab['${controllerRoom.text}|${controllerBusiness.text}'].toString());
            }
          }else{
            for(int duf = 0; duf < dataUF.length; duf++){
              if(dataUF[duf]['idunidadfuncional'].toString() == fkRoom && dataUF[duf]['idalojamiento'] != null){
                await SharedPreferencesClass().setStringValue('S4CAlojamientoUF',dataUF[duf]['idalojamiento'].toString());
              }
            }
          }
          await SharedPreferencesClass().setBoolValue('S4CisRoom',isRoom);

          if(checkIp){
            String ipUpdate = '';
            if(widget.isConfig && ipDevice.length > 2){
              await DeviceIp().updateDeviceIp(ip: controllerIpLampara.text, id: ipDevice.split('|')[2]);
              ipUpdate = '${controllerIpLampara.text}|${ipDevice.split('|')[1]}|${ipDevice.split('|')[2]}';
            }else{
              ipUpdate = await getIpLampara();
            }
            await SharedPreferencesClass().setStringValue('S4CIpDeviceLampara',ipUpdate);

            String intP = '30';
            if(valuePul == 'Seg'){ intP = '${int.parse(controllerIntPulsador.text).toStringAsFixed(0)}'; }
            if(valuePul == 'Min'){ intP = '${(int.parse(controllerIntPulsador.text) * 60).toStringAsFixed(0)}'; }
            if(valuePul == 'Hrs'){ intP = '${(int.parse(controllerIntPulsador.text) * 3600).toStringAsFixed(0)}'; }
            await SharedPreferencesClass().setStringValue('S4CIntPulsador','$intP|$valuePul|${controllerIntPulsador.text}');
          }
          if(widget.isConfig){
            Navigator.of(context).pop();
          }else{
            FocusScope.of(context).requestFocus(new FocusNode());
            await Future.delayed(Duration(seconds: 1));
            await SharedPreferencesClass().setIntValue('S4CInit',3);
            AuthService auth = Provider.of<AuthService>(widget.contextHome!,listen: false);
            auth.init();
          }
        }else{
          showAlert(text: 'Problemas para enviar la información',isSuccess: false);
        }
      }catch(e){
        print('saveButton config tablet');
        showAlert(text: 'Problemas para enviar la información',isSuccess: false);
      }
    }else{
      showAlert(text: error,isSuccess: false);
    }


    loadButton = false;
    setState(() {});
  }
}
