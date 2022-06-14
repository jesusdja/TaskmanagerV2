import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tra_s4c/config/s4c_colors.dart';
import 'package:tra_s4c/config/s4c_style.dart';
import 'package:tra_s4c/main.dart';
import 'package:tra_s4c/models/motivo_model.dart';
import 'package:tra_s4c/services/http_connection.dart';
import 'package:tra_s4c/services/shared_preferences.dart';
import 'package:tra_s4c/services/sqflite.dart';
import 'package:tra_s4c/utils/send_data.dart';
import 'package:tra_s4c/widgets_utils/button_general.dart';
import 'package:tra_s4c/widgets_utils/circular_progress_colors.dart';
import 'package:tra_s4c/widgets_utils/dropdownButton_generic.dart';
import 'package:tra_s4c/widgets_utils/textfield_general.dart';
import 'package:tra_s4c/widgets_utils/toast_widget.dart';

class SosForm extends StatefulWidget {
  @override
  _SosFormState createState() => _SosFormState();
}

class _SosFormState extends State<SosForm> {

  bool obscure = false;
  bool loadSaveButton = false;
  TextEditingController controllerId = TextEditingController();
  TextEditingController controllerSee = TextEditingController();
  TimeOfDay? timeOfDay;
  DateTime? dateSelected;
  bool loadData = false;
  List<String> listMotivos = ['Seleccionar motivo'];
  String motivoSelect = 'Seleccionar motivo';
  Map<String,int> mapMotivos = {};
  List<String> listState = ['Atendido','No atendido'];
  String stateSelect = 'Atendido';

  Map<String,dynamic> dataUserActive = {};
  String idEmpleado = '';

