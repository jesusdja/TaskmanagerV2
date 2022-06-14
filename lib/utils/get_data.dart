import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:tra_s4c/main.dart';
import 'package:tra_s4c/models/patient_model.dart';
import 'package:tra_s4c/services/http_connection.dart';
import 'package:tra_s4c/services/shared_preferences.dart';
import 'package:path/path.dart';
import 'package:tra_s4c/services/sqflite.dart';

Future<Map<String,dynamic>> getDataUserLogin() async{
  Map<String,dynamic> data = {};

  try{
    String values = await SharedPreferencesClass().getValue('s4cUserLogin');
    data = jsonDecode(values);
  }catch(_){}

  return data;
}

Future ledOnAndOff(int type) async{
  String ipDevice = await SharedPreferencesClass().getValue('S4CIpDeviceLampara') ?? '';
  if(ipDevice.isNotEmpty){
    String ip =  ipDevice.split('|')[0];
    String device =  ipDevice.split('|')[1];
    try{
      Map<String,dynamic> body = {
        'deviceid' : device,
        'data' : {
          'switch' : type == 0 ? 'on' : 'off'
        }
      };
      var response = await ConnectionHttp().httpPostOnOffLampara(body: body, ip: ip);
      if(response.statusCode == 200){
        if(type == 0){
          print('ENCENDIO LA LAMPARA');
          //showAlert(text: 'Lámpara encendida', color: Colors.green);
          await SharedPreferencesClass().setIntValue('S4COnOffLed',0);
        }else{
          print('APAGO LA LAMPARA');
          //showAlert(text: 'Lámpara apagada', color: Colors.grey);
          await SharedPreferencesClass().setIntValue('S4COnOffLed',1);
        }
      }
    }catch(e){
      print('${e.toString()}');
      //showAlert(text: 'Error: ${e.toString()}', isSuccess: false);
    }
  }else{
    //showAlert(text: 'Error: No se encontro la IP de la lámpara para este dispositivo ($idTablet)', isSuccess: false);
  }
}

Map<String,String> tokenForAzure = {
  'host1' : '8:acs:82bb0ff9-74b0-420a-99f4-3e0ada2aed89_0000000d-ce14-15e7-65f0-ad3a0d003c0e',
  'host2' : '8:acs:82bb0ff9-74b0-420a-99f4-3e0ada2aed89_0000000d-ce14-a21a-65f0-ad3a0d003c1b',
  'user1' : '8:acs:82bb0ff9-74b0-420a-99f4-3e0ada2aed89_0000000d-2436-dbb1-0bf3-b03a0d00a6d8',
  'user2' : '8:acs:82bb0ff9-74b0-420a-99f4-3e0ada2aed89_0000000d-2440-7a19-6bf9-b03a0d007bcb',
  'user3' : '8:acs:82bb0ff9-74b0-420a-99f4-3e0ada2aed89_0000000d-34bd-6592-78f0-b03a0d002d8c',
  'user4' : '8:acs:82bb0ff9-74b0-420a-99f4-3e0ada2aed89_0000000d-ce13-8c72-65f0-ad3a0d003bfc',
};

Future<Map<String,dynamic>> getDataDevicesHttp({required String idTablet}) async{
  Map<String,dynamic> dataDevice = {};
  List listLamparas = [];
  try{
    var response = await ConnectionHttp().httpGetLamparas();
    if(response.statusCode == 200){
      var value = jsonDecode(response.body);
      listLamparas = value['devices'];
    }
  }catch(e){
    print('${e.toString()}');
  }


  for(int x = 0; x < listLamparas.length; x++){
    if(listLamparas[x]['tablet_id'].toString() == idTablet){
      dataDevice = listLamparas[x];

      x = listLamparas.length;
    }
  }
  return dataDevice;
}

Future<bool> getCheckIpHttp({required String ip}) async{
  bool res = false;
  List listLamparas = [];
  try{
    var response = await ConnectionHttp().httpGetLamparas();
    if(response.statusCode == 200){
      var value = jsonDecode(response.body);
      listLamparas = value['devices'];
      for(int x = 0; x < listLamparas.length; x++){
        if(listLamparas[x]['ip'].toString() == ip){
          res = true;
          x = listLamparas.length;
        }
      }
    }
  }catch(e){
    print('${e.toString()}');
  }
  return res;
}

List orderListMenuDer2(List listOld){
  List newList = [];
  try{
    List listOldAux = [];
    listOld.forEach((element) { listOldAux.add(element); });

    for(int x = 0; x < listOldAux.length; x++){
      int pos = 0;
      for(int xx = 0; xx < listOld.length; xx++){
        Map<String,dynamic> element1 = listOld[xx];
        for(int yy = 0; yy < listOld.length; yy++){
          Map<String,dynamic> element2 = listOld[yy];

          if(element1['fxInicio'].toString().isNotEmpty && element2['fxInicio'].toString().isNotEmpty){
            DateTime f1 = DateTime.parse(formatDate(element1['fxInicio']));
            DateTime f2 = DateTime.parse(formatDate(element2['fxInicio']));
            if(f1.difference(f2).inMinutes > 0){
              element1 = element2;
              pos = yy;
            }
          }
        }
      }
      newList.add(listOld[pos]);
      listOld.removeAt(pos);
    }
  }catch(_){}
  return newList;
}

String formatDate(String date){
  String newDate = date;
  try{
    List data1 = date.split(' ');
    List data2 = data1[0].toString().split('/');
    newDate = '${data2[2]}-${data2[1]}-${data2[0]} ${data1[1]}';
  }catch(_){}

  return newDate;
}

Image? netWorkImage({required String ruta}){
  Image? image;
  try{
    String name = ruta.split('/').last;
    File fileImage = File(join(dirMain!.path, name));
    image = Image(image: NetworkToFileImage(url: ruta,file: fileImage));

  }catch(e){
    print('${e.toString()}');
  }
  return image;
}

Future<bool> checkBeaconsPatientsLocal({required String uId}) async{
  bool result = false;
  try{
    List<PatientModel> patients = [];
    bool isRoom = await SharedPreferencesClass().getValue('S4CisRoom') ?? true;
    if(isRoom){
      patients = await DatabaseProvider.db.getAllPatientUID(uId: uId);
    } else {
      patients = await DatabaseProvider.db.getAllPatientUIDUnidadFunctional(uId: uId);
    }
    result = patients.isNotEmpty;
  }catch(e){
    print('checkBeaconsPatientsLocal: ${e.toString()}');
  }
  return result;
}