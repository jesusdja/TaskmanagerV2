import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:tra_s4c/config/s4c_colors.dart';
import 'package:tra_s4c/config/s4c_style.dart';
import 'package:tra_s4c/initial_page.dart';
import 'package:tra_s4c/main.dart';
import 'package:tra_s4c/models/user_model.dart';
import 'package:tra_s4c/services/http_connection.dart';
import 'package:tra_s4c/services/shared_preferences.dart';
import 'package:tra_s4c/services/sqflite.dart';
import 'package:tra_s4c/services/updateDataHttpToSqlflite.dart';
import 'package:tra_s4c/views/home/home_page.dart';
import 'package:tra_s4c/widgets_utils/avatar_widget.dart';
import 'package:tra_s4c/widgets_utils/button_general.dart';
import 'package:tra_s4c/widgets_utils/circular_progress_colors.dart';
import 'package:tra_s4c/widgets_utils/textfield_general.dart';
import 'package:tra_s4c/widgets_utils/toast_widget.dart';

class SensorSearch extends StatefulWidget {
  @override
  _SensorSearchState createState() => _SensorSearchState();
}

class _SensorSearchState extends State<SensorSearch> {

  bool loadWithSensor = true;
  bool inInitialData = false;
  TextEditingController controllerPin = TextEditingController();
  bool obscure = false;
  StreamSubscription? _streamRanging;
  Beacon? beaconsSelect;
  String name = '';
  String inPIN = '';
  Map<String,Beacon> listBeacons = {};
  Map<String,DateTime> beaconsTime = {};
  Map<String,UserModel> users = {};
  StreamSubscription? streamSubscriptionBloc;

  @override
  void initState() {
    super.initState();
    playSearchBeacons();
    initialData();
    _initializeBloc();
  }

  Future<void> initialData() async {


    UpdateDataHttpToSqlLite().getUsersHttp();
    UpdateDataHttpToSqlLite().getPatientsHttp();

    if(mounted){
      users = await  DatabaseProvider.db.getAllUserMap();
      // Beacon beacon = Beacon(
      //   accuracy: 0.31,
      //   major: 0,
      //   minor: 0,
      //   proximityUUID: '7E882318-3A36-4706-9324-AC233F8C7CEB',
      //   macAddress: '4C:63:71:80:0A:65',
      // );
      // listBeacons.add(beacon);
      // listBeacons.add(beacon);
      // listBeacons.add(beacon);
      // listBeacons.add(beacon);
      // listBeacons.add(beacon);
      // listBeacons.add(beacon);
      // listBeacons.add(beacon);
      // listBeacons.add(beacon);
      // listBeacons.add(beacon);
      // listBeacons.add(beacon);
      // listBeacons.add(beacon);
      // listBeacons.add(beacon);
      // listBeacons.add(beacon);
      // listBeacons.add(beacon);
      setState(() {});
    }
  }

