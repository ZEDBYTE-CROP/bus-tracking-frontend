import 'package:bustracker/Assets/logo.dart';
import 'package:bustracker/Components/Container.dart';
import 'package:bustracker/Components/FlatButton.dart';
import 'package:bustracker/Components/Snackbar.dart';
import 'package:bustracker/Components/TextFormField.dart';
import 'package:bustracker/Database/SharedPreferences.dart';
import 'package:bustracker/Handler/Network.dart';
import 'package:bustracker/Model/Default.dart';
import 'package:bustracker/Model/Exception.dart';
import 'package:bustracker/Model/Profile.dart';
import 'package:bustracker/Others/LottieString.dart';
import 'package:bustracker/Others/Routes.dart';
import 'package:bustracker/Others/Structure.dart';
import 'package:bustracker/Pages/Authentication/SignUp.dart';
import 'package:bustracker/Pages/Dashboard/Dashboard.dart';
import 'package:bustracker/Style/Colors.dart';
import 'package:bustracker/Style/Text.dart';
import 'package:bustracker/Validator/Validator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuple/tuple.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  int optionIndex = 0;
  final _formKey = GlobalKey<FormState>();

  bool obscure = true;
  ValueNotifier<Tuple4> loginValueNotifier = ValueNotifier<Tuple4>(Tuple4(-1, exceptionFromJson(alert), "Null", null));
  TextEditingController idTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  @override
  void dispose() {
    loginValueNotifier.dispose();
    idTextEditingController.dispose();
    passwordTextEditingController.dispose();
    super.dispose();
  }

  Future studentLoginApiCall() async {
    return await ApiHandler().apiHandler(
      valueNotifier: loginValueNotifier,
      jsonModel: defaultFromJson,
      url: studentLoginUrl,
      requestMethod: 1,
      body: {"idNumber": idTextEditingController.text, "password": passwordTextEditingController.text},
    );
  }

  Future adminLoginApiCall() async {
    return await ApiHandler().apiHandler(
      valueNotifier: loginValueNotifier,
      jsonModel: defaultFromJson,
      url: adminLoginUrl,
      requestMethod: 1,
      body: {"userName": idTextEditingController.text, "password": passwordTextEditingController.text},
    );
  }

  Future driverLoginApiCall() async {
    return await ApiHandler().apiHandler(
      valueNotifier: loginValueNotifier,
      jsonModel: defaultFromJson,
      url: driverLoginUrl,
      requestMethod: 1,
      body: {"idNumber": idTextEditingController.text, "password": passwordTextEditingController.text},
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: Color(white),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(children: [
                  SizedBox(height: MediaQuery.of(context).size.height / 10),
                  CustomPaint(
                    size: Size(
                        250, (250 * 0.7733421750663131).toDouble()), //You can Replace [WIDTH] with your desired width for Custom Paint and height will be calculated automatically
                    painter: LogoPainter(),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        signInClaimList.length,
                        (index) => GestureDetector(
                            onTap: () {
                              if (!mounted) return;
                              setState(() {
                                optionIndex = index;
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(10),
                                  width: MediaQuery.of(context).size.width / 4,
                                  bgColor: (index == optionIndex) ? Color(materialBlack) : Color(white),
                                  shadow: (index == optionIndex) ? true : false,
                                  border: true,
                                  borderColor: Color(materialBlack),
                                  widget: Text(
                                    signInClaimList[index],
                                    style: textStyle(color: (index == optionIndex) ? Color(white) : Color(materialBlack)),
                                  )),
                            ))),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 15),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        textFormField(
                          textStyle: GoogleFonts.montserrat(textStyle: textStyle()),
                          textEditingController: idTextEditingController,
                          hintStyle: GoogleFonts.montserrat(textStyle: textStyle(color: Color(grey))),
                          hintText: (optionIndex == 0) ? "Enter username" : "Enter idnumber",
                          validator: (value) => defaultValidator(value, (optionIndex == 0) ? "username" : "idnumber"),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: textFormField(
                              textStyle: GoogleFonts.montserrat(textStyle: textStyle()),
                              textEditingController: passwordTextEditingController,
                              obscureText: obscure,
                              hintStyle: GoogleFonts.montserrat(textStyle: textStyle(color: Color(grey))),
                              hintText: "Enter Password",
                              validator: (value) => defaultValidator(value, "Password"),
                              // validator: (value) => passwordValidator(value),
                              suffixIcon: GestureDetector(
                                  onTap: () {
                                    if (!mounted) return;
                                    setState(() {
                                      obscure = !obscure;
                                    });
                                  },
                                  child: Icon(
                                    (obscure == false) ? Icons.visibility : Icons.visibility_off,
                                    color: Color(grey),
                                  ))),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: flatButton(
                        onPressed: (loginValueNotifier.value.item1 == 0)
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  if (optionIndex == 0) {
                                    return await adminLoginApiCall().whenComplete(() async {
                                      if (loginValueNotifier.value.item1 == 1) {
                                        await writeUserProfile(profileToJson(Profile(claim: optionIndex, idNumber: idTextEditingController.text)));
                                        await writeUserPersistence(true);
                                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Dashboard()), (route) => false);
                                      } else if (loginValueNotifier.value.item1 == 2 || loginValueNotifier.value.item1 == 3) {
                                        final snackBar = snackbar(content: loginValueNotifier.value.item3);
                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                      }
                                    });
                                  } else if (optionIndex == 1) {
                                    return await studentLoginApiCall().whenComplete(() async {
                                      if (loginValueNotifier.value.item1 == 1) {
                                        await writeUserProfile(profileToJson(Profile(claim: optionIndex, idNumber: idTextEditingController.text)));
                                        await writeUserPersistence(true);
                                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Dashboard()), (route) => false);
                                      } else if (loginValueNotifier.value.item1 == 2 || loginValueNotifier.value.item1 == 3) {
                                        final snackBar = snackbar(content: loginValueNotifier.value.item3);
                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                      }
                                    });
                                  } else if (optionIndex == 2) {
                                    return await driverLoginApiCall().whenComplete(() async {
                                      if (loginValueNotifier.value.item1 == 1) {
                                        await writeUserProfile(profileToJson(Profile(claim: optionIndex, idNumber: idTextEditingController.text)));
                                        await writeUserPersistence(true);
                                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Dashboard()), (route) => false);
                                      } else if (loginValueNotifier.value.item1 == 2 || loginValueNotifier.value.item1 == 3) {
                                        final snackBar = snackbar(content: loginValueNotifier.value.item3);
                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                      }
                                    });
                                  } else {
                                    return;
                                  }
                                } else {
                                  final snackBar = snackbar(content: "Fill out the required fields!");
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                }
                              },
                        widget: (loginValueNotifier.value.item1 == 0) ? CircularProgressIndicator() : Text("Login")),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: flatButton(
                        onPressed: () {
                          return Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()));
                        },
                        widget: Text("SignUp")),
                  )
                ]),
              ),
            )));
  }
}
