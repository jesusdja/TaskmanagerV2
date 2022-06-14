import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class MotivoModel extends Equatable{
  MotivoModel({
    this.idMotivoAlarma,
    this.stMotivoAlarma,
  });

  int? idMotivoAlarma;
  String? stMotivoAlarma;

  factory MotivoModel.fromJson(Map<dynamic, dynamic> json) => MotivoModel(
    idMotivoAlarma: json["idMotivoAlarma"],
    stMotivoAlarma: json["stMotivoAlarma"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "idMotivoAlarma": idMotivoAlarma,
    "stMotivoAlarma": stMotivoAlarma,
  };

  MotivoModel.fromMap(Map snapshot) :
        idMotivoAlarma = int.parse(snapshot['idMotivoAlarma']),
        stMotivoAlarma = snapshot['stMotivoAlarma']
  ;

  Map<String, dynamic> toMap() => {
    'idMotivoAlarma' : idMotivoAlarma.toString(),
    'stMotivoAlarma' : stMotivoAlarma,
  };

  @override
  List<Object?> get props => [
    idMotivoAlarma,
    stMotivoAlarma,
  ];

  @override
  bool get stringify => false;
}
