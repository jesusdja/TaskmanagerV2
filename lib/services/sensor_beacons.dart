import 'dart:async';
import 'dart:io';

import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:tra_s4c/models/location_model.dart';
import 'package:tra_s4c/services/shared_preferences.dart';
import 'package:tra_s4c/services/sqflite.dart';
import 'package:tra_s4c/services/updateDataHttpToSqlflite.dart';
import 'package:tra_s4c/utils/permission_handler.dart';

class SensorBeacons {
  var _patronController = StreamController<Map<String,dynamic>>.broadcast();
  Stream<Map<String,dynamic>> get outList => _patronController.stream;
  Sink<Map<String,dynamic>> get inList => _patronController.sink;
  StreamSubscription? _streamRanging;

  Future initialSensor() async{
    await SharedPreferencesClass().setStringValue('s4cLoginBeaconsPos', '0|0|0');
    await SharedPreferencesClass().setIntValue('stSos', 0);
    try {
      await flutterBeacon.initializeScanning;
      await flutterBeacon.initializeAndCheckScanning;
      playSearch();
      PermissionHandlerClass();
    }catch(e){
      print('initialSensor : ${e.toString()}');
    }
  }

  Future playSearch() async {
    try{
      final regions = <Region>[];
      if (Platform.isIOS) {
        regions.add(Region(identifier: 'Apple Airlocate',proximityUUID: 'E2C56DB5-DFFB-48D2-B060-D0F5A71096E0'));
      } else {
        regions.add(Region(identifier: 'com.beacon',));
      }
      //int cont = 8;
      _streamRanging = flutterBeacon.ranging(regions).listen((RangingResult result) async {
        //ENVIA DATA ENCONTRADA
        inList.add({'beaconsResult': result.beacons});
        // if(cont >= 8){
        //   print(result);
        //   cont = 0;
        //   inList.add({'beaconsResult': result.beacons, 'seeBeacons' : true});
        // }else{
        //   cont++;
        //   inList.add({'beaconsResult': result.beacons, 'seeBeacons' : false});
        // }
        await checkBeaconsList(beacons: result.beacons);
      });
    }catch(e){
      print('initialSensor : ${e.toString()}');
    }
  }

  Future checkBeaconsList({required List<Beacon> beacons})async{
    try{

      Map<String,LocationModel> locationBeacon = {};

      beacons.forEach((beacon) {
        LocationModel locationModel = LocationModel(
          uuid: beacon.proximityUUID,
          mac: beacon.macAddress,
          rssi: beacon.rssi,
          proximity: beacon.proximity.toString(),
          date: DateTime.now(),
        );
        bool saveLocation = false;
        //VERIFICAR SI EXISTE EN EL MAPA LOCAL
        if(!locationBeacon.containsKey(locationModel.uuid)){
          locationBeacon[beacon.proximityUUID] = locationModel;
          saveLocation = true;
        }else{
          //VERIFICAR CAMBIO DE ESTATUS
          if(locationBeacon[beacon.proximityUUID]!.proximity != locationModel.proximity){
            saveLocation = true;
            locationBeacon[beacon.proximityUUID] = locationModel;
          }else{
            //SI TIENE EL MISMO ESTATUS VERIFICAR QUE HAYA PASADO 30 MIN
            DateTime date1 = locationBeacon[beacon.proximityUUID]!.date!;
            DateTime date2 = locationModel.date!;
            if(date2.difference(date1).inMinutes >= 5){
              saveLocation = true;
              locationBeacon[beacon.proximityUUID] = locationModel;
            }
          }
        }
        if(saveLocation){
          saveLocationModel(locationModel);
        }
      });
    }catch(e){
      print('_streamRanging ${e.toString()}');
    }
  }

  Future saveLocationModel(LocationModel locationModel) async{
    try{
      locationModel.send = 0;
      await  DatabaseProvider.db.saveLocationUser(locationModel);
      print('GUARDANDO ${locationModel.uuid} || ${locationModel.proximity} || ${locationModel.date}');
      LoadDataHttpToSqlLite();
    }catch(e){
      print('saveLocationModel : ${e.toString()}');
    }
  }

  void dispose() {
    _patronController.close();
    _streamRanging?.cancel();
  }
}