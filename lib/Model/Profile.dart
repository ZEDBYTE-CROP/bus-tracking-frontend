

import 'dart:convert';

Profile profileFromJson(String str) => Profile.fromJson(json.decode(str));

String profileToJson(Profile data) => json.encode(data.toJson());

class Profile {
  Profile({
    required this.claim,
    required this.idNumber,
  });

  int claim;
  String idNumber;

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        claim: json["claim"],
        idNumber: json["idNumber"],
      );

  Map<String, dynamic> toJson() => {
        "claim": claim,
        "idNumber": idNumber,
      };
}
