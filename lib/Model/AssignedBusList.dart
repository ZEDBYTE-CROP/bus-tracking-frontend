import 'dart:convert';

AssignedBusList assignedBusListFromJson(String str) => AssignedBusList.fromJson(json.decode(str));

String assignedBusListToJson(AssignedBusList data) => json.encode(data.toJson());

class AssignedBusList {
  AssignedBusList({
    required this.code,
    required this.status,
    required this.message,
    required this.documentCount,
    required this.result,
  });

  int code;
  String status;
  String message;
  int documentCount;
  List<Result> result;

  factory AssignedBusList.fromJson(Map<String, dynamic> json) => AssignedBusList(
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
    required this.id,
    required this.busNumber,
    required this.busIdNumber,
    required this.busRoute,
    required this.busDriverName,
    required this.busDriverId,
    required this.isAssigned,
  });

  String id;
  String busNumber;
  String busIdNumber;
  String busRoute;
  String busDriverName;
  String busDriverId;
  bool isAssigned;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["_id"],
        busNumber: json["busNumber"],
        busIdNumber: json["busIdNumber"],
        busRoute: json["busRoute"],
        busDriverName: json["busDriverName"],
        busDriverId: json["busDriverId"],
        isAssigned: json["isAssigned"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "busNumber": busNumber,
        "busIdNumber": busIdNumber,
        "busRoute": busRoute,
        "busDriverName": busDriverName,
        "busDriverId": busDriverId,
        "isAssigned": isAssigned,
      };
}
