import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tra_s4c/services/shared_preferences.dart';

class ConnectionHttp{

  String urlLocal = 'https://conecta.soft4care.net/BiData.svc';

  Future<http.Response> httpGetLoginQR({required String cn, required String cod}) async{
    var response;
    try{
      response = http.get( Uri.parse('$urlLocal/LoginQR?centro=$cn&codigo=$cod'));
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpGetLoginBeacons({required String uuid}) async{
    String nameDB = await SharedPreferencesClass().getValue('S4CNameDB');
    var response;
    try{
      response = http.get( Uri.parse('$urlLocal/LoginBeacon?centro=$nameDB&beaconid=$uuid'));
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpGetUsers() async{
    String nameDB = await SharedPreferencesClass().getValue('S4CNameDB');
    var response;
    try{
      response = http.get( Uri.parse('$urlLocal/LoginsBeacons?centro=$nameDB'));
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpGetDataCentro({String? idAlojamiento}) async{
    String nameDB = await SharedPreferencesClass().getValue('S4CNameDB');
    var response;
    String ruta = '$urlLocal/GetHabitaciones?centro=$nameDB';
    if(idAlojamiento != null && idAlojamiento != '0'){
      ruta = '$urlLocal/GetHabitaciones?centro=$nameDB&idalojamiento=$idAlojamiento';
    }
    try{
      response = http.get( Uri.parse(ruta));
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpGetDataCentroUnidadFuncional() async{
    String nameDB = await SharedPreferencesClass().getValue('S4CNameDB');
    var response;
    try{
      response = http.get( Uri.parse('$urlLocal/GetUF?centro=$nameDB'));
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response?> httpPostSaveLogSensorBeacons({required Map<String,dynamic> body}) async{
    var response;
    try{
      Map<String,String> headers = {
        'Content-Type':'application/json',
      };

      String bodyEncode = jsonEncode(body);

      response = await http.post(
        Uri.parse('https://soft4care.site/api/sensors'),
        headers: headers,
        body: bodyEncode,
      );
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpGetValidateCentro(String centro) async{
    var response;
    try{
      response = http.get( Uri.parse('$urlLocal/ValidaCentro?centro=$centro'));
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpGetPatients() async{
    String nameDB = await SharedPreferencesClass().getValue('S4CNameDB');
    var response;
    try{
      response = http.get( Uri.parse('$urlLocal/ResidentesMobile?centro=$nameDB&idasis=0&fkdispositivo=0'));
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpGetMotivosAlarma() async{
    String nameDB = await SharedPreferencesClass().getValue('S4CNameDB') ?? '';
    var response;
    try{
      response = http.get( Uri.parse('$urlLocal//GetMotivosAlarma?centro=$nameDB'));
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  //MODIFICAR PARA TAREAS
  Future<http.Response?> httpGetDataTherapy(int idRes,String idRol) async{
    String nameDB = await SharedPreferencesClass().getValue('S4CNameDB');
    var response;
    try{
      response = http.get( Uri.parse('$urlLocal/GetControlesMobile?centro=$nameDB&idresi=$idRes&idrol=$idRol'));
      //response = http.get( Uri.parse('$urlLocal/GetControlesMobile?centro=$nameDB&idresi=125&idrol=18'));
    }catch(ex){
      print(ex.toString());
    }

    return response;
  }

  Future<http.Response?> httpGetDataTaskSchedules(int idRes,String idRol) async{
    String nameDB = await SharedPreferencesClass().getValue('S4CNameDB');
    var response;
    try{
      response = http.get( Uri.parse('$urlLocal/GetControlesMobileProgramadasAll?centro=$nameDB&idasistido=$idRes&idrol=$idRol'));
      //response = http.get( Uri.parse('$urlLocal/GetControlesMobile?centro=$nameDB&idresi=125&idrol=18'));
    }catch(ex){
      print(ex.toString());
    }

    return response;
  }

  Future<http.Response?> httpPostSetLogBeacon({required List<Map<String,dynamic>> body}) async{
    var response;
    try{
      Map<String,String> headers = {
        'Content-Type':'application/json',
      };

      String bodyEncode = jsonEncode(body);

      response = await http.post(
        Uri.parse('$urlLocal/SetLogBeacon'),
        headers: headers,
        body: bodyEncode,
      );
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response?> httpPostSetControlMobileOne({required Map body}) async{
    var response;
    try{
      Map<String,String> headers = {
        'Content-Type':'application/json',
      };

      String bodyEncode = jsonEncode(body);

      response = await http.post(
        Uri.parse('$urlLocal/SetControlMobileOne'),
        headers: headers,
        body: bodyEncode,
      );
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpGetLamparas() async{
    var response;
    String url = 'https://soft4care.site/api/devices';
    try{
      response = await http.get(Uri.parse(url),);
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpPostCheckLamparas(String ip) async{
    var response;
    Map<String,String> headers = {
      'Content-Type':'application/json',
    };
    try{
      String bodyEncode = jsonEncode({'deviceid' : '', 'data' :{}});

      response = await http.post(
          Uri.parse('http://$ip:8081/zeroconf/info'),
          body: bodyEncode,
          headers: headers
      );
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpPostOnOffLampara({required Map<String,dynamic> body, required String ip}) async{
    var response;
    try{
      Map<String,String> headers = {
        'Content-Type':'application/json',
      };

      String bodyEncode = jsonEncode(body);

      response = await http.post(
        Uri.parse('http://$ip:8081/zeroconf/switch'),
        body: bodyEncode,
        headers: headers
      );
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpPostCreateDeviceIdIp({required Map<String,dynamic> body}) async{
    var response;
    try{
      Map<String,String> headers = {
        'Content-Type':'application/json',
      };

      String bodyEncode = jsonEncode(body);

      response = await http.post(
        Uri.parse('https://soft4care.site/api/devices'),
        headers: headers,
        body: bodyEncode,
      );
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpPutDeviceIdIp({required Map<String,dynamic> body,required String id}) async{
    var response;
    try{
      Map<String,String> headers = {
        'Content-Type':'application/json',
      };

      String bodyEncode = jsonEncode(body);

      response = await http.put(
        Uri.parse('https://soft4care.site/api/devices/$id'),
        headers: headers,
        body: bodyEncode,
      );
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpPostFormSos({required Map<String,dynamic> body}) async{
    var response;
    try{
      Map<String,String> headers = {
        'Content-Type':'application/json',
      };

      String bodyEncode = jsonEncode(body);

      response = await http.post(
        Uri.parse('$urlLocal/SetAtenAlarma'),
        headers: headers,
        body: bodyEncode,
      );
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpPostSetConfigTK({required Map<String,dynamic> body}) async{
    var response;
    try{
      Map<String,String> headers = {
        'Content-Type':'application/json',
      };

      String bodyEncode = jsonEncode(body);

      response = await http.post(
        Uri.parse('$urlLocal/SetConfigTK'),
        headers: headers,
        body: bodyEncode,
      );
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpPostSendToUser({required Map<String,dynamic> body}) async{
    var response;
    try{
      Map<String,String> headers = {
        'Content-Type':'application/json',
      };

      String bodyEncode = jsonEncode(body);

      response = await http.post(
        Uri.parse('https://s4csignalr.soft4care.net/api/sendtouser'),
        headers: headers,
        body: bodyEncode,
      );
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpGetPasswordTK({required String nameDb}) async{
    var response;
    String url = '$urlLocal/GetPasswordTK?centro=$nameDb';
    try{
      response = await http.get(Uri.parse(url),);
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpPostGetControlesRealizados({required Map<String,dynamic> body}) async{
    var response;
    try{
      Map<String,String> headers = {
        'Content-Type':'application/json',
      };

      String bodyEncode = jsonEncode(body);

      response = await http.post(
        Uri.parse('$urlLocal/GetControlesRealizados'),
        headers: headers,
        body: bodyEncode,
      );
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpPostGetRealizadosEvals({required Map<String,dynamic> body}) async{
    var response;
    try{
      Map<String,String> headers = {
        'Content-Type':'application/json',
      };

      String bodyEncode = jsonEncode(body);

      response = await http.post(
        Uri.parse('$urlLocal/GetRealizadosEvals'),
        headers: headers,
        body: bodyEncode,
      );
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpGetControlesEvalItems({required String idevaltareaaux}) async{
    var response;
    String centro  = await SharedPreferencesClass().getValue('S4CNameDB') ?? '';
    String url = '$urlLocal/GetControlesEvalItems?centro=$centro&idevaltareaaux=$idevaltareaaux';
    try{
      response = await http.get(Uri.parse(url),);
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response?> httpGetDataTaskUnitFunctional() async{
    String nameDB = await SharedPreferencesClass().getValue('S4CNameDB');
    String fkRoom = await SharedPreferencesClass().getValue('S4CfkRoom');
    var response;
    try{
      response = http.get( Uri.parse('$urlLocal/GetControlesMantenimientoMobile?centro=$nameDB&idresi=$fkRoom'));
      //response = http.get( Uri.parse('$urlLocal/GetControlesMantenimientoMobile?centro=$nameDB&idresi=78'));
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response?> httpGetControlesMantenimientoProgramados() async{
    String nameDB = await SharedPreferencesClass().getValue('S4CNameDB');
    String fkRoom = await SharedPreferencesClass().getValue('S4CfkRoom');
    var response;
    try{
      response = http.get( Uri.parse('$urlLocal/GetControlesMantenimientoProgramados?centro=$nameDB&idresi=$fkRoom'));
      //response = http.get( Uri.parse('$urlLocal/GetControlesMantenimientoProgramados?centro=nimperialbk&iduf=78'));
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response?> httpGetControlesMantenimientoHabitacion({String? idFk}) async{
    String nameDB = await SharedPreferencesClass().getValue('S4CNameDB');
    String idHab = idFk != null ? idFk : await SharedPreferencesClass().getValue('S4CfkRoom');
    var response;
    try{
      response = http.get( Uri.parse('$urlLocal/GetControlesMantenimientoHabitacion?centro=$nameDB&idhabitacion=$idHab'));
      //response = http.get( Uri.parse('$urlLocal/GetControlesMantenimientoHabitacion?centro=$nameDB&idhabitacion=2'));
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response?> httpGetControlesMantenimientoProgramadosHab({String? idFk}) async{
    String nameDB = await SharedPreferencesClass().getValue('S4CNameDB');
    String idHab = idFk != null ? idFk : await SharedPreferencesClass().getValue('S4CfkRoom');
    var response;
    try{
      response = http.get( Uri.parse('$urlLocal/GetControlesMantenimientoProgramadosHab?centro=$nameDB&idhab=$idHab'));
      //response = http.get( Uri.parse('$urlLocal/GetControlesMantenimientoProgramadosHab?centro=$nameDB&idhab=2'));
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  //MODIFICAR PARA TAREAS
  Future<http.Response?> httpGetResidentesMobileUF() async{
    String nameDB = await SharedPreferencesClass().getValue('S4CNameDB');
    String idfkRooms = await SharedPreferencesClass().getValue('S4CfkRoom');
    var response;
    try{
      response = http.get( Uri.parse('$urlLocal/ResidentesMobileUF?centro=$nameDB&iduf=$idfkRooms'));
      //response = http.get( Uri.parse('$urlLocal/ResidentesMobileUF?centro=$nameDB&iduf=2'));
    }catch(ex){
      print(ex.toString());
    }

    return response;
  }

  //OBTENER PASTILLERO
  Future<http.Response?> httpGetPastilleroTK({required int idAsis, required String idUser}) async{
    String nameDB = await SharedPreferencesClass().getValue('S4CNameDB');
    var response;
    try{
      response = http.get( Uri.parse('$urlLocal/GetPastilleroTK?centro=$nameDB&idasis=$idAsis&idusuario=$idUser'));
      //response = http.get( Uri.parse('$urlLocal/GetPastilleroTK?centro=taskontrol&idasis=5421&idusuario=91'));
    }catch(ex){
      print(ex.toString());
    }

    return response;
  }

  //RESPUESTA PASTILLERO
  Future<http.Response?> httpSetPastilleroTK({required String idAsis, required String numFil}) async{
    String nameDB = await SharedPreferencesClass().getValue('S4CNameDB');
    var response;
    try{
      response = http.get( Uri.parse('$urlLocal/SetPastilleroTK?centro=$nameDB&idusuario=$idAsis&numfilas=$numFil'));
      //response = http.get( Uri.parse('$urlLocal/SetPastilleroTK?centro=taskontrol&idusuario=91&numfilas=$numFil'));
    }catch(ex){
      print(ex.toString());
    }

    return response;
  }
}