import 'dart:convert';

import 'package:http/http.dart';
import 'package:tra_s4c/main.dart';
import 'package:tra_s4c/models/centro_model.dart';
import 'package:tra_s4c/models/location_model.dart';
import 'package:tra_s4c/models/motivo_model.dart';
import 'package:tra_s4c/models/patient_model.dart';
import 'package:tra_s4c/models/user_model.dart';
import 'package:tra_s4c/services/http_connection.dart';
import 'package:tra_s4c/services/shared_preferences.dart';
import 'package:tra_s4c/services/sqflite.dart';
import 'package:tra_s4c/utils/send_data.dart';

class UpdateDataHttpToSqlLite{
  UpdateDataHttpToSqlLite(){
    LoadDataHttpToSqlLite();
  }

  Future getAll() async{
    getUsersHttp();
    getPatientsHttp();
    getMotivosAlarma();
    // getDataCentro();
  }

  Future getUsersHttp() async{
    print('GET DATA getUsersHttp');
    try{
      var response = await ConnectionHttp().httpGetUsers();
      var value = jsonDecode(response.body);
      List<dynamic> listHttp = value ?? [];
      bool checkTrue = false;
      for(int x = 0; x < listHttp.length; x++){
        try{
          UserModel userModel = UserModel.fromJson(listHttp[x]);
          UserModel? userModelCheck = await  DatabaseProvider.db.getUser('${userModel.idusuario}');
          if(userModel != userModelCheck){
            checkTrue = true;
            if (userModelCheck == null) {
              await DatabaseProvider.db.saveUser(userModel);
            }else {
              await DatabaseProvider.db.updateUser(userModel);
            }
          }
        }catch(e){
          print('getUsersHttp: ${e.toString()}');
        }
      }
      if(checkTrue){
        blocData.inList.add({'refreshUserServer' : 'refreshUserServer'});
      }
    }catch(e){
      print('getUsersHttp: ${e.toString()}');
    }
  }

  Future getDataCentro() async{
    print('GET DATA getDataCentro');
    try{
      var response = await ConnectionHttp().httpGetDataCentro();
      var value = jsonDecode(response.body);
      List<dynamic> listHttp = value ?? [];
      for(int x = 0; x < listHttp.length; x++){
        try{
          CentroModel centroModel = CentroModel.fromJson(listHttp[x]);
          CentroModel? centroModelCheck = await DatabaseProvider.db.getRoom(id: centroModel.id!);
          if(centroModel != centroModelCheck){
            if (centroModelCheck == null) {
              await DatabaseProvider.db.saveRoom(centroModel);
            }else {
              await DatabaseProvider.db.updateRoom(centroModel);
            }
          }
        }catch(e){
          print('getDataCentro: ${e.toString()}');
        }
      }
    }catch(e){
      print('getDataCentro: ${e.toString()}');
    }
  }

  Future getPatientsHttp() async{
    print('GET DATA getPatientsHttp');
    try{
      var response = await ConnectionHttp().httpGetPatients();
      var value = jsonDecode(response.body);
      List<dynamic> listHttp = value ?? [];
      for(int x = 0; x < listHttp.length; x++){
        try{
          PatientModel patientModel = PatientModel.fromJson(listHttp[x]);
          PatientModel? patientModelCheck = await  DatabaseProvider.db.getPatient('${patientModel.idasis}');
          if(patientModel != patientModelCheck){
            if (patientModelCheck == null) {
              await DatabaseProvider.db.savePatient(patientModel);
            }else {
              await DatabaseProvider.db.updatePatient(patientModel);
            }
          }
        }catch(e){
          print('getPatientsHttp: ${e.toString()}');
        }
      }
    }catch(e){
      print('getPatientsHttp: ${e.toString()}');
    }
  }

