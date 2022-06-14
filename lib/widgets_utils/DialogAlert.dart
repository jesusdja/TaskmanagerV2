import 'package:flutter/material.dart';
import 'package:tra_s4c/config/s4c_colors.dart';
import 'package:tra_s4c/config/s4c_style.dart';

Future<bool> alert(BuildContext context) async{
  Size size = MediaQuery.of(context).size;
  bool? res = await showDialog(
      context: context,
      builder: ( context ) {
        return AlertDialog(
          title: Text(''),
          content: Text('¿Estás seguro que desea cerrar sesión?',textAlign: TextAlign.center,
            style: S4CStyles().stylePrimary(size: size.height * 0.025,fontWeight: FontWeight.w500, color: S4CColors().primary),),
          actions: <Widget>[
            // ignore: deprecated_member_use
            FlatButton(
              child: Text('Ok',
                style: S4CStyles().stylePrimary(size: size.height * 0.02, color: S4CColors().primary,fontWeight: FontWeight.bold),),
              onPressed: ()  {
                Navigator.of(context).pop(true);
              },
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
            // ignore: deprecated_member_use
            FlatButton(
              child: Text('Cancelar',
                style: S4CStyles().stylePrimary(size: size.height * 0.02, color: S4CColors().primary,fontWeight: FontWeight.bold),),
              onPressed: (){
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      }
  );
  return res ?? false;
}

Future<bool> alertUnauthenticated(BuildContext context) async{
  Size size = MediaQuery.of(context).size;
  bool? res = await showDialog(
      context: context,
      builder: ( context ) {
        return AlertDialog(
          title: Text(''),
          content: Text('Token no autorizado, por favor loguearse nuevamente',textAlign: TextAlign.center,
            style: S4CStyles().stylePrimary(size: size.height * 0.025,fontWeight: FontWeight.w500, color: S4CColors().primary),),
          actions: <Widget>[
            // ignore: deprecated_member_use
            FlatButton(
              child: Text('Ok',
                style: S4CStyles().stylePrimary(size: size.height * 0.02, color: S4CColors().primary,fontWeight: FontWeight.bold),),
              onPressed: ()  {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      }
  );
  return res ?? false;
}

Future<bool> alertNoDataBase(BuildContext context) async{
  Size size = MediaQuery.of(context).size;
  bool? res = await showDialog(
      context: context,
      builder: ( context ) {
        return AlertDialog(
          title: Text('¿Quieres ir a configuración de la base de datos?'),
          content: Text('Nombre de la base de datos no encontrada, agregar una correcta',textAlign: TextAlign.center,
            style: S4CStyles().stylePrimary(size: size.height * 0.03,fontWeight: FontWeight.w500, color: S4CColors().primary),),
          actions: <Widget>[
            // ignore: deprecated_member_use
            FlatButton(
              child: Text('SI',
                style: S4CStyles().stylePrimary(size: size.height * 0.02, color: S4CColors().primary,fontWeight: FontWeight.bold),),
              onPressed: ()  {
                Navigator.of(context).pop(true);
              },
            ),
            // ignore: deprecated_member_use
            FlatButton(
              child: Text('NO',
                style: S4CStyles().stylePrimary(size: size.height * 0.02, color: S4CColors().primary,fontWeight: FontWeight.bold),),
              onPressed: ()  {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      }
  );
  return res ?? false;
}

Future<bool> alertDeleteAllValue({required BuildContext context}) async{
  Size size = MediaQuery.of(context).size;
  bool? res = await showDialog(
      context: context,
      builder: ( context ) {
        return AlertDialog(
          title: Text(''),
          content: Text('¿Estás seguro que desea borrar todos los datos de la app?',textAlign: TextAlign.center,
            style: S4CStyles().stylePrimary(size: size.height * 0.025,fontWeight: FontWeight.w500, color: S4CColors().primary),),
          actions: <Widget>[
            // ignore: deprecated_member_use
            FlatButton(
              child: Text('BORRAR',
                style: S4CStyles().stylePrimary(size: size.height * 0.02, color: S4CColors().primary,fontWeight: FontWeight.bold),),
              onPressed: ()  {
                Navigator.of(context).pop(true);
              },
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
            // ignore: deprecated_member_use
            FlatButton(
              child: Text('CANCELAR',
                style: S4CStyles().stylePrimary(size: size.height * 0.02, color: S4CColors().primary,fontWeight: FontWeight.bold),),
              onPressed: (){
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      }
  );
  return res ?? false;
}

Future<bool?> alertDialogGeneral({required BuildContext context}) async{
  Size size = MediaQuery.of(context).size;
  bool? res = await showDialog(
      context: context,
      builder: ( context ) {
        return AlertDialog(
          title: Text(''),
          content: Text('Seleccionar',textAlign: TextAlign.center,
            style: S4CStyles().stylePrimary(size: size.height * 0.025,fontWeight: FontWeight.w500, color: S4CColors().primary),),
          actions: <Widget>[
            // ignore: deprecated_member_use
            FlatButton(
              child: Text('MANTENIMIENTO',
                style: S4CStyles().stylePrimary(size: size.height * 0.02, color: S4CColors().primary,fontWeight: FontWeight.bold),),
              onPressed: ()  {
                Navigator.of(context).pop(true);
              },
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
            // ignore: deprecated_member_use
            FlatButton(
              child: Text('RESIDENTES',
                style: S4CStyles().stylePrimary(size: size.height * 0.02, color: S4CColors().primary,fontWeight: FontWeight.bold),),
              onPressed: (){
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      }
  );
  return res;
}