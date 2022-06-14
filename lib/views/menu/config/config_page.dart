import 'package:flutter/material.dart';
import 'package:tra_s4c/config/s4c_colors.dart';
import 'package:tra_s4c/config/s4c_style.dart';
import 'package:tra_s4c/main.dart';
import 'package:tra_s4c/services/shared_preferences.dart';
import 'package:tra_s4c/services/updateDataHttpToSqlflite.dart';
import 'package:tra_s4c/utils/get_data.dart';
import 'package:tra_s4c/views/login/select_config_tablet.dart';
import 'package:tra_s4c/views/login/select_db.dart';
import 'package:tra_s4c/views/login/select_template.dart';
import 'package:tra_s4c/views/login/select_type_login.dart';
import 'package:tra_s4c/widgets_utils/DialogAlert.dart';
import 'package:tra_s4c/widgets_utils/button_general.dart';
import 'package:flutter_app_restart/flutter_app_restart.dart';
import 'package:tra_s4c/widgets_utils/toast_widget.dart';

class ConfigPage extends StatefulWidget {
  ConfigPage({this.isWelcome: false, required this.superUser});
  final bool isWelcome;
  final bool superUser;
  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage>{

  bool? res = false;
  List<String> listSelectedUser = [];

  @override
  void initState() {
    super.initState();
    tokenForAzure.forEach((key, value) { listSelectedUser.add(key); });
    checkUpdateSystem();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Scaffold(
        backgroundColor: S4CColors().colorLoginPageBack,
        body: Column(
          children: [
            appBarWidget(),
            Expanded(
              child: Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: sizeW * 0.05,),
                    contentsHomeDer(),
                    SizedBox(width: sizeW * 0.05,),
                    contentsHomeIzq(),
                    SizedBox(width: sizeW * 0.05,),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget contentsHomeDer(){
    return Container(
      margin: EdgeInsets.only(top: sizeW * 0.02),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(height: sizeH * 0.1,),
            !widget.superUser ? Container() : ButtonGeneral(
              title: 'Seleccionar BB.DD.',
              textStyle: S4CStyles().stylePrimary(size: sizeH * 0.025,color: S4CColors().colorLoginPageButtonText,fontWeight: FontWeight.bold),
              height: sizeH * 0.07,
              width: sizeW * 0.325,
              textAlign: TextAlign.left,
              titlePadding: EdgeInsets.only(left: sizeW * 0.01),
              icon: Container(
                padding: EdgeInsets.only(right: sizeW * 0.01),
                child: Icon(Icons.all_inbox,size: sizeH * 0.03,color: Colors.white,),
              ),
              backgroundColor: S4CColors().primary,
              onPressed: () async {
                bool? res = await Navigator.push(context, new MaterialPageRoute(builder:
                    (BuildContext context) => new SelectDB(contextHome: null,isConfig: true,)));
                if(res != null && res){
                  UpdateDataHttpToSqlLite().getAll();
                }
              },
            ),
            SizedBox(height: sizeH * 0.05,),
            ButtonGeneral(
              title: 'Seleccionar Template',
              textStyle: S4CStyles().stylePrimary(size: sizeH * 0.025,color: S4CColors().colorLoginPageButtonText,fontWeight: FontWeight.bold),
              height: sizeH * 0.07,
              width: sizeW * 0.325,
              textAlign: TextAlign.left,
              titlePadding: EdgeInsets.only(left: sizeW * 0.01),
              icon: Container(
                padding: EdgeInsets.only(right: sizeW * 0.01),
                child: Icon(Icons.title,size: sizeH * 0.03,color: Colors.white,),
              ),
              backgroundColor: S4CColors().primary,
              onPressed: () async {
                res = await Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new SelectTemplate(contextHome: null,isConfig: true,)));
                if(res != null && res!){
                  setState(() {});
                }
              },
            ),
            SizedBox(height: sizeH * 0.05,),
            ButtonGeneral(
              title: 'Reiniciar TaskManager',
              textStyle: S4CStyles().stylePrimary(size: sizeH * 0.025,color: S4CColors().colorLoginPageButtonText,fontWeight: FontWeight.bold),
              height: sizeH * 0.07,
              width: sizeW * 0.325,
              textAlign: TextAlign.left,
              titlePadding: EdgeInsets.only(left: sizeW * 0.01),
              icon: Container(
                padding: EdgeInsets.only(right: sizeW * 0.01),
                child: Icon(Icons.flip_camera_android,size: sizeH * 0.03,color: Colors.white,),
              ),
              backgroundColor: S4CColors().primary,
              onPressed: () async {
                await FlutterRestart.restartApp();
              },
            ),
            SizedBox(height: sizeH * 0.05,),
            ButtonGeneral(
              title: titleButtonUpdateLocal[statusUpdateLocal],
              textStyle: S4CStyles().stylePrimary(size: sizeH * 0.025,color: S4CColors().colorLoginPageButtonText,fontWeight: FontWeight.bold),
              height: sizeH * 0.07,
              width: sizeW * 0.325,
              textAlign: TextAlign.left,
              titlePadding: EdgeInsets.only(left: sizeW * 0.01),
              icon: Container(
                padding: EdgeInsets.only(right: sizeW * 0.01),
                child: statusUpdateLocal == StatusUpdateLocal.checking ?
                Container(
                  height: sizeH * 0.02,width: sizeH * 0.02,
                  child: CircularProgressIndicator(),
                ) :
                Icon(Icons.system_update_alt,size: sizeH * 0.03,color: Colors.white,),
              ),
              backgroundColor: colorButtonUpdateLocal[statusUpdateLocal]!,
              onPressed: () async {
                statusUpdateLocal = StatusUpdateLocal.checking;
                setState(() {});
                await UpdateDataHttpToSqlLite().getAll();
                await Future.delayed(Duration(seconds: 3));
                statusUpdateLocal = StatusUpdateLocal.success;
                setState(() {});
                showAlert(text: 'Base de datos actualizada');
              },
            ),
            SizedBox(height: sizeH * 0.05,),
            !widget.superUser ? Container() :ButtonGeneral(
              title: 'Reiniciar Tablet',
              textStyle: S4CStyles().stylePrimary(size: sizeH * 0.025,color: S4CColors().colorLoginPageButtonText,fontWeight: FontWeight.bold),
              height: sizeH * 0.07,
              width: sizeW * 0.325,
              textAlign: TextAlign.left,
              titlePadding: EdgeInsets.only(left: sizeW * 0.01),
              icon: Container(
                padding: EdgeInsets.only(right: sizeW * 0.01),
                child: Icon(Icons.reset_tv,size: sizeH * 0.03,color: Colors.white,),
              ),
              backgroundColor: S4CColors().primary,
              onPressed: () async {

              },
            ),
          ],
        ),
      ),
    );
  }

