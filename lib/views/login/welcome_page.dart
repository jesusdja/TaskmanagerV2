import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:tra_s4c/config/s4c_colors.dart';
import 'package:tra_s4c/config/s4c_style.dart';
import 'package:tra_s4c/initial_page.dart';
import 'package:tra_s4c/main.dart';
import 'package:tra_s4c/services/http_connection.dart';
import 'package:tra_s4c/services/push_notifications_services.dart';
import 'package:tra_s4c/services/shared_preferences.dart';
import 'package:tra_s4c/services/updateDataHttpToSqlflite.dart';
import 'package:tra_s4c/utils/deviced_lampara_ip.dart';
import 'package:tra_s4c/utils/get_data.dart';
import 'package:tra_s4c/utils/send_data.dart';
import 'package:tra_s4c/views/login/login_page.dart';
import 'package:tra_s4c/views/login/qr_active.dart';
import 'package:tra_s4c/views/login/sensor_search.dart';
import 'package:tra_s4c/views/menu/config/config_page.dart';
import 'package:tra_s4c/views/menu/config/get_password.dart';
import 'package:tra_s4c/views/menu/sos/jitsi_meet.dart';
import 'package:tra_s4c/views/menu/sos/sos_page.dart';
import 'package:tra_s4c/widgets_utils/button_general.dart';
import 'package:http/http.dart' as http;
import 'package:tra_s4c/widgets_utils/toast_widget.dart';

