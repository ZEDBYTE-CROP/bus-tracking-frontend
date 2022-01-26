import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/gestures.dart';
import 'package:here_sdk/mapview.dart';

List<String> signInClaimList = ["Admin", "Student", "Driver"];

List<String> signUpClaimList = ["Student", "Driver"];

List<String> bloodGroupList = ["A+", "O+", "B+", "AB+", "A-", "o-", "B-", "AB-"];

onMapCreated(HereMapController hereMapController,
    {required double lat, required double lng, required GeoCoordinates geoCoordinates, required MapImage? poiMapImage, required BuildContext context}) {
  hereMapController.mapScene.loadSceneForMapScheme(MapScheme.normalDay, (MapError? error) async {
    if (error != null) {
      print('Map scene not loaded. MapError: ${error.toString()}');
      return;
    }

    const double distanceToEarthInMeters = 800;
    hereMapController.camera.lookAtPointWithDistance(GeoCoordinates(lat, lng), distanceToEarthInMeters);

    await addMapMarker(hereMapController, geoCoordinates, 0, "locationMark.png", poiMapImage);
  });
}

Future<Uint8List> loadFileAsUint8List(String fileName) async {
  ByteData fileData = await rootBundle.load('assets/' + fileName);
  return Uint8List.view(fileData.buffer);
}

Future<void> addMapMarker(HereMapController hereMapController, GeoCoordinates geoCoordinates, int drawOrder, String fileName, MapImage? poiMapImage) async {
  if (poiMapImage == null) {
    Uint8List imagePixelData = await loadFileAsUint8List(fileName);
    poiMapImage = MapImage.withPixelDataAndImageFormat(imagePixelData, ImageFormat.png);
  }
  Anchor2D anchor2D = Anchor2D.withHorizontalAndVertical(0.5, 1);
  MapMarker mapMarker = MapMarker.withAnchor(geoCoordinates, poiMapImage, anchor2D);
  mapMarker.drawOrder = drawOrder;
  hereMapController.mapScene.addMapMarker(mapMarker);
}
