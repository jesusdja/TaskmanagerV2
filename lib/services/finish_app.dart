import 'package:tra_s4c/services/shared_preferences.dart';

Future<void> finishApp() async{
  try{
    await SharedPreferencesClass().deleteValue('S4CNameDB');
    await SharedPreferencesClass().deleteValue('s4cUserLogin');
    await SharedPreferencesClass().deleteValue('S4CIdTablet');
    await SharedPreferencesClass().deleteValue('S4CBusiness');
    await SharedPreferencesClass().deleteValue('S4CRoom');
    await SharedPreferencesClass().deleteValue('s4cTypeLogin');
    await SharedPreferencesClass().deleteValue('S4CAlojamientoUF');
    print('TODO LIMPIO');
  }catch(e){
    print(e.toString());
  }
}