import 'dart:convert';

import 'package:tra_s4c/services/http_connection.dart';
import 'package:tra_s4c/services/shared_preferences.dart';

Future sendToUser({required int type, String texto = '', required int idtk}) async{

  String idUser = await SharedPreferencesClass().getValue('S4CIdTablet') ?? '';
  String nameCentro = await SharedPreferencesClass().getValue('S4CNameDB') ?? '';
  String fkRoom = await SharedPreferencesClass().getValue('S4CfkRoom');

  String idwearableSt = await SharedPreferencesClass().getValue('s4cUserAlertSt') ?? '';

  String s4cUserAlertStrssi = await SharedPreferencesClass().getValue('s4cUserAlertStrssi') ?? '';
  String s4cUserAlertStMacAddress = await SharedPreferencesClass().getValue('s4cUserAlertStmac_address') ?? '';
  String s4cUserAlertStProximity = await SharedPreferencesClass().getValue('s4cUserAlertStproximity') ?? '';

  try{
    if(idwearableSt.isEmpty){
      String data = await SharedPreferencesClass().getValue('s4cUserLogin');
      Map dataUserActive = jsonDecode(data);
      idwearableSt = dataUserActive['fkCodigo'];
    }
  }catch(_){}

  Map<String,dynamic> body = {
    'centro' : nameCentro.toLowerCase(),
    'fkHabitacion' : int.parse(fkRoom.toString()),
    'idwearable' : idwearableSt,
    'idtablet' : int.parse(idUser),
    'tipo' : type,
    'idtk' : '$idUser$idtk',
    'rssi' : s4cUserAlertStrssi,
    'mac_address' : s4cUserAlertStMacAddress,
    'proximity' : s4cUserAlertStProximity,
  };

  if(type == 1 || type == 2){
    String room = await SharedPreferencesClass().getValue('S4CRoom');
    body['texto'] = 'Alerta a habitación $room';
  }

  if(texto.isNotEmpty){ body['texto'] = texto; }

  try{
    var response = await ConnectionHttp().httpPostSendToUser(body: body);
    //var value = jsonDecode(response.body);
    if(response.statusCode == 200){

    }
  }catch(e){
    print('${e.toString()}');
  }

  await SharedPreferencesClass().deleteValue('s4cUserAlertStrssi');
  await SharedPreferencesClass().deleteValue('s4cUserAlertStmac_address');
  await SharedPreferencesClass().deleteValue('s4cUserAlertStproximity');
}

Future setCorrelativo() async{
  try{
    int correlativo =  await SharedPreferencesClass().getValue('S4CCorrelativo') ?? 0;
    correlativo++;
    await SharedPreferencesClass().setIntValue('S4CSosId',correlativo);
    await SharedPreferencesClass().setIntValue('S4CCorrelativo',correlativo);
    sendToUser(type: 1,idtk: correlativo);
  }catch(e){
    print('${e.toString()}');
  }
}