import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import '../Model/Exception.dart';
import '../Others/LottieString.dart';
import 'package:flutter/foundation.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http_parser/http_parser.dart';
import 'package:tuple/tuple.dart';
import 'package:path_provider/path_provider.dart';

void valueResetter(ValueNotifier<Tuple4> valueNotifier) {
  valueNotifier.value = Tuple4(-1, exceptionFromJson(alert), "Null", null);
}

class ApiHandler {
  Map<String, String> _httpHeader({Map<String, String>? headers, String? authToken}) {
    Map<String, String> defaultHeader = {'Content-Type': 'application/json', 'Accept': '*/*'};
    if (authToken != null) {
      defaultHeader.addAll({HttpHeaders.authorizationHeader: 'Bearer $authToken'});
    }
    if (headers != null) {
      defaultHeader.addAll(headers);
    }
    return defaultHeader;
  }

  Future _httpRequest({
    required Uri uri,
    required int requestMethod,
    Map<String, File>? formBody,
    Map<String, String>? headers,
    String? authToken,
    Object? body,
  }) async {
    switch (requestMethod) {
      case 0:
        return await http.get(uri, headers: _httpHeader(headers: headers, authToken: authToken));

      case 1:
        {
          if (formBody != null) {
            var request = new http.MultipartRequest("POST", uri);
            request.headers.addAll(_httpHeader(headers: headers, authToken: authToken));
            if (body != null) {
              request.fields.addAll(body as Map<String, String>);
            }
            formBody.forEach((key, value) async {
              request.files.add(new http.MultipartFile(key, http.ByteStream(DelegatingStream(value.openRead()).cast()), await value.length(),
                  filename: key + "_" + value.path, contentType: new MediaType('image', 'jpeg')));
            });
            return request.send();
          } else {
            if (body != null) {
              return await http.post(uri, headers: _httpHeader(headers: headers, authToken: authToken), body: jsonEncode(body));
            } else {
              return await http.post(uri, headers: _httpHeader(headers: headers, authToken: authToken));
            }
          }
        }

      case 2:
        return await http.delete(uri, headers: _httpHeader(headers: headers, authToken: authToken), body: jsonEncode(body));
    }
  }

//!this is the main handler
//! result index ==> -1->Null,0->loading,1->done,2->error,3->response error
  Future<void> apiHandler(
      {required ValueNotifier<Tuple4> valueNotifier,
      String? testJsonString,
      required Function jsonModel,
      required String url,
      required int requestMethod,
      Map<String, String>? headers,
      Map<String, File>? formBody,
      String? authToken,
      Object? body,
      int? subscribedConnectivityIndex}) async {
    ConnectivityResult? connectivityResult;
    if (subscribedConnectivityIndex == null) {
      connectivityResult = await Connectivity().checkConnectivity();
    }
    Uri uri = Uri.parse(url);
    try {
      valueNotifier.value = Tuple4(0, exceptionFromJson(loading), "Api Loading", null);
      if ((subscribedConnectivityIndex ?? connectivityResult?.index) != 3) {
        if (testJsonString == null) {
          log("Url:\n" + url.toString() + "\n");
          log((headers != null) ? "Headers:\n" + headers.toString() + "\n" : "Headers:\n" + authToken.toString() + "\n");
          log("Body:\n" + body.toString() + "\n");
          var response = await _httpRequest(uri: uri, requestMethod: requestMethod, headers: headers, authToken: authToken, formBody: formBody, body: body);
          if (formBody != null) {
            response = await http.Response.fromStream(response);
          }
          log(response.body.toString());
          if (response.statusCode == 200) {
            Map jsonResponse = json.decode(response.body);
            inspect(jsonResponse);
            if (jsonResponse["code"].toString() == "200") {
              valueNotifier.value = Tuple4(1, jsonModel(response.body), jsonResponse["message"].toString(), jsonResponse);
            } else {
              valueNotifier.value = (jsonResponse["message"] != null)
                  ? Tuple4(3, exceptionFromJson(alert), jsonResponse["message"].toString(), jsonResponse)
                  : Tuple4(3, exceptionFromJson(alert), "Something went wrong!", jsonResponse);
            }
          } else {
            switch (response.statusCode) {
              case 404:
                {
                  valueNotifier.value = Tuple4(2, exceptionFromJson(notFound), response.reasonPhrase!, null);
                }
                break;

              case 500:
                {
                  valueNotifier.value = Tuple4(2, exceptionFromJson(serverError), response.reasonPhrase!, null);
                }
                break;

              default:
                {
                  valueNotifier.value = Tuple4(2, exceptionFromJson(invalid), response.reasonPhrase!, null);
                }
                break;
            }
          }
        } else {
          Future.delayed(const Duration(seconds: 2), () {
            valueNotifier.value = Tuple4(1, jsonModel(testJsonString), "Testing Purposes", json.decode(testJsonString));
          });
        }
      } else {
        valueNotifier.value = Tuple4(2, exceptionFromJson(noNetwork), "No Connectivity", null);
      }
    } catch (e) {
      valueNotifier.value = Tuple4(2, exceptionFromJson(alert), e.toString(), null);
    }
    log(valueNotifier.value.toString());
  }
}

Future<File> uint8listToFile({required String name, String ext = 'jpg', required Uint8List uint8list}) async {
  Uint8List imageInUnit8List = uint8list;
  final tempDir = await getTemporaryDirectory();
  File file = await File('${tempDir.path}/$name.$ext').create();
  file.writeAsBytesSync(imageInUnit8List);
  return file;
}
