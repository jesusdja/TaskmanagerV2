import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart' as provider;
import 'package:tra_s4c/main.dart';
import 'package:tra_s4c/services/auth.dart';
import 'package:tra_s4c/services/sensor_beacons.dart';
import 'package:tra_s4c/views/login/select_config_tablet.dart';
import 'package:tra_s4c/views/login/select_db.dart';
import 'package:tra_s4c/views/login/select_template.dart';
import 'package:tra_s4c/views/login/select_type_login.dart';
import 'package:tra_s4c/views/login/welcome_page.dart';
import 'package:tra_s4c/widgets_utils/page_loanding.dart';

class InitialPage extends StatefulWidget {
  @override
  _InitialPageState createState() => _InitialPageState();
}
SensorBeacons sensorBeacons = SensorBeacons();
class _InitialPageState extends State<InitialPage> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    sensorBeacons.initialSensor();
  }

  @override
  void dispose() {
    super.dispose();
    blocData.dispose();
    sensorBeacons.dispose();
  }

  @override
  Widget build(BuildContext context) {

    sizeW = MediaQuery.of(context).size.width;
    sizeH = MediaQuery.of(context).size.height;

    return provider.ChangeNotifierProvider(
      create: (_) => AuthService.instance(),
      child: provider.Consumer(
        // ignore: missing_return
        builder: (context, AuthService auth, _){
          switch (auth.status) {
            case Status.splash:
              return BasicSplash();
            case Status.lockScreen:
              return WelcomePage(contextHome: context,);
            case Status.selectTemplate:
              return SelectTemplate(contextHome: context,isConfig: false,);
            case Status.selectDB:
              return SelectDB(contextHome: context,isConfig: false,);
            case Status.typeLogin:
              return SelectTypeLogin(contextHome: context,isConfig: false,);
            case Status.configTablet:
              return ConfigTablet(contextHome: context,isConfig: false,);
            default:
              return Scaffold(body: Center(child: Text('default'),),);
          }
        },
      ),
    );
  }
}

class BasicSplash extends StatelessWidget {

  Future<bool> exit() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {

    final AuthService auth = provider.Provider.of<AuthService>(context);
    double sizeH = MediaQuery.of(context).size.height;
    double sizeW = MediaQuery.of(context).size.width;

    return WillPopScope(
        child: FutureBuilder(
          future: auth.init(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot){

            Widget bdy = Container();
            switch(snapshot.connectionState){
              case ConnectionState.none:
                bdy =  Container(
                  child: Center(
                    child: Text('Error'),
                  ),
                );
                break;
              case ConnectionState.waiting:
                bdy =  containerLoading(sizeH: sizeH, sizeW: sizeW);
                break;
              case ConnectionState.active:
                bdy =  containerLoading(sizeH: sizeH, sizeW: sizeW);
                break;
              case ConnectionState.done:
                bdy =  containerLoading(sizeH: sizeH, sizeW: sizeW);
                break;
            }
            return Scaffold(
              body: bdy,
            );
          },
        ),
        onWillPop: exit
    );
  }
}