class WelcomePage extends StatefulWidget {
  WelcomePage({required this.contextHome});
  final BuildContext contextHome;
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {

  StreamSubscription? streamSubscriptionBloc;
  StreamSubscription? _streamRanging;
  DateTime? dateAlertNow;
  bool getConnectionProfile = false;

  @override
  void initState() {
    super.initState();
    _initializeBloc();
    _notificationListener();
    playSearchBeacons();
    channelNative();
    PasswordAdmin().updatePassword();
  }

  Future initialData() async{
    await UpdateDataHttpToSqlLite().getUsersHttp();
    await UpdateDataHttpToSqlLite().getPatientsHttp();
    await UpdateDataHttpToSqlLite().getDataCentro();
    await UpdateDataHttpToSqlLite().getMotivosAlarma();
  }

  void _notificationListener() async{
    PushNotificationServices.messageStream.listen((message) {
      print('***********************');
      print('***********************');
      print(message);
      print('***********************');
      print('***********************');
      if(message.containsKey('nameRoom')){
        Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new JitsiMeetVideo(callRoom: true,nameRoom: message['nameRoom'].toString(),)));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscriptionBloc?.cancel();
    _streamRanging?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () async {
        bool isRoom = await SharedPreferencesClass().getValue('S4CisRoom') ?? true;
        if(isRoom){
          await Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new SOSPage(isBLockWellcome: true,)));
          await SharedPreferencesClass().setIntValue('stSos', 0);
        }else{
          await setCorrelativo();
          showAlert(text: 'Alerta enviada');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: logoHelp(),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: sizeH * 0.1,),
            logo(),
            SizedBox(height: sizeH * 0.2,),
            ButtonGeneral(
              title: 'Toca la pantalla para Acceder',
              textStyle: S4CStyles().stylePrimary(size: sizeH * 0.028,color: Colors.white,fontWeight: FontWeight.bold),
              height: sizeH * 0.07,
              width: sizeW * 0.3,
              icon: Container(),
              backgroundColor: S4CColors().primary,
              onPressed: () async {

                setState(() {
                  isOpenSosForm = false;
                });

                await SharedPreferencesClass().setStringValue('s4cLoginBeaconsPos', '0|0|0');
                int selectTypeLogin = await SharedPreferencesClass().getValue('s4cTypeLogin');
                if(selectTypeLogin == 0){
                  Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new SensorSearch()));
                }
                if(selectTypeLogin == 1){
                  Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new QRActive()));
                }
                if(selectTypeLogin == 2){
                  Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new LoginPage()));
                }
              },
            ),
            Expanded(child: Container(),),
            Container(
              width: sizeW,
              margin: EdgeInsets.only(right: sizeW * 0.08,),
              child: Text(versionApp,style: S4CStyles().stylePrimary(color: S4CColors().colorLoginPageBack,size: sizeH * 0.02),textAlign: TextAlign.right,),
            ),
            SizedBox(height: sizeH * 0.02,),
          ],
        ),
      ),
    );
  }

  Widget logo(){
    return Container(
      width: sizeW,
      child: Container(
        height: sizeH * 0.25,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Image.asset("assets/image/logo_lock.png").image,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  PreferredSize logoHelp(){
    return PreferredSize(
      preferredSize: Size.fromHeight(sizeH * 0.1),
      child: Container(
        width: sizeW,
        margin: EdgeInsets.only(top: sizeH * 0.03,left: sizeW * 0.02, right: sizeW * 0.02),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: EdgeInsets.only(right: sizeW * 0.01),
              child: Icon(getConnectionProfile ? Icons.signal_wifi_4_bar_outlined : Icons.signal_wifi_bad, color: getConnectionProfile ? Colors.green : Colors.red,size: sizeH * 0.07,),
            ),
            Expanded(
              child: InkWell(
                onTap: () async {
                  Map? res = await Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new GetPass()));
                  if(res != null && res.containsKey('user')){
                    await SharedPreferencesClass().setIntValue('s4cIsWelcome',1);
                    await Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new ConfigPage(isWelcome: true,superUser: res['user'] == 1,)));
                    setState(() {});
                    await SharedPreferencesClass().setIntValue('s4cIsWelcome',0);
                  }
                },
                focusColor: S4CColors().colorHomeSplashMenu,
                splashColor: S4CColors().colorHomeSplashMenu,
                hoverColor: S4CColors().colorHomeSplashMenu,
                highlightColor: S4CColors().colorHomeSplashMenu,
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: sizeH * 0.08,
                    height: sizeH * 0.08,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: Image.asset("assets/image/icon_menu_7_black.png").image,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              child: Container(
                height: sizeH * 0.1,
                width: sizeH * 0.1,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: Image.asset("assets/image/icon_help.png").image,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _initializeBloc(){
    try {
      // ignore: cancel_subscriptions
      streamSubscriptionBloc = blocData.outList.listen((newVal) {
        if(newVal.containsKey('refreshApp') && newVal['refreshApp']){
          setState(() {});
        }
        if(newVal.containsKey('getConnectionProfile') && newVal['getConnectionProfile']){
          getConnectionProfile = newVal['getConnectionProfile'];
          setState(() {});
        }
      });
    } catch (e) {}
  }

  Future playSearchBeacons() async {
    try{
      _streamRanging = sensorBeacons.outList.listen((result) {
        openSos(result['beaconsResult']);
      });
    }catch(e){
      print('playSearchBeacons : ${e.toString()}');
    }
  }

  Future openSos(List<Beacon> listBeacons) async{
    try{
      int stSos = await SharedPreferencesClass().getValue('stSos') ?? 0;
      if(stSos == 0 && !isOpenSosForm){
        DateTime dateAux = DateTime.now();
        print('BUSCANDO BEACONS ALERT');
        await SharedPreferencesClass().setIntValue('stSos', 1);
        for(int x = 0; x < listBeacons.length; x++){
          //if(listBeacons[x].proximityUUID == '15164A5A-F607-49AE-0000-66B7106A0000'){
          if(await checkBeaconsPatientsLocal(uId: listBeacons[x].proximityUUID)){
            String data = await SharedPreferencesClass().getValue('S4CIntPulsador') ?? '30|Seg|30';
            if(dateAlertNow == null || dateAux.difference(dateAlertNow!).inSeconds > int.parse(data.split('|')[0])){
              dateAlertNow = DateTime.now();
              setState(() {});

              await SharedPreferencesClass().setStringValue('s4cUserAlertSt',listBeacons[x].proximityUUID);
              await SharedPreferencesClass().setStringValue('s4cUserAlertStrssi',listBeacons[x].rssi.toString());
              await SharedPreferencesClass().setStringValue('s4cUserAlertStmac_address',listBeacons[x].macAddress!);
              await SharedPreferencesClass().setStringValue('s4cUserAlertStproximity',listBeacons[x].proximity.name);

              bool isRoom = await SharedPreferencesClass().getValue('S4CisRoom') ?? true;
              if(isRoom){
                await Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new SOSPage(isBLockWellcome: true,)));
                await SharedPreferencesClass().setIntValue('stSos', 0);
              }else{
                await setCorrelativo();
                showAlert(text: 'Alerta enviada');
              }
            }
          }
        }
        await SharedPreferencesClass().setIntValue('stSos', 0);
      }
    }catch(e){
      print('openSos : ${e.toString()}');
      await SharedPreferencesClass().setIntValue('stSos', 0);
    }
  }

  Future channelNative() async{
    initialData();
    await activeSignalR();
    await getIpLampara();
    await checkLamparaAlert();
  }

  Future activeSignalR() async{

    await SharedPreferencesClass().setStringValue('S4CFamilyJitsyActivo','0');
    String nameDB = await SharedPreferencesClass().getValue('S4CNameDB');
    String idRoom = await SharedPreferencesClass().getValue('S4CfkRoom');

    String httpClientLocal = '${nameDB}_hab_$idRoom';

    final httpClient = _HttpClient(defaultHeaders: {
      'x-ms-signalr-userid' : httpClientLocal,
    });

    try{
      final connection = HubConnectionBuilder().
      withUrl('https://s4csignalr.soft4care.net/api/',
          HttpConnectionOptions(
            transport: HttpTransportType.webSockets,
            client: httpClient,
            logging: (level,message){
              print('SIGNAL-R: $message');
              bool received = message.contains('data received') || message.contains('sending data') ;
              blocData.inList.add({'getConnectionProfile' : received});
            }
          )).withAutomaticReconnect().build();


      connection.on('newMessage', (message) async {
        print('SIGNAL-R: $message');
        if(message != null && message.isNotEmpty){
          Map<String,dynamic> mapMessage = jsonDecode(message[0].toString().replaceAll('\n', '').replaceAll('\r', ''));
          try{
            if((httpClientLocal == mapMessage['sento']) && (mapMessage['tipo'].toString() == '50' || mapMessage['tipo'].toString() == '51')){
              if(mapMessage.containsKey('texto') && mapMessage['texto'].toString().isNotEmpty){
                List data = mapMessage['texto'].toString().split(',');
                if(data.length >= 3){
                  if(data[2].toString().contains('1')){
                    String jitsyActivo = await SharedPreferencesClass().getValue('S4CFamilyJitsyActivo') ?? '0';
                    if(jitsyActivo == '0'){
                      Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) =>
                      new JitsiMeetVideo(callRoom: true,nameRoom: data[0].toString(),videoMuted: data[1].toString().contains('0'),)));
                    }
                  }else {
                    blocData.inList.add({'closetJitsy' : true});
                  }
                }
              }
            }
            if((mapMessage['tipo'].toString() == '6') && (httpClientLocal == mapMessage['sento'])){
              blocData.inList.add({'closetAlert' : true});
            }
            if(mapMessage['tipo'].toString() == '10'){
              UpdateDataHttpToSqlLite().getAll();
            }
          }catch(e){
            print('newMessage: ${e.toString()}');
          }
        }
      });

      connection.start();

      print('CONECTADO AL SIGNAL-R CON ${nameDB}_hab_$idRoom' );

    }catch(e){
      print('ERROR SIGNAL-R: ${e.toString()}');
    }
  }

  Future getIpLampara() async{

    String idTablet = await SharedPreferencesClass().getValue('S4CIdTablet') ?? '';
    Map<String,dynamic> dataDevice = await getDataDevicesHttp(idTablet: idTablet);
    String ip = '';
    if(dataDevice.isNotEmpty){
      ip = '${dataDevice['ip']}|${dataDevice['deviceid']}|${dataDevice['id']}';
    }
    if(ip.isNotEmpty){
      await SharedPreferencesClass().setStringValue('S4CIpDeviceLampara',ip);
    }else{
      //SE CREA EL REGISTRO PARA SER EDITADO
      await DeviceIp().createDeviceIp();
      getIpLampara();
    }
  }

  Future checkLamparaAlert() async{
    bool isRoom = await SharedPreferencesClass().getValue('S4CisRoom') ?? true;
    if(isRoom){
      String ipDevice = await SharedPreferencesClass().getValue('S4CIpDeviceLampara') ?? '';
      if(ipDevice.isNotEmpty){
        String ip =  ipDevice.split('|')[0];
        try{
          var response = await ConnectionHttp().httpPostCheckLamparas(ip);
          if(response.statusCode == 200){
            var value = jsonDecode(response.body);
            if(value['data']['switch'] == 'on'){
              int stSos = await SharedPreferencesClass().getValue('stSos') ?? 0;
              if(stSos == 0){
                await Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new SOSPage(isBLockWellcome: true,)));
                await SharedPreferencesClass().setIntValue('stSos', 0);
              }
            }
          }
        }catch(e){
          print('checkLamparaAlert: ${e.toString()}');
        }
      }
      await Future.delayed(Duration(seconds: 10));
      if(mounted){
        checkLamparaAlert();
      }
    }
  }
}

class _HttpClient extends http.BaseClient {
  final _httpClient = http.Client();
  final Map<String, String> defaultHeaders;

  _HttpClient({required this.defaultHeaders});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(defaultHeaders);
    return _httpClient.send(request);
  }
}