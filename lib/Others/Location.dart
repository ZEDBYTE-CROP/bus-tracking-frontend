import 'package:background_locator/background_locator.dart';
import 'package:background_locator/settings/android_settings.dart';
import 'package:background_locator/settings/ios_settings.dart';
import 'package:background_locator/settings/locator_settings.dart' as bgSetting;
import 'package:flutter/painting.dart';
import 'package:location/location.dart';
import '../Style/Colors.dart';
import '../Others/location_callback_handler.dart';
import 'package:tuple/tuple.dart';

Future<Tuple3> getLocation() async {
  Location location = new Location();

  bool serviceStatus;
  PermissionStatus permissionStatus;
  LocationData? locationData;

  serviceStatus = await location.serviceEnabled();
  if (!serviceStatus) {
    serviceStatus = await location.requestService();
  }

  permissionStatus = await location.hasPermission();
  if (permissionStatus == PermissionStatus.denied) {
    permissionStatus = await location.requestPermission();
  }
  if (serviceStatus == true && (permissionStatus == PermissionStatus.granted || permissionStatus == PermissionStatus.grantedLimited)) {
    locationData = await location.getLocation();
  }
  return Tuple3(locationData, serviceStatus, permissionStatus);
}

Future<void> getLiveLocation() async {
  Map<String, dynamic> data = {'countInit': 1};
  return await BackgroundLocator.registerLocationUpdate(LocationCallbackHandler.callback,
      initCallback: LocationCallbackHandler.initCallback,
      initDataCallback: data,
      disposeCallback: LocationCallbackHandler.disposeCallback,
      iosSettings: IOSSettings(accuracy: bgSetting.LocationAccuracy.NAVIGATION, distanceFilter: 0),
      autoStop: false,
      androidSettings: AndroidSettings(
          accuracy: bgSetting.LocationAccuracy.NAVIGATION,
          interval: 5,
          distanceFilter: 0,
          client: LocationClient.google,
          androidNotificationSettings: AndroidNotificationSettings(
              notificationChannelName: 'Location tracking',
              notificationTitle: 'Start Location Tracking',
              notificationMsg: 'Track location in background',
              notificationBigMsg:
                  'Background location is on to keep the app up-to-date with your location. This is required for main features to work properly when the app is not running.',
              notificationIconColor: Color(materialBlack),
              notificationIcon: "",
              notificationTapCallback: LocationCallbackHandler.notificationCallback)));
}
