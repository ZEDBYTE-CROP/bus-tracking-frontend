import 'package:bustracker/Components/FlatButton.dart';
import 'package:bustracker/Components/Snackbar.dart';
import 'package:bustracker/Components/TextFormField.dart';
import 'package:bustracker/Handler/Network.dart';
import 'package:bustracker/Model/Default.dart';
import 'package:bustracker/Model/Exception.dart';
import 'package:bustracker/Others/LottieString.dart';
import 'package:bustracker/Others/Routes.dart';
import 'package:bustracker/Pages/Firestore/BusLocationCollection.dart';
import 'package:bustracker/Style/Colors.dart';
import 'package:bustracker/Style/Text.dart';
import 'package:bustracker/Validator/Validator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuple/tuple.dart';

class CreateBus extends StatefulWidget {
  const CreateBus({Key? key}) : super(key: key);

  @override
  _CreateBusState createState() => _CreateBusState();
}

class _CreateBusState extends State<CreateBus> {
  final _formKey = GlobalKey<FormState>();

  ValueNotifier<Tuple4> createBusValueNotifier = ValueNotifier<Tuple4>(Tuple4(-1, exceptionFromJson(alert), "Null", null));

  TextEditingController busNumberTextEditingController = TextEditingController();
  TextEditingController busIdNumberTextEditingController = TextEditingController();
  TextEditingController busRouteTextEditingController = TextEditingController();

  Future createBusApiCall() async {
    return await ApiHandler().apiHandler(
      valueNotifier: createBusValueNotifier,
      jsonModel: defaultFromJson,
      url: createBusUrl,
      requestMethod: 1,
      body: {
        "busNumber": busNumberTextEditingController.text,
        "busIdNumber": busIdNumberTextEditingController.text,
        "busRoute": busRouteTextEditingController.text,
      },
    );
  }

  @override
  void dispose() {
    busIdNumberTextEditingController.dispose();
    busNumberTextEditingController.dispose();
    busRouteTextEditingController.dispose();
    createBusValueNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(white),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Color(white),
          automaticallyImplyLeading: false,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
                color: Color(materialBlack),
              )),
          title: Text(
            "Create Bus",
            style: textStyle(),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      textFormField(
                        textStyle: GoogleFonts.montserrat(textStyle: textStyle()),
                        textEditingController: busNumberTextEditingController,
                        hintStyle: GoogleFonts.montserrat(textStyle: textStyle(color: Color(grey))),
                        hintText: "Enter bus number",
                        validator: (value) => defaultValidator(value, "Bus number"),
                      ),
                      textFormField(
                        textStyle: GoogleFonts.montserrat(textStyle: textStyle()),
                        textEditingController: busIdNumberTextEditingController,
                        hintStyle: GoogleFonts.montserrat(textStyle: textStyle(color: Color(grey))),
                        hintText: "Enter Bus Id Number",
                        validator: (value) => defaultValidator(value, "Bus id number"),
                      ),
                      textFormField(
                        textStyle: GoogleFonts.montserrat(textStyle: textStyle()),
                        textEditingController: busRouteTextEditingController,
                        hintStyle: GoogleFonts.montserrat(textStyle: textStyle(color: Color(grey))),
                        hintText: "Enter route",
                        validator: (value) => defaultValidator(value, "Route"),
                      ),
                    ],
                  ),
                ),
                flatButton(
                    onPressed: (createBusValueNotifier.value.item1 == 0)
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              return await createBusApiCall().whenComplete(() async {
                                if (createBusValueNotifier.value.item1 == 1) {
                                  await createBus(busNumber: busNumberTextEditingController.text, busIdNumber: busIdNumberTextEditingController.text);
                                  Navigator.pop(context, true);
                                } else if (createBusValueNotifier.value.item1 == 2 || createBusValueNotifier.value.item1 == 3) {
                                  final snackBar = snackbar(content: createBusValueNotifier.value.item3);
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                }
                              });
                            } else {
                              final snackBar = snackbar(content: "Fill out the required fields!");
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            }
                          },
                    widget: (createBusValueNotifier.value.item1 == 0) ? CircularProgressIndicator() : Text("Upload"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