  @override
  void initState() {
    super.initState();
    initialData();
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  Future initialData() async {

    List<MotivoModel?> listMotivosAux = await DatabaseProvider.db.getAllMotivo();
    listMotivosAux.forEach((element) {
      listMotivos.add(element!.stMotivoAlarma!);
      mapMotivos[element.stMotivoAlarma!] = element.idMotivoAlarma!;
    });

    try{
      String data = await SharedPreferencesClass().getValue('s4cUserLogin');
      dataUserActive = jsonDecode(data);
      idEmpleado = '${dataUserActive['stNombre']} - ${dataUserActive['fkEmpleado']}';
    }catch(e){
      print('initialData: ${e.toString()}');
    }
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
      SystemUiOverlay.bottom,SystemUiOverlay.top
    ]);
  }

  Future<bool> exit() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: exit,
      child: GestureDetector(
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
      ),
    );
  }

  Widget imageButtonLogin(){
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: sizeW * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: sizeH * 0.05,),
            Container(
              child: Text('Completar datos',style: S4CStyles().stylePrimary(size: sizeH * 0.04,color: S4CColors().colorLoginPageText,fontWeight: FontWeight.bold),),
            ),
            SizedBox(height: sizeH * 0.08,),
            Container(
              width: sizeW,
              child: Row(
                children: [
                  Expanded( child: widget1(controller: controllerId, title: 'Id Empleado'),),
                  Expanded(child: widget2(title: 'Fecha de atención'),),
                  Expanded(child: widget3(title: 'Hora de atención'),),
                ],
              ),
            ),
            SizedBox(height: sizeH * 0.08,),
            Container(
              width: sizeW,
              child: Row(
                children: [
                  Expanded( child: widget5(title: 'Estado',type: 2, listSt: listState),),
                  Expanded( child: widget5(title: 'Motivo',type: 1, listSt: listMotivos),),
                  Expanded(child: Container(),),
                ],
              ),
            ),
            SizedBox(height: sizeH * 0.08,),
            widget4(title: 'Observaciones',controller: controllerSee),
            SizedBox(height: sizeH * 0.1,),
            loadSaveButton ?
            Center(
              child: circularProgressColors(widthContainer1: sizeW,widthContainer2: sizeH * 0.08,colorCircular: S4CColors().primary),
            )
                :
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
        ],
      ),
    );
  }

  //TEXT
  Widget widget1({required TextEditingController controller, required String title}){
    return Container(
      child: Column(
        children: [
          Container(
            width: sizeW ,
            child: Text(title,style: S4CStyles().stylePrimary(size: sizeH * 0.03,color: Colors.grey, fontWeight: FontWeight.bold),textAlign: TextAlign.left,),
          ),
          SizedBox(height: sizeH * 0.02,),
          Container(
            width: sizeW ,
            child: Text(idEmpleado,style: S4CStyles().stylePrimary(size: sizeH * 0.03,color: Colors.grey, fontWeight: FontWeight.bold),textAlign: TextAlign.left,),
          ),
          // Container(
          //   child: TextFieldGeneral(
          //     constraints: BoxConstraints(maxHeight: sizeH * 0.06,minHeight: sizeH * 0.02),
          //     labelStyle: S4CStyles().stylePrimary(size: sizeH * 0.025,color: Colors.grey, fontWeight: FontWeight.bold),
          //     sizeHeight: sizeH * 0.02,
          //     maxLines: null,
          //     sizeH: sizeH,
          //     sizeW: sizeW,
          //     colorBack: Colors.transparent,
          //     borderColor: Colors.transparent,
          //     activeInputBorder: true,
          //     textInputType: TextInputType.name,
          //     textEditingController: controller,
          //     initialValue: null,
          //   ),
          // ),
          // Container(
          //   width: sizeW,height: 2,
          //   color: Colors.grey,
          // )
        ],
      ),
    );
  }

  //FECHA
  Widget widget2({required String title}){

    // String date = dateSelected == null ? 'Agregar' :
    // '${dateSelected!.day.toString().padLeft(2,'0')}/${dateSelected!.month.toString().padLeft(2,'0')}/${dateSelected!.year}';

    String date = '${DateTime.now().day.toString().padLeft(2,'0')}/${DateTime.now().month.toString().padLeft(2,'0')}/${DateTime.now().year}';

    return Container(
      width: sizeW,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: sizeW,
            child: Text(title,style: S4CStyles().stylePrimary(size: sizeH * 0.03,color: Colors.grey, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
          ),
          SizedBox(height: sizeH * 0.03,),
          InkWell(
            child: Container(
              child: Text(date,style: S4CStyles().stylePrimary(size: sizeH * 0.025,color: Colors.grey,fontWeight: FontWeight.bold),textAlign: TextAlign.right,),
            ),
            onTap: (){
              // showDatePicker(
              //     context: context,
              //     initialDate: dateSelected == null ? DateTime.now() : dateSelected!,
              //     firstDate: DateTime(DateTime.now().year - 100),
              //     lastDate: DateTime(DateTime.now().year + 1))
              //     .then((value) {
              //   if(value != null){
              //     setState(() {
              //       dateSelected = value;
              //     });
              //   }
              // });
            },
          ),
        ],
      ),
    );
  }

  //HORA
  Widget widget3({required String title}){

    // String time = timeOfDay == null ? 'Agregar' :
    // '${timeOfDay!.hour.toString().padLeft(2,'0')}:${timeOfDay!.minute.toString().padLeft(2,'0')}';

    String time = '${DateTime.now().hour.toString().padLeft(2,'0')}:${DateTime.now().minute.toString().padLeft(2,'0')}';

    return Container(
      width: sizeW,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: sizeW,
            child: Text(title,style: S4CStyles().stylePrimary(size: sizeH * 0.03,color: Colors.grey, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
          ),
          SizedBox(height: sizeH * 0.03,),
          InkWell(
            child: Container(
              child: Text(time,style: S4CStyles().stylePrimary(size: sizeH * 0.025,color: Colors.grey,fontWeight: FontWeight.bold),textAlign: TextAlign.right,),
            ),
            onTap: () async {
              // TimeOfDay? timeOfDay2 = await showTimePicker(
              //   context: context,
              //   initialTime: timeOfDay ?? TimeOfDay.now(),
              // );
              // if(timeOfDay2 != null){
              //   timeOfDay = timeOfDay2;
              //   setState(() {});
              // }
            },
          ),
        ],
      ),
    );
  }

  //SELECCION
  Widget widget5({required String title, required List<String> listSt, required int type}){

    String selectSt = '';
    if(type == 1){ selectSt = motivoSelect; }
    if(type == 2){ selectSt = stateSelect; }

    return Container(
      width: sizeW,
      child: Column(
        children: [
          Container(
            width: sizeW,
            child: Text(title,style: S4CStyles().stylePrimary(size: sizeH * 0.03,color: Colors.grey, fontWeight: FontWeight.bold),textAlign: TextAlign.left,),
          ),
          SizedBox(height: sizeH * 0.03,),
          Container(
            margin: EdgeInsets.only(right: sizeW * 0.05),
            decoration: BoxDecoration(
              color: S4CColors().colorLoginPageBack,
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            child: DropdownGeneric(
              backColor: Colors.transparent,
              onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
              sizeH: sizeH,
              value: selectSt,
              onChanged: (String? value) {
                if(type == 1){ motivoSelect = value!; }
                if(type == 2){ stateSelect = value!; }
                setState(() {});
              },
              items: listSt.map<DropdownMenuItem<String>>((String value) {
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

  //TEXT LONG
  Widget widget4({required TextEditingController controller, required String title}){
    return Container(
      child: Column(
        children: [
          Container(
            width: sizeW ,
            child: Text(title,style: S4CStyles().stylePrimary(size: sizeH * 0.03,color: Colors.grey, fontWeight: FontWeight.bold),textAlign: TextAlign.left,),
          ),
          Container(
            child: TextFieldGeneral(
              constraints: BoxConstraints(maxHeight: sizeH * 0.06,minHeight: sizeH * 0.02),
              labelStyle: S4CStyles().stylePrimary(size: sizeH * 0.025,color: Colors.grey, fontWeight: FontWeight.bold),
              sizeHeight: sizeH * 0.02,
              maxLines: null,
              sizeH: sizeH,
              sizeW: sizeW,
              colorBack: Colors.transparent,
              borderColor: Colors.transparent,
              activeInputBorder: true,
              textInputType: TextInputType.name,
              textEditingController: controller,
              initialValue: null,
            ),
          ),
          Container(
            width: sizeW,height: 2,
            color: Colors.grey,
          )
        ],
      ),
    );
  }

  Future saveButton() async {

    loadSaveButton = true;
    setState(() {});

    String error = '';
    if(motivoSelect == 'Seleccionar motivo'){
      error = 'Seleccionar motivo';
    }
    if(error.isEmpty){
      String nameDB = await SharedPreferencesClass().getValue('S4CNameDB') ?? '';
      String idUser = await SharedPreferencesClass().getValue('S4CIdTablet') ?? '';
      int correlativo = await SharedPreferencesClass().getValue('S4CSosId');

      try{
        Map<String,dynamic> body = {
          "centro": nameDB,
          "fxresolucion":"\/Date(${DateTime.now().millisecondsSinceEpoch}+0200)\/",
          "stestado": stateSelect,
          "fkmotivo": mapMotivos[motivoSelect],
          "idempleado": dataUserActive['fkEmpleado'],
          "fkalarmatk": '$idUser$correlativo',
          "stobservaciones": controllerSee.text,
        };
        var response = await ConnectionHttp().httpPostFormSos(body: body);
        var value = jsonDecode(response.body);
        if(value){
          await sendToUser(type: 5,texto: controllerSee.text, idtk: correlativo);
          await SharedPreferencesClass().deleteValue('s4cUserAlertSt');
          Navigator.of(context).pop();
        }else{
          showAlert(text: 'Error al enviar la data',isSuccess: false);
        }
      }catch(e){
        print('saveButtonSosFomr: ${e.toString()}');
        showAlert(text: 'Error al enviar la data',isSuccess: false);
      }
    }else{
      showAlert(text: error,isSuccess: false);
    }
    loadSaveButton = false;
    setState(() {});
  }
}
