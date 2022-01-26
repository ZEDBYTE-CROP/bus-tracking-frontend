import '../Components/Regex.dart';

String? defaultValidator(String? value, String type) {
  if (value == null || value.trim() == "" || value.isEmpty || value.length < 1) {
    return '$type should contain atleast 1 characters or above';
  }
  return null;
}

String? usernameValidator(String? value) {
  String userPattern = r'(^[a-zA-Z0-9]{6,12}$)';
  if (value == null || regex(pattern: userPattern, input: value) == false) {
    return 'Enter Username correctly';
  }
  return null;
}

String? passwordValidator(String? value) {
  String passwordPattern = r'(^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{6,12}$)';
  if (value == null || regex(pattern: passwordPattern, input: value) == false) {
    return 'Password should contain 6 to 12 characters, at least one uppercase letter, one lowercase letter and one number';
  }
  return null;
}

String? phoneValidator(String? value) {
  if (value == null || (int.tryParse(value) == null && int.tryParse(value).toString().length != 10)) {
    return 'Enter 10 digit Phone Number';
  }
  return null;
}

String? intValidator(String? value, String type) {
  if (value == null || (int.tryParse(value) == null && int.tryParse(value).toString().length < 1)) {
    return '$type must be numeric(integer) and should contain more than 1 digits!';
  }
  return null;
}