  Future<void> initialData2() async {
    if(!inInitialData && mounted){
      inInitialData = true;
      setState(() {});

      await UpdateDataHttpToSqlLite().getUsersHttp();
      await UpdateDataHttpToSqlLite().getPatientsHttp();
      users = await  DatabaseProvider.db.getAllUserMap();

      inInitialData = false;
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    _streamRanging?.cancel();
    streamSubscriptionBloc?.cancel();
  }

  @override
  Widget build(BuildContext context) {

    // return GestureDetector(
    //   onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
    //   child: Scaffold(
    //     body: loadWithSensor ? Center(
    //       child: ButtonGeneral(
    //         title: 'Login beacons',
    //         icon: Icon(Icons.pause_presentation_sharp,size: 50),
    //         width: 300,
    //         height: 80,
    //         backgroundColor: Colors.blueAccent,
    //         loadButton: false,
    //         onPressed: (){
    //           Beacon beacon = Beacon(
    //             accuracy: 0.31,
    //             major: 0,
    //             minor: 0,
    //             proximityUUID: '7E882318-3A36-4706-9324-AC233F8C7CEB',
    //             macAddress: '4C:63:71:80:0A:65',
    //           );
    //           getDataBeacons(beacon);
    //         },
    //       ),
    //     ) : beaconSuccess(),
    //   ),
    // );


    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Scaffold(
        backgroundColor: S4CColors().colorLoginPageBack,
        body: Column(
          children: [
            appBarWidget(),
            beaconsSelect == null ?
            Expanded(
              child: listBeacons.isEmpty ?
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: sizeH * 0.2,
                    width: sizeH * 0.2,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: Image.asset("assets/image/search-becoins-animate${idTemplate == 0 ? '' : '_black'}.gif").image,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Text('Buscando beacons',style: S4CStyles().stylePrimary(size: sizeH * 0.035,color: S4CColors().colorLoginPageButtonText,fontWeight: FontWeight.bold),)
                ],
              ) : listViewBeacons(),
            ) :
            Expanded(
              child: Container(
                child: loadWithSensor ?
                Center(
                  child: circularProgressColors(widthContainer1: sizeW,widthContainer2: sizeH * 0.1,colorCircular: S4CColors().primary),
                ) :
                beaconSuccess(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget listViewBeacons(){
    String path = idTemplate == 0 ? 'icons_sensor_login' :  'icons_sensor_login_black';
    return Container(
      width: sizeW,
      child: GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: new BouncingScrollPhysics(),
        childAspectRatio: 0.85,
        children: List.generate(listBeacons.length, (index) {

          String keyList = listBeacons.keys.elementAt(index);

          UserModel? user;
          if(users.containsKey(listBeacons[keyList]!.proximityUUID)){
            user = users[listBeacons[keyList]!.proximityUUID]!;
          }

          if(user == null){
            initialData2();
            return Container();
          }
          String? nameUser = user.stnombre;
          Widget imageUser = CircleAvatar(
            radius: sizeH * 0.12,
            backgroundColor: S4CColors().primary,
            child: CircleAvatar(
              radius: sizeH * 0.118,
              backgroundColor: Colors.white,
              child: Center(
                child: Icon(Icons.person_rounded,size: sizeH * 0.22,color: S4CColors().primary,),
              ),
            ),
          );

          imageUser = CircleAvatar(
            radius: sizeH * 0.12,
            backgroundColor: S4CColors().primary,
            child: avatarCircularNet(rutaImage: user.stFoto!,radiu: sizeH * 0.118),
          );

          return InkWell(
            onTap: (){
              getDataBeacons(listBeacons[keyList]!);
            },
            child: Container(
              margin: EdgeInsets.all(sizeH * 0.03),
              decoration: BoxDecoration(
                color: S4CColors().colorLoginPageBack,
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: sizeW * 0.15,
                        child: imageUser,
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: CircleAvatar(
                            radius: sizeH * 0.0425,
                            backgroundColor: S4CColors().primary,
                            child: CircleAvatar(
                              radius: sizeH * 0.04,
                              backgroundColor: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.all(sizeH * 0.01),
                                child: Container(
                                  height: sizeH * 0.15,
                                  width: sizeH * 0.15,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: Image.asset("assets/image/$path.png").image,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: sizeW * 0.005),
                    child: Text('${nameUser!}',style: S4CStyles().stylePrimary(size: sizeH * 0.03,),textAlign: TextAlign.center,maxLines: 2),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: sizeW * 0.005),
                    child: Text('${listBeacons[keyList]!.proximityUUID}',style: S4CStyles().stylePrimary(size: sizeH * 0.015,),textAlign: TextAlign.center,maxLines: 2),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget beaconSuccess(){

    String path = idTemplate == 0 ? 'icons_sensor_login' :  'icons_sensor_login_black';

    UserModel? user;
    if(users.containsKey(beaconsSelect!.proximityUUID)){
      user = users[beaconsSelect!.proximityUUID]!;
    }
    Widget imageUser = CircleAvatar(
      radius: sizeH * 0.12,
      backgroundColor: S4CColors().primary,
      child: CircleAvatar(
        radius: sizeH * 0.118,
        backgroundColor: Colors.white,
        child: Center(
          child: Icon(Icons.person_rounded,size: sizeH * 0.22,color: S4CColors().primary,),
        ),
      ),
    );

    if(user != null){
      imageUser = CircleAvatar(
        radius: sizeH * 0.12,
        backgroundColor: S4CColors().primary,
        child: avatarCircularNet(rutaImage: user.stFoto!,radiu: sizeH * 0.118),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: sizeH * 0.15,),
          Stack(
            children: [
              Container(
                width: sizeW * 0.15,
                child: imageUser,
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(
                    radius: sizeH * 0.05,
                    backgroundColor: S4CColors().primary,
                    child: CircleAvatar(
                      radius: sizeH * 0.048,
                      backgroundColor: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(sizeH * 0.01),
                        child: Container(
                          height: sizeH * 0.2,
                          width: sizeH * 0.2,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: Image.asset("assets/image/$path.png").image,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: sizeH * 0.02,),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Text('Bienvenido',style: S4CStyles().stylePrimary(size: sizeH * 0.03,color: S4CColors().colorLoginPageText),),
                ),
                Container(
                  child: Text(' $name',style: S4CStyles().stylePrimary(size: sizeH * 0.03,color: S4CColors().colorLoginPageText,fontWeight: FontWeight.bold),),
                ),
              ],
            ),
          ),
          SizedBox(height: sizeH * 0.05,),
          Container(
            child: Text('Ingresa tu PIN de seguridad',style: S4CStyles().stylePrimary(size: sizeH * 0.02,color: S4CColors().colorLoginPageText),),
          ),
          SizedBox(height: sizeH * 0.025,),
          Container(
            margin: EdgeInsets.symmetric(horizontal: sizeW * 0.4),
            child: TextFieldGeneral(
              sizeH: sizeH,sizeW: sizeW,
              prefixIcon: Icon(Icons.lock_outline),
              suffixIcon: InkWell(
                child: Icon(!obscure ? Icons.remove_red_eye_outlined : Icons.remove_red_eye_rounded),
                onTap: (){
                  setState(() {
                    obscure = !obscure;
                  });
                },
              ),
              colorBack: Colors.transparent,
              borderColor: Colors.transparent,
              activeInputBorder: false,
              obscure: !obscure,
              textEditingController: controllerPin,
              initialValue: null,
              textInputType: TextInputType.number,
            ),
          ),
          SizedBox(height: sizeH * 0.04,),
          ButtonGeneral(
            title: 'Acceder',
            textStyle: S4CStyles().stylePrimary(size: sizeH * 0.028,color: S4CColors().colorLoginPageButtonText,fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
            icon: Container(
              margin: EdgeInsets.only(right: sizeW * 0.015),
              height: sizeH * 0.03,
              width: sizeH * 0.03,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Image.asset("assets/image/icon_access${(idTemplate == 1) ? '_black' : ''}.png").image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            titlePadding: EdgeInsets.only(left: sizeW * 0.015),
            height: sizeH * 0.07,
            width: sizeW * 0.25,
            backgroundColor: S4CColors().primary,
            onPressed: () async {
              String error = '';
              // if(controllerPin.text.isEmpty){
              //   error = 'PIN no puede estar vacio';
              // }
              if(error.isEmpty && controllerPin.text != inPIN){
                error = 'PIN incorrecto';
              }
              if(error.isEmpty){
                await SharedPreferencesClass().setStringValue('s4cLoginBeaconsPos', '1|${beaconsSelect!.proximityUUID}|0');
                Navigator.pushReplacement(context, new MaterialPageRoute(builder: (BuildContext context) => new HomePage()));
              }else{
                showAlert(text: error,isSuccess: false);
              }
            },
          ),
          SizedBox(height: sizeH * 0.1,),
        ],
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
                  margin: EdgeInsets.only(left: sizeW * 0.05),
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
          InkWell(
            onTap: (){
              Navigator.of(context).pop();
            },
            child: Container(
              height: sizeH * 0.05,
              width: sizeH * 0.05,
              margin: EdgeInsets.only(right: sizeW * 0.03),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Image.asset("assets/image/icons_door_out${idTemplate == 0 ? '' : '_black'}.png").image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future playSearchBeacons() async {
    try{
      _streamRanging = sensorBeacons.outList.listen((result) {
        filterDataBeaconsForTime(dataBeacons: result['beaconsResult']);


        // if(result.containsKey('seeBeacons') && result['seeBeacons']){
        //   print('MOSTRANDO ${result['beaconsResult'].length}');
        //   listBeacons = [];
        //   result['beaconsResult'].forEach((beacon) {
        //     print('ADD BEACON : ${beacon.proximity.toString()}');
        //     listBeacons.add(beacon);
        //   });
        //   setState(() {});
        // }
      });
    }catch(e){
      print(e.toString());
    }
  }

  Future filterDataBeaconsForTime({required List<Beacon> dataBeacons}) async{
    for(int x =0; x < dataBeacons.length; x++){
      //agregar a lista
      listBeacons[dataBeacons[x].proximityUUID] = dataBeacons[x];
      //actualizar fecha
      beaconsTime[dataBeacons[x].proximityUUID] = DateTime.now();
    }
    //revisar quien tenga la fecha con 30 segundos o mas para borrarlos
    List<String> listDeleteBeacons = [];
    beaconsTime.forEach((key, value) {
      if(DateTime.now().difference(value).inSeconds > 20){
        listDeleteBeacons.add(key);
      }
    });
    //borrar de la lista
    for(int x =0; x < listDeleteBeacons.length; x++){
      listBeacons.remove(listDeleteBeacons[x]);
    }
    setState(() {});
  }

  Future getDataBeacons(Beacon beacon)async {
    setState(() {
      beaconsSelect = beacon;
      loadWithSensor = true;
    });
    try{
        print('BUSCAR DATOS');
        var response = await ConnectionHttp().httpGetLoginBeacons(uuid: beacon.proximityUUID);
        print('OBTENIDOS LOS DATOS');
        if(response.statusCode == 200){
          var value = jsonDecode(response.body);
          String data = jsonEncode(value[0]);
          name = value[0]['stNombre'] ?? '';
          inPIN = value[0]['inPIN'] != null ? value[0]['inPIN'].toString() : '';
          await SharedPreferencesClass().setStringValue('s4cUserLogin', data);
        }else{
          String errorHttp = 'Error de conexión con el servidor';
          showAlert(text: errorHttp,isSuccess: false);
          beaconsSelect = null;
        }
    }catch(e){
      String errorHttp = 'Error de conexión con el servidor';
      showAlert(text: errorHttp,isSuccess: false);
      print('Error: ${e.toString()}');
      beaconsSelect = null;
    }
    setState(() {
      loadWithSensor = false;
    });
  }

  void _initializeBloc(){
    try {
      // ignore: cancel_subscriptions
      streamSubscriptionBloc = blocData.outList.listen((newVal) async {
        if(newVal.containsKey('refreshUserServer') && newVal['refreshUserServer']){
          initialData();
        }
      });
    } catch (e) {}
  }
}
