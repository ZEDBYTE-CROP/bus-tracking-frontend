

import 'dart:convert';

DriverList driverListFromJson(String str) => DriverList.fromJson(json.decode(str));

String driverListToJson(DriverList data) => json.encode(data.toJson());

class DriverList {
  DriverList({
   required  this.code,
   required  this.status,
   required  this.message,
   required  this.documentCount,
   required  this.result,
  });

  int code;
  String status;
  String message;
  int documentCount;
  List<Result> result;

  factory DriverList.fromJson(Map<String, dynamic> json) => DriverList(
        code: json["code"],
        status: json["status"],
        message: json["message"],
        documentCount: json["documentCount"],
        result: List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "status": status,
        "message": message,
        "documentCount": documentCount,
        "result": List<dynamic>.from(result.map((x) => x.toJson())),
      };
}

class Result {
  Result({
  required   this.id,
  required   this.name,
  required   this.phoneNumber,
  required   this.idNumber,
  });

  String id;
  String name;
  int phoneNumber;
  int idNumber;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["_id"],
        name: json["name"],
        phoneNumber: json["phoneNumber"],
        idNumber: json["idNumber"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "phoneNumber": phoneNumber,
        "idNumber": idNumber,
      };
}
