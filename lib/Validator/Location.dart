import 'package:location/location.dart';
import 'package:tuple/tuple.dart';

Future locationValidator(Tuple3 value) async {
  if (value.item1 != null && value.item2 != false && value.item3 != PermissionStatus.denied && value.item3 != PermissionStatus.deniedForever) {
    return value;
  }
}
