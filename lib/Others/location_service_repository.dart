import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:developer' as dev;
import 'dart:ui';
import 'package:background_locator/location_dto.dart';
import 'package:bustracker/Database/SharedPreferences.dart';
import 'package:bustracker/Model/UserBusDetail.dart';
import 'package:bustracker/Pages/Firestore/BusLocationCollection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Others/Location.dart';
import 'package:http/http.dart' as http;

class LocationServiceRepository {
  static final LocationServiceRepository _instance = LocationServiceRepository._internal();
  // static LocationServiceRepository _instance = LocationServiceRepository._();

  // LocationServiceRepository._();

  factory LocationServiceRepository() {
    return _instance;
  }

  LocationServiceRepository._internal() {
    // websocketMapString = "";
    channelString = "";
  }

  static const String isolateName = 'LocatorIsolate';

  int _count = -1;
  String? channelString;
  // Map? websocketMap;

  //short getter for my variable
  String get myVariable => channelString!;

  //short setter for my variable
  set myVariable(String value) => myVariable = value;

  void channelChanger(String value) => channelString = value;

  Future<void> init(Map<dynamic, dynamic> params) async {
    print("***********Init callback handler");
    if (params.containsKey('countInit')) {
      dynamic tmpCount = params['countInit'];
      if (tmpCount is double) {
        _count = tmpCount.toInt();
      } else if (tmpCount is String) {
        _count = int.parse(tmpCount);
      } else if (tmpCount is int) {
        _count = tmpCount;
      } else {
        _count = -2;
      }
    } else {
      _count = 0;
    }
    print("$_count");
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }

  Future<void> dispose() async {
    print("***********Dispose callback handler");
    print("$_count");
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }

  Future<void> callback({LocationDto? locationDto, Map? web}) async {
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    // dev.log("web" + websocketMap.toString());
    // dev.log("var" + myVariable.toString());

    String? busMapString = await readBusDetails();

    BusDetail busMap = busDetailFromJson(busMapString!);

    // dev.log("var:" + socketMapString.toString());
    if (locationDto != null) {
      writeToFirestore(locationDto, busMap, send!);
    }
    // send?.send(locationDto);
    _count++;
  }

  writeToFirestore(LocationDto data, BusDetail busMap, SendPort send) async {
    await updateBus(busNumber: busMap.busNumber, busIdNumber: busMap.busIdNumber, geoPoint: GeoPoint(data.latitude, data.longitude));
    send.send(data);
  }
}
