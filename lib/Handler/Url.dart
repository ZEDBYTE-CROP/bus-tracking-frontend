import '../Components/Snackbar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future launchGoogleMaps({required String latitude, required String longitude, required BuildContext context}) async {
  String url = "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
  bool launchStatus = await canLaunch(url);
  print(launchStatus);
  if (launchStatus) {
    await launch(url);
  } else {
    final snackBar = snackbar(content: "Please install google maps.");
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

Future launchPhone({required String phone, required BuildContext context}) async {
  String url = "tel:$phone";
  bool launchStatus = await canLaunch(url);
  print(launchStatus);
  if (launchStatus) {
    await launch(url);
  } else {
    final snackBar = snackbar(content: "Please install dialer.");
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

void launchUrl(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
