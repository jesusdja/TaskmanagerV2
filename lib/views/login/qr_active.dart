import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
//import 'package:qr_mobile_vision/qr_camera.dart';
import 'package:tra_s4c/config/s4c_colors.dart';
import 'package:tra_s4c/main.dart';
import 'package:tra_s4c/services/http_connection.dart';
import 'package:tra_s4c/services/shared_preferences.dart';
import 'package:tra_s4c/views/login/qr_success.dart';
import 'package:tra_s4c/widgets_utils/circular_progress_colors.dart';
import 'package:tra_s4c/widgets_utils/toast_widget.dart';

class QRActive extends StatefulWidget {
  @override
  _QRActiveState createState() => _QRActiveState();
}

class _QRActiveState extends State<QRActive> {

  bool loadData = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? barcodeController;

  @override
  initState() {
    super.initState();
  }

  Future<bool> exit() async {
    return false;
  }

  @override
  void reassemble() {
    super.reassemble();
    if(barcodeController != null){
      if (Platform.isAndroid) {
        barcodeController!.pauseCamera();
      } else if (Platform.isIOS) {
        barcodeController!.resumeCamera();
      }
    }
  }

  @override
  void dispose() {
    barcodeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            loadData ?
            Container(
              width: sizeW,
              height: sizeH,
              child: Center(
                child: circularProgressColors(widthContainer1: sizeW,widthContainer2: sizeH * 0.1,colorCircular: S4CColors().primary),
              ),
            )
                :
            Container(
              color: Colors.grey,
              width: sizeW,
              height: sizeH,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
            ),
            // Center(
            //   child: InkWell(
            //     onTap: ()=>loginQR(),
            //     child: Container(
            //       height: sizeH * 0.1,
            //       width: sizeW * 0.3,
            //       color: Colors.purpleAccent,
            //       child: Center(child: Text('CLICK AQUI'),),
            //     ),
            //   ),
            // ),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: sizeW * 0.1,height: sizeW * 0.1,
                child: IconButton(
                  icon: Icon(Icons.cancel,color: S4CColors().primary,size: sizeH * 0.15,),
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: EdgeInsets.only(left: sizeW * 0.01),
                width: sizeW * 0.1,height: sizeW * 0.1,
                child: IconButton(
                  icon: Icon(Icons.cameraswitch,color: S4CColors().primary,size: sizeH * 0.15,),
                  onPressed: () async {
                    if(barcodeController != null){
                      await barcodeController!.flipCamera();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onQRViewCreated(QRViewController controller) async {
    this.barcodeController = controller;
    await barcodeController!.flipCamera();
    controller.scannedDataStream.listen((scanData) async {
      if(!loadData){
        loadData = true;
        setState(() {});
        String code = scanData.code!;
        print('QR = $code');
        String decode = code.replaceAll("'", '"');
        var codeJson = json.decode(decode);
        try{
          var response = await ConnectionHttp().httpGetLoginQR(cn: codeJson['centro'], cod: codeJson['idcodigo']);
          if(response.statusCode == 200){
            var value = jsonDecode(response.body);
            if(value.isNotEmpty){
              String data = jsonEncode(value[0]);
              await SharedPreferencesClass().setStringValue('s4cUserLogin', data);
              Navigator.pushReplacement(context, new MaterialPageRoute(builder: (BuildContext context) => new QRSuccess()));
            }else{
              showAlert(text: 'El QR no contiene datos especificos de un usuario',isSuccess: false);
            }
          }else{
            String errorHttp = 'Error de conexión con el servidor';
            showAlert(text: errorHttp,isSuccess: false);
          }
        }catch(e){
          print('Error: ${e.toString()}');
          showAlert(text: 'El QR no contiene datos especificos de un usuario',isSuccess: false);
        }
        loadData = false;
        setState(() {});
      }
    });
  }

  Future loginQR() async{
    if(!loadData){
      loadData = true;
      setState(() {});
      Map<String,dynamic> codeJson = {'centro':'taskontrol','idcodigo':'5'}; //JESUS
      //Map<String,dynamic> codeJson = {'centro':'landazabalcopia','idcodigo':'93'};
      try{
        var response = await ConnectionHttp().httpGetLoginQR(cn: codeJson['centro'], cod: codeJson['idcodigo']);
        if(response.statusCode == 200){
          var value = jsonDecode(response.body);
          if(value.isNotEmpty){
            String data = jsonEncode(value[0]);
            await SharedPreferencesClass().setStringValue('s4cUserLogin', data);
            Navigator.pushReplacement(context, new MaterialPageRoute(builder: (BuildContext context) => new QRSuccess()));
          }else{
            showAlert(text: 'El QR no contiene datos especificos de un usuario',isSuccess: false);
          }
        }else{
          String errorHttp = 'Error de conexión con el servidor';
          showAlert(text: errorHttp,isSuccess: false);
        }
      }catch(e){
        print('Error: ${e.toString()}');
        showAlert(text: 'El QR no contiene datos especificos de un usuario',isSuccess: false);
      }
      loadData = false;
      setState(() {});
    }
  }
}
