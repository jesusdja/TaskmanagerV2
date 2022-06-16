import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:tra_s4c/config/s4c_colors.dart';
import 'package:tra_s4c/config/s4c_style.dart';
import 'package:tra_s4c/main.dart';
import 'package:tra_s4c/services/http_connection.dart';
import 'package:tra_s4c/services/shared_preferences.dart';
import 'package:tra_s4c/utils/get_data.dart';
import 'package:tra_s4c/utils/send_data.dart';
import 'package:tra_s4c/views/menu/sos/sos_page.dart';
import 'package:tra_s4c/widgets_utils/avatar_widget.dart';
import 'package:tra_s4c/widgets_utils/circular_progress_colors.dart';
import 'package:tra_s4c/widgets_utils/dropdownButton_generic.dart';
import 'package:tra_s4c/widgets_utils/textfield_general.dart';
import 'package:tra_s4c/widgets_utils/toast_widget.dart';

class TaskPatientHabScheduled extends StatefulWidget {
  @override
  _TaskPatientHabScheduledState createState() => _TaskPatientHabScheduledState();
}

class _TaskPatientHabScheduledState extends State<TaskPatientHabScheduled>{

  bool loadData = true;
  bool loadData2 = true;
  bool switchValue = true;
  String nameTablet = '';
  String idUfHab = '';

  Map<String,dynamic> dataUserActive = {};
  Map<int,bool> selectedMenu = {1: false, 2: true, 3: false, 4: false};
  List allTaskUnitFunctional = [];
  List allTaskUnitFunctionalData2 = [];
  Map taskSelectAssigned = {};
  Map taskSelectProgramada = {};
  Map<String,dynamic> mapResult = {};

  bool loadButtonSave = false;
  TextStyle style1 = TextStyle();

  @override
  void initState() {
    super.initState();
    dateMenu3[0] = DateTime.now().add(Duration(days: -7));
    dateMenu3[1] = DateTime.now();
    initialData();
  }

  Future initialData() async {

    switchValue = await SharedPreferencesClass().getValue('S4CSwitchValue') ?? true;
    bool isRoom = await SharedPreferencesClass().getValue('S4CisRoom') ?? true;
    String room = await SharedPreferencesClass().getValue('S4CRoom') ?? '';
    idUfHab = await SharedPreferencesClass().getValue('S4CIdUFHab');

    if(isRoom){
      String business = await SharedPreferencesClass().getValue('S4CBusiness') ?? '';
      nameTablet = '$business - $room';
    }else{
      nameTablet = room;
    }

    try{
      String data = await SharedPreferencesClass().getValue('s4cUserLogin') ?? '';
      dataUserActive = jsonDecode(data);
    }catch(e){
      print('initialData: ${e.toString()}');
    }

    try{
      String existA = await SharedPreferencesClass().getValue('s4cTaskUnitFunctionalAll') ?? '';
      if(existA.isNotEmpty){
        List value = jsonDecode(existA);
        allTaskUnitFunctional = value;
        loadData = false;
      }
    }catch(e){
      print('allTaskUnitFunctional: ${e.toString()}');
    }

    try{
      String existB = await SharedPreferencesClass().getValue('s4cTaskUnitFunctionalAll2') ?? '';
      if(existB.isNotEmpty){
        List value = jsonDecode(existB);
        allTaskUnitFunctionalData2 = value;
        loadData2 = false;
      }
    }catch(e){
      print('allTaskUnitFunctionalData2: ${e.toString()}');
    }

    if(mounted){
      setState(() {});
      await loadDataAll1();
      await loadDataAll2();
      await loadDataAll3();
    }
  }

  Future loadDataAll1()async{
    try{
      Response? response;
      bool isRoom = await SharedPreferencesClass().getValue('S4CisRoom') ?? true;
      if(isRoom){
        response = await ConnectionHttp().httpGetControlesMantenimientoHabitacion();
      }else{
        response = await ConnectionHttp().httpGetDataTaskUnitFunctional();
      }

      if(response != null && response.statusCode == 200){
        allTaskUnitFunctional = jsonDecode(response.body);
        await SharedPreferencesClass().setStringValue('s4cTaskUnitFunctionalAll',response.body);
      }else{
        showAlert(text: 'Error para cargar tareas asignadas',isSuccess: false);
      }
    }catch(e){
      print('Error: ${e.toString()}');
      showAlert(text: 'Error de conexión',isSuccess: false);
    }

    if(mounted){
      setState(() {
        loadData = false;
      });
    }
  }

  Future loadDataAll2()async{
    try{
      Response? response;
      bool isRoom = await SharedPreferencesClass().getValue('S4CisRoom') ?? true;
      if(isRoom){
        response = await ConnectionHttp().httpGetControlesMantenimientoProgramadosHab();
      }else{
        response = await ConnectionHttp().httpGetControlesMantenimientoProgramados();
      }

      if(response != null && response.statusCode == 200){
        allTaskUnitFunctionalData2 = jsonDecode(response.body);
        await SharedPreferencesClass().setStringValue('s4cTaskUnitFunctionalAll2',response.body);
      }else{
        showAlert(text: 'Error para cargar tareas programadas',isSuccess: false);
      }
    }catch(e){
      print('Error: ${e.toString()}');
      showAlert(text: 'Error de conexión',isSuccess: false);
    }

    if(mounted){
      setState(() {
        loadData2 = false;
      });
    }
  }

  bool loadDataSuccess = true;
  bool loadDataSuccess2 = true;
  List listTaskSuccess = [];
  Map<int,DateTime> dateMenu3 = {};
  Map<String,bool> dateMenu3Open = {};
  Map<String,bool> dateMenu3Open2 = {};
  Map<String,dynamic> allTaskSuccess2 = {};
  Map<String,dynamic> allTaskSuccess3 = {};

