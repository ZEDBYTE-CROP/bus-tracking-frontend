import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';

import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';
import 'package:bustracker/Components/Container.dart';
import 'package:bustracker/Components/ExceptionScaffold.dart';
import 'package:bustracker/Components/FlatButton.dart';
import 'package:bustracker/Components/Snackbar.dart';
import 'package:bustracker/Components/TextFormField.dart';
import 'package:bustracker/Database/SharedPreferences.dart';
import 'package:bustracker/Handler/Network.dart';
import 'package:bustracker/Model/AssignedBusList.dart';
import 'package:bustracker/Model/BusList.dart';
import 'package:bustracker/Model/Default.dart';
import 'package:bustracker/Model/DriverDetail.dart';
import 'package:bustracker/Model/Exception.dart';
import 'package:bustracker/Model/Profile.dart';
import 'package:bustracker/Model/UserBusDetail.dart';
import 'package:bustracker/Others/Lifecycle.dart';
import 'package:bustracker/Others/Location.dart';
import 'package:bustracker/Others/LottieString.dart';
import 'package:bustracker/Others/Routes.dart';
import 'package:bustracker/Others/location_service_repository.dart';
import 'package:bustracker/Pages/Bus/CreateBus.dart';
import 'package:bustracker/Pages/Bus/DriverList.dart';
import 'package:bustracker/Pages/Firestore/BusLocationCollection.dart';
import 'package:bustracker/Pages/Map/BusMap.dart';
import 'package:bustracker/Style/Colors.dart';
import 'package:bustracker/Style/Text.dart';
import 'package:bustracker/Validator/Validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import 'package:tuple/tuple.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  StreamController<LocationData> controller = StreamController<LocationData>();
  StreamSubscription<LocationData>? streamSubscription;
  bool isLoading = false;
  List body = [];

  final ScrollController scrollController = ScrollController();
  TextEditingController searchTextEditingController = TextEditingController();
  int page = 1;
  Profile? profile;
  ValueNotifier<Tuple4> sendAlertValueNotifier = ValueNotifier<Tuple4>(Tuple4(-1, exceptionFromJson(alert), "Null", null));
  ValueNotifier<Tuple4> unassignDriverValueNotifier = ValueNotifier<Tuple4>(Tuple4(-1, exceptionFromJson(alert), "Null", null));
  ValueNotifier<Tuple4> dashboardValueNotifier = ValueNotifier<Tuple4>(Tuple4(0, exceptionFromJson(loading), "Loading", null));

  TextEditingController reasonTextEditingController = TextEditingController();
  TextEditingController descriptionTextEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  LocationDto? lastLocation;
  bool? isRunning;
  ReceivePort port = ReceivePort();

  Future sendAlertApiCall(String name) async {
    return await ApiHandler().apiHandler(
      valueNotifier: sendAlertValueNotifier,
      jsonModel: defaultFromJson,
      url: sendAlertUrl,
      requestMethod: 1,
      body: {"name": name, "type": reasonTextEditingController.text, "description": descriptionTextEditingController.text},
    );
  }

  Future driverDetailApiCall(String idNumber) async {
    return await ApiHandler().apiHandler(
      valueNotifier: dashboardValueNotifier,
      jsonModel: driverDetailFromJson,
      url: driverDetailsUrl,
      requestMethod: 1,
      body: {"idNumber": idNumber},
    );
  }

  Future unassignDriverApiCall({required String busId, required String driverId}) async {
    return await ApiHandler().apiHandler(
      valueNotifier: unassignDriverValueNotifier,
      jsonModel: defaultFromJson,
      url: unassignDriverUrl,
      requestMethod: 1,
      body: {"busIdNumber": busId, "busDriverId": driverId},
    );
  }

  Future busListApiCall() async {
    return await ApiHandler().apiHandler(
      valueNotifier: dashboardValueNotifier,
      jsonModel: busListFromJson,
      url: busListUrl,
      requestMethod: 1,
      body: {
        "page": page,
        "limit": 10,
        "busIdNumber": searchTextEditingController.text,
      },
    ).whenComplete(() {
      if (dashboardValueNotifier.value.item1 == 1) {
        if (mounted) {
          setState(() {
            body.addAll(dashboardValueNotifier.value.item2.result);
          });
        }
      } else if (dashboardValueNotifier.value.item1 == 2 || dashboardValueNotifier.value.item1 == 3) {
        final snackBar = snackbar(content: dashboardValueNotifier.value.item3);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }

  Future assignedBusListApiCall() async {
    return await ApiHandler().apiHandler(
      valueNotifier: dashboardValueNotifier,
      jsonModel: assignedBusListFromJson,
      url: assignedBusListUrl,
      requestMethod: 1,
      body: {
        "page": page,
        "busIdNumber": searchTextEditingController.text,
      },
    ).whenComplete(() {
      if (dashboardValueNotifier.value.item1 == 1) {
        if (mounted) {
          setState(() {
            body.addAll(dashboardValueNotifier.value.item2.result);
          });
        }
      } else if (dashboardValueNotifier.value.item1 == 2 || dashboardValueNotifier.value.item1 == 3) {
        final snackBar = snackbar(content: dashboardValueNotifier.value.item3);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }

  initialiser() async {
    page = 1;
    body.clear();
    return await readUserProfile().then((value) {
      if (value == null) return;
      profile = profileFromJson(value);
    }).whenComplete(() async {
      if (profile!.claim == 0) {
        return await busListApiCall();
      } else if (profile!.claim == 2) {
        return await driverDetailApiCall(profile!.idNumber);
      } else {
        return await assignedBusListApiCall();
      }
    });
  }

  @override
  void initState() {
    initialiser();
    // WidgetsBinding.instance!.addObserver(LifecycleEventHandler(resumeCallBack: () async {
    //   await Location().hasPermission().then((value) async {
    //     if (value == PermissionStatus.granted || value == PermissionStatus.granted) {
    //       initialiser();
    //     }
    //   });
    // }));

    // if (IsolateNameServer.lookupPortByName(LocationServiceRepository.isolateName) != null) {
    //   IsolateNameServer.removePortNameMapping(LocationServiceRepository.isolateName);
    // }
    // IsolateNameServer.registerPortWithName(port.sendPort, LocationServiceRepository.isolateName);
    // port.listen(
    //   (dynamic data) async {
    //     await updateUI(data);
    //   },
    // );
    // initPlatformState();
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    sendAlertValueNotifier.dispose();
    dashboardValueNotifier.dispose();
    searchTextEditingController.dispose();
    reasonTextEditingController.dispose();
    descriptionTextEditingController.dispose();
    streamSubscription!.cancel();
    body.clear();
    super.dispose();
  }

  // Future<void> updateUI(data) async {
  //   if (data == null) {
  //     return;
  //   }
  //   // await BackgroundLocator.updateNotificationText(title: "BusTracker", msg: "Background Location is Running!", bigMsg: "BusTracker needs to access location in the background!");
  //   await BackgroundLocator.updateNotificationText(title: "BusTracker", msg: "${DateTime.now()}", bigMsg: "${data.latitude}, ${data.longitude}");
  // }

  // Future<void> initPlatformState() async {
  //   print('Initializing...');
  //   await BackgroundLocator.initialize();
  //   print('Initialization done');
  //   final _isRunning = await BackgroundLocator.isServiceRunning();
  //   if (!mounted) return;
  //   setState(() {
  //     isRunning = _isRunning;
  //   });
  //   print('Running ${isRunning.toString()}');
  // }

  // void onStop() async {
  //   await BackgroundLocator.unRegisterLocationUpdate();
  //   final _isRunning = await BackgroundLocator.isServiceRunning();
  //   if (!mounted) return;
  //   setState(() {
  //     isRunning = _isRunning;
  //   });
  // }

  // void onStart() async {
  //   await getLocation().then((value) async {
  //     if (value.item1 != null) {
  //       await getLiveLocation();
  //       final _isRunning = await BackgroundLocator.isServiceRunning();
  //       if (!mounted) return;
  //       setState(() {
  //         isRunning = _isRunning;
  //         lastLocation = null;
  //       });
  //     } else {
  //       log(isRunning.toString());
  //     }
  //   });
  // }

  onStart() async {
    Location location = new Location();
    String? busMapString = await readBusDetails();
    Map busMap = jsonDecode(busMapString!);
    location.enableBackgroundMode(enable: true);
    location.onLocationChanged.listen((event) async {
      controller.add(event);
    });
    if (streamSubscription != null) {
      if (streamSubscription!.isPaused) {
        streamSubscription!.resume();
      }
    } else {
      streamSubscription = controller.stream.listen((value) async {
        await updateBus(busNumber: busMap["busNumber"], busIdNumber: busMap["busIdNumber"], geoPoint: GeoPoint(value.latitude!, value.longitude!));
        print('Value from controller: $value');
      });
    }
  }

  onStop() async {
    if (streamSubscription != null) {
      streamSubscription!.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
          animation: Listenable.merge([dashboardValueNotifier, unassignDriverValueNotifier, sendAlertValueNotifier]),
          builder: (context, _) {
            if (profile != null) {
              if (profile!.claim == 0) {
                return Scaffold(
                    backgroundColor: Color(white),
                    appBar: AppBar(
                      backgroundColor: Color(white),
                      title: Text(
                        "Bus Tracker",
                        style: textStyle(),
                      ),
                    ),
                    floatingActionButton: FloatingActionButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => CreateBus())).then((value) async {
                          if (value == true) {
                            await initialiser();
                          }
                        });
                      },
                      backgroundColor: Color(materialBlack),
                      child: Icon(Icons.add),
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
                              bottom: PreferredSize(
                                preferredSize: Size.fromHeight(30.0),
                                child: Text(''),
                              ),
                              flexibleSpace: Center(
                                child: Padding(
                                    padding: const EdgeInsets.only(left: 20, right: 20),
                                    child: textFormField(
                                      textStyle: textStyle(),
                                      textEditingController: searchTextEditingController,
                                      hintText: "Search Bus Number",
                                      hintStyle: textStyle(color: Color(grey)),
                                      onFieldSubmitted: (value) async {
                                        page = 1;
                                        body.clear();
                                        return await busListApiCall();
                                      },
                                      suffixIcon: IconButton(
                                        onPressed: () async {
                                          page = 1;
                                          body.clear();
                                          return await busListApiCall();
                                        },
                                        icon: Icon(
                                          Icons.search,
                                          size: 35,
                                        ),
                                        color: Color(materialBlack),
                                      ),
                                    )),
                              ),
                            ),
                          )
                        ];
                      },
                      body: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if ((isLoading == false &&
                                  notification.metrics.axisDirection == AxisDirection.down &&
                                  notification.metrics.pixels == notification.metrics.maxScrollExtent) ==
                              true) {
                            // if (dashboardValueNotifier.value.item2.result.length == 10) {
                            if (!mounted) return false;
                            setState(() {
                              isLoading = true;
                              page += 1;
                            });
                            this.busListApiCall().whenComplete(() {
                              if (!mounted) return;
                              setState(() {
                                isLoading = false;
                              });
                            });
                            // }
                            // else {
                            //   if (dashboardValueNotifier.value.item2.result.length == 0 || dashboardValueNotifier.value.item2.result.length < 10) {
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
                              return await busListApiCall();
                            },
                            child: Padding(
                                padding: const EdgeInsets.only(left: 20, right: 20),
                                child: (body.isNotEmpty || dashboardValueNotifier.value.item1 == 1)
                                    ? Column(
                                        children: [
                                          Expanded(
                                            child: ListView.builder(
                                                itemCount: body.length,
                                                shrinkWrap: true,
                                                itemBuilder: (context, index) {
                                                  return Padding(
                                                    padding: const EdgeInsets.only(bottom: 20),
                                                    child: container(
                                                        padding: EdgeInsets.only(top: 15, bottom: 15, left: 10, right: 10),
                                                        bgColor: Color(materialBlack),
                                                        widget: Padding(
                                                          padding: const EdgeInsets.only(left: 10),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                "BUS ID : " + body[index].busIdNumber,
                                                                style: textStyle(color: Color(white), fontsize: 18, fontWeight: FontWeight.w600),
                                                                overflow: TextOverflow.ellipsis,
                                                                maxLines: 1,
                                                                softWrap: true,
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.only(top: 2.5),
                                                                child: Text(
                                                                  "BUS ROUTE : " + body[index].busRoute,
                                                                  style: textStyle(color: Color(white), fontsize: 18, fontWeight: FontWeight.w600),
                                                                  overflow: TextOverflow.ellipsis,
                                                                  maxLines: 1,
                                                                  softWrap: true,
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.only(top: 2.5),
                                                                child: Text(
                                                                  "BUS NO : " + body[index].busNumber,
                                                                  style: textStyle(color: Color(white), fontsize: 18),
                                                                  overflow: TextOverflow.ellipsis,
                                                                  maxLines: 1,
                                                                  softWrap: true,
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.only(top: 2.5),
                                                                child: Align(
                                                                  alignment: Alignment.center,
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                    children: [
                                                                      flatButton(
                                                                          backgroundColor: Color(white),
                                                                          primary: Color(materialBlack),
                                                                          onPressed: () {
                                                                            Navigator.push(
                                                                                context,
                                                                                MaterialPageRoute(
                                                                                    builder: (context) =>
                                                                                        BusMap(busNumber: body[index].busNumber, busIdNumber: body[index].busIdNumber)));
                                                                          },
                                                                          widget: Text("Location")),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(left: 10),
                                                                        child: flatButton(
                                                                            primary: Color(materialBlack),
                                                                            backgroundColor: Color(white),
                                                                            onPressed: (body[index].isAssigned == true)
                                                                                ? (unassignDriverValueNotifier.value.item1 == 0)
                                                                                    ? null
                                                                                    : () async {
                                                                                        return await unassignDriverApiCall(
                                                                                                busId: body[index].busIdNumber, driverId: body[index].busDriverId)
                                                                                            .whenComplete(() async {
                                                                                          if (unassignDriverValueNotifier.value.item1 == 1) {
                                                                                            page = 1;
                                                                                            body.clear();
                                                                                            valueResetter(unassignDriverValueNotifier);
                                                                                            return await busListApiCall();
                                                                                          } else if (unassignDriverValueNotifier.value.item1 == 2 ||
                                                                                              unassignDriverValueNotifier.value.item1 == 3) {
                                                                                            valueResetter(unassignDriverValueNotifier);
                                                                                            final snackBar = snackbar(content: unassignDriverValueNotifier.value.item3);
                                                                                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                                                          }
                                                                                        });
                                                                                      }
                                                                                : () {
                                                                                    Navigator.push(
                                                                                        context,
                                                                                        MaterialPageRoute(
                                                                                            builder: (context) => DriverList(
                                                                                                  busIdNumber: body[index].busIdNumber,
                                                                                                ))).whenComplete(() async {
                                                                                      page = 1;
                                                                                      body.clear();
                                                                                      return await busListApiCall();
                                                                                    });
                                                                                  },
                                                                            widget: Text((body[index].isAssigned == true) ? "Unassign Driver" : "Assign Driver")),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        )),
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
                                    : (dashboardValueNotifier.value.item1 == 2 || dashboardValueNotifier.value.item1 == 3)
                                        ? exceptionScaffold(
                                            context: context,
                                            lottieString: dashboardValueNotifier.value.item2!.lottieString,
                                            subtitle: dashboardValueNotifier.value.item3,
                                            buttonTitle: "Try Again",
                                            goBack: false,
                                            onPressed: () async {
                                              return await initialiser();
                                            })
                                        : exceptionScaffold(
                                            context: context,
                                            lottieString: dashboardValueNotifier.value.item2!.lottieString,
                                            subtitle: dashboardValueNotifier.value.item3,
                                            goBack: false,
                                          ))),
                      ),
                    ));
              } else if (profile!.claim == 2) {
                if (dashboardValueNotifier.value.item1 == 1) {
                  return Scaffold(
                    backgroundColor: Color(white),
                    appBar: AppBar(
                      backgroundColor: Color(white),
                      title: Text(
                        "Bus Tracker",
                        style: textStyle(),
                      ),
                    ),
                    body: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height / 15),
                            Text(
                              "CLICK THIS BUTTON TO UPDATE YOUR TRIP STATUS",
                              style: textStyle(),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  flatButton(
                                      onPressed: () async {
                                        return await writeBusDetails(busDetailToJson(BusDetail(
                                                busNumber: dashboardValueNotifier.value.item2.result.busNumber,
                                                busIdNumber: dashboardValueNotifier.value.item2.result.busIdNumber)))
                                            .whenComplete(() {
                                          onStart();
                                        });
                                      },
                                      widget: Text("Start Trip")),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: flatButton(
                                        onPressed: () async {
                                          return await updateBus(
                                                  busNumber: dashboardValueNotifier.value.item2.result.busNumber,
                                                  busIdNumber: dashboardValueNotifier.value.item2.result.busIdNumber,
                                                  geoPoint: null)
                                              .whenComplete(() {
                                            onStop();
                                          });
                                        },
                                        widget: Text("End Trip")),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height / 15),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    "ALERT EMERGENCY",
                                    style: textStyle(),
                                  ),
                                  Form(
                                      key: _formKey,
                                      child: Column(
                                        children: [
                                          textFormField(
                                            textStyle: GoogleFonts.montserrat(textStyle: textStyle()),
                                            textEditingController: reasonTextEditingController,
                                            hintStyle: GoogleFonts.montserrat(textStyle: textStyle(color: Color(grey))),
                                            hintText: "Enter Reason",
                                            validator: (value) => defaultValidator(value, "Reason"),
                                          ),
                                          textFormField(
                                            textStyle: GoogleFonts.montserrat(textStyle: textStyle()),
                                            textEditingController: descriptionTextEditingController,
                                            hintStyle: GoogleFonts.montserrat(textStyle: textStyle(color: Color(grey))),
                                            hintText: "Enter Description",
                                            validator: (value) => defaultValidator(value, "Description"),
                                          ),
                                        ],
                                      )),
                                  flatButton(
                                      onPressed: (sendAlertValueNotifier.value.item1 == 0)
                                          ? null
                                          : () async {
                                              if (_formKey.currentState!.validate()) {
                                                return await sendAlertApiCall(dashboardValueNotifier.value.item2.result.name).whenComplete(() {
                                                  if (sendAlertValueNotifier.value.item1 == 1) {
                                                    final snackBar = snackbar(content: sendAlertValueNotifier.value.item3);
                                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                    valueResetter(sendAlertValueNotifier);
                                                    reasonTextEditingController.clear();
                                                    descriptionTextEditingController.clear();
                                                  } else if (sendAlertValueNotifier.value.item1 == 2 || sendAlertValueNotifier.value.item1 == 3) {
                                                    final snackBar = snackbar(content: sendAlertValueNotifier.value.item3);
                                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                    valueResetter(sendAlertValueNotifier);
                                                  }
                                                });
                                              } else {
                                                final snackBar = snackbar(content: "Fill out the required fields!");
                                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                              }
                                            },
                                      widget: Text("SEND ALERT")),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("*USE THIS ONLY AT EMERGENCY"),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                } else if (dashboardValueNotifier.value.item1 == 2 || dashboardValueNotifier.value.item1 == 3) {
                  return exceptionScaffold(
                      context: context,
                      lottieString: dashboardValueNotifier.value.item2!.lottieString,
                      subtitle: dashboardValueNotifier.value.item3,
                      buttonTitle: "Try Again",
                      goBack: false,
                      onPressed: () async {
                        return await initialiser();
                      });
                } else {
                  return exceptionScaffold(
                    context: context,
                    lottieString: dashboardValueNotifier.value.item2!.lottieString,
                    subtitle: dashboardValueNotifier.value.item3,
                    goBack: false,
                  );
                }
              } else if (profile!.claim == 1) {
                return Scaffold(
                    backgroundColor: Color(white),
                    appBar: AppBar(
                      backgroundColor: Color(white),
                      title: Text(
                        "Bus Tracker",
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
                              bottom: PreferredSize(
                                preferredSize: Size.fromHeight(30.0),
                                child: Text(''),
                              ),
                              flexibleSpace: Center(
                                child: Padding(
                                    padding: const EdgeInsets.only(left: 20, right: 20),
                                    child: textFormField(
                                      textStyle: textStyle(),
                                      textEditingController: searchTextEditingController,
                                      hintText: "Search Bus Number",
                                      hintStyle: textStyle(color: Color(grey)),
                                      onFieldSubmitted: (value) async {
                                        page = 1;
                                        body.clear();
                                        return await assignedBusListApiCall();
                                      },
                                      suffixIcon: IconButton(
                                        onPressed: () async {
                                          page = 1;
                                          body.clear();
                                          return await assignedBusListApiCall();
                                        },
                                        icon: Icon(
                                          Icons.search,
                                          size: 35,
                                        ),
                                        color: Color(materialBlack),
                                      ),
                                    )),
                              ),
                            ),
                          )
                        ];
                      },
                      body: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if ((isLoading == false &&
                                  notification.metrics.axisDirection == AxisDirection.down &&
                                  notification.metrics.pixels == notification.metrics.maxScrollExtent) ==
                              true) {
                            // if (dashboardValueNotifier.value.item2.result.length == 10) {
                            if (!mounted) return false;
                            setState(() {
                              isLoading = true;
                              page += 1;
                            });
                            this.assignedBusListApiCall().whenComplete(() {
                              if (!mounted) return;
                              setState(() {
                                isLoading = false;
                              });
                            });
                            // } else {
                            //   if (dashboardValueNotifier.value.item2.result.length == 0 || dashboardValueNotifier.value.item2.result.length < 10) {
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
                              return await assignedBusListApiCall();
                            },
                            child: Padding(
                                padding: const EdgeInsets.only(left: 20, right: 20),
                                child: (body.isNotEmpty || dashboardValueNotifier.value.item1 == 1)
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
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => BusMap(busNumber: body[index].busNumber, busIdNumber: body[index].busIdNumber)));
                                                      },
                                                      child: container(
                                                          padding: EdgeInsets.only(top: 15, bottom: 15, left: 10, right: 10),
                                                          bgColor: Color(materialBlack),
                                                          widget: Padding(
                                                            padding: const EdgeInsets.only(left: 10),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  "BUS ID : " + body[index].busIdNumber,
                                                                  style: textStyle(color: Color(white), fontsize: 18, fontWeight: FontWeight.w600),
                                                                  overflow: TextOverflow.ellipsis,
                                                                  maxLines: 1,
                                                                  softWrap: true,
                                                                ),
                                                                Text(
                                                                  "DRIVER NAME : " + body[index].busDriverName,
                                                                  style: textStyle(color: Color(white), fontsize: 18, fontWeight: FontWeight.w600),
                                                                  overflow: TextOverflow.ellipsis,
                                                                  maxLines: 1,
                                                                  softWrap: true,
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 2.5),
                                                                  child: Text(
                                                                    "BUS ROUTE : " + body[index].busRoute,
                                                                    style: textStyle(color: Color(white), fontsize: 18, fontWeight: FontWeight.w600),
                                                                    overflow: TextOverflow.ellipsis,
                                                                    maxLines: 1,
                                                                    softWrap: true,
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 2.5),
                                                                  child: Text(
                                                                    "BUS NO : " + body[index].busNumber,
                                                                    style: textStyle(color: Color(white), fontsize: 18),
                                                                    overflow: TextOverflow.ellipsis,
                                                                    maxLines: 1,
                                                                    softWrap: true,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
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
                                    : (dashboardValueNotifier.value.item1 == 2 || dashboardValueNotifier.value.item1 == 3)
                                        ? exceptionScaffold(
                                            context: context,
                                            lottieString: dashboardValueNotifier.value.item2!.lottieString,
                                            subtitle: dashboardValueNotifier.value.item3,
                                            buttonTitle: "Try Again",
                                            goBack: false,
                                            onPressed: () async {
                                              return await initialiser();
                                            })
                                        : exceptionScaffold(
                                            context: context,
                                            lottieString: dashboardValueNotifier.value.item2!.lottieString,
                                            subtitle: dashboardValueNotifier.value.item3,
                                            goBack: false,
                                          ))),
                      ),
                    ));
              } else {
                return exceptionScaffold(
                  context: context,
                  lottieString: "assets/lottie/alert.json",
                  subtitle: "Out of Claim!!!",
                  goBack: false,
                );
              }
            } else {
              return exceptionScaffold(
                context: context,
                lottieString: "assets/lottie/loading.json",
                subtitle: "loading!",
                goBack: false,
              );
            }
          }),
    );
  }
}