  Widget contentsHomeIzq(){
    return Container(
      margin: EdgeInsets.only(top: sizeW * 0.02),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(height: sizeH * 0.1,),
            !widget.superUser ? Container() :ButtonGeneral(
              title: 'Configuración de Tablet',
              textStyle: S4CStyles().stylePrimary(size: sizeH * 0.025,color: S4CColors().colorLoginPageButtonText,fontWeight: FontWeight.bold),
              height: sizeH * 0.07,
              width: sizeW * 0.325,
              textAlign: TextAlign.left,
              titlePadding: EdgeInsets.only(left: sizeW * 0.01),
              icon: Container(
                padding: EdgeInsets.only(right: sizeW * 0.01),
                child: Icon(Icons.tablet,size: sizeH * 0.03,color: Colors.white,),
              ),
              backgroundColor: S4CColors().primary,
              onPressed: () async {
                await Navigator.push(context, new MaterialPageRoute(builder:
                    (BuildContext context) => new ConfigTablet(contextHome: null,isConfig: true,)));
              },
            ),
            SizedBox(height: sizeH * 0.05,),
            ButtonGeneral(
              title: 'Seleccionar Inicio de sesión',
              textStyle: S4CStyles().stylePrimary(size: sizeH * 0.025,color: S4CColors().colorLoginPageButtonText,fontWeight: FontWeight.bold),
              height: sizeH * 0.07,
              width: sizeW * 0.325,
              textAlign: TextAlign.left,
              titlePadding: EdgeInsets.only(left: sizeW * 0.01),
              icon: Container(
                padding: EdgeInsets.only(right: sizeW * 0.01),
                child: Icon(Icons.send,size: sizeH * 0.03,color: Colors.white,),
              ),
              backgroundColor: S4CColors().primary,
              onPressed: () async {
                await Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new SelectTypeLogin(contextHome: null,isConfig: true,)));
              },
            ),
            !widget.superUser ? Container() : SizedBox(height: sizeH * 0.05,),
            !widget.superUser ? Container() : ButtonGeneral(
              title: 'Formatear datos iniciales TaskManager',
              textStyle: S4CStyles().stylePrimary(size: sizeH * 0.025,color: S4CColors().colorLoginPageButtonText,fontWeight: FontWeight.bold),
              height: sizeH * 0.07,
              width: sizeW * 0.325,
              textAlign: TextAlign.left,
              titlePadding: EdgeInsets.only(left: sizeW * 0.01),
              icon: Container(
                padding: EdgeInsets.only(right: sizeW * 0.01),
                child: Icon(Icons.flip_camera_android,size: sizeH * 0.03,color: Colors.white,),
              ),
              backgroundColor: S4CColors().primary,
              onPressed: () async {
                bool res = await alertDeleteAllValue(context: context);
                if(res){
                  await SharedPreferencesClass().deleteAllValue();
                  await FlutterRestart.restartApp();
                }
              },
            ),
            SizedBox(height: sizeH * 0.05,),
            ButtonGeneral(
              title: titleButtonUpdate[statusSystem],
              textStyle: S4CStyles().stylePrimary(size: sizeH * 0.025,color: S4CColors().colorLoginPageButtonText,fontWeight: FontWeight.bold),
              height: sizeH * 0.07,
              width: sizeW * 0.325,
              textAlign: TextAlign.left,
              titlePadding: EdgeInsets.only(left: sizeW * 0.01),
              icon: Container(
                padding: EdgeInsets.only(right: sizeW * 0.01),
                child: statusSystem == StatusSystem.checking ?
                Container(
                  height: sizeH * 0.02,width: sizeH * 0.02,
                  child: CircularProgressIndicator(),
                ) :
                Icon(Icons.system_update_alt,size: sizeH * 0.03,color: Colors.white,),
              ),
              backgroundColor: colorButtonUpdate[statusSystem]!,
              onPressed: () async {
                checkUpdateSystem();
              },
            ),
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

