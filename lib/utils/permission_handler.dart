import 'package:permission_handler/permission_handler.dart';

class PermissionHandlerClass{

  PermissionHandlerClass() {
    initialData();
  }

  Future initialData() async{
    await permissionCamera();
    await permissionMicrophone();
  }

  Future<bool> permissionCamera() async {
    bool result = true;
    var status = await Permission.camera.status;
    if(!status.isGranted){
      PermissionStatus resultP = await Permission.camera.request();
      if(!resultP.isGranted){
        result = false;
        await openAppSettings();
      }
    }
    return result;
  }

  Future<bool> permissionMicrophone() async {
    bool result = true;
    var status = await Permission.microphone.status;
    if(!status.isGranted){
      PermissionStatus resultP = await Permission.microphone.request();
      if(!resultP.isGranted){
        result = false;
        await openAppSettings();
      }
    }
    return result;
  }

}