  Future loadDataAll3()async{

    loadDataSuccess2 = true;
    listTaskSuccess = [];
    dateMenu3Open = {};
    dateMenu3Open2 = {};
    allTaskSuccess2 = {};
    allTaskSuccess3 = {};
    setState(() {});

    String centro  = await SharedPreferencesClass().getValue('S4CNameDB') ?? '';
    try{

      DateTime dateIni = dateMenu3[0] ?? DateTime.now();
      DateTime dateFin = dateMenu3[1] ?? DateTime.now();

      Map<String,dynamic> body = {
        "centro": centro,
        "idclasificacion": 5,
        "idasistido": int.parse(idUfHab),
        "fxinicio":"${dateIni.day.toString().padLeft(2,'0')}/${dateIni.month.toString().padLeft(2,'0')}/${dateIni.year}",
        "fxfin":"${dateFin.day.toString().padLeft(2,'0')}/${dateFin.month.toString().padLeft(2,'0')}/${dateFin.year}"
      };

      Response response = await ConnectionHttp().httpPostGetControlesRealizados(body: body);
      if(response.statusCode == 200){
        listTaskSuccess = jsonDecode(response.body);
        listTaskSuccess.forEach((element) {
          dateMenu3Open[element['idtareaauxasistido'].toString()] = false;
        });
      }else{
        String errorHttp = 'Error para cargar tareas realizadas';
        showAlert(text: errorHttp,isSuccess: false);
      }
    }catch(e){
      print('Error: ${e.toString()}');
      showAlert(text: 'Error de conexión',isSuccess: false);
    }

    if(mounted){
      setState(() {
        loadDataSuccess = false;
        loadDataSuccess2 = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    style1 = S4CStyles().stylePrimary(size: sizeH * 0.017,color: Colors.grey);
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            appBarWidget(),
            Expanded(
              child: contentsHome(),
            )
          ],
        ),
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
                  margin: EdgeInsets.only(left: sizeW * 0.02),
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
            splashColor: S4CColors().primary,
            focusColor: S4CColors().primary,
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

  Widget contentsHome(){
    return Container(
      width: sizeW,
      child: Row(
        children: [
          menuIzq(),
          Expanded(child: menuDer()),
        ],
      ),
    );
  }

  Widget menuIzq(){

    Widget imageUser = Container(
      child: CircleAvatar(
        radius: sizeH * 0.05,
        backgroundColor: S4CColors().primary,
        child: CircleAvatar(
          radius: sizeH * 0.045,
          backgroundColor: S4CColors().primary,
          child: Center(
            child: Icon(Icons.person_rounded,size: sizeH * 0.07,color: Colors.white,),
          ),
        ),
      ),
    );
    if(dataUserActive.isNotEmpty && dataUserActive.containsKey('stFoto') && dataUserActive['stFoto'].toString().isNotEmpty){
      imageUser = CircleAvatar(
        radius: sizeH * 0.05,
        backgroundColor: S4CColors().primary,
        child: avatarCircularNet(rutaImage: dataUserActive['stFoto'],radiu: sizeH * 0.048),
      );
    }

    return Container(
      width: sizeW * 0.11,
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(height: sizeH * 0.025,),
          imageUser,
          //SizedBox(height: sizeH * 0.07,),
          textMenuIzq(type: 1),
          textMenuIzq(type: 2),
          textMenuIzq(type: 3),
          textMenuIzq(type: 4),
          Expanded(child: Container(),),
          menuIzqSos(),
          SizedBox(height: sizeH * 0.05,),
        ],
      ),
    );
  }

  Widget textMenuIzq({required int type}){

    String title = 'Tareas de mantenimiento';
    if(type == 2){ title = 'Asignadas'; }
    if(type == 3){ title = 'Programadas'; }
    if(type == 4){ title = 'Realizada'; }

    return InkWell(
      onTap: () async {
        if(type != 1){
          selectedMenu = {1: false, 2: false, 3: false, 4: false};
          selectedMenu[type] = true;
          taskSelectAssigned = {};
          taskSelectProgramada = {};
          setState(() {});
        }
      },
      child: Container(
        width: sizeW,
        color: selectedMenu[type]! ? S4CColors().colorLoginPageBack : Colors.white,
        padding: EdgeInsets.symmetric(vertical: sizeH * 0.025),
        child: Text(title,
          style: S4CStyles().stylePrimary(
            size: sizeH * 0.018,
            color: S4CColors().primary,
            fontWeight: FontWeight.bold,
          ),textAlign: TextAlign.center,),
      ),
    );
  }

