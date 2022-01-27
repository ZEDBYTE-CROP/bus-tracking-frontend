import 'package:bustracker/Database/SharedPreferences.dart';
import 'package:bustracker/Model/Profile.dart';
import 'package:bustracker/Pages/Authentication/SignIn.dart';
import 'package:bustracker/Pages/Dashboard/Dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_framework/responsive_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Bus Tracker',
        builder: (context, child) {
          return ResponsiveWrapper.builder(child,
              maxWidth: 1200,
              minWidth: 480,
              defaultScale: true,
              breakpoints: [
                ResponsiveBreakpoint.resize(480, name: MOBILE),
                ResponsiveBreakpoint.autoScale(800, name: TABLET),
                ResponsiveBreakpoint.resize(1000, name: DESKTOP),
              ],
              background: Container(color: Color(0xFFF5F5F5)));
        },
        home: FutureBuilder<String?>(
            future: readUserProfile(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data == null || profileFromJson(snapshot.data!).claim != 2) {
                  return FutureBuilder(
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
                  );
                } else {
                  return SignIn();
                }
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }));
  }
}
