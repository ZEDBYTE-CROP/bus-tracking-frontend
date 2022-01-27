import 'dart:async';

import 'package:background_locator/location_dto.dart';
import 'package:bustracker/Database/SharedPreferences.dart';
import 'package:bustracker/Model/UserBusDetail.dart';
import 'package:bustracker/Pages/Firestore/BusLocationCollection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'location_service_repository.dart';

class LocationCallbackHandler {
  static Future<void> initCallback(Map<dynamic, dynamic> params) async {
    LocationServiceRepository myLocationCallbackRepository = LocationServiceRepository();
    await myLocationCallbackRepository.init(params);
  }

  static Future<void> disposeCallback() async {
    LocationServiceRepository myLocationCallbackRepository = LocationServiceRepository();
    await myLocationCallbackRepository.dispose();
  }

  static Future<void> callback(LocationDto locationDto) async {
    LocationServiceRepository myLocationCallbackRepository = LocationServiceRepository();
    await myLocationCallbackRepository.callback(locationDto: locationDto);
  }

  static Future<void> notificationCallback() async {
    print('***notificationCallback');
  }
}
