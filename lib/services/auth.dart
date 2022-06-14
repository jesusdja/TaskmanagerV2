import 'package:flutter/material.dart';
import 'package:tra_s4c/main.dart';
import 'package:tra_s4c/services/shared_preferences.dart';

enum Status { splash,lockScreen,selectTemplate,selectDB,configTablet,typeLogin}

class AuthService with ChangeNotifier{
  Status _status = Status.splash;

  AuthService.instance();

  Status get status => _status;

  Future init() async {

    idTemplate = await SharedPreferencesClass().getValue('s4cTemplateId') ?? 0;
    //int counter = 0;
    int counter = await SharedPreferencesClass().getValue('S4CInit') ?? 0;
    if(counter == 0){
      _status = Status.selectTemplate;
    }
    if(counter == 1){
      _status = Status.selectDB;
    }
    if(counter == 2){
      _status = Status.configTablet;
    }
    if(counter == 3){
      _status = Status.typeLogin;
    }
    if(counter == 4){
      _status = Status.lockScreen;
    }
    notifyListeners();
  }
}