  Future getMotivosAlarma() async{
    print('GET DATA getMotivosAlarma');
    try{
      var response = await ConnectionHttp().httpGetMotivosAlarma();
      var value = jsonDecode(response.body);
      List<dynamic> listHttp = value ?? [];
      for(int x = 0; x < listHttp.length; x++){
        try{
          MotivoModel motivoModel = MotivoModel.fromJson(listHttp[x]);
          MotivoModel? motivoModelCheck = await  DatabaseProvider.db.getMotivo('${motivoModel.idMotivoAlarma}');
          if(motivoModel != motivoModelCheck){
            if (motivoModelCheck == null) {
              await DatabaseProvider.db.saveMotivo(motivoModel);
            }else {
              await DatabaseProvider.db.updateMotivo(motivoModel);
            }
          }
        }catch(e){
          print('getMotivosAlarma: ${e.toString()}');
        }
      }
    }catch(e){
      print('getMotivosAlarma: ${e.toString()}');
    }
  }
}

class LoadDataHttpToSqlLite{
  LoadDataHttpToSqlLite(){
    getLocationHttp();
  }

  Future getLocationHttp() async{
    print('GET DATA getLocationHttp');
    try{
      String centro = await SharedPreferencesClass().getValue('S4CNameDB');
      String idTablet = await SharedPreferencesClass().getValue('S4CIdTablet');
      if(centro.isNotEmpty && idTablet.isNotEmpty){
        List<Map<String,dynamic>> listData = [];
        List<Map<String,dynamic>> listData2 = [];
        List<LocationModel?> listLocationForSend = await DatabaseProvider.db.getAllLocationUserForSend();
        for(int x = 0; x < listLocationForSend.length; x++){
          try{
            LocationModel? locationModel = listLocationForSend[x];
            UserModel? user = await DatabaseProvider.db.getUserSensor(locationModel!.uuid!);
            listData.add({
              'UUID' : locationModel.uuid,
              'rssi' : locationModel.rssi.toString(),
              'mac_address' : locationModel.mac,
              'proximity' : locationModel.proximity,
              'date' : locationModel.date.toString(),
              'id_tablet' : idTablet,
              'centro' : centro,
              'idusuario' : user!.idusuario!.toString()
            });
            listData2.add({
              'UUID' : locationModel.uuid,
              'rssi' : locationModel.rssi.toString(),
              'mac_address' : locationModel.mac,
              'proximity' : locationModel.proximity,
              'fdate' : locationModel.date.toString(),
              'id_tablet' : idTablet,
              'centro' : centro,
              'idusuario' : user.idusuario!.toString()
            });
          }catch(_){}
        }
        if(listData.isNotEmpty){
          print('ENVIAR AL SERVER ${listData.length} DATA');
          Map<String,dynamic> body = {'data' : listData};
          Response? response = await ConnectionHttp().httpPostSaveLogSensorBeacons(body: body);

          bool sendResponse2 = false;
          if(listData2.isNotEmpty){
            //for(int y = 0; y < listData2.length; y++){
              Response? response2 = await ConnectionHttp().httpPostSetLogBeacon(body: listData2);
              sendResponse2 = jsonDecode(response2!.body);
              sendToUser(type: 2,idtk: 1);
            //}
          }

          if(response != null && response.statusCode == 200 && sendResponse2){
            for(int x = 0; x < listLocationForSend.length; x++){
              LocationModel? locationModel = listLocationForSend[0];
              locationModel!.send = 1;
              await DatabaseProvider.db.updateLocation(locationModel);
            }
          }
        }
      }
    }catch(e){
      print('getLocationHttp: ${e.toString()}');
    }
  }
}

class PasswordAdmin{

  Future<bool> checkPassword({required String nameDb, required String pass})async{
    print('GET DATA getPassword');
    bool res = false;
    try{
      var response = await ConnectionHttp().httpGetPasswordTK(nameDb: nameDb);
      if(response.statusCode == 200){
        var value = jsonDecode(response.body);
        if(value.toString() == pass && value.toString() != '0'){
          res = true;
        }
      }
    }catch(e){
      print('checkPassword: ${e.toString()}');
    }
    return res;
  }

  Future<bool> updatePassword() async{
    print('GET DATA updatePassword');
    bool res = false;
    try{
      String nameDb = await SharedPreferencesClass().getValue('S4CNameDB') ?? '';
      var response = await ConnectionHttp().httpGetPasswordTK(nameDb: nameDb);
      if(response.statusCode == 200){
        var value = jsonDecode(response.body);
        await SharedPreferencesClass().setStringValue('S4CPasswordDB', value.toString());
        res = true;
      }
    }catch(e){
      print('updatePassword: ${e.toString()}');
    }
    return res;
  }


}