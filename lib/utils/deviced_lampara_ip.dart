import 'package:tra_s4c/services/http_connection.dart';
import 'package:tra_s4c/services/shared_preferences.dart';

class DeviceIp{
  Future createDeviceIp({String ip = ''})async{
    try{
      String idTablet = await SharedPreferencesClass().getValue('S4CIdTablet') ?? '';
      if(idTablet.isNotEmpty){
        Map<String,dynamic> body = {
          'ip' : ip,
          'deviceid' : '',
          'tablet_id' : idTablet,
        };
        /*var response = */await ConnectionHttp().httpPostCreateDeviceIdIp(body: body);
        //var value = jsonDecode(response.body);
      }
    }catch(e){
      print('${e.toString()}');
    }
  }


  Future updateDeviceIp({required String ip, required String id}) async{
    try{
      String idTablet = await SharedPreferencesClass().getValue('S4CIdTablet') ?? '';
      if(idTablet.isNotEmpty){
        Map<String,dynamic> body = {
          'ip' : ip,
          'deviceid' : '',
          'tablet_id' : idTablet,
        };
        /*var response = */await ConnectionHttp().httpPutDeviceIdIp(body: body, id: id);
        //var value = jsonDecode(response.body);
      }
    }catch(e){
      print('${e.toString()}');
    }
  }
}