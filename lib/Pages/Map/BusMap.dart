import 'dart:async';
import 'dart:typed_data';

import 'package:bustracker/Components/LottieComposition.dart';
import 'package:bustracker/Handler/HereMaps.dart';
import 'package:bustracker/Pages/Firestore/BusLocationCollection.dart';
import 'package:bustracker/Style/Colors.dart';
import 'package:bustracker/Style/Text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';

class BusMap extends StatefulWidget {
  final String busNumber;
  final String busIdNumber;
  const BusMap({Key? key, required this.busNumber, required this.busIdNumber}) : super(key: key);

  @override
  _BusMapState createState() => _BusMapState();
}

class _BusMapState extends State<BusMap> {
  HereMapController? hereMapController;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> stream;
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> streamSubscription;
  MapImage? poiMapImage;
  static const double distanceToEarthInMeters = 800;
  @override
  void initState() {
    // readStream();
    stream = readBus(busNumber: widget.busNumber, busIdNumber: widget.busIdNumber);
    SdkContext.init(IsolateOrigin.main);
    super.initState();
  }

  // readStream() {
  //   streamSubscription = stream.listen((event) async {
  //     if (event.data() != null) {
  //       GeoCoordinates geoCoordinates = GeoCoordinates(event.data()!["Location"].latitude, event.data()!["Location"].latitude);
  //       if (hereMapController != null) {
  //         await addMapMarker(hereMapController!, geoCoordinates, 0, "locationMark.png", poiMapImage);
  //         hereMapController!.camera.lookAtPointWithDistance(geoCoordinates, distanceToEarthInMeters);
  //       }
  //     }
  //   });
  // }

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
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: stream,
          builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.active && snapshot.hasData) {
              if (snapshot.data!.data() != null) {
                GeoCoordinates geoCoordinates = GeoCoordinates(snapshot.data!.data()!["Location"].latitude, snapshot.data!.data()!["Location"].latitude);
                if (hereMapController != null) {
                  hereMapController!.camera.lookAtPointWithDistance(geoCoordinates, distanceToEarthInMeters);
                  addMapMarker(hereMapController!, geoCoordinates, 0, "locationMark.png", poiMapImage);
                }
              }
              print(snapshot.data!.data().toString());
              if (snapshot.data!.exists && snapshot.data!.data() != null && snapshot.data!.data()!["Location"] != null) {
                return Container(
                  child: HereMap(
                    onMapCreated: (value) {
                      hereMapController = value;
                      return onMapCreated(hereMapController!,
                          context: context,
                          poiMapImage: poiMapImage,
                          lat: snapshot.data!.data()!["Location"].latitude,
                          lng: snapshot.data!.data()!["Location"].longitude,
                          geoCoordinates: GeoCoordinates(snapshot.data!.data()!["Location"].latitude, snapshot.data!.data()!["Location"].longitude));
                    },
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                );
              } else {
                return Center(
                    child: Column(
                  children: [lottieAnimation("assets/lottie/location.json"), Text("No Location Data")],
                ));
              }
            } else {
              return Center(
                  child: Column(
                children: [lottieAnimation("assets/lottie/loading.json"), Text("Loading Data")],
              ));
            }
          }),
    ));
  }
}
