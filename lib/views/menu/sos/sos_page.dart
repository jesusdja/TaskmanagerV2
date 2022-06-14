import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tra_s4c/config/s4c_style.dart';
import 'package:tra_s4c/main.dart';
import 'package:tra_s4c/services/shared_preferences.dart';
import 'package:tra_s4c/utils/get_data.dart';
import 'package:tra_s4c/utils/send_data.dart';
import 'package:tra_s4c/views/login/login_page.dart';
import 'package:tra_s4c/views/login/qr_active.dart';
import 'package:tra_s4c/views/login/sensor_search.dart';
import 'package:tra_s4c/views/menu/sos/sos_form.dart';
import 'package:tra_s4c/widgets_utils/button_general.dart';
import 'package:vibration/vibration.dart';

class SOSPage extends StatefulWidget {
  SOSPage({required this.isBLockWellcome});
  final bool isBLockWellcome;
  @override
  _SOSPageState createState() => _SOSPageState();
}

class _SOSPageState extends State<SOSPage>{

  String room = '';
  String idTablet = '';
  bool alert = false;
  StreamSubscription? streamSubscriptionBloc;

  @override
  void initState() {
    super.initState();
    initData();
    initAlert();
    initVibrate();
    _initializeBloc();
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  Future initData() async {
    await SharedPreferencesClass().setIntValue('stSos', 1);
    room = await SharedPreferencesClass().getValue('S4CRoom');
    idTablet = await SharedPreferencesClass().getValue('S4CIdTablet');
    setState(() {});

    lamparaOn(0);
    setCorrelativo();
  }

  Future initVibrate()async{
    bool? vi = await Vibration.hasVibrator();
    if (vi != null && vi && mounted) {
      await Vibration.vibrate(duration: 400,amplitude: 200);
      await Future.delayed(Duration(milliseconds: 1000));
      initVibrate();
    }
  }

  Future initAlert()async{
    await Future.delayed(Duration(milliseconds: 200));
    alert = !alert;
    if(mounted){
      setState(() {});
      initAlert();
    }
  }

  @override
  void dispose() {
    super.dispose();
    //activeCentral(0);
    lamparaOn(1);
    Vibration?.cancel();
    streamSubscriptionBloc?.cancel();

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
          backgroundColor: alert ? Colors.white : Colors.redAccent,
          body: Column(
            children: [
              appBarWidget(),
              Expanded(
                child: contentsHome(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget contentsHome(){
    return Container(
      margin: EdgeInsets.only(top: sizeW * 0.03),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(height: sizeH * 0.05,),
            Container(
              margin: EdgeInsets.symmetric(vertical: sizeH * 0.01),
              child: Container(
                height: sizeH * 0.3,
                width: sizeH * 0.3,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: Image.asset("assets/image/sos_icon_${alert ? '2' : '1'}.png").image,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SizedBox(height: sizeH * 0.05,),
            Container(
              child: Text('ALERTA DE LA HABITACIÓN ${room.toUpperCase()}',
              style: S4CStyles().stylePrimary(size: sizeH * 0.04,color: alert ? Colors.redAccent : Colors.white,fontWeight: FontWeight.bold),),
            ),
            SizedBox(height: sizeH * 0.05,),
            ButtonGeneral(
              title: 'Atender',
              textStyle: S4CStyles().stylePrimary(size: sizeH * 0.03,color: Colors.white,fontWeight: FontWeight.bold),
              height: sizeH * 0.08,
              width: sizeW * 0.25,
              backgroundColor: Colors.grey,
              radius: 1,
              icon: Container(
                margin: EdgeInsets.only(right: sizeW * 0.02),
                child: Icon(Icons.info_outline,size: sizeH * 0.04,color: Colors.white,),
              ),
              textAlign: TextAlign.left,
              titlePadding: EdgeInsets.only(left: sizeW * 0.02),
              onPressed: () async {
                //activeCentral(0);
                Vibration?.cancel();
                lamparaOn(1);
                if(widget.isBLockWellcome){

                  setState(() {
                    isOpenSosForm = true;
                  });

                  await SharedPreferencesClass().setStringValue('s4cLoginBeaconsPos', '0|0|0');
                  int selectTypeLogin = await SharedPreferencesClass().getValue('s4cTypeLogin');
                  if(selectTypeLogin == 0){
                    Navigator.pushReplacement(context, new MaterialPageRoute(builder: (BuildContext context) => new SensorSearch()));
                  }
                  if(selectTypeLogin == 1){
                    Navigator.pushReplacement(context, new MaterialPageRoute(builder: (BuildContext context) => new QRActive()));
                  }
                  if(selectTypeLogin == 2){
                    Navigator.pushReplacement(context, new MaterialPageRoute(builder: (BuildContext context) => new LoginPage()));
                  }
                }else{
                  Navigator.pushReplacement(context, new MaterialPageRoute(builder: (BuildContext context) => new SosForm()));
                }
              },
            ),
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
          // InkWell(
          //   splashColor: S4CColors().primary,
          //   focusColor: S4CColors().primary,
          //   onTap: () async {
          //     //activeCentral(0);
          //     Vibration?.cancel();
          //     lamparaOn(1);
          //     Navigator.of(context).pop();
          //   },
          //   child: Container(
          //     height: sizeH * 0.05,
          //     width: sizeH * 0.05,
          //     margin: EdgeInsets.only(right: sizeW * 0.03),
          //     decoration: BoxDecoration(
          //       image: DecorationImage(
          //         image: Image.asset("assets/image/icons_door_out${idTemplate == 0 ? '' : '_black'}.png").image,
          //         fit: BoxFit.contain,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  // Future activeCentral(int active) async{
  //   try{
  //     int idServer = await SharedPreferencesClass().getValue('idServerS4C') ?? 0;
  //     String idTablet = await SharedPreferencesClass().getValue('S4CIdTablet') ?? '';
  //     String business = await SharedPreferencesClass().getValue('S4CBusiness') ?? '';
  //     String token = await SharedPreferencesClass().getValue('tokenFirebaseS4C') ?? '';
  //     var response = await ConnectionHttp().httpPutServerToken(body: {
  //       'nombre' : '$idTablet|$business|$room',
  //       'url' : token,
  //       'activo' : 1,
  //       'alert' : 0,
  //       'is_doctor' : 0,
  //       'central_alert' : active,
  //     },idTablet: idServer);
  //     if(response!.statusCode == 200){
  //       //var value = jsonDecode(response.body);
  //       print('MODIFICANDO ALERTA CENTRAL');
  //     }
  //   }catch(e){
  //     print('SOSPage: ${e.toString()}');
  //   }
  // }

  Future lamparaOn(int type) async{
    await ledOnAndOff(type);
  }

  void _initializeBloc(){
    try {
      // ignore: cancel_subscriptions
      streamSubscriptionBloc = blocData.outList.listen((newVal) {
        if(newVal.containsKey('closetAlert') && newVal['closetAlert']){
          Navigator.of(context).pop();
        }
      });
    } catch (e) {}
  }
}
