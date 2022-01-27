import 'dart:convert';

DriverDetail driverDetailFromJson(String str) => DriverDetail.fromJson(json.decode(str));

String driverDetailToJson(DriverDetail data) => json.encode(data.toJson());

class DriverDetail {
  DriverDetail({
    required this.code,
    required this.status,
    required this.message,
    required this.result,
  });

  int code;
  String status;
  String message;
  Result result;

  factory DriverDetail.fromJson(Map<String, dynamic> json) => DriverDetail(
        code: json["code"],
        status: json["status"],
        message: json["message"],
        result: Result.fromJson(json["result"]),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "status": status,
        "message": message,
        "result": result.toJson(),
      };
}

class Result {
  Result({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.idNumber,
    required this.busNumber,
    required this.busIdNumber,
  });

  String id;
  String name;
  int phoneNumber;
  int idNumber;
  String busNumber;
  String busIdNumber;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["_id"],
        name: json["name"],
        phoneNumber: json["phoneNumber"],
        idNumber: json["idNumber"],
        busNumber: json["busNumber"],
        busIdNumber: json["busIdNumber"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "phoneNumber": phoneNumber,
        "idNumber": idNumber,
        "busNumber": busNumber,
        "busIdNumber": busIdNumber,
      };
}
