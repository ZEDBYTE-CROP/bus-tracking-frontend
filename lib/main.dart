import 'package:bustracker/Database/SharedPreferences.dart';
import 'package:bustracker/Pages/Authentication/SignIn.dart';
import 'package:bustracker/Pages/Dashboard/Dashboard.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Bus Tracker',
        home: FutureBuilder(
          future: readUserPersistence(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data == true) {
                return Dashboard();
              } else {
                return SignIn();
              }
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ));
  }
}
