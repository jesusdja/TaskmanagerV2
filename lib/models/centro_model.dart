import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class CentroModel extends Equatable{
  CentroModel({
    this.id,
    this.idHabitacion,
    this.stHabitacion,
    this.fkAlojamiento,
    this.stAlojamiento,
    this.acsid,
  });

  String? id;
  int? idHabitacion;
  String? stHabitacion;
  int? fkAlojamiento;
  String? stAlojamiento;
  String? acsid;

  factory CentroModel.fromJson(Map<dynamic, dynamic> json) => CentroModel(
    id: '${json["idHabitacion"]}-${json["fkAlojamiento"]}',
    idHabitacion: json["idHabitacion"],
    stHabitacion: json["stHabitacion"] ?? '',
    fkAlojamiento: json["fkAlojamiento"] ?? '',
    stAlojamiento: json["stAlojamiento"] ?? '',
    acsid: json["acsid"] ?? '',
  );

  CentroModel.fromMap(Map snapshot) :
    id = snapshot['id'],
    idHabitacion = int.parse(snapshot['idHabitacion']),
    stHabitacion = snapshot['stHabitacion'],
    fkAlojamiento = int.parse(snapshot['fkAlojamiento']),
    stAlojamiento = snapshot['stAlojamiento'],
        acsid = snapshot['acsid']
  ;

  Map<String, dynamic> toMap() => {
    'id' : '$idHabitacion-$fkAlojamiento',
    'idHabitacion' : idHabitacion.toString(),
    'stHabitacion' : stHabitacion,
    'fkAlojamiento' : fkAlojamiento.toString(),
    'stAlojamiento' : stAlojamiento,
    'acsid' : acsid,
  };

  @override
  List<Object?> get props => [
    id,
    idHabitacion,
    stHabitacion,
    fkAlojamiento,
    stAlojamiento,
    acsid,
  ];

  @override
  bool get stringify => false;
}
