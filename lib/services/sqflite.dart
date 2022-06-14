import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tra_s4c/models/centro_model.dart';
import 'package:tra_s4c/models/location_model.dart';
import 'package:tra_s4c/models/motivo_model.dart';
import 'package:tra_s4c/models/patient_model.dart';
import 'package:tra_s4c/models/user_model.dart';
import 'package:tra_s4c/services/shared_preferences.dart';

class DatabaseProvider{
  static final  DatabaseProvider db = DatabaseProvider();
  Database? _database;

  Future<Database?> get database async {
    if (_database != null){
      return _database!;
    }
    int? versionDB = await SharedPreferencesClass().getValue('S4CVersionDB');
    if(versionDB == null || versionDB != 25){
      await SharedPreferencesClass().setIntValue('S4CVersionDB', 25);
      await deleteDatabaseInstance();
    }
    _database = await getDatabaseInstance();
    return _database;
  }

  Future<Database> getDatabaseInstance() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, "RacketDB25.db");
    print(path);
    return await openDatabase(path, version: 25,
        onCreate: (Database db, int version) async {
          await db.execute(
              "CREATE TABLE USERS("
                  "idusuario TEXT primary key,"
                  "stnombre TEXT, "
                  "idempleado TEXT, "
                  "fkCodigo TEXT, "
                  "fkDispositivo TEXT, "
                  "stFoto TEXT "
                  ")");
          await db.execute(
              "CREATE TABLE LOCATION("
                  "uuid TEXT,"
                  "rssi TEXT, "
                  "mac TEXT, "
                  "proximity TEXT, "
                  "send TEXT, "
                  "date TEXT "
                  ")");
          await db.execute(
              "CREATE TABLE ROOMS("
                  "id TEXT primary key,"
                  "idHabitacion TEXT,"
                  "stHabitacion TEXT, "
                  "fkAlojamiento TEXT, "
                  "acsid TEXT, "
                  "stAlojamiento TEXT "
                  ")");
          await db.execute(
              "CREATE TABLE PATIENT("
                  "idasis TEXT primary key,"
                  "nombre TEXT, "
                  "foto TEXT, "
                  "direccion TEXT,"
                  "telefono TEXT, "
                  "movil TEXT, "
                  "letra TEXT,"
                  "flLatitud TEXT, "
                  "flLongitud TEXT, "
                  "ubicacion TEXT,"
                  "habitacion TEXT, "
                  "cama TEXT, "
                  "iBeaconUID TEXT, "
                  "fkHabitacion TEXT "
                  ")");

          await db.execute(
              "CREATE TABLE MOTIVO("
                  "idMotivoAlarma TEXT primary key,"
                  "stMotivoAlarma TEXT "
                  ")");
        });

  }

  //ELIMINAR INSTANCIA
  Future deleteDatabaseInstance() async {
    try{
      final db  = await database;
      await db!.rawDelete('DELETE FROM USERS');
      await db.rawDelete('DELETE FROM ROOMS');
      await db.rawDelete('DELETE FROM PATIENT');
      await db.rawDelete('DELETE FROM MOTIVO');
    }catch(e){
      print(e.toString());
      print('ERROR AL BORRAR DB');
    }

    try{
      final db  = await database;
      await db!.rawDelete('DELETE FROM USERS');
      await db.rawDelete('DELETE FROM ROOMS');
      await db.rawDelete('DELETE FROM PATIENT');
      await db.rawDelete('DELETE FROM MOTIVO');
    }catch(e){
      print(e.toString());
      print('ERROR AL BORRAR DB');
    }

  }

  //*******
  //USUARIO
  //*******
  Future<UserModel?> getUser(String id) async {
    try{
      Database? db = await database;
      var response = await db!.query("USERS", where: "idusuario = ?", whereArgs: [id]);
      return response.isNotEmpty ? UserModel.fromMap(response.first) : null;
    }catch(e){
      return null;
    }
  }
  //OBTENER USUARIO POR SENSOR
  Future<UserModel?> getUserSensor(String fkCode) async {
    try{
      Database? db = await database;
      var response = await db!.query("USERS", where: "fkCodigo = ?", whereArgs: [fkCode]);
      return response.isNotEmpty ? UserModel.fromMap(response.first) : null;
    }catch(e){
      return null;
    }
  }
  //OBTENER TODOS LOS USUARIOS
  Future<List<UserModel?>> getAllUser() async {
    List<UserModel> listNegocio = [];
    final db = await database;
    try{
      List<Map> list = await db!.rawQuery('SELECT * FROM USERS');
      list.forEach((mapa){
        UserModel? invitation = new UserModel.fromMap(mapa);
        listNegocio.add(invitation);
      });
    }catch(e){
      print('getAllNegocio : ${e.toString()}');
    }
    return listNegocio;
  }
  //OBTENER TODOS LOS USUARIOS EN MAPA
  Future<Map<String,UserModel>> getAllUserMap() async {
    Map<String,UserModel> users = {};
    final db = await database;
    try{
      List<Map> list = await db!.rawQuery('SELECT * FROM USERS');
      list.forEach((mapa){
        UserModel? invitation = new UserModel.fromMap(mapa);
        users[invitation.fkCodigo!] = invitation;
      });
    }catch(e){
      print('getAllUserMap : ${e.toString()}');
    }
    return users;
  }
  //INSERTAR USUARIO
  Future<int> saveUser(UserModel user) async {
    int res = 0;
    try{
      var dbClient = await database;
      res = await dbClient!.insert("USERS", user.toMap());
    }catch(e){
      print(e.toString());
    }

    return res;
  }
  //ELIMINAR USUARIO
  Future<int> deleteUser(String id) async {
    int res = 0;
    try{
      var dbClient = await database;
      res = await dbClient!.delete("USERS", where: "id = ?", whereArgs: [id]);
    }catch(e){
      print(e.toString());
    }

    return res;
  }
  //MODIFICAR USUARIO
  Future<int> updateUser(UserModel user) async {
    var dbClient = await  database;
    int res = 0;
    try{
      res = await dbClient!.update('USERS', user.toMap(),where: 'idusuario = ?', whereArgs: [user.idusuario]);
    }catch(e){
      print(e.toString());
    }
    return res;
  }

  //*******
  //LOCALIZACION DE USUARIO
  //*******
  //OBTENER TODOS LOS USUARIOS
  Future<List<LocationModel?>> getAllLocationUser() async {
    List<LocationModel> listLocationUser = [];
    final db = await database;
    try{
      List<Map> list = await db!.rawQuery('SELECT * FROM LOCATION');
      list.forEach((mapa){
        LocationModel? invitation = new LocationModel.fromMap(mapa);
        listLocationUser.add(invitation);
      });
    }catch(e){
      print('getAllNegocio : ${e.toString()}');
    }
    return listLocationUser;
  }
  //OBTENER TODOS LOS USUARIOS
  Future<List<LocationModel?>> getAllLocationUserForSend() async {
    List<LocationModel> listLocationUser = [];
    final db = await database;
    try{
      List<Map> list = await db!.rawQuery('SELECT * FROM LOCATION WHERE send = 0');
      list.forEach((mapa){
        LocationModel? invitation = new LocationModel.fromMap(mapa);
        listLocationUser.add(invitation);
      });
    }catch(e){
      print('getAllNegocio : ${e.toString()}');
    }
    return listLocationUser;
  }
  //INSERTAR USUARIO
  Future<int> saveLocationUser(LocationModel user) async {
    int res = 0;
    try{
      var dbClient = await database;
      res = await dbClient!.insert("LOCATION", user.toMap());
    }catch(e){
      print(e.toString());
    }
    return res;
  }

  //OBTENER TODOS LOS USUARIOS
  Future<int> updateLocation(LocationModel locationModel ) async {
    var dbClient = await  database;
    int res = 0;
    try{
      String date = locationModel.date.toString();
      String uuid = locationModel.uuid!;
      res = await dbClient!.update('LOCATION', locationModel.toMap(),where: "uuid = ? AND date = ?", whereArgs: [uuid,date]);
    }catch(e){
      print(e.toString());
    }
    return res;
  }

  //*******
  //ROOMS
  //*******
  Future<CentroModel?> getRoom({required String id}) async {
    try{
      Database? db = await database;
      var response = await db!.query("ROOMS", where: "id = ?", whereArgs: [id]);
      return response.isNotEmpty ? CentroModel.fromMap(response.first) : null;
    }catch(e){
      return null;
    }
  }
  //OBTENER TODOS LOS ROOMS
  Future<List<CentroModel?>> getAllRooms() async {
    List<CentroModel> listNegocio = [];
    final db = await database;
    try{
      List<Map> list = await db!.rawQuery('SELECT * FROM ROOMS');
      list.forEach((mapa){
        CentroModel? invitation = new CentroModel.fromMap(mapa);
        listNegocio.add(invitation);
      });
    }catch(e){
      print('getAllNegocio : ${e.toString()}');
    }
    return listNegocio;
  }
  //INSERTAR USUARIO
  Future<int> saveRoom(CentroModel room) async {
    int res = 0;
    try{
      var dbClient = await database;
      res = await dbClient!.insert("ROOMS", room.toMap());
    }catch(e){
      print(e.toString());
    }

    return res;
  }
  //MODIFICAR USUARIO
  Future<int> updateRoom(CentroModel room) async {
    var dbClient = await  database;
    int res = 0;
    try{
      res = await dbClient!.update('ROOMS', room.toMap(),where: "idHabitacion = ?,fkAlojamiento = ?", whereArgs: [room.idHabitacion,room.fkAlojamiento]);
    }catch(e){
      print(e.toString());
    }
    return res;
  }
  //OBTENER ROOMS POR NOMBRE Y ORGANIZACION
  Future<CentroModel?> getIdRoom({required String stHabitacion,required String stAlojamiento,}) async {
    try{
      Database? db = await database;
      var response = await db!.query("ROOMS", where: "stHabitacion = ? AND stAlojamiento = ?", whereArgs: [stHabitacion,stAlojamiento]);
      return response.isNotEmpty ? CentroModel.fromMap(response.first) : null;
    }catch(e){
      return null;
    }
  }

  //*******
  //PACIENTES
  //*******
  Future<PatientModel?> getPatient(String id) async {
    try{
      Database? db = await database;
      var response = await db!.query("PATIENT", where: "idasis = ?", whereArgs: [id]);
      return response.isNotEmpty ? PatientModel.fromMap(response.first) : null;
    }catch(e){
      return null;
    }
  }
  //OBTENER TODOS LOS USUARIOS
  Future<List<PatientModel>> getAllPatient() async {
    List<PatientModel> listNegocio = [];
    final db = await database;

    String business = await SharedPreferencesClass().getValue('S4CBusiness');
    String room = await SharedPreferencesClass().getValue('S4CRoom');

    try{
      List<Map> list = await db!.rawQuery('SELECT * FROM PATIENT');
      list.forEach((mapa){
        if(mapa['ubicacion'].toString().contains(business) && mapa['habitacion'] == room){
          PatientModel? invitation = new PatientModel.fromMap(mapa);
          listNegocio.add(invitation);
        }
      });
    }catch(e){
      print('getAllNegocio : ${e.toString()}');
    }
    return listNegocio;
  }
  //OBTENER TODOS LOS USUARIOS
  Future<List<PatientModel>> getAllPatientUID({required String uId}) async {
    List<PatientModel> listNegocio = [];
    final db = await database;

    String business = await SharedPreferencesClass().getValue('S4CBusiness');
    String room = await SharedPreferencesClass().getValue('S4CRoom');

    try{
      List<Map> list = await db!.rawQuery('SELECT * FROM PATIENT');
      list.forEach((mapa){
        if(mapa['ubicacion'].toString().contains(business) && mapa['habitacion'] == room && mapa['iBeaconUID'] == uId){
          PatientModel? invitation = new PatientModel.fromMap(mapa);
          listNegocio.add(invitation);
        }
      });
    }catch(e){
      print('getAllNegocio : ${e.toString()}');
    }
    return listNegocio;
  }
  //OBTENER TODOS LOS USUARIOS
  Future<List<PatientModel>> getAllPatientUIDUnidadFunctional({required String uId}) async {
    List<PatientModel> listNegocio = [];
    final db = await database;
    try{
      List<Map> list = await db!.rawQuery('SELECT * FROM PATIENT');
      list.forEach((mapa){
        if(mapa['iBeaconUID'] == uId){
          PatientModel? invitation = new PatientModel.fromMap(mapa);
          listNegocio.add(invitation);
        }
      });
    }catch(e){
      print('getAllNegocio : ${e.toString()}');
    }
    return listNegocio;
  }
  //INSERTAR USUARIO
  Future<int> savePatient(PatientModel patientModel) async {
    int res = 0;
    try{
      var dbClient = await database;
      res = await dbClient!.insert("PATIENT", patientModel.toMap());
    }catch(e){
      print(e.toString());
    }

    return res;
  }
  //ELIMINAR USUARIO
  Future<int> deletePatient(String id) async {
    int res = 0;
    try{
      var dbClient = await database;
      res = await dbClient!.delete("PATIENT", where: "idasis = ?", whereArgs: [id]);
    }catch(e){
      print(e.toString());
    }

    return res;
  }
  //MODIFICAR USUARIO
  Future<int> updatePatient(PatientModel patientModel) async {
    var dbClient = await  database;
    int res = 0;
    try{
      res = await dbClient!.update('PATIENT', patientModel.toMap(),where: 'idasis = ?', whereArgs: [patientModel.idasis]);
    }catch(e){
      print(e.toString());
    }
    return res;
  }

  //*******
  //MOTIVOS
  //*******
  Future<MotivoModel?> getMotivo(String id) async {
    try{
      Database? db = await database;
      var response = await db!.query("MOTIVO", where: "idMotivoAlarma = ?", whereArgs: [id]);
      return response.isNotEmpty ? MotivoModel.fromMap(response.first) : null;
    }catch(e){
      return null;
    }
  }
  //OBTENER TODOS LOS USUARIOS
  Future<List<MotivoModel?>> getAllMotivo() async {
    List<MotivoModel> listNegocio = [];
    final db = await database;
    try{
      List<Map> list = await db!.rawQuery('SELECT * FROM MOTIVO');
      list.forEach((mapa){
        MotivoModel? invitation = new MotivoModel.fromMap(mapa);
        listNegocio.add(invitation);
      });
    }catch(e){
      print('getAllMotivoModel : ${e.toString()}');
    }
    return listNegocio;
  }
  //INSERTAR USUARIO
  Future<int> saveMotivo(MotivoModel motivoModel) async {
    int res = 0;
    try{
      var dbClient = await database;
      res = await dbClient!.insert("MOTIVO", motivoModel.toMap());
    }catch(e){
      print(e.toString());
    }

    return res;
  }
  //ELIMINAR USUARIO
  Future<int> deleteMotivo(String id) async {
    int res = 0;
    try{
      var dbClient = await database;
      res = await dbClient!.delete("MOTIVO", where: "idMotivoAlarma = ?", whereArgs: [id]);
    }catch(e){
      print(e.toString());
    }

    return res;
  }
  //MODIFICAR USUARIO
  Future<int> updateMotivo(MotivoModel motivoModel) async {
    var dbClient = await  database;
    int res = 0;
    try{
      res = await dbClient!.update('MOTIVO', motivoModel.toMap(),where: 'idMotivoAlarma = ?', whereArgs: [motivoModel.idMotivoAlarma]);
    }catch(e){
      print(e.toString());
    }
    return res;
  }
}
