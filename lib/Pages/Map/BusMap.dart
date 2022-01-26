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
  MapImage? poiMapImage;

  @override
  void initState() {
    SdkContext.init(IsolateOrigin.main);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Color(white),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(white),
        title: Text(
          "Driver List",
          style: textStyle(),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: readBus(busNumber: widget.busNumber, busIdNumber: widget.busIdNumber),
          builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.active && snapshot.hasData) {
              if (snapshot.data!.data()!["Location"] != null) {
                return Container(
                  child: HereMap(
                    onMapCreated: (value) => onMapCreated(value,
                        context: context,
                        poiMapImage: poiMapImage,
                        lat: snapshot.data!.data()!["Location"].latitude,
                        lng: snapshot.data!.data()!["Location"].longitude,
                        geoCoordinates: GeoCoordinates(snapshot.data!.data()!["Location"].latitude, snapshot.data!.data()!["Location"].longitude)),
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: 300,
                );
              } else {
                return Center(
                    child: Column(
                  children: [lottieAnimation("assets/lottie/location.json"), Text("No Location Data")],
                ));
              }
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    ));
  }
}
