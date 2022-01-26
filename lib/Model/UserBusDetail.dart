import 'dart:convert';

BusDetail busDetailFromJson(String str) => BusDetail.fromJson(json.decode(str));

String busDetailToJson(BusDetail data) => json.encode(data.toJson());

class BusDetail {
  BusDetail({
    required this.busNumber,
    required this.busIdNumber,
  });

  String busNumber;
  String busIdNumber;

  factory BusDetail.fromJson(Map<String, dynamic> json) => BusDetail(
        busNumber: json["busNumber"],
        busIdNumber: json["busIdNumber"],
      );

  Map<String, dynamic> toJson() => {
        "busNumber": busNumber,
        "busIdNumber": busIdNumber,
      };
}
