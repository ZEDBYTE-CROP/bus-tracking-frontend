import '../Components/FlatButton.dart';
import '../Components/LottieComposition.dart';
import '../Style/Colors.dart';
import '../Style/Text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

Widget exceptionScaffold(
    {required BuildContext context, required String lottieString, required String subtitle, Function()? onPressed, String buttonTitle = "Try Again", bool goBack = true}) {
  return Scaffold(
    backgroundColor: Color(white),
    resizeToAvoidBottomInset: false,
    appBar: (onPressed != null)
        ? AppBar(
            elevation: 0,
            backgroundColor: Color(white),
            automaticallyImplyLeading: false,
            leading: (goBack)
                ? IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.chevron_left,
                      color: Color(white),
                    ))
                : null,
          )
        : null,
    body: FutureBuilder(
      future: lottieComposition(lottieString),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return (snapshot.hasData && snapshot.connectionState == ConnectionState.done)
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: MediaQuery.of(context).size.width / 1.25,
                        child: Lottie(
                          composition: snapshot.data,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          subtitle,
                          style: GoogleFonts.montserratAlternates(textStyle: textStyle(color: Color(materialBlack))),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    (onPressed != null)
                        ? Align(
                            alignment: Alignment.center,
                            child: Padding(
                                padding: const EdgeInsets.only(top: 20, left: 50, right: 50),
                                child: flatButton(
                                  onPressed: onPressed,
                                  textStyle: GoogleFonts.montserratAlternates(textStyle: textStyle(fontsize: 20)),
                                  widget: Text(buttonTitle),
                                )),
                          )
                        : Container(),
                  ],
                ),
              )
            : Container();
      },
    ),
  );
}