  Widget menuIzqSos({int type = 1}){
    String path = 'icon_menu_${type}_black';
    return InkWell(
      onTap: () async {
        if(type == 1){
          bool isRoom = await SharedPreferencesClass().getValue('S4CisRoom') ?? true;
          if(isRoom){
            await Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new SOSPage(isBLockWellcome: false,)));
            await SharedPreferencesClass().setIntValue('stSos', 0);
          }else{
            await setCorrelativo();
            showAlert(text: 'Alerta enviada');
          }
        }
      },
      focusColor: S4CColors().colorHomeSplashMenu,
      splashColor: S4CColors().colorHomeSplashMenu,
      hoverColor: S4CColors().colorHomeSplashMenu,
      highlightColor: S4CColors().colorHomeSplashMenu,
      child: Container(
        width: sizeH * 0.125,
        height: sizeH * 0.125,
        padding: EdgeInsets.all(sizeH * 0.012),
        child: Container(
          height: sizeH * 0.05,
          width: sizeH * 0.05,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Image.asset("assets/image/$path.png").image,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Widget menuDer(){
    return Container(
      width: sizeW,
      color: S4CColors().colorLoginPageBack,
      child: Column(
        children: [
          menuDerTop(),
          Expanded(child: selectedMenu[2]! ? menuDer1() : selectedMenu[3]! ? menuDer2() : menuDer3()),
        ],
      ),
    );
  }

  Widget menuDerTop(){

    return Container(
      width: sizeW,
      padding: EdgeInsets.symmetric(vertical: sizeH * 0.01),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Container(
              child: Text(nameTablet,style: S4CStyles().stylePrimary(
                size: sizeH * 0.03,
                color: S4CColors().primary
              ),),
            )
          ],
        ),
      ),
    );
  }

  Widget menuDer1(){
    return loadData ?
    Center(
      child: circularProgressColors(widthContainer1: sizeW,widthContainer2: sizeH * 0.1,colorCircular: S4CColors().primary),
    ) : menuDer1Container();
  }

  Widget menuDer1Container(){

    return taskSelectAssigned.isNotEmpty ?
    Container(
      width: sizeW,
      margin: EdgeInsets.only(left: sizeW * 0.01,bottom: sizeH * 0.008,right: sizeW * 0.01),
      color: Colors.white70,
      child: taskSelectedContainer(isAssigned: true),
    ) :
    Container(
      width: sizeW,
      margin: EdgeInsets.only(left: sizeW * 0.01,bottom: sizeH * 0.008,right: sizeW * 0.01),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.start,
        alignment: WrapAlignment.start,
        children: List.generate(allTaskUnitFunctional.length, (index){
          return menuDer1RowListContainer(element: allTaskUnitFunctional[index]);
        }),
      ),
    );
  }

  Widget menuDer1RowListContainer({required Map element}){

    Widget viewImageContainer = Container();
    Widget viewImage = Container(width: sizeH * 0.1,height: sizeH * 0.1);
    if(element['icono'].toString().isNotEmpty){
      Image? image = netWorkImage(ruta: element['icono']);
      if(image != null){
        viewImage = Container(
          width: sizeH * 0.1,
          height: sizeH * 0.1,
          padding: EdgeInsets.all(sizeH * 0.01),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: image.image,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        );
      }
    }

    if(!switchValue){
      viewImageContainer = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          viewImage,
          Container(
            width: sizeW * 0.125,
            padding: EdgeInsets.symmetric(horizontal: 0,vertical: sizeH * 0.005),
            child: Text('${element['sttarea'].toString()[0].toUpperCase()}${element['sttarea'].toString().substring(1).toLowerCase()}',style: S4CStyles().stylePrimary(size: sizeH * 0.02,color: S4CColors().primary,),textAlign: TextAlign.center,maxLines: 2,),
          ),
        ],
      );
    }else{
      viewImageContainer = viewImage;
    }

    return GestureDetector(
      onLongPress: (){
        customDialog(
            widgetTitle: Container(
              child: Center(
                child: Text('${element['categoria']}'),
              ),
            ),
            widgetContent: Container(
              width: sizeW * 0.3,height: sizeH * 0.3,
              child: Center(
                child: Text('${element['sttarea']}',textAlign: TextAlign.center,),
              ),
            )
        );
      },
      onTap: () {
        if(taskSelectAssigned.isEmpty || taskSelectAssigned != element){
          taskSelectAssigned = element;
        }else{
          taskSelectAssigned = {};
        }
        mapResult = {};
        setState(() {});
      },
      child: FittedBox(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: sizeW * 0.005, vertical: sizeH * 0.01),
          color: Colors.white38,
          child: Center(
            child: viewImageContainer,
          ),
        ),
      ),
    );
  }

  Widget menuDer2(){
    return loadData2 ?
    Center(
      child: circularProgressColors(widthContainer1: sizeW,widthContainer2: sizeH * 0.1,colorCircular: S4CColors().primary),
    ) : menuDer2Container();
  }

  Widget menuDer2Container(){

    return taskSelectProgramada.isNotEmpty ?
    Container(
      width: sizeW,
      margin: EdgeInsets.only(left: sizeW * 0.01,bottom: sizeH * 0.008,right: sizeW * 0.01),
      color: Colors.white70,
      child: taskSelectedContainer(isAssigned: false),
    ) :
    Container(
      width: sizeW,
      margin: EdgeInsets.only(left: sizeW * 0.01,bottom: sizeH * 0.008,right: sizeW * 0.01),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.start,
        alignment: WrapAlignment.start,
        children: List.generate(allTaskUnitFunctionalData2.length, (index){
          return menuDer2RowListContainer(element: allTaskUnitFunctionalData2[index]);
        }),
      ),
    );
  }

  Widget menuDer2RowListContainer({required Map element}){

    Widget viewImageContainer = Container();
    Widget viewImage = Container(width: sizeH * 0.1,height: sizeH * 0.1);
    if(element['icono'].toString().isNotEmpty){
      Image? image = netWorkImage(ruta: element['icono']);
      if(image != null){
        viewImage = Container(
          width: sizeH * 0.1,
          height: sizeH * 0.1,
          padding: EdgeInsets.all(sizeH * 0.01),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: image.image,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        );
      }
    }

    if(!switchValue){
      viewImageContainer = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          viewImage,
          Container(
            width: sizeW * 0.125,
            padding: EdgeInsets.symmetric(horizontal: 0,vertical: sizeH * 0.005),
            child: Text('${element['sttarea'].toString()[0].toUpperCase()}${element['sttarea'].toString().substring(1).toLowerCase()}',style: S4CStyles().stylePrimary(size: sizeH * 0.02,color: S4CColors().primary,),textAlign: TextAlign.center,maxLines: 2,),
          ),
        ],
      );
    }else{
      viewImageContainer = viewImage;
    }

    return GestureDetector(
      onLongPress: (){
        customDialog(
            widgetTitle: Container(
              child: Center(
                child: Text('${element['categoria']}'),
              ),
            ),
            widgetContent: Container(
              width: sizeW * 0.3,height: sizeH * 0.3,
              child: Center(
                child: Text('${element['sttarea']}',textAlign: TextAlign.center,),
              ),
            )
        );
      },
      onTap: () {
        if(taskSelectProgramada.isEmpty || taskSelectProgramada != element){
          taskSelectProgramada = element;
        }else{
          taskSelectProgramada = {};
        }
        mapResult = {};
        setState(() {});
      },
      child: FittedBox(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: sizeW * 0.005, vertical: sizeH * 0.01),
          color: Colors.white38,
          child: Center(
            child: viewImageContainer,
          ),
        ),
      ),
    );
  }

  Widget textTitleTaskSelectedContainer({required String title}){
    return Container(
      padding: EdgeInsets.symmetric(vertical: sizeH * 0.015),
      child: Text(title,
        style: S4CStyles().stylePrimary(
          size: sizeH * 0.02,
          color: S4CColors().primary,
          fontWeight: FontWeight.bold,
        ),textAlign: TextAlign.center,),
    );
  }

  Widget taskSelectedContainer({required bool isAssigned}){

    List indicators = [];
    String title = '';

    if(isAssigned){
      indicators = taskSelectAssigned['indicadores'];
      title = taskSelectAssigned['sttarea'];
    }else{
      indicators = taskSelectProgramada['indicadores'];
      title = taskSelectProgramada['sttarea'];
    }

    List<Widget> listW = [];

    listW.add(
      Container(
        width: sizeW,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2,child: textTitleTaskSelectedContainer(title: title),),
            InkWell(
              onTap: (){
                saveData(isAssigned: isAssigned);
              },
              child: Container(
                margin: EdgeInsets.only(right: sizeW * 0.001),
                child: loadButtonSave ?
                Container(
                  width: sizeW * 0.05,
                  height: sizeH * 0.1,
                  child: Center(
                    child: circularProgressColors(widthContainer1: sizeW,widthContainer2: sizeH * 0.05,colorCircular: S4CColors().primary),
                  ),
                ) : Icon(Icons.save,color: S4CColors().primary,size: sizeH * 0.1,),
              ),
            ),
            InkWell(
              onTap: (){
                taskSelectAssigned = {};
                taskSelectProgramada = {};
                mapResult = {};
                setState(() {});
              },
              child: Container(
                child: Icon(Icons.cancel,color: S4CColors().primary,size: sizeH * 0.1,),
              ),
            ),
          ],
        ),
      )
    );

    List<Widget> listWI = [];
    for(int x = 1; x < 8; x++){
      indicators.forEach((indicator) {
        if(indicator['fktipodato'] == x){
          listWI.add(getIndicator(type: x, indicatorMap: indicator));
        }
      });
    }
    for(int y = 0 ; y < listWI.length; y = y + 4){
      if(((listWI.length == 1) && (y == 0)) || (y == (listWI.length - 1))){
        listW.add(
            Container(
              width: sizeW,
              margin: EdgeInsets.only(bottom: sizeH * 0.05),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: listWI[y],
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                ],
              ),
            )
        );
      }
      if(((listWI.length == 2) && (y == 0)) || (y == (listWI.length - 2))){
        listW.add(
            Container(
              width: sizeW,
              margin: EdgeInsets.only(bottom: sizeH * 0.05),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: listWI[y],
                  ),
                  Expanded(
                    child: listWI[y + 1],
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                ],
              ),
            )
        );
      }
      if(((listWI.length == 3) && (y == 0)) || (y == (listWI.length - 3))){
        listW.add(
            Container(
              width: sizeW,
              margin: EdgeInsets.only(bottom: sizeH * 0.05),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: listWI[y],
                  ),
                  Expanded(
                    child: listWI[y + 1],
                  ),
                  Expanded(
                    child: listWI[y + 2],
                  ),
                  Expanded(
                    child: Container(),
                  ),
                ],
              ),
            )
        );
      }
      if((y + 4) < listWI.length){
        listW.add(
            Container(
              width: sizeW,
              margin: EdgeInsets.only(bottom: sizeH * 0.05),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: listWI[y],
                  ),
                  Expanded(
                    child: listWI[y + 1],
                  ),
                  Expanded(
                    child: listWI[y + 2],
                  ),
                  Expanded(
                    child: listWI[y + 3],
                  ),
                ],
              ),
            )
        );
      }
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(sizeH * 0.01),
      child: Column(
        children: listW,
      ),
    );
  }

  Widget getIndicator({required int type, required Map<String,dynamic> indicatorMap}){
    Widget indicatorWidget = Container();
    String key = indicatorMap['iditemeval'];

    if(type == 1){
      if(mapResult.containsKey(key)){
        mapResult[key] = mapResult[key];
      }else{
        mapResult[key] = '';
      }
      indicatorWidget = widget1(indicatorMap: indicatorMap);
    }
    //FECHA - HORA
    if(type == 2){
      if(mapResult.containsKey(key)){
        mapResult[key] = mapResult[key];
      }else{
        DateTime? date;
        TimeOfDay? time;
        mapResult[key] = [date,time];
      }
      indicatorWidget = widget2(indicatorMap: indicatorMap);
    }
    //SI/NO
    if(type == 3){
      if(mapResult.containsKey(key)){
        mapResult[key] = mapResult[key];
      }else{
        mapResult[key] = true;
      }
      indicatorWidget = widget3(indicatorMap: indicatorMap);
    }
    //NUMERICO
    if(type == 4){
      if(mapResult.containsKey(key)){
        mapResult[key] = mapResult[key];
      }else{
        mapResult[key] = 0;
      }
      indicatorWidget = widget4(indicatorMap: indicatorMap);
    }
    //SELECCION
    if(type == 5){
      if(mapResult.containsKey(key)){
        mapResult[key] = mapResult[key];
      }else{
        mapResult[key] = 0;
      }
      indicatorWidget = widget5(indicatorMap: indicatorMap);
    }
    //HORA
    if(type == 6){
      if(mapResult.containsKey(key)){
        mapResult[key] = mapResult[key];
      }else{
        TimeOfDay? time;
        mapResult[key] = time;
      }
      indicatorWidget = widget6(indicatorMap: indicatorMap);
    }
    //SELECCION MULTIPLE
    if(type == 7){
      if(mapResult.containsKey(key)){
        mapResult[key] = mapResult[key];
      }else{
        mapResult[key] = [];
      }
      indicatorWidget = widget7(indicatorMap: indicatorMap);
    }
    return indicatorWidget;
  }

  //TEXT
  Widget widget1({required Map<String,dynamic> indicatorMap}){
    return Container(
      width: sizeW,
      padding: EdgeInsets.symmetric(horizontal: sizeW * 0.02),
      child: Column(
        children: [
          Container(
            width: sizeW ,
            child: Text('${indicatorMap['stitemeval']}',style: style1,textAlign: TextAlign.left,),
          ),
          Container(
            child: TextFieldGeneral(
              constraints: BoxConstraints(maxHeight: sizeH * 0.06,minHeight: sizeH * 0.02),
              sizeHeight: sizeH * 0.02,
              maxLines: null,
              sizeH: sizeH,
              sizeW: sizeW * 0.1,
              colorBack: Colors.transparent,
              borderColor: Colors.transparent,
              activeInputBorder: true,
              textInputType: TextInputType.name,
              labelStyle: S4CStyles().stylePrimary(size: sizeH * 0.02, color: Colors.black38,fontWeight: FontWeight.bold,),
              onChanged: (valueSt){
                mapResult[indicatorMap['iditemeval']] = valueSt;
                setState(() {});
              },
            ),
          ),
          Container(
            width: sizeW,height: 1,
            color: Colors.grey,
          )
        ],
      ),
    );
  }
  //FECHA Y HORA
  Widget widget2({required Map<String,dynamic> indicatorMap}){

    List listTimeDate = mapResult[indicatorMap['iditemeval']];
    DateTime? dateSelected = listTimeDate[0] == null  ? null : listTimeDate[0];
    TimeOfDay? timeSelected = listTimeDate[1] == null ? null : listTimeDate[1];

    String date = dateSelected == null ? 'Agregar fecha' :
    '${dateSelected.day.toString().padLeft(2,'0')}/${dateSelected.month.toString().padLeft(2,'0')}/${dateSelected.year}';
    String time = timeSelected == null ? 'Agregar hora' :
    '${timeSelected.hour.toString().padLeft(2,'0')}:${timeSelected.minute.toString().padLeft(2,'0')}';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: sizeW * 0.02),
      width: sizeW,
      child: Container(
        width: sizeW,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: sizeW,
              child: Text('${indicatorMap['stitemeval']}',style: style1,textAlign: TextAlign.center,),
            ),
            InkWell(
              onTap: (){
                showDatePicker(
                    context: context,
                    initialDate: dateSelected == null ? DateTime.now() : dateSelected,
                    firstDate: DateTime(DateTime.now().year - 100),
                    lastDate: DateTime(DateTime.now().year + 1))
                    .then((value) {
                  if(value != null){
                    setState(() {
                      mapResult[indicatorMap['iditemeval']][0] = value;
                    });
                  }
                });
              },
              child: Container(
                width: sizeW,
                margin: EdgeInsets.symmetric(vertical: sizeH * 0.01),
                child: Text(date,style: S4CStyles().stylePrimary(size: sizeH * 0.017,color: S4CColors().primary,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
              ),
            ),
            InkWell(
              onTap: () async {
                TimeOfDay? timeOfDay = await showTimePicker(
                  context: context,
                  initialTime: timeSelected ?? TimeOfDay.now(),
                );
                if(timeOfDay != null){
                  mapResult[indicatorMap['iditemeval']][1] = timeOfDay;
                  setState(() {});
                }
              },
              child: Container(
                width: sizeW,
                margin: EdgeInsets.symmetric(vertical: sizeH * 0.01),
                child: Text(time,style: S4CStyles().stylePrimary(size: sizeH * 0.017,color: S4CColors().primary,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
              ),
            )
          ],
        ),
      ),
    );
  }
  //SI/NO
  Widget widget3({required Map<String,dynamic> indicatorMap}){
    bool change = false;
    if(!indicatorMap['stitemeval'].toString().contains('Realizada')){
      change = true;
    }
    return Container(
      width: sizeW,
      padding: EdgeInsets.symmetric(horizontal: sizeW * 0.02),
      child: Column(
        children: [
          Container(
            width: sizeW,
            child: Text('${indicatorMap['stitemeval']}',style: style1,textAlign: TextAlign.center,),
          ),
          Container(
            width: sizeW,
            margin: EdgeInsets.only(top: sizeH * 0.025),
            decoration: BoxDecoration(
              color: S4CColors().colorLoginPageBack,
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              border: new Border.all(
                width: 3,
                color: S4CColors().primary,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: !change ? null : (){
                      setState(() { mapResult[indicatorMap['iditemeval']] = true; });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: sizeH * 0.005),
                      color: mapResult[indicatorMap['iditemeval']] ? S4CColors().primary : Colors.white,
                      child: Text('SI',style: S4CStyles().stylePrimary(size: sizeH * 0.02,color: mapResult[indicatorMap['iditemeval']] ? Colors.white : S4CColors().primary),textAlign: TextAlign.center,),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: !change ? null : (){
                      setState(() { mapResult[indicatorMap['iditemeval']] = false; });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: sizeH * 0.005),
                      color: mapResult[indicatorMap['iditemeval']] ? Colors.white : S4CColors().primary,
                      child: Text('NO',style: S4CStyles().stylePrimary(size: sizeH * 0.02,color: mapResult[indicatorMap['iditemeval']] ? S4CColors().primary : Colors.white ),textAlign: TextAlign.center,),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // //NUMERICO
  Widget widget4({required Map<String,dynamic> indicatorMap}){
    return Container(
      width: sizeW,
      padding: EdgeInsets.symmetric(horizontal: sizeW * 0.02),
      child: Column(
        children: [
          Container(
            width: sizeW,
            child: Text('${indicatorMap['stitemeval']}',style: style1,textAlign: TextAlign.left,),
          ),
          Container(
            width: sizeW,
            //margin: EdgeInsets.only(right: sizeW * 0.2),
            child: TextFieldGeneral(
              constraints: BoxConstraints(maxHeight: sizeH * 0.06,minHeight: sizeH * 0.02),
              sizeHeight: sizeH * 0.02,
              maxLines: null,
              sizeH: sizeH,sizeW: sizeW * 0.1,
              colorBack: Colors.transparent,
              borderColor: Colors.transparent,
              activeInputBorder: true,
              labelStyle: S4CStyles().stylePrimary(size: sizeH * 0.02, color: Colors.black38,fontWeight: FontWeight.bold,),
              textInputType: TextInputType.numberWithOptions(decimal: false, signed: false),
              onChanged: (valueSt){
                mapResult[indicatorMap['iditemeval']] = valueSt;
              },
            ),
          ),
          Container(
            //margin: EdgeInsets.only(right: sizeW * 0.2),
            width: sizeW,height: 1,
            color: Colors.grey,
          )
        ],
      ),
    );
  }
  //SELECCION
  Widget widget5({required Map<String,dynamic> indicatorMap}){

    List<String> listItems = [];
    List listAux= indicatorMap['listaitems'];
    bool elementDouble = false;
    listAux.forEach((element) {
      if(listItems.contains(element['stitem'])){
        elementDouble = true;
      }else{
        listItems.add(element['stitem']);
      }
    });
    int posMap = mapResult[indicatorMap['iditemeval']];
    String itemsSelect = listItems[posMap];

    Widget wi = Container();
    try{
      wi = elementDouble ? Container() : Container(
        width: sizeW,
        //padding: EdgeInsets.symmetric(horizontal: sizeW * 0.02),
        child: Column(
          children: [
            Container(
              width: sizeW,
              child: Text('${indicatorMap['stitemeval']}',style: style1,textAlign: TextAlign.center,),
            ),
            Container(
              width: sizeW * 0.15,
              margin: EdgeInsets.only(top: sizeH * 0.025),
              decoration: BoxDecoration(
                color: S4CColors().colorLoginPageBack,
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              ),
              child: DropdownGeneric(
                backColor: Colors.transparent,
                onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
                sizeH: sizeH,
                value: itemsSelect,
                itemHeight: sizeH * 0.09,
                onChanged: (String? value) {
                  List listAux= indicatorMap['listaitems'];
                  int pos = 0; int aux = 0;
                  listAux.forEach((element) {
                    if(element['stitem'] == value){
                      pos = aux;
                    }
                    aux++;
                  });
                  mapResult[indicatorMap['iditemeval']] = pos;
                  setState(() {});
                },
                items: listItems.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Container(
                      child: Text(value,style: S4CStyles().stylePrimary(size: sizeH * 0.015),),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    }catch(e){
      print(e.toString());
    }

    return wi;
  }
  //HORA
  Widget widget6({required Map<String,dynamic> indicatorMap}){

    TimeOfDay? timeSelected = mapResult[indicatorMap['iditemeval']];
    String time = timeSelected == null ? 'Agregar hora' :
    '${timeSelected.hour.toString().padLeft(2,'0')}:${timeSelected.minute.toString().padLeft(2,'0')}';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: sizeW * 0.02),
      width: sizeW,
      child: Column(
        children: [
          Container(
            width: sizeW * 0.08,
            child: Text('${indicatorMap['stitemeval']}',style: style1,textAlign: TextAlign.center,),
          ),
          InkWell(
            onTap: () async {
              TimeOfDay? timeOfDay = await showTimePicker(
                context: context,
                initialTime: timeSelected ?? TimeOfDay.now(),
              );
              if(timeOfDay != null){
                mapResult[indicatorMap['iditemeval']] = timeOfDay;
                setState(() {});
              }
            },
            child: Container(
              width: sizeW,
              margin: EdgeInsets.symmetric(vertical: sizeH * 0.01),
              child: Text(time,style: S4CStyles().stylePrimary(size: sizeH * 0.02,color: S4CColors().primary,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
            ),
          ),
        ],
      ),
    );
  }
  //SELECCION MULTIPLE
  Widget widget7({required Map<String,dynamic> indicatorMap}){
    List<String> listItems = [];
    List listAux= indicatorMap['listaitems'];
    listAux.forEach((element) { listItems.add(element['stitem']); } );

    List listSelect = mapResult[indicatorMap['iditemeval']] ?? [];


    List<Widget> listW = [];
    listItems.forEach((item) {
      listW.add(
          InkWell(
            onTap: (){
              if(listSelect.contains(item)){
                int posItem = listSelect.indexOf(item);
                listSelect.removeAt(posItem);
                mapResult[indicatorMap['iditemeval']] = listSelect;
              }else{
                mapResult[indicatorMap['iditemeval']].add(item);
              }
              setState(() {});
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: sizeH * 0.01,horizontal: sizeW * 0.005),
              width: sizeW,
              child: Row(
                children: [
                  Expanded(
                    child: Text(item,style: S4CStyles().stylePrimary(size: sizeH * 0.018,color: S4CColors().primary,fontWeight: FontWeight.bold),),
                  ),
                  listSelect.contains(item) ? Icon( Icons.check_circle,size: sizeH * 0.03,color: S4CColors().primary,) : Container(height: sizeH * 0.03),
                ],
              ),
            ),
          )
      );
    });


    return Container(
      width: sizeW,
      padding: EdgeInsets.symmetric(horizontal: sizeW * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: sizeW,
            child: Text('${indicatorMap['stitemeval']}',style: style1,textAlign: TextAlign.center,),
          ),
          Container(
            width: sizeW,
            //margin: EdgeInsets.symmetric(horizontal: sizeW * 0.1),
            decoration: BoxDecoration(
              color: S4CColors().colorLoginPageBack,
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            child: Column(
              children: listW,
            ),
          ),
        ],
      ),
    );
  }

  Future saveData({required bool isAssigned}) async{
    loadButtonSave = true;
    setState(() {});

    String error = '';

    Map tasks = {};

    try{
      tasks = isAssigned ? taskSelectAssigned : taskSelectProgramada;

      if(tasks.isNotEmpty){
        List elementListIndicators = tasks['indicadores'];
        for(int y = 0; y < elementListIndicators.length; y++){

          Map<String,dynamic> indicator = elementListIndicators[y];

          if(indicator['fktipodato'] == 1 && (error.isEmpty || isAssigned)){
            if(mapResult[indicator['iditemeval']].toString().isNotEmpty) {
              tasks['indicadores'][y]['resultado'] = mapResult[indicator['iditemeval']];
            }else{
              error = isAssigned ? '' : 'El campo de texto no puede estar  vacio';
            }
          }

          if(indicator['fktipodato'] == 2 && (error.isEmpty || isAssigned)) {
            if(mapResult[indicator['iditemeval']][0] != null || mapResult[indicator['iditemeval']][1] != null){
              try{
                DateTime date = mapResult[indicator['iditemeval']][0];
                TimeOfDay timeSelected = mapResult[indicator['iditemeval']][1];
                DateTime dateTotal = DateTime.parse('${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')} ${timeSelected.hour.toString().padLeft(2,'0')}:${timeSelected.minute.toString().padLeft(2,'0')}');
                String stDate = '/\\Date(${dateTotal.millisecondsSinceEpoch}${dateTotal.timeZoneName}00)/\\';
                tasks['indicadores'][y]['resultado'] = stDate;
              }catch(_){
                error = isAssigned ? '' : 'Error con el campo fecha y hora';
              }
            }else{
              error = isAssigned ? '' : 'El campo fecha y hora no puede estar vacio';
            }
          }

          if(indicator['fktipodato'] == 3 && (error.isEmpty || isAssigned)) {
            tasks['indicadores'][y]['resultado'] = mapResult[indicator['iditemeval']] == true ? 'Si' : 'No';
          }

          if(indicator['fktipodato'] == 4 && (error.isEmpty || isAssigned)) {
            if(mapResult[indicator['iditemeval']] != 0){
              tasks['indicadores'][y]['resultado'] = mapResult[indicator['iditemeval']].toString();
            }else{
              error = isAssigned ? '' : 'El campo ${indicator['stitemeval']} no puede estar vacio';
            }
          }

          if(indicator['fktipodato'] == 5 && (error.isEmpty || isAssigned)) {
            int pos = mapResult[indicator['iditemeval']];
            tasks['indicadores'][y]['resultado'] = tasks['indicadores'][y]['listaitems'][pos]['stitem'];
          }

          if(indicator['fktipodato'] == 6 && (error.isEmpty || isAssigned)) {
            if(mapResult[indicator['iditemeval']] == null){
              TimeOfDay timeSelected = mapResult[indicator['iditemeval']];
              final now = new DateTime.now();
              DateTime date = DateTime(now.year, now.month, now.day, timeSelected.hour, timeSelected.minute);
              DateTime dateTotal = DateTime.parse('${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')} ${timeSelected.hour.toString().padLeft(2,'0')}:${timeSelected.minute.toString().padLeft(2,'0')}');
              String stDate = '/\\Date(${dateTotal.millisecondsSinceEpoch}${dateTotal.timeZoneName}00)/\\';
              tasks['indicadores'][y]['resultado'] = stDate;
            }else{
              error = isAssigned ? '' : 'Debe seleccionar la hora';
            }
          }
          if(indicator['fktipodato'] == 7 && (error.isEmpty || isAssigned)) {
            List listItems = mapResult[indicator['iditemeval']];
            if(listItems.isNotEmpty){
              String items = '';
              for(int z = 0; z < listItems.length; z++){
                if(z == 0){
                  items = '${listItems[z]}';
                }else{
                  items = '$items|${listItems[z]}';
                }
              }
              tasks['indicadores'][y]['resultado'] = items;
            }else{
              error = isAssigned ? '' : 'Debe seleccionar al menos un campo en la selcción multiple';
            }
          }
        }

        if(dataUserActive.containsKey('fkEmpleado')){
          tasks['fkempleado'] = dataUserActive['fkEmpleado'];
        }
        if(dataUserActive.containsKey('idUsuario')){
          tasks['fkusuario'] = dataUserActive['idUsuario'];
        }

        if(error.isEmpty){
          print(tasks);
          try{
            var response = await ConnectionHttp().httpPostSetControlMobileOne(body: tasks);
            if(response!.statusCode == 200){
              var value = jsonDecode(response.body);
              if(value == 0){
                showAlert(text: 'Indicador enviado con exito');
                taskSelectAssigned = {};
                taskSelectProgramada = {};
                mapResult = {};
                initialData();
              }else{
                showAlert(text: 'Error al enviar la información',isSuccess: false);
              }
            }
          }catch(e){
            print('saveData2 : ${e.toString()}');
            showAlert(text: 'Error al enviar la información',isSuccess: false);
          }
        }else{
          showAlert(text: error,isSuccess: false);
        }
      }
    }catch(e){
      error = 'Error al enviar la información';
      print('saveData : ${e.toString()}');
      showAlert(text: error,isSuccess: false);
    }

    loadButtonSave = false;
    setState(() {});
  }

  void customDialog({required Widget widgetTitle, required Widget widgetContent}) {
    showGeneralDialog(barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                title: widgetTitle,
                content: widgetContent,
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) { return Container(); });
  }

  Widget menuDer3(){
    return loadDataSuccess ?
    Center(
      child: circularProgressColors(widthContainer1: sizeW,widthContainer2: sizeH * 0.1,colorCircular: S4CColors().primary),
    )
        :
    menuDer3Container();
  }

  Widget menuDer3Container(){

    List<Widget> listW = [menuDer3Date(),SizedBox(height: sizeH * 0.02,)];

    if(loadDataSuccess2){
      listW.add(SizedBox(height: sizeH * 0.1,));
      listW.add(
          Center(
            child: circularProgressColors(widthContainer1: sizeW,widthContainer2: sizeH * 0.05,colorCircular: S4CColors().primary),
          )
      );
    }else{
      listTaskSuccess.forEach((element) {
        listW.add(menuDer3ContainerRow(dataSuccess: element));
      });
    }

    listW.add(SizedBox(height: sizeH * 0.02,));

    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: listW,
        ),
      ),
    );
  }

  Widget menuDer3ContainerRow({required Map<String,dynamic> dataSuccess}){

    bool selectedOpen = dateMenu3Open[dataSuccess['idtareaauxasistido'].toString()] ?? false;

    return Container(
      child: Column(
        children: [
          InkWell(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: sizeH * 0.008),
              width: sizeW,
              color: Colors.grey[400],
              margin: EdgeInsets.only(top: sizeH * 0.002),
              child: Row(
                children: [
                  Icon(selectedOpen ? Icons.arrow_drop_down_outlined : Icons.arrow_right,color: Colors.white,size: sizeW * 0.02,),
                  Container(
                    child: Text(dataSuccess['sttareaaux'] ?? '',style: S4CStyles().stylePrimary(size: sizeH * 0.015,fontWeight: FontWeight.bold,color: Colors.black54),),
                  )
                ],
              ),
            ),
            onTap: (){
              dateMenu3Open[dataSuccess['idtareaauxasistido'].toString()] = !dateMenu3Open[dataSuccess['idtareaauxasistido'].toString()]!;
              if(dateMenu3Open[dataSuccess['idtareaauxasistido'].toString()] ?? false){
                getRealizadosEvals(
                  idtareaauxasistido: dataSuccess['idtareaauxasistido'].toString(),
                );
              }
              setState(() {});
            },
          ),
          selectedOpen ?
          allTaskSuccess2.containsKey(dataSuccess['idtareaauxasistido'].toString()) ?
          menuDer3ContainerRowBranch2(idtareaauxasistido: dataSuccess['idtareaauxasistido'].toString()) :
          Container(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(S4CColors().primary)),height: sizeH * 0.02,width: sizeH * 0.02,margin: EdgeInsets.symmetric(vertical: sizeH * 0.01),)
              : Container()
        ],
      ),
    );
  }

  Widget menuDer3ContainerRowBranch2({required String idtareaauxasistido}){

    List<Widget> listW = [];
    List listAsistidos = allTaskSuccess2[idtareaauxasistido] ?? [];
    List listAsistidosOrder = orderListAsistidoForDate(listAsistidos: listAsistidos);
    listAsistidosOrder.forEach((asistido) {
      listW.add(menuDer3ContainerRowBranch2Container(asistido: asistido,idtareaauxasistido: idtareaauxasistido));
    });

    return Container(
      width: sizeW,
      padding: EdgeInsets.only(left: sizeW * 0.025),
      color: Colors.grey[100],
      child: Column(
        children: listW,
      ),
    );
  }

  Widget menuDer3ContainerRowBranch2Container({required Map<String,dynamic> asistido,required String idtareaauxasistido}){

    bool selectedOpen = dateMenu3Open2['$idtareaauxasistido-${asistido['idevaltareaaux']}'] ?? false;

    return Container(
      child: Column(
        children: [
          InkWell(
            child: Container(
              width: sizeW,
              color: Colors.grey[300],
              padding: EdgeInsets.symmetric(vertical: sizeH * 0.008),
              margin: EdgeInsets.only(top: sizeH * 0.002),
              child: Row(
                children: [
                  Icon(selectedOpen ? Icons.arrow_drop_down_outlined : Icons.arrow_right,color: Colors.white,size: sizeW * 0.02,),
                  Container(
                    width: sizeW * 0.25,
                    child: Text(asistido['empleado'] ?? '',style: S4CStyles().stylePrimary(size: sizeH * 0.015,fontWeight: FontWeight.bold,color: Colors.black54),),
                  ),
                  SizedBox(width: sizeW * 0.05,),
                  Expanded(
                    child: Text('Fecha de registro: ${asistido['fxsuceso'] ?? ''}',style: S4CStyles().stylePrimary(size: sizeH * 0.015,fontWeight: FontWeight.bold,color: Colors.black54),textAlign: TextAlign.left),
                  ),
                ],
              ),
            ),
            onTap: (){
              dateMenu3Open2['$idtareaauxasistido-${asistido['idevaltareaaux']}'] = !dateMenu3Open2['$idtareaauxasistido-${asistido['idevaltareaaux']}']!;
              setState(() {});
              if(dateMenu3Open2['$idtareaauxasistido-${asistido['idevaltareaaux']}'] ?? false){
                getRealizadosEvalsItems(idevaltareaaux: asistido['idevaltareaaux'].toString(),idtareaauxasistido: idtareaauxasistido);
              }
            },
          ),
          selectedOpen ?
          allTaskSuccess3.containsKey('$idtareaauxasistido-${asistido['idevaltareaaux']}') ?
          menuDer3ContainerRowBranch3(idtareaauxasistido: idtareaauxasistido, idevaltareaaux: asistido['idevaltareaaux'].toString()) :
          Container(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(S4CColors().primary)),height: sizeH * 0.02,width: sizeH * 0.02,margin: EdgeInsets.symmetric(vertical: sizeH * 0.01),)
              : Container(),
        ],
      ),
    );
  }

  Widget menuDer3ContainerRowBranch3({required String idevaltareaaux,required String idtareaauxasistido}){

    List<Widget> listW = [];
    List listTaskForAsistido = allTaskSuccess3['$idtareaauxasistido-$idevaltareaaux'] ?? [];

    listW.add(menuDer3ContainerRowBranch3Title());

    listTaskForAsistido.forEach((task) {
      listW.add(menuDer3ContainerRowBranch3Container(task: task));
    });

    return Container(
      width: sizeW,
      padding: EdgeInsets.only(left: sizeW * 0.025),
      color: Colors.grey[100],
      child: Column(
        children: listW,
      ),
    );
  }

  Widget menuDer3ContainerRowBranch3Container({required Map<String,dynamic> task}){

    String resultado = '';
    try{
      resultado = task['resultado'] ?? '';
      if(task['indicador'].contains('HORA')){
        String miliSt = resultado.replaceAll('/\\Date(', '');
        String miliSt2 = '';
        for(int x =0; x < miliSt.length;x++){
          if(miliSt[x] != 'G'){
            miliSt2 = '$miliSt2${miliSt[x]}';
          }else{
            x = miliSt.length + 1;
          }
        }
        DateTime date = DateTime.fromMillisecondsSinceEpoch(int.parse(miliSt2));
        resultado = '${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}';
      }
    }catch(e){
      print('menuDer3ContainerRowBranch3Container: ${e.toString()}');
    }

    return Container(
      child: Column(
        children: [
          InkWell(
            child: Container(
              width: sizeW,
              color: Colors.grey[300],
              padding: EdgeInsets.symmetric(vertical: sizeH * 0.01),
              margin: EdgeInsets.only(top: sizeH * 0.002),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(left: sizeW * 0.01),
                      child: Text(task['indicador']),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: sizeW * 0.35),
                    width: sizeW * 0.2,
                    child: Text(resultado),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget menuDer3ContainerRowBranch3Title(){

    return Container(
      width: sizeW,
      padding: EdgeInsets.symmetric(vertical: sizeH * 0.01),
      child: Row(
        children: [
          Expanded(
            child: Container(
              child: Text('Item'),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: sizeW * 0.35),
            width: sizeW * 0.2,
            child: Text('Resultado'),
          )
        ],
      ),
    );
  }

  Future getRealizadosEvals({required String idtareaauxasistido})async{
    try{

      String centro  = await SharedPreferencesClass().getValue('S4CNameDB') ?? '';
      DateTime dateIni = dateMenu3[0] ?? DateTime.now();
      DateTime dateFin = dateMenu3[1] ?? DateTime.now();

      Map<String,dynamic> body = {
        "centro": centro,
        "idclasificacion":1,
        "idtareaauxasistido": idtareaauxasistido,
        "fxinicio":"${dateIni.day.toString().padLeft(2,'0')}/${dateIni.month.toString().padLeft(2,'0')}/${dateIni.year}",
        "fxfin":"${dateFin.day.toString().padLeft(2,'0')}/${dateFin.month.toString().padLeft(2,'0')}/${dateFin.year}"
      };

      Response response = await ConnectionHttp().httpPostGetRealizadosEvals(body: body);
      if(response.statusCode == 200){
        List value = jsonDecode(response.body);
        value.forEach((element) {
          allTaskSuccess2[idtareaauxasistido.toString()] = value;
          dateMenu3Open2['$idtareaauxasistido-${element['idevaltareaaux']}'] = false;
        });
      }else{
        getRealizadosEvals(idtareaauxasistido: idtareaauxasistido);
      }
    }catch(e){
      print('Error: ${e.toString()}');
      getRealizadosEvals(idtareaauxasistido: idtareaauxasistido);
    }

    setState(() {});
  }

  Future getRealizadosEvalsItems({required String idevaltareaaux,required String idtareaauxasistido})async{
    try{
      Response response = await ConnectionHttp().httpGetControlesEvalItems(idevaltareaaux: idevaltareaaux);
      if(response.statusCode == 200){
        List value = jsonDecode(response.body);
        allTaskSuccess3['$idtareaauxasistido-$idevaltareaaux'] = value;
      }else{
        getRealizadosEvalsItems(idevaltareaaux: idevaltareaaux,idtareaauxasistido: idtareaauxasistido);
      }
    }catch(e){
      print('Error: ${e.toString()}');
      getRealizadosEvalsItems(idevaltareaaux: idevaltareaaux, idtareaauxasistido: idtareaauxasistido);
    }
    setState(() {});
  }

  Widget menuDer3Date(){

    return Container(
      width: sizeW,
      child: Row(
        children: [
          menuDer3DateContainer(type: 0),
          menuDer3DateContainer(type: 1),
        ],
      ),
    );
  }

  Widget menuDer3DateContainer({required int type}){
    String dateSt = '';
    DateTime dateTime = dateMenu3[type] ?? DateTime.now();
    dateSt = '${dateTime.day.toString().padLeft(2,'0')}/${dateTime.month.toString().padLeft(2,'0')}/${dateTime.year}';

    String title = type == 0 ? 'Fecha desde:' : 'Fecha hasta:';

    return Container(
      child: Row(
        children: [
          SizedBox(width: sizeW * 0.02,),
          Text(title),
          SizedBox(width: sizeW * 0.02,),
          InkWell(
            child: Container(
              margin: EdgeInsets.only(right: sizeW * 0.05,top: sizeH * 0.005),
              padding: EdgeInsets.all(sizeH * 0.02),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                border: Border.all(
                  color : S4CColors().colorLoginPageBack,
                  width : 1.0,
                  style : BorderStyle.solid,
                ),
              ),
              child: Text(dateSt),
            ),
            onTap:(){
              showDatePicker(
                  context: context,
                  initialDate: dateMenu3[type] ?? DateTime.now(),
                  firstDate: DateTime(DateTime.now().year - 100),
                  lastDate: DateTime.now()).then((value) {
                if(value != null){
                  bool save = true;
                  if(type == 0){
                    int dif = value.difference(dateMenu3[1]!).inDays;
                    save = dif <= 0;
                  }else{
                    int dif = value.difference(dateMenu3[0]!).inDays;
                    save = dif >= 0;
                  }
                  if(save){
                    setState(() {
                      dateMenu3[type] = value;
                    });
                    loadDataAll3();
                  }else{
                    String error = type == 0 ? 'Fecha desde debe ser menor o igual a la fecha hasta' : 'Fecha hasta debe ser mayor o igual que la fecha desde';
                    showAlert(text: error,isSuccess: false);
                  }
                }
              });
            },
          ),
        ],
      ),
    );
  }

  List orderListAsistidoForDate({required List listAsistidos}){
    List listNew = [];
    List listCopy = listAsistidos.map((e) => e).toList();
    try{
      for(int x = 0; x < listAsistidos.length; x++){
        int pos = 0;
        String dateSt = listCopy[0]['fxsuceso'].toString();
        DateTime dateDelete = DateTime.parse('${dateSt.split('/')[2]}-${dateSt.split('/')[1]}-${dateSt.split('/')[0]}');
        for(int xx = 0; xx < listCopy.length; xx++){
          dateSt = listCopy[xx]['fxsuceso'].toString();
          DateTime dateCompare = DateTime.parse('${dateSt.split('/')[2]}-${dateSt.split('/')[1]}-${dateSt.split('/')[0]}');
          if(dateDelete.difference(dateCompare).inDays > 0){
            pos = xx;
            dateDelete = dateCompare;
          }
        }
        listNew.add(listCopy[pos]);
        listCopy.removeAt(pos);
      }
    }catch(e){
      print('orderListAsistidoForDate: ${e.toString()}');
    }
    return listNew;
  }
}



