import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class LocationModel extends Equatable{
  LocationModel({
    this.uuid,
    this.rssi,
    this.mac,
    this.proximity,
    this.date,
    this.send,
  });

  String? uuid;
  int? rssi;
  String? mac;
  String? proximity;
  DateTime? date;
  int? send;

  LocationModel.fromMap(Map snapshot) :
    uuid = snapshot['uuid'],
    rssi = int.parse(snapshot['rssi']),
    mac = snapshot['mac'],
    proximity = snapshot['proximity'],
    date =  DateTime.parse(snapshot['date']),
    send =  int.parse(snapshot['send'])
  ;

  Map<String, dynamic> toMap() => {
    'uuid' : uuid,
    'rssi' : rssi.toString(),
    'mac' : mac,
    'proximity' : proximity,
    'date' : date.toString(),
    'send' : send.toString()
  };

  @override
  List<Object?> get props => [
    uuid,
    rssi,
    mac,
    proximity,
    date,
    send,
  ];

  @override
  bool get stringify => false;
}
