import '../Others/Environment.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> writeUserPersistence(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return await prefs.setBool("${EnvironmentConfig.PERSISTENCE_KEY}", value);
}

Future<bool> readUserPersistence() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? value = prefs.getBool("${EnvironmentConfig.PERSISTENCE_KEY}");
  return value ?? false;
}

Future<bool> writeUserProfile(String profile) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setString("${EnvironmentConfig.PROFILE_KEY}", profile);
}

Future<String?> readUserProfile() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString("${EnvironmentConfig.PROFILE_KEY}");
}

Future<bool> writeBusDetails(String busDetails) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setString("${EnvironmentConfig.BUS_KEY}", busDetails);
}

Future<String?> readBusDetails() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString("${EnvironmentConfig.BUS_KEY}");
}
