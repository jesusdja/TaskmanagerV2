import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:tra_s4c/config/s4c_colors.dart';
import 'package:tra_s4c/config/s4c_style.dart';
import 'package:tra_s4c/main.dart';
import 'package:tra_s4c/models/patient_model.dart';
import 'package:tra_s4c/services/http_connection.dart';
import 'package:tra_s4c/services/shared_preferences.dart';
import 'package:tra_s4c/services/sqflite.dart';
import 'package:tra_s4c/widgets_utils/avatar_widget.dart';
import 'package:tra_s4c/widgets_utils/circular_progress_colors.dart';
import 'package:tra_s4c/widgets_utils/toast_widget.dart';

class MedicinesPatient extends StatefulWidget {
  @override
  _MedicinesPatientState createState() => _MedicinesPatientState();
}

class _MedicinesPatientState extends State<MedicinesPatient>{

  bool loadData = true;
  ButtonState sendDataBool = ButtonState.idle;
  int patientsSelected = 0;
  Map<String,dynamic> dataUserActive = {};
  List<PatientModel> patients = [];
  TextStyle style1 = TextStyle();

  Map<String,bool> buttonsStates = {};

  Map<int,List> dataPastilleroPacientes = {};

  @override
  void initState() {
    super.initState();
    getDataInitial();
  }

  Future getDataInitial() async{
    try{
      String data = await SharedPreferencesClass().getValue('s4cUserLogin') ?? '';
      dataUserActive = jsonDecode(data);
    }catch(e){
      print('initialData: ${e.toString()}');
    }

    patients = await DatabaseProvider.db.getAllPatient();
    if(patients.isNotEmpty){ patientsSelected =  patients[0].idasis!; }
    setState(() {});

    initialData();
  }

