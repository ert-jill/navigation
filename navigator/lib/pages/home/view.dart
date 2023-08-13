import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:line_icons/line_icon.dart';
import 'package:url_launcher/url_launcher.dart';

import 'index.dart';
import 'widgets/widgets.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      id: 'home',
      init: HomeController(),
      builder: (_) {
        return SafeArea(
          child: Scaffold(
            extendBodyBehindAppBar: true,
            // appBar: AppBar(title: const Text("Travel")),
            body: SafeArea(
              child: Stack(
                // mainAxisAlignment: MainAxisAlignment.start,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LayoutBuilder(builder:
                      (BuildContext context, BoxConstraints constraints) {
                    return SizedBox(
                      height: constraints.maxHeight * .6,
                      child: FlutterMap(
                        mapController:
                            controller.geoLocationService.mapController,
                        options: MapOptions(
                          onMapReady: () {
                            controller
                                .geoLocationService.mapController.mapEventStream
                                .listen((evt) {
                              print("EERT ----- " + evt.zoom.toString());
                            });
                            // And any other `MapController` dependent non-movement methods
                          },
                          center:
                              LatLng(10.372658699301972, 123.94772601070204),
                          zoom: 15,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.app',
                          ),

                          // Obx(() => PolylineLayer(
                          //       polylines: [
                          //         Polyline(
                          //           points: controller
                          //               .geoLocationService.routePoints.value,
                          //           color: Colors
                          //               .blue, // Set the color of the route line
                          //           strokeWidth:
                          //               5, // Set the width of the route line
                          //         ),
                          //       ],
                          //     )),
                          Obx(() => PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: controller
                                        .geoLocationService.travelPoints.value,
                                    color: Colors
                                        .green, // Set the color of the route line
                                    strokeWidth:
                                        5, // Set the width of the route line
                                  ),
                                ],
                              )),
                          //                       PolylineLayer(
                          //   polylines: isochronePolygons.map((polygon) => Polygon(
                          //     points: polygon,
                          //     color: Colors.blue.withOpacity(0.5), // Set the color and opacity of the isochrone polygons
                          //     borderColor: Colors.blue,
                          //     borderStrokeWidth: 1.0,
                          //   )).toList(),
                          // ),
                        ],
                      ),
                    );
                  }),
                  DraggableScrollableSheet(
                      initialChildSize: .4,
                      minChildSize: .4,
                      builder: (BuildContext context,
                          ScrollController scrollController) {
                        return Container(
                          color: Colors.black,
                          child: ListView.builder(
                              controller: scrollController,
                              itemCount: 1,
                              itemBuilder: ((context, index) {
                                return Container(
                                  color: Colors.black,
                                  height: 250,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 15, 0, 0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Center(
                                                      child: Text(
                                                        'Distance',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    Center(
                                                      child: Obx(() => Text(
                                                            "${(controller.geoLocationService.totalDistance.value / 1000).toPrecision(3)} \nkm",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Digital',
                                                                color: Colors
                                                                    .white,
                                                                height: 1,
                                                                fontSize: 25,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                  child: Obx(() => Switch(
                                                        // This bool value toggles the switch.
                                                        value: controller
                                                            .geoLocationService
                                                            .start
                                                            .value,
                                                        activeColor: Colors.red,
                                                        onChanged:
                                                            (bool value) {
                                                          // This is called when the user toggles the switch.
                                                          controller
                                                              .geoLocationService
                                                              .StartEndTravel(
                                                                  value);
                                                        },
                                                      )))
                                            ],
                                          ),
                                        ),
                                        // Expanded(
                                        //     child: Obx(() => Text('Current Position ' +
                                        //         controller.geoLocationService.value.value))),
                                        Column(
                                          children: [
                                            Center(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Color.fromARGB(
                                                          255, 39, 255, 46),
                                                      width: 5),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          140),
                                                  color: Colors.black,
                                                ),
                                                height: 140,
                                                width: 140,
                                                child: Column(
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          // Text('Speed'),
                                                          Obx(() => Text(
                                                                controller
                                                                    .geoLocationService
                                                                    .speed
                                                                    .toStringAsFixed(
                                                                        0),
                                                                maxLines: 1,
                                                                style: TextStyle(
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            39,
                                                                            255,
                                                                            46),
                                                                    fontFamily:
                                                                        'Digital',
                                                                    height: 1,
                                                                    fontSize:
                                                                        70,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )),
                                                          Text(
                                                            "km/h",
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        39,
                                                                        255,
                                                                        46),
                                                                fontFamily:
                                                                    'Digital',
                                                                height: 1.5,
                                                                fontSize: 25,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Expanded(
                                                    //   child: Column(
                                                    //     mainAxisAlignment: MainAxisAlignment.center,
                                                    //     crossAxisAlignment: CrossAxisAlignment.center,
                                                    //     children: [
                                                    //       // Center(
                                                    //       //   child: Text('Travel Distance'),
                                                    //       // ),
                                                    //       // Center(
                                                    //       //   child: Obx(() => Text((controller
                                                    //       //               .geoLocationService
                                                    //       //               .totalDistance
                                                    //       //               .value /
                                                    //       //           1000)
                                                    //       //       .toStringAsFixed(3))),
                                                    //       // ),
                                                    //     ],
                                                    //   ),
                                                    // ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                                child: Obx(() => Center(
                                                      child: controller
                                                              .geoLocationService
                                                              .start
                                                              .value
                                                          ? Container(
                                                              height: 60,
                                                              width: 85,
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .red,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30)),
                                                              child: Center(
                                                                child:
                                                                    IconButton(
                                                                        iconSize:
                                                                            40,
                                                                        color: Colors
                                                                            .white,
                                                                        onPressed:
                                                                            () {
                                                                          controller.geoLocationService.setPlayPause(!controller
                                                                              .geoLocationService
                                                                              .isPause
                                                                              .value);
                                                                        },
                                                                        icon: Obx(() => Icon(controller.geoLocationService.isPause.value
                                                                            ? Icons.play_arrow
                                                                            : Icons.pause))),
                                                              ),
                                                            )
                                                          : Container(),
                                                    )))
                                          ],
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Center(
                                                      child: Text(
                                                        'Elevation',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                    Center(
                                                      child: Obx(() => Text(
                                                            controller
                                                                    .geoLocationService
                                                                    .elevation
                                                                    .toStringAsFixed(
                                                                        0) +
                                                                "\nm",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Digital',
                                                                color: Colors
                                                                    .white,
                                                                height: 1,
                                                                fontSize: 25,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    // Center(
                                                    //   child: Text('Travel Distance'),
                                                    // ),
                                                    // Center(
                                                    //   child: Obx(() => Text((controller
                                                    //               .geoLocationService
                                                    //               .totalDistance
                                                    //               .value /
                                                    //           1000)
                                                    //       .toStringAsFixed(3))),
                                                    // ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              })),
                        );
                      })
                ],
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Colors.red,

              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: LineIcon.alternateMapMarked(),
                  label: 'Travel',
                  backgroundColor: Colors.red,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outlined),
                  label: 'Profile',
                  backgroundColor: Colors.red,
                  // backgroundColor: Colors.green,
                ),
                // BottomNavigationBarItem(
                //   icon: Icon(Icons.school),
                //   label: 'School',
                //   backgroundColor: Colors.purple,
                // ),
                // BottomNavigationBarItem(
                //   icon: Icon(Icons.settings),
                //   label: 'Settings',
                //   backgroundColor: Colors.pink,
                // ),
              ],
              currentIndex: 0,
              selectedItemColor: Colors.white,
              // onTap: _onItemTapped,
            ),
          ),
        );
      },
    );
  }
}
