

import 'dart:convert';

Exception exceptionFromJson(String str) => Exception.fromJson(json.decode(str));

String exceptionToJson(Exception data) => json.encode(data.toJson());

class Exception {
  Exception({
    required this.data,
    required this.lottieString,
  });

  String data;
  String lottieString;

  factory Exception.fromJson(Map<String, dynamic> json) => Exception(
        data: json["data"],
        lottieString: json["lottieString"],
      );

  Map<String, dynamic> toJson() => {
        "data": data,
        "lottieString": lottieString,
      };
}