  Future initialData() async {

    sendDataBool = ButtonState.idle;
    loadData = true;
    buttonsStates = {};
    dataPastilleroPacientes = {};
    setState(() {});

    try{
      Response? response = await ConnectionHttp().httpGetPastilleroTK(idAsis: patientsSelected,idUser: dataUserActive['idUsuario'].toString());
      if(response != null && response.statusCode == 200){
        List value = jsonDecode(response.body);
        dataPastilleroPacientes[patientsSelected] = await orderListDate(value.length,jsonDecode(response.body));
        for(int xx = 0; xx < value.length; xx++){
          buttonsStates['$patientsSelected-${value[xx]['ID']}-${value[xx]['NumFila']}'] = false;
        }
      }else{
        showAlert(text: 'Error para cargar tareas asignadas',isSuccess: false);
      }
    }catch(e){
      print('Error: ${e.toString()}');
      showAlert(text: 'Error de conexión con el servidor',isSuccess: false);
    }

    if(mounted){
      setState(() {
        loadData = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    style1 = S4CStyles().stylePrimary(size: sizeH * 0.017,color: Colors.grey);

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            appBarWidget(),
            Expanded(
              child: contentsHome(),
            )
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
                  margin: EdgeInsets.only(left: sizeW * 0.02),
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

  Widget contentsHome(){
    return Container(
      width: sizeW,
      child: Row(
        children: [
          Expanded(child: menuDer()),
        ],
      ),
    );
  }

  Widget menuDer(){
    return Container(
      width: sizeW,
      color: S4CColors().colorLoginPageBack,
      child: Column(
        children: [
          menuDerTop(),
          Expanded(child: menuDer1())
        ],
      ),
    );
  }

  Widget menuDerTop(){

    List<Widget> listW = [];
    for(int x = 0; x < patients.length; x++){
      listW.add(containerPatientTop(patientModel: patients[x]));
    }

    return Container(
      width: sizeW,
      padding: EdgeInsets.symmetric(vertical: sizeH * 0.01,horizontal: sizeW * 0.025),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: listW,
              ),
            ),
          ),
          buttonSendAll(),
        ],
      ),
    );
  }

  Widget containerPatientTop({required PatientModel patientModel}){
    String name = '';
    if(patientModel.nombre != null && patientModel.nombre!.isNotEmpty){
      name = patientModel.nombre!;
    }else{
      return Container();
    }

    Widget imageUser = Container(
      child: CircleAvatar(
        radius: sizeH * 0.03,
        backgroundColor: S4CColors().primary,
        child: CircleAvatar(
          radius: sizeH * 0.03,
          backgroundColor: S4CColors().primary,
          child: Center(
            child: Icon(Icons.person_rounded,size: sizeH * 0.028,color: Colors.white,),
          ),
        ),
      ),
    );
    if(patientModel.foto != null && patientModel.foto!.isNotEmpty){
      imageUser = CircleAvatar(
        radius: sizeH * 0.03,
        backgroundColor: S4CColors().primary,
        child: avatarCircularNet(rutaImage: patientModel.foto!,radiu: sizeH * 0.028),
      );
    }

    return InkWell(
      onTap: (){
        if(patientsSelected != patientModel.idasis!){
          patientsSelected = patientModel.idasis!;
          setState(() {});
          initialData();
        }
      },
      child: Container(
        margin: EdgeInsets.only(right: sizeW * 0.02),
        padding: EdgeInsets.symmetric(vertical: sizeH * 0.01,horizontal: sizeW * 0.005),
        decoration: BoxDecoration(
          color: patientsSelected == patientModel.idasis! ? S4CColors().colorLoginPageBack : Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          border: Border.all(
            color : S4CColors().colorLoginPageBack,
            width : 1.0,
            style : BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            imageUser,
            SizedBox(width: sizeW * 0.01,),
            Text(name,style: S4CStyles().stylePrimary(size: sizeH * 0.02,color: Colors.black87),)
          ],
        ),
      ),
    );
  }

  Widget menuDer1(){
    return loadData ?
    Center(
      child: circularProgressColors(widthContainer1: sizeW,widthContainer2: sizeH * 0.1,colorCircular: S4CColors().primary),
    ) : menuDer1Container();
  }

  Widget menuDer1Container(){

    List listData = dataPastilleroPacientes[patientsSelected] ?? [];

    return listData.isEmpty ?
    Container(
      height: double.infinity,width: double.infinity,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off,size: sizeH * 0.18,color: S4CColors().primary,),
            Text('No se encontro resultado',style: S4CStyles().stylePrimary(size: sizeH * 0.028,color: S4CColors().primary,fontWeight: FontWeight.bold),)
          ],
        ),
      ),
    )
    : SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        child: Column(
          children: listData.map((medicamento){
            return containerMedicamento(medicamento: medicamento);
          }).toList(),
        ),
      ),
    );
  }

  Widget containerMedicamento({required Map<String,dynamic> medicamento}){
    return Card(
      margin: EdgeInsets.only(left: 5,right: 5,top: 10),
      child: Container(
        width: sizeW,
        padding: EdgeInsets.symmetric(horizontal: sizeW * 0.02,vertical: sizeH * 0.01),
        child: Row(
          children: [
            textCard(title: 'Fecha',subTitle: '${medicamento['Dia']} ${medicamento['Hora']}',flex: 2),
            textCard(title: 'Cantidad',subTitle: '${medicamento['Cantidad']}'),
            textCard(title: 'Farmaco',subTitle: '${medicamento['Farmaco']}',flex: 3),
            textCard(title: 'Observaciones',subTitle: '${medicamento['Observaciones']}',flex: 3),
            buttonSend(medicamento: medicamento),
          ],
        ),
      ),
    );
  }

  Widget textCard({required String title, required String subTitle, int flex = 1}){
    return Expanded(
      flex: flex,
      child: Column(
        children: [
          Text(title,style: S4CStyles().stylePrimary(size: sizeH * 0.025,color: S4CColors().primary, fontWeight: FontWeight.bold)),
          SizedBox(height: sizeH * 0.02,),
          Text(subTitle,style: S4CStyles().stylePrimary(size: sizeH * 0.02,color: S4CColors().primary)),
        ],
      ),
    );
  }

  Widget buttonSend({required Map<String,dynamic> medicamento}){
    
    if(medicamento.containsKey('Administrada') && medicamento['Administrada'] == 1){
      return containerAdmin();
    }
    

    bool active = true;
    DateTime dateElement = DateTime.now();
    try{
      List dataDate = medicamento['Dia'].toString().split('/');
      dateElement = DateTime.parse('${dataDate[2]}-${dataDate[1]}-${dataDate[0]} ${medicamento['Hora']}');
      if(DateTime.now().difference(dateElement).inMinutes < 0){
        active = false;
      }
    }catch(_){}

    TextStyle style = S4CStyles().stylePrimary(size: sizeH * 0.022,color: Colors.white, fontWeight: FontWeight.bold);

    return Container(
      width: sizeW * 0.14,
      height: sizeH * 0.06,
      child: ProgressButton(
        progressIndicatorSize: sizeH * 0.025,
        padding: EdgeInsets.symmetric(horizontal: sizeW * 0.02),
        stateWidgets: {
          ButtonState.idle: Text(active ? "Enviar" : "Fuera de Hora",style: style),
          ButtonState.loading: Text("Enviando...",style: style,),
          ButtonState.fail: Text("Marcar",style: style),
          ButtonState.success: Text("Por enviar",style: style,)
        },
        stateColors: {
          ButtonState.idle: active ? S4CColors().primary : Colors.grey.shade400,
          ButtonState.loading: Colors.blue.shade300,
          ButtonState.fail: Colors.red.shade300,
          ButtonState.success: Colors.green.shade400,
        },
        onPressed: () async{
          if(active){
            buttonsStates['$patientsSelected-${medicamento['ID']}-${medicamento['NumFila']}'] = !buttonsStates['$patientsSelected-${medicamento['ID']}-${medicamento['NumFila']}']!;
            setState(() {});
          }
        },
        state: (sendDataBool != ButtonState.idle && buttonsStates['$patientsSelected-${medicamento['ID']}-${medicamento['NumFila']}']!) ? ButtonState.loading :
        active ? buttonsStates['$patientsSelected-${medicamento['ID']}-${medicamento['NumFila']}']! ? ButtonState.success : ButtonState.fail :
        ButtonState.idle,
      ),
    );
  }

  Widget containerAdmin(){
    TextStyle style = S4CStyles().stylePrimary(size: sizeH * 0.022,color: Colors.white, fontWeight: FontWeight.bold);
    return Container(
      width: sizeW * 0.14,
      height: sizeH * 0.06,
      child: ProgressButton(
        progressIndicatorSize: sizeH * 0.025,
        padding: EdgeInsets.symmetric(horizontal: sizeW * 0.02),
        stateWidgets: {
          ButtonState.idle: Text("Fuera de Hora",style: style),
          ButtonState.loading: Text("Enviando...",style: style,),
          ButtonState.fail: Text("Marcar",style: style),
          ButtonState.success: Text("Administrada",style: style,)
        },
        stateColors: {
          ButtonState.idle: S4CColors().primary,
          ButtonState.loading: Colors.blue.shade300,
          ButtonState.fail: Colors.red.shade300,
          ButtonState.success: Colors.green.shade400,
        },
        onPressed: (){},
        state: ButtonState.success,
      ),
    );
  }

  Future<List> orderListDate(int length,List listAuxOld,) async{
    List listNew = [];
    try{
      for(int x = 0; x < length; x++){
        int posDelete = 0;
        DateTime? dateAdd;
        for(int y = 0; y < listAuxOld.length; y++){
          DateTime dateElement = DateTime.now();
          List dataDate = listAuxOld[y]['Dia'].toString().split('/');
          dateElement = DateTime.parse('${dataDate[2]}-${dataDate[1]}-${dataDate[0]} ${listAuxOld[y]['Hora']}');

          if(dateAdd == null){
            dateAdd = dateElement;
          }else{
            List dataDate = listAuxOld[y]['Dia'].toString().split('/');
            DateTime date2 = DateTime.parse('${dataDate[2]}-${dataDate[1]}-${dataDate[0]} ${listAuxOld[y]['Hora']}');
            if(dateAdd.difference(date2).inMinutes > 0){
              dateAdd = date2;
              posDelete = y;
            }
          }
        }
        listNew.add(listAuxOld[posDelete]);
        listAuxOld.removeAt(posDelete);
      }
    }catch(_){}
    return listNew;
  }

  Widget buttonSendAll(){

    TextStyle style = S4CStyles().stylePrimary(size: sizeH * 0.022,color: Colors.white, fontWeight: FontWeight.bold);

    return Container(
      width: sizeW * 0.14,
      height: sizeH * 0.06,
      child: ProgressButton(
        progressIndicatorSize: sizeH * 0.025,
        padding: EdgeInsets.symmetric(horizontal: sizeW * 0.02),
        stateWidgets: {
          ButtonState.idle: Text("Enviar",style: style),
          ButtonState.loading: Text("Enviando...",style: style,),
          ButtonState.fail: Text("Error",style: style),
          ButtonState.success: Text("Enviado",style: style,)
        },
        stateColors: {
          ButtonState.idle: Colors.blue.shade300,
          ButtonState.loading: Colors.blue.shade300,
          ButtonState.fail: Colors.red.shade300,
          ButtonState.success: Colors.green.shade400,
        },
        onPressed: () async{
          String numFil = '';
          buttonsStates.forEach((key, value) {
            List dataKey = key.toString().split('-');
            if(patientsSelected.toString() == dataKey[0] && value){
              if(numFil.isEmpty){
                numFil = dataKey[2];
              }else{
                numFil = '$numFil,${dataKey[2]}';
              }
            }
          });

          if(numFil.isNotEmpty){

            sendDataBool = ButtonState.loading;
            setState(() {});

            try{
              Response? response = await ConnectionHttp().httpSetPastilleroTK(idAsis: dataUserActive['idUsuario'].toString(),numFil: numFil);
              if(response != null && response.statusCode == 200){
                var value = jsonDecode(response.body);
                if(value.toString() == '1'){
                  sendDataBool = ButtonState.success;
                  await Future.delayed(Duration(seconds: 1));
                  initialData();
                }else{
                  sendDataBool = ButtonState.fail;
                }
              }else{
                sendDataBool = ButtonState.fail;
              }
            }catch(e){
              print('Error: ${e.toString()}');
              sendDataBool = ButtonState.fail;
            }
            setState(() {});
          }else{
            showAlert(text: 'Debe marcar al menos una fila',isSuccess: false);
          }


        },
        state: sendDataBool,
      ),
    );
  }
}


