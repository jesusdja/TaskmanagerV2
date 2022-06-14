import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tra_s4c/services/shared_preferences.dart';

class PushNotificationServices{

  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static String? token;

  static StreamController<Map<String,dynamic>> _messageStreamController  = StreamController<Map<String,dynamic>>.broadcast();
  static Stream<Map<String,dynamic>> get messageStream => _messageStreamController.stream;
  dispose(){
    _messageStreamController.close();
  }

  static Future initializeApp() async {
    await Firebase.initializeApp();

    token = await FirebaseMessaging.instance.getToken();
    print('======== TOKEN FIREBASE ========');
    print('======== TOKEN FIREBASE ========');
    print(token);
    await SharedPreferencesClass().setStringValue('tokenFirebaseS4C',token!);
    print('======== TOKEN FIREBASE ========');
    print('======== TOKEN FIREBASE ========');

    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
    FirebaseMessaging.onMessage.listen(_onMessageHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenApp);
  }

  static Future _backgroundHandler( RemoteMessage message )async{
    _messageStreamController.sink.add(message.data);
  }
  static Future _onMessageHandler( RemoteMessage message )async{
    _messageStreamController.sink.add(message.data);
  }
  static Future _onMessageOpenApp( RemoteMessage message )async{
    _messageStreamController.sink.add(message.data);
  }

  // static Future sendTokenServer() async{
  //   int? idServer = 0; //await SharedPreferencesClass().getValue('idServerS4C') ?? 0;
  //   String idTablet = await SharedPreferencesClass().getValue('S4CIdTablet') ?? '';
  //   String business = await SharedPreferencesClass().getValue('S4CBusiness') ?? '';
  //   String room = await SharedPreferencesClass().getValue('S4CRoom') ?? '';
  //
  //   if(idTablet.isNotEmpty && business.isNotEmpty && room.isNotEmpty){
  //     //if(idServer == null || idServer == 0){
  //       bool exits = true;
  //       int pos = 0;
  //       List<Map<String,dynamic>> listData = [];
  //       while(exits){
  //         try{
  //           var response = await ConnectionHttp().httpGetServerUsers(index: pos);
  //           var value = jsonDecode(response.body);
  //           if(response.statusCode == 200){
  //             List data = value['data']['data'] ?? [];
  //             data.forEach((element) {
  //               listData.add(element);
  //             });
  //             if(value['data']['next_page_url'] == null){
  //               exits = false;
  //             }
  //           }
  //         }catch(e){
  //           exits = false;
  //           print('${e.toString()}');
  //         }
  //         pos++;
  //       }
  //       //VER SI EXISTE EL MODULO Y LA HABITACION
  //       bool isCreate = false;
  //       for(int x = 0; x < listData.length; x++){
  //         List listD = listData[x]['nombre'].toString().split('|');
  //         if(listD.length == 3 && listD[1] == business && listD[2] == room){
  //           idServer = int.parse(listData[x]['id'].toString());
  //           isCreate = true;
  //           x = listData.length;
  //         }
  //       }
  //       if(isCreate){
  //         await SharedPreferencesClass().setIntValue('idServerS4C',idServer!);
  //         await updateToken(idTablet: idTablet, room: room, business: business, idServer: idServer);
  //       }else{
  //         //CREAR TOKEN
  //         await createToken(idTablet: idTablet, room: room, business: business);
  //       }
  //     // } else {
  //     //   //ACTUALIZAR TOKEN
  //     //   await updateToken(idTablet: idTablet, room: room, business: business, idServer: idServer);
  //     // }
  //   }
  // }
  //
  // static Future createToken({ required String idTablet, required String business, required String room }) async{
  //   try{
  //     var response = await ConnectionHttp().httpPostServerCreate(body: {
  //       'nombre' : '$idTablet|$business|$room',
  //       'url' : token,
  //       'activo' : 1,
  //       'alert' : 0,
  //       'is_doctor' : 0,
  //       'central_alert' : 0,
  //     });
  //     if(response!.statusCode == 200){
  //       print('TOKEN ENVIADO');
  //       var value = jsonDecode(response.body);
  //       await SharedPreferencesClass().setIntValue('idServerS4C',value['data']['id']);
  //     }
  //   }catch(e){
  //     print('createToken: ${e.toString()}');
  //   }
  // }
  //
  // static Future updateToken({required String idTablet, required String business, required String room, required int idServer }) async {
  //   try{
  //     var response = await ConnectionHttp().httpPutServerToken(body: {
  //       'nombre' : '$idTablet|$business|$room',
  //       'url' : token,
  //       'activo' : 1,
  //       'alert' : 0,
  //       'is_doctor' : 0,
  //       'central_alert' : 0,
  //     },idTablet: idServer);
  //     if(response!.statusCode == 200){
  //       print('MODIFICANDO TOKEN');
  //     }
  //   }catch(e){
  //     print('createToken: ${e.toString()}');
  //   }
  // }

  // Future<Response> httpSendMessage({required String to, required bool isDoctor, required String description}) async{
  //   var url = "https://fcm.googleapis.com/fcm/send";
  //
  //   Map<String, String> requestHeaders = {
  //     'Content-Type' : 'application/json',
  //     'Authorization': 'key=AAAALnHxHzg:APA91bEsObY1Z5w8U0MZBbJKkrZwBbZEU-SBANlSwggh_lIKx72D3ukglRdHOeLOrb_xacYDchv7zcQEqRlu69R4QFlJQjdR20wptLj8f2Rbp7k7E8T9PVW2hzU0_fbvv5BkNBVIaqAX'
  //   };
  //
  //   String sms = 'Solicitud de llamada con : $description';
  //
  //   final msg = jsonEncode({
  //     "notification": {
  //       "body" : sms,
  //     },
  //     "priority":"high",
  //     "data" : {
  //       "open_canal" : true,
  //       "is_doctor" : isDoctor,
  //       "description" : description
  //     },
  //     "to" : "$to"
  //   });
  //
  //   var response;
  //   try{
  //     response = await http.post(
  //         Uri.parse(url),
  //         headers: requestHeaders,
  //         body: msg
  //     );
  //   }catch(ex){
  //     print(ex.toString());
  //   }
  //   return response;
  // }
}