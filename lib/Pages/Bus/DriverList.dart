import 'package:bustracker/Components/Container.dart';
import 'package:bustracker/Components/ExceptionScaffold.dart';
import 'package:bustracker/Components/Snackbar.dart';
import 'package:bustracker/Handler/Network.dart';
import 'package:bustracker/Model/Default.dart';
import 'package:bustracker/Model/DriverList.dart';
import 'package:bustracker/Model/Exception.dart';
import 'package:bustracker/Others/LottieString.dart';
import 'package:bustracker/Others/Routes.dart';
import 'package:bustracker/Style/Colors.dart';
import 'package:bustracker/Style/Text.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class DriverList extends StatefulWidget {
  final String busIdNumber;
  const DriverList({Key? key, required this.busIdNumber}) : super(key: key);

  @override
  _DriverListState createState() => _DriverListState();
}

class _DriverListState extends State<DriverList> {
  ValueNotifier<Tuple4> assignDriverValueNotifier = ValueNotifier<Tuple4>(Tuple4(-1, exceptionFromJson(alert), "Null", null));
  ValueNotifier<Tuple4> driverListValueNotifier = ValueNotifier<Tuple4>(Tuple4(0, exceptionFromJson(loading), "Loading", null));
  int page = 1;
  bool isLoading = false;
  List body = [];
  final ScrollController scrollController = ScrollController();

  Future driverListApiCall() async {
    return await ApiHandler().apiHandler(
      valueNotifier: driverListValueNotifier,
      jsonModel: driverListFromJson,
      url: driverListUrl,
      requestMethod: 1,
      body: {"page": page},
    ).whenComplete(() {
      if (driverListValueNotifier.value.item1 == 1) {
        if (mounted) {
          setState(() {
            body.addAll(driverListValueNotifier.value.item2.result);
          });
        }
      } else if (driverListValueNotifier.value.item1 == 2 || driverListValueNotifier.value.item1 == 3) {
        final snackBar = snackbar(content: driverListValueNotifier.value.item3);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }

  Future assignDriverApiCall({required String name, required String id}) async {
    return await ApiHandler().apiHandler(
      valueNotifier: assignDriverValueNotifier,
      jsonModel: defaultFromJson,
      url: assignDriverUrl,
      requestMethod: 1,
      body: {
        "busIdNumber": widget.busIdNumber,
        "busDriverName": name,
        "busDriverId": id,
      },
    );
  }

  @override
  void initState() {
    driverListApiCall();
    super.initState();
  }

  @override
  void dispose() {
    driverListValueNotifier.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: driverListValueNotifier,
        builder: (context, value, _) {
          return Scaffold(
            backgroundColor: Color(white),
            appBar: AppBar(
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Color(materialBlack),
                  )),
              backgroundColor: Color(white),
              title: Text(
                "Driver List",
                style: textStyle(),
              ),
            ),
            body: NestedScrollView(
              controller: scrollController,
              floatHeaderSlivers: true,
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                    sliver: SliverAppBar(
                      floating: true,
                      pinned: false,
                      snap: true,
                      forceElevated: innerBoxIsScrolled,
                      automaticallyImplyLeading: false,
                      backgroundColor: Color(white),
                    ),
                  )
                ];
              },
              body: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if ((isLoading == false && notification.metrics.axisDirection == AxisDirection.down && notification.metrics.pixels == notification.metrics.maxScrollExtent) ==
                      true) {
                    // if (driverListValueNotifier.value.item2.result.length == 10) {
                    if (!mounted) return false;
                    setState(() {
                      isLoading = true;
                      page += 1;
                    });
                    this.driverListApiCall().whenComplete(() {
                      if (!mounted) return;
                      setState(() {
                        isLoading = false;
                      });
                    });
                    // } else {
                    //   if (driverListValueNotifier.value.item2.result.length == 0 || driverListValueNotifier.value.item2.result.length < 10) {
                    //     final snackBar = snackbar(content: "End of Scroll!");
                    //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    //   }
                    // }
                  }
                  return true;
                },
                child: RefreshIndicator(
                    onRefresh: () async {
                      page = 1;
                      body.clear();
                      return await driverListApiCall();
                    },
                    child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: (body.isNotEmpty || driverListValueNotifier.value.item1 == 1)
                            ? Column(
                                children: [
                                  Expanded(
                                    child: ListView.builder(
                                        itemCount: body.length,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 20),
                                            child: GestureDetector(
                                              onTap: () async {
                                                return await assignDriverApiCall(name: body[index].name, id: body[index].idNumber.toString()).whenComplete(() {
                                                  if (assignDriverValueNotifier.value.item1 == 1) {
                                                    Navigator.pop(context, true);
                                                  } else if (assignDriverValueNotifier.value.item1 == 2 || assignDriverValueNotifier.value.item1 == 3) {
                                                    valueResetter(assignDriverValueNotifier);
                                                    final snackBar = snackbar(content: assignDriverValueNotifier.value.item3);
                                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                  }
                                                });
                                              },
                                              child: container(
                                                  padding: EdgeInsets.only(top: 15, bottom: 15, left: 10, right: 10),
                                                  bgColor: Color(materialBlack),
                                                  widget: Text(
                                                    "DRIVER NAME : " + body[index].name,
                                                    style: textStyle(color: Color(white), fontsize: 18, fontWeight: FontWeight.w600),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    softWrap: true,
                                                  )),
                                            ),
                                          );
                                        }),
                                  ),
                                  Container(
                                    height: (isLoading == true) ? 20.0 : 0,
                                    color: Colors.transparent,
                                    child: Center(
                                      child: new LinearProgressIndicator(
                                        color: Color(materialBlack),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : (driverListValueNotifier.value.item1 == 2 || driverListValueNotifier.value.item1 == 3)
                                ? exceptionScaffold(
                                    context: context,
                                    lottieString: driverListValueNotifier.value.item2!.lottieString,
                                    subtitle: driverListValueNotifier.value.item3,
                                    buttonTitle: "Try Again",
                                    goBack: false,
                                    onPressed: () async {
                                      return await driverListApiCall();
                                    })
                                : exceptionScaffold(
                                    context: context,
                                    lottieString: driverListValueNotifier.value.item2!.lottieString,
                                    subtitle: driverListValueNotifier.value.item3,
                                    goBack: false,
                                  ))),
              ),
            ),
          );
        });
  }
}
