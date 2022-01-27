import 'dart:async';
import 'dart:typed_data';

import 'package:bustracker/Components/LottieComposition.dart';
import 'package:bustracker/Others/Structure.dart';
import 'package:bustracker/Pages/Firestore/BusLocationCollection.dart';
import 'package:bustracker/Style/Colors.dart';
import 'package:bustracker/Style/Text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';
import 'package:lottie/lottie.dart';

class BusMap extends StatefulWidget {
  final String busNumber;
  final String busIdNumber;
  const BusMap({Key? key, required this.busNumber, required this.busIdNumber}) : super(key: key);

  @override
  _BusMapState createState() => _BusMapState();
}

class _BusMapState extends State<BusMap> {
  HereMapController? hereMapController;
  GeoCoordinates? geoCoordinates;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> stream;
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> streamSubscription;
  MapImage? poiMapImage;
  MapMarker? marker;
  static const double distanceToEarthInMeters = 800;
  @override
  void initState() {
    readStream();
    SdkContext.init(IsolateOrigin.main);
    super.initState();
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    stream.drain();
    super.dispose();
  }

  readStream() async {
    Uint8List imagePixelData = await loadFileAsUint8List('locationMark.png');
    poiMapImage = MapImage.withPixelDataAndImageFormat(imagePixelData, ImageFormat.png);
    stream = readBus(busNumber: widget.busNumber, busIdNumber: widget.busIdNumber);

    streamSubscription = stream.listen((event) async {
      if (event.data() != null) {
        if (marker != null) {
          hereMapController!.mapScene.removeMapMarker(marker!);
        }
        if (!mounted) return;
        setState(() {
          geoCoordinates = GeoCoordinates(event.data()!["Location"].latitude, event.data()!["Location"].longitude);
          marker = MapMarker(geoCoordinates!, poiMapImage!);
        });
        if (hereMapController != null) {
          hereMapController!.mapScene.addMapMarker(marker!);
          hereMapController!.camera.lookAtPointWithDistance(geoCoordinates!, distanceToEarthInMeters);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: Color(white),
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Color(white),
              automaticallyImplyLeading: false,
              leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Color(materialBlack),
                  )),
              title: Text(
                "Driver List",
                style: textStyle(),
              ),
            ),
            body: Container(
              child: HereMap(
                onMapCreated: (value) {
                  hereMapController = value;
                  hereMapController!.mapScene.loadSceneForMapScheme(MapScheme.normalDay, (MapError? error) async {
                    if (error != null) {
                      print('Map scene not loaded. MapError: ${error.toString()}');
                      return;
                    }
                  });

                  // return onMapCreated(hereMapController!,
                  //     context: context,
                  //     poiMapImage: poiMapImage,
                  //     lat: snapshot.data!.data()!["Location"].latitude,
                  //     lng: snapshot.data!.data()!["Location"].longitude,
                  //     geoCoordinates: GeoCoordinates(snapshot.data!.data()!["Location"].latitude, snapshot.data!.data()!["Location"].longitude));
                },
              ),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            )));
  }
}
