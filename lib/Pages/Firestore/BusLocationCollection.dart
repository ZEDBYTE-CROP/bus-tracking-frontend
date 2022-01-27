import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

Future createBus({required String busNumber, required String busIdNumber}) async {
  FirebaseFirestore instance = FirebaseFirestore.instance;

  return await instance.collection('Bus List').doc(busNumber + "-" + busIdNumber).set({
    "busNumber": busNumber,
    "busIdNumber": busIdNumber,
    "Location": null,
  });
}

Future updateBus({required String busNumber, required String busIdNumber, required GeoPoint? geoPoint}) async {
  FirebaseFirestore instance = FirebaseFirestore.instance;
  return await instance.collection('Bus List').doc(busNumber + "-" + busIdNumber).update({"Location": geoPoint});
}

Stream<DocumentSnapshot<Map<String, dynamic>>> readBus({required String busNumber, required String busIdNumber}) async* {
  FirebaseFirestore instance = FirebaseFirestore.instance;
  yield* await instance.collection('Bus List').doc(busNumber + "-" + busIdNumber).snapshots();
}
