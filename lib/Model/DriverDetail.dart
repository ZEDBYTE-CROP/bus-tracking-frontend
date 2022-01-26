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
  List<Result> result;

  factory DriverDetail.fromJson(Map<String, dynamic> json) => DriverDetail(
        code: json["code"],
        status: json["status"],
        message: json["message"],
        result: List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "status": status,
        "message": message,
        "result": List<dynamic>.from(result.map((x) => x.toJson())),
      };
}

class Result {
  Result({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.idNumber,
    required this.password,
    required this.busNumber,
    required this.busIdNumber,
    required this.v,
  });

  String id;
  String name;

  int phoneNumber;
  int idNumber;
  String password;
  String busNumber;
  String busIdNumber;
  int v;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["_id"],
        name: json["name"],
        phoneNumber: json["phoneNumber"],
        idNumber: json["idNumber"],
        password: json["password"],
        busNumber: json["busNumber"],
        busIdNumber: json["busIdNumber"],
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "phoneNumber": phoneNumber,
        "idNumber": idNumber,
        "password": password,
        "busNumber": busNumber,
        "busIdNumber": busIdNumber,
        "__v": v,
      };
}
