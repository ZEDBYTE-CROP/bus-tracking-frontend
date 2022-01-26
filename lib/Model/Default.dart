
import 'dart:convert';

Default defaultFromJson(String str) => Default.fromJson(json.decode(str));

String defaultToJson(Default data) => json.encode(data.toJson());

class Default {
  Default({
    required this.code,
    required this.status,
    required this.message,
  });

  int code;
  String status;
  String message;

  factory Default.fromJson(Map<String, dynamic> json) => Default(
        code: json["code"],
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "status": status,
        "message": message,
      };
}
