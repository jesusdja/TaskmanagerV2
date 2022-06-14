import 'package:flutter/material.dart';
import 'package:tra_s4c/config/s4c_colors.dart';
import 'package:tra_s4c/config/s4c_style.dart';
import 'package:tra_s4c/main.dart';
import 'package:tra_s4c/services/shared_preferences.dart';
import 'package:tra_s4c/services/updateDataHttpToSqlflite.dart';
import 'package:tra_s4c/widgets_utils/button_general.dart';
import 'package:tra_s4c/widgets_utils/circular_progress_colors.dart';
import 'package:tra_s4c/widgets_utils/textfield_general.dart';
import 'package:tra_s4c/widgets_utils/toast_widget.dart';

class GetPass extends StatefulWidget {
  @override
  _GetPassState createState() => _GetPassState();
}

class _GetPassState extends State<GetPass>{

  bool obscure = false;
  TextEditingController controllerPass = TextEditingController();
  bool updatePass = false;
  String passDb = '';
  String passSuperUser = 'TsadRozas';

  @override
  void initState() {
    super.initState();
    initial();
  }

  Future initial()async{
    passDb = await SharedPreferencesClass().getValue('S4CPasswordDB');
    try{
      int moth = DateTime.now().month;
      if(moth == 1){
        passSuperUser = '${passSuperUser}11';
      }else if(moth == 2){
        passSuperUser = '${passSuperUser}12';
      }else{
        moth = moth - 2;
        passSuperUser = '$passSuperUser${moth.toString().padLeft(2,'0')}';
      }
    }catch(_){
      passSuperUser = '';
    }
    setState(() {});
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              appBarWidget(),
              SizedBox(height: sizeH * 0.25,),
              Container(
                width: sizeW * 0.2,
                child: Text('Contraseña de validación',style: S4CStyles().stylePrimary(size: sizeH * 0.03,color: S4CColors().colorLoginPageText),textAlign: TextAlign.center),
              ),
              SizedBox(height: sizeH * 0.03,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: sizeW * 0.38),
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
                  textInputType: TextInputType.visiblePassword,
                  textEditingController: controllerPass,
                  initialValue: null,
                ),
              ),
              SizedBox(height: sizeH * 0.08,),
              ButtonGeneral(
                title: 'Confirmar',
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
                  FocusScope.of(context).requestFocus(new FocusNode());
                  await Future.delayed(Duration(milliseconds: 200));
                  String error = '';
                  if(error.isEmpty && controllerPass.text != passDb){
                    if(controllerPass.text != passSuperUser){
                      error = 'Contraseña de validación incorrecta';
                    }
                  }
                  if(error.isEmpty){

                    Navigator.of(context).pop({'user': controllerPass.text != passSuperUser ? 0 : 1});
                  }else{
                    showAlert(text: error,isSuccess: false);
                  }
                },
              ),
              SizedBox(height: sizeH * 0.04,),
              updatePass ?
              Container(
                width: sizeH * 0.04,
                height: sizeH * 0.04,
                child: Center(
                  child: circularProgressColors(widthContainer1: sizeW,widthContainer2: sizeH * 0.1,colorCircular: S4CColors().primary),
                ),
              ) :
              InkWell(
                onTap: ()=>updatePassword(),
                child: Container(
                  width: sizeW * 0.2,
                  child: Text('Actualizar contraseña',style: S4CStyles().stylePrimary(size: sizeH * 0.03,color: S4CColors().colorLoginPageText, textDecoration: TextDecoration.underline,),textAlign: TextAlign.center,),
                ),
              ),
            ],
          ),
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
            onTap: () async {
              FocusScope.of(context).requestFocus(new FocusNode());
              await Future.delayed(Duration(milliseconds: 200));
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

  Future updatePassword()async{
    updatePass = true;
    setState(() {});

    bool result = await PasswordAdmin().updatePassword();
    if(result){
      await initial();
      showAlert(text: 'Contraseña actualizada con exito');
    }else{
      showAlert(text: 'No se pudo actualizar la contraseña, problemas para conectarse con la base de datos.',isSuccess: false);
    }

    updatePass = false;
    setState(() {});
  }
}
