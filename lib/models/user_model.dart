import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class UserModel extends Equatable{
  UserModel({
    this.idusuario,
    this.stnombre,
    this.idempleado,
    this.fkCodigo,
    this.fkDispositivo,
    this.stFoto,
  });

  int? idusuario;
  String? stnombre;
  int? idempleado;
  String? fkCodigo;
  int? fkDispositivo;
  String? stFoto;

  factory UserModel.fromJson(Map<dynamic, dynamic> json) => UserModel(
    idusuario: json["idusuario"],
    stnombre: json["stnombre"] ?? '',
    idempleado: json["idempleado"] ?? '',
    fkCodigo: json["fkCodigo"] ?? '',
    fkDispositivo: json["fkDispositivo"] ?? '',
    stFoto: json["stFoto"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "idusuario": idusuario,
    "stnombre": stnombre,
    "idempleado": idempleado,
    "fkCodigo": fkCodigo,
    "fkDispositivo": fkDispositivo,
    "stFoto": stFoto,
  };

  UserModel.fromMap(Map snapshot) :
        idusuario = int.parse(snapshot['idusuario']),
        stnombre = snapshot['stnombre'],
        idempleado = int.parse(snapshot['idempleado']),
        fkCodigo = snapshot['fkCodigo'],
        fkDispositivo = int.parse(snapshot['fkDispositivo']),
        stFoto = snapshot['stFoto']
  ;

  Map<String, dynamic> toMap() => {
    'idusuario' : idusuario.toString(),
    'stnombre' : stnombre,
    'idempleado' : idempleado.toString(),
    'fkCodigo' : fkCodigo,
    'fkDispositivo' : fkDispositivo.toString(),
    'stFoto' : stFoto,
  };

  @override
  List<Object?> get props => [
    idusuario,
    stnombre,
    idempleado,
    fkCodigo,
    fkDispositivo,
    stFoto,
  ];

  @override
  bool get stringify => false;
}
