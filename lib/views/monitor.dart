import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:tra_s4c/main.dart';
import 'package:tra_s4c/services/shared_preferences.dart';

class Monitor extends StatefulWidget {
  @override
  _MonitorState createState() => _MonitorState();
}

class _MonitorState extends State<Monitor> {

  bool showSearch = false;
  StreamSubscription? _streamMonitoring;
  StreamSubscription? _streamRanging;
  List<String> listData = [];
  Map<String,Map<String,dynamic>> mapDataNow = {};

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  void dispose() {
    super.dispose();
    _streamMonitoring?.cancel();
    _streamRanging?.cancel();
  }

  Future initData()async{
    try {
      await flutterBeacon.initializeScanning;
      await flutterBeacon.initializeAndCheckScanning;
    } on PlatformException catch(e) {
      print('${e.toString()}');
    }

    try{
      listData = [];
      List listDataShared = await SharedPreferencesClass().getValue('listDataShared') ?? [];
      listDataShared.forEach((element) {
        listData.add(element);
      });
    }catch(e){
      print('initData : ${e.toString()}');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    sizeW = MediaQuery.of(context).size.width;
    sizeH = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Beacons'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await SharedPreferencesClass().deleteValue('listDataShared');
              initData();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if(showSearch){
            stopSearch();
          }else{
            playSearch();
          }
          showSearch = !showSearch;
          setState(() {});
        },
        child: Center(
          child: Icon(
            showSearch ? Icons.stop : Icons.play_arrow,
            color: Colors.white,
            size: sizeH * 0.05,
          ),
        ),
      ),
      body: Container(
        width: sizeW,
        child: ListView.builder(
          itemCount: listData.length,
          itemBuilder: (context,index){
            return cardElement(listData[index]);
          },
        ),
      ),
    );
  }

  Widget cardElement(String text){
    //UUID | MAC ADRESS | STATUS CERCANIA | FECHA ACTUAL DIA MES AÑO HORA MINUTO SEGUNDO
    List data = text.split('|');

    TextStyle style1 = TextStyle(fontSize: sizeH * 0.02,color: Colors.grey,fontWeight: FontWeight.w400);
    TextStyle style2 = TextStyle(fontSize: sizeH * 0.02,color: Colors.black,);

    return Container(
      width: sizeW,
      margin: EdgeInsets.symmetric(horizontal: sizeW * 0.03, vertical: sizeH * 0.01),
      padding: EdgeInsets.all(10),
      decoration: new BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        border: new Border.all(
          width: 1.5,
          color: Colors.blue,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: sizeW,
            child: Row(
              children: [
                Expanded(
                  child: Text('UUID',style: style2,textAlign: TextAlign.left,),
                ),
                SizedBox(width: sizeW * 0.02,),
                Expanded(
                  child: Text('Status',style: style2,textAlign: TextAlign.right,),
                ),
              ],
            ),
          ),

          Container(
            width: sizeW,
            child: Row(
              children: [
                Expanded(
                  child: Text(data[0],style: style1,textAlign: TextAlign.left,),
                ),
                SizedBox(width: sizeW * 0.02,),
                Expanded(
                  child: Text(data[2].toString().replaceAll('Proximity.', ''),style: style1,textAlign: TextAlign.right,),
                ),
              ],
            ),
          ),
          Container(
            width: sizeW,
            child: Row(
              children: [
                Expanded(
                  child: Text('',style: style1,textAlign: TextAlign.left,),
                ),
                SizedBox(width: sizeW * 0.02,),
                Expanded(
                  child: Text(data[3],style: style1,textAlign: TextAlign.right,),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future playSearch() async {
    try{
      final regions = <Region>[];
      if (Platform.isIOS) {
        regions.add(Region(
            identifier: 'Apple Airlocate',
            proximityUUID: 'E2C56DB5-DFFB-48D2-B060-D0F5A71096E0'));
      } else {
        regions.add(Region(identifier: 'com.beacon',));
      }
      _streamRanging = flutterBeacon.ranging(regions).listen((RangingResult result) {
        print(result);
        //UUID | MAC ADRESS | STATUS CERCANIA | FECHA ACTUAL DIA MES AÑO HORA MINUTO SEGUNDO
        if(result.beacons.isNotEmpty){
          result.beacons.forEach((beacons) {
            print(beacons.proximityUUID);
            print(beacons.macAddress);
            print(beacons.proximity);
            bool exists = mapDataNow.containsKey(beacons.proximityUUID);
            if(!exists || ((exists) && (mapDataNow[beacons.proximityUUID]!['proximity'] != '${beacons.proximity}'))){
              //GUARDAR EN LISTADO
              DateTime date = DateTime.now();
              String date1 = "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}";
              saveData('${beacons.proximityUUID}|${beacons.macAddress}|${beacons.proximity}|$date1');
              setState(() {
                mapDataNow[beacons.proximityUUID] = {
                  'proximityUUID' : '${beacons.proximityUUID}',
                  'macAddress' : '${beacons.macAddress}',
                  'proximity' : '${beacons.proximity}',
                  'date' : '$date1'
                };
              });
            }
          });
        }
      });
    }catch(e){
      print(e.toString());
    }
  }

  Future stopSearch() async {
    _streamRanging?.cancel();
  }

  Future saveData(String data) async{
    listData = [];
    listData.add(data);
    List listDataShared = await SharedPreferencesClass().getValue('listDataShared') ?? [];
    listDataShared.forEach((element) {
      listData.add(element);
    });
    setState(() {});
    await SharedPreferencesClass().setStringListValue('listDataShared',listData);
  }
}
