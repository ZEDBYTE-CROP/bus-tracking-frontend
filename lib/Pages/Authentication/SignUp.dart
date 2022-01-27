import 'package:bustracker/Assets/logo.dart';
import 'package:bustracker/Components/Container.dart';
import 'package:bustracker/Components/ExceptionScaffold.dart';
import 'package:bustracker/Components/FlatButton.dart';
import 'package:bustracker/Components/Snackbar.dart';
import 'package:bustracker/Components/TextFormField.dart';
import 'package:bustracker/Handler/Network.dart';
import 'package:bustracker/Model/BusList.dart';
import 'package:bustracker/Model/Default.dart';
import 'package:bustracker/Model/Exception.dart';
import 'package:bustracker/Others/LottieString.dart';
import 'package:bustracker/Others/Routes.dart';
import 'package:bustracker/Others/Structure.dart';
import 'package:bustracker/Pages/Authentication/SignIn.dart';
import 'package:bustracker/Pages/Dashboard/Dashboard.dart';
import 'package:bustracker/Style/Colors.dart';
import 'package:bustracker/Style/Text.dart';
import 'package:bustracker/Validator/Validator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuple/tuple.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  int optionIndex = 0;
  List<String> busNumberList = [];
  final _formKey = GlobalKey<FormState>();
  String? bloodGroup;
  String? busIdNumber;
  bool obscure = true;
  ValueNotifier<Tuple4> registerValueNotifier = ValueNotifier<Tuple4>(Tuple4(-1, exceptionFromJson(alert), "Null", null));
  ValueNotifier<Tuple4> busListValueNotifier = ValueNotifier<Tuple4>(Tuple4(0, exceptionFromJson(loading), "Loading", null));
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController phoneNumberTextEditingController = TextEditingController();
  TextEditingController idTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController confirmPasswordTextEditingController = TextEditingController();

  Future studentRegisterApiCall() async {
    return await ApiHandler().apiHandler(
      valueNotifier: registerValueNotifier,
      jsonModel: defaultFromJson,
      url: studentSignUpUrl,
      requestMethod: 1,
      body: {
        "name": nameTextEditingController.text,
        "phoneNumber": phoneNumberTextEditingController.text,
        "idNumber": idTextEditingController.text,
        "bloodGroup": bloodGroup,
        "busIdNumber": busIdNumber,
        "password": passwordTextEditingController.text
      },
    );
  }

  Future driverRegisterApiCall() async {
    return await ApiHandler().apiHandler(
      valueNotifier: registerValueNotifier,
      jsonModel: defaultFromJson,
      url: driverSignUpUrl,
      requestMethod: 1,
      body: {
        "name": nameTextEditingController.text,
        "phoneNumber": phoneNumberTextEditingController.text,
        "idNumber": idTextEditingController.text,
        "bloodGroup": bloodGroup,
        "password": passwordTextEditingController.text
      },
    );
  }

  Future busListApiCall() async {
    return await ApiHandler().apiHandler(
      valueNotifier: busListValueNotifier,
      jsonModel: busListFromJson,
      url: busListUrl,
      requestMethod: 1,
      body: {"page": "", "limit": "", "busIdNumber": ""},
    );
  }

  @override
  void dispose() {
    registerValueNotifier.dispose();
    nameTextEditingController.dispose();
    phoneNumberTextEditingController.dispose();
    idTextEditingController.dispose();
    passwordTextEditingController.dispose();
    confirmPasswordTextEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    busListApiCall().whenComplete(() {
      if (busListValueNotifier.value.item1 == 1) {
        for (int i = 0; i < busListValueNotifier.value.item2.result.length; i++) {
          busNumberList.add(busListValueNotifier.value.item2.result[i].busIdNumber);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder(
          valueListenable: busListValueNotifier,
          builder: (context, value, _) {
            if (busListValueNotifier.value.item1 == 1) {
              return Scaffold(
                backgroundColor: Color(white),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height / 10),
                        CustomPaint(
                          size: Size(250,
                              (250 * 0.7733421750663131).toDouble()), //You can Replace [WIDTH] with your desired width for Custom Paint and height will be calculated automatically
                          painter: LogoPainter(),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height / 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                              signUpClaimList.length,
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
                                          signUpClaimList[index],
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
                                textEditingController: nameTextEditingController,
                                hintStyle: GoogleFonts.montserrat(textStyle: textStyle(color: Color(grey))),
                                hintText: "Enter username",
                                validator: (value) => defaultValidator(value, "Name"),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: textFormField(
                                  textStyle: GoogleFonts.montserrat(textStyle: textStyle()),
                                  textEditingController: phoneNumberTextEditingController,
                                  keyboardType: TextInputType.phone,
                                  hintStyle: GoogleFonts.montserrat(textStyle: textStyle(color: Color(grey))),
                                  hintText: "Enter Phone Number",
                                  validator: (value) => phoneValidator(value),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: textFormField(
                                  textStyle: GoogleFonts.montserrat(textStyle: textStyle()),
                                  textEditingController: idTextEditingController,
                                  hintStyle: GoogleFonts.montserrat(textStyle: textStyle(color: Color(grey))),
                                  hintText: "Enter Id Number",
                                  validator: (value) => defaultValidator(value, "Id Number"),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: container(
                                    padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                                    bgColor: Color(white),
                                    border: true,
                                    shadow: false,
                                    widget: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                          value: bloodGroup,
                                          hint: Text(
                                            "Pick a Blood Group",
                                            style: GoogleFonts.montserratAlternates(textStyle: textStyle(color: Color(grey))),
                                          ),
                                          icon: Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: Color(materialBlack),
                                          ),
                                          isExpanded: true,
                                          onChanged: (String? value) {
                                            if (!mounted) return;
                                            setState(() {
                                              bloodGroup = value;
                                            });
                                          },
                                          dropdownColor: Color(white),
                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                          items: bloodGroupList
                                              .map((value) => DropdownMenuItem(
                                                  value: value,
                                                  child: Text(
                                                    value,
                                                    style: GoogleFonts.montserratAlternates(textStyle: textStyle(color: Color(materialBlack))),
                                                  )))
                                              .toList()),
                                    )),
                              ),
                              (optionIndex == 0)
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 15),
                                      child: container(
                                          padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                                          bgColor: Color(white),
                                          border: true,
                                          shadow: false,
                                          widget: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                                value: busIdNumber,
                                                hint: Text(
                                                  "Pick a Bus Number",
                                                  style: GoogleFonts.montserratAlternates(textStyle: textStyle(color: Color(grey))),
                                                ),
                                                icon: Icon(
                                                  Icons.keyboard_arrow_down_rounded,
                                                  color: Color(materialBlack),
                                                ),
                                                isExpanded: true,
                                                onChanged: (String? value) {
                                                  if (!mounted) return;
                                                  setState(() {
                                                    busIdNumber = value;
                                                  });
                                                },
                                                dropdownColor: Color(white),
                                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                                items: busNumberList
                                                    .map((value) => DropdownMenuItem(
                                                        value: value,
                                                        child: Text(
                                                          value,
                                                          style: GoogleFonts.montserratAlternates(textStyle: textStyle(color: Color(materialBlack))),
                                                        )))
                                                    .toList()),
                                          )),
                                    )
                                  : Container(),
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: textFormField(
                                    textStyle: GoogleFonts.montserrat(textStyle: textStyle()),
                                    textEditingController: passwordTextEditingController,
                                    obscureText: obscure,
                                    hintStyle: GoogleFonts.montserrat(textStyle: textStyle(color: Color(grey))),
                                    hintText: "Enter password",
                                    validator: (value) => defaultValidator(value, "Password"),
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
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: textFormField(
                                    textStyle: GoogleFonts.montserrat(textStyle: textStyle()),
                                    textEditingController: confirmPasswordTextEditingController,
                                    obscureText: obscure,
                                    hintStyle: GoogleFonts.montserrat(textStyle: textStyle(color: Color(grey))),
                                    hintText: "Confirm Password",
                                    validator: (value) => defaultValidator(value, "Password"),
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
                              onPressed: (registerValueNotifier.value.item1 == 0)
                                  ? null
                                  : () async {
                                      if (optionIndex == 0) {
                                        if (_formKey.currentState!.validate() && busIdNumber != null && bloodGroup != null) {
                                          if (passwordTextEditingController.text == confirmPasswordTextEditingController.text) {
                                            if (optionIndex == 0) {
                                              return await studentRegisterApiCall().whenComplete(() {
                                                if (registerValueNotifier.value.item1 == 1) {
                                                  Navigator.pop(context);
                                                } else if (registerValueNotifier.value.item1 == 2 || registerValueNotifier.value.item1 == 3) {
                                                  final snackBar = snackbar(content: registerValueNotifier.value.item3);
                                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                }
                                              });
                                            } else if (optionIndex == 1) {
                                              return await driverRegisterApiCall().whenComplete(() {
                                                if (registerValueNotifier.value.item1 == 1) {
                                                  Navigator.pop(context);
                                                } else if (registerValueNotifier.value.item1 == 2 || registerValueNotifier.value.item1 == 3) {
                                                  final snackBar = snackbar(content: registerValueNotifier.value.item3);
                                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                }
                                              });
                                            } else {
                                              return;
                                            }
                                          } else {
                                            final snackBar = snackbar(content: "Passwords do not match!");
                                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                          }
                                        } else {
                                          final snackBar = snackbar(content: "Fill out the required fields!");
                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                        }
                                      } else if (optionIndex == 1) {
                                        if (_formKey.currentState!.validate() && bloodGroup != null) {
                                          if (passwordTextEditingController.text == confirmPasswordTextEditingController.text) {
                                            if (optionIndex == 0) {
                                              return await studentRegisterApiCall().whenComplete(() {
                                                if (registerValueNotifier.value.item1 == 1) {
                                                  Navigator.pop(context);
                                                } else if (registerValueNotifier.value.item1 == 2 || registerValueNotifier.value.item1 == 3) {
                                                  final snackBar = snackbar(content: registerValueNotifier.value.item3);
                                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                }
                                              });
                                            } else if (optionIndex == 1) {
                                              return await driverRegisterApiCall().whenComplete(() {
                                                if (registerValueNotifier.value.item1 == 1) {
                                                  Navigator.pop(context);
                                                } else if (registerValueNotifier.value.item1 == 2 || registerValueNotifier.value.item1 == 3) {
                                                  final snackBar = snackbar(content: registerValueNotifier.value.item3);
                                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                }
                                              });
                                            } else {
                                              return;
                                            }
                                          } else {
                                            final snackBar = snackbar(content: "Passwords do not match!");
                                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                          }
                                        } else {
                                          final snackBar = snackbar(content: "Fill out the required fields!");
                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                        }
                                      }
                                    },
                              widget: (registerValueNotifier.value.item1 == 0) ? CircularProgressIndicator() : Text("Register")),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: flatButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              widget: Text("Login")),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height / 15),
                      ],
                    ),
                  ),
                ),
              );
            } else if (busListValueNotifier.value.item1 == 2 || busListValueNotifier.value.item1 == 3) {
              return exceptionScaffold(
                  context: context,
                  lottieString: busListValueNotifier.value.item2.lottieString,
                  subtitle: busListValueNotifier.value.item3,
                  goBack: false,
                  buttonTitle: "Try Again",
                  onPressed: () async {
                    await busListApiCall();
                  });
            } else {
              return exceptionScaffold(
                context: context,
                lottieString: busListValueNotifier.value.item2.lottieString,
                goBack: false,
                subtitle: busListValueNotifier.value.item3,
              );
            }
          }),
    );
  }
}
