import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tra_s4c/config/s4c_colors.dart';
import 'package:tra_s4c/config/s4c_style.dart';
import 'package:tra_s4c/main.dart';
import 'package:tra_s4c/services/auth.dart';
import 'package:tra_s4c/services/shared_preferences.dart';

class SelectTemplate extends StatefulWidget {
  SelectTemplate({required this.contextHome, required this.isConfig});
  final BuildContext? contextHome;
  final bool isConfig;
  @override
  _SelectTemplateState createState() => _SelectTemplateState();
}

class _SelectTemplateState extends State<SelectTemplate> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: logoHelp(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            logo(),
            SizedBox(height: sizeH * 0.05,),
            Container(
              width: sizeW,
              child: Text('Seleccione el tema o plantilla con el prefiere\ntrabajar en la aplicación:',
              style: S4CStyles().stylePrimary(size: sizeH * 0.03,),textAlign: TextAlign.center,),
            ),
            SizedBox(height: sizeH * 0.08,),
            Container(
              width: sizeW,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  selectTemplateImage(type: 0),
                  SizedBox(width: sizeW * 0.05,),
                  selectTemplateImage(type: 1),
                  SizedBox(width: sizeW * 0.05,),
                  selectTemplateImage(type: 2),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget selectTemplateImage({required int type}){
    return InkWell(
      onTap: () async {
        await SharedPreferencesClass().setIntValue('s4cTemplateId', type);
        if(widget.isConfig){
          idTemplate = type;
          setState(() {});
          blocData.inList.add({'refreshApp' : true});
          Navigator.of(context).pop(true);
        }else{
          await SharedPreferencesClass().setIntValue('S4CInit',1);
          AuthService auth = Provider.of<AuthService>(widget.contextHome!,listen: false);
          auth.init();
        }

      },
      child: Container(
        height: sizeH * 0.35,
        width: sizeH * 0.35,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Image.asset("assets/image/template_$type.png").image,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget logo(){
    return Container(
      width: sizeW,
      child: Container(
        height: sizeH * 0.15,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Image.asset("assets/image/logo_lock.png").image,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  PreferredSize logoHelp(){
    return PreferredSize(
      preferredSize: Size.fromHeight(sizeH * 0.1),
      child: Container(
        color: Colors.white,
        width: sizeW,
        child: Align(
          alignment: Alignment.bottomRight,
          child: widget.isConfig ?
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
          ) :
          Container(
            height: sizeH * 0.08,
            width: sizeH * 0.08,
            margin: EdgeInsets.only(right: sizeW * 0.05),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: Image.asset("assets/image/icon_help.png").image,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
