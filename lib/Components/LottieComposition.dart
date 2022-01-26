import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

Future<LottieComposition> lottieComposition(String asset) async {
  var assetData = await rootBundle.load(asset);
  return await LottieComposition.fromByteData(assetData);
}

Widget lottieAnimation(String asset) {
  return FutureBuilder(
    future: lottieComposition(asset),
    builder: (BuildContext context, AsyncSnapshot snapshot) {
      return (snapshot.hasData && snapshot.connectionState == ConnectionState.done)
          ? Center(
              child: Lottie(
                width: MediaQuery.of(context).size.width / 1.25,
                composition: snapshot.data,
              ),
            )
          : Container();
      // : Center(child: CircularProgressIndicator(color:Color(white)));
    },
  );
}
