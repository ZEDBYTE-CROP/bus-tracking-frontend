import 'package:location/location.dart';
import 'package:tuple/tuple.dart';

Future<Tuple3> getUserLocation() async {
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
