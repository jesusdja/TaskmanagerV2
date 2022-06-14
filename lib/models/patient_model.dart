import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class PatientModel extends Equatable{
  PatientModel({
    this.idasis,
    this.nombre,
    this.foto,
    this.direccion,
    this.telefono,
    this.movil,
    this.letra,
    this.flLatitud,
    this.flLongitud,
    this.ubicacion,
    this.habitacion,
    this.cama,
    this.iBeaconUID,
    this.fkHabitacion,
  });

  int? idasis;
  String? nombre;
  String? foto;
  String? direccion;
  String? telefono;
  String? movil;
  String? letra;
  String? flLatitud;
  String? flLongitud;
  String? ubicacion;
  String? habitacion;
  String? cama;
  String? iBeaconUID;
  int? fkHabitacion;


  factory PatientModel.fromJson(Map<dynamic, dynamic> json) => PatientModel(
    idasis: json["idasis"],
    nombre: json["nombre"] ?? '',
    foto: json["foto"] ?? '',
    direccion: json["direccion"] ?? '',
    telefono: json["telefono"] ?? '',
    movil: json["movil"] ?? '',
    letra: json["letra"],
    flLatitud: json["flLatitud"].toString(),
    flLongitud: json["flLongitud"].toString(),
    ubicacion: json["ubicacion"] ?? '',
    habitacion: json["habitacion"] ?? '',
    cama: json["cama"] ?? '',
    fkHabitacion: json["fkHabitacion"] ?? 0,
    iBeaconUID: json["iBeaconUID"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "idasis": idasis,
    "nombre": nombre,
    "foto": foto,
    "direccion": direccion,
    "telefono": telefono,
    "movil": movil,
    "letra": letra,
    "flLatitud": flLatitud,
    "flLongitud": flLongitud,
    "ubicacion": ubicacion,
    "habitacion": habitacion,
    "cama": cama,
    "iBeaconUID": iBeaconUID,
    "fkHabitacion": fkHabitacion,
  };

  PatientModel.fromMap(Map snapshot) :
        idasis = int.parse(snapshot['idasis']),
        nombre = snapshot['nombre'],
        foto = snapshot['foto'],
        direccion = snapshot['direccion'],
        telefono = snapshot['telefono'],
        movil = snapshot['movil'],
        letra = snapshot['letra'],
        flLatitud = snapshot['flLatitud'],
        flLongitud = snapshot['flLongitud'],
        ubicacion = snapshot['ubicacion'],
        habitacion = snapshot['habitacion'],
        cama = snapshot['cama'],
        iBeaconUID = snapshot['iBeaconUID'],
        fkHabitacion = int.parse(snapshot['fkHabitacion'])
  ;

  Map<String, dynamic> toMap() => {
    'idasis' : idasis.toString(),
    'nombre' : nombre,
    'foto' : foto,
    'direccion' : direccion,
    'telefono' : telefono,
    'movil' : movil,
    'letra' : letra,
    'flLatitud' : flLatitud.toString(),
    'flLongitud' : flLongitud.toString(),
    'ubicacion' : ubicacion,
    'habitacion' : habitacion,
    'cama' : cama,
    'iBeaconUID' : iBeaconUID,
    'fkHabitacion' : fkHabitacion.toString(),
  };

  @override
  List<Object?> get props => [
    idasis,
    nombre,
    foto,
    direccion,
    telefono,
    movil,
    letra,
    flLatitud,
    flLongitud,
    ubicacion,
    habitacion,
    cama,
    iBeaconUID,
    fkHabitacion,
  ];

  @override
  bool get stringify => false;
}
