import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tra_s4c/config/s4c_colors.dart';
import 'package:tra_s4c/config/s4c_style.dart';
import 'package:tra_s4c/main.dart';
import 'package:tra_s4c/models/user_model.dart';
import 'package:tra_s4c/services/shared_preferences.dart';
import 'package:tra_s4c/services/sqflite.dart';
import 'package:tra_s4c/services/updateDataHttpToSqlflite.dart';
import 'package:tra_s4c/utils/send_data.dart';
import 'package:tra_s4c/views/menu/config/config_page.dart';
import 'package:tra_s4c/views/menu/config/get_password.dart';
import 'package:tra_s4c/views/menu/medicines/medicines_patients.dart';
import 'package:tra_s4c/views/menu/sos/sos_form.dart';
import 'package:tra_s4c/views/menu/sos/sos_page.dart';
import 'package:tra_s4c/views/menu/task/task_patients_hab_mantenimiento.dart';
import 'package:tra_s4c/views/menu/task/task_patients_hab_unid_residents.dart';
import 'package:tra_s4c/views/menu/task/task_patients_unid_mantenimiento_for_rooms.dart';
import 'package:tra_s4c/widgets_utils/DialogAlert.dart';
import 'package:tra_s4c/widgets_utils/avatar_widget.dart';
import 'package:tra_s4c/widgets_utils/textfield_general.dart';
import 'package:tra_s4c/widgets_utils/toast_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{

  bool inOrOut = false;
  Map<String,dynamic> dataUserActive = {};
  UserModel? user;
  StreamSubscription? streamSubscriptionBloc;

  @override
  void initState() {
    super.initState();
    UpdateDataHttpToSqlLite().getAll();
    initialData();
    openForm();
    _initializeBloc();
  }

  Future initialData() async{
    String data = await SharedPreferencesClass().getValue('s4cUserLogin') ?? '';
    if(data.isNotEmpty){
      try{
        dataUserActive = jsonDecode(data);
        Map<String,UserModel> users = await  DatabaseProvider.db.getAllUserMap();
        if(users.containsKey(dataUserActive['fkCodigo'])){
          user = users[dataUserActive['fkCodigo']]!;
          if(user != null && user!.stFoto != null){
            dataUserActive['stFoto'] = user!.stFoto;
            String data = jsonEncode(dataUserActive);
            await SharedPreferencesClass().setStringValue('s4cUserLogin', data);
          }
        }
        setState(() {});
      }catch(_){}
    }
  }

  Future openForm() async{
    await Future.delayed(Duration(seconds: 2));
    if(isOpenSosForm){
      await Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new SosForm()));
      isOpenSosForm = false;
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscriptionBloc?.cancel();
    SharedPreferencesClass().setStringValue('s4cLoginBeaconsPos', '0|0|0');
    SharedPreferencesClass().setIntValue('s4cIsWelcome',0);
    isOpenSosForm = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Scaffold(
        backgroundColor: S4CColors().colorLoginPageBack,
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

  Widget contentsHome(){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: sizeW * 0.07,
          height: sizeH,
          margin: EdgeInsets.symmetric(horizontal: sizeW * 0.015,vertical: sizeH * 0.03),
          decoration: BoxDecoration(
            color: S4CColors().primary,
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          child: menu(),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(top: sizeW * 0.03),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(height: sizeH * 0.02,),
                  Container(
                    margin: EdgeInsets.only(left: sizeW * 0.01),
                    height: sizeH * 0.06,
                    width: sizeH * 0.25,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: Image.asset("assets/image/logo_lock.png").image,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget menu(){

    Widget imageUser = Container(
      child: CircleAvatar(
        radius: sizeH * 0.045,
        backgroundColor: Colors.white,
        child: Center(
          child: Icon(Icons.person_rounded,size: sizeH * 0.055,color: S4CColors().primary,),
        ),
      ),
    );
    if(user != null){
      imageUser = CircleAvatar(
        radius: sizeH * 0.045,
        backgroundColor: S4CColors().primary,
        child: avatarCircularNet(rutaImage: user!.stFoto!,radiu: sizeH * 0.055),
      );
    }
    
    bool isAdmin = false;
    if(dataUserActive.containsKey('bladmintk') && dataUserActive['bladmintk'] == 1){
      isAdmin = true;
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: sizeH * 0.01,),
          imageUser,
          SizedBox(height: sizeH * 0.04,),
          iconMenu(type: 1),
          iconMenu(type: 2),
          iconMenu(type: 3),
          iconMenu(type: 4),
          iconMenu(type: 5),
          SizedBox(height: sizeH * 0.1,),
          iconMenu(type: 6),
          if(isAdmin )...[
            iconMenu(type: 7),
          ]
        ],
      ),
    );
  }

  Widget iconMenu({required int type}){
    String path = 'icon_menu_$type${idTemplate != 1 ? '' : '_black'}';
    return InkWell(
      onTap: () async {
        if(type == 1){
          bool isRoom = await SharedPreferencesClass().getValue('S4CisRoom') ?? true;
          if(isRoom) {
            await Navigator.push(context,new MaterialPageRoute(builder: (BuildContext context) => new SOSPage(isBLockWellcome: false,)));
            await SharedPreferencesClass().setIntValue('stSos', 0);
          }else{
            await setCorrelativo();
            showAlert(text: 'Alerta enviada');
          }
        }
        if(type == 2){
          bool isRoom = await SharedPreferencesClass().getValue('S4CisRoom') ?? true;
          bool boolMant = dataUserActive['blmant'] == 1 ;
          bool boolCuid = dataUserActive['blcuidados'] == 1 ;
          if(boolMant && boolCuid){
            bool? res = await alertDialogGeneral(context: context);
            if(res != null){
              if(res){
                if(isRoom){
                  //HABITACION MANTENIMIENTO
                  await Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new TaskPatientHabScheduled()));
                }else{
                  //UNIDAD FUNCIONAL MANTENIMIENTO
                  await Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new TaskUnitForRooms()));
                }
              }else{
                //HABITACION Y UNIDAD RESIDENTES
                await Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new TaskPatientHabUnidResidents()));
              }
            }
          }else{
            if(!boolMant && boolCuid){
              await Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new TaskPatientHabUnidResidents()));
            }
            if(boolMant && !boolCuid){
              if(isRoom){
                await Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new TaskPatientHabScheduled()));
              }else{
                await Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new TaskUnitForRooms()));
              }
            }
          }
        }
        if(type == 3){
          await Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new MedicinesPatient()));
        }
        if(type == 7){
          Map? res = await Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new GetPass()));
          if(res != null && res.containsKey('user')){
            await Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new ConfigPage(superUser: res['user'] == 1)));
            setState(() {});
          }
        }
      },
      focusColor: S4CColors().colorHomeSplashMenu,
      splashColor: S4CColors().colorHomeSplashMenu,
      hoverColor: S4CColors().colorHomeSplashMenu,
      highlightColor: S4CColors().colorHomeSplashMenu,
      child: Container(
        width: sizeW * 0.06,
        height: sizeH * 0.08,
        padding: EdgeInsets.all(sizeH * 0.012),
        child: Container(
          height: sizeH * 0.07,
          width: sizeH * 0.07,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Image.asset("assets/image/$path.png").image,
              fit: BoxFit.contain,
            ),
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
          InkWell(
            child: Container(
              //margin: EdgeInsets.only(left: sizeW * 0.02),
              padding: EdgeInsets.symmetric(horizontal: sizeW * 0.015,vertical: sizeH * 0.015),
              child: Icon(Icons.menu,size: sizeH * 0.035,color: S4CColors().primary,),
            ),
            onTap: (){
              if(inOrOut){

              }else{

              }
              inOrOut = !inOrOut;
              setState(() {});
            },
          ),
          Container(
            margin: EdgeInsets.only(bottom: sizeH * 0.01),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.only(left: sizeW * 0.01),
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
          Expanded(
            child: Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.search,size: sizeH * 0.035,color: S4CColors().primary,),
                    onPressed: (){},
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: sizeW * 0.02),
                    width: sizeW * 0.35,height: sizeH * 0.05,
                    child: TextFieldGeneral(
                      sizeW: sizeW * 0.3,sizeH: sizeH * 0.03,
                      radius: 25,
                      colorBack: S4CColors().colorHomeButtonSearch,
                      hintText: 'Buscar',
                      padding: EdgeInsets.symmetric(horizontal: sizeW * 0.04),
                      labelStyle: S4CStyles().stylePrimary(size: sizeH * 0.025),
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            splashColor: S4CColors().primary,
            focusColor: S4CColors().primary,
            onTap: (){},
            child: Container(
              height: sizeH * 0.05,
              width: sizeH * 0.05,
              margin: EdgeInsets.only(right: sizeW * 0.02),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Image.asset("assets/image/notification_button${idTemplate == 0 ? '' : '_black'}.png").image,
                  fit: BoxFit.contain,
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

  void _initializeBloc(){
    try {
      // ignore: cancel_subscriptions
      streamSubscriptionBloc = blocData.outList.listen((newVal) async {
        if(newVal.containsKey('refreshUserServer') && newVal['refreshUserServer']){
          initialData();
        }
      });
    } catch (e) {}
  }
}