  StatusSystem statusSystem = StatusSystem.checking;
  Map<StatusSystem,String> titleButtonUpdate = {
    StatusSystem.checking: 'Verificando actualización',
    StatusSystem.outdated: 'Sistema no actualizado',
    StatusSystem.updated: 'Sistema actualizado'
  };
  Map<StatusSystem,Color> colorButtonUpdate = {
    StatusSystem.checking: Colors.orange,
    StatusSystem.outdated: Colors.redAccent,
    StatusSystem.updated: Colors.green,
  };

  StatusUpdateLocal statusUpdateLocal = StatusUpdateLocal.success;
  Map<StatusUpdateLocal,String> titleButtonUpdateLocal = {
    StatusUpdateLocal.checking: 'Actualizar base de datos local',
    StatusUpdateLocal.success: 'Actualizar base de datos local'
  };
  Map<StatusUpdateLocal,Color> colorButtonUpdateLocal = {
    StatusUpdateLocal.checking: Colors.orange,
    StatusUpdateLocal.success: S4CColors().colorLoginPageText,
  };


  Future checkUpdateSystem() async{
    statusSystem = StatusSystem.checking;
    setState(() {});

    // await Future.delayed(Duration(seconds: 3));
    // statusSystem = StatusSystem.outdated;
    // setState(() {});
    //
    // await Future.delayed(Duration(seconds: 3));
    // statusSystem = StatusSystem.checking;
    // setState(() {});

    await Future.delayed(Duration(seconds: 3));
    statusSystem = StatusSystem.updated;
    setState(() {});
  }
}
enum StatusSystem { checking,updated,outdated }
enum StatusUpdateLocal { checking,success}